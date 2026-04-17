---

description: "Task list for Mellow Koala Wombat Console implementation"

---

# Tasks: Mellow Koala Wombat Console

**Input**: Design documents from `/specs/001-wombat-console/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/rake-task-contracts.md ✅, quickstart.md ✅

**Tests**: Included — spec SC-009 requires all critical user journeys covered by automated tests.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies with peers)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths are included in every task description

---

## Phase 1: Setup (Rails App Initialization)

**Purpose**: Create and configure the Rails 8 application shell. Nothing else can start until this is done.

- [ ] T001 Create Rails 8 application at repo root with SQLite3 and Tailwind CSS: `rails new . --database=sqlite3 --css=tailwind --skip-action-mailer --skip-action-cable --skip-active-storage --skip-action-text --skip-hotwire`
- [ ] T002 Add `pagy`, `yajl-ruby` (~> 1.4, require: 'yajl'), and production-group `mysql2` (~> 0.5) gems to `Gemfile`; run `bundle install`
- [ ] T003 [P] Configure production MySQL adapter in `config/database.yml` (production section: adapter mysql2, encoding utf8mb4, ENV-driven host/port/database/username/password)
- [ ] T004 [P] Pin Ruby version in `.ruby-version` (e.g., `3.3.x` matching your system); verify `ruby -v` matches

**Checkpoint**: `rails server` boots without errors; `rails -T` lists default tasks

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Database schema, authentication scaffold, routing, and shared infrastructure that every user story depends on. **No user story work begins until this phase is complete.**

- [ ] T005 Run `rails generate authentication` to scaffold User, Session, Current, and Authentication concern; run `bundle install` to install bcrypt
- [ ] T006 Extend the generated sessions migration to add `touched_at` column (`t.datetime :touched_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }`) in `db/migrate/*_create_sessions.rb`, or generate `rails generate migration AddTouchedAtToSessions touched_at:datetime`
- [ ] T007 [P] Create CreateTasks migration (`rails generate migration CreateTasks name:string uuid:string host:string start_time:datetime stop_time:datetime`) and hand-edit to add `null: false` on required columns, `add_index :tasks, :uuid, unique: true`, `add_index :tasks, :host`, `add_index :tasks, :start_time` in `db/migrate/*_create_tasks.rb`
- [ ] T008 [P] Create CreateBoxScores migration (`rails generate migration CreateBoxScores task_name:string task_uuid:string uuid:string population:decimal time_stamp:datetime`) and hand-edit to add `null: false`, `precision: 10, scale: 4` on population, `add_index :box_scores, :uuid, unique: true`, `add_index :box_scores, :task_name` in `db/migrate/*_create_box_scores.rb`
- [ ] T009 [P] Create CreateImportLogs migration (`rails generate migration CreateImportLogs source_file:string import_type:string run_at:datetime records_processed:integer records_inserted:integer records_skipped:integer error_details:text`) and hand-edit to add `null: false` on required columns, `add_index :import_logs, :run_at`, `add_index :import_logs, :import_type` in `db/migrate/*_create_import_logs.rb`
- [ ] T010 Run `rails db:migrate` and `rails db:test:prepare`; confirm `rails db:schema:dump` shows all five tables (users, sessions, tasks, box_scores, import_logs) with correct columns and indexes in `db/schema.rb`
- [ ] T011 Configure all application routes in `config/routes.rb`: root `tasks#index`; `resources :tasks, only: [:index]`; `resources :box_scores, only: [:index]`; `resource :session, only: [:new, :create, :destroy]`; `namespace :admin` with `root dashboard#index`, `resources :import_logs, only: [:index, :show]`
- [ ] T012 Create `app/controllers/admin/base_controller.rb` inheriting from `ApplicationController` with `before_action :require_authentication`
- [ ] T013 [P] Create Pagy initializer at `config/initializers/pagy.rb`: `require 'pagy/extras/rails'`; `Pagy::DEFAULT[:limit] = 25`
- [ ] T014 [P] Add `include Pagy::Rails` to `app/controllers/application_controller.rb` (do NOT add global `before_action :require_authentication` — dashboards are public per FR-012)

**Checkpoint**: `rails routes` shows all expected routes; `rails db:schema:dump` shows all five tables; `rails test` runs (0 failures, setup errors only acceptable if no test files yet exist)

---

## Phase 3: User Story 1 — Task Dashboard (Priority: P1) 🎯 MVP

**Goal**: Operators can navigate to `/tasks` and view a paginated, sortable, filterable table of all task execution records with name, UUID, host, start_time, stop_time, and computed duration. Empty state displays "No tasks found."

**Independent Test**: Navigate to `/tasks`; table shows the six required columns for all seeded records; duration computed as HH:MM:SS or "In Progress" for null stop_time; pagination controls navigate pages; host and date-range filters narrow results.

### Tests for User Story 1 ⚠️ Write first — they MUST fail before implementation

- [ ] T015 [P] [US1] Write `test/models/task_test.rb`: test `duration` returns nil when stop_time is nil; returns Float seconds when stop_time present; test `duration_display` returns "In Progress" for nil stop_time and "HH:MM:SS" format otherwise; test validations (uuid/name/host/start_time presence, uuid uniqueness)
- [ ] T016 [P] [US1] Write `test/controllers/tasks_controller_test.rb`: test `GET /tasks` returns 200 with seeded records; test `host` filter param narrows results; test `start_from`/`start_to` date range filter; test sort param (`name`, `host`, `start_time`, `stop_time`); test empty state when no records exist
- [ ] T017 [P] [US1] Write `test/system/task_dashboard_test.rb` (Capybara): visit `/tasks`; assert table has columns Name, UUID, Host, Start Time, Stop Time, Duration; assert "In Progress" shown for task with null stop_time; assert pagination links present when records > 25; assert "No tasks found" on empty state

### Implementation for User Story 1

- [ ] T018 [P] [US1] Implement `app/models/task.rb`: `validates :uuid, :name, :host, :start_time, presence: true`; `validates :uuid, uniqueness: true`; `def duration` (returns Float or nil); `def duration_display` (returns "HH:MM:SS" or "In Progress") per research R-006
- [ ] T019 [US1] Implement `app/controllers/tasks_controller.rb`: `index` action applying host filter (`params[:host]`), date range filter (`params[:start_from]`, `params[:start_to]`), sort (`params[:sort]` allowlisted to `name/host/start_time/stop_time`, `params[:direction]` allowlisted to `asc/desc`), and `pagy(Task.order(...).where(...))` for offset pagination
- [ ] T020 [US1] Create `app/views/tasks/index.html.erb`: Tailwind-styled filter form (host text input, start_from/start_to date inputs, submit button); sortable table with clickable column headers for name/host/start_time/stop_time/duration; `<%= pagy_nav(@pagy) %>` pagination controls; empty-state div with "No tasks found" shown when `@tasks.empty?`
- [ ] T021 [US1] Create `app/views/layouts/application.html.erb`: Tailwind base layout with responsive nav (links to Tasks, Box Scores, Admin Login); `<%= yield %>` content area; flash message display block for notices and alerts

**Checkpoint**: `rails test test/models/task_test.rb test/controllers/tasks_controller_test.rb` passes; `rails test:system TEST=test/system/task_dashboard_test.rb` passes; `/tasks` renders correctly with seed data

---

## Phase 4: User Story 2 — Box-Score Dashboard (Priority: P1)

**Goal**: Operators can navigate to `/box_scores` and view a paginated, sortable, filterable table of all box-score records with task_name, task_uuid, population, and time_stamp. Filtering by task_name narrows results. Empty state displays "No box scores found."

**Independent Test**: Navigate to `/box_scores`; table shows four required columns for all seeded records; task_name filter narrows results; pagination navigates pages correctly.

### Tests for User Story 2 ⚠️ Write first — they MUST fail before implementation

- [ ] T022 [P] [US2] Write `test/models/box_score_test.rb`: test validations (uuid/task_name/task_uuid/time_stamp presence, uuid uniqueness, population numericality ≥ 0); test decimal precision round-trips for population
- [ ] T023 [P] [US2] Write `test/controllers/box_scores_controller_test.rb`: test `GET /box_scores` returns 200 with seeded records; test `task_name` filter param narrows results; test sort param; test empty state when no records
- [ ] T024 [P] [US2] Write `test/system/box_score_dashboard_test.rb` (Capybara): visit `/box_scores`; assert table has columns Task Name, Task UUID, Population, Time Stamp; assert task_name filter form present; assert "No box scores found" on empty state; assert Pagy nav present when records > 25

### Implementation for User Story 2

- [ ] T025 [P] [US2] Implement `app/models/box_score.rb`: `validates :uuid, :task_name, :task_uuid, :time_stamp, presence: true`; `validates :uuid, uniqueness: true`; `validates :population, presence: true, numericality: { greater_than_or_equal_to: 0 }`
- [ ] T026 [US2] Implement `app/controllers/box_scores_controller.rb`: `index` action applying task_name filter (`params[:task_name]` with LIKE/ilike), sort (`params[:sort]` allowlisted to `task_name/task_uuid/population/time_stamp`), and `pagy(:keyset, BoxScore.order(id: :asc))` keyset pagination for performance at 50k rows (per research R-001)
- [ ] T027 [US2] Create `app/views/box_scores/index.html.erb`: Tailwind-styled filter form (task_name text input, submit button); sortable table with clickable headers for task_name/task_uuid/population/time_stamp; `<%= pagy_nav(@pagy) %>` pagination controls; empty-state div with "No box scores found" when `@box_scores.empty?`

**Checkpoint**: `rails test test/models/box_score_test.rb test/controllers/box_scores_controller_test.rb` passes; `rails test:system TEST=test/system/box_score_dashboard_test.rb` passes; `/box_scores` renders correctly with seed data

---

## Phase 5: User Story 3 — JSON Import via Rake Task (Priority: P2)

**Goal**: Running `rails import:tasks[file]` or `rails import:box_scores[file]` inserts records from a JSON file, skips duplicates by UUID, writes an ImportLog audit record, and prints a human-readable summary. Re-running the same file produces zero new inserts and zero errors.

**Independent Test**: Run `rails import:tasks[path/to/tasks.json]`; records appear in DB. Re-run same command; output shows `Inserted: 0, Skipped: N`. Run with a missing file path; exit code 1 with clear error message. Check `ImportLog` table for audit entry after each run.

### Tests for User Story 3 ⚠️ Write first — they MUST fail before implementation

- [ ] T028 [P] [US3] Write `test/models/import_log_test.rb`: test validations (source_file/import_type/run_at presence; records_processed/inserted/skipped numericality ≥ 0; import_type inclusion in `%w[tasks box_scores]`)
- [ ] T029 [P] [US3] Write `test/integration/import_service_test.rb`: test happy-path tasks import creates correct DB records + ImportLog; test idempotency (second import of same file inserts 0 records); test box_scores import; test partial-success (malformed record skipped, valid records inserted, error logged to ImportLog.error_details); test empty JSON array exits cleanly with processed: 0; test non-existent file raises ArgumentError
- [ ] T030 [P] [US3] Write `test/integration/rake_import_contract_test.rb`: test `import:tasks[file]` stdout matches contract format (Processed/Inserted/Skipped/Errors lines); test exit code 0 on success; test exit code 1 on missing file; test `import:box_scores[file]` same contract

### Implementation for User Story 3

- [ ] T031 [P] [US3] Implement `app/models/import_log.rb`: `validates :source_file, :import_type, :run_at, presence: true`; `validates :records_processed, :records_inserted, :records_skipped, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }`; `validates :import_type, inclusion: { in: %w[tasks box_scores] }`
- [ ] T032 [US3] Implement `app/services/import_service.rb`: `require 'yajl'`; `BATCH_SIZE = 500`; `import!(filepath, model_class, import_type)` method that raises `ArgumentError` on missing file; uses `Yajl::Parser` with `on_parse_complete` callback for streaming (constant ~5 MB memory per research R-002); `flush_batch!` calls `model_class.upsert_all(batch, unique_by: :uuid, on_duplicate: :update, returning: [:id])`; `write_audit_log!` creates `ImportLog` record; per-record rescue in `handle_record` logs to `@stats[:errors]` and continues (partial-success per FR-018)
- [ ] T033 [US3] Implement `lib/tasks/import.rake`: `import:tasks[filepath]` task that calls `ImportService.new.import!(filepath, Task, 'tasks')` and prints summary (`Processed: N | Inserted: N | Skipped: N | Errors: N`) then `exit 0`; handles `ArgumentError` with error print and `exit 1`; `import:box_scores[filepath]` task identical pattern with `BoxScore` and `'box_scores'`

**Checkpoint**: `rails test test/models/import_log_test.rb test/integration/import_service_test.rb test/integration/rake_import_contract_test.rb` passes; running rake task against sample JSON file produces expected stdout and creates ImportLog record

---

## Phase 6: User Story 4 — Admin Authentication (Priority: P2)

**Goal**: All `/admin/*` routes redirect unauthenticated users to `/session/new`. Valid credentials grant access; invalid credentials show an error. Logout immediately invalidates the session. Sessions expire after 8 hours of inactivity (configurable via `SESSION_TIMEOUT_HOURS`). Public dashboard routes remain accessible without authentication.

**Independent Test**: Visit `/admin` without a session → redirected to `/session/new`. Submit valid credentials → admin page loads. Click Logout → revisiting `/admin` redirects to login. Submit invalid credentials → error message shown, user remains on login page. Visit `/tasks` without session → page loads normally.

### Tests for User Story 4 ⚠️ Write first — they MUST fail before implementation

- [ ] T034 [P] [US4] Write `test/system/admin_auth_test.rb` (Capybara): test unauthenticated visit to `/admin` redirects to login page; test valid credentials → admin page loads; test invalid credentials → error shown, stays on login; test logout → subsequent `/admin` visit redirects to login; test `/tasks` accessible without authentication (FR-012); test session inactivity expiry (manipulate `touched_at` to past, assert redirect on next request)

### Implementation for User Story 4

- [ ] T035 [US4] Extend generated `app/models/session.rb`: add `SESSION_TIMEOUT = ENV.fetch('SESSION_TIMEOUT_HOURS', '8').to_i.hours`; add `scope :expired, -> { where(touched_at: ...SESSION_TIMEOUT.ago) }`; add `def self.sweep_expired = expired.delete_all`
- [ ] T036 [US4] Extend `app/controllers/concerns/authentication.rb`: override `resume_session` to check `session.touched_at < Session::SESSION_TIMEOUT.ago` → destroy and return nil; call `session.touch(:touched_at)` on active sessions; ensure `require_authentication` redirects to `new_session_path` with a flash notice
- [ ] T037 [US4] Create `app/controllers/admin/dashboard_controller.rb` inheriting from `Admin::BaseController`; `index` action that renders a simple landing page (recent import summary, links to import logs)
- [ ] T038 [US4] Create `app/views/sessions/new.html.erb`: Tailwind-styled login form with email and password fields, submit button, flash error display for invalid credentials (uses `session_path` POST route)
- [ ] T039 [US4] Create `app/views/admin/dashboard/index.html.erb`: Tailwind-styled admin landing page showing greeting, link to Import Logs, count of recent imports (last 7 days via `ImportLog.where(run_at: 7.days.ago..)`)
- [ ] T040 [US4] Update `db/seeds.rb` to include admin user provisioning instructions (commented-out `User.create!` block with ENV var references for `ADMIN_EMAIL`/`ADMIN_PASSWORD`; never hard-code credentials per security policy)

**Checkpoint**: `rails test:system TEST=test/system/admin_auth_test.rb` passes; full auth flow (login → admin → logout) works end-to-end in browser via `bin/dev`

---

## Phase 7: User Story 5 — Audit Log Viewer (Priority: P3)

**Goal**: An authenticated admin navigates to `/admin/import_logs` and sees a chronological, paginated list of all import runs showing source file, import type, run time, processed/inserted/skipped counts. Clicking an entry shows detail including any per-record error_details.

**Independent Test**: After running at least one import, navigate to `/admin/import_logs`; entries appear with all required fields. Click an entry with errors; error detail text is shown on the show page.

### Tests for User Story 5 ⚠️ Write first — they MUST fail before implementation

- [ ] T041 [P] [US5] Write `test/controllers/admin/import_logs_controller_test.rb`: test `GET /admin/import_logs` with authenticated session returns 200 and lists import log records; test unauthenticated request redirects to login; test `GET /admin/import_logs/:id` shows detail record; test record with `error_details` shows error text on show page

### Implementation for User Story 5

- [ ] T042 [P] [US5] Implement `app/controllers/admin/import_logs_controller.rb` inheriting from `Admin::BaseController`: `index` action with `pagy(ImportLog.order(run_at: :desc))`; `show` action finding by id
- [ ] T043 [P] [US5] Create `app/views/admin/import_logs/index.html.erb`: Tailwind-styled table with columns Source File, Import Type, Run At, Processed, Inserted, Skipped, Errors (count from error_details lines); link to show page per row; `<%= pagy_nav(@pagy) %>` pagination controls; empty state "No import logs yet"
- [ ] T044 [US5] Create `app/views/admin/import_logs/show.html.erb`: detail view showing all ImportLog fields; `error_details` section rendered as preformatted text (`<pre>`) only when present; "Back to Import Logs" link; Tailwind card layout

**Checkpoint**: `rails test test/controllers/admin/import_logs_controller_test.rb` passes; authenticated admin can browse and view import log entries

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Developer experience, seed data, CI validation, and final verification across all user stories.

- [ ] T045 Populate `db/seeds.rb` with ~50 `Task` records (varied hosts, date ranges, some with null stop_time for "In Progress" display) and ~200 `BoxScore` records (multiple task names, varied populations) exercising pagination; run `rails db:seed` to verify
- [ ] T046 [P] Add Tailwind responsive table utility classes (`overflow-x-auto`, `min-w-full`, `whitespace-nowrap`) to both dashboard tables so they scroll horizontally on small screens without layout breaks
- [ ] T047 [P] Review and update `.github/workflows/ci.yml` to confirm it runs `bin/rails db:test:prepare test test:system` and that the `mysql2` gem is included in the CI matrix (SQLite3 for dev/test is the CI target per spec FR-014)
- [ ] T048 Validate all steps in `specs/001-wombat-console/quickstart.md` end-to-end: clean checkout → `rails new` → `bundle install` → `generate authentication` → `db:migrate` → `db:seed` → `bin/dev` → verify all routes load → run full test suite
- [ ] T049 [P] Run the full test suite (`rails test test:system`) and confirm all tests pass; review coverage for the five critical journeys from SC-009: task dashboard, box-score dashboard, import run, admin login, admin logout

**Final Checkpoint**: `rails test test:system` green; `bin/dev` boots with no errors; all five user story acceptance scenarios manually verified against seed data

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)
  └── Phase 2 (Foundational)  ← BLOCKS all user stories
        ├── Phase 3 (US1 Task Dashboard)       P1 — start here
        ├── Phase 4 (US2 Box-Score Dashboard)  P1 — can parallel with US1
        ├── Phase 5 (US3 JSON Import)          P2 — depends on ImportLog model (T031)
        ├── Phase 6 (US4 Admin Auth)           P2 — depends on auth scaffold (T005)
        └── Phase 7 (US5 Audit Log Viewer)     P3 — depends on US3 (ImportLog) + US4 (auth)
              └── Phase 8 (Polish)
```

### User Story Dependencies

| Story | Depends On | Can Start After |
|-------|------------|-----------------|
| US1 Task Dashboard (P1) | Phase 2 complete | T014 |
| US2 Box-Score Dashboard (P1) | Phase 2 complete | T014 — parallel with US1 |
| US3 JSON Import (P2) | Phase 2 complete; ImportLog migration (T009) | T010 |
| US4 Admin Authentication (P2) | auth scaffold (T005–T006) | T006 |
| US5 Audit Log Viewer (P3) | US3 (ImportLog model T031), US4 (auth T035–T036) | T040 |

### Within Each User Story

1. Tests written and confirmed FAILING first
2. Models → Services → Controllers → Views
3. Controller tests before system tests (system tests depend on views)
4. Story complete and checkpoint passed before declaring done

### Parallel Opportunities

- **Phase 2**: T007, T008, T009 (three migration files) can be created in parallel
- **Phase 3 + Phase 4**: US1 and US2 have no dependency on each other — two developers can work them in parallel
- **Phase 3 tests**: T015, T016, T017 are all independent test files — write in parallel
- **Phase 4 tests**: T022, T023, T024 are all independent test files — write in parallel
- **Phase 5 tests**: T028, T029, T030 are all independent test files — write in parallel
- **Models in same phase**: Task (T018) and BoxScore (T025) can be written in parallel

---

## Parallel Execution Example: User Story 1 + User Story 2

```bash
# Terminal A — User Story 1 (Task Dashboard)
rails test test/models/task_test.rb          # T015 — confirm fails
# Implement Task model                        # T018
rails test test/models/task_test.rb          # should now pass
# Implement TasksController                   # T019
# Create tasks/index.html.erb                # T020
rails test test/controllers/tasks_controller_test.rb   # T016 — pass

# Terminal B — User Story 2 (Box-Score Dashboard) — in parallel
rails test test/models/box_score_test.rb     # T022 — confirm fails
# Implement BoxScore model                   # T025
rails test test/models/box_score_test.rb     # should now pass
# Implement BoxScoresController              # T026
# Create box_scores/index.html.erb          # T027
rails test test/controllers/box_scores_controller_test.rb  # T023 — pass

# Both can merge once Phase 2 checkpoint is cleared
```

---

## Implementation Strategy

### MVP Scope (Phase 1 + 2 + 3)

Deliver a fully functional Task Dashboard alone:

1. Complete Phase 1 (app setup) + Phase 2 (foundational infra)
2. Complete Phase 3 (US1 Task Dashboard) with seed data
3. Demo: Operator can load `/tasks`, see paginated/sortable/filterable task records, observe "In Progress" for tasks with null stop_time

**MVP Demo Command**:
```bash
rails db:seed && bin/dev
# Navigate to http://localhost:3000/tasks
```

### Increment 2 (Add Box-Score Dashboard)

Complete Phase 4 (US2). Now both public dashboards are live.

### Increment 3 (Add Data Import)

Complete Phase 5 (US3). Rake import tasks populate the DB from real JSON files.

### Increment 4 (Add Security)

Complete Phase 6 (US4). Admin endpoints are protected behind authentication.

### Increment 5 (Add Audit Log Viewer)

Complete Phase 7 (US5). Admin can review import history from the browser.

---

## Task Summary

| Phase | Purpose | Task IDs | Count |
|-------|---------|----------|-------|
| Phase 1 | Setup | T001–T004 | 4 |
| Phase 2 | Foundational | T005–T014 | 10 |
| Phase 3 | US1 Task Dashboard (P1) | T015–T021 | 7 |
| Phase 4 | US2 Box-Score Dashboard (P1) | T022–T027 | 6 |
| Phase 5 | US3 JSON Import (P2) | T028–T033 | 6 |
| Phase 6 | US4 Admin Authentication (P2) | T034–T040 | 7 |
| Phase 7 | US5 Audit Log Viewer (P3) | T041–T044 | 4 |
| Phase 8 | Polish | T045–T049 | 5 |
| **Total** | | **T001–T049** | **49** |

| User Story | Tasks | Test Tasks | Impl Tasks |
|------------|-------|-----------|------------|
| US1 Task Dashboard | 7 | 3 | 4 |
| US2 Box-Score Dashboard | 6 | 3 | 3 |
| US3 JSON Import | 6 | 3 | 3 |
| US4 Admin Authentication | 7 | 1 | 6 |
| US5 Audit Log Viewer | 4 | 1 | 3 |
