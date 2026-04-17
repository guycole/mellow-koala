<!--
Sync Impact Report:
─────────────────────────────────────────────────────────────────────────────
Version: TEMPLATE → 1.0.0 (Initial Constitution)
Date: 2026-04-17

CHANGES:
- ✅ Initial constitution created for Mellow Koala project
- ✅ All placeholders replaced with concrete values
- ✅ 5 core principles defined for Rails 8 web application
- ✅ Technology stack and governance rules established

PRINCIPLES ADDED:
1. I. Rails Convention Over Configuration
2. II. Data Integrity First
3. III. Security By Design
4. IV. Test Coverage
5. V. Performance & Scalability

SECTIONS ADDED:
- Technology Stack & Constraints
- Development Workflow

TEMPLATES STATUS:
- ✅ .specify/templates/plan-template.md (reviewed - compatible)
- ✅ .specify/templates/spec-template.md (reviewed - compatible)
- ✅ .specify/templates/tasks-template.md (reviewed - compatible)

FOLLOW-UP ACTIONS:
- None required - all placeholders filled
─────────────────────────────────────────────────────────────────────────────
-->

# Mellow Koala Constitution

## Core Principles

### I. Rails Convention Over Configuration

Follow Rails conventions and established patterns for maintainability and team
productivity. Deviations from Rails conventions MUST be documented with clear
justification. Prefer standard Rails patterns (ActiveRecord, RESTful routes,
standard directory structure) unless specific requirements demand otherwise.

**Rationale**: Rails conventions reduce cognitive load, improve onboarding,
and leverage battle-tested patterns from the Rails community.

### II. Data Integrity First

Data imported from other Mellow projects MUST maintain referential integrity
and consistency. All data imports MUST be idempotent and auditable. Database
constraints (foreign keys, unique constraints, NOT NULL) MUST be defined at
the database level, not just in application code.

**Rationale**: As a display system aggregating data from multiple sources,
data quality and consistency are critical to system trustworthiness.

### III. Security By Design

All user inputs MUST be validated and sanitized. Authentication and
authorization MUST be implemented for administrative functions. Database
credentials and secrets MUST never be committed to version control. SQL
injection prevention through parameterized queries is NON-NEGOTIABLE.

**Rationale**: Web applications are attack vectors; security must be built in
from the start, not added later.

### IV. Test Coverage

All import utilities MUST have integration tests verifying correct data
transformation and loading. Critical user journeys MUST have system/feature
tests. Test coverage for models and controllers SHOULD exceed 80%. Tests MUST
run successfully before deployment.

**Rationale**: Automated testing prevents regressions and provides confidence
when refactoring or adding features.

### V. Performance & Scalability

Database queries MUST be optimized to avoid N+1 problems (use eager loading).
Long-running import jobs MUST use background processing (e.g., Sidekiq, solid
queue). Response times for user-facing pages SHOULD be under 200ms. Import
utilities MUST handle batch processing for large datasets.

**Rationale**: As a data aggregation system, query performance and import
efficiency directly impact user experience and system viability.

## Technology Stack & Constraints

**Core Stack**:
- Ruby on Rails 8.x
- MySQL database
- Tailwind CSS for styling
- Linux server deployment

**Requirements**:
- Ruby version MUST be specified in `.ruby-version` and Gemfile
- Database migrations MUST be reversible where possible
- Asset pipeline MUST be configured for production optimization
- Background job processing MUST be configured for imports

**Constraints**:
- Import utilities MUST be implemented as Rails commands or Rake tasks
- Database connection pooling MUST be configured appropriately for
  concurrent imports
- Logs MUST include timestamps and severity levels

## Development Workflow

**Version Control**:
- Use feature branches following Spec Kit naming conventions
  (`###-feature-name`)
- Commit messages MUST be descriptive and reference related issues/features
- Never commit secrets, credentials, or database dumps

**Code Review**:
- All changes MUST be reviewed before merging to main branch
- Reviews MUST verify compliance with this constitution
- Database migrations MUST be reviewed for safety and reversibility

**Testing Gates**:
- All tests MUST pass before merging
- New features MUST include appropriate test coverage
- Import utilities MUST be tested with sample data before production use

**Deployment**:
- Database migrations MUST be tested on staging before production
- Deployment MUST follow zero-downtime principles where possible
- Rollback procedures MUST be documented and tested

## Governance

This constitution supersedes all other development practices and preferences.
Changes to core principles require documented justification and team consensus.

**Amendment Process**:
- Proposed amendments MUST include rationale and impact analysis
- Version number MUST be incremented following semantic versioning:
  - MAJOR: Backward-incompatible principle changes or removals
  - MINOR: New principles or substantial guidance additions
  - PATCH: Clarifications, wording improvements, non-semantic updates
- All dependent templates and documentation MUST be updated when principles
  change

**Compliance Review**:
- All feature specifications MUST reference relevant principles
- Implementation plans MUST include constitution compliance checks
- Code reviews MUST verify adherence to security and data integrity principles

**Complexity Justification**:
- Deviations from Rails conventions MUST be documented in implementation plans
- Performance optimizations that sacrifice simplicity MUST be justified with
  metrics
- Third-party dependencies MUST be justified and documented

**Version**: 1.0.0 | **Ratified**: 2026-04-17 | **Last Amended**: 2026-04-17
