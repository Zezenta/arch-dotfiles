#!/bin/bash

# Get battery info with hardware detection

# Check if battery hardware exists
if ! ls /sys/class/power_supply/BAT* &>/dev/null; then
    # No battery hardware found, hide module completely
    exit 0
fi

# Get battery info
capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)

if [ -z "$capacity" ]; then
    exit 0
fi

# Determine icon and class
if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    icon="󰂄"
    class="charging"
elif [ "$capacity" -le 15 ]; then
    icon="󰂎"
    class="critical"
elif [ "$capacity" -le 30 ]; then
    icon="󰁺"
    class="warning"
elif [ "$capacity" -le 50 ]; then
    icon="󰁻"
    class="normal"
elif [ "$capacity" -le 60 ]; then
    icon="󰁼"
    class="normal"
elif [ "$capacity" -le 70 ]; then
    icon="󰁽"
    class="normal"
elif [ "$capacity" -le 80 ]; then
    icon="󰁾"
    class="normal"
elif [ "$capacity" -le 90 ]; then
    icon="󰁿"
    class="normal"
elif [ "$capacity" -le 100 ]; then
    icon="󰁹"
    class="normal"
fi

# Build JSON output
printf '{"text": "%s %s%%", "tooltip": "Battery: %s%% (%s)", "class": "%s"}' "$icon" "$capacity" "$capacity" "$status" "$class"
