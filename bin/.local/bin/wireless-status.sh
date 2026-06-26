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
    # The bar renders with markup=pango and the SSID is set by the access
    # point (untrusted). Escape pango metacharacters. Also stops an
    # ordinary '&' in a network name from breaking the block.
    # NB: the \& is required – in bash 5.1+ a bare & in the replacement means
    # "the matched text", which would corrupt the < and > escaping.
    ssid="${ssid//&/\&amp;}"
    ssid="${ssid//</\&lt;}"
    ssid="${ssid//>/\&gt;}"
    echo "${ssid}"
    exit 0
  fi
done

echo "down"
