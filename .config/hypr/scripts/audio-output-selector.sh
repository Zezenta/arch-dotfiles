#!/bin/bash

# Auto-enable any cards that are set to "off" but have an "available: yes" profile
# (excluding "pro-audio" which is typically not wanted for simple stereo switching).
while read -r card profile; do
    if [ -n "$card" ] && [ -n "$profile" ]; then
        pactl set-card-profile "$card" "$profile"
    fi
done < <(pactl list cards | awk '
    /^Card #/ { card_name="" }
    /Name:/ { card_name=$2 }
    /^[ \t]+[a-zA-Z0-9_:-]+:[ \t]+.*\(sinks: [1-9].*available: yes\)/ {
        profile=$1; sub(/:$/, "", profile)
        if (profile != "pro-audio" && card_name != "") {
            available_profiles[card_name] = profile
        }
    }
    /Active Profile: off/ {
        if (card_name in available_profiles) {
            print card_name, available_profiles[card_name]
        }
    }
')

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

    # Send signal to waybar to update audio icon
    pkill -SIGRTMIN+10 waybar 2>/dev/null

    # Get the friendly name for notification
    friendly_name=$(echo "$selection" | cut -d'|' -f2)

    # Notify the user
    notify-send "Audio Output" "Changed to: $friendly_name"
fi
