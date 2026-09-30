# ADR-0018: Backend platform is Spring Boot 4.1 on Java 25

- **Status:** Accepted
- **Date:** 2026-09-30
- **Supersedes:** The platform versions in ADR-0001 (Spring Boot 3.x on Java 21)
- **Related:** ADR-0001, ADR-0006, ADR-0010, ADR-0012, ADR-0014

## Context

ADR-0001 chose a Spring Boot modular monolith on Spring Boot 3.x and Java 21. No code has been written yet, so this is the cheapest point to move to the current generation:

- **Java 25** is the current long-term support (LTS) release of Java.
- **Spring Boot 4.1.0** was released in June 2026, and **4.1.1** in August 2026. Boot 4 is a major version, built on Spring Framework 7, Spring Security 7, Jakarta EE 11 (Servlet 6.1), Jackson 3, and JUnit 6, with a new **modular** set of starters.

Starting on Boot 3.x would mean a platform migration within the first year, because Boot 3.5's open-source support ends in 2026.

## Decision

1. **Java 25 (LTS)** for the backend, built and run on **Eclipse Temurin 25**. Container images use the Temurin 25 JRE for **ARM64**, to match Fargate on Graviton (ADR-0014).
2. **Spring Boot 4.1.x**, pinned to the latest patch release through the parent POM (4.1.1 at the time of writing). Spring Boot's dependency management sets the versions of Spring Framework 7, Spring Security 7, Spring Data, Hibernate, Jackson 3, JUnit, and Testcontainers. **We don't override managed versions** unless a security fix requires it.
3. **Use the Boot 4 modular starters**, for example:
   - `spring-boot-starter-webmvc` (replacing `spring-boot-starter-web`)
   - `spring-boot-starter-security`
   - `spring-boot-starter-security-oauth2-client`
   - `spring-boot-starter-flyway`
   - `spring-boot-starter-validation`
   - the matching Spring Data JPA, Actuator, and Spring Session JDBC modules

   Tests use the matching `-test` starters, such as `spring-boot-starter-security-test`, which is needed for the `oidcLogin()` test support used by the authorization matrix (identity design, section 12). Exact names follow the Spring Boot 4 migration guide and reference documentation.
4. **Jackson 3** (`tools.jackson.*`) is the JSON library for our own code. Jackson 2 (`com.fasterxml.jackson.*`) must not be used in our code. It may still appear as a dependency of a third-party library, and an ArchUnit rule blocks our code from importing it.
5. **Call the Keycloak Admin REST API with Spring's `RestClient`**, behind `UserProvisioningPort` (identity design, section 6.4), rather than the `keycloak-admin-client` library. That keeps the backend on a single JSON stack and avoids pulling in an older HTTP client. The library can be reconsidered if the compatibility spike (story 0.7) shows it works cleanly.
6. **Virtual threads are enabled** (`spring.threads.virtual.enabled=true`) for request handling and `@Async` work. Most of our work is I/O-bound (Postgres, Stripe, Postmark, Keycloak). Java 24 and later no longer pin virtual threads inside `synchronized` blocks, which makes this safer with JDBC drivers and libraries. Connection pool sizes stay the real limit on concurrency.
7. **Compatible libraries:** every third-party library on the backend must officially support **Java 25 bytecode and Spring Boot 4**. This includes JaCoCo, PIT, Mockito and Byte Buddy, ArchUnit, Spring Modulith, ShedLock, Bucket4j, openapi-generator's Spring generator, `testcontainers-keycloak`, and the Stripe Java SDK. The versions are confirmed and pinned in the Sprint 0 compatibility spike (backlog story 0.7).
8. **Upgrades:** apply Spring Boot patch releases promptly. Move to each new Spring Boot minor release within its open-source support window. Stay on Java 25 until the next LTS release is available and supported by Spring Boot.

## Consequences

**Positive**
- There's no platform migration during the first year of the product.
- Current Spring Security 7 and Spring Framework 7 features and fixes are available from day one.
- Virtual threads make simple blocking code scale well on small Fargate tasks.
- The modular starters produce a smaller, more explicit set of dependencies.

**Negative and risks**
- **Some libraries lag behind major releases.** Generators, test tools, and SDKs may need specific versions for Java 25 and Boot 4, which story 0.7 checks before Sprint 1.
- **Jackson 3 changes package names and some APIs** compared with Jackson 2. Examples and snippets written for Boot 3 need adjusting.
- **Spring Security 7 examples** online are fewer than for 6.x. The identity design's security configuration (section 6.3) must be checked against the Spring Security 7 reference documentation during Sprint 1.
- **Claude Code and other AI tools** tend to produce Boot 3 idioms (for example `spring-boot-starter-web`, or Jackson 2 imports). Each repository's `CLAUDE.md` must state the platform versions and these rules explicitly.

## Alternatives considered

| Option | Reason rejected |
|---|---|
| Spring Boot 3.5 on Java 21 | Its open-source support ends in 2026, which would force a major migration shortly after launch |
| Spring Boot 4.0 | 4.1 is the current minor release. 4.0's support window is shorter. |
| Java 21 (the previous LTS) | Java 25 is the current LTS and is supported by Spring Boot 4.1 |
