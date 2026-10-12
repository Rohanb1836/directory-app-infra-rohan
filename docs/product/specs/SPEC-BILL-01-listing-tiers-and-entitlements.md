# Feature Spec: Account Types, Listing Tiers, and Entitlements

*Part 1 of the Billing and Discounts specification*

| | |
|---|---|
| **Spec ID** | SPEC-BILL-01 |
| **Version** | 0.7 (draft) |
| **Date** | 2026-10-06 |
| **Status** | Draft for review. It needs product owner approval **before Sprint 1 refinement ends**, because the entitlement engine (7.10) starts in Sprint 2. |
| **Change from v0.1** | Silver, Gold, and Platinum are no longer account plans. They are **tiers of an individual listing**. There are two **account types**, business and shopper. A business account can add any number of listings, each with its own tier, and **gets one Silver listing by default**. |
| **Change from v0.2** | The **default Silver listing is charged the Silver price and discounted like any other listing**. There's no longer a free allowance. The account owner can **upgrade or downgrade every listing**, including the default one. |
| **Change from v0.3** | **Only the account owner can change tiers**, and **each business account has exactly one user, its owner**, for now. The team-member entitlement and editor role are removed. |
| **Change from v0.6** | New keys for survey insights: `listing.survey_insights.level` and `account.survey_insights.shopper` (SPEC-SRV-01, ADR-0022) |
| **Change from v0.5** | Answers to Q2 and Q6 (2026-09-30): gallery photos are **Silver 1, Gold 3, Platinum 6**, and **Silver listings aren't featured on the directory landing page** (new key `listing.landing_page`). |
| **Change from v0.4** | The **shopper account always has a price**. Discounts apply to it, and the $1 service fee is charged in addition. |
| **Owner** | Product owner |
| **Reviewers** | Tech lead for `directory-app-svc`, tech lead for `directory-app-ui` |
| **Related** | MVP Definition v1.10 (sections 4 and 5), Product Backlog v1.6 (E7), ADR-0007, ADR-0009, ADR-0017 |
| **Part 2** | SPEC-BILL-02, Billing and Discounts: checkout, proration, discount mechanics, lapses, invoices, tax. Due by the end of Sprint 4. |

---

## 1. Problem and goals

BlackPages charges for two things:
- **Taking part**, through a business or shopper account.
- **Visibility and features for each listing**, through its tier.

Many parts of the system depend on "what this listing's tier allows" or "what this account type allows": placement in lists, gallery size, links, analytics, messaging, reviews, and secret shopper eligibility. If each feature checks this in its own way, the rules will drift apart, and it becomes hard to change prices or limits.

**Goals**
1. Put every tier-dependent and account-type-dependent rule in **one place**, the entitlement engine.
2. Let admins change prices and limits **without code changes**.
3. Make adding listings, changing a listing's tier, discounts, and lapses behave **predictably**, and never destroy members' content.
4. Show members clearly what each listing has, and what a higher tier would add.

**Out of scope (covered in Part 2):** Stripe checkout, proration arithmetic, discount redemption, invoices, dunning, lapse timing, and sales tax.

---

## 2. Definitions

| Term | Meaning |
|---|---|
| **Account type** | **Business** or **Shopper**. Every member account is one of these. |
| **Business account** | An account that owns listings. It can have any number of listings, and has **exactly one user, its owner**. |
| **Owner** | The single user of a business account. Only the owner can change tiers, add or remove listings, and manage billing. |
| **Shopper account** | An account for an individual who reviews businesses and can be picked as a secret shopper |
| **Listing tier** | The level of an individual listing: **Silver (1), Gold (2), or Platinum (3)**. Each listing has exactly one tier. |
| **Default Silver listing** | The Silver listing created automatically with every new business account. It's **billed, discounted, and changed like any other Silver listing**. |
| **Tier price** | The monthly price of a listing at a given tier |
| **Price version** | A tier's (or the shopper account's) price and entitlements at a point in time. Changing prices, or reducing entitlements, creates a new version. |
| **Entitlement** | A single named feature flag or limit, such as `listing.gallery.max_photos = 10` |
| **Entitlement definition** | The code-level definition of an entitlement key: its type, scope, default, and where it's enforced |
| **Entitlement set** | All the resolved entitlement values for one listing (from its tier) or one account (from its type) at a given moment |
| **Service fee** | The $1 monthly fee charged to every business and shopper account. It's not an entitlement and is **never discounted**. |

---

## 3. Account types and listing tiers

### 3.1 Account types

| Account type | Monthly charges | What's included |
|---|---|---|
| **Business** | $1 service fee, plus the tier price of **every** listing, including the default Silver listing | **One Silver listing is created by default.** More listings can be added at any tier. |
| **Shopper** | The shopper account price (**$ TBD**), less any discount, **plus** the $1 service fee | Writing reviews, secret shopper eligibility, message history, shopper dashboard |

### 3.2 Listing tiers

| Tier | Rank | Monthly tier price |
|---|---|---|
| **Silver** | 1 | **$ TBD** (also charged for the default Silver listing) |
| **Gold** | 2 | **$ TBD** |
| **Platinum** | 3 | **$ TBD** |

Prices are set by the product owner before Sprint 5 (see OQ-3). The engine doesn't depend on the values.

### 3.3 Rules for accounts and listings

- **BR-PE-01.** There are **two account types**, business and shopper. There are **no account plans**. Silver, Gold, and Platinum describe **listings only**.
- **BR-PE-02.** **Each listing has its own tier.** A business account can have listings at different tiers, for example one Platinum listing and two Silver listings.
- **BR-PE-03.** A business account can add **any number of listings** (see `account.listings.max`). Every listing is charged at its own tier's price.
- **BR-PE-04.** **The default Silver listing.** Every new business account gets one Silver listing, created automatically. It is an ordinary listing:
  - it's **charged the Silver tier price**;
  - **discounts apply to it the same way** as to any other Silver listing;
  - it can be **upgraded or downgraded** like any other listing (BR-PE-19 to BR-PE-22).

  It has no special billing treatment. The only thing that marks it out is how it was created.
- **BR-PE-05.** **Onboarding a business** creates the business account and its **default Silver listing**, starting as a draft. The owner can choose a higher tier for it straight away, in which case that tier's price applies instead of Silver's.
- **BR-PE-06.** A business account always has **at least one listing**. The last listing can be paused but not deleted. Removing all listings means closing the account.
- **BR-PE-39.** **Each business account has exactly one user, its owner**, in the MVP. Adding more users to an account comes after the MVP.
- **BR-PE-40.** **The shopper account price.** Every shopper account is charged the shopper account price each month. **Discounts apply to it** the same way as to listing tier prices (up to 100%, for a set duration or forever). **The $1 service fee is charged in addition** and is never discounted.
- **BR-PE-07.** A person who has both a shopper account and a business account has **two accounts**, each with its own $1 service fee. *(Assumption: see OQ-6.)*
- **BR-PE-08.** The MVP uses **monthly billing only**. An annual *service fee* option is under consideration (MVP question Q1, Part 2).
- **BR-PE-09.** Tiers are ordered by rank. Moving a listing to a higher tier is a **tier upgrade**, and to a lower tier a **tier downgrade**. Silver is the lowest tier, so a Silver listing can't be downgraded further. To stop paying for it, the owner removes it (BR-PE-18), unless it's the account's last listing (BR-PE-06).

---

## 4. Entitlement catalogue

### 4.1 Entitlement definitions

Each key gets its value from one of two sources:
- **Listing tier:** the listing's own tier. Every listing gets the full value for its tier.
- **Account type:** whether the account is a business or a shopper.

| Key | Type | Source | Enforced at | Stories |
|---|---|---|---|---|
| `listing.logo` | Yes/no | Listing tier | Write (upload), read (profile) | 3.7 |
| `listing.cover_image` | Yes/no | Listing tier | Write, read | 3.7 |
| `listing.description.max_chars` | Number | Listing tier | Write (validation), read (truncation after a tier downgrade) | 3.8 |
| `listing.gallery.max_photos` | Number | Listing tier | Write (upload), read (visible photos) | 3.9 |
| `listing.specialties.max` | Number | Listing tier | Write (tagging), read (visible tags, search matching) | 4.7 |
| `listing.links.website` | Yes/no | Listing tier | Write, read, schema `sameAs` | 3.2, 6.8b |
| `listing.links.social` | Yes/no | Listing tier | Write, read, schema `sameAs` | 3.2, 6.8b |
| `listing.placement` | Choice: STANDARD, FEATURED, PREMIUM | Listing tier | Read (directory and search ordering) | 4.2, 5.1 |
| `listing.landing_page` | Yes/no | Listing tier | Read (eligible for the directory landing page's featured areas) | 4.4 |
| `listing.service_area` | Yes/no | Listing tier | Write, read, search matching | 5.7, 5.8 |
| `listing.messaging.receive` | Yes/no | Listing tier | Read (Contact button), write (accepting messages) | 16.1, 16.6 |
| `listing.analytics.level` | Choice: BASIC, STANDARD, ADVANCED | Listing tier | Read (that listing's dashboard widgets and API fields) | 12.1 |
| `listing.analytics.history_days` | Number | Listing tier | Read (that listing's date range limit) | 12.1 |
| `listing.survey_insights.level` | Choice: BASIC, STANDARD, ADVANCED | Listing tier. **The account uses its highest active listing** (SPEC-SRV-01, BR-SI-13). | Read (survey insights breakdowns, trends, export) | 18.9, 18.10 |
| `account.survey_insights.shopper` | Yes/no | Account type (shopper) | Read (shopper survey insights) | 18.11 |
| `account.listings.max` | Number, or no limit | Account type (business) | Write (creating a listing) | 3.3 |
| `account.reviews.respond` | Yes/no | Account type (business) | Write (replying to reviews of the account's listings) | 9.5 |
| `account.reviews.write` | Yes/no | Account type (both) | Write (creating a review) | 9.1 |
| `account.secret_shopper.eligible` | Yes/no | Account type (both) | Monthly selection job | 10.1 |
| `account.messaging.history` | Yes/no | Account type (shopper) | Read (shopper message history) | 16.5 |
| `account.dashboard.shopper` | Yes/no | Account type (shopper) | Read | 12.4 |

- **BR-PE-10.** Entitlement **definitions** (the keys, their types, sources, and enforcement) are part of the **code**. Adding a new key needs a code change and a story.
- **BR-PE-11.** Entitlement **values** for each tier and account type are **configuration** that admins can change (story 7.1).

### 4.2 Default values by listing tier

Values marked *indicative* are proposals waiting on MVP question Q6 (see OQ-2).

| Key | Silver | Gold | Platinum |
|---|---|---|---|
| `listing.logo` | Yes | Yes | Yes |
| `listing.cover_image` | Yes | Yes | Yes |
| `listing.description.max_chars` *(indicative)* | 500 | 1,500 | 3,000 |
| `listing.gallery.max_photos` | **1** | **3** | **6** |
| `listing.specialties.max` *(indicative)* | 3 | 5 | 10 |
| `listing.links.website` | No | No | **Yes** |
| `listing.links.social` | No | No | **Yes** |
| `listing.placement` | STANDARD | **FEATURED** | **PREMIUM** |
| `listing.landing_page` | **No** | Yes | Yes |
| `listing.service_area` | Yes | Yes | Yes |
| `listing.messaging.receive` | Yes | Yes | Yes |
| `listing.analytics.level` | BASIC | STANDARD | ADVANCED |
| `listing.analytics.history_days` *(indicative)* | 90 | 365 | 730 |
| `listing.survey_insights.level` | BASIC | STANDARD | ADVANCED |

### 4.3 Default values by account type

| Key | Business | Shopper |
|---|---|---|
| `account.listings.max` | No limit* | — |
| `account.reviews.respond` | Yes | — |
| `account.reviews.write` | Yes | Yes |
| `account.secret_shopper.eligible` | Yes | Yes |
| `account.messaging.history` | — | Yes |
| `account.dashboard.shopper` | — | Yes |
| `account.survey_insights.shopper` | — | Yes |

\* *"No limit" still has a system-wide safety cap of 100 listings per account, which admins can raise for an individual account.*

### 4.4 What each analytics level includes (story 12.1)

Analytics apply to each listing at its own tier's level. The business dashboard also has an **account overview**, which shows BASIC metrics summed across all of the account's listings.

| Level | Includes, for that listing |
|---|---|
| BASIC | Views, click-to-call count, website clicks, message leads. Totals for the period, with a daily chart. |
| STANDARD | Everything in BASIC, plus trends compared with the previous period, the top 20 search terms that led to the listing, and a breakdown by city |
| ADVANCED | Everything in STANDARD, plus benchmarks against the median of the same category and city (only when there are at least 5 other listings, so no single competitor can be identified), review trends, and secret shopper survey insights once available |

---

## 5. How entitlements are worked out

- **BR-PE-12.** A **listing's** entitlements come from its **tier's current price version**. An **account's** entitlements come from its **account type**. In both cases the account's billing status decides whether they apply:

| Account billing status | Effect |
|---|---|
| ACTIVE (including listings discounted to $0) | All listings have their tier's entitlements, and the account has its type's entitlements |
| PAST_DUE (within the 7-day grace period) | Same as ACTIVE |
| LAPSED (after the grace period) | **All of the account's listings are hidden** from the public, and account entitlements are suspended. The member can still sign in to pay. |
| CANCELED | All listings are hidden |

A listing with a **tier downgrade scheduled** keeps its current (higher) tier's entitlements until the change takes effect.

- **BR-PE-13.** **Discounts never change entitlements.** A Gold listing discounted to $0 has exactly the same entitlements as a full-price Gold listing. The default Silver listing has the same entitlements as any other Silver listing.
- **BR-PE-14.** **Admin overrides.** An admin can give a single listing or account an override for any key, for example to raise `account.listings.max`. Each override has a reason, an optional expiry date, and an audit record. Overrides take priority over configured values. *(This is a Should for the MVP. The data model supports it from the start.)*
- **BR-PE-15.** Order of precedence: an active admin override, then the tier or account-type value, then the definition's default (which is always the most restrictive value).
- **BR-PE-16.** Every entitlement check goes through `EntitlementService`. No module reads tier or pricing data directly. An ArchUnit rule enforces this.

---

## 6. Listing changes and their effects

### 6.1 Adding and removing listings
- **BR-PE-17.** Adding a listing requires choosing a tier. The tier price is charged, prorated for the rest of the billing period.
- **BR-PE-18.** A removed listing stops being charged at the end of the billing period and is hidden immediately. The default Silver listing can be removed like any other, as long as it isn't the account's last listing (BR-PE-06).

### 6.2 Who can change a listing's tier
- **BR-PE-37.** **Every listing can be upgraded or downgraded**, including the default Silver listing. Each listing is changed on its own, and changing one never affects the account's other listings.
- **BR-PE-38.** **Only the account owner can change a listing's tier.** In the MVP the owner is the account's only user (BR-PE-39). Anyone else, including other businesses, gets 404 for the listing's tier-change endpoints (ADR-0007).

### 6.3 Tier upgrades
- **BR-PE-19.** A tier upgrade takes effect **immediately** for that listing. The new entitlements unlock as soon as the payment for it succeeds. Proration is covered in Part 2.
- **BR-PE-20.** An upgrade is charged as the **prorated difference** between the old and new tier prices for the rest of the billing period, then the new tier's full price. The default Silver listing is upgraded the same way.
- **BR-PE-21.** Content that had been hidden after an earlier downgrade (extra photos, specialties, links) **comes back automatically** if it fits within the new tier's limits.

### 6.4 Tier downgrades
- **BR-PE-22.** A tier downgrade takes effect **at the end of the current billing period**. Until then, the listing keeps its current tier's entitlements and price. From the next period, it's charged the lower tier's price. The owner can cancel a scheduled downgrade before it takes effect.
- **BR-PE-23.** **Content is never deleted because of a tier downgrade.** Anything over the new tier's limit is **hidden** from the public and kept, so it can be restored:

| Entitlement | What happens to content over the new limit |
|---|---|
| `listing.gallery.max_photos` | The first N photos, in the member's chosen order, stay visible. The rest are hidden and shown to the member as "hidden: over this listing's tier limit". |
| `listing.specialties.max` | The first N specialties, in the member's chosen order, stay visible and searchable. The rest are hidden. |
| `listing.description.max_chars` | The public page cuts the description off at a word boundary within the limit. The full text is kept. |
| `listing.links.*` | The links are hidden on the profile and left out of the schema markup. They're kept. |
| `listing.placement` | Directory and search ordering changes as soon as the downgrade takes effect. |
| `listing.analytics.*` | That listing's dashboard shows the new level and date range. The underlying data is kept. |

- **BR-PE-24.** **Seven days before** a scheduled tier downgrade takes effect, the owner is emailed a list of what will be hidden on that listing. They can reorder photos and specialties so the ones they want stay visible.

### 6.5 Lapse and reactivation
- **BR-PE-25.** Billing happens at the account level, on one consolidated invoice. When an account lapses, **all of its listings are hidden**, but nothing is deleted. Paying restores every listing at its tier and makes them visible again, subject to approval rules (story 3.6: edits made while lapsed still need approval).

### 6.6 Changes to tier configuration
- **BR-PE-26.** **Price changes** create a new price version. **Existing listings stay on their current version** (they keep their price) unless an admin moves them explicitly. Moving existing listings comes after the MVP. The same applies to the shopper account price.
- **BR-PE-27.** **Increasing a tier's entitlements** (for example, raising Gold's gallery limit) updates the current version and applies to every listing at that tier immediately.
- **BR-PE-28.** **Reducing a tier's entitlements** creates a new version that **only new listings** get in the MVP.

---

## 7. Placement and ordering (stories 4.2 and 5.1)

- **BR-PE-29.** Each listing stores its own `tier` and `tier_rank` (Silver 1, Gold 2, Platinum 3). They're updated through the `ListingEntitlementsChanged` event.
- **BR-PE-30.** Directory and search results are ordered **by tier_rank, highest first, then alphabetically by name**. The name is normalized for sorting: lower case, accents removed, and a leading "The" ignored.
- **BR-PE-31.** Filters (city, specialty, rating, open now, service area) are applied **before** ordering, and never change the tier order within a result set.
- **BR-PE-32.** Each listing's badge shows **its own tier**. Different listings from the same business can show different badges.

---

## 8. What members see

- **BR-PE-33.** Locked features are **shown, not hidden**, with a short explanation and a prompt to move that listing up a tier, for example "Add your website: available on Platinum listings". Admins and operators don't see these prompts.
- **BR-PE-34.** When a limit is reached, the owner sees current usage and the limit for that listing (for example, "3 of 3 photos"), plus the next tier up that gives more.
- **BR-PE-35.** The business dashboard shows **every listing with its tier**, its monthly price, any discount, and any scheduled tier change, with **Upgrade** and **Downgrade** actions on each listing for the owner.
- **BR-PE-36.** The pricing page (13.3) and the tier choice in onboarding (2.2) and when adding a listing (3.3) are generated from the same configuration, so they always match the entitlement engine.

---

## 9. Data model

| Table | Key columns | Notes |
|---|---|---|
| `listing_tier` | id, code (SILVER, GOLD, PLATINUM), tier_rank, name, description, display_order, status | One row per tier |
| `listing_tier_version` | id, tier_id, version, effective_from, price_cents, stripe_price_id, status (DRAFT, ACTIVE, RETIRED) | Only one version per tier is ACTIVE for new listings |
| `account_type_config` | account_type (BUSINESS, SHOPPER), version, price_cents (for shoppers), stripe_price_id, status | The shopper account price. Business accounts have no price of their own beyond the service fee. |
| `entitlement_definition` | key (primary key), type (BOOL, INT, ENUM), source (LISTING_TIER, ACCOUNT_TYPE), account_type, default_value, allowed_values | Seeded by Flyway from code. Never edited in the admin UI. |
| `tier_entitlement` | listing_tier_version_id, key, value (jsonb) | Validated against the definition's type |
| `account_type_entitlement` | account_type_config id, key, value (jsonb) | |
| `entitlement_override` | id, subject_type (LISTING, ACCOUNT), subject_id, key, value, reason, expires_at, created_by, created_at | Optional (BR-PE-14) |
| `subscription` *(existing)* | One per account: account_id, status, current_period_end, stripe_subscription_id | Billing is at the account level |
| `subscription_item` *(existing)* | subscription_id, kind (SERVICE_FEE, LISTING, SHOPPER_ACCOUNT), listing_id, listing_tier_version_id, pending_tier_version_id, pending_effective_at, stripe_item_id | One item per listing, **including the default Silver listing** |
| `listing` *(existing)* | tier and tier_rank (from its subscription item), `is_default` (informational only, never used for billing), and `visibility_state` on media, specialties, and links (VISIBLE, HIDDEN_OVER_LIMIT) | For BR-PE-23 |

---

## 10. Events and caching

| Event | Published by | Consumed by | Effect |
|---|---|---|---|
| `AccountActivated` | billing | entitlement | Works out the account's entitlements, and publishes `ListingEntitlementsChanged` for its listings |
| `ListingAdded` / `ListingRemoved` | billing | entitlement, listing | Works out the listing's entitlements, or hides the removed listing (BR-PE-17, BR-PE-18) |
| `ListingTierChangeScheduled` / `ListingTierChangeCanceled` | billing | entitlement, notification | Stores or clears the pending downgrade, and schedules the 7-day email (BR-PE-24) |
| `ListingTierChangeEffective` | billing | entitlement | Works out the listing's new entitlements |
| `AccountLapsed` / `AccountReactivated` | billing | entitlement, listing | Hides or restores all of the account's listings |
| `EntitlementOverrideChanged` | admin | entitlement | Works out the affected entitlements again |
| **`ListingEntitlementsChanged`** (listing id, before, after) | entitlement | listing, search, seo, analytics | Updates the tier copy, content visibility, search index, sitemaps, and schema |
| **`AccountEntitlementsChanged`** (account id, before, after) | entitlement | review, secretshopper | Updates review rights and secret shopper eligibility |

- Entitlement sets are cached in memory (Caffeine) by listing ID and account ID for 5 minutes, and the cache is cleared on the matching event. With a single backend task in the MVP, this is enough (ADR-0010).
- All events go through the transactional outbox, so a change and its effects never get out of step.

---

## 11. API

| Method and path | Access | Purpose |
|---|---|---|
| `GET /api/public/pricing` | Public | Listing tiers with current prices and their visible entitlements, the shopper account price, and the service fee. Used by the pricing page and onboarding. |
| `GET /api/auth/me` *(existing)* | Authenticated | Includes the account type, its account entitlements, and a summary of each listing's tier |
| `GET /api/business-accounts/{id}/listings/entitlements` | Owner, staff | Each listing's tier, entitlements, and usage, for example `{ "listingId": "…", "tier": "GOLD", "listing.gallery.max_photos": { "limit": 3, "used": 2 } }`, plus the account's entitlements |
| `POST /api/business-accounts/{id}/listings` | Owner | Adds a listing at a chosen tier (BR-PE-17) |
| `POST /api/listings/{id}/tier-change` | Owner | Upgrades immediately or schedules a downgrade, for any listing including the default one (sections 6.2 to 6.4) |
| `DELETE /api/listings/{id}/tier-change` | Owner | Cancels a scheduled downgrade (BR-PE-22) |
| `GET /api/admin/listing-tiers`, `POST /api/admin/listing-tiers/{id}/versions`, `PUT /api/admin/listing-tier-versions/{id}`, `PUT /api/admin/account-types/{type}` | Admin | Manage tiers, prices, account-type entitlements, and the shopper price (story 7.1) |
| `POST /api/admin/entitlement-overrides` | Admin | Overrides (BR-PE-14) |

**Error when a limit is reached.** The API returns HTTP 422 with an RFC 9457 Problem Details body, which the UI uses to show the prompt in BR-PE-34:

```json
{
  "type": "https://blackpages.io/problems/entitlement-limit-reached",
  "title": "Listing tier limit reached",
  "status": 422,
  "code": "ENTITLEMENT_LIMIT_REACHED",
  "listingId": "4f7c…",
  "entitlement": "listing.gallery.max_photos",
  "limit": 3,
  "used": 3,
  "upgradeTo": "PLATINUM"
}
```

A feature that isn't included in the tier returns 403 with `code: ENTITLEMENT_NOT_INCLUDED`, and the same fields apart from `limit` and `used`.

---

## 12. Acceptance scenarios

These become the test cases for story 7.10 and the related stories.

| # | Given | When | Then |
|---|---|---|---|
| AS-1 | A new business completes onboarding | The account is created | It has one listing, at Silver, marked as the default listing. The first invoice is the $1 service fee plus the Silver price. |
| AS-2 | A Gold listing with 3 photos | The owner uploads a 4th | 422 `ENTITLEMENT_LIMIT_REACHED`, `upgradeTo: PLATINUM` |
| AS-3 | A Silver listing | The owner saves a website URL | 403 `ENTITLEMENT_NOT_INCLUDED`, and the UI shows "Available on Platinum listings" |
| AS-4 | A business account with a Platinum listing and a Silver listing, in the same category and city as another business's Gold listing | A visitor opens the category page | Platinum, then Gold, then Silver, alphabetical within each tier. Each listing shows its own badge. |
| AS-5 | A business with only its default Silver listing | The owner adds a second listing at Gold | The Gold price is charged, prorated. The default listing is still charged the Silver price. |
| AS-6 | A business's default Silver listing | The owner upgrades it to Gold | The upgrade applies immediately. The prorated difference between Silver and Gold is charged, then the full Gold price from the next period. |
| AS-7 | That listing is now Gold | The owner downgrades it to Silver | The downgrade is scheduled for the end of the period. The listing keeps Gold features and price until then, and the owner can cancel the downgrade. |
| AS-8 | A Platinum listing with 6 photos is scheduled to move down to Gold | Seven days before the period ends | The owner is emailed that 3 photos on that listing will be hidden |
| AS-9 | That downgrade takes effect | A visitor views the listing | 3 photos are visible. The owner sees 3 more marked "hidden". The website link isn't shown or included in the schema. Other listings on the account are unaffected. |
| AS-10 | That listing is moved back up to Platinum | Payment succeeds | All 6 photos and the links are visible again, and the listing is ordered as Platinum |
| AS-11 | A Gold listing discounted 100% for 3 months, on an account whose default Silver listing is at full price | The account is active | The Gold listing has all of Gold's entitlements. The invoice is the $1 service fee plus the Silver price. |
| AS-11a | A launch offer of 100% off Silver for 3 months | A new business signs up | The discount applies to the default Silver listing exactly as to any Silver listing. The invoice is the $1 service fee only, and the email in 7.11 is sent 7 days before the Silver price starts. |
| AS-12 | An account passes its 7-day grace period | The lapse job runs | All of the account's listings are hidden, and no content is deleted |
| AS-13 | An admin raises Gold's gallery limit from 3 to 4 | The owner of a Gold listing uploads a 4th photo | It's accepted, without any change to billing |
| AS-14 | An admin changes Gold's price | The owner of an existing Gold listing views billing | That listing keeps its current price. New Gold listings get the new price. |
| AS-15 | A business account whose only listing is the default Silver listing | The owner tries to delete it | Deletion is blocked, with an option to pause the listing or close the account (BR-PE-06) |
| AS-16 | A module other than `billing` or `entitlement` reads `tier_entitlement` directly | CI runs | The ArchUnit rule fails the build |
| AS-17 | A signed-in user who doesn't own the listing's account | They try to change the listing's tier | 404, and nothing changes (BR-PE-38) |
| AS-18 | A business account with an owner | Someone tries to add a second user to it | The request is rejected, because each account has exactly one user (BR-PE-39) |
| AS-19 | A shopper signs up with a 50% discount for 3 months | The first invoice is created | It shows the shopper account price less 50%, plus the $1 service fee. From month 4, the full shopper account price plus the $1 fee. |

---

## 13. Open questions

| # | Question | Proposed answer | Owner | Needed by |
|---|---|---|---|---|
| ~~OQ-1~~ | ~~Can branches have different tiers?~~ | **Resolved:** each listing has its own tier | — | — |
| OQ-2 | **Photos answered** (Silver 1, Gold 3, Platinum 6). Still to confirm in section 4.2: specialties (the product owner asked what these are), description length, and analytics history. This is MVP question Q6. | Use the proposed values | Product owner | Sprint 1 refinement |
| OQ-3 | Set the tier prices for Silver, Gold, and Platinum, and the shopper account price | — | Product owner | Before Sprint 5 |
| ~~OQ-4~~ | ~~Does add-on pricing vary by tier?~~ | **Resolved:** every listing is priced by its own tier | — | — |
| OQ-5 | Should Silver listings get a logo and cover image? | Yes, because profiles look much better, which helps the directory as a whole | Product owner | Sprint 1 refinement |
| OQ-6 | Does a person with both a shopper and a business account pay **two** $1 service fees (BR-PE-07)? | Yes, one per account | Product owner | Before Sprint 5 |
| OQ-7 | Should admin overrides (BR-PE-14) be a Must for launch? | Should. The data model is built now, and the admin UI can come in Sprint 10. | Product owner | Sprint 2 |
| ~~OQ-8~~ | ~~Is the default Silver listing free of any listing charge?~~ | **Resolved:** no. It's charged the Silver price, and discounts apply to it like any other Silver listing (BR-PE-04). | — | — |
| ~~OQ-9~~ | ~~Does upgrading the default listing give a credit?~~ | **Resolved:** not applicable. The default listing is an ordinary paid Silver listing, so an upgrade charges the prorated difference (BR-PE-20). | — | — |
| ~~OQ-11~~ | ~~Who can change a listing's tier?~~ | **Resolved:** the account owner only (BR-PE-38) | — | — |
| ~~OQ-10~~ | ~~Is the team-member limit the same for every business account?~~ | **Resolved:** not applicable. Each business account has one user (BR-PE-39). | — | — |

---

## 14. Traceability

| Stories | Rules in this spec |
|---|---|
| 7.1 Configure listing tiers and account pricing | Section 3, BR-PE-10, BR-PE-11, BR-PE-26 to BR-PE-28, section 11 |
| 7.10 Entitlement engine | Sections 4, 5, and 10, BR-PE-16, AS-1 to AS-19 |
| 7.3 Sign up and pay, 2.2 Onboarding | BR-PE-04, BR-PE-05, BR-PE-40, AS-1, AS-11a, AS-19 |
| 3.3 Add more listings | BR-PE-03, BR-PE-17, `account.listings.max`, AS-5 |
| 7.4 Upgrade or downgrade a listing | Sections 6.2 to 6.4, BR-PE-37, BR-PE-38, AS-6 to AS-10, AS-17 |
| 2.4 Role-based access control | BR-PE-39, AS-18 |
| 7.5 One invoice for all listings | BR-PE-03, BR-PE-18, BR-PE-25, AS-1, AS-5 |
| 7.7 Lapsed accounts | BR-PE-12, BR-PE-25, AS-12 |
| 7.11 Listings discounted to $0 | BR-PE-13, AS-11, AS-11a |
| 3.2, 3.7, 3.8, 3.9, 4.7 Profile features | Section 4.2, BR-PE-23 |
| 4.2, 5.1 Ordering | Section 7, AS-4 |
| 12.1 Business dashboards | Section 4.4 |
| 9.1, 9.5, 10.1 Reviews and secret shopper | Section 4.3 |
| 13.3 Pricing page | BR-PE-36, `GET /api/public/pricing` |

### Suggested backlog updates once this spec is approved
- **7.10:** link to this spec as its source of truth, and replace its acceptance criteria with AS-1 to AS-19.
- **3.9 and 4.7:** replace the "indicative" limits with a reference to section 4.2.
- **New story 7.14, admin entitlement overrides (Should, 3 points, Sprint 10):** covers BR-PE-14. The data model is built in Sprint 2 as part of 7.10.
- **New story 7.15, content hidden over a tier limit (Must, 3 points, Sprint 6):** covers BR-PE-21 to BR-PE-24. It goes in Sprint 6 alongside the tier-change story, 7.4.
