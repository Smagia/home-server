# Local Home Server Setup

This repository contains a Docker Compose configuration for setting up a local home server with multiple services, split into topic-based compose files.

## Structure

```
compose/
├── dashboard.yaml    # Homer dashboard with links to all services
├── management.yaml   # Server management tools
├── media.yaml        # Media streaming and downloads
├── arr.yaml          # *arr media automation stack
├── sync.yaml         # File synchronization
├── photos.yaml       # Photo and video backup (Immich)
├── backup.yaml       # Data backup and restore
└── documents.yaml    # Document management (Paperless-ngx)
```

The main `docker-compose.yaml` includes all compose files. You can run everything together or individual stacks separately.

## Services

### Dashboard (`compose/dashboard.yaml`)

| Service | Description | Port |
|---|---|---|
| Homer | Dashboard with links to all services | `8087` |

### Management (`compose/management.yaml`)

| Service | Description | Port |
|---|---|---|
| Portainer | Web-based Docker management interface | `8088` |
| File Browser | Web interface to manage files on your server | `8089` |

### Media (`compose/media.yaml`)

| Service | Description | Port |
|---|---|---|
| Transmission | BitTorrent client for downloading and seeding torrents | `8090` |
| Jellyfin | Media server for streaming and managing your media collection | `8091` |
| Calibre Web | Web application for managing and accessing your eBook library | `8092` |

### Media Automation (`compose/arr.yaml`)

| Service | Description | Port |
|---|---|---|
| Prowlarr | Indexer manager that feeds sources to Sonarr and Radarr | `8099` |
| Sonarr | TV show monitoring, search, and download automation | `8097` |
| Radarr | Movie monitoring, search, and download automation | `8098` |

> **Integration**: Prowlarr manages indexers for Sonarr and Radarr. They use Transmission (from `media.yaml`) as the download client and organize media into `${HDD_DIR}/media/tv` and `${HDD_DIR}/media/movies`. All services share the same `/media` mount so Sonarr/Radarr create **hardlinks** instead of copying — no duplicate disk usage.
>
> **Autoconfiguration**: Run `./scripts/configure-arr.sh` after starting services to automatically configure download clients and root paths. See [arr-setup.md](docs/arr-setup.md) for the complete setup guide.

### Sync (`compose/sync.yaml`)

| Service | Description | Port |
|---|---|---|
| Syncthing | Continuous file synchronization tool for keeping files in sync across devices | `8093` |

### Photos (`compose/photos.yaml`)

| Service | Description | Port |
|---|---|---|
| Immich Server | Self-hosted photo and video backup solution | `8094` |
| Immich Machine Learning | AI/ML tasks (image recognition, auto-tagging) | - |
| Redis | Cache and message broker for Immich | - |
| PostgreSQL | Database with vector extension for Immich | - |

### Backup (`compose/backup.yaml`)

| Service | Description | Port |
|---|---|---|
| Duplicati | Web-based backup solution with scheduling, encryption, and cloud storage support | `8095` |

## Directory Layout

Storage is split across two disks for optimal performance:

| Disk | Variable | Contents |
|---|---|---|
| **SSD** | `SSD_DIR` | Service configs (`config/`), Immich database |
| **HDD** | `HDD_DIR` | Media files, downloads, photos, backups, sync data |

```
SSD_DIR/
├── config/
│   ├── portainer/
│   ├── filebrowser/
│   ├── transmission/
│   ├── jellyfin/
│   ├── calibre/
│   ├── duplicati/
│   ├── prowlarr/
│   ├── sonarr/
│   └── radarr/
└── immich/
    └── postgres/

HDD_DIR/
├── media/
│   ├── download/
│   ├── movies/
│   ├── tv/
│   └── books/
├── photos/
├── sync/
└── backups/
```

## Usage

1. Clone the repository.
2. Create a `.env` file with the necessary environment variables (see `example.env`).
3. Set `SSD_DIR`, `HDD_DIR`, `UPLOAD_LOCATION`, `BACKUP_LOCATION`, `DB_PASSWORD` in your environment.
4. Do not change `DB_USERNAME`, `DB_DATABASE_NAME`, and `DB_DATA_LOCATION`, see Immich documentation.

### Run all services

```bash
docker compose up -d
```

### Configure the *arr stack (Sonarr/Radarr)

After starting services, autoconfigure the *arr stack:

```bash
./scripts/configure-arr.sh
```

This adds Transmission as the download client and sets up root paths. See [docs/arr-setup.md](docs/arr-setup.md) for the complete setup guide.

### Configure Homepage with custom server URL (optional)

If accessing the dashboard from a different machine, set `SERVER_URL` in your `.env`:

```bash
SERVER_URL=http://192.168.1.50 ./scripts/generate-homepage.sh
```

This updates the dashboard links to point to your server's IP instead of `localhost`. See `scripts/README.md` for details.

### Run a specific stack

```bash
docker compose -f compose/media.yaml --env-file .env up -d
docker compose -f compose/photos.yaml --env-file .env up -d
```

### Stop a specific stack

```bash
docker compose -f compose/media.yaml --env-file .env down
```

## Notes

- Requires Docker Compose v2.20+ (for the `include` directive).
- Customize the environment variables and paths as needed.
- This setup is intended for a local home server and not for production use.
