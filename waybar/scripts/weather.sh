#!/bin/bash

MAX_RETRIES=3
RETRY_DELAY=2

for i in $(seq 1 $MAX_RETRIES); do
    data=$(curl -s --max-time 5 \
        'https://api.open-meteo.com/v1/forecast?latitude=43.11&longitude=12.39&current_weather=true&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode,windspeed_10m_max&hourly=relativehumidity_2m,precipitation_probability&timezone=auto&forecast_days=3')

    if echo "$data" | jq -e '.current_weather.temperature' &>/dev/null; then
        break
    fi

    data=""
    sleep $RETRY_DELAY
done

if [[ -z "$data" ]]; then
    printf '{"text": "󰖐  N/A", "tooltip": "Dati non disponibili"}'
    exit 1
fi

temp=$(echo "$data" | jq '.current_weather.temperature')
code=$(echo "$data" | jq '.current_weather.weathercode')
wind=$(echo "$data" | jq '.current_weather.windspeed')

# Dati giornalieri (3 giorni)
max0=$(echo "$data" | jq '.daily.temperature_2m_max[0]')
min0=$(echo "$data" | jq '.daily.temperature_2m_min[0]')
max1=$(echo "$data" | jq '.daily.temperature_2m_max[1]')
min1=$(echo "$data" | jq '.daily.temperature_2m_min[1]')
max2=$(echo "$data" | jq '.daily.temperature_2m_max[2]')
min2=$(echo "$data" | jq '.daily.temperature_2m_min[2]')
rain0=$(echo "$data" | jq '.daily.precipitation_sum[0]')
rain1=$(echo "$data" | jq '.daily.precipitation_sum[1]')
rain2=$(echo "$data" | jq '.daily.precipitation_sum[2]')
wcode1=$(echo "$data" | jq '.daily.weathercode[1]')
wcode2=$(echo "$data" | jq '.daily.weathercode[2]')
windmax0=$(echo "$data" | jq '.daily.windspeed_10m_max[0]')

# Umidità ora corrente (indice ora attuale)
current_hour=$(date +%-H)
humidity=$(echo "$data" | jq ".hourly.relativehumidity_2m[$current_hour]")
rain_prob=$(echo "$data" | jq ".hourly.precipitation_probability[$current_hour]")

# Nomi giorni
day1=$(date -d "+1 day" +%A)
day2=$(date -d "+2 days" +%A)

weather_desc() {
    case $1 in
        0)              echo "Sereno" ;;
        1|2|3)          echo "Parz. nuvoloso" ;;
        45|48)          echo "Nebbia" ;;
        51|53|55)       echo "Pioggerella" ;;
        61|63|65)       echo "Pioggia" ;;
        71|73|75|77)    echo "Neve" ;;
        85|86)          echo "Rovesci neve" ;;
        95|96|99)       echo "Temporale" ;;
        *)              echo "N/D" ;;
    esac
}

weather_icon() {
    case $1 in
        0)                     echo '󰖙' ;;
        1|2|3)                 echo '󰖕' ;;
        45|48)                 echo '󰖑' ;;
        51|53|55|61|63|65)     echo '󰖗' ;;
        71|73|75|77|85|86)     echo '󰼶' ;;
        95|96|99)              echo '󰙪' ;;
        *)                     echo '󰖐' ;;
    esac
}

desc1=$(weather_desc $wcode1)
desc2=$(weather_desc $wcode2)
icon1=$(weather_icon $wcode1)
icon2=$(weather_icon $wcode2)

tooltip=$(printf \
"󰖙 Oggi\n  Temp:     %s°C (min %s° | max %s°)\n  Umidità:  %s%%\n  Vento:    %s km/h (max %s)\n  Pioggia:  %s mm  (%s%% prob.)\n\n%s %s\n  %s°C — %s°C  |  %s mm\n\n%s %s\n  %s°C — %s°C  |  %s mm" \
    "$temp" "$min0" "$max0" \
    "$humidity" "$wind" "$windmax0" \
    "$rain0" "$rain_prob" \
    "$icon1" "$day1" "$min1" "$max1" "$rain1" \
    "$icon2" "$day2" "$min2" "$max2" "$rain2")

# Escape newlines per JSON
tooltip_json=$(echo "$tooltip" | jq -Rs '.')

# Icon testo principale
case $code in
    0)                     icon='󰖙' ;;
    1|2|3)                 icon='󰖕' ;;
    45|48)                 icon='󰖑' ;;
    51|53|55|61|63|65)     icon='󰖗' ;;
    71|73|75|77|85|86)     icon='󰼶' ;;
    95|96|99)              icon='󰙪' ;;
    *)                     icon='󰖐' ;;
esac

printf '{"text": "%s  %s°C", "tooltip": %s}' "$icon" "$temp" "$tooltip_json"
