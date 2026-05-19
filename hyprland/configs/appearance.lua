-- ~/.config/hypr/configs/appearance.lua
-- x280 — Hyprland 0.55
-- Tema: Nord (nordtheme.com)
-- Palette:
--   nord0  #2e3440 — Polar Night (background)
--   nord3  #4c566a — bordo inattivo
--   nord8  #88c0d0 — accent primario (azzurro ghiaccio)
--   nord9  #81a1c1 — accent secondario (blu artico)
--   nord10 #5e81ac — accent terziario

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 6,
        border_size = 1,
        -- Gradiente aurora: ruota con borderangle
        ["col.active_border"]   = { colors = { "rgb(88c0d0)", "rgb(81a1c1)", "rgb(5e81ac)", "rgb(81a1c1)", "rgb(88c0d0)" }, angle = 45 },
        ["col.inactive_border"] = "rgb(4c566a)",
        extend_border_grab_area = 15,
        layout = "dwindle",
    },
    decoration = {
        rounding         = 10,
        active_opacity   = 0.90,
        inactive_opacity = 0.85,
        blur = {
            enabled    = true,
            size       = 4,
            passes     = 2,
            vibrancy   = 0.2,   -- bassa: Nord è volutamente desaturato
            noise      = 0.02,
            brightness = 0.85,
        },
    },
    animations = {
        enabled = true,
    },
    input = {
        kb_layout    = "it",
        follow_mouse = 1,
        sensitivity  = 0,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = false,
            tap_to_click   = true,
            scroll_factor  = 1.0,
        },
    },
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        enable_swallow           = true,
        swallow_regex            = "^(kitty)$",
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
        vrr                      = 0,
    },
})

-- ── Curve bezier ─────────────────────────────────────────────────────────────
hl.curve("overshot",  { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.1}   } })
hl.curve("smoothOut", { type = "bezier", points = { {0.36, 0},    {0.66, -0.56} } })
hl.curve("spring",    { type = "bezier", points = { {0.68, -0.55},{0.27, 1.55}  } })
hl.curve("linear",    { type = "bezier", points = { {0, 0},       {1, 1}        } })
hl.curve("easeInOut", { type = "bezier", points = { {0.42, 0},    {0.58, 1}     } })
hl.curve("bounce",    { type = "bezier", points = { {0.17, 0.67}, {0.54, 1.5}   } })

-- ── Animazioni ───────────────────────────────────────────────────────────────
hl.animation({ leaf = "windows",          enabled = true, speed = 5, bezier = "spring",    style = "slide"     })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 4, bezier = "smoothOut", style = "slide"     })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 5, bezier = "overshot"                       })
hl.animation({ leaf = "border",           enabled = true, speed = 6, bezier = "easeInOut"                      })
-- Rotazione gradiente bordo — effetto aurora boreale continuo
hl.animation({ leaf = "borderangle",      enabled = true, speed = 8, bezier = "linear"                         })
hl.animation({ leaf = "fade",             enabled = true, speed = 4, bezier = "easeInOut"                      })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5, bezier = "bounce",    style = "slide"     })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "spring",    style = "slidevert" })
