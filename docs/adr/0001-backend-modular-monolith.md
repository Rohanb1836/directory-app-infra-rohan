# ADR-0001: The backend is a Spring Boot modular monolith

- **Status:** Accepted
- **Date:** 2026-09-27

## Context
The MVP has 16 functional epics, one backend team, and moderate traffic. Running separate microservices would add operational cost with no benefit at this scale.

## Decision
- There is one deployable application: Spring Boot 3.x on Java 21, structured as a **modular monolith** with Spring Modulith.
- The modules are: `location`, `identity`, `taxonomy`, `listing`, `search`, `billing`, `payment`, `review`, `secretshopper`, `messaging`, `analytics`, `seo`, `admin`, and `notification`.
- Each module has `api`, `application`, `domain`, and `infrastructure` packages. Modules talk to each other only through `api` facades or domain events.
- A Spring Modulith verification test and ArchUnit rules enforce these boundaries on every build.

## Consequences
- The system is simple to deploy, test, and debug. Any module can be extracted into its own service later.
- Keeping the boundaries is a matter of discipline, backed by the build-time checks.
