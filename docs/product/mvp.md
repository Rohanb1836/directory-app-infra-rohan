# BlackPages.io: Minimum Viable Product (MVP) Definition

| | |
|---|---|
| **Document version** | 1.4 |
| **Date** | 2026-09-27 |
| **Status** | Draft for stakeholder review (v1.4: release plan aligned with Product Backlog v1.0) |
| **Repositories** | `directory-app-svc` (backend), `directory-app-ui` (frontend), `directory-app-infra` (infrastructure) |
| **Related documents** | ADR-0001 to ADR-0016, Identity and Access Design v2.0 (`directory-app-infra/docs/`) |

---

## 1. Product overview

BlackPages.io is a **business directory for multiple locations**. Businesses register a profile, list themselves by category, and pay for subscription plans that make them more visible. Shoppers register to review businesses and join the community. The public can search, browse, and view listings without an account.

The directory's point of difference is **credible reviews**. Reviews of a business stay hidden until a randomly selected **secret shopper** has reviewed that business.

### 1.1 MVP goals
1. Launch a working, SEO-friendly directory in the initial launch location, **Arizona**, with the ability to expand to **50 locations**.
2. Earn recurring revenue from paid subscriptions and the monthly service fee.
3. Establish trust through the secret shopper program and moderated reviews.
4. Collect activity data from day one and show it back to subscribers as dashboards that depend on their plan.

### 1.2 Success metrics (proposed, to be confirmed)

| Metric | Target 90 days after launch in Arizona |
|---|---|
| Published business listings | 500 or more |
| Share of businesses paying for their plan (more than the $1 service fee) after discounts | 15% or more |
| Businesses that keep a paid plan after a free-plan introductory offer ends | 30% or more |
| Registered shoppers | 1,000 or more |
| Searches that lead to a listing view | 40% or more |
| Secret shopper assignments completed | 70% or more |
| Businesses with reviews unlocked | 25% or more of listings that have at least one review |
| Visits from organic search | 50% or more of all sessions |

### 1.3 Initial launch location: Arizona

| Item | Detail |
|---|---|
| Launch location | **Arizona (AZ)**, the first active location. The other 49 location slots stay in draft until expansion. |
| Launch cities | Seed the city list with the major metros first: Phoenix, Tucson, Mesa, Chandler, Scottsdale, Gilbert, Glendale, Tempe, Peoria, and Flagstaff. The remaining cities are added as listings arrive. *(The final list is for the product owner to confirm.)* |
| Time zone | **Arizona doesn't observe daylight saving time**, so most of the state uses `America/Phoenix`. **The Navajo Nation does observe it** and uses `America/Denver`. Each location and city stores an IANA time zone, which is used for business hours, "open now", and scheduled jobs such as the monthly secret shopper selection. |
| SEO | Launch sitemaps and category-by-city pages for the Arizona cities above first. |
| Sales tax | Arizona charges a transaction privilege tax (TPT) at state and city level. Whether it applies to directory subscriptions needs a tax adviser's review before billing goes live (see Q12). |
| Hosting region | Serving Arizona from AWS `us-west-2` (Oregon) gives lower latency than `us-east-1`, at similar prices. This is optional, because the CDN serves most public pages anyway (see ADR-0014). |

---

## 2. Users and roles

| Role | Description | Key abilities |
|---|---|---|
| **Public visitor** | No account | Search, browse, view listings and unlocked reviews, contact businesses, see public charts |
| **Shopper** | Registered individual on a paid plan | Everything a visitor can do, plus writing reviews, being picked as a secret shopper, and a basic dashboard |
| **Business member** | Registered business account on the Silver, Gold, or Platinum plan | Manage listings and branches, reply to reviews and messages, see analytics for their plan. Roles within the account are OWNER and EDITOR. |
| **Site operator** | Staff member | Read access to all locations. Write access (moderation, approvals, user management) only to the locations assigned to them. |
| **Admin** | Staff member | Read and write access to all locations. Manages plans, taxonomy, locations, staff, and platform settings. |

Staff accounts are created by invitation only and must use multi-factor authentication.

---

## 3. MVP scope

### 3.1 In scope

| Capability | Summary | Priority |
|---|---|---|
| Multi-location foundation | Up to 50 locations (states), each with cities. All data is scoped by location. | Must |
| User accounts | Member accounts, dashboards, and permissions. Authentication through Keycloak. | Must |
| Rich business profiles | Logo, cover image, gallery, description, hours, specialties, service area, and contact | Must |
| Listing management | Create, edit, and publish listings, with an approval workflow and branch locations | Must |
| Categories | A three-level taxonomy: categories, subcategories, and specialties | Must |
| Directory search | Keyword, category, and location search with filters. Results are ordered by tier, then alphabetically. | Must |
| Maps and location | Google Maps view, address autocomplete with Places, and service areas | Must *(assumed)* |
| SEO tools | Basic tools for the MVP: dynamic SEO pages, schema, metadata, and sitemaps | Must (basic) |
| Membership plans | Silver, Gold, and Platinum plans, a shopper plan, add-on locations, and discounts of up to 100% | Must |
| Payments | Recurring subscriptions through Stripe | Must |
| Reviews | Ratings and reviews on profiles, gated until a secret shopper has reviewed the business | Must |
| Secret shopper program | Random monthly selection, assignments, and survey-based evaluations | Must |
| Messaging | Visitors send messages to members, who reply through an email relay | Must |
| Activity tracking | Every search, view, and click by users and the public is recorded | Must |
| Data visualizations | Dashboards for subscribers that depend on their plan, an admin dashboard, and limited public charts | Must (subscriber and admin), Should (public) |
| Administration | Search, filter, edit, and approve members. Moderation and audit. | Must |
| Minimal home page | A search box, a location selector, and navigation | Must |

### 3.2 Out of scope for the MVP (planned for later releases)
- Social login and passkeys. These are enabled later through Keycloak with no code migration.
- Live chat. The MVP uses an email relay for messaging.
- Advanced SEO tools: a content editor, a Search Console dashboard, SEO audits, FAQ schema, and "Best X in Y" editorial pages.
- Metadata that members can edit themselves.
- Admins viewing the site as a member (impersonation).
- Native mobile apps.
- Custom polygons for service areas. The MVP supports a list of cities or a radius.
- Showing each subscriber tier a different set of visualizations through admin configuration.
- Exporting data to a warehouse, and advanced analytics.

---

## 4. Membership plans and pricing

### 4.1 Plan ladder

Each plan includes everything in the plan before it.

There is **no free plan**. Silver is the entry plan. A discount can bring a **plan's price** down to $0 for a period or indefinitely (section 4.3). **The $1 monthly service fee is always charged**, so every member pays at least $1 a month.

| Feature | Silver | Gold | Platinum |
|---|---|---|---|
| Name, phone, category and subcategory, optional address | ✓ | ✓ | ✓ |
| Listed in the directory and search | ✓ | ✓ | ✓ |
| Logo, cover image, description, hours | ✓ | ✓ | ✓ |
| Gallery photos *(indicative)* | 3 | 10 | 25 |
| Specialties *(to be confirmed)* | 3 | 5 | 10 |
| Receive visitor messages | ✓ | ✓ | ✓ |
| Placement in category lists | Standard | **Above Silver** | **Above all other tiers** |
| Website and social media links | — | — | ✓ |
| Analytics dashboard | Basic: views and clicks | Adds trends and search terms | Adds category benchmarks and review and survey insights |
| Add-on branch locations | Paid add-on | Paid add-on | Paid add-on |

### 4.2 Pricing rules
- **Every plan price can be changed by an admin** without code changes, including the price, billing interval, and entitlements.
- A **monthly service fee of $1** applies to businesses and shoppers **on top of** the plan price. **Discounts never apply to it.**
- **All charges for an account go on one consolidated invoice:** the plan, add-on locations, and the service fee.
- Upgrades take effect immediately and are prorated. Downgrades take effect at the end of the billing period.
- Lapsed subscriptions get a 7-day grace period, after which the listing is hidden.

### 4.3 Discounts and plans discounted to $0
Discounts replace a free plan as the way to attract members, for example an Arizona launch offer.

| Rule | Detail |
|---|---|
| Plans | Discounts can apply to Silver, Gold, Platinum, and the shopper plan. |
| Amount | A percentage **up to 100%**, or a fixed amount. A fixed discount can reduce a charge to $0 but never below it. |
| Duration | Once, a set number of months, or forever. There can also be an expiry date after which new customers can't redeem it. |
| What it covers | The plan price, and optionally add-on locations (the admin chooses for each discount). **It never covers the $1 service fee.** The smallest possible monthly total is therefore $1. |
| How it's applied | Either a **code** entered at signup or checkout, or an **automatic campaign** that applies itself. Both can be limited by date window, location, plan, number of redemptions, and new customers only. |
| Stacking | One discount per subscription. Discounts can't be combined. *(Assumption)* |
| Display | When the plan price is discounted to $0, the pricing page and checkout show the plan as **"Free"** and state the service fee and the price afterwards, for example "Silver free for 3 months: you pay only the $1/month service fee, then $X/month". |
| Status of discounted subscriptions | A subscription with its plan discounted to $0 is an ordinary **active subscription**. It has all the plan's entitlements and counts as active for reviews and secret shopper eligibility. Its monthly invoice is $1, for the service fee. |
| Card collection | **A card is always required at signup**, because the $1 service fee is always charged. |
| When a discount ends | Members get an email **7 days before the full plan price is first charged**, showing the new monthly total. |
| Plan changes during a discount | The discount carries over only if it covers the new plan. Otherwise the new plan is billed at full price, prorated. *(Assumption)* |

---

## 5. Key business rules

### 5.1 Directory ordering
Within any category, city, or specialty list, results are ordered **Platinum (A–Z), then Gold (A–Z), then Silver (A–Z)**. Tier ordering still applies when filters are used.

### 5.2 Reviews
- Only registered shoppers and businesses with an **active subscription** can write reviews. That includes subscriptions whose plan is discounted to $0. The public can only read them.
- Each reviewer can leave **one review per business**, which they can edit. A business can't review itself.
- **Reviews of a business are hidden from the public until at least one secret shopper review has been submitted for it.** Authors see their own hidden reviews marked "pending".
- Reviews can be flagged, and operators moderate them. Businesses can reply publicly to reviews.

### 5.3 Secret shopper program
- On the 1st of every month, **1 in 100 active businesses and 1 in 100 active shoppers are selected at random in each location**, with at least one of each when the pool isn't empty.
- Only accounts with an active subscription are eligible, including those whose plan is discounted to $0. Anyone selected the previous month is excluded.
- Each secret shopper is assigned businesses to evaluate. **They are never assigned their own business or a direct competitor in the same category.** Businesses without a secret shopper review yet are prioritized.
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

---

## 6. Feature summary by epic

| Epic | Name | MVP content |
|---|---|---|
| E1 | Multi-location foundation | Location and city management, location scoping, a location selector |
| E2 | Identity and accounts | Keycloak authentication, registration and onboarding, staff invites with MFA, the member dashboard, business team roles |
| E3 | Listing management and rich profiles | Listings, media, hours, branches, geocoding, the approval workflow, profile pages |
| E4 | Categories and browsing | A three-level taxonomy, the directory index, tier ordering, pagination |
| E5 | Search and maps | Search that combines keyword, category, and city, filters, Google Maps, service areas, map cost controls |
| E6 | SEO tools (basic) | Static and dynamic URLs, server-side rendering, metadata templates, schema.org markup, sitemaps, 301 redirects, protection against thin-content pages |
| E7 | Subscriptions and pricing | Configurable plans, the entitlement engine, discounts up to 100% on plan prices (never the service fee), upgrades, add-on locations, the $1 fee |
| E8 | Payments | Stripe Checkout or Elements, webhooks, dunning, refunds |
| E9 | Reviews | Reviews, the unlock gate, ratings, moderation, business replies |
| E10 | Secret shopper program | Selection, eligibility, assignment, notifications, evaluations, surveys, a program dashboard |
| E11 | Activity tracking | An event taxonomy, asynchronous ingestion, cookie consent, bot filtering |
| E12 | Data visualizations | Dashboards for subscribers by plan, the admin dashboard, public charts |
| E13 | Home page and public UX | A minimal home page, responsive design, pricing and static pages |
| E14 | Administration | Operator assignments, member management, bulk actions, audit log, email templates |
| E15 | Non-functional requirements | Security, performance, accessibility, reliability, privacy |
| E16 | Messaging | A contact form, spam controls, the member inbox, the reply relay, lead tracking |

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
| Backend | Spring Boot 3.x on Java 21, as a modular monolith | 0001 |
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

The plan uses two-week sprints with two teams, backend (svc) and frontend (ui). The timeline is about **24 weeks** from Sprint 0 to launch.

| Sprint | Theme | Main stories | Milestone |
|---|---|---|---|
| **0** | Foundation | 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 2.11, 2.16, 2.22 |  |
| **1** | Locations and identity | 1.1, 1.3, 2.1, 2.3, 2.4, 2.12, 2.14, 2.15, 2.17, 2.18 |  |
| **2** | Listings, taxonomy, and entitlements | 1.2, 1.5, 2.2, 2.17, 2.20, 3.1, 3.4, 3.5, 4.1, 4.6, 4.7, 7.10, 13.2 |  |
| **3** | Rich profiles, approval, and staff security | 1.4, 2.8, 2.9, 2.19, 3.6, 3.7, 3.8, 3.10, 4.2, 4.3, 4.4, 4.5 |  |
| **4** | SEO, search, and observability | 5.1, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8a, 15.4 | **R1: internal alpha** in Arizona |
| **5** | Monetization core | 7.1, 7.3, 7.6, 8.1, 8.2, 11.1, 13.1, 13.3 |  |
| **6** | Discounts, upgrades, and maps | 3.2, 3.3, 5.3, 5.7, 7.2, 7.4, 7.5, 7.7, 7.11, 7.12, 11.3 | **R2: paid beta** with Arizona businesses |
| **7** | Service areas and messaging | 2.6, 3.9, 5.8, 5.9, 11.2, 16.1, 16.2, 16.3, 16.4, 16.6 |  |
| **8** | Reviews and secret shopper | 6.8b, 9.1, 9.2, 9.3, 9.4, 10.1, 10.3, 10.4, 10.5 |  |
| **9** | Administration and analytics | 2.5, 12.1, 12.2, 13.4, 14.1, 14.2, 14.3, 14.5, 15.5, 16.8 |  |
| **10** | Should-have items | 2.7, 2.21, 6.9, 7.8, 8.3, 8.4, 9.5, 10.2, 10.6, 10.7, 12.3, 12.4, 14.4, 14.6, 16.5, 16.7 | Can move after the MVP (saves about 2 weeks) |
| **11** | Hardening and launch | 5.2, 6.12, 11.4, 15.1, 15.2, 15.3 | **R3: public MVP launch in Arizona** |

### 10.1 Sequencing rationale
- **Identity and the entitlement engine come first**, because profiles, messaging, analytics, and billing all depend on them.
- **Tracking starts in Sprints 5–7**, so real data exists by the time dashboards are built in Sprint 9.
- **Payments come before reviews and the secret shopper program**, because those features depend on active paid accounts.
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
| A3 | Plans are cumulative, and the $1 service fee is charged on top of the plan price. |
| A4 | Shoppers have one paid plan, made up of the $1 fee plus an optional plan price. |
| A5 | Only registered users with an active subscription can write reviews, including subscriptions whose plan is discounted to $0. |
| A6 | One secret shopper review unlocks all approved reviews for that business. |
| A7 | Secret shoppers are selected in each location every month (1%, with a minimum of 1). |
| A8 | "Surveys" means the structured questionnaire a secret shopper completes. |
| A9 | Admins and operators can both read every location. Operators write only to the locations assigned to them. |
| A10 | Stripe is the card processor, using hosted card fields (PCI SAQ-A). |
| A11 | **There's no free plan.** Silver is the entry plan. Discounts of up to 100% can bring a plan's price to $0 for a period or forever, but **never cover the $1 service fee**. Discounts don't stack. |
| A12 | The plan ladder is Silver, Gold, then Platinum. All gated features are controlled by one entitlement matrix. |
| A13 | Specialties are tags under a subcategory. |
| A14 | A service area is a list of cities or a radius. A business can hide its street address. |
| A15 | Messaging works without an account and uses an email relay. |
| A16–A18 | Dynamic SEO pages are indexed only when they have 3 or more listings. Schema markup reflects each listing's plan and settings. |

---

## 12. Open questions

| # | Question | Affects |
|---|---|---|
| Q1 | When a plan is discounted to $0, the invoice is just the $1 fee, and standard card fees would take about a third of it. Should we accept that as the cost of acquiring members, or bill the service fee **annually ($12)** while the plan is discounted? | E7, E8 |
| Q2 | Is Maps and location a Must? It's currently assumed to be. | E5 |
| Q3 | *Resolved:* discounts never cover the $1 service fee. A card is always required. | E7 |
| Q4 | Is the email relay acceptable, or is live chat needed? Live chat would add 1–2 sprints. | E16 |
| Q5 | Is a list of cities or a radius enough for service areas, or are custom polygons needed? | E5 |
| Q6 | How many specialties and gallery photos should each plan allow? | E3, E4, E7 |
| Q7 | Is business team access (story 2.7) needed at launch? | E2 |
| Q8 | Should specialty URLs nest under the category or sit at the top level? Should the state appear in URLs? | E6 |
| Q9 | Is 3 listings the right minimum for indexing a dynamic page? | E6 |
| Q10 | What incentives do secret shoppers get, and how many businesses does each one evaluate? | E10 |
| Q11 | Can a secret shopper who is a business review a competitor in the same category? It's currently assumed they can't. | E10 |
| Q12 | Does the platform need to collect sales tax on subscriptions? **Start with Arizona's state and city transaction privilege tax (TPT).** Consider Stripe Tax. | E7, E8 |
| Q13 | Confirm AWS, Stripe, and Postmark, and who owns each account. | ADR-0009, 0014, 0015 |
| Q14 | Staff MFA: use the default conditional OTP flow with reconciliation, or a custom flow keyed on the `staff` role? | ADR-0005 |
| Q15 | Confirm the list of Arizona cities to seed at launch, and whether the Navajo Nation's time zone needs handling for any city on it. | E1 |

---

## 13. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Too few businesses and shoppers join in Arizona | Low engagement. Not enough members for random secret shopper selection. | Introductory discounts (up to 100% during the Arizona launch) to grow listings. Minimum selection of one. Launch marketing focused on the largest Arizona metros first. |
| Reviews stay locked for a long time | Few reviews are visible, which reduces the value of the directory | Prioritize businesses without a secret shopper review. Monitor completion rates. Admins can reselect. |
| Members leave when a $0 offer ends | Revenue falls short of forecasts | A card is always on file, because the service fee is always charged. Send a reminder 7 days before the full price is first charged. Always show the price after the discount. |
| Card fees on small charges | When a plan is discounted to $0, the invoice is only $1, and standard card fees take about a third of it | Put the fee on the consolidated plan invoice whenever there is one. For discounted periods, decide Q1 (accept the cost, or bill the fee annually). |
| Google Maps usage costs | Unexpected bills | Restricted API keys, loading maps only when needed, static maps in lists, usage alerts |
| Thin-content SEO penalties | Pages rank poorly | Threshold for indexing dynamic pages, and schema markup that reflects the plan |
| Keycloak operations and upgrades | Security exposure if patches are missed | Pinned versions, configuration as code, a quarterly upgrade window, staging first, a login end-to-end suite |
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
| 2.7 | Business team invites | S | 10 |
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
| 3.1 | Create a listing | M | 2 |
| 3.2 | Website and social links for Platinum | M | 6 |
| 3.3 | Branch locations | M | 6 |
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
| 5.1 | Search | M | 4 |
| 5.2 | Search autocomplete | S | 11 |
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
| 6.8b | Schema for reviews, service area, and plan | M | 8 |
| 6.9 | Metadata overrides | S | 10 |
| 6.12 | Search Console setup | M | 11 |
| 7.1 | Configure plans | M | 5 |
| 7.2 | Discount engine | M | 6 |
| 7.3 | Choose a plan and pay at signup | M | 5 |
| 7.4 | Upgrade and downgrade | M | 6 |
| 7.5 | Consolidated billing for branches | M | 6 |
| 7.6 | $1 monthly service fee | M | 5 |
| 7.7 | Lapsed subscriptions | M | 6 |
| 7.8 | Billing history and invoices | S | 10 |
| 7.10 | Entitlement engine | M | 2 |
| 7.11 | Plans discounted to $0 | M | 6 |
| 7.12 | Promotions at checkout and on the pricing page | M | 6 |
| 7.13 | Sales tax on subscriptions | TBD | TBD |
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
| 10.3 | Assign businesses to secret shoppers | M | 8 |
| 10.4 | Confidential notifications | M | 8 |
| 10.5 | Submit an evaluation | M | 8 |
| 10.6 | Survey configuration | S | 10 |
| 10.7 | Program dashboard | S | 10 |
| 11.1 | Track user activity | M | 5 |
| 11.2 | Event storage and aggregates | M | 7 |
| 11.3 | Cookie consent | M | 6 |
| 11.4 | Bot filtering | S | 11 |
| 12.1 | Business dashboards by plan | M | 9 |
| 12.2 | Admin analytics dashboard | M | 9 |
| 12.3 | Public charts | S | 10 |
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
| 15.1 | Performance budgets | M | 11 |
| 15.2 | Accessibility audit | M | 11 |
| 15.3 | Security testing | M | 11 |
| 15.4 | Observability | M | 4 |
| 15.5 | Privacy compliance | M | 9 |
| 16.1 | Contact form | M | 7 |
| 16.2 | Spam protection | M | 7 |
| 16.3 | Member inbox | M | 7 |
| 16.4 | Replies through an email relay | M | 7 |
| 16.5 | Shopper message history | S | 10 |
| 16.6 | Messaging by plan | M | 7 |
| 16.7 | Report and block senders | S | 10 |
| 16.8 | Message leads in analytics | M | 9 |

---

## Appendix B: Glossary

| Term | Meaning |
|---|---|
| **Location** | A US state that has its own directory |
| **Listing** | A business's public entry. A business account can have several listings, one per branch. |
| **Tier** | A business plan level: Silver, Gold, or Platinum |
| **Discount** | A price reduction of up to 100% on a plan price, and optionally on add-on locations. It never applies to the $1 service fee. |
| **Entitlement** | A feature or limit that a plan grants, such as the number of gallery photos |
| **Secret shopper** | A randomly selected business or shopper who evaluates assigned businesses |
| **Review unlock** | The moment when a business's reviews become public, triggered by its first secret shopper review |
| **Service area** | The cities or radius a business serves, which may differ from its address |
| **Backend-for-frontend (BFF)** | The backend acts as the OIDC client for the browser and keeps authentication tokens on the server |
| **Realm** | Keycloak's container for users, clients, and policies (`blackpages`) |
