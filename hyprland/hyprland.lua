-- ~/.config/hypr/hyprland.lua
-- Verificato sul wiki ufficiale PDF (9 maggio 2026)
-- hl.monitor() è la sintassi corretta (NON hl.config({ monitor = {} }))
-- dwindle.pseudotile NON esiste in 0.55

require("configs.execs")
require("configs.appearance")
require("configs.rules")
require("configs.binds")

-- ── Monitor ───────────────────────────────────────────────────────────────────
-- Sintassi: hl.monitor({ output = "...", mode = "...", position = "...", scale = N })
hl.monitor({ output = "eDP-1",    mode = "1920x1080@60", position = "0x0",    scale = 1.25 })
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60", position = "auto",   scale = 1    })
hl.monitor({ output = "DP-2",     mode = "3840x2160@60", position = "1536x0", scale = 2    })
-- Fallback per qualsiasi monitor non specificato
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- ── Config globale ────────────────────────────────────────────────────────────
hl.config({
    dwindle = {
        -- pseudotile rimosso: non esiste in 0.55
        preserve_split = true,
        force_split    = 2,
        smart_split    = false,
    },
    master = {
        new_on_top = false,
        mfact      = 0.55,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})
