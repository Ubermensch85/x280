#!/bin/bash

set -e

MAX_RETRIES=3
COUNTRIES="Italy,Switzerland"

for ((i=1; i<=MAX_RETRIES; i++)); do
    echo "[*] Tentativo $i di $MAX_RETRIES..."
    if sudo reflector \
        --country "$COUNTRIES" \
        --age 12 \
        --protocol https \
        --sort rate \
        --save /etc/pacman.d/mirrorlist; then
        echo "[+] Mirrorlist aggiornata con successo."
        break
    else
        echo "[!] Errore al tentativo $i, riprovo..."
        sleep 3
    fi
done

echo "[*] Aggiornamento sistema con yay..."
yay -Syyu --devel --noconfirm

echo "[*] Pulizia cache pacman e yay..."
yes | yay -Sc
yes | yay -Scc
yes | sudo pacman -Sc
yes | sudo pacman -Scc

echo "[*] Rigenerazione Systemd-boot..."
sudo bootctl update

echo "[*] Aggiornamento completato!"
