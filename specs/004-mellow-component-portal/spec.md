# Feature Specification: Mellow Component Portal

**Feature Branch**: `004-mellow-component-portal`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: User description: "Mellow Koala is a web application which provides information about other Mellow components such as Mellow Heeler, Mellow Hyena, Mellow Mastodon, etc. Each compnents can share configuration and collection information. The index page will provide an overview of mellow component configurations. There will be a navigation bar on the left side to navigate for component details and collection information. There will also be a carousel mode which cycles through the component pages. Components will update their information via dedicated command line utilities to a Mellow Koala API."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - CLI Upload of Component Configuration & Collection Info (Priority: P1)

As a Mellow component maintainer, I want a dedicated CLI utility to upload my component’s configuration and collection information to the Mellow Koala API so the portal stays up to date.

**Why this priority**: Without ingestion, the portal has nothing to display.

**Independent Test**: POST a valid configuration payload and a valid collection payload; verify they persist and are visible in the UI.

**Acceptance Scenarios (BDD)**:

1. **Given** a component identifier exists and the CLI is authenticated for that component, **When** the CLI uploads a valid configuration payload, **Then** the API accepts it and stores a new configuration snapshot
2. **Given** a component identifier exists and the CLI is authenticated for that component, **When** the CLI uploads valid collection information, **Then** the API accepts it and stores a new collection snapshot
3. **Given** the CLI uploads an invalid payload, **When** the API processes it, **Then** the API rejects it with actionable validation errors
4. **Given** the CLI retries the same upload with an idempotency key, **When** the API receives it again, **Then** it does not create duplicates and returns an idempotent success response
5. **Given** the CLI is missing authentication, **When** it uploads a snapshot, **Then** the API rejects the request with 401 Unauthorized
6. **Given** the CLI provides invalid authentication, **When** it uploads a snapshot, **Then** the API rejects the request with 403 Forbidden
7. **Given** the CLI is authenticated for component A, **When** it attempts to upload to component B’s endpoint, **Then** the API rejects the request with 403 Forbidden

---

### User Story 2 - Index Overview of Component Configurations (Priority: P1)

As an operator, I want the index page to show an overview of configuration for all known Mellow components so I can quickly understand what is configured and whether it is fresh.

**Why this priority**: It is the primary operator view and a fast way to spot problems.

**Independent Test**: Create 2 components with configuration snapshots, visit `/`, verify the overview reflects their latest configuration timestamps and key fields.

**Acceptance Scenarios (BDD)**:

1. **Given** no components have reported configuration, **When** I visit the index page, **Then** I see an empty state indicating no components are available
2. **Given** components have reported configuration, **When** I visit the index page, **Then** I see a row/card per component with its name and last-updated timestamp
3. **Given** a component has stale configuration (older than a defined freshness window), **When** I visit the index page, **Then** that component is visually marked as stale

---

### User Story 3 - Component Detail & Collection Information Pages (Priority: P2)

As an operator, I want to view a component’s detail page and collection information so I can inspect configuration and understand what data the component is collecting.

**Why this priority**: The index is summary-only; operators need drill-down.

**Independent Test**: Navigate to a component page and verify it shows the latest configuration snapshot and recent collection records.

**Acceptance Scenarios (BDD)**:

1. **Given** a component exists, **When** I navigate to that component’s detail page, **Then** I see the latest configuration snapshot
2. **Given** a component has collection information, **When** I open the collection view, **Then** I see recent collection summaries/items with timestamps
3. **Given** a component has never reported collection information, **When** I open the collection view, **Then** I see an empty state explaining no data is available yet

---

### User Story 6 - Mellow Heeler Collection View (Priority: P2)

As an operator, I want to see Mellow Heeler’s latest WiFi AP beacon observations so I can monitor wireless network activity at each site.

**Source**: [GitHub Issue #25 — mellow heeler component](https://github.com/guycole/mellow-koala/issues/25)

**Why this priority**: Heeler is the first concrete component with a defined payload schema and display requirements.

**Independent Test**: Upload a Heeler collection snapshot; navigate to Heeler’s collection page; verify timestamp, AP count, and the AP table are rendered correctly.

**Acceptance Scenarios (BDD)**:

1. **Given** a Heeler collection snapshot has been received, **When** I view the Heeler collection page, **Then** I see the timestamp of the most recent observation
2. **Given** a Heeler collection snapshot has been received, **When** I view the Heeler collection page, **Then** I see the count of WiFi AP beacons in the last observation
3. **Given** a Heeler collection snapshot has been received, **When** I view the Heeler collection page, **Then** I see a table of up to 15 AP beacons with columns: SSID, BSSID, frequency (MHz), signal strength (dBm)
4. **Given** a Heeler snapshot has more than 15 AP beacons, **When** I view the collection page, **Then** only the first 15 are displayed
5. **Given** no Heeler collection data has been received, **When** I view the Heeler collection page, **Then** I see an empty state message

---

### User Story 4 - Left Navigation for Components (Priority: P2)

As an operator, I want a persistent left navigation bar listing components and their pages so I can quickly move between component details and collection information.

**Why this priority**: Efficient navigation becomes essential as the number of components grows.

**Independent Test**: Verify left nav renders on all pages and provides working links for each component.

**Acceptance Scenarios (BDD)**:

1. **Given** I am on any page, **When** the page renders, **Then** I see a left navigation bar
2. **Given** multiple components exist, **When** I view the left navigation, **Then** I see an entry for each component
3. **Given** I click a component’s “Details” link, **When** navigation completes, **Then** I arrive at that component’s detail page

---

### User Story 5 - Carousel Mode Cycling Through Component Pages (Priority: P3)

As an operator using a kiosk/display, I want a carousel mode that cycles through component pages so the latest configuration/collection info is visible without manual navigation.

**Why this priority**: Valuable for passive monitoring, but not required for core portal functionality.

**Independent Test**: Start carousel and verify the page cycles through components in a deterministic order.

**Acceptance Scenarios (BDD)**:

1. **Given** carousel mode is enabled, **When** the first page loads, **Then** it automatically advances after the configured dwell duration
2. **Given** carousel reaches the final component page, **When** it advances, **Then** it loops back to the first component page
3. **Given** carousel is enabled, **When** I manually click a navigation link, **Then** carousel mode stops

---

### Edge Cases

- Component names contain spaces/special characters (slugging)
- Stale component data vs fresh data (freshness window)
- Large configuration/collection payloads (size limits)
- Payloads missing optional fields (forward compatibility)
- Duplicate uploads / retries (idempotency)
- Concurrent uploads (consistency)
- Carousel encounters a component page that errors (skip + continue)
- Carousel config missing/invalid dwell time (defaults and bounds)

## Requirements *(mandatory)*

### Functional Requirements

#### Component Registry & Overview

- **FR-001**: System MUST represent each Mellow component as a "component" with a stable identifier and display name
- **FR-002**: Index page MUST display an overview of all components and their latest configuration status
- **FR-003**: Index page MUST show last-updated timestamps for configuration and collection info (when available)
- **FR-004**: System MUST compute and display a freshness/staleness indicator based on last update times

#### Component Detail & Collection Views

- **FR-005**: System MUST provide a component detail page that displays the latest configuration snapshot
- **FR-006**: System MUST provide a view for collection information per component
- **FR-007**: Component pages MUST show appropriate empty states when no data exists

#### Navigation

- **FR-008**: System MUST provide a persistent left navigation bar across portal pages
- **FR-009**: Navigation MUST list each component and provide links to at least: Details and Collection
- **FR-010**: Navigation MUST indicate the currently active page

#### API for Component Updates

- **FR-011**: System MUST expose an HTTP API for components to upload configuration information
- **FR-012**: System MUST expose an HTTP API for components to upload collection information
- **FR-013**: API endpoints MUST accept JSON payloads
- **FR-014**: API endpoints MUST validate payload shape and required fields
- **FR-015**: API endpoints MUST return clear error messages for invalid requests
- **FR-016**: API endpoints MUST enforce request size limits
- **FR-017**: API endpoints MUST support idempotent retries using an idempotency key or upload identifier
- **FR-018**: System MUST store accepted payloads and make them visible in the UI

#### Authentication (Component Utilities)

- **FR-019**: All portal web views MUST be publicly accessible (no browser authentication)
- **FR-020**: API upload endpoints MUST require simple authentication
- **FR-021**: Component utilities are the API “users”; each component MUST have a credential allowing it to upload snapshots
- **FR-022**: API authentication MUST authorize uploads only for the matching component (a credential for component A cannot upload to component B)
- **FR-023**: Missing authentication MUST return 401 Unauthorized; invalid/incorrect authentication MUST return 403 Forbidden
- **FR-024**: Authentication secrets MUST NOT be logged and MUST NOT be returned in any API response

#### Carousel Mode

- **FR-025**: System MUST provide a carousel mode that cycles through component pages
- **FR-026**: Carousel MUST pause on each page for a configured dwell duration (default 30 seconds)
- **FR-027**: Carousel MUST cycle in a deterministic order (default alphabetical by component display name)
- **FR-028**: Carousel MUST stop when the user manually navigates
- **FR-029**: Carousel MUST handle page errors by recording an error and continuing

#### CLI Utilities

- **FR-030**: Each component MUST have a dedicated CLI utility that can submit configuration and collection payloads to the API
- **FR-031**: CLI utilities MUST provide clear success/failure output suitable for automation
- **FR-032**: CLI utilities MUST support configuring the API credential via environment variable or config file (no plaintext secret required on the command line)


#### Mellow Heeler — Component-Specific Display Requirements

- **FR-033**: Mellow Heeler collection page MUST display the timestamp of the most recent observation
- **FR-034**: Mellow Heeler collection page MUST display the count of WiFi AP beacons in the last observation
- **FR-035**: Mellow Heeler collection page MUST display a table of up to 15 AP beacons per observation, with columns: SSID, BSSID, frequency (MHz), signal strength (dBm)
- **FR-036**: Mellow Heeler collection payload schema is defined in `data-model.md` (see HeelerCollectionPayload)

### Key Entities *(include if feature involves data)*

- **Component**: A contributing Mellow application (includes an ingestion credential used by its CLI utility).
- **ConfigurationSnapshot**: Historical configuration snapshots per component.
- **CollectionSnapshot**: Historical collection snapshots per component.
- **CarouselSession**: Runtime state for cycling.

### Non-Functional Requirements

- **NFR-001**: Index page SHOULD load in under 2 seconds for 100 components
- **NFR-002**: API endpoints SHOULD respond in under 2 seconds for typical payloads
- **NFR-003**: API MUST reject malformed JSON with actionable validation errors
- **NFR-004**: System SHOULD preserve raw payloads for audit/debugging
- **NFR-005**: Carousel timing SHOULD be accurate within ±2 seconds per dwell interval

## Success Criteria

1. Components can upload configuration and collection information via API and see it reflected in the portal
2. Index shows an accurate overview with freshness indicators
3. Operators can navigate via left nav to details/collection pages for each component
4. Carousel cycles through component pages with the configured dwell and loops
5. Retry uploads do not create duplicates (idempotency)

## Assumptions & Constraints

- All portal web views are public and do not require browser authentication.
- Component utilities are the only API clients and are treated as the “users” of the ingestion API.
- Upload endpoints require simple authentication (e.g., a per-component shared secret/bearer token). Network controls (reverse proxy allowlist/firewall) are recommended but are not a substitute for authentication.
- Payload schemas may evolve; unknown fields should be tolerated and preserved.

## Out of Scope (V1)

- Human end-user accounts, sessions, and roles for the portal UI
- Fine-grained authorization beyond “this component utility may upload for this component”
- Advanced alerting/notifications
- Real-time streaming updates (WebSockets)
- Cross-component correlation dashboards beyond overview + drill-down
