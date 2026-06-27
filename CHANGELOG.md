# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org).

## [Unreleased]

## [1.1.0] - 2026-06-26

### Added

- `--version` flag for both scripts

### Changed

- Extracted shared Bash library (`lib/`) with 5 modules: colors, common, user, state, apt
- Deduplicated ~300 lines across `setup_i3_kali.sh` and `purge_xfce.sh`
- Refactored test suite to use shared `tests/lib/test-helpers.sh`
- Replaced hardcoded paths in docs with relative paths

### Fixed

- Arithmetic bug in `tests/run-tests.sh` (`grep -c` with 0 matches produced double output)
- Error handling in `parse_args` (`err` → `die` for unknown options)

## [1.0.0] - 2026-06-26

### Added

- Core i3-wm installation with NEON MINIMAL theme
- Kitty/Alacritty terminal configuration (FiraCode Nerd Font)
- Polybar status bar with neon theme (`#0A0A0A` background)
- Rofi launcher with border radius 0
- Picom compositor with blur and shadows
- TMUX configuration with KALI logo, TPM, and agent-state hooks
- Zsh + Oh-My-Zsh + Powerlevel10k integration
- Wallpaper deployment from ~/Descargas or automatic generation
- Security tools suite: Metasploit, Nmap, Empire Docker
- Gentle-AI stack integration (`--gentle-ai` flag)
- HexStrike AI MCP integration (`--hexstrike-ai` flag)
- Idempotent checkpoints via `~/.config/i3-setup-state.json`
- Progress bar with NEON colors during installation
- Test suite (unit, integration, approval tests)
- Documentation (INSTALLATION.md, CONTRIBUTING.md)
- Three-phase safe installation (install → verify → purge)
- Branching workflow (`main ← develop ← feature/*`)
- Conventional Commits support
