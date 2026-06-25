#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# Nord-themed battery indicator for i3blocks (with plug icon when charging).

BAT="$(
  find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT*' -printf '%f\n' \
    | head -n1
)"
[[ -n "${BAT}" ]] || exit 0

STATUS="$(cat "/sys/class/power_supply/${BAT}/status" 2>/dev/null)"
CAPACITY="$(cat "/sys/class/power_supply/${BAT}/capacity" 2>/dev/null)"
[[ "${CAPACITY}" =~ ^[0-9]+$ ]] || exit 0

# Nord palette.
readonly NORD_GREEN="#A3BE8C"
readonly NORD_YELLOW="#EBCB8B"
readonly NORD_ORANGE="#D08770"
readonly NORD_RED="#BF616A"
readonly NORD_CYAN="#88C0D0"

# Choose icon based on level.
if [[ "${CAPACITY}" -ge 95 ]]; then
  ICON=""
  COLOR="${NORD_GREEN}"
elif [[ "${CAPACITY}" -ge 75 ]]; then
  ICON=""
  COLOR="${NORD_GREEN}"
elif [[ "${CAPACITY}" -ge 55 ]]; then
  ICON=""
  COLOR="${NORD_YELLOW}"
elif [[ "${CAPACITY}" -ge 35 ]]; then
  ICON=""
  COLOR="${NORD_ORANGE}"
else
  ICON=""
  COLOR="${NORD_RED}"
fi

# Add plug symbol if charging.
if [[ "${STATUS}" == "Charging" ]]; then
  ICON=" ${ICON}"
  COLOR="${NORD_CYAN}"
fi

# Output for i3blocks.
echo "<span color='${COLOR}'>${ICON} ${CAPACITY}%</span>"
echo "<span color='${COLOR}'>${ICON} ${CAPACITY}%</span>"
echo "${COLOR}"
