#!/bin/bash

# Backend X11
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb

# Scaling coincidente con Hyprland (1.25)
# Questo assicura che l'interfaccia abbia le dimensioni native corrette
export QT_SCALE_FACTOR=1.25
export QT_AUTO_SCREEN_SCALE_FACTOR=0

# Avvia silenziando l'output
anydesk "$@" > /dev/null 2>&1 &
