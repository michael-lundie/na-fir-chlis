#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
# External-connection monitor for i3blocks (VPN-aware; works with NordLynx).
#
# Shows which *process* is talking to which *external peer*, rotating one entry
# per refresh. Flashes red for 10s when a NEW, non-allowlisted external peer
# appears, and logs new peers to ~/.local/share/i3blocks/netlog.txt.
#
# Only genuinely external peers are considered: loopback, RFC1918/CGNAT-style
# private ranges, link-local, ULA, multicast and IPv4-mapped equivalents are
# all filtered out (IPv4 and IPv6).
#
# Allowlist (optional): one entry per line in ${DOTFILES_NETDETAIL_ALLOWLIST},
#   default $XDG_CONFIG_HOME/i3blocks/netdetail-allow.txt
# An entry matches if the peer IP *starts with* it (so "52.39." or a full IP
# both work) or equals the process name. Allowlisted peers are still displayed
# but never trigger the red "NEW!" flash. Lines starting with # are ignored.

set -uo pipefail

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/dotfiles-i3blocks"
RUNTIME_DIR="${DOTFILES_RUNTIME_DIR:-${RUNTIME_DIR}}"
readonly RUNTIME_DIR
readonly PREV_FILE="${RUNTIME_DIR}/net_peers.txt"
readonly INDEX_FILE="${RUNTIME_DIR}/net_index.txt"
readonly ALERT_FILE="${RUNTIME_DIR}/net_alert.txt"
readonly LOG_FILE="${HOME}/.local/share/i3blocks/netlog.txt"

cfg_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/i3blocks"
ALLOWLIST="${DOTFILES_NETDETAIL_ALLOWLIST:-${cfg_dir}/netdetail-allow.txt}"
readonly ALLOWLIST

# Nord palette.
readonly C_GREEN="#A3BE8C"
readonly C_RED="#BF616A"
readonly C_BLUE="#88C0D0"
readonly C_GREY="#4C566A"

# emit <text> <colour>
# Print an i3blocks block: full_text, short_text, colour (one per line).
emit() {
  printf '%s\n%s\n%s\n' "$1" "$1" "$2"
}

# is_external <ip>
# Return 0 if <ip> is a public peer; 1 for loopback / private / link-local /
# ULA / multicast / unspecified (IPv4, IPv4-mapped and native IPv6).
is_external() {
  local ip="${1#::ffff:}"   # unwrap IPv4-mapped IPv6
  [[ -z "${ip}" ]] && return 1
  case "${ip}" in
    # wildcard / loopback / RFC1918 private / link-local
    0.0.0.0|127.*|10.*|192.168.*|169.254.*) return 1 ;;
    # 172.16.0.0/12 private
    172.1[6-9].*|172.2[0-9].*|172.3[0-1].*) return 1 ;;
    # 224.0.0.0/4 multicast
    22[4-9].*|23[0-9].*) return 1 ;;
    # v6 loopback / unspecified
    ::1|::) return 1 ;;
    # v6 link-local fe80::/10
    fe8*:*|fe9*:*|fea*:*|feb*:*) return 1 ;;
    # v6 ULA fc00::/7
    fc*:*|fd*:*) return 1 ;;
    # v6 multicast ff00::/8
    ff*:*) return 1 ;;
  esac
  return 0
}

# strip_port <addr>
# Echo <addr> with its :port and any %zone removed (handles [v6]:port too).
strip_port() {
  local p="$1"
  if [[ "${p}" == \[*\]:* ]]; then   # [v6]:port
    p="${p#\[}"
    p="${p%%\]*}"
  else
    p="${p%:*}"                      # v4:port (or v4%zone:port)
  fi
  printf '%s' "${p%%\%*}"            # drop %iface zone if present
}

# is_allowed <ip> <proc>
# Return 0 if <ip> (prefix match) or <proc> (exact match) is on the allowlist.
# Globals: ALLOWLIST. Blank lines and # comments in the file are ignored.
is_allowed() {
  local ip="$1" proc="$2" entry
  [[ -f "${ALLOWLIST}" ]] || return 1
  while IFS= read -r entry || [[ -n "${entry}" ]]; do
    entry="${entry%%#*}"
    entry="${entry//[[:space:]]/}"
    [[ -z "${entry}" ]] && continue
    [[ "${ip}" == "${entry}"* ]] && return 0
    [[ "${proc}" == "${entry}" ]] && return 0
  done < "${ALLOWLIST}"
  return 1
}

main() {
  mkdir -p "${RUNTIME_DIR}"
  mkdir -p "$(dirname "${LOG_FILE}")"

  # --- VPN tag ---
  local vpn_tag=""
  if command -v nordvpn >/dev/null 2>&1 \
      && nordvpn status 2>/dev/null | grep -q "Status: Connected"; then
    vpn_tag=" [VPN]"
  fi

  if ! command -v ss >/dev/null 2>&1; then
    emit "  net: ss missing" "${C_GREY}"
    exit 0
  fi

  # --- collect current external peers (peer -> process) ---
  local line ip proc
  local -a F
  declare -A PEER_PROC
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    read -ra F <<<"${line}"
    ip="$(strip_port "${F[4]:-}")"   # field 5 = peer address
    is_external "${ip}" || continue
    proc="?"
    [[ "${line}" =~ \"([^\"]+)\" ]] && proc="${BASH_REMATCH[1]}"
    # First process to claim a peer wins (keeps the display stable).
    [[ -n "${PEER_PROC[${ip}]:-}" ]] || PEER_PROC["${ip}"]="${proc}"
  done < <(ss -tunpH state established 2>/dev/null)

  # Stable, sorted list of current peers.
  local -a PEERS
  mapfile -t PEERS < <(printf '%s\n' "${!PEER_PROC[@]}" | sort)
  local count=${#PEERS[@]}

  # --- detect new (non-allowlisted) peers vs. the last run ---
  declare -A PREV
  local p
  if [[ -f "${PREV_FILE}" ]]; then
    while IFS= read -r p; do
      [[ -n "${p}" ]] && PREV["${p}"]=1
    done < "${PREV_FILE}"
  fi

  local -a new_unexpected=()
  for ip in "${PEERS[@]}"; do
    [[ -n "${PREV[${ip}]:-}" ]] && continue              # seen last run
    is_allowed "${ip}" "${PEER_PROC[${ip}]}" && continue  # explicitly allowed
    new_unexpected+=("${ip}")
  done

  # Persist the current peer set for the next run.
  printf '%s\n' "${PEERS[@]}" > "${PREV_FILE}"

  if [[ "${#new_unexpected[@]}" -gt 0 ]]; then
    date +%s > "${ALERT_FILE}"
    {
      echo "$(date '+%Y-%m-%d %H:%M:%S')  NEW external peer(s):"
      for ip in "${new_unexpected[@]}"; do
        printf '    %s  (%s)\n' "${ip}" "${PEER_PROC[${ip}]}"
      done
      echo ""
    } >> "${LOG_FILE}"
  fi

  # Is a flash currently active (within 10s of the last new peer)?
  local alert_active="no"
  if [[ -f "${ALERT_FILE}" ]]; then
    local last_alert now
    last_alert="$(<"${ALERT_FILE}")"
    now="$(date +%s)"
    [[ "${last_alert}" =~ ^[0-9]+$ ]] && (( now - last_alert < 10 )) \
      && alert_active="yes"
  fi

  # --- no external peers ---
  if [[ "${count}" -eq 0 ]]; then
    emit "  no ext. conns${vpn_tag}" "${C_BLUE}"
    exit 0
  fi

  # --- rotate through peers ---
  local index=0
  [[ -f "${INDEX_FILE}" ]] && index="$(<"${INDEX_FILE}")"
  [[ "${index}" =~ ^[0-9]+$ ]] || index=0
  index=$(( (index + 1) % count ))
  echo "${index}" > "${INDEX_FILE}"

  ip="${PEERS[${index}]}"
  proc="${PEER_PROC[${ip}]}"

  local icon color tag
  if [[ "${alert_active}" == "yes" ]]; then
    icon=""
    color="${C_RED}"
    tag=" NEW!"
  else
    icon=""
    color="${C_GREEN}"
    tag=""
  fi

  # e.g. "  brave → 52.39.76.165 (3) [VPN]"
  emit "${icon}  ${proc} → ${ip} (${count})${tag}${vpn_tag}" "${color}"
}

main "$@"
