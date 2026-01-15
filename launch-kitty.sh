#!/bin/bash

# Ottieni l'ID del workspace attivo in formato JSON pulito
ACTIVE_WS=$(hyprctl activeworkspace -j | jq '.id')

# Se l'ID è esattamente 2 (senza dubbi o spazi strani)
if [ "$ACTIVE_WS" == "2" ]; then
    # Lancia Kitty in modalità speciale (Floating + Centrato)
    kitty --class kitty-float
else
    # Lancia Kitty normale (Tiling)
    kitty
fi
