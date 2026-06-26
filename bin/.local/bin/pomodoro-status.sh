#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# i3blocks pomodoro display.

RUNTIME_DIR="${XDG_RUNTIME_DIR:-${HOME}/.cache}/dotfiles-i3blocks"
RUNTIME_DIR="${DOTFILES_RUNTIME_DIR:-${RUNTIME_DIR}}"
mkdir -p "${RUNTIME_DIR}"
chmod 700 "${RUNTIME_DIR}"

readonly STATE_FILE="${RUNTIME_DIR}/pomodoro_state"

if [[ -f "${STATE_FILE}" ]]; then
  end_time="$(<"${STATE_FILE}")"
  # Guard: never feed unvalidated file content into $(( )) – a non-numeric
  # value can execute commands via bash arithmetic. Drop corrupt state.
  if [[ ! "${end_time}" =~ ^[0-9]+$ ]]; then
    rm -f "${STATE_FILE}"
    exit 0
  fi
  now="$(date +%s)"
  remaining=$(( end_time - now ))

  if [[ "${remaining}" -gt 0 ]]; then
    mins=$(( remaining / 60 ))
    secs=$(( remaining % 60 ))
    printf '󰔛 %02d:%02d\n' "${mins}" "${secs}"
  else
    # Timer done - notify and clean up.
    notify-send -u critical "Pomodoro" "Time's up!"
    rm -f "${STATE_FILE}"
  fi
fi
