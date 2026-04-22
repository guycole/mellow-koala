# Feature Specification: Mellow Collector Portal

**Feature Branch**: `004-mellow-collector-portal`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: User description: "Mellow Koala is a web application which provides information about other Mellow collectors such as Mellow Heeler, Mellow Hyena-ADSB, Mellow Mastodon, etc. Each collector can share configuration and collection information. The index page will provide an overview of available collection tasking. There will be a navigation bar on the left side to navigate for collector details and collection information. There will also be a carousel mode which cycles through the collector pages. Collectors will update their information via dedicated command line utilities to a Mellow Koala API."

## Technical Environment

**Platform**: Docker containers on ARM64 Linux (64-bit ARM embedded systems with generous resources)  
**Database**: PostgreSQL 15+  
**Monitoring**: Prometheus (metrics), Elasticsearch (structured logs)  
**Network**: Air-gapped capable (no external internet dependencies)  
**Deployment**: Potentially offline/isolated networks; all dependencies must be bundleable

## User Scenarios & Testing *(mandatory)*

### User Story 1 - CLI Import of Collector Configuration & Collection Info (Priority: P1)

As a Mellow collector maintainer, I want a dedicated CLI utility to import my collector’s data from a JSON file into the Mellow Koala API so the portal always shows the freshest values.

**Why this priority**: Without ingestion, the portal has nothing to display.

**Note**: Each collection-only collector has a dedicated import utility that reads a JSON file. On import, existing collection data for that collector is deleted and replaced with the new values. Only the freshest snapshot is retained.

**Independent Test**: Import a collection JSON file; verify only the new data is visible in the UI (prior data is gone).

**Acceptance Scenarios (BDD)**:

1. **Given** a collector identifier exists and the CLI is authenticated for that collector, **When** the CLI imports a valid collection JSON file, **Then** the API deletes existing collection data for that collector and stores the new values
2. **Given** a collector identifier exists and the CLI is authenticated for that collector, **When** the CLI imports a valid configuration payload, **Then** the API accepts it and stores a new configuration snapshot
3. **Given** the CLI uploads an invalid payload, **When** the API processes it, **Then** the API rejects it with actionable validation errors and does NOT delete existing data
4. **Given** the CLI retries the same import, **When** the API receives it again, **Then** it replaces the existing collection data with the same values (idempotent result)
5. **Given** the CLI is missing authentication, **When** it imports a snapshot, **Then** the API rejects the request with 401 Unauthorized
6. **Given** the CLI provides invalid authentication, **When** it imports a snapshot, **Then** the API rejects the request with 403 Forbidden
7. **Given** the CLI is authenticated for collector A, **When** it attempts to upload to collector B’s endpoint, **Then** the API rejects the request with 403 Forbidden

---

### User Story 2 - Index Overview of Collector Tasking (Priority: P1)

As an operator, I want the index page to show an overview of tasking for all known Mellow collectors so I can quickly understand what work is being done and whether it is fresh.

**Why this priority**: It is the primary operator view and a fast way to spot problems.

**Independent Test**: Create 2 collectors with configuration snapshots, visit `/`, verify the overview reflects their latest configuration timestamps and key fields.

**Acceptance Scenarios (BDD)**:

1. **Given** no collectors have reported configuration, **When** I visit the index page, **Then** I see an empty state indicating no collectors are available
2. **Given** collectors have reported configuration, **When** I visit the index page, **Then** I see a row/card per collector with its name and last-updated timestamp
3. **Given** a collector has stale configuration (older than a defined freshness window), **When** I visit the index page, **Then** that collector is visually marked as stale

---

### User Story 3 - Collector Detail & Collection Information Pages (Priority: P2)

As an operator, I want to view a collector’s applicable pages so I can inspect its configuration or collection data.

**Why this priority**: The index is summary-only; operators need drill-down.

**Note**: Not all collectors have a Details page. Collector collectors expose Collection only. Only collectors that submit configuration snapshots have a Details page.

**Independent Test**: Navigate to a non-collection-only collector and verify it shows the latest configuration snapshot; navigate to a collection-only collector and verify only the collection view is available.

**Acceptance Scenarios (BDD)**:

1. **Given** a non-collection-only collector exists, **When** I navigate to that collector’s detail page, **Then** I see the latest configuration snapshot
2. **Given** a collector has collection information, **When** I open the collection view, **Then** I see recent collection summaries/items with timestamps
3. **Given** a collector has never reported collection information, **When** I open the collection view, **Then** I see an empty state explaining no data is available yet
4. **Given** a collection-only collector exists, **When** I attempt to navigate to its detail page, **Then** I am redirected to or shown only the collection view
---

### User Story 6 - Mellow Heeler Collection View (Priority: P2)

As an operator, I want to see Mellow Heeler’s latest WiFi AP beacon observations so I can monitor wireless network activity at each site.

**Source**: [GitHub Issue #25 — mellow heeler collector](https://github.com/guycole/mellow-koala/issues/25)

**Why this priority**: Heeler is the first concrete collector with a defined payload schema and display requirements.

**Note**: Mellow Heeler is a collection-only collector and exposes the **Collection view only**. Collection-only collectors do not have a Details (configuration snapshot) page.

**Independent Test**: Upload a Heeler collection snapshot; navigate to Heeler’s collection page; verify timestamp, AP count, and the AP table are rendered correctly.

**Acceptance Scenarios (BDD)**:

1. **Given** a Heeler collection snapshot has been received, **When** I view the Heeler collection page, **Then** I see the timestamp of the most recent observation
2. **Given** a Heeler collection snapshot has been received, **When** I view the Heeler collection page, **Then** I see the count of WiFi AP beacons in the last observation
3. **Given** a Heeler collection snapshot has been received, **When** I view the Heeler collection page, **Then** I see a table of up to 15 AP beacons with columns: SSID, BSSID, frequency (MHz), signal strength (dBm)
4. **Given** a Heeler snapshot has more than 15 AP beacons, **When** I view the collection page, **Then** only the first 15 are displayed
5. **Given** no Heeler collection data has been received, **When** I view the Heeler collection page, **Then** I see an empty state message

---

### User Story 7 - Mellow Hyena ADSB Collection View (Priority: P2)

As an operator, I want to see Mellow Hyena's latest ADSB aviation observations so I can monitor air traffic activity at each site.

**Source**: [GitHub Issue #26 — mellow hyena adsb collector](https://github.com/guycole/mellow-koala/issues/26)

**Why this priority**: Hyena ADSB is the second concrete collector with a defined payload schema and display requirements.

**Note**: Mellow Hyena ADSB is a collection-only collector and exposes the **Collection view only**. It does not have a Details (configuration snapshot) page.

**Independent Test**: Upload a Hyena ADSB collection snapshot; navigate to Hyena ADSB's collection page; verify the header (timestamp, beacon count, platform, site) and the observation table render correctly, with registration/model resolved from the adsbex stanza (or "unknown" when absent).

**Acceptance Scenarios (BDD)**:

1. **Given** a Hyena ADSB collection snapshot has been received, **When** I view the Hyena ADSB collection page, **Then** I see a header with the timestamp of the last observation, the quantity of ADSB beacons, the collection platform, and the site name
2. **Given** a Hyena ADSB collection snapshot has been received, **When** I view the Hyena ADSB collection page, **Then** I see a table of up to 15 ADSB observations with columns: adsbHex, registration, model, flight, altitude, track
3. **Given** an observation's `adsbHex` has a matching entry in the `adsbex` stanza, **When** the table renders, **Then** registration and model are displayed from that entry
4. **Given** an observation's `adsbHex` has no matching entry in the `adsbex` stanza, **When** the table renders, **Then** registration and model display as "unknown"
5. **Given** a Hyena ADSB snapshot has more than 15 observations, **When** I view the collection page, **Then** only the first 15 are displayed
6. **Given** no Hyena ADSB collection data has been received, **When** I view the Hyena ADSB collection page, **Then** I see an empty state message

---

### User Story 8 - Mellow Hyena UAT Collection View (Priority: P2)

As an operator, I want to see Mellow Hyena's latest UAT aviation observations so I can monitor UAT-equipped air traffic activity at each site.

**Source**: [GitHub Issue #27 — mellow hyena uat collector](https://github.com/guycole/mellow-koala/issues/27)

**Why this priority**: Hyena UAT is the UAT counterpart to Hyena ADSB; it shares the same payload structure and display requirements with a distinct project identifier.

**Note**: Mellow Hyena UAT is a collection-only collector and exposes the **Collection view only**. It does not have a Details (configuration snapshot) page.

**Independent Test**: Upload a Hyena UAT collection snapshot; navigate to Hyena UAT's collection page; verify the header (timestamp, beacon count, platform, site) and the observation table render correctly, with registration/model resolved from the adsbex stanza (or "unknown" when absent).

**Acceptance Scenarios (BDD)**:

1. **Given** a Hyena UAT collection snapshot has been received, **When** I view the Hyena UAT collection page, **Then** I see a header with the timestamp of the last observation, the quantity of beacons, the collection platform, and the site name
2. **Given** a Hyena UAT collection snapshot has been received, **When** I view the Hyena UAT collection page, **Then** I see a table of up to 15 observations with columns: adsbHex, registration, model, flight, altitude, track
3. **Given** an observation's `adsbHex` has a matching entry in the `adsbex` stanza, **When** the table renders, **Then** registration and model are displayed from that entry
4. **Given** an observation's `adsbHex` has no matching entry in the `adsbex` stanza, **When** the table renders, **Then** registration and model display as "unknown"
5. **Given** a Hyena UAT snapshot has more than 15 observations, **When** I view the collection page, **Then** only the first 15 are displayed
6. **Given** no Hyena UAT collection data has been received, **When** I view the Hyena UAT collection page, **Then** I see an empty state message

---

### User Story 9 - Mellow Mastodon Collection View (Priority: P2)

As an operator, I want to see Mellow Mastodon's latest energy survey results so I can monitor energy activity at each site.

**Source**: [GitHub Issue #28 — mellow mastodon collector](https://github.com/guycole/mellow-koala/issues/28)

**Why this priority**: Mastodon is a distinct collector with its own simple payload and display requirements.

**Note**: Mellow Mastodon is a collection-only collector and exposes the **Collection view only**. It does not have a Details (configuration snapshot) page.

**Independent Test**: Upload a Mastodon collection snapshot; navigate to Mastodon's collection page; verify the header (timestamp, peakers count, platform, site) renders correctly.

**Acceptance Scenarios (BDD)**:

1. **Given** a Mastodon collection snapshot has been received, **When** I view the Mastodon collection page, **Then** I see a header with the timestamp of the last observation, the peakers count, the collection platform, and the site name
2. **Given** no Mastodon collection data has been received, **When** I view the Mastodon collection page, **Then** I see an empty state message

---

### User Story 4 - Left Navigation for Collectors (Priority: P2)

As an operator, I want a persistent left navigation bar listing collectors and their pages so I can quickly move between collector details and collection information.

**Why this priority**: Efficient navigation becomes essential as the number of collectors grows.

**Independent Test**: Verify left nav renders on all pages and provides working links for each collector.

**Acceptance Scenarios (BDD)**:

1. **Given** I am on any page, **When** the page renders, **Then** I see a left navigation bar
2. **Given** multiple collectors exist, **When** I view the left navigation, **Then** I see an entry for each collector
3. **Given** I click a collector’s “Details” link (where available), **When** navigation completes, **Then** I arrive at that collector’s detail page
4. **Given** a collection-only collector is listed in the navigation, **When** I view its nav entry, **Then** only a Collection link is shown (no Details link)

---

### User Story 5 - Carousel Mode Cycling Through Collector Pages (Priority: P3)

As an operator using a kiosk/display, I want a carousel mode that cycles through collector pages so the latest configuration/collection info is visible without manual navigation.

**Why this priority**: Valuable for passive monitoring, but not required for core portal functionality.

**Independent Test**: Start carousel and verify the page cycles through collectors in a deterministic order.

**Acceptance Scenarios (BDD)**:

1. **Given** carousel mode is enabled, **When** the first page loads, **Then** it automatically advances after the configured dwell duration
2. **Given** carousel reaches the final collector page, **When** it advances, **Then** it loops back to the first collector page
3. **Given** carousel is enabled, **When** I manually click a navigation link, **Then** carousel mode stops

---

### Edge Cases

- Collector names contain spaces/special characters (slugging)
- Stale collector data vs fresh data (freshness window)
- Large configuration/collection payloads (size limits)
- Payloads missing optional fields (forward compatibility)
- Import failure mid-delete (system MUST NOT leave collector with no data if new payload is invalid)
- Concurrent imports for the same collector (last writer wins or serialized)
- Concurrent uploads (consistency)
- Carousel encounters a collector page that errors (skip + continue)
- Carousel config missing/invalid dwell time (defaults and bounds)

## Requirements *(mandatory)*

### Functional Requirements

#### Collector Registry & Overview

- **FR-001**: System MUST represent each Mellow collector as a "collector" with a stable identifier and display name
- **FR-002**: Index page MUST display an overview of all collectors and their latest configuration status
- **FR-003**: Index page MUST show last-updated timestamps for configuration and collection info (when available)
- **FR-004**: System MUST compute and display a freshness/staleness indicator based on last update times

#### Collector Detail & Collection Views

- **FR-005**: System MUST provide a collector detail page that displays the latest configuration snapshot
- **FR-006**: System MUST provide a view for collection information per collector
- **FR-006a**: Collection-only collectors (those that only submit collection snapshots) MUST NOT expose a Details page; the system MUST treat collection as their only view
- **FR-007**: Collector pages MUST show appropriate empty states when no data exists

#### Navigation

- **FR-008**: System MUST provide a persistent left navigation bar across portal pages
- **FR-009**: Navigation MUST list each collector with a Collection link; a Details link MUST NOT be shown for collection-only collectors (those that only submit collection snapshots)
- **FR-010**: Navigation MUST indicate the currently active page

#### API for Collector Updates

- **FR-011**: System MUST expose an HTTP API for collectors to upload configuration information
- **FR-012**: System MUST expose an HTTP API for collectors to upload collection information
- **FR-013**: API endpoints MUST accept JSON payloads
- **FR-014**: API endpoints MUST validate payload shape and required fields
- **FR-015**: API endpoints MUST return clear error messages for invalid requests
- **FR-016**: API endpoints MUST enforce request size limits
- **FR-017**: Collection import endpoints MUST be idempotent: re-submitting the same payload MUST result in the same stored state (replace semantics guarantee this by design)
- **FR-018**: System MUST store accepted payloads and make them visible in the UI

#### Authentication (Collector Utilities)

- **FR-019**: All portal web views MUST be publicly accessible (no browser authentication)
- **FR-020**: API upload endpoints MUST require simple authentication
- **FR-021**: Collector utilities are the API “users”; each collector MUST have a credential allowing it to upload snapshots
- **FR-022**: API authentication MUST authorize uploads only for the matching collector (a credential for collector A cannot upload to collector B)
- **FR-023**: Missing authentication MUST return 401 Unauthorized; invalid/incorrect authentication MUST return 403 Forbidden
- **FR-024**: Authentication secrets MUST NOT be logged and MUST NOT be returned in any API response

#### Carousel Mode

- **FR-025**: System MUST provide a carousel mode that cycles through collector pages
- **FR-026**: Carousel MUST pause on each page for a configured dwell duration (default 30 seconds)
- **FR-027**: Carousel MUST cycle in a deterministic order (default alphabetical by collector display name)
- **FR-028**: Carousel MUST stop when the user manually navigates
- **FR-029**: Carousel MUST handle page errors by recording an error and continuing

#### CLI Utilities

- **FR-030**: Each collection-only collector MUST have a dedicated CLI import utility that reads a JSON file and submits collection data to the API
- **FR-030a**: On a successful collection import, the system MUST delete all existing collection data for that collector before storing the new values; only the freshest data is retained
- **FR-030b**: If the import payload is invalid, the system MUST reject it with actionable errors and MUST NOT delete existing collection data
- **FR-031**: CLI utilities MUST provide clear success/failure output suitable for automation
- **FR-032**: CLI utilities MUST support configuring the API credential via environment variable or config file (no plaintext secret required on the command line)


#### Mellow Heeler — Collector-Specific Display Requirements

- **FR-033**: Mellow Heeler collection page MUST display the timestamp of the most recent observation
- **FR-034**: Mellow Heeler collection page MUST display the count of WiFi AP beacons in the last observation
- **FR-035**: Mellow Heeler collection page MUST display a table of up to 15 AP beacons per observation, with columns: SSID, BSSID, frequency (MHz), signal strength (dBm)
- **FR-036**: Mellow Heeler collection payload schema is defined in `data-model.md` (see HeelerCollectionPayload)
- **FR-037**: Collection-only collectors (those that only submit collection snapshots) MUST NOT have a Details (configuration snapshot) page; navigation MUST only expose the Collection view for these collectors

#### Mellow Hyena ADSB — Collector-Specific Display Requirements

- **FR-038**: Mellow Hyena ADSB collection page MUST display a header with: timestamp of the last observation, quantity of ADSB beacons in the last observation, collection platform, and site name
- **FR-039**: Mellow Hyena ADSB collection page MUST display a table of up to 15 ADSB observations with columns: adsbHex, registration, model, flight, altitude, track
- **FR-040**: For each observation row, registration and model MUST be looked up from the `adsbex` stanza by matching `adsbHex`; if no match is found, registration and model MUST display as "unknown"
- **FR-041**: Mellow Hyena ADSB collection payload schema is defined in `data-model.md` (see HyenaAdsbCollectionPayload)
- **FR-042**: Mellow Hyena ADSB is a collection-only collector; it MUST NOT have a Details page

#### Mellow Hyena UAT — Collector-Specific Display Requirements

- **FR-043**: Mellow Hyena UAT collection page MUST display a header with: timestamp of the last observation, quantity of beacons in the last observation, collection platform, and site name
- **FR-044**: Mellow Hyena UAT collection page MUST display a table of up to 15 observations with columns: adsbHex, registration, model, flight, altitude, track
- **FR-045**: For each observation row, registration and model MUST be looked up from the `adsbex` stanza by matching `adsbHex`; if no match is found, registration and model MUST display as "unknown"
- **FR-046**: Mellow Hyena UAT collection payload schema is defined in `data-model.md` (see HyenaUatCollectionPayload)
- **FR-047**: Mellow Hyena UAT is a collection-only collector; it MUST NOT have a Details page

#### Mellow Mastodon — Collector-Specific Display Requirements

- **FR-048**: Mellow Mastodon collection page MUST display a header with: timestamp of the last observation, peakers count, collection platform, and site name
- **FR-049**: Mellow Mastodon collection payload schema is defined in `data-model.md` (see MastodonCollectionPayload)
- **FR-050**: Mellow Mastodon is a collection-only collector; it MUST NOT have a Details page

### Key Entities *(include if feature involves data)*

- **Collector**: A contributing Mellow application (includes an ingestion credential used by its CLI utility).
- **ConfigurationSnapshot**: Historical configuration snapshots per collector.
- **CollectionSnapshot**: The current (freshest) collection data for a collector. Replaced in full on each successful import; only one active record is retained per collector.
- **CarouselSession**: Runtime state for cycling.

### Non-Functional Requirements

- **NFR-001**: Index page SHOULD load in under 2 seconds for 100 collectors
- **NFR-002**: API endpoints SHOULD respond in under 2 seconds for typical payloads
- **NFR-003**: API MUST reject malformed JSON with actionable validation errors
- **NFR-004**: System MAY preserve the most recent raw payload per collector for debugging; long-term audit history of collection data is out of scope
- **NFR-005**: Carousel timing SHOULD be accurate within ±2 seconds per dwell interval

## Success Criteria

1. Collectors can upload configuration and collection information via API and see it reflected in the portal
2. Index shows an accurate overview with freshness indicators
3. Operators can navigate via left nav to details/collection pages for each collector
4. Carousel cycles through collector pages with the configured dwell and loops
5. Re-importing the same JSON file leaves the collector with identical data (idempotent result)
6. Mellow Hyena ADSB collection page shows header (timestamp, beacon count, platform, site) and table of up to 15 observations with enriched registration/model from adsbex lookup
7. Mellow Hyena UAT collection page shows header (timestamp, beacon count, platform, site) and table of up to 15 observations with enriched registration/model from adsbex lookup
8. Mellow Mastodon collection page shows header (timestamp, peakers count, platform, site)

## Assumptions & Constraints

- All portal web views are public and do not require browser authentication.
- Collector utilities are the only API clients and are treated as the “users” of the ingestion API.
- Upload endpoints require simple authentication (e.g., a per-collector shared secret/bearer token). Network controls (reverse proxy allowlist/firewall) are recommended but are not a substitute for authentication.
- Payload schemas may evolve; unknown fields should be tolerated and preserved.
- Collection data for a collector represents the current state only; historical collection data is not retained.
- Configuration snapshots remain append-only (historical); only collection data is replaced on import.

## Out of Scope (V1)

- Human end-user accounts, sessions, and roles for the portal UI
- Fine-grained authorization beyond “this collector utility may upload for this collector”
- Advanced alerting/notifications
- Real-time streaming updates (WebSockets)
- Cross-collector correlation dashboards beyond overview + drill-down
