// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_duckdb/otel_duckdb.dart';

/// Traces Duckdb calls with OpenTelemetry.
///
/// `otel_duckdb` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Duckdb call in
/// [tracedDuckDB]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'duckdb-example');

  // Traces a Duckdb call.
  final duckDBId = await tracedDuckDB<String>(
    operation: 'create',
    invoke: () async {
      // Make the Duckdb call here, then report what it returned.
      const id = 'duckdb_8f3a2c';
      return const DuckDBCallResult(
          value: id,
          result: DuckDBResult(
              database: 'example',
              table: 'orders',
              statementType: 'active',
              queryText: 'example',
              rowsAffected: 1,
              elapsedMs: 120,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedDuckDB create returned $duckDBId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutDuckdbInstrumentationAsync.
  await runWithoutDuckdbInstrumentationAsync(
    () => tracedDuckDB<String>(
      operation: 'create',
      invoke: () async {
        const id = 'duckdb_8f3a2c';
        return const DuckDBCallResult(
            value: id,
            result: DuckDBResult(
                database: 'example',
                table: 'orders',
                statementType: 'active',
                queryText: 'example',
                rowsAffected: 1,
                elapsedMs: 120,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
