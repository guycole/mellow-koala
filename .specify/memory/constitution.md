<!--
Sync Impact Report:

 2.0.0 (Embedded Systems Specialization)
Date: 2026-04-22

CHANGES:
-  Specialized constitution for embedded monitoring application
-  Added embedded/edge computing context and constraints
-  New principle: VI. Offline-First & Air-Gap Ready
-  Enhanced Performance principle for ARM resource constraints
-  Updated Technology Stack for ARM Linux and limited packages
-  Added Embedded Deployment Constraints section
-  Clarified purpose: monitoring embedded applications
-  Replaced generic web app principles with Mellow Koala specifics

PRINCIPLES MODIFIED:
- All principles customized for embedded ARM monitoring context
 Enhanced for embedded resource constraints
- Security principle adapted for air-gapped environments

PRINCIPLES ADDED:
- VI. Offline-First & Air-Gap Ready (NEW - critical for embedded)

SECTIONS MODIFIED:
 ARM Linux, offline-capable, no cloud
- Added "Embedded Deployment Constraints" section
 Added ARM-specific considerations

VERSION BUMP RATIONALE:
 2.0.0): Fundamental shift from generic web app to 
  embedded systems monitoring. This is a backward-incompatible change
  that redefines the project scope and deployment model.

TEMPLATES STATUS:
-  .specify/templates/plan-template.md (reviewed - compatible)
-  .specify/templates/spec-template.md (reviewed - compatible)
-  .specify/templates/tasks-template.md (reviewed - compatible)

PREVIOUS VERSIONS:
- 1.2.1 (2026-04-19): Generic web application constitution
- 1.0.0 (2026-04-17): Initial constitution

-->

# Mellow Koala Constitution

**Purpose**: Monitoring and displaying data from embedded applications running
on ARM Linux hosts, potentially in air-gapped or internet-isolated
environments.

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

**Rationale**: As a display system aggregating data from multiple embedded
sources, data quality and consistency are critical to system trustworthiness.

### III. Security By Design

All user inputs MUST be validated and sanitized. Authentication and
authorization MUST be implemented for administrative functions. Database
credentials and secrets MUST never be committed to version control. SQL
injection prevention through parameterized queries is NON-NEGOTIABLE.

**Air-Gapped Context**: External authentication providers MUST NOT be required.
Security measures MUST function in isolated networks without internet access.

**Rationale**: Embedded monitoring systems require security without cloud
dependencies. Air-gapped deployments cannot rely on external services.

### IV. Test Coverage

All import utilities MUST have integration tests verifying correct data
transformation and loading. Critical user journeys MUST have system/feature
tests. Test coverage for models and controllers SHOULD exceed 80%. Tests MUST
run successfully before deployment.

**Rationale**: Automated testing prevents regressions and provides confidence
when refactoring or adding features.

### V. Performance & Resource Constraints

Database queries MUST be optimized to avoid N+1 problems (use eager loading).
Long-running import jobs MUST use background processing (e.g., Sidekiq, solid
queue). Response times for user-facing pages SHOULD be under 200ms. Import
utilities MUST handle batch processing for large datasets.

**Embedded System Constraints**: The application runs on ARM Linux hosts with
limited resources. Memory usage MUST be monitored and bounded. Background jobs
MUST respect system resource limits. Database size growth MUST be manageable
through data retention policies. The application MUST operate efficiently on
ARM architecture with limited package availability.

**Rationale**: As a data aggregation system for embedded monitoring, query
performance and resource efficiency directly impact system viability on
constrained hardware.

### VI. Offline-First & Air-Gap Ready

The application MUST function without external internet access. All
dependencies and packages MUST be bundleable for offline installation. No
cloud-based services or external APIs SHOULD be required for core
functionality. Configuration MUST support fully air-gapped deployment
scenarios. Updates and maintenance procedures MUST account for disconnected
environments.

**Rationale**: Embedded monitoring systems often operate in isolated or
air-gapped networks for security or physical isolation. Internet dependency
would make the system unusable in its primary deployment context.

## Technology Stack & Constraints

**Core Stack**:
- Ruby on Rails 8.x
- MySQL database
- Tailwind CSS for styling
- ARM Linux hosts (embedded systems)

**Deployment Environment**:
- ARM architecture (32-bit or 64-bit depending on hardware)
- Limited package availability compared to x86_64 Linux
- Potentially air-gapped (no external internet access)
- No cloud services or external dependencies

**Requirements**:
- Ruby version MUST be specified in `.ruby-version` and Gemfile
- All gems MUST be vendored or bundleable for offline installation
- Database migrations MUST be reversible where possible
- Asset pipeline MUST be configured for production optimization
- Background job processing MUST be configured for imports
- ARM compatibility MUST be verified for all dependencies

**Constraints**:
- Import utilities MUST be implemented as Rails commands or Rake tasks
- Database connection pooling MUST be configured appropriately for
  concurrent imports and resource limits
- Logs MUST include timestamps and severity levels
- External HTTP calls MUST NOT be required for core functionality
- Memory footprint MUST be appropriate for embedded systems
- No CDN or external asset dependencies in production

## Embedded Deployment Constraints

**Package Management**:
- Gem dependencies MUST be compatible with ARM architecture
- Native extensions MUST compile on ARM Linux or have ARM-compatible prebuilt
  binaries
- Dependency updates MUST be testable in ARM environment before production
- Document any gems that require special compilation flags for ARM

**Offline Installation**:
- Bundle MUST support `bundle package --all` for offline installation
- Asset precompilation MUST work without internet access
- Database setup scripts MUST not require external downloads
- Documentation MUST include offline installation procedures

**Resource Management**:
- Database size MUST be monitored with automatic cleanup/archival policies
- Log rotation MUST be configured to prevent disk space exhaustion
- Background job queues MUST have memory limits and timeout configurations
- Monitoring of system resources (CPU, memory, disk) SHOULD be included

**Data Collection**:
- Import utilities collect data from other embedded Mellow projects on the
  same network
- Communication protocols MUST be network-local (no internet routing required)
- Data sources MAY be unreachable temporarily; import utilities MUST handle
  graceful degradation

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
- ARM compatibility MUST be verified for new dependencies

**Testing Gates**:
- All tests MUST pass before merging
- New features MUST include appropriate test coverage
- Import utilities MUST be tested with sample data before production use
- ARM deployment MUST be tested before production rollout

**Deployment**:
- Database migrations MUST be tested on staging before production
- Deployment MUST follow zero-downtime principles where possible
- Rollback procedures MUST be documented and tested
- Deployment packages MUST be self-contained for air-gapped installation
- ARM-specific deployment considerations MUST be documented

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
- ARM compatibility MUST be verified for dependency changes

**Complexity Justification**:
- Deviations from Rails conventions MUST be documented in implementation plans
- Performance optimizations that sacrifice simplicity MUST be justified with
  metrics
- Third-party dependencies MUST be justified and ARM-compatibility verified
- Cloud or internet-dependent features MUST be justified as non-core optional
  enhancements only

**Version**: 2.0.0 | **Ratified**: 2026-04-17 | **Last Amended**: 2026-04-22
