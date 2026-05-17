# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedDuckdb<T>(...)` — wraps a otel_duckdb call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutDuckdbInstrumentation()` / `Async()`.
