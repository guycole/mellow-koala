<!--
Sync Impact Report:
─────────────────────────────────────────────────────────────────────────────
Version: 1.2.1 → 2.0.0 → 2.0.1 → 2.0.2 → 2.0.3 → 2.0.4 (Docker Deployment)
Date: 2026-04-22

CHANGES IN 2.0.4 (PATCH):
- ✅ Added Docker containerization to deployment model
- ✅ Updated Deployment Environment: Docker in production
- ✅ Added Docker image requirements for ARM64 architecture
- ✅ Updated Offline Installation: Docker image export/load procedures
- ✅ Updated Testing Gates: Docker image testing on ARM64
- ✅ Updated Deployment section: Docker-specific requirements

CHANGES IN 2.0.3 (PATCH):
- ✅ Added monitoring infrastructure: Prometheus & Elasticsearch
- ✅ Updated Technology Stack with Monitoring & Observability section
- ✅ Added structured logging guidance for Elasticsearch
- ✅ Added metrics exposure guidance for Prometheus
- ✅ Updated Resource Management to reference Prometheus monitoring

CHANGES IN 2.0.2 (PATCH):
- ✅ Clarified ARM architecture: 64-bit ARM (ARM64) only, not 32-bit
- ✅ Clarified resource profile: generous resources, not constrained
- ✅ Updated Principle V: Performance & Scalability (removed "Constraints")
- ✅ Softened resource management requirements (SHOULD vs MUST)
- ✅ All references updated: ARM → ARM64 throughout document

CHANGES IN 2.0.1 (PATCH):
- ✅ Corrected database from MySQL to PostgreSQL (technical accuracy fix)

CHANGES IN 2.0.0 (MAJOR):
- ✅ Specialized constitution for embedded monitoring application
- ✅ Added embedded/edge computing context and constraints
- ✅ New principle: VI. Offline-First & Air-Gap Ready
- ✅ Enhanced Performance principle for ARM resource constraints
- ✅ Updated Technology Stack for ARM Linux and limited packages
- ✅ Added Embedded Deployment Constraints section
- ✅ Clarified purpose: monitoring embedded applications
- ✅ Replaced generic web app principles with Mellow Koala specifics

PRINCIPLES MODIFIED:
- V. Performance & Resource Constraints → Performance & Scalability
  (clarified: generous resources, not constrained)
- All principles customized for embedded ARM64 monitoring context
- Security principle adapted for air-gapped environments

PRINCIPLES ADDED:
- VI. Offline-First & Air-Gap Ready (NEW - critical for embedded)

SECTIONS MODIFIED:
- Deployment Environment → Docker containerization in production
- Technology Stack → Added Monitoring & Observability (Prometheus, Elasticsearch)
- Technology Stack → ARM64 Linux, offline-capable, no cloud, PostgreSQL
- Offline Installation → Docker image export/load procedures
- Testing Gates → Docker image testing requirements
- Deployment → Docker-specific deployment requirements
- Added "Embedded Deployment Constraints" section
- Development Workflow → Added ARM64-specific considerations
- Purpose statement → Clarified 64-bit ARM with generous resources

VERSION BUMP RATIONALE:
- PATCH (2.0.3 → 2.0.4): Added Docker deployment model to deployment context
- PATCH (2.0.2 → 2.0.3): Added available monitoring infrastructure details
- PATCH (2.0.1 → 2.0.2): Architecture and resource profile clarification
- PATCH (2.0.0 → 2.0.1): Database technology correction (MySQL → PostgreSQL)
- MAJOR (1.2.1 → 2.0.0): Fundamental shift from generic web app to 
  embedded systems monitoring. Backward-incompatible change that redefines
  the project scope and deployment model.

TEMPLATES STATUS:
- ✅ .specify/templates/plan-template.md (reviewed - compatible)
- ✅ .specify/templates/spec-template.md (reviewed - compatible)
- ✅ .specify/templates/tasks-template.md (reviewed - compatible)

PREVIOUS VERSIONS:
- 2.0.3 (2026-04-22): Monitoring infrastructure (Prometheus, Elasticsearch)
- 2.0.2 (2026-04-22): ARM64 & resource clarification
- 2.0.1 (2026-04-22): Database correction (MySQL → PostgreSQL)
- 2.0.0 (2026-04-22): Embedded systems specialization
- 1.2.1 (2026-04-19): Generic web application constitution
- 1.0.0 (2026-04-17): Initial constitution
─────────────────────────────────────────────────────────────────────────────
-->

# Mellow Koala Constitution

**Purpose**: Monitoring and displaying data from embedded applications running
on 64-bit ARM Linux hosts with generous resources, potentially in air-gapped or
internet-isolated environments.

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

### V. Performance & Scalability

Database queries MUST be optimized to avoid N+1 problems (use eager loading).
Long-running import jobs MUST use background processing (e.g., Sidekiq, solid
queue). Response times for user-facing pages SHOULD be under 200ms. Import
utilities MUST handle batch processing for large datasets.

**Embedded Deployment Context**: The application runs on 64-bit ARM Linux hosts
with generous resources. While resource-efficient code is preferred, the system
has adequate memory and CPU capacity for typical Rails applications. Database
size growth MUST still be manageable through data retention policies where
appropriate. The application MUST operate efficiently on ARM64 architecture with
limited package availability.

**Rationale**: As a data aggregation system for embedded monitoring, query
performance and import efficiency directly impact user experience and system
reliability, even with generous hardware resources.

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
- PostgreSQL database
- Tailwind CSS for styling
- ARM64 Linux hosts (64-bit ARM embedded systems)

**Monitoring & Observability**:
- Prometheus (metrics collection and alerting)
- Elasticsearch (log aggregation and search)

**Deployment Environment**:
- Docker containerization in production
- ARM64 architecture (64-bit ARM only)
- Generous hardware resources (adequate memory and CPU)
- Limited package availability compared to x86_64 Linux
- Potentially air-gapped (no external internet access)
- No cloud services or external dependencies

**Requirements**:
- Ruby version MUST be specified in `.ruby-version` and Gemfile
- Application MUST be containerized using Docker for production deployment
- Docker images MUST be buildable for ARM64 architecture
- All gems MUST be vendored or bundleable for offline installation
- Database migrations MUST be reversible where possible
- Asset pipeline MUST be configured for production optimization
- Background job processing MUST be configured for imports
- ARM64 compatibility MUST be verified for all dependencies

**Constraints**:
- Import utilities MUST be implemented as Rails commands or Rake tasks
- Database connection pooling MUST be configured appropriately for
  concurrent imports and resource limits
- Logs MUST include timestamps and severity levels
- Logs SHOULD be structured for Elasticsearch ingestion
- Application metrics SHOULD be exposed for Prometheus collection
- External HTTP calls MUST NOT be required for core functionality
- Memory footprint MUST be appropriate for embedded systems
- No CDN or external asset dependencies in production

## Embedded Deployment Constraints

**Package Management**:
- Gem dependencies MUST be compatible with ARM64 architecture
- Native extensions MUST compile on ARM64 Linux or have ARM64-compatible
  prebuilt binaries
- Dependency updates MUST be testable in ARM64 environment before production
- Document any gems that require special compilation flags for ARM64

**Offline Installation**:
- Docker images MUST be exportable and loadable for air-gapped deployment
- Docker images MUST be built for ARM64 architecture
- Bundle MUST support `bundle package --all` for offline installation
- Asset precompilation MUST work without internet access
- Database setup scripts MUST not require external downloads
- Documentation MUST include offline Docker image transfer procedures
- Documentation MUST include offline installation procedures

**Resource Management**:
- Database size SHOULD be monitored with cleanup/archival policies where
  appropriate
- Log rotation MUST be configured to prevent disk space exhaustion
- Background job queues SHOULD have timeout configurations for long-running
  tasks
- System resources (CPU, memory, disk) SHOULD be monitored via Prometheus
- Application health metrics SHOULD be exposed for monitoring

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
- ARM64 compatibility MUST be verified for new dependencies

**Testing Gates**:
- All tests MUST pass before merging
- New features MUST include appropriate test coverage
- Import utilities MUST be tested with sample data before production use
- Docker images MUST be tested on ARM64 before production rollout
- ARM64 deployment MUST be tested before production rollout

**Deployment**:
- Production deployment uses Docker containers
- Docker images MUST be built for ARM64 architecture
- Database migrations MUST be tested on staging before production
- Deployment MUST follow zero-downtime principles where possible
- Rollback procedures MUST be documented and tested
- Docker images MUST be self-contained for air-gapped installation
- ARM64-specific deployment considerations MUST be documented

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
- ARM64 compatibility MUST be verified for dependency changes

**Complexity Justification**:
- Deviations from Rails conventions MUST be documented in implementation plans
- Performance optimizations that sacrifice simplicity MUST be justified with
  metrics
- Third-party dependencies MUST be justified and ARM64-compatibility verified
- Cloud or internet-dependent features MUST be justified as non-core optional
  enhancements only

**Version**: 2.0.4 | **Ratified**: 2026-04-17 | **Last Amended**: 2026-04-22
