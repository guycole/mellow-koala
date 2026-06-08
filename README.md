# Mellow Koala

Mellow Koala is a web portal that aggregates and displays data from a family of
embedded Mellow collectors (Heeler, Hyena-ADSB, Hyena-UAT, Mastodon, and
others). Each collector pushes its latest snapshot to Koala via a JSON API; the
portal surfaces an overview of all collectors, per-collector collection pages,
and an auto-cycling carousel view for kiosk use.

- **Runtime**: Ruby 3.4.9 + Rails 8.x
- **Database**: PostgreSQL 15+
- **Front-end**: Tailwind CSS, Hotwire (Turbo + Stimulus)
- **Monitoring**: Prometheus (`/metrics`), structured logs for Elasticsearch
- **Deployment**: Docker on ARM64 Linux, built on the host

![Mellow Koala Index Page](https://github.com/guycole/mellow-koala/blob/main/images/index.png)
![Hyena Collector Page](https://github.com/guycole/mellow-koala/blob/main/images/hyena-adsb.png)
---

## Import Utilities

Each Mellow collector ships a standalone Ruby script (`bin/import_*`) that
reads a local JSON file and pushes it to the Koala ingestion API. Imports are
**idempotent** — re-importing the same file replaces existing data with the
same values.

| Utility | Collector | Data |
|---|---|---|
| `bin/import_heeler` | Mellow Heeler | WiFi AP beacon observations |
| `bin/import_hyena_adsb` | Mellow Hyena-ADSB | ADSB aviation beacon observations |
| `bin/import_hyena_uat` | Mellow Hyena-UAT | UAT aviation beacon observations |
| `bin/import_mastodon` | Mellow Mastodon | Energy survey peaker observations |

### Configuration

Each utility reads its credentials from (in order of precedence):

1. Environment variables
2. `~/.mellow-koala/credentials` (plain `KEY=VALUE` file)

| Variable | Required | Default | Description |
|---|---|---|---|
| `MELLOW_KOALA_TOKEN` | Yes | — | Bearer token for the collector (shown by `db:seed`) |
| `MELLOW_KOALA_URL` | No | `http://localhost:3000` | Base URL of the Koala server |

Example credentials file:

```
MELLOW_KOALA_TOKEN=abc123...
MELLOW_KOALA_URL=http://koala.local:3000
```

### Usage

```bash
bin/import_heeler      /path/to/heeler.json
bin/import_hyena_adsb  /path/to/hyena_adsb.json
bin/import_hyena_uat   /path/to/hyena_uat.json
bin/import_mastodon    /path/to/mastodon.json
```

Pass `--help` to any utility for a usage reminder.

---

## Production Deployment

Mellow Koala is deployed as a Docker container built directly on the ARM64
Linux host. No image registry or image export/transfer is required.

### Prerequisites

- Docker installed on the ARM64 host
- PostgreSQL 15+ accessible from the host (can be a separate container or
  system service)
- A dedicated database user and database created for Koala

```sql
CREATE USER koala_admin WITH PASSWORD 'change-me';
CREATE DATABASE mellow_koala_production OWNER koala_admin;
```

### 1. Clone the repository

```bash
git clone https://github.com/guycole/mellow-koala.git
cd mellow-koala
```

### 2. Build the image

```bash
docker build -t koala:latest .
```

The Dockerfile installs production gems, precompiles assets, and produces a
self-contained image. No network access is required after cloning (assuming
gems are available in `Gemfile.lock`).

### 3. Generate a secret key base

```bash
docker run --rm koala:latest bundle exec rails secret
```

Copy the output — you will use it as `SECRET_KEY_BASE` below.

### 4. Prepare the database

Run migrations and seed the collector records (tokens are printed once on
first seed):

```bash
docker run --rm \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=<your-secret> \
  -e DB_HOST=<postgres-host> \
  -e DB_USERNAME=koala_admin \
  -e DB_PASSWORD=<db-password> \
  koala:latest bundle exec rails db:prepare db:seed
```

Note the ingest tokens printed for each collector — these are the values
collectors must supply as `MELLOW_KOALA_TOKEN`.

### 5. Start the server

```bash
docker run -d \
  --name koala \
  --restart unless-stopped \
  -p 3000:3000 \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=<your-secret> \
  -e DB_HOST=<postgres-host> \
  -e DB_USERNAME=koala_admin \
  -e DB_PASSWORD=<db-password> \
  koala:latest
```

The portal is now available at `http://<host>:3000`.

### Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `SECRET_KEY_BASE` | Yes | — | Rails secret; generate with `rails secret` |
| `DB_HOST` | Yes | `localhost` | PostgreSQL host |
| `DB_PORT` | No | `5432` | PostgreSQL port |
| `DB_USERNAME` | No | `koala_admin` | Database user |
| `DB_PASSWORD` | Yes | — | Database password |
| `DB_NAME` | No | `mellow_koala_production` | Database name |
| `RAILS_MAX_THREADS` | No | `5` | Puma thread count / DB pool size |
| `PROMETHEUS_MULTIPROC_DIR` | No | — | Writable directory for multi-process Prometheus metrics aggregation (needed when running Puma in cluster mode) |

### Prometheus

The `/metrics` endpoint is served by Rack middleware and is always available —
no route configuration needed. Prometheus can scrape it directly:

```yaml
scrape_configs:
  - job_name: mellow_koala
    static_configs:
      - targets: ["<host>:3000"]
```

### Upgrading

```bash
git pull
docker build -t koala:latest .
docker run --rm <env-flags> koala:latest bundle exec rails db:migrate
docker restart koala
```

---

## Development

```bash
bin/setup          # install gems, create & migrate dev database
bin/dev            # start Rails + Tailwind CSS watcher
bundle exec rspec  # run the test suite
```

PostgreSQL must be running locally with the credentials in `config/database.yml`
(`koala_admin` / `woofwoof` by default for development).

