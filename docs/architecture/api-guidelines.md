# BlackPages.io: API Style Guide

| | |
|---|---|
| **Version** | 1.3 (2026-10-06: `/api/integration/` paths for service-to-service calls, ADR-0022. v1.2: section 12.2, the activity events endpoint and its CSRF exemption, ADR-0021. v1.1: section 12.1, polling and notifications.) |
| **Date** | 2026-09-30 |
| **Status** | Draft for review by both tech leads before Sprint 1 |
| **Applies to** | `contract/openapi.yaml` in `directory-app-svc`, and every endpoint the backend serves |
| **Related** | ADR-0006 (sessions), ADR-0007 (authorization), ADR-0012 (contract-first API), ADR-0018 (backend platform), System Overview v1.2 section 8.6, Frontend Architecture v1.0 |

Both teams follow these rules when designing and reviewing the API contract. The goal is an API that's **predictable** (every endpoint works the same way), **safe to change** (no surprise breaking changes), and **easy to generate code from** (for both the Spring interfaces and the TypeScript client).

---

## 1. Principles
1. **The contract comes first.** Changes to `openapi.yaml` are agreed by both teams and merged **before** implementation starts (ADR-0012).
2. **Resource-oriented.** URLs name things, and HTTP methods say what's done to them. Actions that don't fit (submitting for approval, changing a tier) are modeled as sub-resources.
3. **Consistent over clever.** If two endpoints do similar things, they look the same.
4. **Changes are additive.** Breaking changes are rare, versioned, and announced (section 13).
5. **Secure by default.** Every operation has a documented access rule, an entry in the authorization matrix, and a 404 for anything outside the caller's scope.

---

## 2. Change workflow

| Step | Who | What |
|---|---|---|
| 1 | Either team | Opens a pull request to `contract/openapi.yaml`, linked to the story issue |
| 2 | Both tech leads | Review it against the checklist in section 16. **Both must approve.** |
| 3 | CI | Lints with the BlackPages ruleset (Spectral), runs **openapi-diff** for breaking changes, and generates the Spring interfaces and the TypeScript client |
| 4 | Merge | CI publishes a new `@blackpages/api-client` version and regenerates the MSW mocks |
| 5 | Frontend | Builds against the mocks straight away |
| 6 | Backend | Implements the generated interface, and adds the operation to `authz-matrix.yaml` (ADR-0007) |

**Definition of Ready** for a story that touches the API: step 4 is done before the sprint starts.

---

## 3. URLs

### 3.1 Base paths by audience

| Prefix | Audience | Authentication | Examples |
|---|---|---|---|
| `/api/public/` | Anyone | None. CAPTCHA and rate limits where needed. | `/api/public/directory`, `/api/public/listings/by-slug/{slug}`, `/api/public/pricing`, `/api/public/events` |
| `/api/auth/` | Browser redirects and session | Varies | `/api/auth/login`, `/api/auth/logout`, `/api/auth/me` |
| `/api/` (no prefix) | Signed-in members | Session | `/api/listings/{listingId}`, `/api/business-accounts/{accountId}/listings` |
| `/api/admin/` | Staff only (MFA verified) | Session plus staff role | `/api/admin/listings/pending`, `/api/admin/listing-tiers` |
| `/api/webhooks/` | Stripe and Postmark | Signature verification, **not** a session | `/api/webhooks/stripe`, `/api/webhooks/postmark` |
| `/api/integration/v1/` | **Other services**, such as the survey app (ADR-0022) | **Keycloak client-credentials bearer token** with the required client role. **No session, cookies, or CSRF.** | `/api/integration/v1/locations`, `/api/integration/v1/survey-recipients` |

Webhook and OAuth callback endpoints aren't part of the public contract that the client is generated from. They're documented in a separate `openapi-internal.yaml`. **Integration endpoints** have their own contract, `contract/openapi-integration.yaml`, versioned in the path (`/v1/`), because other teams build against them. Breaking changes need a `/v2/` path running alongside `/v1/` until callers have moved.

### 3.2 Naming
- **Plural nouns**, **kebab-case** segments: `/business-accounts`, `/listing-tiers`, `/secret-shopper-assignments`.
- **Path parameters** are camelCase and specific: `{listingId}`, `{accountId}`, not `{id}`.
- **At most one level of nesting**, and only where the child can't exist without the parent: `/business-accounts/{accountId}/listings`. Address an item by its own ID after that: `/listings/{listingId}`.
- **Public pages use slugs; everything else uses IDs:** `/api/public/listings/by-slug/{slug}`, and `/api/listings/{listingId}` for owners.
- **Actions** that aren't plain CRUD are sub-resources named with a noun or verb phrase, used with `POST`:

  | Action | Endpoint |
  |---|---|
  | Submit a listing for approval | `POST /api/listings/{listingId}/submission` |
  | Upgrade, or schedule a downgrade | `POST /api/listings/{listingId}/tier-change` |
  | Cancel a scheduled downgrade | `DELETE /api/listings/{listingId}/tier-change` |
  | Approve or reject (staff) | `POST /api/admin/listings/{listingId}/approval`, `POST /api/admin/listings/{listingId}/rejection` |

- **No file extensions, no trailing slashes, no verbs in resource paths** (`/getListings` is never acceptable).

---

## 4. HTTP methods and status codes

| Method | Use | Success status | Request body | Idempotent |
|---|---|---|---|---|
| `GET` | Read | 200 | None | Yes |
| `POST` | Create, or run an action | 201 with a `Location` header (create); 200 or 202 (action) | Yes | No, unless it has an `Idempotency-Key` (section 10) |
| `PUT` | Replace a whole resource or a whole sub-collection (for example, all of a listing's hours) | 200 | Yes | Yes |
| `PATCH` | Partial update with **JSON Merge Patch** (`application/merge-patch+json`) | 200 | Yes | No |
| `DELETE` | Remove | 204 | None | Yes |

| Status | When |
|---|---|
| 200 / 201 / 202 / 204 | As above. Use 202 only for work that finishes later (section 12). |
| 400 | The request is malformed or fails validation (`VALIDATION_FAILED`) |
| 401 | No valid session (`UNAUTHENTICATED`) |
| 402 | The account has lapsed and must pay before continuing (`ACCOUNT_LAPSED`) |
| 403 | Signed in and **allowed to see** the resource, but the action is blocked: onboarding not done, staff MFA not set up, or a feature the listing's tier doesn't include (section 8) |
| 404 | The resource doesn't exist **or is outside the caller's scope**. Never 403 for another account's data (ADR-0007). |
| 409 | Version conflict (section 9), or a state conflict such as approving an already-approved listing |
| 412 | Reserved for an `If-Match` precondition, if it's introduced later |
| 422 | Valid request that breaks a business rule, such as reaching a tier limit (`ENTITLEMENT_LIMIT_REACHED`) or reusing an idempotency key with a different body |
| 429 | Rate limited, with `Retry-After` |
| 500 / 503 | An unexpected error, or a dependency such as Stripe or Keycloak isn't available |

---

## 5. Request and response bodies

| Topic | Rule |
|---|---|
| Format | JSON (`application/json`). Errors use `application/problem+json`. |
| Property names | **camelCase**: `businessAccountId`, `tierRank` |
| Enum values | **UPPER_SNAKE_CASE**: `SILVER`, `GOLD`, `PLATINUM`; `BUSINESS`, `SHOPPER`; `PENDING_APPROVAL` |
| IDs | UUID strings, with the name ending in `Id` (`listingId`). Never expose database sequence numbers. |
| Timestamps | ISO 8601 in **UTC** with `Z`: `"2026-09-30T14:05:00Z"`. Names end in `At`: `createdAt`, `reviewsUnlockedAt`. |
| Calendar dates | `"2026-10-01"`. Names end in `Date` or `On`. |
| Local times and time zones | Business hours are `"HH:mm"` strings, plus the listing's IANA `timeZone` (`"America/Phoenix"`). Never convert hours to UTC. |
| Money | An object: `{ "amountCents": 1299, "currency": "USD" }`. **Never floating point.** Names describe the amount: `tierPrice`, `discountAmount`, `serviceFee`, `total`. |
| Percentages | Whole numbers 0–100 in a field ending `Percent`: `discountPercent: 50` |
| Geography | `{ "lat": 33.4484, "lng": -112.0740 }` |
| Booleans | Plain adjectives or `has`/`is` where it reads better: `hideAddress`, `isDefault`, `hasUnreadMessages` |
| Missing values | Optional properties that have no value are **omitted** from responses, not sent as `null`. `null` is used in `PATCH` requests only, to clear a field (JSON Merge Patch). |
| Single resources | Returned directly, with **no wrapper object** |
| Collections | Always wrapped (section 6). Never a bare JSON array. |
| Large text | Plain text, or the restricted rich-text format set by the backend. Never raw HTML from users. |
| Personal data | Only the minimum. Never return another user's email address. Reviews show the author's display name only. |

**Example: a listing as its owner sees it**
```json
{
  "listingId": "4f7c2a9e-3b1d-4c55-9a0e-1d2f3b4c5d6e",
  "businessAccountId": "9a1b2c3d-4e5f-4a6b-8c7d-0e1f2a3b4c5d",
  "slug": "acme-plumbing-phoenix",
  "name": "Acme Plumbing",
  "tier": "GOLD",
  "isDefault": true,
  "status": "PUBLISHED",
  "cityId": "1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f",
  "timeZone": "America/Phoenix",
  "tierPrice": { "amountCents": 2900, "currency": "USD" },
  "pendingTierChange": { "tier": "SILVER", "effectiveAt": "2026-11-01T07:00:00Z" },
  "reviewsUnlockedAt": "2026-09-12T18:30:00Z",
  "version": 7,
  "createdAt": "2026-08-01T16:00:00Z",
  "updatedAt": "2026-09-29T21:14:00Z"
}
```

---

## 6. Pagination

| Style | Use for | Request | Response |
|---|---|---|---|
| **Page-based** | Public directory and search results, which need crawlable page numbers | `?page=1&size=25`. Pages start at 1. `size` defaults to 25, with a maximum of 100. | `{ "items": [...], "page": { "number": 1, "size": 25, "totalItems": 312, "totalPages": 13 } }` |
| **Cursor-based** | Dashboards, admin lists, messages, analytics, and anything that changes often | `?cursor=…&limit=50`. `limit` defaults to 50, with a maximum of 200. | `{ "items": [...], "nextCursor": "eyJ…" }`. `nextCursor` is omitted on the last page. |

Cursors are opaque strings. Clients must never build or parse them.

---

## 7. Filtering, sorting, and search
- **Filters** are query parameters named after the property: `?status=PENDING_APPROVAL&cityId=…`.
- **Several values** for one filter repeat the parameter: `?tier=GOLD&tier=PLATINUM`.
- **Ranges** use `From` and `To` suffixes: `?createdFrom=2026-09-01&createdTo=2026-09-30`.
- **Sorting** uses `?sort=name` (ascending) or `?sort=-createdAt` (descending), with commas for several fields. **Each endpoint documents the sort fields it allows.** Anything else returns `VALIDATION_FAILED`.
- **Directory and search results always use the fixed tier ordering** (SPEC-BILL-01, section 7). Their `sort` parameter, if any, can't override the order of tiers.
- **Free-text search** uses `q`: `GET /api/public/search?q=tankless+plumber&cityId=…`.

---

## 8. Errors (RFC 9457 Problem Details)

Every error response uses `application/problem+json` with these fields:

| Field | Always present | Meaning |
|---|---|---|
| `type` | Yes | `https://blackpages.io/problems/{code in kebab-case}` |
| `title` | Yes | A short, fixed summary of the code |
| `status` | Yes | The HTTP status |
| `code` | Yes | **A stable, machine-readable code.** Clients act on this, never on `title` or `detail`. |
| `detail` | Optional | An explanation for this occurrence. Never includes internal details or stack traces. |
| `instance` | Optional | The request path |
| `traceId` | Yes | For support and log search |
| `errors` | For `VALIDATION_FAILED` | `[{ "field": "phone", "code": "INVALID_FORMAT", "message": "…" }]`. Fields use JSON Pointer-style paths for nested data: `hours/0/opens`. |

Some codes add more fields, for example `entitlement`, `limit`, `used`, `upgradeTo`, and `listingId` for entitlement errors (SPEC-BILL-01, section 11).

### 8.1 Error codes

| Code | Status | Meaning |
|---|---|---|
| `VALIDATION_FAILED` | 400 | One or more fields are invalid. See `errors[]`. |
| `UNAUTHENTICATED` | 401 | No valid session |
| `ACCOUNT_LAPSED` | 402 | The account's payment has lapsed beyond the grace period |
| `ONBOARDING_REQUIRED` | 403 | The user must finish onboarding first |
| `EMAIL_NOT_VERIFIED` | 403 | The action needs a verified email address |
| `STAFF_MFA_REQUIRED` | 403 | A staff action needs MFA to be set up and verified |
| `ENTITLEMENT_NOT_INCLUDED` | 403 | The listing's tier or the account's type doesn't include the feature |
| `NOT_FOUND` | 404 | The resource doesn't exist, or the caller can't access it |
| `CONFLICT` | 409 | The `version` sent doesn't match the current one (section 9) |
| `INVALID_STATE` | 409 | The action isn't allowed in the resource's current state, such as approving an approved listing or downgrading a Silver listing |
| `ENTITLEMENT_LIMIT_REACHED` | 422 | A tier limit has been reached, such as the gallery photo limit |
| `BUSINESS_RULE_VIOLATED` | 422 | Another business rule is broken. `detail` explains it, and `rule` gives the rule ID, for example `BR-PE-06` (can't delete the last listing). |
| `IDEMPOTENCY_KEY_REUSED` | 422 | The same `Idempotency-Key` was used with a different request body |
| `PAYLOAD_TOO_LARGE` | 413 | The request body is over the endpoint's size limit (for example, more than 50 events or 32 KB on `/api/public/events`) |
| `RATE_LIMITED` | 429 | Too many requests. See `Retry-After`. |
| `UPSTREAM_UNAVAILABLE` | 503 | A dependency (Stripe, Keycloak, Postmark, Google) isn't available. It's safe to retry later. |
| `INTERNAL_ERROR` | 500 | An unexpected error. Use `traceId` to report it. |

**Adding a code** needs a pull request to this table and to the shared `Problem` schema in the contract. **Codes are never renamed or reused.**

**Example**
```json
{
  "type": "https://blackpages.io/problems/entitlement-limit-reached",
  "title": "Listing tier limit reached",
  "status": 422,
  "code": "ENTITLEMENT_LIMIT_REACHED",
  "detail": "This Gold listing already has 3 photos.",
  "instance": "/api/listings/4f7c2a9e-3b1d-4c55-9a0e-1d2f3b4c5d6e/media",
  "traceId": "0af7651916cd43dd8448eb211c80319c",
  "listingId": "4f7c2a9e-3b1d-4c55-9a0e-1d2f3b4c5d6e",
  "entitlement": "listing.gallery.max_photos",
  "limit": 3,
  "used": 3,
  "upgradeTo": "PLATINUM"
}
```

---

## 9. Concurrency
- Resources that people edit (listings, hours, discounts, tier configuration, surveys) include an integer **`version`**.
- `PUT` and `PATCH` requests **must** send the `version` they were based on. A mismatch returns **409 `CONFLICT`** with the current version, and the UI offers to reload (Frontend Architecture, section 7).
- This maps directly to JPA optimistic locking (`@Version`) in the backend.

---

## 10. Idempotency
- Requests that **create a charge or a billing change** must send an **`Idempotency-Key`** header, a client-generated UUID. These are:
  - adding a listing;
  - changing a tier, or canceling a scheduled downgrade;
  - starting checkout;
  - applying a discount code.
- The backend stores each key with a hash of the request for **24 hours**:
  - the same key and body returns the **original response**, without repeating the action;
  - the same key with a different body returns **422 `IDEMPOTENCY_KEY_REUSED`**.
- The key is passed on to Stripe's own idempotency mechanism.
- `PUT` and `DELETE` are naturally idempotent and don't need the header.

---

## 11. Security rules for every operation
1. **Each operation's description** in the contract states who can call it: for example, "Owner of the listing's business account" or "Admin; site operator for assigned locations".
2. **Every operation has an entry in `authz-matrix.yaml`.** CI fails if one is missing (ADR-0007, backlog 2.12).
3. **Calls that change data** from the browser must send `X-XSRF-TOKEN`. There are **two exemptions**: webhooks, which are verified by signature, and **`POST /api/public/events`**, which is protected in other ways (section 12.2.4).
4. **Out of scope means 404,** never 403 (ADR-0007).
5. **Owner-only operations** (tier changes, adding or removing listings, billing) state this explicitly (SPEC-BILL-01, BR-PE-38).
6. **Rate limits** apply to login, public forms, search, reviews, and messaging. Responses include `RateLimit-Limit`, `RateLimit-Remaining`, and `RateLimit-Reset`, and 429 responses include `Retry-After`.
7. **No secrets or tokens** appear in URLs or responses. Stripe and Keycloak IDs are internal and never returned to the browser.
8. **Logs** never contain request bodies with personal data, or authentication headers.

---

## 12. Long-running and asynchronous work
- Most operations finish within the request.
- When something genuinely takes longer, such as a CSV export of members or regenerating sitemaps, return **202 Accepted** with a `Location` header pointing to a status resource: `GET /api/admin/exports/{exportId}` returns `{ "status": "PENDING" | "COMPLETE" | "FAILED", "downloadUrl": … }`.
- Outcomes that depend on Stripe, such as an upgrade waiting for payment, return the **current known state** of the listing, including the pending change. The UI refreshes when the payment is confirmed.

---

### 12.1 Polling and notifications (ADR-0020)
There's **no push channel** in the MVP. Endpoints that clients poll follow these rules:
- **Conditional requests:** they return an `ETag`. Clients send `If-None-Match`, and an unchanged response is **`304 Not Modified`** with no body.
- **Cheap summaries:** where clients poll for a count, the response includes it directly. For example, `GET /api/notifications?limit=10` returns `{ "items": [...], "unreadCount": 3, "nextCursor": "…" }`.
- **Polling rates:** clients poll **no more than once every 60 seconds** per endpoint, except the short checkout confirmation poll (every 2 seconds for up to 30 seconds). Rate limits allow for this.
- **Notification endpoints:**

  | Endpoint | Purpose |
  |---|---|
  | `GET /api/notifications` | The current user's notifications, newest first. Cursor-paginated, with optional `unreadOnly=true`. |
  | `POST /api/notifications/{notificationId}/read` | Mark one notification as read. Returns 204. |
  | `POST /api/notifications/read-all` | Mark all as read. Returns 204. |

  A notification is `{ "notificationId", "type", "title", "message", "link", "createdAt", "readAt"? }`, where `type` is UPPER_SNAKE_CASE, for example `LISTING_APPROVED` or `MESSAGE_RECEIVED`. **Users only ever see their own notifications.** Any other ID returns 404.

### 12.2 Activity events: `POST /api/public/events` (ADR-0011, ADR-0021)

The web app reports website activity here: views, clicks, contact reveals, and map use. **Searches and message leads aren't sent from the browser.** The backend records them itself (System Overview, section 8.14).

#### 12.2.1 Request

| Item | Rule |
|---|---|
| Method and path | `POST /api/public/events` |
| How it's sent | `navigator.sendBeacon`, or `fetch` with `keepalive: true` as a fallback. Events are **batched**: sent every **5 seconds**, at **20 events**, and when the page is hidden (`visibilitychange` or `pagehide`). |
| Content type | `application/json`. `text/plain` containing JSON is also accepted, because some browsers send beacons that way. |
| Size limits | Up to **50 events** and **32 KB** per request. Larger requests get **413 `PAYLOAD_TOO_LARGE`**. |
| Authentication | None required. If a session cookie arrives, the backend adds the **user ID** itself. **The body never contains a user ID, email, or name**, and any such field is ignored. |
| Consent | The web app sends events **only after the visitor accepts analytics cookies** (story 11.3). Counting anonymous totals without consent is an open question (T1). |

**Body**
```json
{
  "analyticsSessionId": "6f1d2c3b-8a9e-4f70-b1c2-d3e4f5a6b7c8",
  "events": [
    {
      "eventId": "0b8c7d6e-5f4a-4b3c-9d2e-1f0a9b8c7d6e",
      "name": "LISTING_VIEW",
      "occurredAt": "2026-10-06T18:02:11.483Z",
      "path": "/member/acme-plumbing-phoenix",
      "referrerHost": "www.google.com",
      "listingId": "4f7c2a9e-3b1d-4c55-9a0e-1d2f3b4c5d6e",
      "categoryId": "a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d",
      "cityId": "1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f",
      "props": { "source": "SEARCH_RESULTS", "position": 3 }
    }
  ]
}
```

| Field | Required | Rule |
|---|---|---|
| `analyticsSessionId` | Yes | A random UUID created by the web app after consent, stored in a first-party cookie (`bp_asid`). It expires after **30 minutes without activity**. It isn't linked to the login session. |
| `eventId` | Yes | A UUID created by the web app. The backend **ignores repeated event IDs**, so a retried beacon is never counted twice. |
| `name` | Yes | An UPPER_SNAKE_CASE name **from the event list** (story 0.5), for example `PAGE_VIEW`, `CATEGORY_VIEW`, `LISTING_VIEW`, `CONTACT_REVEAL`, `CLICK_TO_CALL`, `WEBSITE_CLICK`, `MAP_INTERACTION`. Unknown names are dropped. |
| `occurredAt` | Yes | When it happened, from the browser's clock. The backend also stores when it was **received**, and **replaces** `occurredAt` with the received time if it's more than 24 hours off. |
| `path` | Yes | The page path **without query strings**, except the filter parameters the event list allows. Never a full URL. |
| `referrerHost` | No | The referring **host name only**, for example `www.google.com` |
| `listingId`, `categoryId`, `cityId` | Depends on the event | As required by the event list. Unknown IDs are dropped. |
| `props` | No | Only the **keys the event list allows for that event**, with short values: strings up to 100 characters, numbers, and booleans. Anything else is removed. |

#### 12.2.2 Response
- **`202 Accepted`** with no body, when the batch is well-formed. **Events that fail validation are dropped one at a time**: the rest of the batch is still accepted, and the number dropped is recorded in backend metrics. Beacons ignore responses, so there's no detail to return.
- `400 VALIDATION_FAILED` when the body isn't valid JSON, or `analyticsSessionId` or `events` is missing.
- `413 PAYLOAD_TOO_LARGE` and `429 RATE_LIMITED`, as in section 8.1.
- The endpoint **never returns personal data**, and is never cached (`Cache-Control: no-store`).

#### 12.2.3 Processing guarantees
- **Best effort, and not part of the outbox.** Events are queued in memory and inserted in batches (System Overview, section 8.14). A small loss is acceptable if a backend task crashes, and is preferable to slowing pages down. Analytics must never block or fail a user's action.
- **No duplicates:** event IDs are de-duplicated across a 24-hour window.

#### 12.2.4 CSRF exemption and how the endpoint is protected instead
`sendBeacon` **can't set custom headers**, so these requests can't carry `X-XSRF-TOKEN`. The endpoint is therefore **excluded from CSRF checks** in the Spring Security configuration (`csrf.ignoringRequestMatchers("/api/public/events")`, next to the webhook paths). It's protected in other ways:

| Protection | Rule |
|---|---|
| **The request must come from our own site** | Requests are accepted only when `Sec-Fetch-Site` is `same-origin`, or, if that header is missing, when `Origin` or `Referer` is our own site. **Other requests are dropped silently** with 202, so they learn nothing. |
| **Nothing else can change** | The endpoint **only adds analytics rows**. It can't change accounts, listings, billing, or anything else. A forged request can at most add analytics noise, which the next two rules limit. |
| **Rate limits** | **60 requests per minute per IP address**, and **120 events per minute per `analyticsSessionId`**. Excess requests get 429, and the extra events are dropped. |
| **Strict validation** | Only names, fields, and `props` keys from the event list are kept, with the size limits in section 12.2.1 |
| **Bots** | Known bots and crawlers (by user agent, plus lists of known bot IP ranges) are dropped or marked, so they're excluded from dashboards (story 11.4) |
| **The user ID comes only from the session cookie** | A forged request can't attribute events to another user |
| **Authorization matrix** | The endpoint is listed as public in `authz-matrix.yaml` (story 2.12), with a note pointing to this section |

## 13. Versioning and deprecation
- **No version number in URLs.** The contract evolves additively.
- **Allowed without notice:** new endpoints, new optional request fields, new response fields, and new enum values in response-only fields. **Clients must ignore response fields they don't recognize, and must handle unknown enum values** without crashing.
- **Breaking changes:** removing or renaming a field or endpoint, making a request field required, changing a type or meaning, or adding an enum value to a request-only field. They need:
  1. agreement from both tech leads;
  2. marking the old element `deprecated: true` in the contract, and sending `Deprecation` and `Sunset` headers, **for at least one release**;
  3. a **major version** of `@blackpages/api-client`.
- **openapi-diff** in CI blocks unannounced breaking changes.

---

## 14. Caching headers
- **Public `GET` responses** that are the same for everyone: `Cache-Control: public, max-age=60, s-maxage=300, stale-while-revalidate=600`, adjusted per endpoint, plus an `ETag`.
- **Anything that depends on the session:** `Cache-Control: private, no-store`.
- **`/api/auth/*`:** always `no-store`.

---

## 15. Writing the OpenAPI contract
- **Version:** OpenAPI **3.1**, if story 0.7 confirms that openapi-generator's Spring and TypeScript generators handle it. Otherwise 3.0.3, with a planned move.
- **`operationId`:** unique, camelCase, verb then noun. Generators use it as the method name:
  - `listDirectoryListings`
  - `getListingBySlug`
  - `updateListing`
  - `changeListingTier`
  - `cancelListingTierChange`
- **`tags`:** one per backend module (`listing`, `billing`, `review`, …), so generated code groups naturally.
- **Schemas:**
  - named components (`Listing`, `ListingSummary`, `TierChangeRequest`, `Money`, `Problem`);
  - no unnamed inline objects with more than three properties;
  - request and response schemas are separate when they differ (`ListingUpdate` versus `Listing`).
- **Every schema and property** has a `description`. **Every operation** has at least one request and response `example`. Examples are used for the MSW mocks.
- **`required`** lists are complete. Enums list every value, with a description of each.
- **Errors:** every operation lists its error responses using the shared `Problem` schema, with the codes it can return named in the description.
- **Linting:** CI runs a Spectral ruleset, `contract/.spectral.yaml`, that enforces this section and sections 3–8.

**Example operation**
```yaml
paths:
  /api/listings/{listingId}/tier-change:
    post:
      operationId: changeListingTier
      tags: [billing]
      summary: Upgrade a listing, or schedule a downgrade
      description: >
        Owner of the listing's business account only (SPEC-BILL-01 BR-PE-38).
        Upgrades take effect immediately and are prorated; downgrades are
        scheduled for the end of the billing period and can be canceled.
        Requires an Idempotency-Key header.
      parameters:
        - $ref: '#/components/parameters/ListingId'
        - $ref: '#/components/parameters/IdempotencyKey'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/TierChangeRequest'
            example:
              tier: PLATINUM
      responses:
        '200':
          description: The listing with its new or pending tier
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Listing'
        '404':
          $ref: '#/components/responses/NotFound'
        '409':
          description: INVALID_STATE (for example, already at that tier) or CONFLICT
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
        '422':
          description: IDEMPOTENCY_KEY_REUSED
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
components:
  schemas:
    TierChangeRequest:
      type: object
      description: The tier the listing should move to.
      required: [tier]
      properties:
        tier:
          $ref: '#/components/schemas/ListingTier'
    ListingTier:
      type: string
      description: The tier of an individual listing (SILVER lowest, PLATINUM highest).
      enum: [SILVER, GOLD, PLATINUM]
    Money:
      type: object
      description: An amount of money in the smallest currency unit.
      required: [amountCents, currency]
      properties:
        amountCents:
          type: integer
          format: int64
          description: Amount in cents. Never fractional.
        currency:
          type: string
          description: ISO 4217 currency code.
          enum: [USD]
```

---

## 16. Review checklist

Use this list for every pull request to the contract:

- [ ] The path is under the right audience prefix, uses plural kebab-case nouns, and has no more than one level of nesting
- [ ] The method and success status follow section 4. Creates return 201 with `Location`.
- [ ] Properties are camelCase and enums UPPER_SNAKE_CASE. Money, dates, times, and IDs follow section 5.
- [ ] Collections are wrapped and paginated in the right style (section 6)
- [ ] Filters and sort fields are documented (section 7)
- [ ] All error responses use `Problem`, and every code is in the catalog (section 8)
- [ ] Editable resources include `version`. Charge-creating calls require `Idempotency-Key`.
- [ ] The description states who may call it. An `authz-matrix.yaml` entry is planned.
- [ ] Any endpoint exempt from CSRF checks is listed in section 11, with the protections that replace them (as in section 12.2.4)
- [ ] Examples are present and realistic (they feed the MSW mocks)
- [ ] openapi-diff shows no breaking change, or the breaking change follows section 13
- [ ] No personal data beyond what's needed, and no internal IDs (Stripe, Keycloak)
