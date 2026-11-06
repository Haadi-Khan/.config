--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Quickshell panels animate themselves; Hyprland's layer fade on top of that
-- (over a full-screen click-catcher surface) just adds artifacts.
hl.layer_rule({
    name    = "quickshell-panels-no-anim",
    match   = { namespace = "^quickshell-(drawer|control)$" },
    no_anim = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Browser Picture-in-Picture: small, pinned, bottom-right corner
hl.window_rule({
    name  = "pip-corner",
    match = { title = "^Picture-in-Picture$" },

    float             = true,
    pin               = true,
    keep_aspect_ratio = true,
    size              = "480 270",
    move              = "monitor_w-window_w-15 monitor_h-window_h-15",
})

-- Bitwarden extension popouts in Zen: float them like a popup instead of
-- tiling them as a full window. The title starts as "Zen Browser" and only
-- changes to the extension title after load, so this relies on Hyprland
-- re-evaluating rules on title change.
hl.window_rule({
    name  = "zen-bitwarden-popout",
    match = { class = "^zen$", title = "^Extension: \\(Bitwarden.*" },

    float  = true,
    center = true,
    pin    = true,
    size   = "420 640",
})

-- Doom Emacs org-capture popup (SUPER+N): floating, centered, on top
hl.window_rule({
    name  = "org-capture-popup",
    match = { title = "^doom-capture$" },

    float  = true,
    center = true,
    pin    = true,
    size   = "900 520",
})

-- Emacs scratch notes (SUPER+;): floating, centered
hl.window_rule({
    name  = "emacs-scratch-popup",
    match = { title = "^emacs-scratch$" },

    float  = true,
    center = true,
    size   = "1000 650",
})

-- Satty screenshot markup: float it instead of tiling
hl.window_rule({
    name  = "satty-float",
    match = { class = "^com.gabm.satty$" },

    float  = true,
    center = true,
})
