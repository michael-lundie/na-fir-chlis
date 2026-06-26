#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# Simple pomodoro timer - control from anywhere.
# Usage: pomodoro.sh [start [minutes]|stop|toggle|status]

RUNTIME_DIR="${XDG_RUNTIME_DIR:-${HOME}/.cache}/dotfiles-i3blocks"
RUNTIME_DIR="${DOTFILES_RUNTIME_DIR:-${RUNTIME_DIR}}"
readonly RUNTIME_DIR
readonly STATE_FILE="${RUNTIME_DIR}/pomodoro_state"
readonly DEFAULT_MINUTES=25

# start_timer [minutes]
# Write the timer's end time (epoch) to STATE_FILE and refresh i3blocks.
start_timer() {
  local minutes="${1:-${DEFAULT_MINUTES}}"
  local now end_time
  now="$(date +%s)"
  end_time=$(( now + minutes * 60 ))
  echo "${end_time}" > "${STATE_FILE}"
  pkill -RTMIN+2 i3blocks 2>/dev/null
  echo "Pomodoro started: ${minutes} minutes"
}

# stop_timer
# Clear the timer state and refresh i3blocks.
stop_timer() {
  rm -f "${STATE_FILE}"
  pkill -RTMIN+2 i3blocks 2>/dev/null
  echo "Pomodoro stopped"
}

# get_status
# Print the time remaining as MM:SS, or DONE when elapsed / OFF when unset.
get_status() {
  if [[ -f "${STATE_FILE}" ]]; then
    local end_time now remaining
    end_time="$(<"${STATE_FILE}")"
    # Avoid feeding unvalidated file content into $(( )) – arithmetic can execute
    # commands. Also, treat a corrupt state file as no active timer.
    if [[ ! "${end_time}" =~ ^[0-9]+$ ]]; then
      rm -f "${STATE_FILE}"
      echo "OFF"
      return
    fi
    now="$(date +%s)"
    remaining=$(( end_time - now ))
    if [[ "${remaining}" -gt 0 ]]; then
      local mins=$(( remaining / 60 ))
      local secs=$(( remaining % 60 ))
      printf '%02d:%02d\n' "${mins}" "${secs}"
    else
      echo "DONE"
    fi
  else
    echo "OFF"
  fi
}

main() {
  mkdir -p "${RUNTIME_DIR}"
  chmod 700 "${RUNTIME_DIR}"
  case "${1:-status}" in
    start)
      start_timer "${2:-}"
      ;;
    stop)
      stop_timer
      ;;
    toggle)
      if [[ -f "${STATE_FILE}" ]]; then
        stop_timer
      else
        start_timer "${2:-}"
      fi
      ;;
    status)
      get_status
      ;;
    *)
      echo "Usage: pomodoro.sh [start [minutes]|stop|toggle|status]"
      exit 1
      ;;
  esac
}

main "$@"
