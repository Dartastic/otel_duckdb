// Licensed under the Dartastic Pro Software License Agreement.
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

    test('DuckdbResult fields default null', () {
      const r = DuckdbResult();
      expect(r.statusCode, isNull);
    });
  });
}
