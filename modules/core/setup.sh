# core: zram swap, btrfs snapshots, pacman cache cleanup, shell defaults, btop theme.

if [[ ! -f /etc/systemd/zram-generator.conf ]]; then
  write_root_file /etc/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF
fi

enable_service paccache.timer

# Snapshots only make sense on btrfs. archinstall's btrfs layout already mounts
# /.snapshots, which `snapper create-config` refuses, so leave that case to the user.
if [[ $(findmnt -no FSTYPE / 2>/dev/null) == btrfs ]]; then
  if as_root snapper list-configs 2>/dev/null | grep -q '^root '; then
    :
  elif [[ -e /.snapshots ]]; then
    warn "/.snapshots exists but snapper has no 'root' config; see https://wiki.archlinux.org/title/Snapper#Configuration_of_snapper_and_mount_point"
  else
    as_root snapper -c root create-config /
    log "snapper: created root config"
  fi
  enable_service snapper-timeline.timer snapper-cleanup.timer
fi

rc_line="source \"$LAZYTAM_CONFIG/defaults/shell/rc.sh\"  # lazytam"
touch "$HOME/.bashrc"
grep -qF "# lazytam" "$HOME/.bashrc" || { echo "$rc_line" >>"$HOME/.bashrc"; log "added lazytam to ~/.bashrc"; }

mkdir -p "$HOME/.config/btop/themes"
ln -sfn "$LAZYTAM_CONFIG/current/btop.theme" "$HOME/.config/btop/themes/lazytam.theme"
if [[ ! -f $HOME/.config/btop/btop.conf ]]; then
  printf 'color_theme = "lazytam"\ntheme_background = False\n' >"$HOME/.config/btop/btop.conf"
fi
