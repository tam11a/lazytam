# lazytam shell defaults, sourced from ~/.bashrc (works in zsh too).
# Override anything after the `source` line in your own rc file.

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"

[[ $- == *i* ]] || return 0

_lt_shell=bash
[[ -n ${ZSH_VERSION:-} ]] && _lt_shell=zsh

command -v mise >/dev/null && eval "$(mise activate "$_lt_shell")"
command -v zoxide >/dev/null && eval "$(zoxide init "$_lt_shell")"
command -v fzf >/dev/null && eval "$(fzf --"$_lt_shell")"

if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='ls -la'
  alias lt='eza --tree --level=2 --icons=auto'
fi
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'
alias lg='lazygit'
alias ld='lazydocker'
alias y='yazi'

# lazydocker and docker-compatible tools talk to podman through its user socket.
if [[ -S ${XDG_RUNTIME_DIR:-/run/user/$UID}/podman/podman.sock ]]; then
  export DOCKER_HOST="unix://${XDG_RUNTIME_DIR:-/run/user/$UID}/podman/podman.sock"
fi

unset _lt_shell
