# Research: Mellow Component Portal

This document captures technical decisions needed to implement `spec.md`.

## Decisions

### 1) Component update API shape
**Decision**: Provide two JSON endpoints:
- `POST /api/components/:component_id/configuration_snapshots`
- `POST /api/components/:component_id/collection_snapshots`

Both accept a JSON payload and an idempotency identifier (`snapshot_id` or `idempotency_key`).

**Rationale**: Keeps semantics explicit (config vs collection), enables separate validation and UI presentation.

**Alternatives considered**:
- Single `/api/uploads` endpoint with type field (less explicit; more branching).

### 2) Idempotency
**Decision**: Enforce uniqueness per component per snapshot type:
- unique `(component_id, snapshot_id)` for config snapshots
- unique `(component_id, snapshot_id)` for collection snapshots

**Rationale**: CLI utilities can safely retry without duplicating.

### 3) Payload storage model
**Decision**:
- Store raw snapshot payload as JSONB for audit/debug.
- Extract a small set of summary fields for fast index rendering (e.g., status, captured_at, key counts).

**Rationale**: JSONB supports schema evolution while keeping the overview fast.

### 4) Freshness window
**Decision**: Treat components as stale when `now - last_config_update > 24h` (default). Make configurable via environment variable.

**Rationale**: Provides a sane default and is easy to adjust per deployment.

### 5) Carousel behavior
**Decision**:
- Default dwell: 30 seconds.
- Dwell bounds: 1..3600 seconds.
- Deterministic order: alphabetical by component display name.
- If a page errors during carousel, record the error and continue.

**Rationale**: Matches spec requirements and keeps behavior predictable.

### 6) Threat model
**Decision**:
- No user auth for viewing (all portal pages are public).
- Ingestion API requires simple authentication for component utilities (per-component bearer token / shared secret).
- Network controls (reverse proxy allowlist/firewall) are recommended in addition to authentication.

## Notes for implementation

- Structured logging for ingestion endpoints: request_id, component_id, snapshot_type, idempotency_key, status, duration_ms, payload_bytes.
- Enforce max payload size (e.g., 10MB) at app/proxy.
