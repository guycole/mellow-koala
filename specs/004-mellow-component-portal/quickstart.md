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

### Upload collection snapshot

Each collector has a dedicated import utility (`bin/import_heeler`, `bin/import_hyena_adsb`, etc.) that reads a local JSON file and calls this endpoint. The raw curl form is shown below for reference.

```bash
export MELLOW_KOALA_TOKEN='replace-me'

curl -X POST http://localhost:3000/api/collectors/mellow-heeler/collection_snapshots \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${MELLOW_KOALA_TOKEN}" \
  -d '{
    "snapshot_id": "col-0001",
    "captured_at": "2026-04-18T06:52:00Z",
    "payload": {
      "geoLoc": {"site": "anderson1"},
      "platform": "rpi3c",
      "project": "heeler",
      "version": 1,
      "wifi": [
        {
          "bssid": "00:22:6b:81:03:d9",
          "frequency_mhz": 2437,
          "signal_dbm": -86,
          "ssid": "braingang2"
        }
      ],
      "zTime": 1742095222
    }
  }'
```

Using an import utility instead:

```bash
export MELLOW_KOALA_TOKEN='replace-me'
export MELLOW_KOALA_URL='http://localhost:3000'

bin/import_heeler samples/heeler1.json
```

## Portal Pages

- `/` index overview
- `/collectors/mellow-heeler/collection` Heeler collection
- `/collectors/mellow-hyena-adsb/collection` Hyena ADSB collection
- `/collectors/mellow-hyena-uat/collection` Hyena UAT collection
- `/collectors/mellow-mastodon/collection` Mastodon collection
- `/carousel` carousel mode
- `/metrics` Prometheus metrics

## Notes

- Portal pages are public.
- Ingestion API requires a per-collector bearer token (shown by `bin/rails db:seed`).
- Each import replaces the collector's existing collection data (last snapshot wins).
- Enforce payload size limits; default staleness window 24h; carousel dwell default 30s.
