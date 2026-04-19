# ADR-001: Production Deployment Stack

**Status**: Accepted  
**Date**: 2026-04-19

## Context

The application needs a defined production deployment stack. The constitution mandates
container-based deployment with an external database, but leaves technology choices to
this document.

## Decision

| Concern | Choice | Version |
|---------|--------|---------|
| Production host OS | Ubuntu LTS | 22.04.4 |
| Container runtime | Docker | latest stable |
| Container image build | Built from source on the production host | — |
| Database | PostgreSQL | 14 |
| Database hosting | Bare-metal / VM on the production host (not containerized) | — |
| Database connection | `DATABASE_URL` environment variable | — |
| Secrets management | Environment variables (upgrade to a secrets manager when scale warrants) | — |
| Migration trigger | `rake db:migrate` run before the app container starts | — |

## Rationale

- **Docker** is the dominant container runtime with broad tooling support and well-understood
  operational characteristics for small-to-medium Rails applications.
- **Build from source on the host** avoids maintaining a private registry for a single-host
  deployment and keeps the build/deploy pipeline simple.
- **PostgreSQL 14** is a proven, long-term-supported release with full Rails/ActiveRecord
  compatibility. Upgrade path to PG 15/16 is straightforward via standard migrations.
- **External database** keeps persistent data outside the container lifecycle, simplifies
  backups, and avoids volume-mount complexity on a single host.

## Consequences

- Deployments require Docker installed on the production host.
- The production host must run PostgreSQL 14 (or later) independently, bound to `localhost`
  only (`listen_addresses = 'localhost'` in `postgresql.conf`). Remote database access is
  not permitted.
- Upgrading the database version or switching container runtime requires updating this ADR,
  not the constitution.

## Alternatives Considered

- **Podman** instead of Docker — compatible, but Docker is more familiar to the current team.
- **Managed database (RDS/Cloud SQL)** — viable at larger scale; deferred until needed.
- **Docker Compose in production** — considered, but a single `docker run` with env vars
  is simpler for a single-host deployment.
