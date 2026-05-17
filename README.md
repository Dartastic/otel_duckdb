# otel_duckdb

Dartastic OpenTelemetry bridge for DuckDB (embedded analytics DB).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_duckdb/otel_duckdb.dart';

await tracedDuckdb<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return DuckdbCallResult(value: r, result: DuckdbResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutDuckdbInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
