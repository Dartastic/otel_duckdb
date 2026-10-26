// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_duckdb_suppression.dart';

class DuckDBResult {
  /// Creates a result.
  const DuckDBResult({
    this.database,
    this.table,
    this.statementType,
    this.queryText,
    this.rowsAffected,
    this.elapsedMs,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? database;
  final String? table;
  final String? statementType;
  final String? queryText;
  final int? rowsAffected;
  final int? elapsedMs;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class DuckDBCallResult<T> {
  /// Creates a call result.
  const DuckDBCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final DuckDBResult? result;
}

Future<T> tracedDuckDB<T>({
  required String operation,
  required Future<DuckDBCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (duckdbInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_duckdb');
  final span = t.startSpan('duckdb $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('db.system.name', 'duckdb')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.database != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('db.namespace', res.database!)]));
      }
      if (res.table != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('db.collection.name', res.table!)]));
      }
      if (res.statementType != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('db.operation.name', res.statementType!)
        ]));
      }
      if (res.queryText != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('db.query.text', res.queryText!)]));
      }
      if (res.rowsAffected != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('db.response.returned_rows', res.rowsAffected!)
        ]));
      }
      if (res.elapsedMs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('db.duration', res.elapsedMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('duckdb.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'duckdb.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
