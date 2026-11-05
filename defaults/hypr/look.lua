-- Layout and motion. Colors come from the theme (~/.config/lazytam/current/hyprland.lua).
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        layout = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 0.95,

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            vibrancy = 0.17,
        },

        shadow = {
            enabled = true,
            range = 14,
            render_power = 3,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        focus_on_activate = true,
    },
})

hl.curve("smooth", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("snappy", { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "snappy", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "smooth", style = "popin 85%" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "smooth", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "smooth", style = "slide" })
