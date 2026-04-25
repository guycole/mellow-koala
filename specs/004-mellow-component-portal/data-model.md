# Data Model: Mellow Collector Portal

Conceptual model derived from `spec.md`.

## Entities

### Collector
Represents a contributing Mellow application (Heeler, Hyena, Mastodon, etc.).

**Fields**
- `id` (uuid, PK)
- `collector_id` (string, unique, required) — stable identifier used by the collector/CLI
- `display_name` (string, required)
- `slug` (string, unique, required)
- `description` (text, optional)
- `collection_only` (boolean, default false, required) — if true, collector only submits collection snapshots and has no Details page; only Collection view is exposed in UI and navigation
- `ingest_token_digest` (string, required) — hashed bearer token used by the collector CLI utility (NEVER store plaintext)
- `token_rotated_at` (timestamp, optional)
- `created_at`, `updated_at`

**Constraints & Indexes**
- Unique index on `collector_id`
- Unique index on `slug`
- `ingest_token_digest` MUST be non-null; compare tokens using constant-time comparison (or bcrypt)
- `collection_only` MUST default to true; all collectors are collection-only

**Collection-Only Collector Behavior**:
- When `collection_only = true`: collector only has Collection view; Details page/link MUST NOT be shown
- When `collection_only = false`: collector may have both Details and Collection views
- Examples: Mellow Heeler is a collector (`collection_only = true`)

---

### ConfigurationSnapshot
Immutable snapshot of a collector’s configuration.

**Fields**
- `id` (uuid, PK)
- `collector_id` (fk → collectors.id, required)
- `snapshot_id` (string, required) — idempotency key
- `captured_at` (timestamp, optional)
- `received_at` (timestamp, required)
- `status` (string: accepted|rejected, required)
- `payload` (jsonb, required)
- `error_details` (jsonb/text, optional)

**Constraints & Indexes**
- Unique index on `(collector_id, snapshot_id)`
- Index on `(collector_id, received_at desc)`
- Optional: partial index on `status = 'rejected'`

---

### CollectionSnapshot
Immutable snapshot of a collector’s collection information.

**Fields**
- `id` (uuid, PK)
- `collector_id` (fk → collectors.id, required)
- `snapshot_id` (string, required) — idempotency key
- `captured_at` (timestamp, optional)
- `received_at` (timestamp, required)
- `status` (string: accepted|rejected, required)
- `payload` (jsonb, required)
- `error_details` (jsonb/text, optional)

**Constraints & Indexes**
- Unique index on `(collector_id, snapshot_id)`
- Index on `(collector_id, received_at desc)`

## Derived UI Queries

- Index overview:
  - list collectors
  - last config snapshot time per collector
  - last collection snapshot time per collector
  - staleness flag based on freshness window

- Collector details:
  - latest config snapshot + selected fields
  - history list (paginated)

- Collector collection:
  - latest collection snapshot + selected fields
  - history list (paginated)

## Notes

- Keep raw payload JSONB for audit/debugging and forward compatibility.
- Extract only minimal summary fields if needed for performance.
- **Collection Snapshot Retention**: Collection snapshots are stored with idempotency keys (like configuration snapshots) to prevent duplicate storage on retry. However, the "delete existing collection data" language in FR-030a refers to the *replace semantics* for display purposes: the UI and API treat collection data as "current state only" and show only the most recent snapshot. Historical collection snapshots are retained in the database for audit but are not surfaced in the primary UI views.

---

## Collector-Specific Payload Schemas

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

---

### HyenaAdsbCollectionPayload

Defined by [GitHub Issue #26](https://github.com/guycole/mellow-koala/issues/26).  
Mellow Hyena ADSB reports aviation ADSB beacon observations from a site. The `adsbex` stanza may be empty or absent.

```json
{
  "platform": "rpi4c",
  "project": "hyena-adsb",
  "zTime": 1706505957,
  "version": 1,
  "geoLoc": {
    "site": "anderson1"
  },
  "observation": [
    {
      "flight": "SKW3695",
      "lat": 40.921838,
      "lon": -123.016725,
      "altitude": 33000,
      "track": 178,
      "speed": 439,
      "adsbHex": "a25925"
    }
  ],
  "adsbex": [
    {
      "adsbHex": "a25925",
      "category": "A3",
      "emergency": "none",
      "flight": "SKW3695",
      "registration": "N250SY",
      "model": "E75L",
      "laddFlag": false,
      "militaryFlag": false,
      "piaFlag": false,
      "wierdoFlag": false
    }
  ]
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `platform` | string | Hardware platform (e.g., `rpi4c`) |
| `project` | string | Always `"hyena-adsb"` for Mellow Hyena ADSB payloads |
| `zTime` | integer | Unix timestamp of observation |
| `version` | integer | Payload format version |
| `geoLoc.site` | string | Site/location identifier |
| `observation` | array | List of observed ADSB beacons |
| `observation[].adsbHex` | string | ADSB hex identifier (join key to `adsbex`) |
| `observation[].flight` | string | Flight number/callsign |
| `observation[].lat` | number | Latitude |
| `observation[].lon` | number | Longitude |
| `observation[].altitude` | integer | Altitude in feet |
| `observation[].track` | integer | Track/heading in degrees |
| `observation[].speed` | integer | Speed in knots |
| `adsbex` | array | Enrichment records keyed by `adsbHex`; may be empty |
| `adsbex[].adsbHex` | string | Join key matching `observation[].adsbHex` |
| `adsbex[].registration` | string | Aircraft registration (tail number) |
| `adsbex[].model` | string | Aircraft model (e.g., `E75L`, `A319`) |
| `adsbex[].flight` | string | Flight number |
| `adsbex[].category` | string | ADS-B emitter category |
| `adsbex[].emergency` | string | Emergency state |
| `adsbex[].laddFlag` | boolean | LADD (privacy) flag |
| `adsbex[].militaryFlag` | boolean | Military aircraft flag |
| `adsbex[].piaFlag` | boolean | PIA (privacy) flag |
| `adsbex[].wierdoFlag` | boolean | Anomaly/weirdo flag |

**Display requirements (FR-038–FR-042):**
- Show header: timestamp (`zTime` converted to local time), count of `observation` entries, `platform`, `geoLoc.site`
- Render a table of up to 15 observation rows: adsbHex, registration, model, flight, altitude, track
- For each row, look up `registration` and `model` from `adsbex` by matching `adsbHex`; display "unknown" if no match
- Truncate to 15 entries if more are present

---

### HyenaUatCollectionPayload

Defined by [GitHub Issue #27](https://github.com/guycole/mellow-koala/issues/27).  
Mellow Hyena UAT reports UAT aviation beacon observations from a site. The payload structure is identical to HyenaAdsbCollectionPayload; the `project` field distinguishes it (`"hyena-uat"`). The `adsbex` stanza may be empty or absent.

```json
{
  "platform": "rpi4c",
  "project": "hyena-uat",
  "zTime": 1706505957,
  "version": 1,
  "geoLoc": {
    "site": "anderson1"
  },
  "observation": [
    {
      "flight": "SKW3695",
      "lat": 40.921838,
      "lon": -123.016725,
      "altitude": 33000,
      "track": 178,
      "speed": 439,
      "adsbHex": "a25925"
    }
  ],
  "adsbex": [
    {
      "adsbHex": "a25925",
      "category": "A3",
      "emergency": "none",
      "flight": "SKW3695",
      "registration": "N250SY",
      "model": "E75L",
      "laddFlag": false,
      "militaryFlag": false,
      "piaFlag": false,
      "wierdoFlag": false
    }
  ]
}
```

**Fields:** Same as HyenaAdsbCollectionPayload; only `project` differs (`"hyena-uat"`).

**Display requirements (FR-043–FR-047):**
- Show header: timestamp (`zTime` converted to local time), count of `observation` entries, `platform`, `geoLoc.site`
- Render a table of up to 15 observation rows: adsbHex, registration, model, flight, altitude, track
- For each row, look up `registration` and `model` from `adsbex` by matching `adsbHex`; display "unknown" if no match
- Truncate to 15 entries if more are present

---

### MastodonCollectionPayload

Defined by [GitHub Issue #28](https://github.com/guycole/mellow-koala/issues/28).  
Mellow Mastodon performs energy surveys and reports a peakers count per observation.

```json
{
  "platform": "rpi4c",
  "project": "mastodon",
  "zTime": 1706505957,
  "version": 1,
  "geoLoc": {
    "site": "anderson1"
  },
  "peakers": 1
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `platform` | string | Hardware platform (e.g., `rpi4c`) |
| `project` | string | Always `"mastodon"` for Mellow Mastodon payloads |
| `zTime` | integer | Unix timestamp of observation |
| `version` | integer | Payload format version |
| `geoLoc.site` | string | Site/location identifier |
| `peakers` | integer | Count of energy peaks observed |

**Display requirements (FR-048–FR-050):**
- Show header: timestamp (`zTime` converted to local time), `peakers` count, `platform`, `geoLoc.site`
