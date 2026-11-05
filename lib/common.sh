# Shared helpers for install.sh, bin/lazytam and module setup scripts.
# Expects LAZYTAM_PATH to be set by the caller.

LAZYTAM_CONFIG="${LAZYTAM_CONFIG:-$HOME/.config/lazytam}"
LAZYTAM_STATE="${LAZYTAM_STATE:-$HOME/.local/state/lazytam}"
export LAZYTAM_PATH LAZYTAM_CONFIG LAZYTAM_STATE

if [[ -t 1 ]]; then
  _c_accent=$'\e[1;36m' _c_warn=$'\e[1;33m' _c_err=$'\e[1;31m' _c_off=$'\e[0m'
else
  _c_accent='' _c_warn='' _c_err='' _c_off=''
fi

log()  { printf '%s::%s %s\n' "$_c_accent" "$_c_off" "$*"; }
warn() { printf '%swarning:%s %s\n' "$_c_warn" "$_c_off" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$_c_err" "$_c_off" "$*" >&2; exit 1; }

# Run as root: directly when already root (containers), otherwise through sudo.
as_root() {
  if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

# True when systemd is PID 1, so `--now` and runtime commands make sense.
systemd_running() { [[ -d /run/systemd/system ]]; }

enable_service() {
  if systemd_running; then
    as_root systemctl enable --now "$@"
  else
    as_root systemctl enable "$@"
  fi
}

lt_py() { python3 "$LAZYTAM_PATH/lib/lazytam.py" "$@"; }
lt_config() { lt_py config-get "$1"; }

# Print a package list file without comments or blank lines.
read_list() {
  [[ -f $1 ]] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$1"
}

# Write a root-owned file only when its content changed. Usage: write_root_file PATH <<EOF
write_root_file() {
  local target=$1 tmp
  tmp=$(mktemp)
  cat >"$tmp"
  if ! as_root cmp -s "$tmp" "$target" 2>/dev/null; then
    as_root install -Dm644 "$tmp" "$target"
    log "wrote $target"
  fi
  rm -f "$tmp"
}

install_packages() {
  local pkgs
  mapfile -t pkgs < <(read_list "$1")
  ((${#pkgs[@]})) || return 0
  as_root pacman -S --needed --noconfirm "${pkgs[@]}"
}

ensure_paru() {
  command -v paru >/dev/null && return 0
  [[ $EUID -eq 0 ]] && { warn "running as root: can't build paru (makepkg refuses root)"; return 1; }
  log "installing paru"
  local dir
  dir=$(mktemp -d)
  git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$dir/paru-bin"
  (cd "$dir/paru-bin" && makepkg -si --noconfirm)
  rm -rf "$dir"
}

install_aur_packages() {
  local pkgs
  mapfile -t pkgs < <(read_list "$1")
  ((${#pkgs[@]})) || return 0
  if [[ ${LAZYTAM_SKIP_AUR:-0} == 1 ]]; then
    warn "skipping AUR packages: ${pkgs[*]}"
    return 0
  fi
  ensure_paru || { warn "skipping AUR packages: ${pkgs[*]}"; return 0; }
  paru -S --needed --noconfirm "${pkgs[@]}"
}

# Copy a module's starter files into ~/.config. Never overwrites a file that
# already points at lazytam; anything else is backed up first.
place_stubs() {
  local stubs=$1 src rel target
  [[ -d $stubs ]] || return 0
  while IFS= read -r -d '' src; do
    rel=${src#"$stubs"/}
    target="$HOME/.config/$rel"
    if [[ -e $target ]]; then
      grep -q lazytam "$target" 2>/dev/null && continue
      mv "$target" "$target.pre-lazytam"
      warn "backed up existing $target to $target.pre-lazytam"
    fi
    mkdir -p "$(dirname "$target")"
    sed "s|@HOME@|$HOME|g" "$src" >"$target"
    log "created $target"
  done < <(find "$stubs" -type f -print0)
}

enabled_modules() { lt_config modules; }

module_enabled() {
  local m
  for m in $(enabled_modules); do [[ $m == "$1" ]] && return 0; done
  return 1
}

# Reload whatever is running so a theme change shows up immediately.
reload_desktop() {
  pgrep -x Hyprland >/dev/null 2>&1 || return 0
  hyprctl reload >/dev/null 2>&1 || true
  pkill -SIGUSR2 -x waybar 2>/dev/null || true
  command -v makoctl >/dev/null && makoctl reload 2>/dev/null || true
  pkill -SIGUSR1 -x kitty 2>/dev/null || true
  apply_wallpaper
}

apply_wallpaper() {
  command -v awww >/dev/null || return 0
  local _
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    awww query >/dev/null 2>&1 && break
    sleep 0.3
  done
  if [[ -e $LAZYTAM_CONFIG/current/background ]]; then
    awww img "$LAZYTAM_CONFIG/current/background" --transition-type grow --transition-duration 1.2 >/dev/null 2>&1 || true
  else
    awww clear "$(lt_py color background | tr -d '#')" >/dev/null 2>&1 || true
  fi
}
