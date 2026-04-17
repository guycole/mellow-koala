# Quickstart: Mellow Koala Wombat Console

**Feature**: `001-wombat-console`
**Generated**: 2026-04-17
**Audience**: Developer implementing the feature on branch `001-wombat-console`

---

## Prerequisites

- Ruby 3.x (see `.ruby-version` once app is created)
- Bundler 2.x (`gem install bundler`)
- Node.js 18+ (for Tailwind CSS asset pipeline)
- SQLite3 (development/test)
- MySQL 8.0+ client libraries (for production target; dev uses SQLite3)

---

## 1. Create the Rails 8 Application

If the Rails app does not yet exist in the repo root:

```bash
# From repo root: /home/runner/work/mellow-koala/mellow-koala
rails new . \
  --database=sqlite3 \
  --css=tailwind \
  --skip-action-mailer \
  --skip-action-cable \
  --skip-active-storage \
  --skip-action-text \
  --skip-hotwire
```

> **Note**: `--database=sqlite3` sets up SQLite3 for development/test.
> MySQL configuration is added separately for the production environment.
> `--css=tailwind` installs and configures the `tailwindcss-rails` gem.

---

## 2. Add Required Gems

Edit `Gemfile`:

```ruby
# Pagination
gem 'pagy'

# Streaming JSON parser for import Rake tasks (FR-007)
gem 'yajl-ruby', '~> 1.4', require: 'yajl'

# Production database
group :production do
  gem 'mysql2', '~> 0.5'
end
```

Then install:

```bash
bundle install
```

---

## 3. Generate Authentication

```bash
rails generate authentication
bundle install          # installs bcrypt if not already present
rails db:migrate        # creates users and sessions tables
```

After generation, extend the `Session` model migration to add `touched_at`:

```ruby
# db/migrate/YYYYMMDD_create_sessions.rb — add to the create_table block:
t.datetime :touched_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
```

Then re-run migration if not yet applied, or create a new migration:

```bash
rails generate migration AddTouchedAtToSessions touched_at:datetime
rails db:migrate
```

---

## 4. Create Database Migrations

```bash
# Tasks table
rails generate migration CreateTasks \
  name:string uuid:string:uniq host:string \
  start_time:datetime stop_time:datetime

# BoxScores table
rails generate migration CreateBoxScores \
  task_name:string task_uuid:string uuid:string:uniq \
  "population:decimal{10,4}" time_stamp:datetime

# ImportLogs table
rails generate migration CreateImportLogs \
  source_file:string import_type:string run_at:datetime \
  records_processed:integer records_inserted:integer \
  records_skipped:integer error_details:text

rails db:migrate
```

Add additional indexes after the migration generators:

```ruby
# db/migrate/YYYYMMDD_create_tasks.rb
add_index :tasks, :host
add_index :tasks, :start_time

# db/migrate/YYYYMMDD_create_box_scores.rb
add_index :box_scores, :task_name
# id index already exists as PK

# db/migrate/YYYYMMDD_create_import_logs.rb
add_index :import_logs, :run_at
add_index :import_logs, :import_type
```

---

## 5. Configure Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "tasks#index"

  resources :tasks,      only: [:index]
  resources :box_scores, only: [:index]

  resource  :session,    only: [:new, :create, :destroy]

  namespace :admin do
    root "dashboard#index"
    resources :import_logs, only: [:index, :show]
  end
end
```

---

## 6. Configure Pagy

```ruby
# config/initializers/pagy.rb
require 'pagy/extras/rails'

Pagy::DEFAULT[:limit] = 25        # Records per page (spec Assumption §10)
```

Include in `ApplicationController`:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pagy::Rails
end
```

---

## 7. Configure Production Database (MySQL)

```yaml
# config/database.yml — production section
production:
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  database: <%= ENV["DATABASE_NAME"] %>
  username: <%= ENV["DATABASE_USERNAME"] %>
  password: <%= ENV["DATABASE_PASSWORD"] %>
  host: <%= ENV.fetch("DATABASE_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DATABASE_PORT") { 3306 } %>
```

---

## 8. Set Up Admin User

```bash
# One-time setup (development)
rails console
> User.create!(
    email_address: ENV.fetch('ADMIN_EMAIL', 'admin@example.com'),
    password: ENV.fetch('ADMIN_PASSWORD'),
    password_confirmation: ENV.fetch('ADMIN_PASSWORD')
  )
> exit
```

For production, set `ADMIN_EMAIL` and `ADMIN_PASSWORD` as environment variables
before running this command. **Never hard-code credentials.**

---

## 9. Run the Development Server

```bash
# Start Rails + Tailwind watch in one command (Rails 8 Procfile.dev)
bin/dev

# Or separately:
rails server
bin/rails tailwindcss:watch
```

Visit:
- `http://localhost:3000/` — Task dashboard (public)
- `http://localhost:3000/box_scores` — Box-score dashboard (public)
- `http://localhost:3000/session/new` — Admin login

---

## 10. Run the Test Suite

```bash
# Prepare test database
rails db:test:prepare

# Run all tests (matches CI)
rails test test:system

# Run specific test files
rails test test/models/task_test.rb
rails test test/integration/import_service_test.rb
rails test test/system/admin_auth_test.rb
```

---

## 11. Run Import Rake Tasks

```bash
# Import task records
rails import:tasks[data/sample_tasks.json]

# Import box-score records
rails import:box_scores[data/sample_box_scores.json]

# Re-run same file (idempotent — should show 0 inserted)
rails import:tasks[data/sample_tasks.json]
# Expected output:
#   Processed: N | Inserted: 0 | Skipped: N | Errors: 0
```

---

## 12. Seed Development Data

```bash
rails db:seed
```

The seed file should create ~50 Task records and ~200 BoxScore records to
exercise pagination and filtering during development.

---

## Key Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_NAME` | Prod only | — | MySQL database name |
| `DATABASE_USERNAME` | Prod only | — | MySQL username |
| `DATABASE_PASSWORD` | Prod only | — | MySQL password |
| `DATABASE_HOST` | Prod only | `localhost` | MySQL host |
| `DATABASE_PORT` | Prod only | `3306` | MySQL port |
| `ADMIN_EMAIL` | Setup | `admin@example.com` | Admin user email |
| `ADMIN_PASSWORD` | Setup | — | Admin user password (min 12 chars) |
| `SESSION_TIMEOUT_HOURS` | Optional | `8` | Admin session inactivity timeout |
| `RAILS_ENV` | Optional | `development` | Rails environment |
| `SECRET_KEY_BASE` | Prod | — | Rails secret key (auto-generated in dev) |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `ArgumentError: No unique index found for uuid` in upsert_all | Run `rails db:migrate` — unique indexes must exist before imports |
| `Sqlite3Adapter does not support skipping duplicates` | Use `on_duplicate: :update` (not `:skip`) in upsert_all — already specified in ImportService |
| Login redirects loop | Check `touched_at` column exists on `sessions` table; run `rails db:migrate` |
| Tailwind classes not applying | Run `bin/rails tailwindcss:build` or use `bin/dev` |
| `yajl` gem not found | Run `bundle install`; confirm `require: 'yajl'` in Gemfile |
