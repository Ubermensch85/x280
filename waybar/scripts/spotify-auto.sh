#!/bin/bash

CONFIG="$HOME/.config/waybar/config-spotify"
STYLE="$HOME/.config/waybar/style.css"

while true; do
    # 1. Trova l'istanza di Brave
    PLAYER=$(playerctl -l 2>/dev/null | grep "brave" | head -n 1)

    # Verifica se la barra waybar-spotify è già in esecuzione
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
        # 2. Estrai Stato e Album
        STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
        # Se xesam:album esiste, è musica (Spotify). Se è vuoto, è video (YouTube/Rai).
        ALBUM=$(playerctl -p "$PLAYER" metadata xesam:album 2>/dev/null)

        if [[ -n "$ALBUM" ]]; then
            IS_MUSIC=1
        else
            IS_MUSIC=0
        fi

        # --- AZIONI ---

        # ACCENDI: Sta suonando + È Musica + Barra spenta
        # RIMOSSO: --name "bottombar" (causava l'errore)
        if [[ "$STATUS" == "Playing" ]] && [[ $IS_MUSIC -eq 1 ]] && [[ $BAR_RUNNING -eq 0 ]]; then
            waybar -c "$CONFIG" -s "$STYLE" &
        
        # SPEGNI: (Non suona PIÙ) OPPURE (Non è più musica) + Barra accesa
        elif { [[ "$STATUS" != "Playing" ]] || [[ $IS_MUSIC -eq 0 ]]; } && [[ $BAR_RUNNING -eq 1 ]]; then
            pkill -f "waybar -c $CONFIG"
        fi
    fi

    sleep 2
done
