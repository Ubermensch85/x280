#!/bin/bash

# Crea la cartella cache in RAM se non esiste
mkdir -p /tmp/brave-cache

# --ozone-platform=wayland: Fondamentale. Forza il rendering nativo (font nitidi a 1.25)
# --enable-features=UseOzonePlatform: Conferma l'uso del backend Ozone
exec brave-nightly \
  --ozone-platform=wayland \
  --enable-features=UseOzonePlatform,WaylandWindowDecorations \
  --disk-cache-dir=/tmp/brave-cache \
  "$@"
