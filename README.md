# dotfiles ✨

> My personal dotfiles collection for a beautiful, minimal, and functional Arch Linux + Hyprland setup with Nord theme

<div align="center">

![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/WM-Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=black)

</div>

## 🖥️ System Information

<details open>
<summary><b>Core Components</b></summary>

| Component | Application |
|-----------|-------------|
| **OS** | Arch Linux |
| **Compositor** | [Hyprland](https://github.com/hyprwm/Hyprland) |
| **Session Manager** | [UWSM](https://github.com/Vladimir-csp/uwsm) |
| **Status Bar** | [Waybar](https://github.com/Alexays/Waybar) |
| **Launcher** | [Fuzzel](https://codeberg.org/dnkl/fuzzel) |
| **Terminal** | [Foot](https://codeberg.org/dnkl/foot) |
| **Lock Screen** | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| **Notification Daemon** | [Mako](https://github.com/emersion/mako) |
| **File Manager** | [Thunar](https://gitlab.gnome.org/GNOME/nautilus) |
| **Wallpaper Manager** | [Waypaper](https://github.com/anufrievroman/waypaper) |

</details>

<details>
<summary><b>Development & Productivity</b></summary>

| Category | Applications |
|----------|-------------|
| **Editors** | [Neovim](https://github.com/neovim/neovim), [Zed](https://github.com/zed-industries/zed) |
| **Browser** | [Zen Browser](https://github.com/zen-browser/desktop) |
| **Terminal Multiplexer** | [Tmux](https://github.com/tmux/tmux) |
| **Shell** | [Fish](https://github.com/fish-shell/fish-shell) + [Bash](https://www.gnu.org/software/bash/) |
| **Fuzzy Finder** | [fzf](https://github.com/junegunn/fzf) |
| **History** | [Atuin](https://github.com/atuinsh/atuin) |

</details>

<details>
<summary><b>System Monitoring & Audio</b></summary>

| Purpose | Application |
|---------|-------------|
| **System Monitor** | [btop](https://github.com/aristocratos/btop) |
| **Audio Visualizer** | [Cava](https://github.com/karlstav/cava) |

</details>

## 🧩 Included Configs

This repository's `config/` directory contains ready-to-use configuration folders for various applications. You can find them in `config/` and copy or symlink the ones you need into `~/.config/`.

Included config directories:
- `btop` — Configuration for btop system monitor
- `cava` — Cava audio visualizer configuration
- `fish` — Fish shell configuration (startup, functions, prompts)
- `foot` — Foot terminal emulator configuration
- `fuzzel` — Fuzzel launcher configuration
- `hypr` — Hyprland compositor configuration (layouts, binds, workspaces)
- `mako` — Mako notification daemon configuration
- `nvim` — Neovim setup and plugins (uses nightly in my workflow)
- `tmux` — Tmux configuration and plugin settings
- `uwsm` — UWSM session manager configuration
- `waybar` — Waybar status bar configuration (alternative to QuickShell)
- `waypaper` — Waypaper wallpaper manager configuration
- `wlogout` — Wlogout logout menu configuration
- `zed` — Zed editor settings

If you want to apply only a subset of these, copy or symlink the corresponding folders into `~/.config/` instead of copying everything.

---

## 🎨 Theme

This setup uses the **Nord** colorscheme throughout most applications for a cohesive and elegant dark theme experience and I have placed much emphasis on lavender color than others :)

---

## 📄 License

This project is licensed under the GNU License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**⭐ If you found this helpful, consider giving it a star!**

*Made with ❤️ on Arch Linux*

</div>
