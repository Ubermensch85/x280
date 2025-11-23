#!/bin/bash

# Configurazioni
TEMP=5600  # Temperatura colore
DEFAULT_BRIGHTNESS=75  # La tua preferenza
BRIGHTNESS_STEP=2  # Passo regolazione luminosità

case "$1" in
    "temp")
        # Gestione luce blu
        if pgrep -x gammastep >/dev/null; then
            pkill gammastep
            notify-send "Gammastep" "Filtro luce blu disattivata"
        else
            gammastep -O "$TEMP" 2>/dev/null &
            notify-send "Gammastep" "Filtro luce blu attivata a ${TEMP}K"
        fi
        ;;
    "brightness-up")
        brightnessctl -d intel_backlight set "${BRIGHTNESS_STEP}%+"
        ;;
    "brightness-down")
        brightnessctl -d intel_backlight set "${BRIGHTNESS_STEP}%-"
        ;;
    *)
        echo "Usage: $0 [temp|brightness-up|brightness-down]"
        exit 1
        ;;
esac
