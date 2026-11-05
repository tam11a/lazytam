-- lazytam Hyprland defaults. Don't edit: override in ~/.config/hypr/hyprland.lua,
-- which loads this file and then applies your settings on top.
local dir = os.getenv("HOME") .. "/.config/lazytam/defaults/hypr/"
require(dir .. "env.lua")
require(dir .. "input.lua")
require(dir .. "look.lua")
require(dir .. "binds.lua")
require(dir .. "rules.lua")
require(dir .. "autostart.lua")
