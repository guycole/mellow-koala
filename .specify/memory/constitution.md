# Web Application Constitution

## Core Principles

### I. Deliver Small, Testable Slices
Build features as small, independently testable slices of user value.
- Each change should be shippable and verifiable on its own
- Prefer simple designs; add complexity only when justified by requirements

### II. Security by Default
Assume all inputs are hostile and all actions need authorization.
- Validate and sanitize all inputs (including JSON payloads)
- Enforce authentication and authorization on protected resources
- Never log secrets; treat PII as sensitive

### III. Reliability over Cleverness
Prefer predictable behavior and clear failure modes.
- Fail fast with actionable errors
- Handle partial failures gracefully (timeouts, retries where appropriate)
- Keep dependencies explicit and minimal

### IV. Observability is a Feature
If we can’t understand it in production, it’s not done.
- Structured logs for requests and background work
- Correlate actions with request IDs / trace IDs
- Health/readiness endpoints for deployment and monitoring

### V. Maintainability First
Optimize for the next engineer.
- Use clear naming and consistent patterns
- Keep modules/components cohesive with defined boundaries
- Documentation for public interfaces and non-obvious decisions

## Additional Constraints

### Data & Privacy
- Collect and store only necessary data
- Define retention and deletion behavior for user data
- Use least-privilege access to data stores

### Performance
- Prevent obvious N+1 patterns and unbounded queries
- Paginate list views by default
- Set reasonable request and payload size limits

## Development Workflow

### Quality Gates (required before merge)
- Automated tests pass (unit + integration/system where applicable)
- Linting/static checks pass (if present in repo)
- Security checks pass (if present in repo)
- New behavior is covered by tests, or explicitly justified

### Review Expectations
- At least one reviewer approval for non-trivial changes
- Changes affecting interfaces include upgrade/migration notes

## Governance

- This constitution overrides local preferences and ad-hoc practices.
- Amendments require:
  1) a short rationale,
  2) impact assessment,
  3) migration plan (if behavior changes),
  4) version bump.

**Version**: 1.0.0 | **Ratified**: 2026-04-18 | **Last Amended**: 2026-04-18
