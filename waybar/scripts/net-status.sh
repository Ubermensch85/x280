#!/bin/bash

# Definisci le icone (Iosevka Nerd Font)
ICON_WIFI=" "     # Icona Wi-Fi
ICON_ETHERNET=""  # Icona Ethernet
ICON_VPN=""       # Icona VPN (lucchetto per sicurezza)
ICON_DISCONNECTED="⚠" # Icona Disconnesso

# Forziamo l'output di nmcli in inglese per una parsing più affidabile
# anche se nmcli può avere output misto, è meglio cercare i termini più precisi.
export LC_ALL=C

# 1. Verifica la VPN Attiva (Priorità massima)
VPN_NAME=$(nmcli -t -f type,name connection show --active | grep '^vpn:' | cut -d: -f2 | head -n 1)

if [ -n "$VPN_NAME" ]; then
    # VPN Attiva
    echo '{"text": "' "$ICON_VPN"'", "tooltip": "'"$VPN_NAME"'", "class": "vpn"}'
    exit 0
fi

# 2. Verifica Connessioni Fisiche
# Usiamo 'nmcli -t -f DEVICE,TYPE,STATE dev' per uno stato più affidabile (non della connessione, ma del dispositivo)
CONNECTION_STATE=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep -E ':connected$')

if [ -n "$CONNECTION_STATE" ]; then
    # Cerchiamo il tipo e il nome del primo dispositivo connesso
    DEV_TYPE=$(echo "$CONNECTION_STATE" | cut -d: -f2 | head -n 1)
    
    # Tentiamo di ottenere l'ESSID o il nome della connessione attiva
    ACTIVE_CONN_NAME=$(nmcli -t -f NAME connection show --active | head -n 1)

    case "$DEV_TYPE" in
        wifi)
            # Wi-Fi Attivo: Otteniamo l'ESSID dall'interfaccia Wi-Fi
            ESSID=$(nmcli -t -f active,ssid device wifi | grep '^yes' | cut -d: -f2 | head -n 1)
            # Se la variabile d'ambiente non funziona e l'output è ancora in italiano
            if [ -z "$ESSID" ]; then
                 ESSID=$(nmcli -t -f active,ssid device wifi | grep '^sì' | cut -d: -f2 | head -n 1)
            fi

            echo '{"text": " '"$ICON_WIFI"'", "tooltip": "'"$ESSID"'", "class": "wifi"}'
            ;;
        ethernet)
            # Ethernet Attivo
            echo '{"text": " '"$ICON_ETHERNET"'", "tooltip": "Connesso via Ethernet ('"$ACTIVE_CONN_NAME"')", "class": "ethernet"}'
            ;;
        *)
            # Altro tipo (es. loopback, bridge, ecc.)
            echo '{"text": "❓", "tooltip": "Rete attiva: '"$DEV_TYPE"'", "class": "other"}'
            ;;
    esac
else
    # 3. Disconnesso
    echo '{"text": " '"$ICON_DISCONNECTED"'", "tooltip": "Disconnected", "class": "disconnected"}'
fi
