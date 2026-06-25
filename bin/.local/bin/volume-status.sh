#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# Volume + mute indicator for i3blocks.

# Get the current volume and mute state from pactl.
volume="$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)"
mute_state="$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')"

if [[ "${mute_state}" == "yes" ]]; then
  echo "MUTE"
else
  echo "${volume}"
fi
