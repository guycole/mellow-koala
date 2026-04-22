# Quickstart: Mellow Collector Portal (Rails 8 + Tailwind + Postgres + Docker)

This describes the intended developer workflow once implementation is complete.

## Prerequisites

- Docker + Docker Compose

## Development

```bash
docker compose up --build
```

```bash
docker compose exec web bin/rails db:prepare
```

```bash
docker compose exec web bundle exec rspec
```

## API Examples

### Upload configuration snapshot

```bash
export MELLOW_KOALA_TOKEN='replace-me'

curl -X POST http://localhost:3000/api/collectors/mellow-hyena-adsb/configuration_snapshots \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${MELLOW_KOALA_TOKEN}" \
  -d '{
    "snapshot_id": "cfg-0001",
    "captured_at": "2026-04-18T06:52:00Z",
    "payload": {
      "version": "1.2.3",
      "config": {"mode": "active"}
    }
  }'
```

### Upload collection snapshot

```bash
export MELLOW_KOALA_TOKEN='replace-me'

curl -X POST http://localhost:3000/api/collectors/mellow-hyena-adsb/collection_snapshots \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${MELLOW_KOALA_TOKEN}" \
  -d '{
    "snapshot_id": "col-0001",
    "captured_at": "2026-04-18T06:52:00Z",
    "payload": {
      "collections": [{"name": "items", "count": 42}]
    }
  }'
```

## Portal Pages

- `/` index overview
- `/collectors/mellow-hyena-adsb` details
- `/collectors/mellow-hyena-adsb/collection` collection
- `/carousel` carousel mode

## Notes

- Portal pages are public.
- Ingestion API requires a per-collector bearer token (recommended to run behind additional network controls such as a reverse proxy allowlist/firewall).
- Enforce payload size limits; default staleness window 24h; carousel dwell default 30s.
