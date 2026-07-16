# Getting Started

## Prerequisites

- **Kali Linux** — fresh install (VM or bare metal)
- **bash 3+** — works on Kali and macOS for development
- **Root access** — the script runs most operations via `sudo`
- **Internet connection** — downloads packages, clones repos, installs tools

## Installation

```bash
git clone https://github.com/statick/kali-i3.git
cd kali-i3
chmod +x setup_i3_kali.sh
sudo ./setup_i3_kali.sh
```

The script will:

1. Detect your user and home directory automatically
2. Install i3 window manager and SDDM display manager
3. Deploy dotfiles (wallpapers, i3 config, tmux config)
4. Install Zsh + Oh-My-Zsh + Powerlevel10k
5. Deploy a hacker profile with 50+ security tool aliases
6. Install the security tools suite (Metasploit, Nmap, Ghidra, etc.)
7. Set up anonymity tools (Tor, Proxychains, UFW)
8. Install AI agent integrations (gentle-ai, HexStrike AI)
9. Clean up caches and temp files

## First Boot

After the script completes and you reboot:

1. **SDDM** shows the NEON MINIMAL login theme
2. Log in — i3 starts automatically
3. Open a terminal (`Super+Enter`) — Zsh with Powerlevel10k loads
4. Your hacker profile is sourced automatically with all aliases ready

## Unattended Mode

Skip the interactive prompts and run everything with defaults:

```bash
sudo ./setup_i3_kali.sh --user-only
```

## Partial Installs

Run specific categories only:

```bash
# Only install security tools (skip dotfiles, shell, AI)
sudo ./setup_i3_kali.sh --skip-dotfiles --skip-shell --skip-ai

# Only deploy dotfiles and shell config (skip security)
sudo ./setup_i3_kali.sh --skip-security

# Only set up AI tools
sudo ./setup_i3_kali.sh --skip-dotfiles --skip-shell --skip-security
```

## Language

Switch output language:

```bash
sudo ./setup_i3_kali.sh --lang en   # English (default)
sudo ./setup_i3_kali.sh --lang es   # Spanish
```

## What Gets Installed

| Category | Tools |
|----------|-------|
| Window Manager | i3, i3status, i3lock, dunst, rofi, picom |
| Display Manager | SDDM with NEON MINIMAL theme |
| Shell | Zsh, Oh-My-Zsh, Powerlevel10k, syntax-highlighting, autosuggestions |
| Terminal | tmux with NEON MINIMAL status bar |
| Security Suite | Metasploit, Nmap, Masscan, Gobuster, FFuf, SQLMap, Hydra, John, Hashcat, Ghidra, Radare2, GDB, Wireshark, Responder, YARA, Binwalk |
| Advanced | NetExec, Sliver C2, Empire (Docker) |
| Anonymity | Tor, Proxychains, UFW |
| AI Agents | gentle-ai (Go), gentle-agent-state, HexStrike AI (Python) |
| Docker | docker.io (for Empire and container-based tools) |
