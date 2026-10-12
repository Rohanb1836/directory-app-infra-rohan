# ADR-0001: The backend is a Spring Boot modular monolith

- **Status:** Accepted (module list amended 2026-09-30: `entitlement` added; 2026-10-06: `survey-insights` added, ADR-0022. Platform versions superseded by ADR-0018.)
- **Date:** 2026-09-27

## Context
The MVP has 16 functional epics, one backend team, and moderate traffic. Running separate microservices would add operational cost with no benefit at this scale.

## Decision
- There is one deployable application, structured as a **modular monolith** with Spring Modulith. The platform is **Spring Boot 4.1 on Java 25** (ADR-0018).
- The modules are: `location`, `identity`, `taxonomy`, `listing`, `search`, `billing`, `entitlement`, `payment`, `review`, `secretshopper`, `messaging`, `analytics`, `seo`, `admin`, `notification`, and `survey-insights` (16 in total). `entitlement` was split out of `billing` on 2026-09-30 so that the many modules that read entitlements don't depend on billing (see `docs/architecture/system-overview.md`, section 3).
- Each module has `api`, `application`, `domain`, and `infrastructure` packages. Modules talk to each other only through `api` facades or domain events.
- A Spring Modulith verification test and ArchUnit rules enforce these boundaries on every build.

## Consequences
- The system is simple to deploy, test, and debug. Any module can be extracted into its own service later.
- Keeping the boundaries is a matter of discipline, backed by the build-time checks.
