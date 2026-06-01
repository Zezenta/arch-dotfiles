#!/bin/bash

# ==========================================
# Wallpaper Mode Toggle (3 Modes)
# ==========================================
# Toggles between:
# 1. 'adamcreation' - Static local wallpaper via hyprpaper
# 2. 'wallpaperengine' - Animated wallpapers via linux-wallpaperengine
# 3. 'wallhaven' - Static rolling wallpapers from Wallhaven favorites

MODE_FILE="$HOME/.config/hypr/scripts/wallpaper-mode.txt"

# Determine if we are restoring the saved state or cycling
CYCLE=true
if [ "$1" = "--restore" ]; then
    CYCLE=false
fi

# Load current mode from file, default to 'adamcreation'
if [ -f "$MODE_FILE" ]; then
    CURRENT_MODE=$(cat "$MODE_FILE")
else
    CURRENT_MODE="adamcreation"
fi

# Clean up all active rotation loops and engines
pkill -9 -f "linux-wallpaperengine"
pkill -9 -f "wallpaper-rotation.sh"
pkill -9 -f "wallpaper-wallhaven-rotation.sh"

if [ "$CYCLE" = "true" ]; then
    # Cycle to the next mode
    if [ "$CURRENT_MODE" = "adamcreation" ]; then
        NEXT_MODE="wallpaperengine"
    elif [ "$CURRENT_MODE" = "wallpaperengine" ]; then
        NEXT_MODE="wallhaven"
    else
        NEXT_MODE="adamcreation"
    fi
    echo "Switching wallpaper mode from $CURRENT_MODE to $NEXT_MODE..."
    echo "$NEXT_MODE" > "$MODE_FILE"
    ACTIVE_MODE="$NEXT_MODE"
else
    echo "Restoring saved wallpaper mode: $CURRENT_MODE..."
    ACTIVE_MODE="$CURRENT_MODE"
fi

# Launch the selected mode
if [ "$ACTIVE_MODE" = "adamcreation" ]; then
    # Ensure hyprpaper is running
    pkill -x hyprpaper 2>/dev/null
    sleep 0.2
    hyprpaper &
    sleep 1.0
    
    # Set the static adamcreation wallpaper
    WALLPAPER="$HOME/.config/hypr/../../assets/wallpaperadamcreation.jpg"
    hyprctl hyprpaper unload all 2>/dev/null
    hyprctl hyprpaper preload "$WALLPAPER" 2>/dev/null
    hyprctl hyprpaper wallpaper "HDMI-A-1,$WALLPAPER" 2>/dev/null

elif [ "$ACTIVE_MODE" = "wallpaperengine" ]; then
    # Kill hyprpaper to save GPU/RAM resources
    pkill -x hyprpaper 2>/dev/null
    sleep 0.2
    
    # Start the wallpaper engine rotation loop
    "$HOME/.config/hypr/scripts/wallpaper-rotation.sh" &

elif [ "$ACTIVE_MODE" = "wallhaven" ]; then
    # Ensure hyprpaper is running
    pkill -x hyprpaper 2>/dev/null
    sleep 0.2
    hyprpaper &
    sleep 1.0
    
    # Start the Wallhaven rotation loop
    "$HOME/.config/hypr/scripts/wallpaper-wallhaven-rotation.sh" &
fi
