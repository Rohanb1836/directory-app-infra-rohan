# BlackPages.io: Minimum Viable Product (MVP) Definition

| | |
|---|---|
| **Document version** | 1.13 |
| **Date** | 2026-10-06 |
| **Status** | Draft for stakeholder review (v1.13: two account types; Silver, Gold, and Platinum are listing tiers; the default Silver listing is charged and discounted like any other; only the owner changes tiers; one user per business account; shopper accounts have a price, discounts apply, and the $1 fee is additional; backend on Spring Boot 4.1 and Java 25; answers to Q1–Q15 applied; in-app notification center; activity tracking design and optional PostHog; survey insights and survey app integration, Sprint 11 added) |
| **Repositories** | `directory-app-svc` (backend), `directory-app-ui` (frontend), `directory-app-infra` (infrastructure) |
| **Related documents** | ADR-0001 to ADR-0022, SPEC-SRV-01, Answers Log (2026-10-06), Identity and Access Design v2.2, SPEC-BILL-01 v0.6, Product Backlog v1.9 (`directory-app-infra/docs/`) |

---

## 1. Product overview

BlackPages.io is a **business directory for multiple locations**. Businesses open a **business account**, list themselves by category, and can add any number of listings. Each listing has a **tier** (Silver, Gold, or Platinum) that sets how visible it is and what it costs, and every business account starts with one Silver listing. Shoppers register to review businesses and join the community. The public can search, browse, and view listings without an account.

The directory's point of difference is **credible reviews**. Reviews of a business stay hidden until a randomly selected **secret shopper** has reviewed that business.

### 1.1 MVP goals
1. Launch a working, SEO-friendly directory in the initial launch location, **Arizona**, with the ability to expand to **50 locations**.
2. Earn recurring revenue from listing tier prices, the shopper account price, and the monthly service fee.
3. Establish trust through the secret shopper program and moderated reviews.
4. Collect activity data from day one and show it back to members as dashboards that depend on each listing's tier.

### 1.2 Success metrics (proposed, to be confirmed)

| Metric | Target 90 days after launch in Arizona |
|---|---|
| Published business listings | 500 or more |
| Share of business accounts with at least one Gold or Platinum listing | 15% or more |
| Listings that stay on a paid tier after a free introductory offer ends | 30% or more |
| Registered shoppers | 1,000 or more |
| Searches that lead to a listing view | 40% or more |
| Secret shopper assignments completed | 70% or more |
| Businesses with reviews unlocked | 25% or more of listings that have at least one review |
| Visits from organic search | 50% or more of all sessions |

### 1.3 Initial launch location: Arizona

| Item | Detail |
|---|---|
| Launch location | **Arizona (AZ)**, the first active location. The other 49 location slots stay in draft until expansion. |
| Launch cities | **Confirmed (Q15): 11 cities.** Phoenix, Tucson, Mesa, Glendale, Scottsdale, Tempe, Goodyear, Gilbert, Chandler, Peoria, Surprise. Each state's major metro area spans several cities. A threshold for adding more cities, based on demand from each city, is to be discussed (see to-do T10). |
| Time zone | **Arizona doesn't observe daylight saving time**, and all launch cities use `America/Phoenix`. Tribal-land time zones don't need special handling (Q15). Each location still stores an IANA time zone for future states. |
| SEO | Launch sitemaps and category-by-city pages for the Arizona cities above first. |
| Sales tax | **Answered (Q12, BPM sales tax policy):** Arizona has no state sales tax on advertising, but **some cities charge city tax, including Phoenix**. Subscribers in other states count towards each state's registration threshold (some are as low as 200 sales), which must be tracked. The approach is decided in to-do T8. |
| Hosting region | Serving Arizona from AWS `us-west-2` (Oregon) gives lower latency than `us-east-1`, at similar prices. This is optional, because the CDN serves most public pages anyway (see ADR-0014). |

---

## 2. Users and roles

| Role | Description | Key abilities |
|---|---|---|
| **Public visitor** | No account | Search, browse, view listings and unlocked reviews, contact businesses, see public charts |
| **Shopper** | Registered individual with a shopper account | Everything a visitor can do, plus writing reviews, being picked as a secret shopper, and a basic dashboard |
| **Business owner** | The single user of a business account. The account starts with one Silver listing and can add any number of listings at any tier. | Manage listings, **upgrade or downgrade each one**, manage billing, reply to reviews and messages, see analytics for each listing. **Only the owner can change tiers**, and each business account has **exactly one user** for now. |
| **Site operator** | Staff member | Read access to all locations. Write access (moderation, approvals, user management) only to the locations assigned to them. |
| **Admin** | Staff member | Read and write access to all locations. Manages listing tiers and pricing, taxonomy, locations, staff, and platform settings. |

Staff accounts are created by invitation only and must use multi-factor authentication.

---

## 3. MVP scope

### 3.1 In scope

| Capability | Summary | Priority |
|---|---|---|
| Multi-location foundation | Up to 50 locations (states), each with cities. All data is scoped by location. | Must |
| User accounts | Member accounts, dashboards, and permissions. Authentication through Keycloak. | Must |
| Rich business profiles | Logo, cover image, gallery, description, hours, specialties, service area, and contact | Must |
| Listing management | Create, edit, and publish any number of listings per business account, with an approval workflow | Must |
| Categories | A three-level taxonomy: categories, subcategories, and specialties | Must |
| Directory search | Keyword, category, and location search with filters. Results are ordered by tier, then alphabetically. | Must |
| Maps and location | Google Maps view, address autocomplete with Places, and service areas as a list of cities | Must *(confirmed, Q2)* |
| SEO tools | Basic tools for the MVP: dynamic SEO pages, schema, metadata, and sitemaps | Must (basic) |
| Accounts and listing tiers | Business and shopper accounts, Silver, Gold, and Platinum listing tiers, a default Silver listing for every business account, per-listing upgrades and downgrades, and discounts of up to 100% on tier prices | Must |
| Payments | Recurring monthly billing through Stripe, on one invoice per account | Must |
| Reviews | Ratings and reviews on profiles, gated until a secret shopper has reviewed the business | Must |
| Secret shopper program | Random monthly selection, assignments, and survey-based evaluations | Must |
| Messaging | Visitors send messages to members, who reply through an email relay | Must |
| In-app notifications | A notification bell for members and staff (approvals, messages, reviews, billing, secret shopper), refreshed every minute, alongside email (ADR-0020) | Must |
| Activity tracking | Every search, view, and click by users and the public is recorded | Must |
| Data visualizations | Dashboards for each listing that depend on its tier, an admin dashboard, and limited public charts | Must (business and admin), Should (public) |
| **Survey insights** | Results of the separate survey app's surveys, shown in BlackPages to businesses (by tier), shoppers, the public (a few charts per state), and admins. The survey app is integrated through APIs, and each of its sites is a BlackPages location (ADR-0022, SPEC-SRV-01). | Must (admin view: Should) |
| Administration | Search, filter, edit, and approve members. Moderation and audit. | Must |
| Minimal home page | A search box, a location selector, and navigation | Must |

### 3.2 Out of scope for the MVP (planned for later releases)
- Social login and passkeys. These are enabled later through Keycloak with no code migration.
- Live chat. It isn't planned (Q4). The MVP uses an email relay for messaging.
- Real-time push to the browser, and notification preferences (post-MVP P.12 and P.13). The MVP refreshes notifications every minute (ADR-0020).
- **Internal product analytics with PostHog** (funnels, session replay, A/B tests). It's optional and unscheduled (story 11.5, ADR-0021). Customer-facing analytics always use BlackPages' own data.
- **Surveys that businesses create themselves** (screen S43). Survey insights in the MVP cover the survey app's surveys only (SPEC-SRV-01).
- Advanced SEO tools: a content editor, a Search Console dashboard, SEO audits, FAQ schema, and "Best X in Y" editorial pages.
- Metadata that members can edit themselves.
- **Multiple users per business account** (team invites and an editor role). In the MVP each business account has exactly one user, its owner.
- Admins viewing the site as a member (impersonation).
- Native mobile apps.
- Radius and custom polygons for service areas. The MVP supports a list of cities (Q5).
- Configuring which visualizations each listing tier gets through the admin UI.
- Exporting data to a warehouse, and advanced analytics.

---

## 4. Accounts, listing tiers, and pricing

The full rules are in **SPEC-BILL-01, Account Types, Listing Tiers, and Entitlements**. This section summarizes them.

### 4.1 Account types

There are **two account types**. There are no account plans.

| Account type | Monthly charges | What's included |
|---|---|---|
| **Business** | $1 service fee, plus the tier price of **every** listing, including the default Silver listing | **One Silver listing is created by default** (the "default Silver listing"). The account can add **any number of listings**, each at the tier the owner chooses. |
| **Shopper** | The shopper account price (to be set), less any discount, **plus** the $1 service fee | Writing reviews, secret shopper eligibility, message history, and a shopper dashboard |

### 4.2 Listing tiers

**Silver, Gold, and Platinum are tiers of an individual listing.** Each listing has exactly one tier, and a business can mix tiers, for example one Platinum listing and two Silver listings. Each tier includes everything in the tier below it.

| Feature (per listing) | Silver | Gold | Platinum |
|---|---|---|---|
| Name, phone, category and subcategory, optional address | ✓ | ✓ | ✓ |
| Listed in the directory and search | ✓ | ✓ | ✓ |
| Logo, cover image, description, hours | ✓ | ✓ | ✓ |
| Gallery photos *(confirmed, Q6)* | 1 | 3 | 6 |
| Specialties *(to be confirmed)* | 3 | 5 | 10 |
| Receive visitor messages | ✓ | ✓ | ✓ |
| Placement in category lists | Standard | **Above Silver** | **Above all other tiers** |
| Featured on the directory landing page | — | ✓ | ✓ |
| Shown on the map (unless online-only, or the owner opts out) | ✓ | ✓ | ✓ |
| Website and social media links | — | — | ✓ |
| Analytics for the listing | Basic: views and clicks | Adds trends and search terms | Adds category benchmarks and review and survey insights |
| Monthly price | $ TBD (also charged for the default Silver listing) | $ TBD | $ TBD |

### 4.3 Pricing rules
- **Shopper accounts** are charged the **shopper account price** every month. Discounts apply to it the same way as to listing tier prices, and **the $1 service fee is charged in addition**.
- **Tier prices, the shopper account price, and entitlements can be changed by an admin** without code changes. Existing listings keep their price when prices change.
- A **monthly service fee of $1** applies to **every business and shopper account**, once per account however many listings it has. **Discounts never apply to it**, so every account pays at least $1 a month, and **a card is always required**.
- **The default Silver listing** is an ordinary listing: it's **charged the Silver price**, **discounts apply to it the same way** as to any other Silver listing, and it can be upgraded, downgraded, or removed like any other (as long as the account keeps at least one listing).
- **All charges for an account go on one consolidated invoice:** the service fee, plus one line per listing at its tier price.
- **Upgrading and downgrading:** **only the account owner** can **upgrade or downgrade each listing**, including the default Silver listing. Upgrades take effect immediately, charging the prorated difference. Downgrades take effect at the end of the billing period and can be canceled until then. Other listings on the account aren't affected. Silver is the lowest tier.
- **Lapsed accounts** get a 7-day grace period, after which **all of the account's listings** are hidden. Nothing is deleted.

### 4.4 Discounts and listings discounted to $0
Discounts are the main way to attract members, for example an Arizona launch offer.

| Rule | Detail |
|---|---|
| What it applies to | **Listing tier prices** (optionally only certain tiers), **including the default Silver listing**, and the **shopper account price**. **It never applies to the $1 service fee.** |
| Amount | A percentage **up to 100%**, or a fixed amount. A fixed discount can reduce a charge to $0 but never below it. |
| Duration | Once, a set number of months, or forever. There can also be an expiry date after which new customers can't redeem it. |
| How it's applied | Either a **code** entered at signup or checkout, or an **automatic campaign** that applies itself. Both can be limited by date window, location, tier, number of redemptions, and new customers only. |
| Stacking | Each listing, and each shopper account price, can carry one discount at a time. Discounts can't be combined. *(Assumption)* |
| Display | A tier discounted to $0 shows as **"Free"** with the price afterwards, for example "Gold listing free for 3 months, then $X/month". The $1 account service fee is always shown separately. |
| Effect on features | A listing discounted to $0 has **all of its tier's features**. Discounts never change entitlements. |
| When a discount ends | The owner is emailed **7 days before the full tier price is first charged**, showing the new monthly total. |
| Tier changes during a discount | The discount carries over only if it covers the new tier. Otherwise the new tier is billed at full price, prorated. *(Assumption)* |

---

## 5. Key business rules

### 5.1 Directory ordering
Within any category, city, or specialty list, results are ordered **Platinum (A–Z), then Gold (A–Z), then Silver (A–Z)**. Tier ordering still applies when filters are used.

### 5.2 Reviews
- Only registered shopper and business accounts **in good standing** (not lapsed or suspended) can write reviews. The public can only read them.
- Each reviewer can leave **one review per business**, which they can edit. A business can't review itself.
- **Reviews of a business are hidden from the public until at least one secret shopper review has been submitted for it.** Authors see their own hidden reviews marked "pending".
- Reviews can be flagged, and operators moderate them. Businesses can reply publicly to reviews.

### 5.3 Secret shopper program
- On the 1st of every month, **1 in 100 active businesses and 1 in 100 active shoppers are selected at random in each location**, with at least one of each when the pool isn't empty.
- Only accounts in good standing are eligible. **A business account counts once**, however many listings it has *(proposed: see Q18)*. Anyone selected the previous month is excluded.
- **Each secret shopper evaluates, and can get a rebate from, no more than 2 listings** (Q10). **The rebate is offered by the listing.** Whether shoppers choose listings or are assigned them is to be decided in SPEC-REV-01.
- A secret shopper never evaluates **their own business or a direct competitor in the same category**. A business acting as a secret shopper **makes the purchase in the listed company's name** (Q11). Listings without a secret shopper review yet are prioritized.
- Assignments are confidential. The business never learns who evaluated it.
- A secret shopper submits a review plus a structured survey. **Submitting it unlocks public reviews for that business.**
- Each selection run records its random seed, so it can be audited and repeated. A location can't be selected twice in the same month.

### 5.4 Locations and staff access
- Each location is a US state, and cities sit under it. City URL slugs are unique across all locations.
- At most 50 locations can be active at once.
- Each location and city has an IANA time zone, used for business hours, "open now", and scheduled jobs. Arizona uses `America/Phoenix`, which has no daylight saving time.
- Admins can write to every location. Site operators can write only to locations assigned to them. Both can read everything.

### 5.5 Messaging
- Visitors can contact a business without an account. They're protected by CAPTCHA, rate limits, and spam filtering.
- Replies go through an email relay, so neither side's email address is revealed.
- Each message counts as a lead in the business's analytics.
- There's **no live chat** (Q4). When visitors can't find what they need, they can say what they're looking for and be emailed when it's added (story 4.8).

---

## 6. Feature summary by epic

| Epic | Name | MVP content |
|---|---|---|
| E1 | Multi-location foundation | Location and city management, location scoping, a location selector |
| E2 | Identity and accounts | Keycloak authentication, registration and onboarding, staff invites with MFA, the member dashboard (one user per business account), the in-app notification center |
| E3 | Listing management and rich profiles | Any number of listings per account, media, hours, geocoding, the approval workflow, profile pages |
| E4 | Categories and browsing | A three-level taxonomy, the directory index, tier ordering, pagination |
| E5 | Search and maps | Search that combines keyword, category, and city, filters, Google Maps, service areas, map cost controls |
| E6 | SEO tools (basic) | Static and dynamic URLs, server-side rendering, metadata templates, schema.org markup, sitemaps, 301 redirects, protection against thin-content pages |
| E7 | Accounts, tiers, and pricing | Configurable listing tiers and account pricing, the default Silver listing, per-listing upgrades and downgrades, the entitlement engine, discounts up to 100% on tier prices (never the service fee), one invoice per account, the $1 fee |
| E8 | Payments | Stripe Checkout or Elements, webhooks, dunning, refunds |
| E9 | Reviews | Reviews, the unlock gate, ratings, moderation, business replies |
| E10 | Secret shopper program | Selection, eligibility, assignment, notifications, evaluations, surveys, a program dashboard |
| E11 | Activity tracking | An event taxonomy, asynchronous ingestion, cookie consent, bot filtering |
| E12 | Data visualizations | Dashboards for each listing by tier, an account overview, the admin dashboard, public charts |
| E13 | Home page and public UX | A minimal home page, responsive design, pricing and static pages |
| E14 | Administration | Operator assignments, member management, bulk actions, audit log, email templates |
| E15 | Non-functional requirements | Security, performance, accessibility, reliability, privacy |
| E16 | Messaging | A contact form, spam controls, the member inbox, the reply relay, lead tracking |
| E18 | Survey insights and survey app integration | APIs between BlackPages and the survey app (sites are locations), syncing responses, summaries with privacy rules, survey charts for businesses, shoppers, the public, and admins, and retiring the MariaDB sync. E17 isn't used. |

The full backlog, with user stories and acceptance criteria, is maintained separately. Appendix A lists the MVP stories.

---

## 7. SEO requirements (basic MVP)

| URL pattern | Page |
|---|---|
| `/member/{slug}` | A business profile, for example `/member/acme-plumbing` |
| `/directory/{category}` | A category index, for example `/directory/plumbers` |
| `/directory/{category}/{city}` | Category plus city, for example `/directory/plumbers/phoenix` |
| `/directory/{category}/{city}/{specialty}` | Specialty plus city *(the pattern is to be confirmed, question Q8)* |

- Every public page is rendered on the server and has a canonical URL, a title and description generated from a template, and Open Graph tags.
- **Schema markup:** LocalBusiness, BreadcrumbList, ItemList, WebSite with a search action, and AggregateRating (only once reviews are unlocked).
- XML sitemaps for each location and a robots.txt file. A 301 redirect is created whenever a slug changes.
- Dynamic pages with **fewer than 3 listings** are marked `noindex` and left out of the sitemap.

---

## 8. Non-functional requirements

| Area | Requirement |
|---|---|
| Performance | API p95 response time under 500 ms. Largest Contentful Paint under 2.5 s and Cumulative Layout Shift under 0.1 on public pages. Search responses under 300 ms (p95). |
| Availability | 99.5% uptime for the MVP. High-availability configuration before scaling beyond the pilot. |
| Security | Protection against the OWASP Top 10. HTTPS everywhere. PCI SAQ-A, since no card data touches our systems. MFA for staff. Authentication tokens are never stored in the browser. |
| Accessibility | WCAG 2.1 AA |
| Privacy | Cookie consent before any non-essential tracking. Compliance with CCPA and state privacy laws. Account deletion with anonymization. |
| Quality | Automated test coverage gate of **95% of lines and 90% of branches** on backend and frontend. Mutation testing on critical modules. End-to-end tests for the key user journeys. |
| Observability | Centralized logs with retention limits, health checks, metrics, and alerting |
| Scalability | Architecture supports 50 locations. Individual modules can be extracted into services later. |

---

## 9. Technical architecture summary

| Layer | Choice | ADR |
|---|---|---|
| Backend | **Spring Boot 4.1 on Java 25**, as a modular monolith | 0001, 0018 |
| Frontend | Next.js (React), with route groups for public, member, and admin | 0002 |
| Database | PostgreSQL 16 with PostGIS, Flyway migrations | 0003 |
| Search | Postgres full-text search behind a SearchPort interface | 0004 |
| Identity | **Keycloak 26.7.x**, running in Docker with its own Postgres database | 0005, 0016 |
| Sessions | The backend is the OIDC client and keeps server-side sessions (Spring Session JDBC) | 0006 |
| Authorization | Four layers enforced by the application: role, location, ownership, entitlement | 0007, 0008 |
| Payments | Stripe Billing | 0009 |
| Background work | Transactional outbox and ShedLock. No Redis in the MVP. | 0010 |
| Analytics | An event table partitioned by month | 0011 |
| API | Designed contract-first with OpenAPI. A typed client is published for the frontend. | 0012 |
| Repositories | `directory-app-svc`, `directory-app-ui`, `directory-app-infra` | 0013 |
| Hosting | AWS: ECS Fargate on ARM, RDS, ALB, S3 and CloudFront | 0014 |
| Email | Postmark for application email, Keycloak email over SMTP, and the reply relay | 0015 |

### 9.1 Estimated monthly infrastructure cost (AWS, MVP traffic)

| Environment | Estimate |
|---|---|
| Minimal production | ~$140–160 |
| Staging (scheduled to run in business hours) | ~$40–55 |
| Production with high availability (recommended before scaling) | ~$310–360 |

These estimates exclude usage-based fees from Stripe, Google Maps, and the email provider.

---

## 10. Release plan

The plan uses two-week sprints with two BlackPages teams, backend (svc) and frontend (ui), plus the **survey app team** for its own changes (E18). The timeline is about **26 weeks** from Sprint 0 to launch.

| Sprint | Theme | Main stories | Milestone |
|---|---|---|---|
| **0** | Foundation | 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 2.11, 2.16, 2.22 |  |
| **1** | Locations and identity | 1.1, 1.3, 2.1, 2.3, 2.4, 2.12, 2.14, 2.15, 2.17, 2.18 |  |
| **2** | Listings, taxonomy, and entitlements | 1.2, 1.5, 2.2, 2.17, 2.20, 3.1, 3.4, 3.5, 4.1, 4.6, 4.7, 7.10, 13.2 |  |
| **3** | Rich profiles, approval, and staff security | 1.4, 2.8, 2.9, 2.19, 3.6, 3.7, 3.8, 3.10, 4.2, 4.3, 4.4, 4.5 |  |
| **4** | SEO, search, and observability | 5.1, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8a, 15.4 | **R1: internal alpha** in Arizona |
| **5** | Monetization core | 7.1, 7.3, 7.6, 7.13, 8.1, 8.2, 11.1, 13.1, 13.3 |  |
| **6** | Discounts, upgrades, and maps | 3.2, 3.3, 5.3, 5.7, 7.2, 7.4, 7.5, 7.7, 7.11, 7.12, 11.3, 18.18 | **R2: paid beta** with Arizona businesses |
| **7** | Service areas and messaging | 2.6, 3.9, 5.8, 5.9, 11.2, 16.1, 16.2, 16.3, 16.4, 16.6, 18.3, 18.4 |  |
| **8** | Reviews and secret shopper | 6.8b, 9.1, 9.2, 9.3, 9.4, 10.1, 10.3, 10.4, 10.5, 18.1, 18.2, 18.5 |  |
| **9** | Administration, analytics, and notifications | 2.5, 2.23, 12.1, 12.2, 13.4, 14.1, 14.2, 14.3, 14.5, 15.5, 16.8, 18.6, 18.15 |  |
| **10** | Should-have items | 2.21, 4.8, 6.9, 7.8, 8.3, 8.4, 9.5, 10.2, 10.6, 10.7, 12.4, 14.4, 14.6, 16.5, 16.7 | Can move after the MVP (saves about 2 weeks) |
| **11** | Survey insights | 12.3, 18.7, 18.8, 18.9, 18.10, 18.11, 18.12, 18.13 |  |
| **12** | Hardening and launch | 5.2, 6.12, 11.4, 15.1, 15.2, 15.3 | **R3: public MVP launch in Arizona** |

### 10.1 Sequencing rationale
- **Identity and the entitlement engine come first**, because profiles, messaging, analytics, and billing all depend on them.
- **Tracking starts in Sprints 5–7**, so real data exists by the time dashboards are built in Sprint 9.
- **Payments come before reviews and the secret shopper program**, because those features depend on accounts in good standing.
- **Service-area search comes after the base map**, because it reuses the geocoding and map components.

### 10.2 Definition of Done
- The acceptance criteria are met, and the code has been reviewed and merged to `main`.
- **Coverage gates pass**: backend lines at 95% or more and branches at 90% or more (JaCoCo), frontend at 95% or more (Vitest), and a PIT mutation score of 80% or more on critical modules.
- The authorization matrix has an entry for every new endpoint.
- Changes to the OpenAPI contract are merged before the work that implements them starts.
- The feature is deployed to staging, and the end-to-end smoke tests pass.
- The work meets the accessibility and performance budgets.

---

## 11. Assumptions

| # | Assumption |
|---|---|
| A1 | A location is a US state, and cities sit under it. Up to 50 locations can be active. The initial launch location is Arizona. |
| A2 | City slugs are unique across all locations (for example, `springfield-mo`). |
| A3 | Listing tiers are cumulative (each includes everything in the tier below). The $1 service fee is charged once per account, on top of any tier prices. |
| A4 | A shopper account is charged the shopper account price each month (discounts can apply), plus the $1 service fee. |
| A5 | Only accounts in good standing can write reviews. |
| A6 | One secret shopper review unlocks all approved reviews for that business. |
| A7 | Secret shoppers are selected in each location every month (1%, with a minimum of 1). Each can evaluate, and get a rebate from, no more than 2 listings (Q10). |
| A8 | "Surveys" means the structured questionnaire a secret shopper completes. |
| A9 | Admins and operators can both read every location. Operators write only to the locations assigned to them. |
| A10 | Stripe is the card processor, using hosted card fields (PCI SAQ-A). |
| A11 | **There are two account types, business and shopper, and no account plans.** Every business account starts with a default Silver listing, which is charged and discounted like any other Silver listing. Discounts of up to 100% can bring a tier price to $0, but **never cover the $1 service fee**. Discounts don't stack. |
| A12 | **Silver, Gold, and Platinum are tiers of individual listings.** Each listing has its own tier. All gated features are controlled by one entitlement engine (SPEC-BILL-01). |
| A13 | Specialties are tags under a subcategory. |
| A14 | A service area is a **list of cities** (Q5). A business can hide its street address, or be **online-only** (no address, not on the map). |
| A15 | Messaging works without an account and uses an email relay. There's no live chat (Q4). |
| A16–A18 | Dynamic SEO pages are indexed only when they have 3 or more listings. Schema markup reflects each listing's tier and settings. |
| A19 | **Each business account has exactly one user, its owner**, who is the only person who can change tiers, add or remove listings, and manage billing. |

---

## 12. Open questions

| # | Question | Affects |
|---|---|---|
| Q1 | *Answered:* card fees on $1 invoices are accepted as a cost of acquiring members. **While an account's listings or shopper price are discounted to $0, the service fee is billed annually ($12)**, which also locks in those members. The mechanics go in SPEC-BILL-02, together with T4. | E7, E8 |
| Q2 | *Answered:* maps are a Must. Silver listings appear on the map but **not on the directory landing page**. Online-only listings, and owners who opt out in their address options, aren't shown on the map. | E4, E5 |
| Q3 | *Resolved:* discounts never cover the $1 service fee. A card is always required. | E7 |
| Q4 | *Answered:* no live chat. The email relay is enough. Visitors who can't find what they need can say what they're looking for and be told when it's added (new story 4.8). | E4, E16 |
| Q5 | *Answered:* a list of cities is enough. No radius or polygons. | E5 |
| Q6 | *Partly answered:* gallery photos are **Silver 1, Gold 3, Platinum 6**. **Follow-up needed:** the product owner asked whether specialties mean categories. They're the third level under a subcategory (for example, Plumbers > Residential > Tankless water heaters). Keep them, and set a limit per tier? | E3, E4, E7 |
| Q7 | *Resolved:* no team access at launch. Each business account has exactly one user, its owner. Multiple users come after the MVP (backlog P.11). The answer in the 9-30-26 sheet appears to address a different question (attending an event), so no change is needed. | E2 |
| Q8 | *Partly answered:* **the state doesn't appear in URLs.** **Follow-up needed:** should a specialty page be `/directory/plumbers/phoenix/tankless-water-heaters` (under its category) or `/directory/tankless-water-heaters/phoenix` (on its own)? | E6 |
| Q9 | *Answered:* apply noindex tags to pages with too few listings, keeping the category structure for future growth. The threshold stays at 3 listings. | E6 |
| Q10 | *Answered, design needed:* **the incentive is a rebate offered by each listing** (its secret-shopper offer). A shopper can get a rebate from **no more than 2 listings**. Listings that aren't being chosen may need to improve their offer. **Follow-up needed:** do selected shoppers **choose** listings from the offers, or does the platform **assign** them? Who pays the rebate, and how? To be settled in SPEC-REV-01. | E10 |
| Q11 | *Answered:* confirmed. A listed business can be a secret shopper (B2B), must make the purchase in the listed company's name, and never evaluates a competitor in the same category. | E10 |
| Q12 | *Answered:* no Arizona state sales tax on advertising, but some cities (including Phoenix) charge city tax, and other states' registration thresholds must be tracked. Story 7.13 is now a Must in Sprint 5. The approach (configured rates or Stripe Tax) is to-do T8. | E7, E8 |
| Q13 | *Partly answered:* the product owner owns the **Stripe** and **PayPal** accounts. **There are no AWS or Postmark accounts yet.** **Follow-up needed:** who creates and owns AWS and Postmark? Should PayPal be offered at checkout (it's currently Stripe only, ADR-0009)? | ADR-0009, 0014, 0015 |
| Q14 | **Open:** the product owner asked for a discussion to clarify this. | ADR-0005 |
| Q15 | *Answered:* 11 launch cities (section 1.3). Tribal-land time zones don't need handling. | E1 |
| Q16 | *Resolved:* the default Silver listing is charged the Silver price, and discounts apply to it like any other Silver listing. | E7 |
| Q17 | *Resolved:* not applicable. The default listing is an ordinary paid listing, so an upgrade charges the prorated difference. | E7 |
| Q19 | *Resolved:* only the business account owner can upgrade or downgrade listings. | E7 |
| Q20 | **Survey app integration:** see SPEC-SRV-01 OQ-S1 to OQ-S7. **The most urgent is OQ-S5: which team owns the survey app changes, and its repository.** OQ-S4 (survey consent at onboarding) is needed before Sprint 8. | E18 |
| Q18 | Is the secret shopper pool 1 in 100 **business accounts** (proposed, so businesses with many listings aren't favored) or 1 in 100 **listings** (the original brief's wording)? | E10 |

---

## 13. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Too few businesses and shoppers join in Arizona | Low engagement. Not enough members for random secret shopper selection. | Introductory discounts (up to 100% during the Arizona launch) to grow listings. Minimum selection of one. Launch marketing focused on the largest Arizona metros first. |
| Reviews stay locked for a long time | Few reviews are visible, which reduces the value of the directory | Prioritize businesses without a secret shopper review. Monitor completion rates. Admins can reselect. |
| Listings move down when a free offer ends | Revenue falls short of forecasts | A card is always on file, because the service fee is always charged. Send a reminder 7 days before the full price is first charged. Always show the price after the discount. |
| Card fees on small charges | An account whose listings are all discounted to $0 pays only the $1 fee, and standard card fees take about a third of it | **Decided (Q1):** bill the service fee annually ($12) during $0 offers, and accept the remaining cost as a cost of acquisition |
| Google Maps usage costs | Unexpected bills | Restricted API keys, loading maps only when needed, static maps in lists, usage alerts |
| Survey email limit | The survey app sends at most 85 emails a day (Mailgun free tier), so a survey to 2,000 members takes about 24 days | Story 18.15: a paid plan or Postmark before the first live survey |
| Retiring the Brilliant Directories sync | Survey responses could be lost or miscounted during the switch | Run in parallel with a daily comparison, and switch off only after 2 clean survey cycles (story 18.16) |
| Identifying survey respondents | Small groups could reveal who answered | A minimum group size of 5 everywhere except the admin console, free text never public, responses stored pseudonymously (SPEC-SRV-01) |
| Thin-content SEO penalties | Pages rank poorly | Threshold for indexing dynamic pages, and schema markup that reflects each listing's tier |
| Keycloak operations and upgrades | Security exposure if patches are missed | Pinned versions, configuration as code, a quarterly upgrade window, staging first, a login end-to-end suite |
| **Backend capacity** | The plan needs about 371 backend points, but 4 backend developers at 20 hours a week deliver about 290 in 26 weeks, so the backend could be about 80 points short | Measure velocity per side at the end of Sprint 2. If behind: move Should items after launch, then have frontend developers take simple backend stories, then extend the timeline (backlog section 3, "Team and capacity") |
| Cost of the 95% coverage target | Slower delivery | Keep logic out of page files, test with builders and fakes, exclude only generated code and configuration |
| Coordination between two teams | API integration delays | Contract-first spec pull requests, MSW mocks, versioned client packages |

---

## Appendix A: MVP story index

The full backlog, with user stories and acceptance criteria, is in `docs/product/backlog.md`.

**Priority key:** M = Must, S = Should, C = Could, TBD = waiting on a decision.

| ID | Story | Pri | Sprint |
|---|---|---|---|
| 0.1 | Architecture decision records | M | 0 |
| 0.2 | Repository scaffolding | M | 0 |
| 0.3 | CI pipelines with coverage gates | M | 0 |
| 0.4 | Staging environment | M | 0 |
| 0.5 | Analytics event taxonomy | M | 0 |
| 0.6 | Identity spike | M | 0 |
| 0.7 | Platform compatibility spike | M | 0 |
| 1.1 | Create and manage locations | M | 1 |
| 1.2 | Manage cities | M | 2 |
| 1.3 | Scope data by location | M | 1 |
| 1.4 | Location selector | M | 3 |
| 1.5 | Arizona launch data | M | 2 |
| 2.1 | Account registration through Keycloak | M | 1 |
| 2.2 | Onboarding for shoppers and businesses | M | 2 |
| 2.3 | Login through the backend (OIDC) | M | 1 |
| 2.4 | Role-based access control | M | 1 |
| 2.5 | Profile updates and account deletion | S | 9 |
| 2.6 | Member dashboard home | M | 7 |
| 2.8 | MFA required for staff | M | 3 |
| 2.9 | Staff invites | M | 3 |
| 2.11 | Password policy | M | 0 |
| 2.12 | Authorization matrix test | M | 1 |
| 2.14 | Identity layer interfaces | M | 1 |
| 2.15 | User identity table | M | 1 |
| 2.16 | Keycloak in the local stack and CI | M | 0 |
| 2.17 | Keycloak login theme | M | 1–2 |
| 2.18 | Just-in-time provisioning | M | 1 |
| 2.19 | User lifecycle sync and reconciliation | M | 3 |
| 2.20 | Logout | M | 2 |
| 2.21 | Hardened staff authentication flow | S | 10 |
| 2.22 | Keycloak in AWS | M | 0 |
| 2.23 | In-app notification center | M | 9 |
| 3.1 | Create a listing | M | 2 |
| 3.2 | Website and social links for Platinum listings | M | 6 |
| 3.3 | Add more listings | M | 6 |
| 3.4 | Address entry and geocoding | M | 2 |
| 3.5 | Edit, pause, and reactivate a listing | M | 2 |
| 3.6 | Listing approval workflow | M | 3 |
| 3.7 | Logo and cover image | M | 3 |
| 3.8 | Description, hours, and details | M | 3 |
| 3.9 | Photo gallery | M | 7 |
| 3.10 | Rich profile page | M | 3 |
| 4.1 | Category taxonomy | M | 2 |
| 4.2 | Category page ordering | M | 3 |
| 4.3 | Filter by city and subcategory | M | 3 |
| 4.4 | Directory index | M | 3 |
| 4.5 | Pagination | M | 3 |
| 4.6 | Specialties | M | 2 |
| 4.7 | Tag a listing with specialties | M | 2 |
| 4.8 | Category requests and "notify me when found" | S | 10 |
| 5.1 | Search | M | 4 |
| 5.2 | Search autocomplete | S | 12 |
| 5.3 | Map view | M | 6 |
| 5.5 | Search filters | M | 4 |
| 5.7 | Service area | M | 6 |
| 5.8 | Search by service area | M | 7 |
| 5.9 | Google Maps cost controls | M | 7 |
| 6.1 | Listing URLs | M | 4 |
| 6.2 | Server-rendered category and city pages | M | 4 |
| 6.3 | Metadata templates | M | 4 |
| 6.4 | Sitemaps and robots.txt | M | 4 |
| 6.5 | Redirects when slugs change | M | 4 |
| 6.6 | Dynamic specialty pages | M | 4 |
| 6.7 | Keep thin pages out of the index | M | 4 |
| 6.8a | Core schema markup | M | 4 |
| 6.8b | Schema for reviews, service area, and tier | M | 8 |
| 6.9 | Metadata overrides | S | 10 |
| 6.12 | Search Console setup | M | 12 |
| 7.1 | Configure listing tiers and account pricing | M | 5 |
| 7.2 | Discount engine | M | 6 |
| 7.3 | Sign up and pay | M | 5 |
| 7.4 | Upgrade or downgrade a listing | M | 6 |
| 7.5 | One invoice for all listings | M | 6 |
| 7.6 | $1 monthly service fee | M | 5 |
| 7.7 | Lapsed accounts | M | 6 |
| 7.8 | Billing history and invoices | S | 10 |
| 7.10 | Entitlement engine | M | 2 |
| 7.11 | Listings discounted to $0 | M | 6 |
| 7.12 | Promotions at checkout and on the pricing page | M | 6 |
| 7.13 | Sales tax on subscriptions | M | 5 |
| 8.1 | Card payments | M | 5 |
| 8.2 | Payment webhooks | M | 5 |
| 8.3 | Dunning | S | 10 |
| 8.4 | Refunds | S | 10 |
| 9.1 | Write a review | M | 8 |
| 9.2 | Hide reviews until a secret shopper has reviewed | M | 8 |
| 9.3 | Average rating | M | 8 |
| 9.4 | Flag and moderate reviews | M | 8 |
| 9.5 | Business replies | S | 10 |
| 10.1 | Monthly random selection | M | 8 |
| 10.2 | Eligibility rules | S | 10 |
| 10.3 | Secret shopper listings and rebates | M | 8 |
| 10.4 | Confidential notifications | M | 8 |
| 10.5 | Submit an evaluation | M | 8 |
| 10.6 | Survey configuration | S | 10 |
| 10.7 | Program dashboard | S | 10 |
| 11.1 | Track user activity | M | 5 |
| 11.2 | Event storage, partitions, and summary tables | M | 7 |
| 11.3 | Cookie consent | M | 6 |
| 11.4 | Bot filtering | S | 12 |
| 11.5 | Internal product analytics with PostHog (optional) | C | TBD |
| 12.1 | Business dashboards by listing tier | M | 9 |
| 12.2 | Admin analytics dashboard | M | 9 |
| 12.3 | Public charts | S | 11 |
| 12.4 | Shopper dashboard | S | 10 |
| 13.1 | Home page | M | 5 |
| 13.2 | Responsive and accessible design | M | 2 |
| 13.3 | Pricing page | M | 5 |
| 13.4 | Static pages | M | 9 |
| 14.1 | Manage operator assignments | M | 9 |
| 14.2 | Admin console access rules | M | 9 |
| 14.3 | Manage members | M | 9 |
| 14.4 | Audit log | S | 10 |
| 14.5 | Email templates | M | 9 |
| 14.6 | Bulk moderation | S | 10 |
| 15.1 | Performance budgets | M | 12 |
| 15.2 | Accessibility audit | M | 12 |
| 15.3 | Security testing | M | 12 |
| 15.4 | Observability | M | 4 |
| 15.5 | Privacy compliance | M | 9 |
| 16.1 | Contact form | M | 7 |
| 16.2 | Spam protection | M | 7 |
| 16.3 | Member inbox | M | 7 |
| 16.4 | Replies through an email relay | M | 7 |
| 16.5 | Shopper message history | S | 10 |
| 16.6 | Messaging by listing tier | M | 7 |
| 16.7 | Report and block senders | S | 10 |
| 16.8 | Message leads in analytics | M | 9 |
| 18.1 | Locations integration API | M | 8 |
| 18.2 | Survey recipients integration API and consent | M | 8 |
| 18.3 | Keycloak clients for the survey integration | M | 7 |
| 18.4 | Survey app: sites from BlackPages locations | M | 7 |
| 18.5 | Survey app: recipients from BlackPages | M | 8 |
| 18.6 | Survey app: integration API | M | 9 |
| 18.7 | Survey insights: sync jobs and response copy | M | 11 |
| 18.8 | Survey result summaries with privacy rules | M | 11 |
| 18.9 | Survey insight entitlements | M | 11 |
| 18.10 | Survey insights screen for businesses | M | 11 |
| 18.11 | Survey insights screen for shoppers | M | 11 |
| 18.12 | Public survey highlights | M | 11 |
| 18.13 | Survey analytics for admins | S | 11 |
| 18.15 | Survey app: email capacity | M | 9 |
| 18.16 | Retire the MariaDB sync | M | TBD |
| 18.17 | Survey app admin login through Keycloak | S | TBD |
| 18.18 | Survey app platform and link hardening | M | 6 |

---

## Appendix B: Glossary

| Term | Meaning |
|---|---|
| **Location** | A US state that has its own directory |
| **Account** | A member account: either **business** (owns listings) or **shopper** |
| **Listing** | A business's public entry. A business account can have any number of listings, each with its own tier. |
| **Default Silver listing** | The Silver listing created automatically with every new business account. It's charged, discounted, upgraded, and downgraded like any other listing. |
| **Tier** | The level of an individual listing: Silver, Gold, or Platinum |
| **Discount** | A price reduction of up to 100% on a listing's tier price or the shopper account price. It never applies to the $1 service fee. |
| **Entitlement** | A feature or limit granted by a listing's tier or an account's type, such as the number of gallery photos |
| **Secret shopper** | A randomly selected business or shopper who evaluates assigned businesses |
| **Review unlock** | The moment when a business's reviews become public, triggered by its first secret shopper review |
| **Service area** | The list of cities a business serves, which may differ from its address |
| **Backend-for-frontend (BFF)** | The backend acts as the OIDC client for the browser and keeps authentication tokens on the server |
| **Realm** | Keycloak's container for users, clients, and policies (`blackpages`) |
