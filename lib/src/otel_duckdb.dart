// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_duckdb_suppression.dart';

class DuckDBResult {
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

class DuckDBCallResult<T> {
  const DuckDBCallResult({required this.value, this.result});
  final T value;
  final DuckDBResult? result;
}

Future<T> tracedDuckDB<T>({
  required String operation,
  required Future<DuckDBCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (duckDBInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_duckdb');
  final span = t.startSpan('duckdb $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('db.system.name', 'duckdb');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.database != null) {
        span.setStringAttribute('db.namespace', res.database!);
      }
      if (res.table != null) {
        span.setStringAttribute('db.collection.name', res.table!);
      }
      if (res.statementType != null) {
        span.setStringAttribute('db.operation.name', res.statementType!);
      }
      if (res.queryText != null) {
        span.setStringAttribute('db.query.text', res.queryText!);
      }
      if (res.rowsAffected != null) {
        span.setIntAttribute('db.response.returned_rows', res.rowsAffected!);
      }
      if (res.elapsedMs != null) {
        span.setIntAttribute('db.duration', res.elapsedMs!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('duckdb.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'duckdb.error',
        );
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
