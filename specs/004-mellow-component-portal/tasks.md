---

description: "Task list for implementing feature 004"
---

# Tasks: Mellow Collector Portal

**Input**: Design documents in `specs/004-mellow-collector-portal/` (spec.md, plan.md, research.md, data-model.md, contracts/)

**Organization**: Tasks are grouped by user story so each story can be implemented and verified independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1..US5
- Paths below match the structure in `plan.md` (Rails app at repository root).

---

## Phase 1: Setup (Shared Infrastructure)

- [X] T001 Create Rails 8 app skeleton with Tailwind + Postgres configuration (see `specs/004-mellow-collector-portal/plan.md`)
- [X] T002 [P] Add base folders/namespaces for controllers (`app/controllers/api`, `app/controllers/portal`) and services (`app/services/`)
- [X] T003 [P] Add Docker + Docker Compose files per `specs/004-mellow-collector-portal/quickstart.md`
- [X] T004 [P] Add RSpec + Capybara baseline configuration for request + system specs (`spec/requests`, `spec/system`)

**Checkpoint**: App boots in Docker, DB connects, test suite runs.

---

## Phase 2: Foundational (Blocking Prerequisites)

- [X] T005 Create database migrations + models for core entities:
  - `app/models/collector.rb` (include `collection_only` boolean field)
  - `app/models/configuration_snapshot.rb`
  - `app/models/collection_snapshot.rb`
  - migrations in `db/migrate/*` with constraints/indexes from `specs/004-mellow-collector-portal/data-model.md`
- [X] T006 Add idempotency constraints (unique `(collector_id, snapshot_id)` for both snapshot tables)
- [X] T007 Implement ingestion authentication mechanism (simple per-collector bearer token):
  - store only token digests (no plaintext)
  - verify token for the collector in the URL
  - return 401 (missing) / 403 (invalid or mismatched)
  - ensure secrets are never logged
- [X] T008 Create shared API error handling + JSON response shape (`app/controllers/api/base_controller.rb`)
- [ ] T009 Add request size limit enforcement (Rack / Rails config and/or reverse-proxy guidance) and ensure `413` response path is covered
- [ ] T010 [P] Add structured logging fields for ingestion (`request_id`, `collector_id`, `snapshot_type`, `snapshot_id`, `status`, `duration_ms`, `payload_bytes`) in JSON format for Elasticsearch ingestion without logging secrets
- [ ] T011 [P] Add Prometheus metrics exposition endpoint (`/metrics`) for monitoring (request counts, durations, errors)

**Checkpoint**: Data model + auth + error handling exist; user story work can begin.

---

## Phase 3: User Story 1 - CLI Upload of Collector Configuration & Collection Info (Priority: P1) 🎯 MVP

**Goal**: Authenticated collectors can upload configuration + collection snapshots via JSON API with validation, idempotency, and clear errors.

**Independent Test**: Use curl (with `Authorization: Bearer ...`) to POST snapshots; verify persistence + visibility in portal.

### Tests for US1 (BDD-first)

- [X] T011a [P] [US1] Request spec: valid authenticated upload returns 201 and persists snapshot (`spec/requests/api/configuration_snapshots_spec.rb`)
- [X] T012 [P] [US1] Request spec: idempotent replay returns 200 and does not duplicate (`spec/requests/api/*_snapshots_spec.rb`)
- [X] T013 [P] [US1] Request spec: missing auth returns 401 (`spec/requests/api/*_snapshots_spec.rb`)
- [X] T014 [P] [US1] Request spec: invalid token or collector mismatch returns 403 (`spec/requests/api/*_snapshots_spec.rb`)
- [X] T015 [P] [US1] Request spec: invalid payload returns 400 with actionable validation errors

### Implementation for US1

- [X] T016 [US1] Add routes for ingestion endpoints in `config/routes.rb`
- [X] T017 [US1] Implement controllers:
  - `app/controllers/api/configuration_snapshots_controller.rb`
  - `app/controllers/api/collection_snapshots_controller.rb`
- [X] T018 [US1] Implement ingestion service objects (`app/services/ingestion/*`) for:
  - auth check + collector lookup
  - JSON validation
  - idempotency handling
  - persistence
- [X] T019 [US1] Persist snapshots and ensure raw JSON payload is stored (JSONB) for audit/debug
- [ ] T020 [US1] Ensure OpenAPI contract matches behavior (`specs/004-mellow-collector-portal/contracts/mellow-koala-api.openapi.yml`)

**Checkpoint**: US1 complete and independently verifiable.

---

## Phase 4: User Story 2 - Index Overview of Collector Configurations (Priority: P1)

**Goal**: Public index page shows all collectors with last-updated timestamps and staleness indicator.

**Independent Test**: Seed two collectors + snapshots; visit `/` and verify freshness/staleness display.

### Tests for US2 (BDD-first)

- [X] T021 [US2] System spec: empty state when no collectors reported (`spec/system/index_overview_spec.rb`)
- [X] T022 [US2] System spec: renders collector list with timestamps + staleness indicator

### Implementation for US2

- [X] T023 [US2] Implement portal index controller + view (`app/controllers/portal/collectors_controller.rb`, `app/views/portal/collectors/index.html.erb`)
- [~] T024 [US2] Implement query/service for overview data (latest snapshots per collector) — implemented inline in controller; dedicated service deferred
- [X] T025 [US2] Add freshness window configuration (env var; default 24h) and staleness logic

**Checkpoint**: Index overview is public and accurate.

---

## Phase 5: User Story 3 - Collector Detail & Collection Information Pages (Priority: P2)

**Goal**: Public collector pages provide drill-down for latest config + collection info with empty states.

### Tests for US3 (BDD-first)

- [X] T026 [P] [US3] System spec: collector details shows latest config snapshot + empty states (`spec/system/collector_details_spec.rb`)
- [X] T027 [P] [US3] System spec: collection page shows latest collection snapshot + empty states (`spec/system/collector_collection_spec.rb`)

### Implementation for US3

- [X] T028 [US3] Implement collector details route/controller/view (`app/controllers/portal/collectors_controller.rb`, `app/views/portal/collectors/show.html.erb`)
- [X] T029 [US3] Implement collector collection route/controller/view (`app/controllers/portal/collectors_controller.rb`, `app/views/portal/collectors/collection.html.erb`)
- [X] T030 [US3] Add “not found” behavior for unknown collector slugs (404)
- [X] T030a [US3] Implement `collection_only` flag: all collectors are collection-only; Details page is not used

**Checkpoint**: Collector pages working with collector-aware routing.

---

## Phase 6: User Story 4 - Left Navigation for Collectors (Priority: P2)

**Goal**: Persistent left nav across portal pages with links to Details + Collection per collector.

### Tests for US4 (BDD-first)

- [X] T031 [US4] System spec: left nav present on index + collector pages (`spec/system/navigation_spec.rb`)

### Implementation for US4

- [X] T032 [US4] Implement nav partial + helper (`app/views/shared/_left_nav.html.erb`, `app/helpers/navigation_helper.rb`)
- [X] T033 [US4] Ensure active link highlighting works
- [X] T033a [US4] Navigation shows Collection link only (no Details link); all collectors are collection-only

**Checkpoint**: Navigation complete with collector-aware link visibility.

---

## Phase 7: User Story 5 - Carousel Mode Cycling Through Collector Pages (Priority: P3)

**Goal**: Public carousel cycles through collector pages with configurable dwell; stops when user manually navigates.

### Tests for US5 (BDD-first)

- [X] T034 [US5] System spec: carousel advances after dwell parameter and loops deterministically (`spec/system/carousel_spec.rb`)
- [ ] T035 [US5] System spec: manual navigation stops carousel mode

### Implementation for US5

- [X] T036 [US5] Implement `/carousel` controller/view that chooses next URL and sets an auto-advance mechanism (meta refresh or JS)
- [X] T037 [US5] Implement dwell validation (default 30, bounds 1..3600) and deterministic ordering
- [ ] T038 [US5] Implement skip-on-error behavior (record error and continue)

---

## Phase 8: User Story 6 - Mellow Heeler Collection View (Priority: P2)

**Goal**: Display Mellow Heeler's WiFi AP beacon observations with timestamp, count, and table of up to 15 APs.

**Independent Test**: Upload Heeler collection JSON; navigate to Heeler collection page; verify timestamp, AP count, and table rendering.

### Tests for US6 (BDD-first)

- [X] T042 [P] [US6] System spec: Heeler collection shows timestamp of most recent observation (`spec/system/heeler_collection_spec.rb`)
- [X] T043 [P] [US6] System spec: Heeler collection shows count of WiFi AP beacons
- [X] T044 [P] [US6] System spec: Heeler collection table displays up to 15 APs with SSID, BSSID, frequency (MHz), signal (dBm)
- [X] T045 [P] [US6] System spec: Heeler collection truncates display to 15 APs when more than 15 are present
- [X] T046 [P] [US6] System spec: Heeler empty state when no collection data received

### Implementation for US6

- [X] T047 [US6] Mark Heeler as a collection-only collector (`collection_only = true`) in seed data or migration
- [X] T048 [US6] Create Heeler-specific collection view template (`app/views/portal/collectors/_heeler.html.erb`)
- [X] T049 [US6] Parse HeelerCollectionPayload schema: extract `zTime`, `wifi` array
- [X] T050 [US6] Render timestamp (convert `zTime` Unix timestamp to display format)
- [X] T051 [US6] Render AP count (length of `wifi` array)
- [X] T052 [US6] Render AP table with columns: SSID, BSSID, frequency (MHz), signal (dBm); limit to first 15 entries
- [X] T053 [US6] Add collector-specific view routing logic (check `project` field or collector identifier to select correct partial)

**Checkpoint**: US6 complete; Heeler collection view functional and independently verifiable.

---

## Phase 9: User Story 7 - Mellow Hyena ADSB Collection View (Priority: P2)

**Goal**: Display Mellow Hyena ADSB's aviation beacon observations with a header (timestamp, count, platform, site) and a table of up to 15 observations enriched with registration/model from the adsbex stanza.

**Independent Test**: Upload Hyena ADSB collection JSON; navigate to Hyena ADSB collection page; verify header fields and observation table with adsbex enrichment (including "unknown" fallback).

### Tests for US7 (BDD-first)

- [X] T059 [P] [US7] System spec: Hyena ADSB collection shows header with timestamp, beacon count, platform, site (`spec/system/hyena_adsb_collection_spec.rb`)
- [X] T060 [P] [US7] System spec: Hyena ADSB collection table displays up to 15 observations with adsbHex, registration, model, flight, altitude, track
- [X] T061 [P] [US7] System spec: registration and model resolved from adsbex by adsbHex match
- [X] T062 [P] [US7] System spec: registration and model show "unknown" when adsbHex not found in adsbex
- [X] T063 [P] [US7] System spec: Hyena ADSB collection truncates display to 15 observations when more than 15 are present
- [X] T064 [P] [US7] System spec: Hyena ADSB empty state when no collection data received

### Implementation for US7

- [X] T065 [US7] Mark Hyena ADSB collector as collection-only (`collection_only = true`) in seed data or migration
- [X] T066 [US7] Create Hyena ADSB-specific collection view template (`app/views/portal/collectors/_hyena_adsb.html.erb`)
- [X] T067 [US7] Parse HyenaAdsbCollectionPayload schema: extract `zTime`, `platform`, `geoLoc.site`, `observation` array, `adsbex` array
- [X] T068 [US7] Render header: timestamp (convert `zTime` Unix timestamp to display format), observation count, platform, site
- [X] T069 [US7] Build adsbex lookup map keyed by `adsbHex` for O(1) enrichment
- [X] T070 [US7] Render observation table: adsbHex, registration, model, flight, altitude, track; limit to first 15; fall back to "unknown" for registration/model when no adsbex match
- [X] T071 [US7] Extend collector-specific view routing to dispatch to `_hyena_adsb` partial (check `project` field = `"hyena-adsb"`)

**Checkpoint**: US7 complete; Hyena ADSB collection view functional and independently verifiable.

---

## Phase 10: User Story 8 - Mellow Hyena UAT Collection View (Priority: P2)

**Goal**: Display Mellow Hyena UAT's aviation beacon observations with a header (timestamp, count, platform, site) and a table of up to 15 observations enriched with registration/model from the adsbex stanza.

**Independent Test**: Upload Hyena UAT collection JSON; navigate to Hyena UAT collection page; verify header fields and observation table with adsbex enrichment (including "unknown" fallback).

### Tests for US8 (BDD-first)

- [X] T072 [P] [US8] System spec: Hyena UAT collection shows header with timestamp, beacon count, platform, site (`spec/system/hyena_uat_collection_spec.rb`)
- [X] T073 [P] [US8] System spec: Hyena UAT collection table displays up to 15 observations with adsbHex, registration, model, flight, altitude, track
- [X] T074 [P] [US8] System spec: registration and model resolved from adsbex by adsbHex match
- [X] T075 [P] [US8] System spec: registration and model show "unknown" when adsbHex not found in adsbex
- [X] T076 [P] [US8] System spec: Hyena UAT collection truncates display to 15 observations when more than 15 are present
- [X] T077 [P] [US8] System spec: Hyena UAT empty state when no collection data received

### Implementation for US8

- [X] T078 [US8] Mark Hyena UAT as a collection-only collector (`collection_only = true`) in seed data or migration
- [X] T079 [US8] Create Hyena UAT-specific collection view template (`app/views/portal/collectors/_hyena_uat.html.erb`)
- [X] T080 [US8] Parse HyenaUatCollectionPayload schema: extract `zTime`, `platform`, `geoLoc.site`, `observation` array, `adsbex` array
- [X] T081 [US8] Render header: timestamp (convert `zTime` Unix timestamp to display format), observation count, platform, site
- [X] T082 [US8] Build adsbex lookup map keyed by `adsbHex` for O(1) enrichment
- [X] T083 [US8] Render observation table: adsbHex, registration, model, flight, altitude, track; limit to first 15; fall back to "unknown" for registration/model when no adsbex match
- [X] T084 [US8] Extend collector-specific view routing to dispatch to `_hyena_uat` partial (check `project` field = `"hyena-uat"`)

**Checkpoint**: US8 complete; Hyena UAT collection view functional and independently verifiable.

---

## Phase 11: User Story 9 - Mellow Mastodon Collection View (Priority: P2)

**Goal**: Display Mellow Mastodon's energy survey results with a header (timestamp, peakers count, platform, site).

**Independent Test**: Upload Mastodon collection JSON; navigate to Mastodon collection page; verify header fields render correctly.

### Tests for US9 (BDD-first)

- [X] T085 [P] [US9] System spec: Mastodon collection shows header with timestamp, peakers count, platform, site (`spec/system/mastodon_collection_spec.rb`)
- [X] T086 [P] [US9] System spec: Mastodon empty state when no collection data received

### Implementation for US9

- [X] T087 [US9] Mark Mastodon as a collection-only collector (`collection_only = true`) in seed data or migration
- [X] T088 [US9] Create Mastodon-specific collection view template (`app/views/portal/collectors/_mastodon.html.erb`)
- [X] T089 [US9] Parse MastodonCollectionPayload schema: extract `zTime`, `platform`, `geoLoc.site`, `peakers`
- [X] T090 [US9] Render header: timestamp (convert `zTime` Unix timestamp to display format), peakers count, platform, site
- [X] T091 [US9] Extend collector-specific view routing to dispatch to `_mastodon` partial (check `project` field = `"mastodon"`)

**Checkpoint**: US9 complete; Mastodon collection view functional and independently verifiable.

---

## Phase 12: CLI Import Utilities (US1 — per-collector)

**Goal**: Each collection-only collector has a dedicated `bin/import_<name>` CLI utility for uploading a JSON file to the Mellow Koala API.

### Fix existing utility

- [X] T092 [US1] Fix stale API path in `bin/import_heeler`: change `/api/components/` → `/api/collectors/` (`bin/import_heeler`)

### New utilities

- [X] T093 [P] [US1] Create `bin/import_hyena_adsb` CLI utility (mirrors `import_heeler`; COLLECTOR_ID `mellow-hyena-adsb`; info line shows `platform`, `geoLoc.site`, `observation` count, `zTime`) (`bin/import_hyena_adsb`)
- [X] T094 [P] [US1] Create `bin/import_hyena_uat` CLI utility (mirrors `import_heeler`; COLLECTOR_ID `mellow-hyena-uat`; info line shows `platform`, `geoLoc.site`, `observation` count, `zTime`) (`bin/import_hyena_uat`)
- [X] T095 [P] [US1] Create `bin/import_mastodon` CLI utility (mirrors `import_heeler`; COLLECTOR_ID `mellow-mastodon`; info line shows `platform`, `geoLoc.site`, `peakers` count, `zTime`) (`bin/import_mastodon`)
- [X] T096 [P] [US1] Make all new import utilities executable (`chmod +x`) (`bin/import_hyena_adsb`, `bin/import_hyena_uat`, `bin/import_mastodon`)

**Checkpoint**: All four collectors have working CLI import utilities pointing at `/api/collectors/`.

---

## Phase 12b: Retrospective Fixes (discovered during deployment)

- [X] T097 [US1] Fix routes param naming: `param: :collector_id` generates `collector_collector_id` in nested resources; changed to `param: :id` so `params[:collector_id]` resolves correctly (`config/routes.rb`)
- [X] T098 Fix stale `db/schema.rb`: schema still referenced `components` table pre-rename; rewrote schema to post-rename state with `collectors` table and correct indexes/foreign keys (`db/schema.rb`, `db/migrate/20260422165702_rename_components_to_collectors.rb`)

---

## Phase 13: Polish & Cross-Cutting

- [ ] T054 [P] Documentation: verify `quickstart.md` curl examples work with auth and match OpenAPI
- [ ] T055 Security hardening pass: confirm secrets never logged; ensure constant-time token verification
- [ ] T056 Run full test suite in Docker (`bundle exec rspec` via compose)
- [ ] T057 [P] Verify all FR-001 through FR-050 are implemented and tested
- [ ] T058 [P] Constitution compliance final check against v2.0.4

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 is blocking.
- After Phase 2, US1 and US2 can proceed (US1 recommended first for data).
- US3/US4 depend on collectors existing (typically via US1 or seeds).
- US5 can be done last; it depends on basic portal routes/pages.