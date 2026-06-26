#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# Works on Arch Linux

# Shows if there were any new failed sudo/ssh authentication attempts in the
# last few minutes.

RUNTIME_DIR="${XDG_RUNTIME_DIR:-${HOME}/.cache}/dotfiles-i3blocks"
RUNTIME_DIR="${DOTFILES_RUNTIME_DIR:-${RUNTIME_DIR}}"

# Private dir (700): the fallback is no longer world-writable /tmp, and this
# state can hold snippets of the auth journal (usernames, source IPs).
mkdir -p "${RUNTIME_DIR}"
chmod 700 "${RUNTIME_DIR}"

readonly STATE_FILE="${RUNTIME_DIR}/auth_state"
readonly LOG_FILE="${RUNTIME_DIR}/auth_latest"

# Fetch recent auth failures (sudo, ssh, su, polkit).
journalctl -b -n 200 -p warning \
  | grep -Ei \
      -e 'authentication failure' \
      -e 'failed password' \
      -e 'incorrect password' \
      -e 'polkitd.*authentication failure' \
      > "${LOG_FILE}" 2>/dev/null

fails="$(wc -l < "${LOG_FILE}")"

# Compare with the last seen count to detect new failures.
last_fails=0
[[ -f "${STATE_FILE}" ]] && last_fails="$(<"${STATE_FILE}")"

# Save the current count.
echo "${fails}" > "${STATE_FILE}"

if [[ "${fails}" -gt "${last_fails}" ]]; then
  # New failures since the last check.
  echo "⚠️  NEW auth fail"
  echo "⚠️  NEW auth fail"
  echo "#BF616A"   # red
elif [[ "${fails}" -gt 0 ]]; then
  # Historical failures but nothing new.
  echo "  ${fails} fails"
  echo "  ${fails} fails"
  echo "#EBCB8B"   # amber
else
  echo "  OK"
  echo "  OK"
  echo "#A3BE8C"   # green
fi
