# Feature Specification: Mellow Summary Dashboard

**Feature Branch**: `003-mellow-summary-dashboard`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: User description: "this is a web application which exposes configuration and summaries from other mellow applications. There are no users or authorization required. The index page will have an activity summary, and there will be a navigation bar on the left side to navigate for details. There will need to be a API to upload statistics and content into the system. There will also be a 'carousel' mode which cycles through various pages so show latest content. The carousel will be configurable for URL and dwell duration."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Activity Summary Index (Priority: P1)

As a visitor, I want an index page that summarizes recent activity from all contributing mellow applications so I can quickly understand what’s happening (latest uploads, freshness, errors).

**Why this priority**: It’s the primary value proposition and the first page users see.

**Independent Test**: Seed a few sources and uploads, load `/`, verify summary counts and timestamps match.

**Acceptance Scenarios**:

1. **Given** no data has been uploaded, **When** I visit the index page, **Then** I see an empty-state summary (no sources / no activity)
2. **Given** multiple sources have uploaded content, **When** I visit the index page, **Then** I see a summary per source including last upload time and basic counts
3. **Given** an upload fails validation, **When** I visit the index page, **Then** I can see an error indicator and a count of recent failures

---

### User Story 2 - Upload API for Stats & Content (Priority: P1)

As another mellow application, I want to upload statistics and content to this system via an API so the dashboard can display up-to-date summaries and details.

**Why this priority**: Without ingestion, there is nothing to summarize or browse.

**Independent Test**: POST a valid JSON payload to the upload endpoint and confirm it is accepted and reflected in the index summary.

**Acceptance Scenarios**:

1. **Given** a known source identifier, **When** I POST a valid upload payload, **Then** the system stores it and returns a success response
2. **Given** an unknown source identifier, **When** I POST an upload payload, **Then** the system rejects it with a clear error response
3. **Given** a malformed payload, **When** I POST it, **Then** the system rejects it with validation errors
4. **Given** I re-send an upload with the same idempotency key, **When** the system receives it, **Then** it does not duplicate data and returns an idempotent success response

---

### User Story 3 - Left Navigation + Detail Pages (Priority: P2)

As a visitor, I want a persistent left navigation bar to move between summary and detail pages so I can drill into specific sources and see uploaded statistics/content.

**Why this priority**: Improves usability once ingestion and summary exist.

**Independent Test**: Navigate from index to a source detail page via left nav and verify content lists render.

**Acceptance Scenarios**:

1. **Given** I am on any page, **When** the page loads, **Then** the left navigation is visible and includes links to key pages
2. **Given** multiple sources exist, **When** I expand the navigation, **Then** I can select a source and reach its detail page
3. **Given** a source has uploaded items, **When** I view its detail page, **Then** I see recent uploads and their key fields

---

### User Story 4 - Configurable Carousel Mode (Priority: P3)

As a visitor running the dashboard on a display, I want a carousel mode that cycles through configured pages at a configured dwell duration so that the latest content is shown without manual navigation.

**Why this priority**: Useful for monitoring/kiosk use, but the app is valuable without it.

**Independent Test**: Start carousel with a small set of URLs and a short dwell (e.g., 2s) and verify the browser redirects in the expected sequence.

**Acceptance Scenarios**:

1. **Given** carousel mode is started with a list of URLs and a dwell duration, **When** the first page loads, **Then** it automatically advances after the dwell duration
2. **Given** carousel mode reaches the end of the list, **When** it advances, **Then** it loops back to the first URL
3. **Given** carousel mode is active, **When** I manually navigate using the left nav, **Then** carousel mode stops
4. **Given** carousel is configured with an invalid URL, **When** carousel reaches it, **Then** it records an error and continues to the next URL

---

### Edge Cases

- No sources configured / no uploads yet (empty state)
- Upload payload too large or too frequent (size/rate limiting)
- Upload includes future timestamps (clock skew)
- Duplicate uploads (idempotency)
- Partial payload (stats present but content missing, and vice versa)
- Carousel dwell duration out of bounds (0, negative, extremely large)
- Carousel URL list includes external sites vs internal-only navigation
- Carousel running while pages error (500/timeout)

## Requirements *(mandatory)*

### Functional Requirements

#### Source & Configuration Exposure

- **FR-001**: System MUST represent contributing mellow applications as "sources" with a stable unique identifier and display name
- **FR-002**: System MUST expose a summary view of all sources on the index page
- **FR-003**: System MUST expose a detail view per source showing recent uploads and derived summaries

#### Index Activity Summary

- **FR-004**: Index page MUST display a global activity summary (e.g., total uploads, last activity time, recent error count)
- **FR-005**: Index page MUST display per-source freshness (e.g., last upload time)
- **FR-006**: Index page MUST display an empty-state when there is no activity

#### Left Navigation

- **FR-007**: System MUST provide a persistent left navigation bar across pages
- **FR-008**: Navigation MUST include at least: Index, per-source details, and Carousel entry point
- **FR-009**: Navigation MUST indicate the currently active page

#### Upload API

- **FR-010**: System MUST provide an API endpoint to upload statistics and content
- **FR-011**: Upload API MUST accept JSON payloads
- **FR-012**: Upload API MUST validate payload shape and required fields
- **FR-013**: Upload API MUST reject uploads for unknown sources with a clear error
- **FR-014**: Upload API MUST support idempotent replays using an idempotency key or upload ID
- **FR-015**: Upload API MUST store accepted uploads such that they can be summarized and browsed in detail pages
- **FR-016**: Upload API MUST record validation failures for observability/troubleshooting
- **FR-017**: Upload API MUST enforce request size limits

#### Carousel Mode

- **FR-018**: System MUST provide a "carousel" mode that cycles through an ordered list of URLs
- **FR-019**: Carousel configuration MUST be expressible in the request URL (e.g., via query parameters) including at minimum: ordered URL list and dwell duration
- **FR-020**: Carousel dwell duration MUST be configurable per carousel session and MUST be validated (minimum 1 second, maximum 3600 seconds); if omitted, default MUST be 30 seconds
- **FR-021**: Carousel MUST pause (dwell) on each URL for the configured duration
- **FR-022**: Carousel MUST advance by HTTP redirect/navigation (not requiring manual action)
- **FR-023**: Carousel MUST loop continuously through the configured URLs
- **FR-024**: Carousel MUST stop when the user manually navigates
- **FR-025**: Carousel MUST handle invalid/unreachable URLs by recording an error and continuing

#### No Users / Authorization

- **FR-026**: System MUST NOT require end-user accounts for viewing pages
- **FR-027**: System MUST NOT require end-user authorization to access dashboard pages
- **FR-028**: System MUST document the assumed threat model for the upload API (e.g., intended to run in a trusted network)

### Key Entities *(include if feature involves data)*

- **Source**: A contributing mellow application.
  - Attributes: source_id, display_name, description (optional), created_at, updated_at

- **Upload**: A single ingestion event containing stats and/or content.
  - Attributes: upload_id (or idempotency_key), source_id, received_at, payload (raw JSON), parsed_stats (structured), parsed_content (structured), status (accepted/rejected), error_details (optional)

- **Statistic**: A normalized statistic derived from uploaded data.
  - Attributes: source_id, name/key, value, observed_at

- **ContentItem**: A content record derived from uploaded data.
  - Attributes: source_id, content_type, title/label, body/summary (optional), url (optional), observed_at

- **CarouselConfig**: Configuration for a carousel session.
  - Attributes: urls (ordered list), dwell_seconds, started_at, last_url_index, error_count

### Non-Functional Requirements

- **NFR-001**: Index page SHOULD load in under 2 seconds for 100 sources and 10k total uploads
- **NFR-002**: Upload API SHOULD respond within 2 seconds for typical payloads
- **NFR-003**: System MUST provide clear, structured error messages for rejected uploads
- **NFR-004**: Carousel timing SHOULD be accurate within ±2 seconds per dwell interval
- **NFR-005**: System SHOULD degrade gracefully when a source provides unexpected fields (ignore unknown fields)

## Success Criteria

1. Visitors can load `/` and see a meaningful activity summary (or an empty state)
2. Another mellow app can upload stats/content via the API and see those reflected in the dashboard
3. Left nav reliably reaches source detail pages and the carousel entry point
4. Carousel can be started with a URL list + dwell duration and rotates continuously
5. No user accounts or authorization are required for viewing dashboard pages

## Assumptions & Constraints

- There are no end-users and no authorization for browsing.
- The upload API is assumed to be used in a trusted environment (e.g., internal network, reverse proxy allowlist). If this assumption changes, an auth layer becomes required.
- Carousel configuration is expected to be provided at runtime (e.g., query parameters or a server-side config), and must support URL list + dwell duration.

## Out of Scope (V1)

- Role-based access control, authentication, and user management
- Public internet exposure hardening beyond basic input validation and rate limiting
- Advanced visualization (charts/dashboards) beyond summaries and lists
- Multi-tenant partitioning across unrelated organizations
