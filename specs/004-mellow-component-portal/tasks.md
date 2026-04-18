---

description: "Task list for implementing feature 004"
---

# Tasks: Mellow Component Portal

**Input**: Design documents in `specs/004-mellow-component-portal/` (spec.md, plan.md, research.md, data-model.md, contracts/)

**Organization**: Tasks are grouped by user story so each story can be implemented and verified independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1..US5
- Paths below match the structure in `plan.md` (Rails app at repository root).

---

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Create Rails 8 app skeleton with Tailwind + Postgres configuration (see `specs/004-mellow-component-portal/plan.md`)
- [ ] T002 [P] Add base folders/namespaces for controllers (`app/controllers/api`, `app/controllers/portal`) and services (`app/services/`)
- [ ] T003 [P] Add Docker + Docker Compose files per `specs/004-mellow-component-portal/quickstart.md`
- [ ] T004 [P] Add RSpec + Capybara baseline configuration for request + system specs (`spec/requests`, `spec/system`)

**Checkpoint**: App boots in Docker, DB connects, test suite runs.

---

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T005 Create database migrations + models for core entities:
  - `app/models/component.rb`
  - `app/models/configuration_snapshot.rb`
  - `app/models/collection_snapshot.rb`
  - migrations in `db/migrate/*` with constraints/indexes from `specs/004-mellow-component-portal/data-model.md`
- [ ] T006 Add idempotency constraints (unique `(component_id, snapshot_id)` for both snapshot tables)
- [ ] T007 Implement ingestion authentication mechanism (simple per-component bearer token):
  - store only token digests (no plaintext)
  - verify token for the component in the URL
  - return 401 (missing) / 403 (invalid or mismatched)
  - ensure secrets are never logged
- [ ] T008 Create shared API error handling + JSON response shape (`app/controllers/api/base_controller.rb`)
- [ ] T009 Add request size limit enforcement (Rack / Rails config and/or reverse-proxy guidance) and ensure `413` response path is covered
- [ ] T010 [P] Add structured logging fields for ingestion (`request_id`, `component_id`, `snapshot_type`, `snapshot_id`, `status`, `duration_ms`, `payload_bytes`) without logging secrets

**Checkpoint**: Data model + auth + error handling exist; user story work can begin.

---

## Phase 3: User Story 1 - CLI Upload of Component Configuration & Collection Info (Priority: P1) 🎯 MVP

**Goal**: Authenticated components can upload configuration + collection snapshots via JSON API with validation, idempotency, and clear errors.

**Independent Test**: Use curl (with `Authorization: Bearer ...`) to POST snapshots; verify persistence + visibility in portal.

### Tests for US1 (BDD-first)

- [ ] T011 [P] [US1] Request spec: valid authenticated upload returns 201 and persists snapshot (`spec/requests/api/configuration_snapshots_spec.rb`)
- [ ] T012 [P] [US1] Request spec: idempotent replay returns 200 and does not duplicate (`spec/requests/api/*_snapshots_spec.rb`)
- [ ] T013 [P] [US1] Request spec: missing auth returns 401 (`spec/requests/api/*_snapshots_spec.rb`)
- [ ] T014 [P] [US1] Request spec: invalid token or component mismatch returns 403 (`spec/requests/api/*_snapshots_spec.rb`)
- [ ] T015 [P] [US1] Request spec: invalid payload returns 400 with actionable validation errors

### Implementation for US1

- [ ] T016 [US1] Add routes for ingestion endpoints in `config/routes.rb`
- [ ] T017 [US1] Implement controllers:
  - `app/controllers/api/configuration_snapshots_controller.rb`
  - `app/controllers/api/collection_snapshots_controller.rb`
- [ ] T018 [US1] Implement ingestion service objects (`app/services/ingestion/*`) for:
  - auth check + component lookup
  - JSON validation
  - idempotency handling
  - persistence
- [ ] T019 [US1] Persist snapshots and ensure raw JSON payload is stored (JSONB) for audit/debug
- [ ] T020 [US1] Ensure OpenAPI contract matches behavior (`specs/004-mellow-component-portal/contracts/mellow-koala-api.openapi.yml`)

**Checkpoint**: US1 complete and independently verifiable.

---

## Phase 4: User Story 2 - Index Overview of Component Configurations (Priority: P1)

**Goal**: Public index page shows all components with last-updated timestamps and staleness indicator.

**Independent Test**: Seed two components + snapshots; visit `/` and verify freshness/staleness display.

### Tests for US2 (BDD-first)

- [ ] T021 [US2] System spec: empty state when no components reported (`spec/system/index_overview_spec.rb`)
- [ ] T022 [US2] System spec: renders component list with timestamps + staleness indicator

### Implementation for US2

- [ ] T023 [US2] Implement portal index controller + view (`app/controllers/portal/index_controller.rb`, `app/views/portal/index/*`)
- [ ] T024 [US2] Implement query/service for overview data (latest snapshots per component) (`app/services/portal/overview_query.rb`)
- [ ] T025 [US2] Add freshness window configuration (env var; default 24h) and staleness logic

**Checkpoint**: Index overview is public and accurate.

---

## Phase 5: User Story 3 - Component Detail & Collection Information Pages (Priority: P2)

**Goal**: Public component pages provide drill-down for latest config + collection info with empty states.

### Tests for US3 (BDD-first)

- [ ] T026 [P] [US3] System spec: component details shows latest config snapshot + empty states (`spec/system/component_details_spec.rb`)
- [ ] T027 [P] [US3] System spec: collection page shows latest collection snapshot + empty states (`spec/system/component_collection_spec.rb`)

### Implementation for US3

- [ ] T028 [US3] Implement component details route/controller/view (`app/controllers/portal/components_controller.rb`, `app/views/portal/components/show.html.erb`)
- [ ] T029 [US3] Implement component collection route/controller/view (`app/controllers/portal/collections_controller.rb`, `app/views/portal/collections/show.html.erb`)
- [ ] T030 [US3] Add “not found” behavior for unknown component slugs (404)

---

## Phase 6: User Story 4 - Left Navigation for Components (Priority: P2)

**Goal**: Persistent left nav across portal pages with links to Details + Collection per component.

### Tests for US4 (BDD-first)

- [ ] T031 [US4] System spec: left nav present on index + component pages (`spec/system/navigation_spec.rb`)

### Implementation for US4

- [ ] T032 [US4] Implement nav partial + helper (`app/views/shared/_left_nav.html.erb`, `app/helpers/navigation_helper.rb`)
- [ ] T033 [US4] Ensure active link highlighting works

---

## Phase 7: User Story 5 - Carousel Mode Cycling Through Component Pages (Priority: P3)

**Goal**: Public carousel cycles through component pages with configurable dwell; stops when user manually navigates.

### Tests for US5 (BDD-first)

- [ ] T034 [US5] System spec: carousel advances after dwell parameter and loops deterministically (`spec/system/carousel_spec.rb`)
- [ ] T035 [US5] System spec: manual navigation stops carousel mode

### Implementation for US5

- [ ] T036 [US5] Implement `/carousel` controller/view that chooses next URL and sets an auto-advance mechanism (meta refresh or JS)
- [ ] T037 [US5] Implement dwell validation (default 30, bounds 1..3600) and deterministic ordering
- [ ] T038 [US5] Implement skip-on-error behavior (record error and continue)

---

## Phase 8: Polish & Cross-Cutting

- [ ] T039 [P] Documentation: verify `quickstart.md` curl examples work with auth and match OpenAPI
- [ ] T040 Security hardening pass: confirm secrets never logged; ensure constant-time token verification
- [ ] T041 Run full test suite in Docker (`bundle exec rspec` via compose)

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 is blocking.
- After Phase 2, US1 and US2 can proceed (US1 recommended first for data).
- US3/US4 depend on components existing (typically via US1 or seeds).
- US5 can be done last; it depends on basic portal routes/pages.