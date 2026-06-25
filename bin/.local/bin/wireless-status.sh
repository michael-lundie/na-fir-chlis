#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
set -euo pipefail

command -v iwgetid >/dev/null 2>&1 || {
  echo "down"
  exit 0
}

for iface_path in /sys/class/net/*; do
  iface="${iface_path##*/}"
  [[ -d "${iface_path}/wireless" ]] || continue
  [[ "$(cat "${iface_path}/operstate" 2>/dev/null)" == "up" ]] || continue

  ssid="$(iwgetid "${iface}" -r 2>/dev/null || true)"
  if [[ -n "${ssid}" ]]; then
    echo "${ssid}"
    exit 0
  fi
done

echo "down"
