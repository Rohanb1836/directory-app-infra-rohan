# ADR-0020: How backend events reach the UI (no live push in the MVP)

- **Status:** Accepted
- **Date:** 2026-10-06
- **Related:** ADR-0002, ADR-0006, ADR-0010 (outbox, no Redis), ADR-0014 (CloudFront and ALB), System Overview section 8.13, Frontend Architecture section 5.5, backlog story 2.23

## Context

Backend domain events, such as `ListingApproved`, `MessageReceived`, `ReviewsUnlocked`, and `PaymentSucceeded`, are published through the transactional outbox and handled **inside the backend** (ADR-0010). Users need to find out about some of them while they're on the site: an approved listing, a new message, a confirmed payment, a secret shopper assignment.

A live push channel (WebSockets or Server-Sent Events) would need:
- long-lived connections through CloudFront and the ALB, whose timeouts would require a separate route that bypasses the CDN;
- a way to reach users connected to any API task once there's more than one (Redis, Valkey, or Postgres `LISTEN/NOTIFY`), when the MVP deliberately has no Redis;
- handling and testing for reconnection and missed messages.

No MVP feature needs updates within seconds. A delay of up to a minute, backed by email, is enough.

## Decision

The UI learns about backend changes in **six ways**, and **no live push channel is built in the MVP**:

1. **The response to the user's own request.** A change returns the updated resource, and the UI invalidates the related TanStack Query data.
2. **Re-fetching** when the window regains focus, or on a timer, for data that other people or systems change (dashboards, admin queues).
3. **Rebuilding public pages:** the `seo` module calls the web app's internal `/_internal/revalidate` endpoint with cache tags, and invalidates CloudFront.
4. **Polling after a redirect** while waiting for Stripe webhooks, for example on the checkout return page.
5. **Email**, sent by the `notification` module, for users who aren't on the site.
6. **An in-app notification center** (story 2.23):
   - the `notification` module writes `user_notification` rows for selected events;
   - the UI shows a bell with an unread count, refreshed **every 60 seconds and when the tab regains focus**;
   - responses support `ETag`, so most refreshes return `304 Not Modified`.

**Upgrade path (post-MVP item P.12):** add `GET /api/notifications/stream` (Server-Sent Events), reading the same table, with Postgres `LISTEN/NOTIFY` or Valkey to reach every API task. Its route must bypass the CDN, with ALB idle timeouts adjusted. Polling stays as the fallback, so the UI and data model don't change.

## Consequences

**Positive**
- No extra infrastructure. It works the same with one API task or several.
- One table serves the bell, the dashboard, and a later push stream.
- Every event already produces an email, so nothing depends on users being online.

**Negative**
- Updates can be up to about 60 seconds late while users are on the site.
- Polling adds a small, predictable load, about one request per signed-in tab per minute. `ETag` and a cheap unread-count query keep it light.
