#!/bin/bash

# Simple script para mostrar ícono de audio (desktop version - solo speakers)

current_sink=$(pactl get-default-sink)

# Desktop: solo muestra speakers, no hay bluetooth
echo '{"text": "", "tooltip": "Speakers"}'
