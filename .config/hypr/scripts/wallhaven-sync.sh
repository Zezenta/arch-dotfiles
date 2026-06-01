#!/bin/bash

# ==========================================
# Wallhaven Favorites Sync Script
# ==========================================
# Load environment credentials
ENV_FILE="$(dirname "$0")/wallhaven.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Error: Credentials environment file not found at $ENV_FILE"
    exit 1
fi

USERNAME="$WALLHAVEN_USERNAME"
API_KEY="$WALLHAVEN_API_KEY"
COLLECTION_NAME="Default" # Name of the collection to sync
CACHE_DIR="$HOME/.cache/wallhaven"

# Create cache directory
mkdir -p "$CACHE_DIR"

if [ -z "$USERNAME" ]; then
    echo "Please set WALLHAVEN_USERNAME in $ENV_FILE"
    exit 1
fi

# 1. Fetch user collections to find the Collection ID
if [ -n "$API_KEY" ]; then
    URL="https://wallhaven.cc/api/v1/collections?apikey=$API_KEY"
else
    URL="https://wallhaven.cc/api/v1/collections/$USERNAME"
fi

echo "Fetching collections from Wallhaven..."
COLLECTIONS_JSON=$(curl -s "$URL")

# Get collection ID matching the configured name
COLLECTION_ID=$(echo "$COLLECTIONS_JSON" | jq -r --arg label "$COLLECTION_NAME" '.data[] | select(.label == $label) | .id')

if [ -z "$COLLECTION_ID" ] || [ "$COLLECTION_ID" = "null" ]; then
    echo "Error: Collection '$COLLECTION_NAME' not found!"
    exit 1
fi

echo "Found collection '$COLLECTION_NAME' with ID: $COLLECTION_ID"

# 2. Fetch all wallpaper paths from the collection (handling pagination)
PAGE=1
while true; do
    echo "Querying wallpapers page $PAGE..."
    if [ -n "$API_KEY" ]; then
        WALLPAPERS_URL="https://wallhaven.cc/api/v1/collections/$USERNAME/$COLLECTION_ID?apikey=$API_KEY&page=$PAGE"
    else
        WALLPAPERS_URL="https://wallhaven.cc/api/v1/collections/$USERNAME/$COLLECTION_ID?page=$PAGE"
    fi
    
    RESPONSE=$(curl -s "$WALLPAPERS_URL")
    PATHS=$(echo "$RESPONSE" | jq -r '.data[].path' 2>/dev/null)
    
    if [ -z "$PATHS" ] || [ "$PATHS" = "null" ]; then
        break
    fi
    
    # Download each wallpaper if not already cached
    for img_url in $PATHS; do
        filename=$(basename "$img_url")
        if [ ! -f "$CACHE_DIR/$filename" ]; then
            echo "Downloading new wallpaper: $filename"
            curl -s -o "$CACHE_DIR/$filename" "$img_url"
        fi
    done
    
    # Check if there is a next page
    HAS_NEXT=$(echo "$RESPONSE" | jq -r '.meta.current_page < .meta.last_page' 2>/dev/null)
    if [ "$HAS_NEXT" != "true" ]; then
        break
    fi
    
    PAGE=$((PAGE + 1))
done

echo "Synchronization complete! Cached wallpapers are stored in $CACHE_DIR"
