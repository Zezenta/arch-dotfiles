#!/bin/bash

# ==========================================
# Wallhaven Favorites Rotation Script
# ==========================================
CACHE_DIR="$HOME/.cache/wallhaven"
INTERVAL=600 # Rotate every 10 minutes (600s)

# Ensure hyprpaper is running
if ! pgrep -x "hyprpaper" >/dev/null; then
    hyprpaper &
    sleep 1.0
fi

while true; do
    # Sync new favorites in the background so you don't have to run it manually
    ~/.config/hypr/scripts/wallhaven-sync.sh & >/dev/null 2>&1

    # Get a list of files in the cache directory
    FILES=("$CACHE_DIR"/*)
    
    # If cache is empty, trigger sync script
    if [ ${#FILES[@]} -eq 0 ] || [ ! -e "${FILES[0]}" ]; then
        echo "No wallpapers found in $CACHE_DIR. Syncing first..."
        # Trigger the sync in case cache is empty
        ~/.config/hypr/scripts/wallhaven-sync.sh
        sleep 5
        FILES=("$CACHE_DIR"/*)
    fi
    
    if [ ${#FILES[@]} -gt 0 ] && [ -e "${FILES[0]}" ]; then
        # Choose a random wallpaper from cache
        SELECTED_IMAGE="${FILES[$RANDOM % ${#FILES[@]}]}"
        
        echo "Setting Wallhaven Wallpaper: $SELECTED_IMAGE"
        
        # Unload previous wallpapers from memory (saves RAM)
        hyprctl hyprpaper unload all 2>/dev/null
        
        # Preload and apply the selected wallpaper
        hyprctl hyprpaper preload "$SELECTED_IMAGE" 2>/dev/null
        hyprctl hyprpaper wallpaper "HDMI-A-1,$SELECTED_IMAGE" 2>/dev/null
    fi
    
    sleep $INTERVAL
done
