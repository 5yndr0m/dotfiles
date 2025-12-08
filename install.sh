#!/usr/bin/env bash
#
# Interactive installer for dottedDotfiles
#
# Features:
#  - Optional backup of ~/.config
#  - Detect or install AUR helper (yay or paru) per user choice
#  - Install selected packages (official repo + AUR)
#  - Install rustup early (required for building some packages)
#  - Use `bob` to install Neovim nightly (if bob available/installed)
#  - Copy or symlink config/ contents into ~/.config
#  - Install GTK theme (nordic-theme-git via AUR) and optional cursor theme (AUR)
#  - Log all actions
#
# Usage:
#  Place this file at the root of the repository and run:
#    bash ./install.sh
#
set -euo pipefail

########################
# Configuration / Vars #
########################

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="${HOME}/.cache/dottedDotfiles"
LOG_FILE="${LOG_DIR}/install-$(date +%Y%m%d-%H%M%S).log"
BACKUP_PREFIX="${HOME}/dotfiles-backup"
AUR_HELPERS=("paru" "yay")

# Packages: group into 'official' and 'aur' buckets. Some packages may reside in either depending on user repo setup;
# the script will try pacman first for 'official' and AUR helper for 'aur' packages.
OFFICIAL_PACKAGES=(
  hyprland
  hyprlock
  thunar
  fzf
  jq
  fish
  foot
  bob
  tmux
  btop
  cava
  fuzzel
  starship
  udiskie
  python-pip  # Optional: some tools might need python
  git
  base-devel
)

# AUR or special packages (examples user asked for)
AUR_PACKAGES=(
  zen-browser-bin
  zed
  waybar
  waypaper-git
  hypridle
  hyprsunset
  hyprpolkitagent
  mako
  nwg-look
  uwsm
  atuin
  lazygit
  nordic-theme-git
)

# You can extend these lists or allow selection during runtime
# Note: some names may differ between repos/aur; the script asks before attempting to install.

########################
# Helper Functions     #
########################

mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"

log() {
  local msg="$*"
  echo "$(date +'%F %T') | ${msg}" | tee -a "${LOG_FILE}"
}

err() {
  echo >&2 "ERROR: $*"
  log "ERROR: $*"
}

confirm() {
  # yes/no prompt. Default yes if ENTER pressed.
  local prompt="${1:-Continue?}"
  local default_yes="${2:-yes}" # "yes" or "no"
  local response
  if [ "${default_yes}" = "yes" ]; then
    read -r -p "${prompt} [Y/n] " response
    response="${response:-y}"
  else
    read -r -p "${prompt} [y/N] " response
    response="${response:-n}"
  fi
  case "${response,,}" in
    y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

pause() {
  read -r -p "Press Enter to continue..."
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Required command '$1' not found. Please install it and re-run the script."
    exit 1
  fi
}

detect_pacman() {
  if command -v pacman >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

detect_aur_helper() {
  for h in "${AUR_HELPERS[@]}"; do
    if command -v "${h}" >/dev/null 2>&1; then
      echo "${h}"
      return 0
    fi
  done
  return 1
}

install_aur_helper() {
  # Installs yay or paru by cloning AUR and building with makepkg.
  # Requires git and base-devel.
  local helper="$1" # yay or paru
  log "Installing AUR helper: ${helper}"
  require_cmd git
  require_cmd makepkg

  local build_dir
  build_dir="$(mktemp -d)"
  pushd "${build_dir}" >/dev/null
  if [ "${helper}" = "yay" ]; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
  else
    git clone https://aur.archlinux.org/paru.git
    cd paru
  fi
  log "Building ${helper} in ${PWD}"
  # Build and install
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf "${build_dir}"
}

install_packages_pacman() {
  local pkgs=("$@")
  if [ "${#pkgs[@]}" -eq 0 ]; then
    log "No pacman packages to install."
    return
  fi
  log "Installing pacman packages: ${pkgs[*]}"
  sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"
}

install_packages_aur() {
  local helper="$1"; shift
  local pkgs=("$@")
  if [ "${#pkgs[@]}" -eq 0 ]; then
    log "No AUR packages to install."
    return
  fi
  log "Installing AUR packages with ${helper}: ${pkgs[*]}"
  if [ "${helper}" = "paru" ]; then
    paru -S --noconfirm --needed "${pkgs[@]}"
  else
    yay -S --noconfirm --needed "${pkgs[@]}"
  fi
}

backup_config() {
  local dest="${BACKUP_PREFIX}-$(date +%Y%m%d-%H%M%S)"
  if [ ! -d "${HOME}/.config" ]; then
    log "No existing ${HOME}/.config directory to back up."
    return
  fi
  log "Backing up ${HOME}/.config to ${dest}"
  mkdir -p "$(dirname "${dest}")"
  # Use rsync if available for a consistent copy that preserves attributes
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --info=progress2 "${HOME}/.config/" "${dest}/"
  else
    cp -a "${HOME}/.config" "${dest}"
  fi
  log "Backup completed."
}

copy_configs_to_home() {
  local method="${1:-copy}" # copy or symlink
  local src="${REPO_DIR}/config"
  if [ ! -d "${src}" ]; then
    err "Config directory not found in repository: ${src}"
    return 1
  fi

  log "Applying configs from ${src} to ${HOME}/.config using method='${method}'"

  mkdir -p "${HOME}/.config"
  if [ "${method}" = "symlink" ]; then
    for d in "${src}"/*; do
      [ -e "${d}" ] || continue
      local base
      base="$(basename "${d}")"
      local target="${HOME}/.config/${base}"
      if [ -e "${target}" ] || [ -L "${target}" ]; then
        log "Existing ${target} found — skipping (not overwriting)."
        continue
      fi
      ln -s "${d}" "${target}"
      log "Symlinked ${d} -> ${target}"
    done
  else
    # copy (rsync preserves metadata, safer)
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --info=progress2 "${src}/" "${HOME}/.config/"
    else
      cp -a "${src}/." "${HOME}/.config/"
    fi
    log "Copied configs to ${HOME}/.config"
  fi
}

install_rustup_and_toolchain() {
  # Prefer distro package if available to allow system package manager to manage it; otherwise use rustup-init.
  log "Installing rustup and toolchain (stable) early because some builds depend on Rust."
  if pacman -Qi rustup >/dev/null 2>&1; then
    log "rustup package already installed via pacman."
  else
    log "Installing rustup via pacman..."
    sudo pacman -S --noconfirm --needed rustup
  fi

  # initialize rustup environment
  if [ -f "${HOME}/.cargo/env" ]; then
    # shellcheck disable=SC1090
    source "${HOME}/.cargo/env"
  fi

  # Install stable toolchain and add components commonly needed for building AUR crates
  rustup toolchain install stable --profile minimal || true
  rustup default stable || true
  # Install cargo build helpers
  rustup component add rustfmt clippy || true

  log "rustup and stable toolchain set up."
}

install_neovim_nightly_with_bob() {
  if ! command -v bob >/dev/null 2>&1; then
    log "bob not found; skipping Neovim nightly via bob. You can install bob and re-run this step."
    return
  fi
  log "Installing Neovim nightly with bob..."
  bob install nightly
  bob use nightly
  log "Neovim nightly installation attempted via bob."
}

########################
# Interactive Workflow  #
########################

echo "=== dottedDotfiles Installer ==="
log "Started install script (cwd=${REPO_DIR})"

if ! detect_pacman; then
  err "This installer expects an Arch-like system with pacman. Exiting."
  exit 1
fi

echo
echo "Step 1 — Backup"
if confirm "Do you want to back up your current ~/.config to ${BACKUP_PREFIX}-TIMESTAMP?" "yes"; then
  backup_config
else
  log "User chose not to back up ~/.config"
fi

echo
echo "Step 2 — AUR helper detection"
AUR_HELPER_DETECTED="$(detect_aur_helper || true)"
if [ -n "${AUR_HELPER_DETECTED}" ]; then
  log "Detected AUR helper: ${AUR_HELPER_DETECTED}"
  echo "Detected AUR helper: ${AUR_HELPER_DETECTED}"
else
  echo "No AUR helper detected (yay or paru)."
  if confirm "Do you want to install an AUR helper now? (yay or paru)?" "yes"; then
    echo "Which AUR helper do you prefer?"
    select choice in "${AUR_HELPERS[@]}" "skip"; do
      if [ "${choice}" = "skip" ]; then
        log "User chose to skip AUR helper installation."
        AUR_HELPER_DETECTED=""
        break
      fi
      if [[ " ${AUR_HELPERS[*]} " == *" ${choice} "* ]]; then
        # Ensure git & base-devel are installed first
        log "Ensuring git & base-devel present"
        sudo pacman -S --needed --noconfirm git base-devel
        install_aur_helper "${choice}"
        AUR_HELPER_DETECTED="$(detect_aur_helper || true)"
        break
      fi
    done
  else
    log "User chose not to install an AUR helper."
  fi
fi

echo
echo "Step 3 — Rust toolchain (early)"
if confirm "Install rustup and set up Rust toolchain now? This is recommended (some packages need Rust)?" "yes"; then
  install_rustup_and_toolchain
else
  log "User chose to skip rustup installation for now."
fi

echo
echo "Step 4 — Package selection"
log "Presenting package lists to user"
echo "The script can install a recommended set of packages. You can choose to:"
echo "  1) Install all recommended packages"
echo "  2) Choose interactively (select categories)"
echo "  3) Skip package installation"
PS3="Choose an option (1/2/3): "
select pkgmode in "Install all" "Choose interactively" "Skip"; do
  case "${pkgmode}" in
    "Install all")
      log "User chose to install all packages"
      TO_INSTALL_OFFICIAL=("${OFFICIAL_PACKAGES[@]}")
      TO_INSTALL_AUR=("${AUR_PACKAGES[@]}")
      break
      ;;
    "Choose interactively")
      log "User chose interactive package selection"
      TO_INSTALL_OFFICIAL=()
      TO_INSTALL_AUR=()
      # Ask to install official packages as a group
      if confirm "Install general system packages (hyprland, hyprlock, thunar, foot, fzf, etc)?" "yes"; then
        TO_INSTALL_OFFICIAL+=("${OFFICIAL_PACKAGES[@]}")
      fi
      # AUR/group packages
      if confirm "Install AUR / additional packages (zen-browser-bin, zed, waybar, nordic-theme-git, etc)?" "yes"; then
        TO_INSTALL_AUR+=("${AUR_PACKAGES[@]}")
      fi
      # Ask for optional GTK/Qt packages
      if confirm "Install GTK / Qt libraries commonly needed by Hyprland (gtk3, gtk4, qt5/6)?" "yes"; then
        TO_INSTALL_OFFICIAL+=(gtk3 gtk4 qt5-base qt6-base)
      fi
      # Prompt for extra items that are sometimes required
      if confirm "Install optional utilities: udiskie, starship, lazygit?" "yes"; then
        TO_INSTALL_OFFICIAL+=(udiskie starship lazygit)
      fi
      break
      ;;
    "Skip")
      log "User chose to skip package installation"
      TO_INSTALL_OFFICIAL=()
      TO_INSTALL_AUR=()
      break
      ;;
    *)
      echo "Invalid choice"
      ;;
  esac
done

# Summarize packages to install
echo
if [ "${#TO_INSTALL_OFFICIAL[@]}" -gt 0 ]; then
  echo "Official repo packages to be installed:"
  printf "  %s\n" "${TO_INSTALL_OFFICIAL[@]}"
fi
if [ "${#TO_INSTALL_AUR[@]}" -gt 0 ]; then
  echo "AUR / special packages to be installed:"
  printf "  %s\n" "${TO_INSTALL_AUR[@]}"
fi
if [ "${#TO_INSTALL_OFFICIAL[@]}" -eq 0 ] && [ "${#TO_INSTALL_AUR[@]}" -eq 0 ]; then
  echo "No packages selected for installation."
fi

if [ "${#TO_INSTALL_OFFICIAL[@]}" -gt 0 ] || [ "${#TO_INSTALL_AUR[@]}" -gt 0 ]; then
  if confirm "Proceed with package installation?" "yes"; then
    if [ "${#TO_INSTALL_OFFICIAL[@]}" -gt 0 ]; then
      install_packages_pacman "${TO_INSTALL_OFFICIAL[@]}"
    fi

    if [ "${#TO_INSTALL_AUR[@]}" -gt 0 ]; then
      if [ -n "${AUR_HELPER_DETECTED}" ]; then
        install_packages_aur "${AUR_HELPER_DETECTED}" "${TO_INSTALL_AUR[@]}"
      else
        echo "No AUR helper available. You can install one (yay or paru) and re-run to install AUR packages."
        log "Skipping AUR package installation because no AUR helper found."
      fi
    fi
  else
    log "User canceled package installation step."
  fi
fi

echo
echo "Step 5 — GTK theme and cursor"
if confirm "Install 'nordic-theme-git' (AUR) and optionally a cursor theme now?" "yes"; then
  if [ -n "${AUR_HELPER_DETECTED}" ]; then
    if printf '%s\n' "${TO_INSTALL_AUR[@]}" | grep -qx "nordic-theme-git"; then
      log "nordic-theme-git already scheduled to install"
    else
      if confirm "Install 'nordic-theme-git' now via ${AUR_HELPER_DETECTED}?" "yes"; then
        install_packages_aur "${AUR_HELPER_DETECTED}" nordic-theme-git
      fi
    fi

    read -r -p "Enter AUR package name for desired cursor theme (leave blank to skip): " CURSOR_AUR
    if [ -n "${CURSOR_AUR}" ]; then
      if confirm "Install cursor theme '${CURSOR_AUR}' via ${AUR_HELPER_DETECTED}?" "yes"; then
        install_packages_aur "${AUR_HELPER_DETECTED}" "${CURSOR_AUR}"
      fi
    else
      log "No cursor theme requested."
    fi
  else
    echo "No AUR helper detected. Skipping AUR theme installs. Install nordic-theme-git manually or install an AUR helper and re-run."
    log "Skipping nordic-theme-git install due to missing AUR helper."
  fi
else
  log "User chose not to install GTK theme and cursor at this time."
fi

echo
echo "Step 6 — Apply configs to ~/.config"
echo "You can copy or symlink the repository's config folders into your home config."
PS3="Choose how to apply configs: "
select cfgmethod in "Copy (recommended)" "Symlink (keeps repo as source of truth)" "Skip"; do
  case "${cfgmethod}" in
    "Copy (recommended)")
      copy_configs_to_home "copy"
      break
      ;;
    "Symlink (keeps repo as source of truth)")
      copy_configs_to_home "symlink"
      break
      ;;
    "Skip")
      log "User chose to skip applying configs."
      break
      ;;
    *)
      echo "Invalid choice"
      ;;
  esac
done

echo
echo "Step 7 — Neovim nightly via bob (optional)"
if command -v bob >/dev/null 2>&1; then
  if confirm "Install Neovim nightly via bob now?" "yes"; then
    install_neovim_nightly_with_bob
  else
    log "User skipped bob Neovim nightly installation."
  fi
else
  log "bob not found. If you want Neovim nightly, install bob and re-run this step or install Neovim manually."
fi

echo
echo "Finalizing..."
log "Install script completed major steps. See ${LOG_FILE} for details."

cat <<EOF

Installation summary recorded to:
  ${LOG_FILE}

What you might want to do next:
 - Review ${LOG_FILE} to see exactly what ran
 - Log out and back in or reboot to apply environment/service changes
 - If Waybar or Mako were installed, restart or reload them as needed
 - If you used symlinks, keep the repo in place; to stop using repo-managed configs, remove symlinks and restore backups

If anything failed, check the log and try the failing step manually. I intentionally do not auto-reboot or restart user services.

EOF

log "Done."

exit 0
