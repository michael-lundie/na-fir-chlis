#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# Lock the screen via xss-lock -> betterlockscreen.
# xss-lock owns the actual locker (so idle/suspend and this manual lock all take
# the same path). If it isn't running, the lock would silently fail – warn
# instead so the failure is visible rather than a no-op.
if pgrep -x xss-lock >/dev/null 2>&1; then
  loginctl lock-session
else
  notify-send -u critical "Lock screen" \
    "xss-lock is not running – log out and back in to enable locking."
fi
