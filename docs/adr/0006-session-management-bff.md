# ADR-0006: The backend acts as the OIDC client, with server-side sessions

- **Status:** Accepted
- **Date:** 2026-09-27
- **Supersedes:** The draft of ADR-05 from the Sprint 0 proposal, which kept JWT access and refresh tokens in cookies
- **Related:** ADR-0005, ADR-0007, ADR-0002

## Context

Public pages are rendered on the server by Next.js for SEO (ADR-0002). The member dashboard and admin console also need the logged-in user during server rendering. The options are to keep OAuth tokens in the browser (a public single-page app client) or to keep them on the server.

Tokens in the browser are exposed to XSS attacks. They also complicate server rendering, and revoking access doesn't take effect until the token expires.

## Decision

1. **Spring Boot is the confidential OIDC client** (`blackpages-bff`). It uses Spring Security's `oauth2Login` with the authorization code flow and PKCE.
2. **Keycloak's tokens are stored only on the server**, inside the Spring Session record. Access tokens are refreshed by the server when needed.
3. **The browser gets one opaque session cookie**, `__Host-bp_session`, with HttpOnly, Secure, SameSite=Lax, and Path=/. Sessions are stored in Postgres with Spring Session JDBC, and Flyway manages that schema.
4. **The browser sees a single origin.** The ALB routes `blackpages.io/api/*` to Spring Boot and everything else to Next.js. During server rendering, Next.js forwards the visitor's `Cookie` header on backend calls. No CORS setup is needed.
5. **OAuth endpoints live under `/api`** so the ALB routes them to the backend:
   - Authorization start: `/api/auth/oauth2/authorization/keycloak`
   - Callback: `/api/auth/oauth2/code/keycloak`
   - `GET /api/auth/login?returnTo=` and `GET /api/auth/register?returnTo=` are friendly entry points. `returnTo` must be a relative path, which prevents open redirects.
6. **CSRF protection** uses Spring Security's cookie-based CSRF token, sent as the `X-XSRF-TOKEN` header on every request that changes data. The back-channel logout endpoint is exempt.
7. **Session lifetimes are enforced by the application**, independently of Keycloak's SSO session:
   - Members: 24 hours, or 30 days with remember-me. Renewed on each request.
   - Staff (ADMIN or SITE_OPERATOR): 30-minute idle timeout and an 8-hour maximum, applied at login according to the user's roles.
8. **Logout:**
   - `POST /api/auth/logout` ends the application session and redirects to Keycloak's end-session endpoint (RP-initiated logout).
   - Keycloak calls `/logout/connect/back-channel/keycloak` directly on the internal network, so sessions ended in Keycloak also end the matching application sessions.
9. **Future non-browser clients** (mobile, partner APIs) will use a second Spring Security filter chain that validates Keycloak access tokens sent as bearer tokens. This isn't built in the MVP.

## Consequences

**Positive**
- No tokens are exposed to browser JavaScript. Server rendering works with an ordinary cookie.
- Revocation is immediate: ending the application session blocks the next request.
- The frontend never handles OAuth; it only redirects to `/api/auth/login`.

**Negative**
- The backend is stateful. Sessions live in Postgres, so a session lookup is added to each authenticated request (with a short cache, this is negligible at MVP scale).
- Back-channel logout requires Keycloak to reach the backend over the internal network.

## Alternatives considered

- **A public PKCE client in the browser with tokens in memory:** rejected because of XSS exposure, poor server-rendering support, and delayed revocation.
- **Next.js as the OIDC client (Auth.js):** rejected because the backend would then have to validate tokens on every call, and authorization would be split across two runtimes.
