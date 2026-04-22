#!/usr/bin/env python3
import os
import sys
import subprocess

# Configuración Ultra-Reactiva de cava
config_path = os.path.expanduser("~/.config/waybar/cava_config")
with open(config_path, "w") as f:
    f.write("""
[general]
framerate = 120
bars = 14
autosens = 1
sensitivity = 100

[smoothing]
integral = 0
gravity = 1500
ignore = 0

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
""")

# Mapeo de caracteres optimizado
dict_bars = {
    '0': ' ', '1': '▂', '2': '▃', '3': '▄', 
    '4': '▅', '5': '▆', '6': '▇', '7': '█', ';': ''
}

# Ejecución con buffer mínimo para evitar lag
process = subprocess.Popen(["cava", "-p", config_path], 
                         stdout=subprocess.PIPE, 
                         text=True, 
                         bufsize=1)

try:
    while True:
        line = process.stdout.readline()
        if not line:
            break

        # Procesamiento ultra rápido de la cadena
        clean_line = line.strip().replace(';', '')
        output = "".join(dict_bars.get(c, '') for c in clean_line)

        # Solo mostrar output si hay actividad de audio (no todo espacio)
        if output.strip():
            sys.stdout.write(output + '\n')
        else:
            sys.stdout.write('\n')

        sys.stdout.flush()
except KeyboardInterrupt:
    process.terminate()
