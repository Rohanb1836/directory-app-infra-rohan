# ADR-0022: Integrating the survey app: survey insights are built in BlackPages and pulled through an API

- **Status:** Accepted
- **Date:** 2026-10-06
- **Related:** ADR-0001 (modular monolith), ADR-0005 (Keycloak), ADR-0006 (sessions), ADR-0007 (authorization), ADR-0008 (location scoping), ADR-0015 (email), ADR-0021 (analytics), SPEC-SRV-01, backlog epic E18

## Context

A **separate survey app** (`survey-app-svc`: Spring Boot 4.0.1, Java 25, PostgreSQL `survey_app_db`) lets admins create questions, build surveys, and schedule them. It emails each survey to business ("company") and shopper ("individual") members, and collects the responses.

- Its **Site** is the same as a BlackPages **location** (a US state).
- Today it **pulls users from**, and **pushes responses to**, the Brilliant Directories MariaDB database (`launc36238_directory`). **That arrangement is being switched off.**

BlackPages needs **charts of survey responses**:
- for **businesses** and **shoppers**, varying by tier and account type;
- **some public**, as the MVP brief requires;
- for admins.

## Decision

1. **The survey app remains the owner of surveys, questions, and responses.** It keeps creating, scheduling, and emailing surveys, and collecting answers.
2. **The charts are built in BlackPages:** the screens in `directory-app-ui`, and the data and access rules in a new backend module, **`survey-insights`**, in `directory-app-svc`. BlackPages is where members sign in, where tier entitlements are decided, and where public pages are served. It also has the information the charts need: location, city, category, and tier.
3. **The two apps integrate through versioned, read-only APIs, never by reading each other's database:**
   - **BlackPages pulls new responses** from the survey app's integration API every hour, using a cursor, and keeps its own **summary tables** for the charts. Charts never call the survey app while a page loads.
   - **The survey app pulls locations and recipients** from BlackPages' integration API. This replaces the MariaDB user sync.
   - **When an account is deleted**, BlackPages tells the survey app, through the outbox, to anonymize that person's responses.
4. **Each survey app Site is one BlackPages location.** BlackPages is the source of truth for the list of locations, and their names, statuses, and time zones. The survey app adds `location_id` and `time_zone` to `Site` and removes `database_url`. Each recipient belongs to the site of their **home location**.
5. **The two services authenticate with each other through Keycloak, using client credentials.** Endpoints under `/api/integration/**` in both apps accept **only Keycloak-issued bearer tokens** with the right scope. BlackPages adds a second, bearer-token **security filter chain** for these endpoints (anticipated in ADR-0006). Sessions, cookies, and CSRF don't apply to them.
6. **Privacy is enforced in the summary tables:**
   - groups of **fewer than 5 respondents** are never shown;
   - **free-text answers are never public**, and are shown to businesses only if a decision allows it;
   - respondents are **never identified**;
   - the stored responses are **pseudonymous**: linked to account IDs, never names or emails.
7. **The MariaDB sync is retired** once Brilliant Directories is switched off. Until then it runs **in parallel**, and the two outputs are compared.

## Consequences

**Positive**
- Each app owns its own data and can change its database without breaking the other. Only the versioned API contracts matter.
- Charts are fast and keep working if the survey app is down. Surveys arrive monthly or quarterly, so an hour's delay is irrelevant.
- One place decides who sees what, using the same entitlement engine as listings (SPEC-BILL-01).
- The two apps authenticate with each other properly, and no database credentials are shared.

**Negative and risks**
- There's a second copy of the response data, in pseudonymous form. Retention and deletion must stay aligned (SPEC-SRV-01, section 8).
- Work is needed in **both** apps: about 38 points in BlackPages and 29 in the survey app (backlog epic E18).
- The survey app's **85-emails-a-day limit** (the Mailgun free tier) would make a survey to 2,000 members take about 24 days. Fixing it is part of E18 (story 18.15).
- The survey app's IDs are numbers, and BlackPages' are UUIDs. `directory_user_id` changes type.

## Alternatives considered

| Option | Reason rejected |
|---|---|
| BlackPages reads `survey_app_db` directly (or a read replica) | Ties BlackPages to the survey app's database structure, shares database credentials, and bypasses its rules. It's the MariaDB arrangement in reverse. |
| BlackPages calls the survey API every time a chart loads | Slow, fails whenever the survey app is down, and would push tier, city, category, and privacy rules into the survey app |
| Build the charts in the survey app's own frontend | Members would need a second login and site. Tiers and BlackPages' data (cities, categories, listings) aren't available there. |
| The survey app pushes every response to BlackPages through webhooks | Needs retry and ordering handling on both sides. Pulling with a cursor is simpler, and never misses or repeats a response. A webhook can be added later, just to trigger an immediate pull. |
