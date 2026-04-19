<!--
  Sync Impact Report
  Version change: 1.1.0 → 1.2.0
  Modified principles: None
  Added sections: "Production Deployment" under Additional Constraints (vendor-neutral);
                  vendor specifics moved to docs/architecture-decisions/ADR-001
  Removed sections: None
  Templates requiring updates:
    ✅ .specify/memory/constitution.md (this file)
    ✅ .specify/templates/plan-template.md (Target Platform / Constraints fields already accommodate this; no structural change needed)
    ✅ .specify/templates/spec-template.md (no structural change needed)
    ✅ .specify/templates/tasks-template.md (no structural change needed)
  Follow-up TODOs: None
-->

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

### Production Deployment
The application MUST be containerized in production; the database MUST run outside the
container on the host.

- The container image MUST be built from source on the production host; pre-built registry
  images are not assumed.
- The database MUST NOT be containerized in production.
- The database MUST only accept connections from localhost; it MUST NOT be accessible
  from other machines on the network.
- Database connection details MUST be injected via environment variables; no hard-coded
  host, port, or credentials are permitted in the image.
- Database migrations MUST run as a distinct step before the application container starts.
- The production container image MUST be minimal: no development dependencies, no test files.
- Health/readiness endpoints (see Principle IV) MUST be reachable from the container host.
- Secrets MUST be injected via environment variables or a secrets manager; they MUST NOT
  be baked into the image.

See [ADR-001: Production Deployment Stack](../../docs/architecture-decisions/ADR-001-production-deployment-stack.md)
for the rationale behind specific technology choices.

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

**Version**: 1.2.1 | **Ratified**: 2026-04-18 | **Last Amended**: 2026-04-19
