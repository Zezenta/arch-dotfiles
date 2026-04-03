#!/bin/bash

# Get current brightness using ddcutil
# VCP 10 is the code for Brightness
brightness=$(ddcutil getvcp 10 --brief | awk '{print $4}' | sed 's/,//')

if [ -z "$brightness" ]; then
    brightness="N/A"
fi

echo "{\"text\":\"󰃠 ${brightness}%\", \"tooltip\":\"Monitor Brightness: ${brightness}%\"}"
