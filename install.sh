#!/usr/bin/env bash
#
# Reformatted Arch Hyprland Installer
#

set -euo pipefail

# --- Configuration & Variables ---
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${REPO_DIR}/config"
BACKUP_DIR="${HOME}/.config_backup_$(date +%Y%m%d_%H%M%S)"

# Package Groups
HYPRLAND_BASE=(
    "hyprland-git"
    "hypridle-git"
    "hyprsunset-git"
    "hyprpolkitagent"
)

SHELL_TOOLS=(
    "fish"
    "starship"
    "foot"
    "btop"
    "tmux"
    "cava"
)

OTHER_UTILS=(
    "discord"
    "nautilus"
    "zen-browser-bin"
    "zed-editor"
    "uwsm"
)

# --- Helper Functions ---

print_header() {
    clear
    echo "=========================================="
    echo "       Arch Hyprland Installer            "
    echo "=========================================="
    echo
}

confirm() {
    read -r -p "$1 [Y/n] " response
    case "$response" in
        [nN][oO]|[nN]) return 1 ;;
        *) return 0 ;;
    esac
}

# --- 1. Backup .config ---
backup_config() {
    print_header
    echo "Step 1: Backing up ~/.config"
    if [ -d "$HOME/.config" ]; then
        if confirm "Create a backup of your current ~/.config?"; then
            echo "Backing up to $BACKUP_DIR..."
            cp -r "$HOME/.config" "$BACKUP_DIR"
            echo "Backup created at $BACKUP_DIR"
        else
            echo "Skipping backup."
        fi
    else
        echo "No ~/.config found to backup."
    fi
    sleep 1
}

# --- 2. Install AUR Helper ---
install_aur_helper() {
    print_header
    echo "Step 2: AUR Helper Selection"
    
    if command -v yay >/dev/null || command -v paru >/dev/null; then
        echo "AUR helper already installed."
        AUR_HELPER=$(command -v yay || command -v paru)
        AUR_HELPER=$(basename "$AUR_HELPER")
        echo "Using: $AUR_HELPER"
    else
        echo "Choose an AUR helper to install:"
        echo "1) yay"
        echo "2) paru"
        read -r -p "Enter choice [1/2]: " choice
        
        case $choice in
            1) AUR_HELPER="yay" ;;
            2) AUR_HELPER="paru" ;;
            *) echo "Invalid choice, defaulting to yay."; AUR_HELPER="yay" ;;
        esac

        echo "Installing $AUR_HELPER..."
        sudo pacman -S --needed --noconfirm base-devel git
        git clone "https://aur.archlinux.org/${AUR_HELPER}.git" /tmp/"${AUR_HELPER}"
        pushd /tmp/"${AUR_HELPER}" > /dev/null
        makepkg -si --noconfirm
        popd > /dev/null
        rm -rf /tmp/"${AUR_HELPER}"
    fi
    sleep 1
}

# --- 3. Package Installation ---
install_packages() {
    print_header
    echo "Step 3: Package Installation"

    # Install Hyprland Base
    if confirm "Install Hyprland Base (hyprland-git, etc.)?"; then
        $AUR_HELPER -S --needed "${HYPRLAND_BASE[@]}"
    fi

    # Install Shell Tools
    if confirm "Install Shell & Terminal tools (fish, starship, foot, etc.)?"; then
        $AUR_HELPER -S --needed "${SHELL_TOOLS[@]}"
    fi

    # Install Other Utilities
    if confirm "Install Other Utilities (Discord, Zen, Zed, etc.)?"; then
        $AUR_HELPER -S --needed "${OTHER_UTILS[@]}"
    fi
    sleep 1
}

# --- 4. Deploy Config ---
deploy_configs() {
    print_header
    echo "Step 4: Deploying Configurations"
    
    if [ -d "$CONFIG_DIR" ]; then
        echo "Copying config files to ~/.config..."
        mkdir -p "$HOME/.config"
        cp -r "$CONFIG_DIR"/* "$HOME/.config/"
        echo "Configs deployed successfully."
    else
        echo "Error: config/ directory not found in repo."
    fi
    sleep 1
}

# --- 5. Finalize ---
finalize() {
    print_header
    echo "Installation Complete!"
    if confirm "Would you like to reboot now to apply changes?"; then
        echo "Rebooting..."
        systemctl reboot
    else
        echo "Please remember to reboot later."
    fi
}

# --- Main Flow ---
backup_config
install_aur_helper
install_packages
deploy_configs
finalize
