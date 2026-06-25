#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io

command -v nordvpn >/dev/null 2>&1 || {
  echo "VPN: off"
  exit 0
}

output="$(nordvpn status 2>/dev/null)"

if grep -q "Status: Connected" <<<"${output}"; then
  ip="$(grep "^IP:" <<<"${output}" | awk '{print $2}')"
  server="$(sed -n 's/^Server: \(.*\) #.*/\1/p' <<<"${output}")"
  echo "VPN: ${server:-ON} (${ip:-no-ip})"
else
  echo "VPN: off"
fi
