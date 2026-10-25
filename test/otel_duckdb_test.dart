// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_duckdb/otel_duckdb.dart';
import 'package:test/test.dart';

void main() {
  group('otel_duckdb', () {
    test('suppression toggles in zone', () async {
      expect(duckdbInstrumentationSuppressed(), isFalse);
      await runWithoutDuckdbInstrumentationAsync(() async {
        expect(duckdbInstrumentationSuppressed(), isTrue);
      });
      expect(duckdbInstrumentationSuppressed(), isFalse);
    });

    test('DuckDBResult fields default null', () {
      const r = DuckDBResult();
      expect(r.statusCode, isNull);
    });
  });
}
