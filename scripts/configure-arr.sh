#!/bin/bash

# Configure *arr stack (Prowlarr, Sonarr, Radarr) for automated downloads
# Usage: ./scripts/configure-arr.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROWLARR_URL="http://localhost:8099"
SONARR_URL="http://localhost:8097"
RADARR_URL="http://localhost:8098"

# Helper functions
wait_for_service() {
    local url=$1
    local name=$2
    local max_attempts=60
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -s "$url/api" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ $name is ready${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        if [ $((attempt % 5)) -eq 0 ]; then
            echo "Waiting for $name... ($attempt/$max_attempts)"
        fi
        sleep 1
    done

    echo -e "${RED}✗ $name failed to start${NC}"
    return 1
}

get_api_key() {
    local config_file=$1
    if [ -f "$config_file" ]; then
        grep -oP '(?<=<ApiKey>)[^<]+' "$config_file" 2>/dev/null || echo ""
    fi
}

configure_download_client() {
    local service_name=$1
    local service_url=$2
    local config_path=$3
    local category=$4

    echo -e "${YELLOW}Configuring $service_name...${NC}"

    # Get API key from config file
    local api_key=$(get_api_key "$config_path")

    if [ -z "$api_key" ]; then
        echo -e "${YELLOW}⚠ Could not find API key for $service_name${NC}"
        echo "  Please configure manually or wait for the config file to be created"
        return 1
    fi

    # Check if Transmission is already configured
    if curl -s -H "X-Api-Key: $api_key" "$service_url/api/v3/downloadclient" 2>/dev/null | grep -q "Transmission"; then
        echo -e "${YELLOW}✓ Transmission already configured in $service_name${NC}"
        return 0
    fi

    # Add Transmission as download client
    local config_json="{
      \"enable\": true,
      \"protocol\": \"torrent\",
      \"priority\": 1,
      \"name\": \"Transmission\",
      \"implementation\": \"Transmission\",
      \"configContract\": \"TransmissionSettings\",
      \"fields\": [
        {\"name\": \"host\", \"value\": \"transmission-container\"},
        {\"name\": \"port\", \"value\": 9091},
        {\"name\": \"useSsl\", \"value\": false},
        {\"name\": \"urlBase\", \"value\": \"/transmission/\"},
        {\"name\": \"username\", \"value\": \"\"},
        {\"name\": \"password\", \"value\": \"\"},
        {\"name\": \"$([ \"$service_name\" = \"Sonarr\" ] && echo \"tvCategory\" || echo \"movieCategory\")\", \"value\": \"$category\"},
        {\"name\": \"addPaused\", \"value\": false}
      ]
    }"

    if curl -s -X POST \
      -H "X-Api-Key: $api_key" \
      -H "Content-Type: application/json" \
      "$service_url/api/v3/downloadclient" \
      -d "$config_json" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Transmission added to $service_name${NC}"
    else
        echo -e "${RED}✗ Failed to add Transmission to $service_name${NC}"
        return 1
    fi

    return 0
}

configure_root_path() {
    local service_name=$1
    local service_url=$2
    local config_path=$3
    local media_path=$4

    # Get API key
    local api_key=$(get_api_key "$config_path")

    if [ -z "$api_key" ]; then
        return 1
    fi

    # Check if path already exists
    if curl -s -H "X-Api-Key: $api_key" "$service_url/api/v3/rootfolder" 2>/dev/null | grep -q "$media_path"; then
        echo -e "${YELLOW}✓ Root path already configured in $service_name${NC}"
        return 0
    fi

    # Add root path
    local path_json="{
      \"path\": \"$media_path\",
      \"accessible\": true,
      \"unmappedFolders\": []
    }"

    if curl -s -X POST \
      -H "X-Api-Key: $api_key" \
      -H "Content-Type: application/json" \
      "$service_url/api/v3/rootfolder" \
      -d "$path_json" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Root path added to $service_name${NC}"
    else
        echo -e "${YELLOW}✗ Could not add root path to $service_name (may already exist)${NC}"
    fi

    return 0
}

# Main script
echo -e "${YELLOW}Waiting for services to be healthy...${NC}\n"

wait_for_service "$PROWLARR_URL" "Prowlarr" || exit 1
wait_for_service "$SONARR_URL" "Sonarr" || exit 1
wait_for_service "$RADARR_URL" "Radarr" || exit 1

echo ""

# Wait a bit more for config files to be created
sleep 2

# Configure Sonarr
SSD_DIR="${SSD_DIR:-.}"
SONARR_CONFIG="${SSD_DIR}/config/sonarr/config.xml"
RADARR_CONFIG="${SSD_DIR}/config/radarr/config.xml"

if [ ! -f "$SONARR_CONFIG" ]; then
    echo -e "${YELLOW}⚠ Sonarr config not found at $SONARR_CONFIG${NC}"
    echo "  Services may still be initializing. Try again in 10 seconds."
    exit 1
fi

configure_download_client "Sonarr" "$SONARR_URL" "$SONARR_CONFIG" "tv"
configure_root_path "Sonarr" "$SONARR_URL" "$SONARR_CONFIG" "/media/tv"

echo ""

# Configure Radarr
if [ ! -f "$RADARR_CONFIG" ]; then
    echo -e "${YELLOW}⚠ Radarr config not found at $RADARR_CONFIG${NC}"
    echo "  Services may still be initializing. Try again in 10 seconds."
    exit 1
fi

configure_download_client "Radarr" "$RADARR_URL" "$RADARR_CONFIG" "movies"
configure_root_path "Radarr" "$RADARR_URL" "$RADARR_CONFIG" "/media/movies"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Arr stack autoconfiguration complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Add indexers to Prowlarr (http://localhost:8099)"
echo "2. Connect Sonarr & Radarr to Prowlarr (Settings → Apps)"
echo "3. Add your first show/movie in Sonarr/Radarr"
echo ""
echo "For detailed setup guide, see: docs/arr-setup.md"
