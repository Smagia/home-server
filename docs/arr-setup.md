# *arr Stack Setup & Automation Guide

This guide covers setting up Prowlarr, Sonarr, and Radarr for fully automated media downloads and organization.

## Architecture

```
You select show in Sonarr/Radarr
         ↓
    Prowlarr searches indexers
         ↓
  Transmission downloads torrent
         ↓
    Sonarr/Radarr moves to /media/tv or /media/movies
         ↓
    Jellyfin displays the media
```

## Quick Start

### 1. Start the services
```bash
docker compose up -d
```

### 2. Wait ~30 seconds, then run the autoconfiguration script
```bash
./scripts/configure-arr.sh
```

This script will:
- ✓ Wait for all services to be healthy
- ✓ Add Transmission as the download client for Sonarr & Radarr
- ✓ Add root paths (`/media/tv` and `/media/movies`)
- ✓ Enable hardlink support (no disk duplication)

### 3. Configure Transmission's download directory (Important!)
Visit `http://localhost:8090` and set the download directory to `/media/download`:
1. Go to Edit → Preferences
2. Click "Directories"
3. Set "Download to" to `/media/download`
4. Save and close

This ensures hardlinks work correctly — all files on the same `/media` mount point.

## What Still Needs Manual Setup

### Prowlarr (Indexer Manager)
Visit `http://localhost:8099`

**Add indexers:**
1. Go to Settings → Indexers
2. Click "Add" and search for your preferred indexers (e.g., The Pirate Bay, 1337x, etc.)
3. Enable them

**Connect to Sonarr/Radarr:**
1. Go to Settings → Apps
2. Click "+" to add Sonarr:
   - Name: `Sonarr`
   - URL: `http://sonarr:8989`
   - API Key: (get from Sonarr settings)
   - Sync Profile: `Standard`
3. Repeat for Radarr:
   - Name: `Radarr`
   - URL: `http://radarr:7878`
   - API Key: (get from Radarr settings)

### Sonarr (TV Shows)
Visit `http://localhost:8097`

The script should have already configured:
- ✓ Transmission as download client
- ✓ Root path: `/media/tv`

**Verify and add shows:**
1. Go to Settings → Download Clients → Verify "Transmission" is there
2. Go to Settings → Media Management → Root Paths → Verify `/media/tv` exists
3. Add a series:
   - Click "+ Add New Series"
   - Search for a show
   - Monitor episodes, set quality, click "Add Series"

### Radarr (Movies)
Visit `http://localhost:8098`

The script should have already configured:
- ✓ Transmission as download client
- ✓ Root path: `/media/movies`

**Verify and add movies:**
1. Go to Settings → Download Clients → Verify "Transmission" is there
2. Go to Settings → Media Management → Root Paths → Verify `/media/movies` exists
3. Add a movie:
   - Click "+ Add New Movie"
   - Search for a movie
   - Set quality and profile, click "Add Movie"

## The Complete Workflow

### Adding a TV Show
1. Open Sonarr (http://localhost:8097)
2. Click "+ Add New Series"
3. Search for the show, select it
4. Choose quality profile and monitored seasons
5. Click "Add Series"
6. Sonarr searches Prowlarr indexers automatically
7. When found, Transmission downloads it
8. Sonarr moves it to `/media/tv/{Show Name}/Season 1/`
9. It appears in Jellyfin

### Adding a Movie
1. Open Radarr (http://localhost:8098)
2. Click "+ Add New Movie"
3. Search for the movie, select it
4. Choose quality profile
5. Click "Add Movie"
6. Radarr searches Prowlarr indexers automatically
7. When found, Transmission downloads it
8. Radarr moves it to `/media/movies/{Movie Name}.{Year}/`
9. It appears in Jellyfin

## Directory Structure

After adding media, your disk will look like:
```
${HDD_DIR}/media/
├── download/              # Temp folder for incomplete downloads
│   └── Show.S01E01.mkv
├── tv/                    # Organized TV shows
│   ├── Breaking Bad/
│   │   ├── Season 1/
│   │   │   └── episode files...
│   │   └── Season 2/
│   └── The Office/
│       └── Season 1/
├── movies/                # Organized movies
│   ├── Inception (2010)/
│   │   └── Inception.2010.1080p.mkv
│   └── The Matrix/
│       └── The.Matrix.1999.mkv
└── anime/ (if needed)     # Anime goes here
```

## Troubleshooting

### Script fails to find API keys
The script looks for `config.xml` files that are only created after the first startup. If the script can't find API keys:
1. Wait another 30 seconds and retry
2. Or manually get the API key:
   - Sonarr: Settings → General → API Key (copy it)
   - Radarr: Settings → General → API Key (copy it)

### Transmission not connecting
Check that Transmission is running:
```bash
docker compose -f compose/media.yaml ps
```

Verify the container name matches: should be `transmission-container` (from your `media.yaml`)

### Shows not downloading
1. **Indexers not added** → Add them in Prowlarr
2. **Prowlarr not connected** → Check Prowlarr Settings → Apps
3. **Quality profiles not set** → Sonarr/Radarr Settings → Quality
4. **Transmission download directory** → Verify `Download to` is set to `/media/download` (Edit → Preferences → Directories)
5. **Disk space** → Check that `/media` has free space

## Manual Configuration (If Script Fails)

If the script doesn't work, you can configure manually through the web UI:

### Sonarr Manual Setup
1. Go to http://localhost:8097/settings/downloadclient
2. Click "+", select "Transmission"
3. Set:
   - Host: `transmission-container`
   - Port: `9091`
   - URL Base: `/transmission/`
   - Category: `tv`
4. Save
5. Go to http://localhost:8097/settings/mediamanagement
6. Click "Add Root Path"
7. Set path to `/media/tv`

### Radarr Manual Setup
1. Go to http://localhost:8098/settings/downloadclient
2. Click "+", select "Transmission"
3. Set:
   - Host: `transmission-container`
   - Port: `9091`
   - URL Base: `/transmission/`
   - Category: `movies`
4. Save
5. Go to http://localhost:8098/settings/mediamanagement
6. Click "Add Root Path"
7. Set path to `/media/movies`

## Key Concepts

### Hardlinks
Your setup uses hardlinks (not copies). This means:
- No disk duplication
- Moving files is instant
- If you delete a file from `/media`, it's gone everywhere it was linked

### Download Path vs Final Path
- Download path: `/media/download/` (Transmission downloads here)
- Final path: `/media/tv/` or `/media/movies/` (Sonarr/Radarr moves it here)
- Sonarr/Radarr automatically moves with hardlinks

### Monitoring
In Sonarr/Radarr, "Monitoring" means:
- ✓ Search for this media when looking for releases
- ✓ Alert when new episodes/movies are available
- You can toggle per show/movie

## API Keys

Never share your API keys! They're in:
- Sonarr: Settings → General → API Key
- Radarr: Settings → General → API Key
- Prowlarr: Settings → General → API Key

## Next Steps

1. ✓ Run the autoconfiguration script
2. Add indexers in Prowlarr
3. Connect Prowlarr to Sonarr/Radarr
4. Add your first show/movie
5. Watch it download automatically!

For detailed docs on each service:
- [Sonarr Wiki](https://wiki.servarr.com/sonarr)
- [Radarr Wiki](https://wiki.servarr.com/radarr)
- [Prowlarr Wiki](https://wiki.servarr.com/prowlarr)
