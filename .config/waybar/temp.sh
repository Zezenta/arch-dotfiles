#!/bin/bash

# Dynamically find the correct hwmon paths by name
# CPU: k10temp (AMD) or coretemp (Intel)
cpu_path=$(grep -lE "k10temp|coretemp" /sys/class/hwmon/hwmon*/name | head -n 1 | sed 's/name/temp1_input/')
# GPU: amdgpu or nvidia
gpu_path=$(grep -lE "amdgpu|nvidia" /sys/class/hwmon/hwmon*/name | head -n 1 | sed 's/name/temp1_input/')

# Fallback to original paths if dynamic detection fails
[ ! -f "$cpu_path" ] && cpu_path="/sys/class/hwmon/hwmon2/temp1_input"
[ ! -f "$gpu_path" ] && gpu_path="/sys/class/hwmon/hwmon1/temp1_input"

cpu_temp=$(cat "$cpu_path" 2>/dev/null | awk '{print int($1/1000)}')
gpu_temp=$(cat "$gpu_path" 2>/dev/null | awk '{print int($1/1000)}')

# Ensure we have a default value if files are missing
[ -z "$cpu_temp" ] && cpu_temp="N/A"
[ -z "$gpu_temp" ] && gpu_temp="N/A"

echo "{\"text\":\" ${cpu_temp}°C\", \"tooltip\":\"CPU: ${cpu_temp}°C\\nGPU: ${gpu_temp}°C\"}"
