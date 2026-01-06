# Hyprland Dotfiles & Arch Setup

A highly customized and interactive Arch Linux setup featuring **Hyprland** and a **Quickshell**-based interface. This repository aims for a modern, glassmorphic aesthetic with a focus on performance and interactivity.

## ✨ Key Features

- **Window Manager**: [Hyprland](https://hyprland.org/) (git version) for a dynamic and smooth tiling experience.
- **Shell Interface**: Built with [Quickshell](https://github.com/outfoxxed/quickshell), providing a customizable and unified UI for bars, menus, and notifications.
- **Color System**: [Matugen](https://github.com/InSync-dev/matugen) for Material You dynamic color generation.
- **Terminal**: [Foot](https://codeberg.org/dnkl/foot) with [Fish Shell](https://fishshell.com/) and [Starship](https://starship.rs/) prompt.
- **Editor**: [Zed](https://zed.dev/) and [Neovim](https://neovim.io/) for high-performance coding.
- **Utilities**: [btop](https://github.com/aristocratos/btop) for monitoring, [cava](https://github.com/karlstav/cava) for audio visualization, and [uwsm](https://github.com/Vladimir-Zheng/uwsm) for session management.

## 📂 Repository Structure

The `config/` directory contains configurations for:
- `hypr/` - Hyprland rules, keybinds, and window settings.
- `quickshell/` - Custom shell components and UI logic.
- `fish/` & `foot/` - Shell and terminal setup.
- `matugen/` - Color generation templates.
- `nvim/`, `zed/`, `tmux/`, `btop/`, `cava/` - Application-specific configs.

## 🚀 Installation

The setup includes an interactive installation script to automate the process.

### Prerequisites
- An Arch Linux-based system.
- `git` installed.

### Run the Installer
```bash
git clone https://github.com/5yndr0m/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

**The installer will guide you through:**
1. Backing up your existing `~/.config`.
2. Choosing and installing an AUR helper (`yay` or `paru`).
3. Installing package groups (Hyprland base, Shell tools, and Utilities).
4. Deploying the configurations.
5. Rebooting the system.

## ⚠️ Important Notes

- **Backups**: The installer creates a timestamped backup of your `.config` folder.
- **AUR Packages**: Many core components use `-git` or AUR versions for the latest features.
- **Session**: It is recommended to use `uwsm` to launch the Hyprland session as configured.

## 🤝 Acknowledgments

Special thanks to the developers of Hyprland, Quickshell, and the Arch Linux community.
