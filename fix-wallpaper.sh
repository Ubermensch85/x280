#!/bin/bash
# Uccidi vecchie istanze per evitare conflitti
pkill hyprpaper

# Avvia hyprpaper in background senza config (tanto la ignora)
hyprpaper &

# Aspetta che il socket si crei (FONDAMENTALE)
sleep 1

# Immagine da usare
IMG="/home/ubermensch/Immagini/coppia.png"

# Comandi IPC diretti
hyprctl hyprpaper preload "$IMG"
# Applica a TUTTI i monitor (virgola iniziale = wildcard)
hyprctl hyprpaper wallpaper ",$IMG"
