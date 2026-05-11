#!/bin/bash

# Script para mostrar ícono de audio según el dispositivo activo

current_sink=$(pactl get-default-sink)

# Detectar si es audífonos (analógico) o speakers (HDMI)
if [[ "$current_sink" == *"analog-stereo"* ]]; then
    echo '{"text": "󰋋", "tooltip": "Headphones"}'
elif [[ "$current_sink" == *"hdmi-stereo"* ]]; then
    echo '{"text": "󰕾", "tooltip": "Speakers"}'
else
    echo '{"text": "󰋋", "tooltip": "Audio"}'
fi
