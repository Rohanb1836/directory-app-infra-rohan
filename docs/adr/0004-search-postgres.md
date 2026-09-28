# ADR-0004: Search uses PostgreSQL full-text search behind a SearchPort

- **Status:** Accepted
- **Date:** 2026-09-27

## Decision
- Search uses `tsvector` indexes, `pg_trgm` for fuzzy name matching, and PostGIS for radius and service-area filters.
- All search goes through a `SearchPort` interface in the `search` module, so the engine can be replaced (for example with OpenSearch) without changing the modules that call it.

## Consequences
- There is no extra infrastructure to run, which is enough for 50 locations at MVP volumes.
- Revisit if search p95 latency goes above 300 ms or relevance tuning outgrows Postgres.
