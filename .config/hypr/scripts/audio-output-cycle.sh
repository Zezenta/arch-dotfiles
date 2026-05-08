#!/bin/bash

# Cycle to the next audio output device

# Get list of sink IDs
sinks=$(pactl list short sinks | awk '{print $1}')
sink_array=($sinks)

# Get current default sink
current_sink=$(pactl get-default-sink)
current_id=$(pactl list short sinks | awk -v sink="$current_sink" '$2 == sink {print $1; exit}')

# Find current index
for i in "${!sink_array[@]}"; do
    if [[ "${sink_array[$i]}" == "$current_id" ]]; then
        current_index=$i
        break
    fi
done

# Calculate next index (wrap around)
next_index=$(( (current_index + 1) % ${#sink_array[@]} ))

# Get the next sink name
next_id=${sink_array[$next_index]}
next_sink=$(pactl list short sinks | awk -v id="$next_id" '$1 == id {print $2; exit}')

# Set as default
pactl set-default-sink "$next_sink"

# Send signal to waybar to update audio icon
pkill -SIGRTMIN+10 waybar 2>/dev/null

# Get friendly name for notification
friendly_name=$(pactl list sinks | grep -A 20 "Sink #$next_id" | grep "Description:" | sed 's/.*Description: //')

notify-send "Audio Output" "Changed to: $friendly_name"
