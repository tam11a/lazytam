hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        repeat_rate = 40,
        repeat_delay = 250,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 0.6,
        },
    },
})

-- Three-finger swipe between workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
