# server: SSH + Tailscale, never sleep, ignore the lid, blank the console.

enable_service sshd.service tailscaled.service

write_root_file /etc/systemd/logind.conf.d/90-lazytam-server.conf <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
IdleAction=ignore
EOF

as_root systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null

# Turn the built-in screen off after a minute at the console.
write_root_file /etc/tmpfiles.d/90-lazytam-consoleblank.conf <<'EOF'
w /sys/module/kernel/parameters/consoleblank - - - - 60
EOF

# Key-only SSH, but only once a key is in place, so this can't lock you out.
if [[ -s $HOME/.ssh/authorized_keys ]]; then
  grep -qE '^\s*Include\s+/etc/ssh/sshd_config.d/' /etc/ssh/sshd_config 2>/dev/null \
    || warn "/etc/ssh/sshd_config has no Include for sshd_config.d; the hardening below won't load"
  write_root_file /etc/ssh/sshd_config.d/90-lazytam.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
EOF
  if systemd_running; then as_root systemctl reload sshd.service || true; fi
else
  warn "no ~/.ssh/authorized_keys yet: password SSH stays on. Add your desktop's key, then re-run install.sh"
fi
