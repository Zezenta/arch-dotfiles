#!/bin/bash

# Esperar a que el servidor de pantalla (X11/XWayland) esté listo
while ! xset q &>/dev/null; do
    sleep 0.5
done

# Configuration
WORKSHOP_DIR="$HOME/.local/share/Steam/steamapps/workshop/content/431960/"
ASSETS_DIR="$HOME/.local/share/Steam/steamapps/common/wallpaper_engine/assets/"
INTERVAL=1200 # 20 minutes

#IDs confirmados
WALLPAPER_IDS=(
    "3616303231"  # Anime Girl 5 (Off)
    "2717303788"  # Rei ayanami
    "3049063511"  # valorant | killjoy | ( by: SuperLens)
)
# Limpiar hyprpaper si está corriendo
pkill -x hyprpaper 2>/dev/null

while true; do
    SELECTED_ID=${WALLPAPER_IDS[$RANDOM % ${#WALLPAPER_IDS[@]}]}

    # Matar instancias previas
    pkill -9 -f "linux-wallpaperengine"

    # Ejecutar con el entorno de librerías correcto
    env LD_LIBRARY_PATH=/opt/linux-wallpaperengine \
    /opt/linux-wallpaperengine/linux-wallpaperengine \
    --assets-dir "$ASSETS_DIR" \
    --screen-root HDMI-A-1 \
    --bg "$WORKSHOP_DIR/$SELECTED_ID/" \
    --scaling fill --fps 30 --silent &

    sleep $INTERVAL
done
