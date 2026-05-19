-- ~/.config/hypr/configs/binds.lua
-- Verificato su https://wiki.hypr.land/Configuring/Basics/Dispatchers/ (latest git, 8 maggio 2026)

local mainMod = "SUPER"

-- ── Applicazioni ─────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("sh /home/ubermensch/.local/bin/firefox-hwaccel"))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("sh /home/ubermensch/.local/librewolf-hwaccel"))
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd("wofi --show drun --style ~/.config/wofi/style.css"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("wofi --show run --style ~/.config/wofi/style.css"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("nemo"))
hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("sh .config/alacritty/script/nota.sh"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("ghostwriter"))

-- ── Sistema & alimentazione ───────────────────────────────────────────────────
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + E",      hl.dsp.exit())
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("reboot"))
hl.bind(mainMod .. " + Delete", hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + Print",  hl.dsp.exec_cmd("grimblast save area"))
hl.bind(mainMod .. " + I",      hl.dsp.exec_cmd("sudo /usr/local/bin/battery_check_root.py"))
hl.bind("F9",                   hl.dsp.exec_cmd("kitty --class=kitty-config -e nano ~/.config/hypr/hyprland.lua"))

-- ── Gestione finestre ────────────────────────────────────────────────────────
-- SUPER + O: float toggle + center + resize 900x600 automatico
-- Se la finestra diventa floating la centra e ridimensiona,
-- se torna tiled non fa nulla di extra
hl.bind(mainMod .. " + O", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.timer(function()
        local win = hl.get_active_window()
        if win and win.floating then
            hl.dispatch(hl.dsp.window.resize({ x = 900, y = 600 }))
            hl.dispatch(hl.dsp.window.center())
        end
    end, { timeout = 50, type = "oneshot" })
end)
-- window.pseudo: action = toggle(default) / enable / disable
hl.bind(mainMod .. " + P",  hl.dsp.window.pseudo())
-- window.fullscreen: mode = "fullscreen"(default) / "maximized"
hl.bind(mainMod .. " + F",  hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + W",  hl.dsp.exec_cmd("~/.local/bin/display-control toggle"))
hl.bind(mainMod .. " + A",  hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
hl.bind(mainMod .. " + S",  hl.dsp.exec_cmd("hyprdvd --screensaver"))

-- ── Spostamento finestre — window.move({ direction })
-- Direzioni valide: l / r / u / d
local move_map = {
    left = "l", right = "r", up = "u", down = "d",
    H    = "l", L     = "r", K  = "u", J    = "d",
}
for key, dir in pairs(move_map) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- ── Workspace 1–9 e 10 ───────────────────────────────────────────────────────
for i = 1, 10 do
    local key = i % 10  -- 10 → tasto "0"
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- ── Mouse ────────────────────────────────────────────────────────────────────
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- ── Audio ─────────────────────────────────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.local/bin/volume-wob.sh up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.local/bin/volume-wob.sh down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("~/.local/bin/volume-wob.sh mute"), { locked = true })
hl.bind("F3",                   hl.dsp.exec_cmd("~/.local/bin/volume-wob.sh up"),   { repeating = true })
hl.bind("F2",                   hl.dsp.exec_cmd("~/.local/bin/volume-wob.sh down"), { repeating = true })
hl.bind("F1",                   hl.dsp.exec_cmd("~/.local/bin/volume-wob.sh mute"))
hl.bind("F4",                   hl.dsp.exec_cmd("/usr/local/bin/toggle-mic.sh"))

-- ── Luminosità ───────────────────────────────────────────────────────────────
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("~/.local/bin/brightness-wob.sh up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.local/bin/brightness-wob.sh down"), { locked = true, repeating = true })
hl.bind("F6",                    hl.dsp.exec_cmd("~/.local/bin/brightness-wob.sh up"),   { repeating = true })
hl.bind("F5",                    hl.dsp.exec_cmd("~/.local/bin/brightness-wob.sh down"), { repeating = true })

-- ── Connettività & DPMS ──────────────────────────────────────────────────────
hl.bind("F8",                hl.dsp.exec_cmd("/usr/local/bin/toggle-wifi.sh"))
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("/usr/local/bin/toggle_bluetooth.sh"))

hl.bind(mainMod .. " + F11", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "disable" }))
    end, { timeout = 1000, type = "oneshot" })
end)
hl.bind(mainMod .. " + F12", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "enable" }))
    end, { timeout = 0, type = "oneshot" })
end)
