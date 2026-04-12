# Home Server Scripts

## generate-homepage.sh

Generates the Homepage dashboard configuration from a template with configurable server URL.

**Usage:**
```bash
./scripts/generate-homepage.sh
```

**What it does:**
- Reads `SERVER_URL` from `.env` (defaults to `http://localhost`)
- Substitutes server URL into the homepage template
- Generates `compose/homepage/services.yaml` with correct hrefs

**When to use:**
- After setting `SERVER_URL` in `.env` to access the dashboard from another machine
- Example: Set `SERVER_URL=http://192.168.1.50` to access from a different host

**Requirements:**
- `.env` file (optional, uses defaults if not present)
- `envsubst` command available (standard on Linux, macOS)

**Examples:**
```bash
# Use default (http://localhost)
./scripts/generate-homepage.sh

# Or set SERVER_URL inline
SERVER_URL=http://192.168.1.50 ./scripts/generate-homepage.sh
```

---

## configure-arr.sh

Autoconfigures Sonarr and Radarr for automated downloads.

**Usage:**
```bash
./scripts/configure-arr.sh
```

**What it does:**
- Waits for all services (Prowlarr, Sonarr, Radarr) to be healthy
- Adds Transmission as the download client for Sonarr & Radarr
- Configures root paths (`/media/tv` and `/media/movies`)
- Enables automatic file organization and hardlinks

**Requirements:**
- Services must be running (`docker compose up -d`)
- `SSD_DIR` environment variable should be set (defaults to current directory)
- Needs `curl` available

**Troubleshooting:**
If the script fails, ensure:
1. All services are running: `docker compose ps`
2. Wait longer for services to initialize (may take 30+ seconds)
3. Config files exist at `${SSD_DIR}/config/sonarr/config.xml` and `${SSD_DIR}/config/radarr/config.xml`
4. Manually configure via web UI as a fallback (see [arr-setup.md](../docs/arr-setup.md))
