# Web Application (Database-Backed) Constitution

## Core Principles

### I. Behavior-Driven Development (NON-NEGOTIABLE)
All features are defined and validated via behavior-first acceptance criteria.
- Define behavior as **executable acceptance scenarios** (Given/When/Then) before implementation.
- Each change MUST include at least one acceptance scenario that proves user-visible value.
- Prefer end-to-end/system tests for user journeys; use lower-level tests to cover edge cases.
- If behavior changes, update scenarios first, then implementation.

### II. Database Integrity is Part of the Product
Schema and data correctness are first-class.
- Schema changes MUST be applied via migrations.
- Migrations MUST be reversible where feasible and reviewed for safety.
- Enforce invariants at the database level where appropriate (uniqueness, non-null, foreign keys).
- Store only necessary data; define retention/deletion expectations when relevant.
- **All timestamps MUST be stored and exchanged in UTC ("Z time", i.e., ISO 8601 with `Z` suffix or `+00:00` offset).** Never store or transmit local/offset-naive times.

### III. Security by Default
Assume all inputs are hostile.
- Validate and sanitize all inbound data (web forms, JSON, headers, query params).
- Apply least-privilege to database access.
- Never log secrets; treat PII as sensitive.

### IV. Observability is Required
If it can’t be understood in production, it’s not done.
- Structured logs for requests and background work.
- Correlate actions with request IDs/trace IDs.
- Health/readiness endpoints for deployment/monitoring.

### V. Simplicity & Maintainability
Optimize for clarity over cleverness.
- Keep components cohesive with clear boundaries.
- Prefer boring, well-known patterns.
- Add complexity only when justified by a measurable requirement.

## Additional Constraints

### Performance & Reliability
- Paginate list views by default.
- Avoid unbounded queries and obvious N+1 patterns.
- Establish request/payload size limits for APIs.
- Define clear error behavior (status codes/messages) for failures.

### Compatibility
- Public interfaces (UI routes, APIs) must be versioned or changed with a migration path when breaking changes occur.

## Development Workflow & Quality Gates

### Definition of Done (per change)
- Acceptance scenarios updated/added (BDD).
- Automated test suite passes.
- Database changes include migrations + tests/coverage for constraints.
- Observability added/updated for new behavior (logs/metrics if available).
- Documentation updated when behavior or interfaces change.

### Review Expectations
- Behavior is reviewed at the scenario level (Given/When/Then reads like requirements).
- Review includes data model impact and migration safety.

## Governance

- This constitution overrides ad-hoc practices.
- Amendments require: rationale, impact assessment, migration plan, and version bump.

**Version**: 1.1.0 | **Ratified**: 2026-04-18 | **Last Amended**: 2026-04-18
