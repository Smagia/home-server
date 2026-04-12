#!/bin/bash

# Generate homepage services.yaml from template with configurable server URL
# Usage: ./scripts/generate-homepage.sh
#
# Set SERVER_URL in .env to customize (defaults to http://localhost)
# Example:
#   SERVER_URL=http://192.168.1.50 ./scripts/generate-homepage.sh

set -e

# Load environment variables from .env if it exists
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Default to localhost if not set
SERVER_URL="${SERVER_URL:-http://localhost}"

TEMPLATE="compose/homepage/services.yaml.template"
OUTPUT="compose/homepage/services.yaml"

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: Template not found at $TEMPLATE"
    exit 1
fi

# Substitute SERVER_URL and write to output
export SERVER_URL
envsubst '$SERVER_URL' < "$TEMPLATE" > "$OUTPUT"

echo "✓ Generated homepage config"
echo "  Template: $TEMPLATE"
echo "  Output: $OUTPUT"
echo "  Server URL: $SERVER_URL"
