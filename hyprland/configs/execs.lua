-- ~/.config/hypr/configs/execs.lua
-- Verificato sul wiki ufficiale PDF (9 maggio 2026)
-- hl.env() è la sintassi corretta per le variabili d'ambiente
-- hl.on("hyprland.start", fn) è la sintassi corretta per l'autostart

-- ── Variabili d'ambiente ─────────────────────────────────────────────────────
hl.env("GDK_BACKEND",          "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",      "wayland;xcb")
hl.env("SDL_VIDEODRIVER",      "wayland")
hl.env("CLUTTER_BACKEND",      "wayland")
hl.env("XDG_CURRENT_DESKTOP",  "Hyprland")
hl.env("XDG_SESSION_TYPE",     "wayland")
hl.env("XDG_SESSION_DESKTOP",  "Hyprland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XCURSOR_SIZE",         "24")
hl.env("HYPRCURSOR_SIZE",      "24")
hl.env("WLR_DRM_GAMMA_CONTROL","1")

-- ── Autostart ────────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
    -- Sistema base
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("mako")

    -- UI & tema
    hl.exec_cmd("pkill waybar; waybar")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface text-scaling-factor 1")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("dispwin -d 1 /usr/share/color/icc/x280/x280-lcd.icc")

    -- wob (on-screen display)
    hl.exec_cmd("rm -f $XDG_RUNTIME_DIR/wob.sock && mkfifo $XDG_RUNTIME_DIR/wob.sock && tail -f $XDG_RUNTIME_DIR/wob.sock | wob")

    -- Script utente
    hl.exec_cmd("~/.local/bin/display-control init")
    hl.exec_cmd("~/.config/waybar/scripts/spotify-auto.sh")
    hl.exec_cmd("checkupdates")
end)
