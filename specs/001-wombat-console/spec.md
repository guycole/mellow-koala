# Feature Specification: Mellow Koala Wombat Console

**Feature Branch**: `001-wombat-console`  
**Created**: 2026-04-17  
**Status**: Draft  
**Input**: User description: "Build the Mellow Koala wombat console — a Rails 8 web application using MySQL and Tailwind CSS that: (1) displays task execution records and box-score metrics imported from other Mellow projects, with a dashboard showing task monitoring (name, uuid, host, start_time, stop_time, duration) and box-score display (task_name, task_uuid, population, time_stamp); (2) provides Rake task import utilities to import task and box-score data from JSON files with idempotent, auditable, batch-capable processing; (3) includes basic admin authentication to protect write/admin endpoints. The existing data model has `tasks` (name, uuid, host, start_time, stop_time) and `box_scores` (task_name, task_uuid, population, time_stamp). Use SQLite3 for development/test since MySQL is for production."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Task Dashboard (Priority: P1)

An operator visits the wombat console to review recent task executions imported from other Mellow projects. They see a paginated list of all tasks with name, UUID, host, start time, stop time, and calculated duration displayed clearly. They can sort by any column and filter by host name or date range to narrow down the records they care about.

**Why this priority**: The dashboard is the primary reason the console exists. Without it, no value is delivered. Every other feature supports this one.

**Independent Test**: Navigate to `/tasks`; a table loads with the six required columns, rows appear for all seeded task records, duration is computed and shown for each row, and pagination controls navigate between pages of results.

**Acceptance Scenarios**:

1. **Given** the console contains imported task records, **When** an operator opens the tasks dashboard, **Then** all tasks are listed with name, UUID, host, start_time, stop_time, and duration visible in a table.
2. **Given** a task list with more than one page of results, **When** the operator clicks "Next Page", **Then** the next set of records loads without a full page reload that loses scroll position.
3. **Given** tasks from multiple hosts, **When** the operator filters by a specific host, **Then** only tasks whose host matches the filter are shown.
4. **Given** tasks across multiple days, **When** the operator filters by a date range, **Then** only tasks that started within that range appear.
5. **Given** the task list, **When** no records exist yet, **Then** the page shows a clear "No tasks found" empty state message rather than an error.

---

### User Story 2 — Box-Score Dashboard (Priority: P1)

An operator needs to review box-score metrics associated with task runs. They navigate to the box-scores section and see a paginated, sortable table showing task_name, task_uuid, population, and time_stamp for every imported box-score record. They can search or filter by task name to view metrics for a specific job family.

**Why this priority**: Box-scores are one of the two core data types the console aggregates; displaying them is equal in importance to tasks.

**Independent Test**: Navigate to `/box_scores`; a table loads with the four required columns, seeded data appears, and filtering by task_name narrows results correctly.

**Acceptance Scenarios**:

1. **Given** imported box-score records exist, **When** an operator opens the box-scores page, **Then** all records are shown with task_name, task_uuid, population, and time_stamp columns.
2. **Given** a box-score list, **When** the operator filters by a task name, **Then** only matching records are shown.
3. **Given** no box-score records, **When** an operator opens the box-scores page, **Then** an empty-state message is displayed.

---

### User Story 3 — JSON Import via Rake Task (Priority: P2)

A developer or scheduled job runs a Rake task pointing at a JSON file of task records (or box-score records). The import processes every record, skips duplicates based on UUID, records an audit log entry for each batch run, and reports how many records were inserted versus skipped. Re-running the same file produces zero new inserts and zero errors.

**Why this priority**: Import utilities are the data entry point. Without them the dashboard has no data, but the display story can be developed and demonstrated with seed data first.

**Independent Test**: Run `rails import:tasks[path/to/tasks.json]`; records appear in the database. Run the same command again; no duplicate records are created and the command exits cleanly with a "0 inserted, N skipped" summary.

**Acceptance Scenarios**:

1. **Given** a valid tasks JSON file, **When** `rails import:tasks[file]` is run, **Then** all records in the file are inserted and a success summary is printed.
2. **Given** the same tasks JSON file is imported twice, **When** the second import runs, **Then** no duplicate records are created (idempotency via uuid uniqueness).
3. **Given** a valid box-scores JSON file, **When** `rails import:box_scores[file]` is run, **Then** all records are inserted and a success summary is printed.
4. **Given** an import run of any type, **When** it completes, **Then** an audit log entry is created recording file name, timestamp, records processed, records inserted, and records skipped.
5. **Given** a JSON file with some valid and some malformed records, **When** the import runs, **Then** valid records are inserted, malformed records are skipped with an error logged per record, and the batch does not abort entirely.
6. **Given** a non-existent file path, **When** the import rake task is run, **Then** a clear error message is printed and the task exits with a non-zero status code.

---

### User Story 4 — Admin Authentication (Priority: P2)

An admin user logs in with a username and password to access write and admin endpoints. Unauthenticated users who attempt to reach admin-only pages are redirected to a login form. After authenticating successfully the admin can manage the system (e.g., view audit logs, trigger actions). Logging out ends the session immediately.

**Why this priority**: Security is required before the console is deployed, but authentication can be added after P1 display stories are functionally complete.

**Independent Test**: Visit an admin-only path without a session; browser redirects to the login page. Submit correct credentials; admin page loads. Click logout; revisiting the admin path redirects back to login.

**Acceptance Scenarios**:

1. **Given** an unauthenticated user, **When** they visit any admin-protected URL, **Then** they are redirected to the login page.
2. **Given** the login page, **When** valid credentials are submitted, **Then** the user is authenticated and redirected to the intended admin page.
3. **Given** the login page, **When** invalid credentials are submitted, **Then** an error message is shown and the user remains on the login page.
4. **Given** an authenticated admin, **When** they click "Log Out", **Then** their session is invalidated and subsequent admin requests redirect to the login page.
5. **Given** a read-only dashboard page, **When** visited by an unauthenticated user, **Then** it loads without requiring authentication.

---

### User Story 5 — Audit Log Viewer (Priority: P3)

An admin reviews import audit logs from within the console. They navigate to the audit log section (admin-protected) and see a chronological list of import runs showing file name, run time, counts of processed/inserted/skipped records, and any errors encountered. This gives visibility into data ingestion history without needing database access.

**Why this priority**: Useful for operations but the console functions without it; can be delivered after core display and import features.

**Independent Test**: After running at least one import, navigate to `/admin/import_logs`; entries appear for each import run with all required fields visible.

**Acceptance Scenarios**:

1. **Given** one or more completed imports, **When** an admin opens the audit log viewer, **Then** each import run appears with file name, timestamp, processed, inserted, and skipped counts.
2. **Given** an import that encountered record-level errors, **When** the admin views that log entry, **Then** the error details for individual records are accessible.

---

### Edge Cases

- What happens when a JSON import file is empty (`[]`)? The task should complete with "0 records processed" and exit cleanly.
- What happens when a task record's `stop_time` is null (task still running)? Duration should display as "In Progress" or "—" rather than erroring.
- What happens when two concurrent import processes run against the same file? The unique constraint on `uuid` should prevent duplicates; both processes may complete without error.
- What happens when a JSON file contains a UUID that already exists but with different field values? The existing record is preserved (no update); the incoming record is counted as skipped, with a log note.
- What happens when the tasks table has no `duration` column? Duration is computed in the application layer from `stop_time - start_time` and never stored.
- What happens when pagination is requested beyond the last page? An empty set is returned gracefully without a 500 error.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display all task records in a paginated, sortable table showing name, uuid, host, start_time, stop_time, and computed duration.
- **FR-002**: The system MUST display all box-score records in a paginated, sortable table showing task_name, task_uuid, population, and time_stamp.
- **FR-003**: The system MUST provide a Rake task `import:tasks[filepath]` that reads a JSON file and inserts task records into the database.
- **FR-004**: The system MUST provide a Rake task `import:box_scores[filepath]` that reads a JSON file and inserts box-score records into the database.
- **FR-005**: Both import Rake tasks MUST be idempotent: re-importing the same file MUST NOT create duplicate records (deduplication by uuid).
- **FR-006**: Both import Rake tasks MUST write an audit log entry per import run recording file name, run timestamp, records processed, records inserted, and records skipped.
- **FR-007**: Import Rake tasks MUST support batch processing and MUST NOT load entire JSON files into memory when files are large (stream or chunk processing preferred).
- **FR-008**: The system MUST protect all admin and write endpoints behind HTTP session-based authentication.
- **FR-009**: The system MUST provide a login page where an admin can authenticate with a username and password.
- **FR-010**: Authenticated admin sessions MUST expire after a configurable inactivity period (default: 8 hours).
- **FR-011**: The system MUST provide a logout action that immediately invalidates the admin session.
- **FR-012**: Read-only dashboard pages (tasks list, box-scores list) MUST be accessible without authentication.
- **FR-013**: Duration MUST be computed from `stop_time - start_time` in the application layer; tasks with a null `stop_time` MUST display a visual "In Progress" indicator instead of a duration.
- **FR-014**: The system MUST use SQLite3 in development and test environments and MySQL in production.
- **FR-015**: The system MUST apply Tailwind CSS for all UI styling; no other CSS frameworks should be added.
- **FR-016**: An admin MUST be able to view the import audit log at a protected admin route.
- **FR-017**: Import Rake tasks MUST print a human-readable summary upon completion: total processed, inserted, skipped, and error count.
- **FR-018**: Import Rake tasks MUST handle individual malformed or invalid records by logging the error and continuing with the remaining records (partial-success pattern).

### Key Entities

- **Task**: Represents a single execution of a named job from a Mellow project. Attributes: `name` (string), `uuid` (string, unique), `host` (string), `start_time` (datetime), `stop_time` (datetime, nullable). Duration is derived.
- **BoxScore**: Represents an aggregated metric snapshot for a task run. Attributes: `task_name` (string), `task_uuid` (string), `population` (integer or decimal), `time_stamp` (datetime).
- **ImportLog**: Audit record for a single import run. Attributes: `source_file` (string), `import_type` (enum: tasks | box_scores), `run_at` (datetime), `records_processed` (integer), `records_inserted` (integer), `records_skipped` (integer), `error_details` (text, nullable).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An operator can load the task dashboard and see all task records within 2 seconds for datasets up to 10,000 records.
- **SC-002**: An operator can load the box-score dashboard and see all box-score records within 2 seconds for datasets up to 50,000 records.
- **SC-003**: Running the import Rake task with a 10,000-record JSON file completes without error in under 60 seconds.
- **SC-004**: Re-importing any previously imported file produces zero new database records and exits without errors, 100% of the time.
- **SC-005**: An unauthenticated user is redirected to the login page within one HTTP response cycle when accessing any admin-protected URL.
- **SC-006**: After a successful login, admin users can access protected pages without re-authenticating for the duration of their session.
- **SC-007**: Every import run produces a corresponding audit log entry with correct counts, verifiable against the source data.
- **SC-008**: The application boots and all tests pass in both SQLite3 (development) and MySQL (production-equivalent CI) configurations.
- **SC-009**: All critical user journeys (task dashboard, box-score dashboard, import run, admin login/logout) are covered by automated tests.

---

## Assumptions

- Admin credentials will be set via environment variables or a database-backed admin user record; a single hard-coded admin account is acceptable for v1 (can be expanded later).
- JSON import file format uses an array of objects at the top level, where each object's keys map directly to the model attribute names (e.g., `[{"uuid": "...", "name": "...", ...}]`).
- The `uuid` field in both `tasks` and `box_scores` is treated as the natural deduplication key for idempotent imports.
- The `duration` column does not exist in the database schema; it is always computed in the application as `stop_time - start_time`.
- Box-score records are not required to have a matching task record (no enforced foreign key at the database level for v1); `task_uuid` is informational.
- The dashboard pages are intentionally public (read-only) — the project operates in a trusted internal network context, and public read access is acceptable.
- Tailwind CSS is already configured in the Rails 8 asset pipeline; no additional CSS toolchain setup is required beyond the standard Rails 8 + Tailwind generator.
- Mobile responsiveness is a nice-to-have; the primary audience uses desktop browsers.
- Background jobs are out of scope for import processing in v1; imports run synchronously via Rake tasks invoked from the command line or a cron job.
- The `population` field in `box_scores` stores a numeric value (integer or float); the exact precision will be determined by the source data during implementation.
- Pagination uses a default page size of 25 records per page; this is configurable at the application level.
