# Implementation Plan: Mellow Koala Wombat Console

**Branch**: `001-wombat-console` | **Date**: 2026-04-17 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-wombat-console/spec.md`

## Summary

Build the Mellow Koala Wombat Console — a Rails 8 web application that aggregates
task execution records and box-score metrics imported from other Mellow projects.
The console provides:
1. **Public read dashboards** for Task and BoxScore records (paginated, sortable,
   filterable) using Pagy for performance and Tailwind CSS for styling.
2. **Idempotent JSON import Rake tasks** using streaming JSON parsing (yajl-ruby)
   and `upsert_all` batch inserts with a full audit log per import run.
3. **Session-based admin authentication** using Rails 8's built-in authentication
   generator to protect write and audit-log endpoints while keeping dashboards public.

Storage: SQLite3 for development/test; MySQL 8.0+ for production.

## Technical Context

**Language/Version**: Ruby 3.x / Rails 8.x (Ruby version pinned in `.ruby-version`)
**Primary Dependencies**:
- `pagy` — high-performance pagination (Pagy v9+, replaces Kaminari; ~40× faster,
  native Tailwind CSS helpers, keyset pagination for 50k BoxScore rows)
- `yajl-ruby` — streaming JSON parser for import Rake tasks (constant ~5 MB memory
  regardless of file size; fulfils FR-007 no-full-file-in-memory requirement)
- `bcrypt` — password hashing for admin authentication (required by Rails 8
  `has_secure_password`; already bundled with Rails)
- `tailwindcss-rails` — Tailwind CSS via asset pipeline (assumed pre-configured
  per spec Assumption §8)

**Storage**:
- Development / Test: SQLite3 (via `sqlite3` gem, Rails default adapter)
- Production: MySQL 8.0+ (via `mysql2` gem; MySQL 8.0+ required for
  `RETURNING` clause support in `upsert_all`)

**Testing**: Minitest (Rails default) + Capybara for system tests (already in
`ci.yml` — `bin/rails db:test:prepare test test:system`)

**Target Platform**: Linux server (CI on `ubuntu-latest`, per `.github/workflows/ci.yml`)

**Project Type**: Rails MVC web application (server-rendered, no SPA framework)

**Performance Goals**:
- Task dashboard loads ≤ 2 s for 10,000 records (SC-001)
- BoxScore dashboard loads ≤ 2 s for 50,000 records (SC-002; use Pagy keyset
  pagination to skip expensive COUNT queries at this scale)
- Import Rake task: 10,000-record JSON file completes in ≤ 60 s (SC-003;
  target ~22 s with yajl-ruby + `upsert_all` batch size 500)

**Constraints**:
- No background jobs in v1; imports run synchronously via Rake tasks (spec
  Assumption §9; justified deviation from Constitution Principle V — see
  Complexity Tracking below)
- No additional CSS frameworks beyond Tailwind CSS (FR-015)
- Admin credentials via environment variables or single database-backed user
  (spec Assumption §1)
- `duration` column does NOT exist in the database; always computed as
  `stop_time - start_time` in the application layer (FR-013)
- Box-score `task_uuid` is informational — no enforced FK to `tasks` at DB level
  for v1 (spec Assumption §5)
- Pagination default page size: 25 (spec Assumption §10)

**Scale/Scope**:
- Tasks table: up to 10,000 records
- BoxScores table: up to 50,000 records
- Single admin user for v1
- 5 controller namespaces: `TasksController`, `BoxScoresController`,
  `SessionsController`, `Admin::ImportLogsController`,
  `Admin::DashboardController`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Rails Convention Over Configuration** | ✅ PASS | Standard RESTful routes, ActiveRecord, MVC directory structure. No deviations. |
| **II. Data Integrity First** | ✅ PASS | Unique index on `tasks.uuid` and `box_scores.uuid` defined at DB level. All imports are idempotent (`upsert_all unique_by: :uuid`). Audit log created per import run. |
| **III. Security By Design** | ✅ PASS | Rails 8 built-in auth generator (bcrypt, signed cookies, rate-limited login). Admin endpoints protected via `before_action :require_authentication`. No secrets in source. |
| **IV. Test Coverage** | ✅ PASS | Import utilities: integration tests for data transformation + idempotency. Controllers: system tests for all critical journeys. Target >80% model/controller coverage. |
| **V. Performance & Scalability** | ⚠️ PARTIAL — see Complexity Tracking | Eager loading used; Pagy keyset for large tables; batch `upsert_all` (500/batch). **VIOLATION**: synchronous Rake imports instead of background jobs (justified for v1). |

**Post-design re-check**: ✅ All principles satisfied in architecture. Sole violation
(synchronous imports) is justified and tracked below.

## Project Structure

### Documentation (this feature)

```text
specs/001-wombat-console/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── rake-task-contracts.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created here)
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── application_controller.rb       # Base; does NOT globally include Authentication
│   ├── tasks_controller.rb             # Public: index (paginated/sortable/filterable)
│   ├── box_scores_controller.rb        # Public: index (paginated/sortable/filterable)
│   ├── sessions_controller.rb          # Login / logout (allow_unauthenticated_access)
│   └── admin/
│       ├── base_controller.rb          # Includes Authentication; shared admin base
│       ├── dashboard_controller.rb     # Admin landing page
│       └── import_logs_controller.rb   # Audit log viewer (index, show)
├── models/
│   ├── task.rb                         # name, uuid (unique), host, start_time, stop_time
│   ├── box_score.rb                    # task_name, task_uuid, population, time_stamp
│   ├── import_log.rb                   # Audit record per import run
│   ├── user.rb                         # has_secure_password (generated by rails g authentication)
│   ├── session.rb                      # Admin session (generated by rails g authentication)
│   └── current.rb                      # ActiveSupport::CurrentAttributes
├── services/
│   └── import_service.rb               # Shared streaming import logic (yajl + upsert_all)
├── views/
│   ├── layouts/
│   │   └── application.html.erb
│   ├── tasks/
│   │   └── index.html.erb              # Table + Pagy nav + filter form
│   ├── box_scores/
│   │   └── index.html.erb              # Table + Pagy nav + filter form
│   ├── sessions/
│   │   └── new.html.erb                # Login form (Tailwind-styled)
│   └── admin/
│       ├── dashboard/
│       │   └── index.html.erb
│       └── import_logs/
│           ├── index.html.erb          # Paginated audit log list
│           └── show.html.erb           # Detail + error_details
├── controllers/concerns/
│   └── authentication.rb               # Generated: require_authentication, session helpers

config/
├── routes.rb                           # RESTful routes + admin namespace
└── initializers/
    └── pagy.rb                         # Pagy defaults (limit: 25, etc.)

db/
├── migrate/
│   ├── YYYYMMDD_create_tasks.rb        # tasks table + uuid unique index
│   ├── YYYYMMDD_create_box_scores.rb   # box_scores table + uuid unique index
│   ├── YYYYMMDD_create_import_logs.rb  # import_logs table
│   ├── YYYYMMDD_create_users.rb        # Generated by rails g authentication
│   └── YYYYMMDD_create_sessions.rb     # Generated by rails g authentication
└── seeds.rb                            # Sample tasks + box_scores for development

lib/
└── tasks/
    └── import.rake                     # import:tasks[filepath], import:box_scores[filepath]

test/
├── models/
│   ├── task_test.rb
│   ├── box_score_test.rb
│   └── import_log_test.rb
├── controllers/
│   ├── tasks_controller_test.rb
│   ├── box_scores_controller_test.rb
│   └── admin/
│       └── import_logs_controller_test.rb
├── integration/
│   └── import_service_test.rb          # Idempotency + partial-success + audit log
└── system/
    ├── task_dashboard_test.rb
    ├── box_score_dashboard_test.rb
    └── admin_auth_test.rb
```

**Structure Decision**: Standard single-project Rails MVC layout. Admin functionality
is namespaced under `admin/` in both controllers and routes. No separate frontend
directory — all views are server-rendered ERB with Tailwind CSS classes. Services
directory added for the shared `ImportService` to keep Rake tasks thin.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| **Principle V**: Synchronous Rake imports instead of background jobs (Sidekiq / Solid Queue) | v1 explicitly scopes out background jobs (spec Assumption §9); operators invoke imports from CLI or cron; no web-triggered imports needed in v1 | Adding a job queue (Sidekiq requires Redis, Solid Queue needs schema migration + worker process) increases operational complexity with no user-facing benefit until imports are triggered from the browser UI — that is a v2 concern |
