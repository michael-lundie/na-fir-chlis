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

# Fetch recent auth failures (sudo, ssh, su, polkit) from the last 10 minutes.
# No -p filter: pam logs per-attempt failures at *notice*, which the old
# `-p warning` dropped – so a fumbled sudo or screen unlock was never seen.
# -o short-unix prefixes each line with an epoch timestamp, used below to spot
# genuinely new failures even as the window slides.
journalctl -b --since "10 minutes ago" -o short-unix \
  | grep -Ei \
      -e 'authentication failure' \
      -e 'failed password' \
      -e 'incorrect password' \
      -e 'polkitd.*authentication failure' \
      > "${LOG_FILE}" 2>/dev/null

fails="$(wc -l < "${LOG_FILE}")"

# Timestamp (epoch) of the newest failure in the window. The journal is
# chronological, so the last line is newest; field 1 of short-unix is the epoch.
newest_ts="$(tail -n 1 "${LOG_FILE}" | cut -d' ' -f1)"

# Compare against the newest failure seen last run. Tracking the timestamp – not
# a raw count – means a new failure still flags red even when the sliding window
# has dropped older failures below a previous count peak.
last_ts=0
[[ -f "${STATE_FILE}" ]] && last_ts="$(<"${STATE_FILE}")"

# Save the newest timestamp for next time (0 when the window is empty).
echo "${newest_ts:-0}" > "${STATE_FILE}"

# awk does the compare: epochs carry microseconds (float), and +0 forces numeric
# so an empty timestamp collapses to 0 rather than comparing as text.
if awk -v a="${newest_ts:-0}" -v b="${last_ts:-0}" 'BEGIN { exit !((a + 0) > (b + 0)) }'; then
  # A failure newer than anything seen last run: something new just happened.
  echo "⚠️  NEW auth fail"
  echo "⚠️  NEW auth fail"
  echo "#BF616A"   # red
elif [[ "${fails}" -gt 0 ]]; then
  # Failures still in the window, but nothing new since last run.
  echo "  ${fails} fails"
  echo "  ${fails} fails"
  echo "#EBCB8B"   # amber
else
  echo "  OK"
  echo "  OK"
  echo "#A3BE8C"   # green
fi
