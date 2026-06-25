#!/usr/bin/env bash
# Na Fir-Chlis – a Nord i3wm theme · lundie.io
#
# install.sh – deploy these dotfiles with GNU Stow.
#
# Safe by design:
#   * Stow only ever creates symlinks; it refuses to clobber real files.
#   * Any pre-existing real config is backed up before stowing, never deleted.
#   * Re-runnable (idempotent): running twice is a no-op.
#
# Usage:
#   ./install.sh              # stow every package into $HOME
#   ./install.sh i3 dunst     # stow only the named packages
#   ./install.sh --deps       # also install Arch packages from deps-arch.txt
#   ./install.sh --jp         # also install Japanese input (IBus + Mozc, AUR)
#   ./install.sh --unstow     # remove the symlinks this repo created
#
# Japanese input is opt-in: without --jp, ibus/ibus-mozc are never installed,
# and the i3 + .xinitrc IBus bits stay dormant (self-skip when ibus is absent).
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR
readonly TARGET="${HOME}"

# Stow packages are auto-discovered: any top-level directory containing a
# dotfile tree (a ".*" entry somewhere) is a package. This naturally skips docs
# dirs like md/ and docs/, and means adding a new package needs no edit here.
ALL_PACKAGES=()
for _dir in "${DOTFILES_DIR}"/*/; do
  if find "${_dir}" -mindepth 1 -name '.*' -print -quit | grep -q .; then
    ALL_PACKAGES+=("$(basename "${_dir}")")
  fi
done
readonly ALL_PACKAGES

BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
readonly BACKUP_DIR

die() { echo "error: $*" >&2; exit 1; }

# Print the script's header comment block (description + usage) as help text.
usage() { awk 'NR<3 { next } /^#/ { print; next } { exit }' "$0"; }

# Checked only before stowing, so --help/--deps/--jp work without stow.
require_stow() {
  command -v stow >/dev/null 2>&1 && return 0
  die "GNU stow is not installed. Install it with your package manager" \
    "(Arch: 'sudo pacman -S stow', or './install.sh --deps')."
}

# --deps and --jp install packages via pacman/AUR; fail clearly off Arch.
# Arguments: $1 – the flag name, used in the message.
require_pacman() {
  command -v pacman >/dev/null 2>&1 && return 0
  die "${1} is Arch-only (pacman/AUR). Install the listed packages with your" \
    "distro's package manager, then re-run without ${1}."
}

install_deps() {
  require_pacman "--deps"
  [[ -f "${DOTFILES_DIR}/deps-arch.txt" ]] || die "deps-arch.txt not found"
  local wanted=() missing=() pkg
  mapfile -t wanted < <(
    grep -Ev '^[[:space:]]*(#|$)' "${DOTFILES_DIR}/deps-arch.txt"
  )
  [[ ${#wanted[@]} -gt 0 ]] \
    || die "deps-arch.txt contains no installable packages"
  # Only install packages that are missing entirely. Anything already present is
  # left as-is – even if older – so we never trigger a partial upgrade (which on
  # rolling Arch can break held-back deps). Use 'pacman -Syu' to update.
  for pkg in "${wanted[@]}"; do
    pacman -Qq "${pkg}" >/dev/null 2>&1 || missing+=("${pkg}")
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    echo ">> All listed packages already installed – nothing to install."
    return
  fi
  echo ">> Installing missing packages: ${missing[*]}"
  sudo pacman -S --needed "${missing[@]}"
  echo ">> Done. Already-installed packages were left untouched" \
    "(run 'pacman -Syu' to update them)."
}

# Japanese input (IBus + Mozc). mozc/ibus-mozc live in the AUR, so this prefers
# an AUR helper; with none, it installs ibus and tells you to add ibus-mozc.
install_jp() {
  require_pacman "--jp"
  local jp=(ibus ibus-mozc)
  echo ">> Installing Japanese input support (${jp[*]}) ..."
  if command -v yay >/dev/null 2>&1; then
    yay -S --needed "${jp[@]}"
  elif command -v paru >/dev/null 2>&1; then
    paru -S --needed "${jp[@]}"
  else
    echo ">> No AUR helper (yay/paru) found; installing 'ibus' from" \
      "official repos only." >&2
    sudo pacman -S --needed ibus
    echo ">> NOTE: install 'ibus-mozc' from the AUR manually" \
      "(e.g. 'yay -S ibus-mozc')." >&2
  fi
}

# Move any real (non-symlink) files that would conflict out of the way, so stow
# can take over without ever deleting your originals.
# Arguments: $1 – the package name. Globals: DOTFILES_DIR, TARGET, BACKUP_DIR.
backup_conflicts() {
  local pkg="$1" src rel dest
  while IFS= read -r -d '' src; do
    rel="${src#"${DOTFILES_DIR}/${pkg}/"}"
    dest="${TARGET}/${rel}"
    if [[ -e "${dest}" && ! -L "${dest}" ]]; then
      mkdir -p "${BACKUP_DIR}/$(dirname "${rel}")"
      echo "   backing up existing ${dest} -> ${BACKUP_DIR}/${rel}"
      mv "${dest}" "${BACKUP_DIR}/${rel}"
    fi
  done < <(find "${DOTFILES_DIR}/${pkg}" -type f -print0)
}

# Scripts in bin/.local/bin are launched by path – i3blocks `command=` lines and
# i3 `exec` rules run them directly – so they must carry the execute bit. Git
# normally tracks +x, but it can be lost in transit (an editor rewrite, a clone
# with core.fileMode=false, a zip download), which silently breaks those blocks.
# Re-assert it here, printing each change, so it is never a surprise that these
# files become runnable. Nothing outside bin/.local/bin is touched.
mark_scripts_executable() {
  local bindir="${DOTFILES_DIR}/bin/.local/bin" f changed=0 already=0
  [[ -d "${bindir}" ]] || return 0
  echo ">> Ensuring bin/.local/bin scripts are executable (run by i3/i3blocks):"
  for f in "${bindir}"/*.sh; do
    [[ -e "${f}" ]] || continue
    if [[ -x "${f}" ]]; then
      already=$(( already + 1 ))
    else
      chmod +x "${f}"
      echo "     marked executable: ${f#"${DOTFILES_DIR}/"}"
      changed=$(( changed + 1 ))
    fi
  done
  echo "     ${changed} newly marked, ${already} already executable"
}

stow_packages() {
  local pkgs=("$@") pkg
  for pkg in "${pkgs[@]}"; do
    [[ -d "${DOTFILES_DIR}/${pkg}" ]] || die "no such package: ${pkg}"
    echo ">> Stowing ${pkg}"
    [[ "${pkg}" == "bin" ]] && mark_scripts_executable
    backup_conflicts "${pkg}"
    # --no-folding: symlink individual files into real directories rather than
    # folding a whole dir into one symlink. Folding is a footgun – an `rm` of a
    # file path inside a folded dir deletes the file from the repo (it resolves
    # through the symlink), and it lets apps write runtime state into the repo.
    stow --no-folding --dir="${DOTFILES_DIR}" --target="${TARGET}" \
      --restow "${pkg}"
  done
  # Ensure the i3blocks runtime log dir used by netdetail-rotating.sh exists.
  mkdir -p "${HOME}/.local/share/i3blocks"
  echo ">> Done. Backups (if any) are in: ${BACKUP_DIR}"
}

unstow_packages() {
  local pkgs=("$@") pkg
  for pkg in "${pkgs[@]}"; do
    echo ">> Unstowing ${pkg}"
    stow --dir="${DOTFILES_DIR}" --target="${TARGET}" --delete "${pkg}"
  done
}

main() {
  local do_deps=0 do_jp=0 action="stow" pkgs=() arg
  for arg in "$@"; do
    case "${arg}" in
      --deps)    do_deps=1 ;;
      --jp)      do_jp=1 ;;
      --unstow)  action="unstow" ;;
      -h|--help) usage; exit 0 ;;
      -*)        die "unknown flag: ${arg}" ;;
      *)         pkgs+=("${arg}") ;;
    esac
  done

  [[ ${#pkgs[@]} -eq 0 ]] && pkgs=("${ALL_PACKAGES[@]}")
  [[ ${do_deps} -eq 1 ]] && install_deps
  [[ ${do_jp} -eq 1 ]] && install_jp

  require_stow
  if [[ "${action}" == "unstow" ]]; then
    unstow_packages "${pkgs[@]}"
  else
    stow_packages "${pkgs[@]}"
  fi
}

main "$@"
