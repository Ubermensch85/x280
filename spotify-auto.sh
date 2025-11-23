#!/bin/bash

CONFIG="$HOME/.config/waybar/config-spotify"
STYLE="$HOME/.config/waybar/style.css"

while true; do
    # 1. Trova dinamicamente il nome del player che contiene "brave"
    PLAYER=$(playerctl -l 2>/dev/null | grep "brave" | head -n 1)

    # Variabile di controllo: 1 se la waybar-spotify è attiva, 0 se no
    if pgrep -f "waybar -c $CONFIG" > /dev/null; then
        BAR_RUNNING=1
    else
        BAR_RUNNING=0
    fi

    # Se non c'è nessun player Brave attivo
    if [ -z "$PLAYER" ]; then
        if [ $BAR_RUNNING -eq 1 ]; then
            pkill -f "waybar -c $CONFIG"
        fi
    else
        # 2. Ottieni lo stato (Playing, Paused, Stopped)
        STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)

        # LOGICA: 
        # Se sta suonando (Playing) E la barra è spenta -> ACCENDI
        if [[ "$STATUS" == "Playing" ]] && [[ $BAR_RUNNING -eq 0 ]]; then
            waybar -c "$CONFIG" -s "$STYLE" &
        
        # Se NON sta suonando (Stopped) E la barra è accesa -> SPEGNI
        # Nota: Ho incluso 'Stopped'. Se metti in pausa (Paused), la barra RIMANE (utile per vedere cosa ascoltavi).
        # Se vuoi che sparisca anche in pausa, cambia in: [[ "$STATUS" != "Playing" ]]
        elif [[ "$STATUS" == "Stopped" ]] && [[ $BAR_RUNNING -eq 1 ]]; then
            pkill -f "waybar -c $CONFIG"
        fi
    fi

    sleep 2
done
