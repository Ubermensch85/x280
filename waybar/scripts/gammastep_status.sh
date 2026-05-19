#!/bin/bash

STATE_FILE=~/.cache/display_state

# Legge lo stato attuale (crea il file se non esiste)
[ -f "$STATE_FILE" ] || echo "day" > "$STATE_FILE"

if [[ $(cat "$STATE_FILE") == "night" ]]; then
    echo '{"text": "󰖔", "tooltip": "Filtro luce blu attivo", "class": "attivo"}'
else
    echo '{"text": "󰖨", "tooltip": "Filtro luce blu disattivato", "class": "nonattivo"}'
fi
