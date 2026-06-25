#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
set -euo pipefail

command -v ip >/dev/null 2>&1 || {
  echo "down"
  exit 0
}

for iface_path in /sys/class/net/*; do
  iface="${iface_path##*/}"
  [[ "${iface}" != "lo" ]] || continue
  [[ ! -d "${iface_path}/wireless" ]] || continue
  [[ "$(cat "${iface_path}/operstate" 2>/dev/null)" == "up" ]] || continue

  ip_addr="$(
    ip -4 -o addr show dev "${iface}" scope global 2>/dev/null \
      | awk '{print $4}' \
      | cut -d/ -f1 \
      | head -n1
  )"
  if [[ -n "${ip_addr}" ]]; then
    echo "${ip_addr}"
    exit 0
  fi
done

echo "down"
