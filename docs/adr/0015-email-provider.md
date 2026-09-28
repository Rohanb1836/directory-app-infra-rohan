# ADR-0015: Postmark for transactional email, Keycloak email, and the reply relay

- **Status:** Proposed (the provider needs to be confirmed; SendGrid is the alternative)
- **Date:** 2026-09-27 (updated for Keycloak)

## Decision
- **Application email** (receipts, dunning, review status, secret shopper notices, visitor messages) is sent through the Postmark API from the `notification` module.
- **Authentication email** (email verification, password reset, staff invite actions) is sent **by Keycloak over Postmark SMTP**, using a separate message stream. The email templates are part of the Keycloakify theme.
- **Replies to visitor messages** (E16) use Postmark inbound processing with a relay address for each thread.
- **Locally:** Mailpit captures all mail from both the application and Keycloak.

## Consequences
- There is one provider and one place to manage deliverability (SPF, DKIM, DMARC on `blackpages.io`). Authentication email is kept separate so it keeps a good sending reputation.
