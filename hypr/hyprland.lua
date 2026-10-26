-- Hyprland config, split into modules under ./modules/
-- Order matters only loosely: env/monitors first, binds and rules last.

require("modules.env")
require("modules.monitors")
require("modules.autostart")
require("modules.appearance")
require("modules.input")
require("modules.keybinds")
require("modules.rules")
