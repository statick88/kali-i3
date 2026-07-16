# Kali i3

**Automated i3 window manager + security tools setup for Kali Linux**

---

## What is this?

A single Bash script that transforms a fresh Kali Linux install into a fully configured pentesting workstation powered by the i3 tiling window manager. Everything runs in 10 automated phases — from installing i3 and SDDM through deploying a curated hacker profile with dozens of security tool aliases and AI agent integrations.

## Features

- **10 automated phases** — i3 core → dotfiles → tmux → zsh → hacker profile → security suite → anonymity → AI tools → cleanup
- **NEON MINIMAL theme** — teal/cyan color palette on a dark `#0A0A10` background across i3, SDDM, tmux, and zsh
- **Idempotent** — safe to re-run; skipped steps are logged and can be resumed via checkpoints
- **Interactive or unattended** — choose categories interactively, or pass `--user-only` / `--skip-security` flags for unattended installs
- **Checkpoint persistence** — progress survives interruptions; resume where you left off
- **Bash 3.x compatible** — works on macOS for development, runs on any Linux with bash 3+
- **27 test files** — lib unit tests, integration tests, VM-based SSH tests, and screenshot validation
- **i18n support** — English and Spanish output via the `--lang` flag

## Quick Start

```bash
git clone https://github.com/statick/kali-i3.git
cd kali-i3
chmod +x setup_i3_kali.sh
sudo ./setup_i3_kali.sh
```

The script will detect your user, install i3 + SDDM, configure your desktop, install security tools, and deploy a complete hacker profile — all in one run.

## Who is this for?

- Pentesters who want a repeatable i3-based Kali setup
- Security researchers who value a minimal, keyboard-driven workflow
- Anyone who wants a dark NEON-themed i3 desktop with security tools pre-configured

## Links

- [Getting Started](getting-started.md) — prerequisites, installation, first boot
- [Architecture](architecture.md) — module structure and design decisions
- [Phases](phases.md) — detailed breakdown of all 10 phases
- [Configuration](configuration.md) — CLI flags and environment variables
- [Customization](customization.md) — colors, themes, dotfiles
- [Testing](testing.md) — test suite structure and how to run tests
- [Contributing](contributing.md) — branch model, conventional commits
