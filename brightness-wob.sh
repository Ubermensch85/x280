#!/bin/bash
[ "$1" = "up" ] && brightnessctl -d intel_backlight set 5%+ || brightnessctl -d intel_backlight set 5%-
sleep 0.05
PERCENT=$(brightnessctl -d intel_backlight get)
MAX=$(brightnessctl -d intel_backlight max)
echo "$((PERCENT * 100 / MAX))" > $XDG_RUNTIME_DIR/wob.sock
