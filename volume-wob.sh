#!/bin/bash
case "$1" in
    up)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0 ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac
sleep 0.05
VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o MUTED)
[ -n "$MUTED" ] && echo 0 > $XDG_RUNTIME_DIR/wob.sock || echo "$VOLUME" > $XDG_RUNTIME_DIR/wob.sock
