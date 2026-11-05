-- uwsm's login shell doesn't reach the PATH line in ~/.bashrc, and binds and Waybar call `lazytam`.
local bin = os.getenv("HOME") .. "/.local/bin"
local path = os.getenv("PATH") or ""
if not (":" .. path .. ":"):find(":" .. bin .. ":", 1, true) then
    hl.env("PATH", bin .. ":" .. path)
end

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
