# desktop: polkit agent and font cache. Hyprland itself is started by hand: uwsm start hyprland.desktop

if systemd_running && [[ $EUID -ne 0 ]]; then
  systemctl --user enable hyprpolkitagent.service 2>/dev/null || warn "could not enable hyprpolkitagent"
fi

fc-cache -f >/dev/null 2>&1 || true
