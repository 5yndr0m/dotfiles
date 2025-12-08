# dotfiles ✨

> My personal dotfiles collection for a minimal, functional, and familiar Arch Linux + Hyprland setup using the Nord color scheme

<div align="center">

![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/WM-Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=black)
![Nord](https://img.shields.io/badge/Theme-Nord-2E3440?style=for-the-badge)

</div>

Note: I prioritize functionality and familiarity over appearance. All configurations follow the Nord color palette for consistency and readability.

---

## 🖥️ System Overview

<details open>
<summary><b>Core Components</b></summary>

| Component | Application |
|-----------|-------------|
| **OS** | Arch Linux |
| **Compositor** | [Hyprland](https://github.com/hyprwm/Hyprland) |
| **Session Manager** | [UWSM](https://github.com/Vladimir-csp/uwsm) |
| **Status Bar / Widgets** | [Waybar](https://github.com/Alexays/Waybar) |
| **Launcher** | [Fuzzel](https://codeberg.org/dnkl/fuzzel) |
| **Terminal** | [Foot](https://codeberg.org/dnkl/foot) |
| **Lock Screen** | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| **Notification Daemon** | [Mako](https://github.com/emersion/mako) |
| **Logout Menu** | [Wlogout](https://github.com/ArtsyMacaw/wlogout) |
| **Wallpaper Manager** | [Waypaper](https://github.com/anufrievroman/waypaper) |
| **Editors** | [Neovim](https://github.com/neovim/neovim), [Zed](https://github.com/zed-industries/zed) |
| **Terminal Multiplexer** | [Tmux](https://github.com/tmux/tmux) |
| **Shell** | [Fish](https://github.com/fish-shell/fish-shell) (primary) |
| **Fuzzy Finder** | [fzf](https://github.com/junegunn/fzf) |
| **History** | [Atuin](https://github.com/atuinsh/atuin) |
| **System Monitor** | [btop](https://github.com/aristocratos/btop) |
| **Audio Visualizer** | [Cava](https://github.com/karlstav/cava) |

</details>

---

## 🧩 Included Configs

The `config/` directory contains ready-to-use configurations. Each application has its own folder — copy or symlink the ones you want into `~/.config/`.

Included folders (exact names in `config/`):
- `btop` — btop system monitor configuration
- `cava` — Cava audio visualizer configuration
- `fish` — Fish shell configuration (startup, functions, prompt)
- `foot` — Foot terminal configuration
- `fuzzel` — Fuzzel launcher configuration
- `hypr` — Hyprland compositor configuration (bindings, workspaces, layouts)
- `mako` — Mako notification daemon configuration
- `nvim` — Neovim configuration and plugins (I often use nightly)
- `tmux` — Tmux configuration and plugin settings
- `uwsm` — UWSM session manager configuration
- `waybar` — Waybar status bar configuration
- `waypaper` — Waypaper wallpaper manager config
- `wlogout` — Wlogout logout menu configuration
- `zed` — Zed editor settings

All configs use the Nord palette and are designed for practicality and familiarity rather than visual experimentation.

---

## 🎨 Theme

This setup uses the Nord color scheme across applications for a calm, readable, and consistent UI. Visuals are intentionally subdued to reduce distraction and improve clarity — functionality and familiar workflows are the priority.

---

## 🚀 Installation

> Work in Progress: the setup is tailored to my personal workflow and may require changes to suit your environment.

### Prerequisites (example)

Install the core packages you plan to use. This list reflects what the configs target; adjust to your needs:

```bash
sudo pacman -S hyprland uwsm fuzzel foot hyprlock mako waybar wlogout bob neovim zed tmux fish fzf atuin btop cava
```

Notes:
- Some packages are AUR-only or have preferred builds (e.g., Zen Browser, Waypaper). Use an AUR helper for those:
```bash
yay -S zen-browser-bin waypaper-git
```
- If you don't want to install everything, pick only the apps you plan to use and the corresponding config folders.

### Neovim (optional)

If you use my Neovim setup and want nightly features:
```bash
bob install nightly
bob use nightly
```

### Quick Setup (manual)

1. Clone the repository:
```bash
git clone https://github.com/5yndr0m/dottedDotfiles.git
cd dottedDotfiles
```

2. Backup your existing configs:
```bash
mkdir -p ~/dotfiles-backup
cp -r ~/.config ~/dotfiles-backup/
```

3. Apply configurations:

- Copy everything (not recommended if you want to preserve some custom settings):
```bash
cp -r config/* ~/.config/
```

- Or copy only what you need:
```bash
cp -r config/foot ~/.config/foot
cp -r config/hypr ~/.config/hypr
# etc.
```

- Or create symlinks (keeps this repo as the single source of truth):
```bash
ln -s $(pwd)/config/foot ~/.config/foot
ln -s $(pwd)/config/nvim ~/.config/nvim
```

4. Restart Hyprland or reboot for compositor-level changes to take effect.

---

## ⚙️ Design Principles

- Functionality and familiarity: configurations are chosen and tuned to be predictable, stable, and fast to work with.
- Consistency: Nord palette applied across most configs for a unified reading and editing experience.
- Minimal surprises: defaults are conservative; explicit choices are documented in per-config files where necessary.

---

## 🛠️ Next steps / Installer

You mentioned you will specify how the installation script should behave. When you're ready, I can implement an interactive script that:
- Lets you pick which configs to install (copy vs symlink)
- Backs up existing configs automatically
- Optionally installs required packages (prompt before running)
- Makes small, safe path adjustments (e.g., setting $HOME-based paths)
- Logs actions so they can be previewed and reversed

Tell me how you want the installer to behave (interactive flags, defaults, copy vs symlink preferences, package installation automation), and I'll draft the script.

---

## 🤝 Contributing

Contributions welcome:
- Bug reports and issues
- Improved documentation for specific configs
- Help improving Waybar, Hyprland, and editor configurations
- Feature suggestions (open an issue to discuss before implementing)

Pull request checklist:
1. Fork and create a feature branch
2. Test changes locally
3. Provide a clear PR description and rationale

---

## 💝 Acknowledgments

Thanks to upstream projects and communities for inspiration and components:
- Hyprland community
- Waybar, Mako, Foot, Hyprlock authors
- Neovim, Tmux, Fish, and plugin maintainers
- Nord color palette contributors

---

## 📄 License

This project is licensed under the GNU License — see the `LICENSE` file for details.

---

<div align="center">

**⭐ If you found this helpful, consider giving it a star!**

*Made with ❤️ on Arch Linux*

</div>