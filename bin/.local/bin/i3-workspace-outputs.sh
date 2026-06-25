#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
set -euo pipefail

command -v xrandr >/dev/null 2>&1 || exit 0
command -v i3-msg >/dev/null 2>&1 || exit 0

mapfile -t connected_outputs < <(xrandr --query | awk '/ connected/ {print $1}')
[[ "${#connected_outputs[@]}" -eq 2 ]] || exit 0

primary_output="$(xrandr --query | awk '/ connected primary/ {print $1; exit}')"
if [[ -z "${primary_output:-}" ]]; then
  primary_output="${connected_outputs[0]}"
fi

secondary_output=""
for output in "${connected_outputs[@]}"; do
  if [[ "${output}" != "${primary_output}" ]]; then
    secondary_output="${output}"
    break
  fi
done

[[ -n "${secondary_output}" ]] || exit 0

for workspace in 1 2 3 4 5 6 7 8 9 10; do
  if (( workspace % 2 == 0 )); then
    i3-msg "workspace number ${workspace} output ${primary_output}" >/dev/null
  else
    i3-msg "workspace number ${workspace} output ${secondary_output}" >/dev/null
  fi
done
