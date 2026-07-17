# Installation Guide — NEON i3-wm for Kali Linux

This guide walks you through migrating from XFCE to i3-wm on Kali Linux. The process has 3 phases: install, verify, purge. Each phase is idempotent — you can re-run if interrupted.

Think of it like building a house: Phase 1 lays the foundation (packages, configs). Phase 2 inspects the work (verify services run). Phase 3 tears down the old structure (remove XFCE). You wouldn't demolish the old house before confirming the new one stands.

## Before you start

| Check | Command | Expected |
|-------|---------|----------|
| Kali version | `cat /etc/os-release` | Kali Linux |
| Disk space | `df -h /` | 2GB+ free |
| Internet | `ping -c 3 kali.org` | Success |

Optional: back up existing configs.

```bash
mkdir -p ~/backup-configs-$(date +%Y%m%d)
cp -r ~/.config ~/backup-configs-$(date +%Y%m%d)/ 2>/dev/null || true
```

Optional: place a wallpaper in `~/Descargas/` (the script auto-detects `.png/.jpg/.jpeg/.webp`).

## Phase 1 — Install

```bash
chmod +x ./setup_i3_kali.sh
sudo ./setup_i3_kali.sh
```

Common variations:

```bash
./setup_i3_kali.sh --user-only        # dotfiles only, no sudo
sudo ./setup_i3_kali.sh --skip-security  # skip pentesting tools
sudo ./setup_i3_kali.sh --gentle-ai   # include AI stack
```

See all flags: `./setup_i3_kali.sh --help`

## Phase 2 — Verify

After the installer finishes, reboot and select **i3** in SDDM.

### Check services

```bash
systemctl status sddm       # display manager
systemctl status docker     # if security suite installed
```

### Check processes

```bash
ps aux | grep -E 'polybar|rofi|picom'
```

If anything is missing, restart i3: `i3-msg restart`

### Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `Mod+Enter` | Open Kitty |
| `Mod+Shift+Enter` | Open Alacritty |
| `Mod+d` | Rofi launcher |
| `Mod+h/j/k/l` | Navigate windows |
| `Mod+1-0` | Switch workspace |
| `Mod+Shift+1-0` | Move window to workspace |
| `Print` | Flameshot screenshot |

`Mod` = Windows/Super key.

## Phase 3 — Purge XFCE

Only run this **after you confirm i3 works correctly**.

```bash
sudo ./purge_xfce.sh
```

This script:
- Protects critical packages (network-manager, systemd, bash, zsh, etc.)
- Removes XFCE, GNOME, and LightDM packages
- Cleans config files
- Keeps SDDM as display manager

Verify the purge:

```bash
dpkg -l | grep -i xfce    # should return nothing
systemctl is-enabled sddm  # should return "enabled"
```

## Post-install

### Configure Powerlevel10k

```bash
p10k configure    # run in first Zsh terminal
```

### Install TMUX plugins

```bash
tmux              # start tmux
# then press Ctrl+B, then I (uppercase) to install plugins
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Black screen on i3 login | Add `exec i3` to `~/.xinitrc` |
| Polybar not showing | `polybar -c ~/.config/polybar/config.ini main` |
| FiraCode fonts missing | `sudo apt install fonts-firacode` |
| Docker permission denied | `sudo usermod -aG docker $USER && newgrp docker` |
| i3 not listed in SDDM | Check `/usr/share/xsessions/i3.desktop` exists |

## Logs

Setup and purge logs are in `/var/log/`:

```bash
sudo tail -f /var/log/setup_i3_kali.log
sudo tail -f /var/log/purge_xfce.log
```
