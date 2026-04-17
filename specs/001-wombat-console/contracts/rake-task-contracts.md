# Rake Task Contracts: Mellow Koala Wombat Console

**Feature**: `001-wombat-console`
**Generated**: 2026-04-17
**Scope**: Public interfaces exposed by this application — Rake import tasks
and HTTP routes.

---

## 1. Rake Task Contracts

The Wombat Console exposes two Rake tasks as its primary programmatic interface
for data ingestion. These are invoked by operators and scheduled jobs (cron).

---

### `import:tasks[filepath]`

**Purpose**: Import task execution records from a JSON file into the `tasks` table.

**Invocation**:
```bash
rails import:tasks[/path/to/tasks.json]
# or
bundle exec rake import:tasks[/path/to/tasks.json]
```

**Input Contract**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `filepath` | String (absolute or relative path) | YES | Path to a JSON file containing an array of task record objects |

**JSON Input Format**:
```json
[
  {
    "uuid":       "550e8400-e29b-41d4-a716-446655440000",
    "name":       "weather_import",
    "host":       "worker-01.example.com",
    "start_time": "2024-01-15T08:30:00Z",
    "stop_time":  "2024-01-15T08:30:45Z"
  },
  {
    "uuid":       "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
    "name":       "data_sync",
    "host":       "worker-02.example.com",
    "start_time": "2024-01-15T09:00:00Z",
    "stop_time":  null
  }
]
```

**Required JSON Fields per record**:

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `uuid` | string | NO | Unique identifier; deduplication key |
| `name` | string | NO | Job/task name |
| `host` | string | NO | Hostname of executing machine |
| `start_time` | ISO 8601 datetime string | NO | Task start timestamp |
| `stop_time` | ISO 8601 datetime string | YES | null = still running |

**Output Contract (stdout)**:
```
Imported tasks from /path/to/tasks.json
  Processed:  10000
  Inserted:   9995
  Skipped:    5
  Errors:     0
```

**Exit Codes**:

| Code | Meaning |
|------|---------|
| `0` | Import completed (even if some records were skipped as duplicates) |
| `1` | Import failed: file not found, unreadable JSON structure, or fatal error |

**Side Effects**:
- Inserts new records into `tasks` table (upsert — existing `uuid` matches are skipped)
- Creates one `ImportLog` record with `import_type: "tasks"` regardless of outcome

**Idempotency**: Running the same command twice with the same file produces
`Inserted: 0, Skipped: N` on the second run. No duplicate records created. ✅

**Error Handling**:
- File not found → error printed to stdout; `exit 1`; no ImportLog created
- Individual malformed record → error logged to `ImportLog.error_details`; import continues
- Entire JSON structure invalid → error printed; `exit 1`
- Empty array `[]` → completes with `Processed: 0`; `exit 0`

---

### `import:box_scores[filepath]`

**Purpose**: Import box-score metric records from a JSON file into the `box_scores` table.

**Invocation**:
```bash
rails import:box_scores[/path/to/box_scores.json]
# or
bundle exec rake import:box_scores[/path/to/box_scores.json]
```

**Input Contract**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `filepath` | String | YES | Path to a JSON file containing an array of box-score record objects |

**JSON Input Format**:
```json
[
  {
    "uuid":       "7c9e6679-7425-40de-944b-e07fc1f90ae7",
    "task_name":  "weather_import",
    "task_uuid":  "550e8400-e29b-41d4-a716-446655440000",
    "population": 1523,
    "time_stamp": "2024-01-15T08:30:45Z"
  },
  {
    "uuid":       "a87ff679-a2f3-451d-ba9f-d79a72c6c5d1",
    "task_name":  "data_sync",
    "task_uuid":  "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
    "population": 0.75,
    "time_stamp": "2024-01-15T09:05:00Z"
  }
]
```

**Required JSON Fields per record**:

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `uuid` | string | NO | Unique identifier; deduplication key |
| `task_name` | string | NO | Name of the associated task |
| `task_uuid` | string | NO | UUID of the associated task (informational; no FK) |
| `population` | number (integer or decimal) | NO | Metric value ≥ 0 |
| `time_stamp` | ISO 8601 datetime string | NO | Metric snapshot timestamp |

**Output Contract (stdout)**: Same format as `import:tasks`.

**Exit Codes**: Same as `import:tasks`.

**Idempotency**: Same guarantee as `import:tasks`. ✅

---

## 2. HTTP Route Contracts

These are the URL routes exposed to browsers. Public routes require no authentication;
admin routes require a valid session cookie.

### Public Routes (no authentication required — FR-012)

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/` | `tasks#index` | Redirects to `/tasks` (root) |
| GET | `/tasks` | `tasks#index` | Paginated, sortable task dashboard |
| GET | `/box_scores` | `box_scores#index` | Paginated, sortable box-score dashboard |

**Query Parameters — `/tasks`**:

| Param | Type | Description |
|-------|------|-------------|
| `page` | integer | Page number (default: 1) |
| `sort` | string | Column to sort by: `name`, `host`, `start_time`, `stop_time` |
| `direction` | string | Sort direction: `asc` or `desc` |
| `host` | string | Filter by exact or partial hostname |
| `start_from` | date | Filter tasks with `start_time` ≥ this date (YYYY-MM-DD) |
| `start_to` | date | Filter tasks with `start_time` ≤ this date (YYYY-MM-DD) |

**Query Parameters — `/box_scores`**:

| Param | Type | Description |
|-------|------|-------------|
| `page` | integer | Page number (default: 1) |
| `sort` | string | Column: `task_name`, `task_uuid`, `population`, `time_stamp` |
| `direction` | string | `asc` or `desc` |
| `task_name` | string | Filter by task name (partial match) |

### Session Routes (authentication — no session required)

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/session/new` | `sessions#new` | Login form |
| POST | `/session` | `sessions#create` | Submit credentials |
| DELETE | `/session` | `sessions#destroy` | Log out |

### Admin Routes (session authentication required — FR-008)

| Method | Path | Controller#Action | Description |
|--------|------|-------------------|-------------|
| GET | `/admin` | `admin/dashboard#index` | Admin landing page |
| GET | `/admin/import_logs` | `admin/import_logs#index` | Paginated audit log list |
| GET | `/admin/import_logs/:id` | `admin/import_logs#show` | Single import log detail |

**Authentication enforcement**: All `admin/*` routes use `Admin::BaseController`
which includes the `Authentication` concern and runs `before_action :require_authentication`.
Unauthenticated requests are redirected to `GET /session/new` (FR-008).

---

## 3. JSON Import File Constraints

| Constraint | Value | Source |
|------------|-------|--------|
| Top-level structure | JSON array `[...]` | spec Assumption §2 |
| Record field names | Match model attribute names exactly (snake_case) | spec Assumption §2 |
| Datetime format | ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) | Standard |
| UUID format | Any unique string (UUID v4 recommended) | spec Key Entities |
| Deduplication key | `uuid` field | spec Assumption §3 |
| File encoding | UTF-8 | yajl-ruby default |
| Min file size | 0 bytes (empty array `[]` is valid) | spec Edge Cases |
| Max recommended file size | No hard limit; tested to 10k records ≈ ~5 MB | SC-003 |

---

## 4. Contract Stability Notes

- The Rake task argument interface (`import:tasks[filepath]`) is **stable** — changing
  it would require operator documentation and cron job updates.
- The JSON field names are **stable** — they map directly to column names and changing
  them would break existing import files from other Mellow projects.
- The HTTP routes are **internal** (admin console, trusted network) — no versioning
  scheme required for v1.
- The `uuid` deduplication contract is **stable** — it is the guarantee operators
  rely on for idempotent re-imports.
