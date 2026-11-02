# laptop: power profiles, battery charge limit, Wi-Fi without power saving, Bluetooth.

enable_service power-profiles-daemon.service bluetooth.service

# Battery charge limit, re-applied on every boot by udev.
limit=$(lt_config battery_limit)
bats=(/sys/class/power_supply/BAT*/charge_control_end_threshold)
if [[ $limit -gt 0 && -e ${bats[0]} ]]; then
  write_root_file /etc/udev/rules.d/90-lazytam-battery.rules <<EOF
ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT*", ATTR{charge_control_end_threshold}="$limit"
EOF
  for f in "${bats[@]}"; do echo "$limit" | as_root tee "$f" >/dev/null || true; done
elif [[ $limit -gt 0 ]]; then
  warn "this battery doesn't expose a charge limit; skipping battery_limit"
fi

# Wi-Fi: iwd with its own DHCP, power saving off (it causes drops on many cards).
# If NetworkManager already manages the network, configure it instead of fighting it.
if systemctl is-enabled NetworkManager.service >/dev/null 2>&1; then
  write_root_file /etc/NetworkManager/conf.d/90-lazytam-wifi.conf <<'EOF'
[connection]
wifi.powersave = 2
EOF
  warn "NetworkManager is in use; impala (iwd TUI) won't manage Wi-Fi. Use nmtui instead."
else
  write_root_file /etc/iwd/main.conf <<'EOF'
[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd

[DriverQuirks]
PowerSaveDisable=*
EOF
  enable_service iwd.service systemd-resolved.service
  # iwd hands DNS to systemd-resolved, so resolv.conf must point at its stub.
  if systemd_running && [[ ! -L /etc/resolv.conf ]]; then
    as_root ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  fi
fi

# Realtek 8821CE (rtw88): deep power saving and ASPM cause disconnects.
if lspci 2>/dev/null | grep -qi 'RTL8821CE'; then
  write_root_file /etc/modprobe.d/90-lazytam-rtw88.conf <<'EOF'
options rtw88_core disable_lps_deep=y
options rtw88_pci disable_aspm=y
EOF
fi
