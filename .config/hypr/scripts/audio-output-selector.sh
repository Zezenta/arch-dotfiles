#!/bin/bash

# Get list of audio sinks (output devices)
devices=$(pactl list short sinks)

# Count devices
count=$(echo "$devices" | wc -l)

if [ "$count" -eq 0 ]; then
    notify-send "Audio" "No audio output devices found"
    exit 1
fi

# Create wofi menu with device names
selection=$(echo "$devices" | awk '{print $1 "\t" $2}' | while read -r id name; do
    # Get a friendly name for the device
    friendly_name=$(pactl list sinks | grep -A 20 "Sink #$id" | grep "Description:" | sed 's/.*Description: //')
    echo "$id|$friendly_name"
done | wofi --dmenu --insensitive --prompt "Select Audio Output" --style ~/.config/wofi/style.css 2>/dev/null)

# Get the selected device ID
if [ -n "$selection" ]; then
    device_id=$(echo "$selection" | cut -d'|' -f1)
    device_name=$(pactl list sinks short | awk -v id="$device_id" '$1 == id {print $2; exit}')

    # Set the default sink
    pactl set-default-sink "$device_name"

    # Get the friendly name for notification
    friendly_name=$(echo "$selection" | cut -d'|' -f2)

    # Notify the user
    notify-send "Audio Output" "Changed to: $friendly_name"
fi
