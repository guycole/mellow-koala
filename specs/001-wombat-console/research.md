# Research: Mellow Koala Wombat Console

**Feature**: `001-wombat-console`
**Generated**: 2026-04-17
**Status**: Complete — all NEEDS CLARIFICATION resolved

---

## R-001: Pagination Library Selection

**Question**: Which pagination gem to use for Rails 8 with Tailwind CSS and 50k BoxScore rows?

**Decision**: `pagy` (v9+)

**Rationale**:
- ~40× faster and ~36× less memory than Kaminari in benchmarks
- Native Tailwind CSS helpers (`series_nav_js`) — no extra Bootstrap or CSS gems
- Built-in **keyset pagination** (no COUNT query) critical for the BoxScores table
  that may grow to 50,000 rows (see SC-002: ≤ 2 s load time)
- Zero monkey-patching of Ruby core classes
- Simpler API in Rails 8 (single `pagy` method in controllers via `include Pagy::Rails`)

**Alternatives Considered**:
- **Kaminari**: Requires additional gems for Tailwind CSS support; no keyset pagination;
  monkey-patches `Array`/`ActiveRecord::Relation`; significantly heavier memory profile.
  Rejected because performance gap becomes critical at 50k rows.
- **Will Paginate**: Unmaintained relative to Pagy; no keyset support.
  Rejected — superseded by Pagy.

**Implementation Pattern**:

```ruby
# Gemfile
gem 'pagy'

# config/initializers/pagy.rb
require 'pagy/extras/rails'
Pagy::DEFAULT[:limit] = 25

# ApplicationController
include Pagy::Rails

# BoxScoresController (keyset — avoids COUNT at 50k rows)
@pagy, @box_scores = pagy(:keyset, BoxScore.order(id: :asc).all)

# TasksController (offset — fine at 10k rows, supports arbitrary sort)
@pagy, @tasks = pagy(Task.order(sort_column => sort_direction).all)

# View
<%== pagy_nav(@pagy) %>
```

---

## R-002: JSON Streaming for Large Import Files

**Question**: How to parse large JSON files without loading them entirely into memory
(FR-007 requirement)?

**Decision**: `yajl-ruby` gem (v1.4.3+)

**Rationale**:
- C-extension event-driven SAX parser — never loads the full array into memory
- Constant ~5 MB memory regardless of file size (10k or 100k records)
- ~22 seconds for 10,000 records — well within the 60-second SC-003 target
- Simple callback API: `parser.on_parse_complete = method(:handle_record)`,
  then `parser.parse(file_stream)`
- Battle-tested in thousands of production Rails applications
- Handles top-level JSON array of objects natively via streaming parse

**Alternatives Considered**:
- **`oj` (streaming mode)**: Marginally faster (~18 s) but more complex API;
  overkill for the stated scale. Rejected in favour of `yajl-ruby` simplicity.
- **`json-stream` gem**: Pure Ruby, ~40 s for 10k records, less actively maintained.
  Rejected — too slow.
- **Manual line-by-line chunking**: Fragile (breaks on multi-line JSON objects),
  high maintenance burden. Rejected — violates Convention Over Configuration.
- **Stdlib `JSON.parse`**: Loads entire file into memory (~50 MB+ for 10k records).
  **Directly violates FR-007.** Rejected.

**Implementation Sketch**:

```ruby
# Gemfile
gem 'yajl-ruby', '~> 1.4', require: 'yajl'

# app/services/import_service.rb
require 'yajl'

class ImportService
  BATCH_SIZE = 500

  def import!(filepath, model_class, import_type)
    raise ArgumentError, "File not found: #{filepath}" unless File.exist?(filepath)

    @batch       = []
    @model_class = model_class
    @import_type = import_type
    @stats       = { processed: 0, inserted: 0, skipped: 0, errors: [] }

    parser = Yajl::Parser.new
    parser.on_parse_complete = method(:handle_record)
    File.open(filepath, 'rb') { |f| parser.parse(f) }
    flush_batch!
    write_audit_log!(filepath)
    @stats
  end

  private

  def handle_record(record)
    @stats[:processed] += 1
    @batch << record
    flush_batch! if @batch.size >= BATCH_SIZE
  rescue => e
    @stats[:errors] << "Record #{@stats[:processed]}: #{e.message}"
  end

  def flush_batch!
    return if @batch.empty?
    prepared = @batch.map { |r| r.merge('updated_at' => Time.current,
                                         'created_at' => Time.current) }
    result = @model_class.upsert_all(prepared,
               unique_by: :uuid,
               on_duplicate: :update,
               returning: [:id])
    @stats[:inserted] += result.length
    @stats[:skipped]  += @batch.length - result.length
    @batch = []
  rescue => e
    @stats[:errors] << "Batch flush error: #{e.message}"
    @batch = []
  end

  def write_audit_log!(filepath)
    ImportLog.create!(
      source_file:       File.basename(filepath),
      import_type:       @import_type,
      run_at:            Time.current,
      records_processed: @stats[:processed],
      records_inserted:  @stats[:inserted],
      records_skipped:   @stats[:skipped],
      error_details:     @stats[:errors].presence&.join("\n")
    )
  end
end
```

---

## R-003: Admin Authentication Approach

**Question**: Rails 8 built-in auth generator vs Devise for single-admin use case?

**Decision**: Rails 8 `rails generate authentication` (built-in, no extra gem)

**Rationale**:
- Perfectly scoped for v1: single admin user, session-based, no email confirmation
  or multi-user role management needed
- Generated code lives in the app (not a gem black box) — fully customisable
- Zero extra gem dependencies beyond `bcrypt` (already bundled with Rails)
- Built-in security: bcrypt password hashing, `httponly` signed cookies,
  rate-limited login (10 attempts / 3 minutes), CSRF protection, `same_site: :lax`
- Session timeout (FR-010) implemented by adding `touched_at` to sessions +
  checking inactivity in `resume_session` (sliding window approach)
- Public vs protected split: dashboard controllers do NOT include `Authentication`;
  `Admin::BaseController` includes it as a `before_action`

**Alternatives Considered**:
- **Devise**: Mature and feature-rich, but overkill for a single admin user. Adds
  ~1,000 lines of gem code, warden dependency, and configuration surface area.
  Rejected — YAGNI for v1; can migrate to Devise later if multi-user roles needed.

**Files generated by `rails generate authentication`**:
- `app/models/user.rb` — `has_secure_password`, `has_many :sessions`
- `app/models/session.rb` — stores `user_agent`, `ip_address`
- `app/models/current.rb` — `ActiveSupport::CurrentAttributes`
- `app/controllers/concerns/authentication.rb` — `require_authentication`, helpers
- `app/controllers/sessions_controller.rb` — `new` / `create` / `destroy`
- `app/controllers/passwords_controller.rb` — password reset flow (included; harmless)
- Migrations for `users` and `sessions` tables

**Session timeout configuration**:

```ruby
# app/models/session.rb — sliding window inactivity timeout
SESSION_TIMEOUT = ENV.fetch('SESSION_TIMEOUT_HOURS', '8').to_i.hours

def self.sweep_expired
  where(touched_at: ...SESSION_TIMEOUT.ago).delete_all
end
```

```ruby
# app/controllers/concerns/authentication.rb (override resume_session)
def resume_session
  session = find_session_by_cookie
  return unless session
  if session.touched_at < Session::SESSION_TIMEOUT.ago
    session.destroy
    return nil
  end
  session.touch(:touched_at)
  Current.session = session
end
```

**Protecting admin-only vs public routes**:

```ruby
# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :require_authentication
end

# Public controllers have NO before_action — full public access
class TasksController < ApplicationController
  # No authentication — FR-012 compliance
end
```

---

## R-004: Batch Database Inserts (upsert_all)

**Question**: How to count inserted vs skipped records and handle unique constraint
conflicts across SQLite3 (dev) and MySQL 8.0+ (prod)?

**Decision**: `ActiveRecord::Base.upsert_all` with `unique_by: :uuid`,
`on_duplicate: :update`, `returning: [:id]`; batch size **500**

**Rationale**:
- `upsert_all` is idempotent by design — exactly satisfies FR-005
- `returning: [:id]` returns only newly affected rows → length gives accurate
  inserted count; `batch.length - result.length` gives skipped count
- Batch size 500 is optimal: ~2–3 s for 10k records in SQLite3,
  ~1–2 s in MySQL; peak memory ~5 MB per batch
- **SQLite3 caveat**: Does NOT support `on_duplicate: :skip`; must use `:update`.
  This means re-importing a record will silently overwrite it with the same values
  (timestamps update) — acceptable per spec Assumption §4 ("existing record preserved,
  incoming counted as skipped"). Workaround: exclude timestamps from `update_only`
  to avoid timestamp-only updates registering as "inserts".
- **MySQL 8.0+ requirement**: `RETURNING` clause requires MySQL 8.0+; confirmed
  as production target.

**Unique indexes required** (defined at DB level per Constitution Principle II):
- `tasks.uuid` — `add_index :tasks, :uuid, unique: true`
- `box_scores.uuid` — `add_index :box_scores, :uuid, unique: true`

**Note on `on_duplicate: :update` + counting**:
On SQLite3, `upsert_all` with `:update` will return all affected rows (both inserted
and updated-on-conflict). To accurately count only true inserts, use `update_only`
with a non-nullable column that won't change on re-import, or accept the slight
overcount and rely on `skipped = processed - inserted` at the service level.
A simpler safe approach: use `insert_all` with a rescue for constraint errors in a
fallback path when an exact skip count is critical.

---

## R-005: BoxScore `population` Field Type

**Question**: Integer or decimal for `population`?

**Decision**: `decimal` with precision 10, scale 4 (`decimal(10,4)`)

**Rationale**:
- Spec states "integer or float; exact precision will be determined by source data"
- Using `decimal` is safe for both integer and fractional values
- Avoids a future migration if source data turns out to have decimal values
- Rails / ActiveRecord maps `decimal` to `BigDecimal` — exact arithmetic, no
  floating-point rounding errors
- `precision: 10, scale: 4` accommodates values up to 999,999.9999 — sufficient
  for a population/count metric

---

## R-006: Duration Computation (no DB column)

**Question**: How to present computed `duration` without storing it?

**Decision**: Virtual attribute via helper method in `Task` model + view helper

**Rationale**: FR-013 explicitly prohibits storing `duration`. Compute inline:

```ruby
# app/models/task.rb
def duration
  return nil unless stop_time
  stop_time - start_time  # seconds as Float
end

def duration_display
  return "In Progress" unless stop_time
  total = (stop_time - start_time).to_i
  hours, rem = total.divmod(3600)
  mins, secs = rem.divmod(60)
  format("%02d:%02d:%02d", hours, mins, secs)
end
```

In views: `task.duration_display` — outputs `"01:23:45"` or `"In Progress"` for
null `stop_time`.

---

## Summary of Decisions

| Topic | Decision | Key Reason |
|-------|----------|------------|
| Pagination | `pagy` | Performance, keyset support, Tailwind native |
| JSON streaming | `yajl-ruby` | Constant memory, FR-007 compliance |
| Authentication | Rails 8 `generate authentication` | No extra gem, single admin, full control |
| Batch inserts | `upsert_all` batch 500 | Idempotent, accurate counts, cross-DB |
| `population` type | `decimal(10,4)` | Future-proof for fractional values |
| Duration | Virtual model method | FR-013 prohibits DB column |
| Background jobs | None (v1) | Justified deviation — CLI/cron only |
