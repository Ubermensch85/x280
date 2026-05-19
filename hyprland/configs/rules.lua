-- ~/.config/hypr/configs/rules.lua
-- Verificato su https://wiki.hypr.land/Configuring/Basics/Window-Rules/ (latest git, 8 maggio 2026)
--
-- Static effects (valutati una volta all'apertura):
--   float, tile, fullscreen, maximize, move, size, center, pseudo,
--   monitor, workspace, pin, no_initial_focus, suppress_event
-- Dynamic effects (rivalutati ad ogni cambio proprietà):
--   opacity, border_color, border_size, rounding, no_blur, no_focus, ...
--
-- Regole valutate top-to-bottom; named rules hanno precedenza sulle anonymous.
-- "negative:PATTERN" nel match nega la regex.

-- ════════════════════════════════════════════════════════════════════════════
-- DIALOG E FINESTRE MODALI
-- ════════════════════════════════════════════════════════════════════════════

-- Regola globale: qualsiasi finestra che il compositor riconosce come modale
-- (Wayland native). Copre selettori file, preferenze, alert, confirm, ecc.
hl.window_rule({
    match  = { modal = true },
    float  = true,
    center = true,
})

-- Fallback per app che non dichiarano modal correttamente (XWayland e app legacy).
-- Matcha title tipici di dialog strumentali. Se una finestra legittima venisse
-- catturata, aggiungila con una regola tile = true più in basso (vince perché viene dopo).
hl.window_rule({
    match  = { title = "^(Open File|Open Folder|Save As|Save File|Salva come|Apri|Preferences|Settings|Impostazioni|Print|Stampa|Alert|Confirm|Error|Warning|About|Find|Search).*$" },
    float  = true,
    center = true,
})

-- ── Firefox Developer Edition — dialog interni ───────────────────────────────
-- modal=true copre i dialog Wayland nativi.
-- Il secondo match copre download manager, permessi, about, ecc.
hl.window_rule({
    match  = { class = "^firefox-developer-edition$", modal = true },
    float  = true,
    center = true,
})
hl.window_rule({
    match  = { class = "^firefox-developer-edition$",
               title = "^(Opening|Save|Salva|Enter name|Alert|Confirm|Print|About Mozilla).*$" },
    float  = true,
    center = true,
})

-- ── AnyDesk — finestre secondarie ────────────────────────────────────────────
-- AnyDesk è XWayland e non dichiara modal. Usiamo due approcci:
-- 1. modal=true per sicurezza futura
-- 2. "negative:" sul title per matchare tutto tranne la finestra principale
hl.window_rule({
    match  = { class = "^(Anydesk)$", modal = true },
    float  = true,
    center = true,
})
hl.window_rule({
    match  = { class = "^(Anydesk)$", title = "negative:^(AnyDesk)$" },
    float  = true,
    center = true,
})

-- ════════════════════════════════════════════════════════════════════════════
-- SISTEMA E UTILITY
-- ════════════════════════════════════════════════════════════════════════════

-- ── Polkit ───────────────────────────────────────────────────────────────────
hl.window_rule({
    match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" },
    float = true,
})

-- ── floating_term (generico) ─────────────────────────────────────────────────
hl.window_rule({
    match  = { class = "^(floating_term)$" },
    float  = true,
    size   = { 700, 550 },
    center = true,
    pin    = true,
})

-- Caso speciale: Arch Info sovrascrive le dimensioni (viene dopo, vince)
hl.window_rule({
    match  = { class = "^(floating_term)$", title = "^(Arch Info)$" },
    size   = { 750, 600 },
    center = true,
})

-- ── Nota ─────────────────────────────────────────────────────────────────────
hl.window_rule({
    match     = { class = "^(Nota)$" },
    float     = true,
    size      = { 750, 500 },
    center    = true,
    workspace = "special:notes",
})

-- ── Kitty su workspace 2 ─────────────────────────────────────────────────────
hl.window_rule({
    match = { class = "^(kitty)$", workspace = "2" },
    float = true,
    size  = { 650, 450 },
    move  = { 750, 150 },
})

-- ── fly-foot-write ───────────────────────────────────────────────────────────
hl.window_rule({
    match        = { title = "^(fly-foot-write)$" },
    float        = true,
    border_color = { colors = { "rgb(FFFFFF)", "rgb(000000)" }, angle = 0 },
})

-- ════════════════════════════════════════════════════════════════════════════
-- BROWSER
-- ════════════════════════════════════════════════════════════════════════════

-- ── Librewolf ────────────────────────────────────────────────────────────────
hl.window_rule({
    match   = { class = "^(librewolf)$" },
    opacity = "1.0 override 1.0 override",
})

-- ── Firefox Developer Edition ────────────────────────────────────────────────
hl.window_rule({
    match   = { class = "^firefox-developer-edition$" },
    opacity = "1.0 override 1.0 override",
})

-- ════════════════════════════════════════════════════════════════════════════
-- APP SPECIFICHE
-- ════════════════════════════════════════════════════════════════════════════

-- ── AnyDesk (finestra principale) ────────────────────────────────────────────
hl.window_rule({
    match       = { class = "^(Anydesk)$", title = "^(AnyDesk)$" },
    float       = true,
    center      = true,
    size        = { 1520, 810 },
    opacity     = "1.0 override 1.0 override",
    border_size = 0,
})

-- ── Sky TG24 (MPV floating) ───────────────────────────────────────────────────
hl.window_rule({
    match = { title = "^(Sky TG24 — Diretta)$" },
    float = true,
    size  = { 512, 288 },
    move  = { 980, 40 },
})

-- ── GeForce NOW ──────────────────────────────────────────────────────────────
hl.window_rule({
    match      = { class = "^(GeForce NOW)$" },
    fullscreen = true,
})
hl.window_rule({
    match      = { class = "^(GeForce NOW)$", title = "^(GeForce NOW)$" },
    fullscreen = false,
    float      = true,
    size       = { 1200, 800 },
    center     = true,
})

-- ════════════════════════════════════════════════════════════════════════════
-- FIX XWAYLAND
-- ════════════════════════════════════════════════════════════════════════════

hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
