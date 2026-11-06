local programs = require("modules.programs")

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod  = "SUPER"
local shiftMod = "SUPER + SHIFT"

-- See https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + return",     hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + M",          hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + Q",          hl.dsp.window.close())
hl.bind(shiftMod .. " + 0",         hl.dsp.exit())
hl.bind(mainMod .. " + comma",      hl.dsp.exec_cmd(programs.fileManager), { repeating = true })
hl.bind(mainMod .. " + space",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + apostrophe", hl.dsp.exec_cmd(programs.menu))
hl.bind("ALT + SHIFT + S",          hl.dsp.exec_cmd(programs.sshot))
hl.bind("Print",                    hl.dsp.exec_cmd(programs.sshotFull))
hl.bind(mainMod .. " + P",          hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + period",     hl.dsp.exec_cmd('emacsclient -c -a ""'), { repeating = true })
hl.bind(mainMod .. " + N",          hl.dsp.exec_cmd("emacsclient -e '(+org-capture/open-frame)'"))
hl.bind(mainMod .. " + semicolon",  hl.dsp.exec_cmd(programs.scratch))
hl.bind(mainMod .. " + V",          hl.dsp.exec_cmd(programs.clipboard))
hl.bind("ALT + SHIFT + C",          hl.dsp.exec_cmd(programs.colorPicker))
hl.bind(mainMod .. " + escape",     hl.dsp.exec_cmd("loginctl lock-session"))

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Move windows with mainMod + SHIFT + hjkl
hl.bind(shiftMod .. " + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(shiftMod .. " + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(shiftMod .. " + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(shiftMod .. " + J", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + key
-- Move active window to a workspace with mainMod + SHIFT + key
local workspaceKeys = { "S", "D", "F", "G", "W", "E", "R", "T", "X", "C" }
for i, key in ipairs(workspaceKeys) do
    hl.bind(mainMod .. " + " .. key,  hl.dsp.focus({ workspace = i }))
    hl.bind(shiftMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Resize submap
hl.bind(mainMod .. " + O", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    -- Repeatable binds for resizing the active window
    hl.bind("L", hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })
    hl.bind("H", hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })

    -- Use reset to go back to the global submap
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n1 set 5%+ && pkill -RTMIN+8 waybar"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n1 set 5%- && pkill -RTMIN+8 waybar"),                  { locked = true, repeating = true })

-- Dictation (voxtype): keyd maps Right Ctrl -> F13, which xkb names XF86Tools.
-- Hold = push-to-talk, double-tap = lock on, tap again = finish. Logic in ptt.sh.
local ptt = os.getenv("HOME") .. "/.config/voxtype/ptt.sh"
hl.bind("XF86Tools", hl.dsp.exec_cmd(ptt .. " down"))
hl.bind("XF86Tools", hl.dsp.exec_cmd(ptt .. " up"), { release = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
