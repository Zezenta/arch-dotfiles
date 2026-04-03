#!/bin/bash

# Toggle between linux-wallpaperengine and hyprpaper
# Kills the active one and starts the other to save resources

# Comprobar si linux-wallpaperengine está corriendo
if pgrep -f "linux-wallpaperengine" >/dev/null; then
    echo "Switching to hyprpaper..."
    # Matar el motor y el script de rotación por completo para no gastar recursos
    pkill -9 -f "linux-wallpaperengine"
    pkill -9 -f "wallpaper-rotation.sh"

    # Esperar un momento para asegurar que los recursos se liberan (memoria/GPU)
    sleep 0.5

    # Matar cualquier instancia previa de hyprpaper para evitar conflictos
    pkill -9 hyprpaper 2>/dev/null
    sleep 0.2

    # Iniciar hyprpaper
    hyprpaper &

    # Esperar a que hyprpaper inicie y cargar el wallpaper
    sleep 1.0
    # Precargar y establecer el wallpaper explícitamente (usando hyprctl para asegurar que se aplica)
    hyprctl hyprpaper preload "~/.config/hypr/../../assets/wallpaperadamcreation.jpg" 2>/dev/null
    hyprctl hyprpaper wallpaper "HDMI-A-1,~/.config/hypr/../../assets/wallpaperadamcreation.jpg" 2>/dev/null

# Si no está corriendo el motor, comprobamos si está hyprpaper
elif pgrep -x "hyprpaper" >/dev/null; then
    echo "Switching to linux-wallpaperengine..."
    # Matar hyprpaper
    pkill -x "hyprpaper"

    # Esperar un momento
    sleep 0.5

    # Iniciar script de rotación del motor
    ~/.config/hypr/scripts/wallpaper-rotation.sh &
else
    # Si ninguno corre (al iniciar la PC), arrancamos hyprpaper por defecto
    echo "Starting hyprpaper as default..."
    hyprpaper &
    sleep 1.0
    hyprctl hyprpaper preload "~/.config/hypr/../../assets/wallpaperadamcreation.jpg" 2>/dev/null
    hyprctl hyprpaper wallpaper "HDMI-A-1,~/.config/hypr/../../assets/wallpaperadamcreation.jpg" 2>/dev/null
fi
