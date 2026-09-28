# ADR-0010: Asynchronous processing and scheduling

- **Status:** Accepted
- **Date:** 2026-09-27

## Decision
- A **transactional outbox** (the `outbox_event` table) publishes domain events reliably. Spring `@Async` workers deliver webhooks, emails, and analytics events off the request path.
- Scheduled jobs use `@Scheduled` with **ShedLock backed by Postgres**. The jobs include the monthly secret shopper selection, the nightly identity reconciliation (ADR-0005), and sitemap regeneration.
- **There is no Redis in the MVP.** Rate limiting uses Postgres with Bucket4j's JDBC backend. Caching uses in-process Caffeine. Valkey (ElastiCache) can be added later without changing callers.

## Consequences
- There are fewer infrastructure components, and costs are lower (ADR-0014).
- Throughput is enough for MVP scale. Revisit caching and rate limiting when a second backend task is added.
