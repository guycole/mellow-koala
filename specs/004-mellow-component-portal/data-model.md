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
- `is_collector` (boolean, default false, required) — if true, component only submits collection snapshots and has no Details page; only Collection view is exposed in UI and navigation
- `ingest_token_digest` (string, required) — hashed bearer token used by the component CLI utility (NEVER store plaintext)
- `token_rotated_at` (timestamp, optional)
- `created_at`, `updated_at`

**Constraints & Indexes**
- Unique index on `component_id`
- Unique index on `slug`
- `ingest_token_digest` MUST be non-null; compare tokens using constant-time comparison (or bcrypt)
- `is_collector` MUST default to false; used by routing and navigation to hide Details link/page for collector components

**Collector Component Behavior**:
- When `is_collector = true`: component only has Collection view; Details page/link MUST NOT be shown
- When `is_collector = false`: component may have both Details and Collection views
- Examples: Mellow Heeler is a collector (`is_collector = true`)

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
- **Collection Snapshot Retention**: Collection snapshots are stored with idempotency keys (like configuration snapshots) to prevent duplicate storage on retry. However, the "delete existing collection data" language in FR-030a refers to the *replace semantics* for display purposes: the UI and API treat collection data as "current state only" and show only the most recent snapshot. Historical collection snapshots are retained in the database for audit but are not surfaced in the primary UI views.

---

## Component-Specific Payload Schemas

### HeelerCollectionPayload

Defined by [GitHub Issue #25](https://github.com/guycole/mellow-koala/issues/25).  
Mellow Heeler reports WiFi AP beacon observations from a site.

```json
{
  "geoLoc": {
    "site": "anderson1"
  },
  "platform": "rpi3c",
  "project": "heeler",
  "version": 1,
  "wifi": [
    {
      "bssid": "00:22:6b:81:03:d9",
      "capability": "unknown",
      "frequency_mhz": 2437,
      "signal_dbm": -86,
      "ssid": "braingang2"
    }
  ],
  "zTime": 1742095222
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `geoLoc.site` | string | Site/location identifier |
| `platform` | string | Hardware platform (e.g., `rpi3c`) |
| `project` | string | Always `"heeler"` for Mellow Heeler payloads |
| `version` | integer | Payload format version |
| `wifi` | array | List of observed WiFi AP beacons |
| `wifi[].ssid` | string | Network name |
| `wifi[].bssid` | string | AP MAC address |
| `wifi[].frequency_mhz` | integer | Radio frequency in MHz |
| `wifi[].signal_dbm` | integer | Signal strength in dBm (negative) |
| `wifi[].capability` | string | AP capability string (may be `"unknown"`) |
| `zTime` | integer | Unix timestamp of observation |

**Display requirements (FR-033–FR-036):**
- Show timestamp of most recent observation (`zTime` converted to local time)
- Show count of `wifi` entries in the last observation
- Render a table of up to 15 AP rows: SSID, BSSID, frequency (MHz), signal (dBm)
- Truncate to 15 entries if more are present
