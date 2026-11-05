-- Apps come from ~/.config/lazytam/current/apps.lua (generated from config.toml).
local apps = require(os.getenv("HOME") .. "/.config/lazytam/current/apps.lua")
local mod = "SUPER"
local exec = hl.dsp.exec_cmd

local function bind(keys, action, flags)
    hl.bind(mod .. " + " .. keys, action, flags)
end

-- Apps
bind("RETURN", exec(apps.terminal))
bind("SPACE", exec(apps.launcher))
bind("B", exec(apps.browser))
bind("E", exec(apps.file_manager))

-- Windows
bind("Q", hl.dsp.window.close())
bind("F", hl.dsp.window.fullscreen())
bind("V", hl.dsp.window.float({ action = "toggle" }))
bind("P", hl.dsp.window.pseudo())
bind("T", hl.dsp.layout("togglesplit"))

local directions = {
    H = "left", J = "down", K = "up", L = "right",
    LEFT = "left", DOWN = "down", UP = "up", RIGHT = "right",
}
for key, direction in pairs(directions) do
    bind(key, hl.dsp.focus({ direction = direction }))
end
for _, key in ipairs({ "H", "J", "K", "L" }) do
    bind("SHIFT + " .. key, hl.dsp.window.move({ direction = directions[key] }))
end

bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces
for i = 1, 9 do
    bind(tostring(i), hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
bind("S", hl.dsp.workspace.toggle_special("scratch"))
bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- lazytam
bind("CTRL + T", exec("lazytam theme pick"))
bind("CTRL + W", exec("lazytam bg next"))
bind("CTRL + V", exec("cliphist list | " .. apps.dmenu .. " | cliphist decode | wl-copy"))

-- Session
bind("ESCAPE", exec("loginctl lock-session"))
bind("SHIFT + ESCAPE", exec("uwsm stop || hyprctl dispatch 'hl.dsp.exit()'"))

-- Screenshots: region to clipboard, full screen to ~/Pictures
hl.bind("PRINT", exec([[grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copied"]]))
bind("PRINT", exec([[mkdir -p ~/Pictures && grim ~/Pictures/screenshot-$(date +%F-%H%M%S).png && notify-send "Screenshot saved"]]))

-- Media and hardware keys (work while locked)
local held = { locked = true, repeating = true }
local locked = { locked = true }
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked)
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), locked)
hl.bind("XF86MonBrightnessUp", exec("brightnessctl -e4 -n2 set 5%+"), held)
hl.bind("XF86MonBrightnessDown", exec("brightnessctl -e4 -n2 set 5%-"), held)
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), locked)
hl.bind("XF86AudioNext", exec("playerctl next"), locked)
hl.bind("XF86AudioPrev", exec("playerctl previous"), locked)
