#!/bin/bash

# Get bluetooth connected devices with battery info

# Check if bluetooth hardware exists
if ! rfkill list bluetooth &>/dev/null || [ -z "$(rfkill list bluetooth 2>/dev/null)" ]; then
    # No bluetooth hardware found, hide module completely
    # Return empty output to make waybar ignore the module
    exit 0
fi

# Check if bluetooth is enabled
if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
    printf '{"text": "", "tooltip": "Bluetooth disabled", "class": "disabled"}'
    exit 0
fi

# Get connected devices via upower (more reliable for battery info)
bt_devices=$(upower --enumerate | grep -E "headset|audio|input_dev" | grep -v "BAT0")

if [ -z "$bt_devices" ]; then
    # No devices connected, check if bluetooth is on but no devices
    printf '{"text": "", "tooltip": "Bluetooth on - no devices connected", "class": "disabled"}'
    exit 0
fi

# Build tooltip and count
tooltip=""
count=0
first=true

while IFS= read -r device; do
    if [ -n "$device" ]; then
        # Get device info
        device_info=$(upower -i "$device" 2>/dev/null)
        if [ $? -eq 0 ]; then
            model=$(echo "$device_info" | grep "model:" | sed 's/.*model: *//' | sed 's/^[[:space:]]*//')
            percentage=$(echo "$device_info" | grep "percentage:" | sed 's/.*percentage: *//' | sed 's/^[[:space:]]*//')

            if [ -n "$model" ]; then
                count=$((count + 1))

                if [ "$first" = true ]; then
                    first=false
                else
                    tooltip="${tooltip}\n"
                fi

                if [ -n "$percentage" ]; then
                    tooltip="${tooltip}${model}: ${percentage}"
                else
                    tooltip="${tooltip}${model}: N/A"
                fi
            fi
        fi
    fi
done <<< "$bt_devices"

if [ $count -eq 0 ]; then
    printf '{"text": "", "tooltip": "Bluetooth on - no devices connected", "class": "disconnected"}'
    exit 0
fi

# Set icon and text
if [ $count -eq 1 ]; then
    text=""
else
    text=" ${count}"
fi

# Build JSON output
printf '{"text": "%s", "tooltip": "%s", "class": "enabled"}' "$text" "$tooltip"
