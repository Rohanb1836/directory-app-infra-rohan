# Review: UI Screen Stories v1.1

| | |
|---|---|
| **Document reviewed** | `ui-screen-stories.md` v1.1 (2026-10-06), 48 screens |
| **Review date** | 2026-10-06 (v1.3: product owner's answers, section 9; notification bell, section 10; survey insights screens, section 11) |
| **For** | Pavan, Ram, Desmond (web team) |
| **Checked against** | Product Backlog v1.5 (125 stories), MVP Definition v1.9, SPEC-BILL-01 v0.5, Identity and Access Design v2.2, Frontend Architecture v1.0, ADR-0001 to ADR-0019, To-Do List v1.0 |
| **Suggested location** | `directory-app-ui/docs/product/ui-screen-stories-review.md` |

**Note:** this review covers the screen list. The ordering in `ui-work-plan.md` wasn't available and should be checked against section 6.

---

## 1. Summary

The list covers **about 90%** of the screens the backlog needs. It's strong on standard states (loading, empty, error, not found), on locked and limit-reached states, and on stating "Pending decision" where rules aren't settled.

| Finding | Count | Section |
|---|---|---|
| Screens or states that are **missing** | 11, plus 6 missing emails | 2 |
| **Conflicts** with decisions already made | 5 | 3 |
| **New scope** not in the backlog | 9 items | 4 |
| Items in "Decide these first" that are **already decided** | 3 of 6 | 5 |
| **Timing** concerns | 3 | 6 |

Each finding has an ID (**R-xx**) so it can be tracked as an issue.

---

## 2. Missing screens and states

| ID | What's missing | Source | Suggested fix | Priority |
|---|---|---|---|---|
| R-01 | **Specialty pages** (`/directory/{category}/{city}/{specialty}`), including the version hidden from search engines when there are fewer than 3 listings | Backlog 6.6, 6.7; MVP section 7 | New public screen, or a variant of S07 | Must |
| R-02 | **Admin SEO settings:** page title and description templates for each page type, plus overrides for individual pages | 6.3 (Must), 6.9 (Should) | New admin screen | Must |
| R-03 | **Admin view of an account's billing:** subscription lines, invoices, payment status, and **refunds** | 8.4 | Add to the S33 member detail page, or a new screen | Should |
| R-04 | **Admin audit log:** who did what, when, and to which record | 14.4 | New admin screen | Should |
| R-05 | **Admin overrides of limits** for one account or listing (reason and expiry date) | SPEC-BILL-01 BR-PE-14 (proposed story 7.14) | Add to the S33 member detail page | Should |
| R-06 | **Pause and reactivate a listing** | 3.5 | Add to S12 and to the listing rows in S04 | Must |
| R-07 | **Content hidden after a downgrade:** photos and specialties over the new limit marked "hidden", and the 7-day notice before a downgrade | SPEC-BILL-01 BR-PE-23, BR-PE-24 (proposed story 7.15) | Add states to S12 and S19 | Must |
| R-08 | **Search suggestions as you type** | 5.2 | Add to S05 and S13 | Should |
| R-09 | **Account suspended, or login refused** (only active accounts can log in) | 2.3; identity design 5.2, 5.9 | A Keycloak or app page with contact details | Must |
| R-10 | **Keycloak account pages:** change password, authenticator devices, active sessions, change email | Identity design 5.7, 5.8, 10 | S25 links to them, but they aren't designed. Theme them with Keycloakify, or **decide** to use Keycloak's default look. | Must (decision) |
| R-11 | **Bulk actions on members** | 14.6 | Add to S33. S40 only mentions bulk actions for approvals, as "later". | Should |

### 2.1 Emails missing from S34 and S09

| ID | Email | Source |
|---|---|---|
| R-12 | Downgrade notice, 7 days before it takes effect, listing what will be hidden | SPEC-BILL-01 BR-PE-24 |
| R-13 | Lapsed account: grace period ended and listings hidden | 7.7 |
| R-14 | New-message alert to the business owner | 16.3 |
| R-15 | Copy of their message sent to the visitor | 16.1 |
| R-16 | Relayed replies (business to visitor and back) | 16.4 |
| R-17 | "We've launched in your state" | T10 (pending) |

### 2.2 Waiting on open to-dos

| ID | Item | To-do |
|---|---|---|
| R-18 | Interstitial page for re-accepting changed terms | T2 |
| R-19 | Admin view of **demand by state**. S48 covers only the visitor's side. | T10 |
| R-20 | Unsubscribe or email preferences page, needed if any non-transactional email is sent (for example R-17) | T1, T10 |

---

## 3. Conflicts with decisions already made

| ID | Screen | Conflict | Decided in | Suggested fix |
|---|---|---|---|---|
| R-21 | **S38 Taxonomy** ("No third level"), and S12's "keywords" tab | **Specialties are the third level** of categories. They're used in stories 4.6 and 4.7, the specialty filter (5.5), specialty pages (6.6), and the limit `listing.specialties.max` (SPEC-BILL-01, section 4.2). | MVP decision D2; backlog E4 | Add specialties to S38. Rename S12's "keywords" tab to "Specialties", or define keywords as something separate. If the team wants to remove specialties, raise it as a change request, because it affects SEO, search, and tier limits. |
| R-22 | **S16 Write a review** (sliders from 1 to 100 per topic; up to 6 photos) | Reviews are rated **1–5** (9.1), averaged (9.3), and published as AggregateRating. Review photos aren't planned: they'd need storage, moderation, and limits. | Backlog 9.1, 9.3, 6.8b | Keep 1–5 for the MVP, or raise a change request for topic sliders and photos (new backlog stories plus moderation in S41) |
| R-23 | **S11 Checkout handoff** (PayPal option) | Payments are **Stripe only** | ADR-0009 | Remove PayPal, or raise it as a post-MVP item |
| R-24 | **S35** title "Plans and discounts" | Silver, Gold, and Platinum are **listing tiers**, never plans. There are no account plans. | Decision D12; ADR-0017; HANDOFF rule 8 | Rename to "**Listing tiers, pricing, and discounts**" |
| R-25 | **S15 Contact reveal**, and S07's "Show contact info" | The listing's structured data for search engines (6.8a, LocalBusiness) includes the **phone number**. Hiding the phone behind a button contradicts publishing it in the page's data. The team's open question 5 is the same issue. | Backlog 6.8a | **Decide** whether the phone is public (search value) or gated (lead tracking). If gated, update 6.8a and accept the SEO trade-off. |

---

## 4. New scope not in the backlog

None of these are in the MVP definition or the backlog. Each needs a **product decision**, and if kept, **new backlog stories**, any new **tier limits** (added to SPEC-BILL-01), and new **APIs**. Together they would add to the 24-week timeline.

| ID | Screen | New scope | What it would need |
|---|---|---|---|
| R-26 | S06 | US map with listing counts per state; rows for Featured, Top searched, Top rated, and Random; "Upgrade to appear here" | A listings-per-state API, ranking rules, and possibly a "featured" limit by tier |
| R-27 | S06, S39 | "Tell us what we're missing" form and **category requests** | A new backend feature and admin workflow |
| R-28 | S15, S07 | **Contact reveal** step, with its own tracking event | A new API and event, and a decision on R-25 |
| R-29 | S12 | **Video**, **certification**, and **coupon** tabs; a "one main category plus one sub-category" rule | New listing fields, tier limits, and moderation rules |
| R-30 | S28, S44 | **Banner advertising** for businesses and admins | A new advertising module: booking, rotation, pricing, billing |
| R-31 | S43 | **Coupons, affiliate links, and surveys** for businesses | New backend features and tier limits |
| R-32 | S29 | **FAQ page** | Content only. Could reuse the static page template (S30 and S42). |
| R-33 | S16 | Topic sliders and review photos (see R-22) | Changes to stories 9.1, 9.3, and 6.8b, plus moderation |
| R-34 | S32 | "At most 2 jobs per secret shopper"; a business doing an evaluation uses its company name | Answers to Q10 and Q18, then added to SPEC-REV-01 |

**Suggested approach:** mark these screens "**Pending decision: new scope**" and leave them out of build steps until the product owner decides. Design work can go ahead for any the product owner wants to see before deciding.

---

## 5. "Decide these first": status

| # | Question | Status |
|---|---|---|
| 1 | Level names: L1/L2/L3 or Silver/Gold/Platinum? | **Decided: Silver, Gold, Platinum** (ADR-0017). Plain-language "level" is fine in UI text, but the names are fixed. |
| 2 | Extra listings priced at their level, or $1 add-ons? | **Decided:** every listing is charged its own tier price, **including the default Silver listing**. The $1 service fee is charged **once per account** and never discounted (SPEC-BILL-01, BR-PE-03 and BR-PE-04; ADR-0017). S19's note "depends on the price decision" can be removed. |
| 3 | What each level includes | **Open: OQ-2.** Proposed values are in SPEC-BILL-01, section 4.2. |
| 4 | Do category counts on the landing page include Silver listings? | **New question.** It belongs with R-26. |
| 5 | Can phone numbers appear in the page source and search data? | **New question.** See R-25. |
| 6 | Team and editor screens removed | **Confirmed:** each business account has one user, its owner (decision D20; SPEC-BILL-01 BR-PE-39) |

---

## 6. Timing

The screen list uses "weeks" for design and "steps" for build, but neither is tied to the **sprint plan** (Product Backlog v1.5, section 3). Some screens may be built after the sprint whose stories depend on them:

| ID | Screen | Backlog sprint | Screen list | Risk |
|---|---|---|---|---|
| R-35 | S40 Listing approvals | **3.6 is a Must in Sprint 3** | Build step 5 | Listings can't be published without approvals. Bring forward, or use a temporary admin workaround in staging. |
| R-36 | S37 Locations, S38 Taxonomy | Stories 1.1, 1.2, 4.1, and 4.6 are in **Sprints 1–2** | Build steps 5 and 6 | Acceptable **if** seed data (story 1.5 and Flyway data migrations) covers Arizona, its cities, and the taxonomy until then. State this explicitly in the plan. |
| R-37 | S16, S23, S32 | Reviews and secret shopper are in **Sprint 8**; messaging is in **Sprint 7** | Build steps 2–4 | Fine for design. Building this early means working against mock data for many sprints, and the real API may change. Consider scheduling the build closer to the backend sprints. |

**Recommendation:** add a "**Target sprint**" column to `ui-work-plan.md`, matched to the backlog's sprint plan, so ordering can be checked at a glance.

---

## 7. What's working well
- Every screen states **who it's for**, the **design states**, and **build notes**, and links to backlog stories and issues.
- The **Definition of Done** for design and build matches the architecture: three breakpoints, WCAG AA, 95% coverage, mock data until the API is ready, deployed to staging.
- It correctly places **login, registration, reset, and OTP pages in Keycloak** (S01, S02, S09, S10, S17), and **sends payment to Stripe** without card fields in our app (S11).
- **Owner-only actions**, **one user per business** (S04), and **reviews locked until a secret shopper review** (S08, S24) all match the decisions.
- The **open rules are flagged** rather than guessed (tax, billing interval, update limits, profile switcher).

---

## 8. Proposed next steps

| Step | Owner | When |
|---|---|---|
| 1. Add R-01 to R-11 as screens S49 onward, or as states on existing screens, and add the emails R-12 to R-17 to S34 and S09 | Web team | Before the design for week 2 |
| 2. Fix the conflicts R-21 to R-25: correct the screens, or raise change requests | Web team and product owner | This week |
| 3. Mark R-26 to R-34 "Pending decision: new scope". The product owner decides which to keep and adds backlog stories for them. | Product owner | Before Sprint 2 refinement |
| 4. Update "Decide these first" with section 5 | Web team | This week |
| 5. Add a "Target sprint" column to `ui-work-plan.md` and resolve R-35 to R-37 | Web team with both tech leads | Before Sprint 1 planning |
| 6. Answer OQ-2 (tier limits), so S12, S19, and S21 can be finished | Product owner | Before Sprint 1 refinement ends |

---

## 9. Addendum: product owner answers (2026-10-06)

The answers to Q1–Q15 (see `directory-app-infra/docs/product/answers-log.md`) settle or change several findings:

| Finding or screen | Update |
|---|---|
| **"Decide these first" #4** (do category counts include Silver?) and **R-26** | **Answered (Q2):** Silver listings **aren't shown on the directory landing page** (new tier key `listing.landing_page`), but they do appear on the map. The landing page's featured rows (S06) are for Gold and Platinum. The rest of R-26 (the US map, and rows for top searched, top rated, and random) is still new scope. |
| **R-27, S39** (category requests) | **Approved (Q4):** visitors say what they couldn't find and are emailed when it's added. **New backlog story 4.8** (Should, Sprint 10). No live chat. |
| **S12** (photos), **S19**, **S21** | **Photo limits: Silver 1, Gold 3, Platinum 6.** Update the "Limit reached" examples (for example, "3 of 3 photos"). |
| **S12, S14** (online-only, map) | **Confirmed (Q2):** online-only listings, and owners who opt out in their address options, aren't shown on the map. |
| **S12** (service area tab) | **A list of cities only** (Q5). No radius or polygon tools. |
| **R-21, S38** (specialties) | **Still open:** the product owner asked whether specialties mean categories. Follow-up F-1 explains them with an example. Keep R-21 open. |
| **R-23, S11** (PayPal) | The product owner has a PayPal account, and **whether to offer PayPal is now an open question** (F-4). Keep PayPal marked "Pending decision". |
| **R-34, S32** (secret shopper) | **Confirmed (Q10, Q11):** at most 2 listings per shopper, the **rebate is offered by the listing**, and a business buys in the company's name. **New:** shoppers may **choose** listings by their offers (follow-up F-3). S32 may need a "choose from offers" step. S12 may need a "secret-shopper offer" field for owners. |
| **S36** (tax rules) | **Tax is needed at launch:** Phoenix (and some other cities) charge city tax on subscriptions. Story 7.13 is a Must in Sprint 5. The design should support city-level rules and tracking of other states' thresholds. |
| **S03** (onboarding, location step) | Launch cities are confirmed: **11 cities** (Flagstaff dropped, Goodyear and Surprise added) |
| **S11, S20** (yearly fee) | **Decided (Q1):** the $1 service fee is billed **annually ($12) while the account's listings or shopper price are discounted to $0**. Replace the "not decided" note with this rule. |

---

## 10. Addendum: in-app notification center (2026-10-06)

| ID | What's needed | Source | Suggested fix | Priority |
|---|---|---|---|---|
| R-38 | **A notification bell and panel** for signed-in members and staff: unread count, a list of recent notifications that link to the relevant page, mark one or all as read, and empty and error states. Shown in the header of every signed-in page (F-02). | New backlog story **2.23** (Must, Sprint 9); ADR-0020; Frontend Architecture section 5.5 | Add as **S49** (or as part of F-02, the header). Design it with the header so the space is reserved. | Must |
| R-39 | **Checkout confirmation waiting state**: "We're confirming your payment…" while the page polls for up to 30 seconds, then a fallback message with a refresh button | Frontend Architecture section 5.5 | Add as a state on S11 (the return pages) | Must |

---

## 11. Addendum: survey insights screens (2026-10-06)

The survey app is a separate application. Its results are shown in BlackPages (ADR-0022, SPEC-SRV-01). That adds four screens that aren't in the screen list:

| ID | Screen | Who | Key states | Backlog |
|---|---|---|---|---|
| R-40 / **S50** | Survey insights for businesses: survey list, charts by question type (scale distribution, multiple choice, yes/no), and tabs for city, respondent type, and category, with trends and CSV export depending on tier | Business owner | Locked tabs ("Available for Gold"), **"Not enough responses yet"** (fewer than 5 respondents), no surveys, error | 18.10 (Must, Sprint 11) |
| R-41 / **S51** | Survey insights for shoppers: surveys they answered, with "your answer compared with the community" | Shopper | Not enough responses, no surveys | 18.11 (Must, Sprint 11) |
| R-42 / **S52** | Public survey highlights, per state, on directory pages and at `/insights/{locationSlug}` | Public | Not enough responses, totals only, no free text | 18.12 (Must, Sprint 11) |
| R-43 / **S53** | Survey analytics for admins: response rates, all groups (small ones marked), free text, choosing public questions, sync health, and the MariaDB parallel-run comparison | Admin, site operator | Location scope, sync errors | 18.13 (Should, Sprint 11) |

**Design notes**
- **Every chart needs a text alternative** (a data table or summary) for WCAG 2.1 AA.
- **Show the question wording as it was sent**, even if the question has since changed.
- **Survey consent** is a new checkbox at onboarding (S03) and a new setting in account settings (S25) (story 18.2, OQ-S4).
- **S43's "survey builder and results"** (surveys businesses create themselves) stays out of scope. Survey creation stays in the survey app's own admin UI.
