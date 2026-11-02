# dev: podman socket for lazydocker, Claude Code.

# The user-level podman socket lets lazydocker and docker-compatible tools talk to podman.
if systemd_running && [[ $EUID -ne 0 ]]; then
  systemctl --user enable --now podman.socket || warn "could not enable podman.socket"
fi

if [[ ${LAZYTAM_SKIP_CLAUDE:-0} != 1 ]] && ! command -v claude >/dev/null && [[ ! -x $HOME/.local/bin/claude ]]; then
  log "installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash || warn "Claude Code install failed; retry later"
fi
