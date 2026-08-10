#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# betterlockscreen-sync.sh – keep the lock-screen image in step with the
# current desktop wallpaper.
#
# betterlockscreen pre-renders a blurred/dimmed cache with `-u <image>`; the
# lock itself (`betterlockscreen --lock dimblur`, run by xss-lock) just reuses
# that cache. So the image only needs re-baking when the wallpaper changes.
#
# The current wallpaper is read from ~/.fehbg (written by `feh --bg-*`); if it
# isn't there yet we fall back to the shipped nord0 default. A stamp records the
# last image baked – path + mtime + output geometry (betterlockscreen caches
# per-resolution) – so repeated i3 restarts don't trigger a slow, needless
# re-render. Pass --force to bake regardless (used by the $mod+Shift+w keybind).
#
# Safe on any machine: if betterlockscreen isn't installed (it's the optional
# AUR package) the script quietly does nothing.

# Shipped fallback wallpaper. It lives in the repo next to this script, which is
# stowed into ~/.local/bin as a symlink – resolve that symlink to find the repo,
# so this works wherever the repo was cloned. Override with DOTFILES_WALLPAPER.
self="$(readlink -f "${BASH_SOURCE[0]}")"
repo="${self%/bin/.local/bin/*}"
default="${DOTFILES_WALLPAPER:-${repo}/wallpaper/escape-nord0-1440p.png}"
readonly self repo default

# notify <notify-send args...>
# Send a desktop notification when notify-send is available; else a no-op.
notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send "$@"
}

main() {
  # No betterlockscreen → nothing to do.
  command -v betterlockscreen >/dev/null 2>&1 || exit 0

  local force=0
  [[ "${1:-}" == "--force" ]] && force=1

  # Resolve the current wallpaper from ~/.fehbg, else the shipped default.
  # ~/.fehbg holds: feh --no-fehbg --bg-fill 'path' ['path2' ...] – take the
  # first.
  local img=""
  if [[ -r "${HOME}/.fehbg" ]]; then
    img="$(grep -oE "'[^']+'" "${HOME}/.fehbg" | head -n1 | tr -d "'")"
  fi
  [[ -n "${img}" ]] || img="${default}"

  if [[ ! -r "${img}" ]]; then
    notify -u critical "Lock sync" "Wallpaper not found: ${img}"
    exit 1
  fi

  # Signature: image + mtime + active output geometries (e.g. 1920x1080+0+0).
  local res
  res="$(
    xrandr --current 2>/dev/null \
      | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+' \
      | sort \
      | tr '\n' ','
  )"
  local sig
  sig="${img}|$(stat -c %Y "${img}" 2>/dev/null)|${res}"

  local stamp="${XDG_CACHE_HOME:-${HOME}/.cache}/betterlockscreen-sync.stamp"

  if [[ "${force}" -eq 0 ]] && [[ -r "${stamp}" ]] \
    && [[ "$(<"${stamp}")" == "${sig}" ]]; then
    exit 0
  fi

  # Re-bake the cache. `-u` is the slow step, the only place it runs.
  if betterlockscreen -u "${img}" >/dev/null 2>&1; then
    mkdir -p "$(dirname "${stamp}")"
    printf '%s' "${sig}" >"${stamp}"
    [[ "${force}" -eq 1 ]] \
      && notify "Lock screen" "Synced to current wallpaper."
  else
    notify -u critical "Lock sync" "betterlockscreen -u failed."
    exit 1
  fi
  exit 0
}

main "$@"
