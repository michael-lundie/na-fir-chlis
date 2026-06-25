#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# Open a web app in a new browser window, for the i3 Super+b / Super+c binds.
#
# Usage: webapp.sh <fullscreen|float> <browser> <url>
#   fullscreen – new window, toggled to fullscreen (F11)
#   float      – centred floating 16:9 window, handy for screen capture
#
# The browser binary name doubles as the WM_CLASS that xdotool matches on.
# qutebrowser opens a new window with `--target window`; change that flag here
# if you swap to another browser (e.g. Firefox uses `--new-window`).
set -u

mode="${1:?usage: webapp.sh <fullscreen|float> <browser> <url>}"
browser="${2:?missing browser}"
url="${3:?missing url}"

if ! command -v "${browser}" >/dev/null 2>&1; then
  notify-send "Web app launcher" "${browser} is not installed"
  exit 0
fi

# Snapshot the visible windows of this class so we can identify the new one
# (rather than grabbing a stale window if the browser is already running).
class_search=(xdotool search --onlyvisible --class "${browser}")
before="$("${class_search[@]}" 2>/dev/null | sort)"

"${browser}" --target window "${url}" &

# Wait up to ~4s for a NEW window to map. A fixed sleep raced the browser on a
# cold start, and driving a half-initialised window could crash it.
win=""
for ((i = 0; i < 40; i++)); do
  after="$("${class_search[@]}" 2>/dev/null | sort)"
  win="$(comm -13 <(echo "${before}") <(echo "${after}") | tail -1)"
  [[ -n "${win}" ]] && break
  sleep 0.1
done

if [[ -z "${win}" ]]; then
  notify-send "Web app launcher" "could not find the ${browser} window"
  exit 0
fi

# Let the new window finish initialising before driving it.
sleep 0.2

case "${mode}" in
  fullscreen)
    xdotool windowactivate --sync "${win}" key F11
    ;;
  float)
    # Floating 16:9 box. qutebrowser's F11 hides its chrome by going
    # WM-fullscreen; wait for that to land, then drop i3 fullscreen so the
    # window keeps the floating 16:9 size for a clean capture.
    i3-msg "[id=${win}] floating enable" >/dev/null
    i3-msg "[id=${win}] resize set 1340 $(( 1340 * 9 / 16 ))" >/dev/null
    xdotool windowactivate --sync "${win}" key F11
    for ((i = 0; i < 40; i++)); do
      state="$(xprop -id "${win}" _NET_WM_STATE 2>/dev/null)"
      [[ "${state}" == *_NET_WM_STATE_FULLSCREEN* ]] && break
      sleep 0.05
    done
    i3-msg "[id=${win}] fullscreen disable" >/dev/null
    ;;
  *)
    notify-send "Web app launcher" "unknown mode: ${mode}"
    exit 1
    ;;
esac
