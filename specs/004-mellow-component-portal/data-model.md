# Data Model: Mellow Component Portal

Conceptual model derived from `spec.md`.

## Entities

### Component
Represents a contributing Mellow application (Heeler, Hyena, Mastodon, etc.).

**Fields**
- `id` (uuid, PK)
- `component_id` (string, unique, required) — stable identifier used by the component/CLI
- `display_name` (string, required)
- `slug` (string, unique, required)
- `description` (text, optional)
- `ingest_token_digest` (string, required) — hashed bearer token used by the component CLI utility (NEVER store plaintext)
- `token_rotated_at` (timestamp, optional)
- `created_at`, `updated_at`

**Constraints & Indexes**
- Unique index on `component_id`
- Unique index on `slug`
- `ingest_token_digest` MUST be non-null; compare tokens using constant-time comparison (or bcrypt)

---

### ConfigurationSnapshot
Immutable snapshot of a component’s configuration.

**Fields**
- `id` (uuid, PK)
- `component_id` (fk → components.id, required)
- `snapshot_id` (string, required) — idempotency key
- `captured_at` (timestamp, optional)
- `received_at` (timestamp, required)
- `status` (string: accepted|rejected, required)
- `payload` (jsonb, required)
- `error_details` (jsonb/text, optional)

**Constraints & Indexes**
- Unique index on `(component_id, snapshot_id)`
- Index on `(component_id, received_at desc)`
- Optional: partial index on `status = 'rejected'`

---

### CollectionSnapshot
Immutable snapshot of a component’s collection information.

**Fields**
- `id` (uuid, PK)
- `component_id` (fk → components.id, required)
- `snapshot_id` (string, required) — idempotency key
- `captured_at` (timestamp, optional)
- `received_at` (timestamp, required)
- `status` (string: accepted|rejected, required)
- `payload` (jsonb, required)
- `error_details` (jsonb/text, optional)

**Constraints & Indexes**
- Unique index on `(component_id, snapshot_id)`
- Index on `(component_id, received_at desc)`

## Derived UI Queries

- Index overview:
  - list components
  - last config snapshot time per component
  - last collection snapshot time per component
  - staleness flag based on freshness window

- Component details:
  - latest config snapshot + selected fields
  - history list (paginated)

- Component collection:
  - latest collection snapshot + selected fields
  - history list (paginated)

## Notes

- Keep raw payload JSONB for audit/debugging and forward compatibility.
- Extract only minimal summary fields if needed for performance.
