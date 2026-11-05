-- Your Hyprland config (lazytam). Order matters:
--   1. lazytam defaults   2. theme colors   3. you
require("@HOME@/.config/lazytam/defaults/hypr/hyprland.lua")
require("@HOME@/.config/lazytam/current/hyprland.lua")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- --- your overrides ---
-- Anything here wins over the defaults above, e.g.:
-- hl.config({ general = { gaps_out = 14 } })
-- hl.bind("SUPER + N", hl.dsp.exec_cmd("kitty nvim"))
