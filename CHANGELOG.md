# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org).

## [Unreleased]

### Fixed

- **apt_install_if_missing() resilience**: Added per-package timeout (120s default), retry with exponential backoff (2s, 4s, 8s), and continue-on-failure behavior
- One bad package no longer aborts the entire batch install
- Progress logging per package: `ok/installed`, `warn/retrying`, `err/failed`
- Fixed `run_as_root` call to pass package names as separate arguments instead of interpolated string

## [2.1.0] - 2026-06-27

### Added

- **SDDM Neon-Minimal Theme**: Custom login screen with `#0A0A10` background, `#008B8B` accent, FiraCode font
- **Interactive Mode**: `--interactive` flag prompts per category (core, dotfiles, shell, security, ai-tools)
- **Skip Flags**: `--skip-dotfiles`, `--skip-shell`, `--skip-tmux`, `--skip.ai` for granular control
- **Progress Bar Rewrite**: Unicode blocks `▓░`, elapsed time MM:SS, color gradient (green/yellow/red)
- `lib/interactive.sh` - category data structures and prompt function
- `tests/test-sddm-theme.sh` - 13 tests for theme files and integration
- `tests/test-progress.sh` - 15 tests for progress bar rendering
- `tests/test-skip-flags.sh` - 44 tests for flag filtering logic
- `tests/test-interactive.sh` - 42 tests for interactive prompts

### Changed

- `setup_i3_kali.sh` - SDDM deploys custom neon-minimal theme instead of breeze
- `lib/state.sh` - `show_progress()` rewritten with 4-param signature and Unicode rendering
- `lib/colors.sh` - added `C_NEON_YELLOW` for progress bar gradient

## [2.0.0] - 2026-06-27

### Added

- **i18n System**: ES/EN internationalization with message catalog, language detection (`--lang` flag), and script integration
- **Theme System**: Centralized color palette (Azul Neón Atenuado) with named constants replacing 31 hardcoded colors
- **Security Arsenal**: NetExec, Sliver C2, Tor, proxychains4, Ghidra JAVA_HOME configuration, UFW basic rules
- `lib/i18n.sh` - i18n infrastructure with associative arrays
- `lib/security.sh` - security tool installation with idempotency and exponential backoff retry
- `tests/test-i18n.sh`, `tests/test-theme.sh`, `tests/test-arsenal.sh` - new test suites

### Changed

- `lib/colors.sh` - expanded with hex palette constants (NEON_BG, NEON_ACCENT, etc.) + export
- `lib/common.sh` - integrated i18n logging functions (ok/warn/err/info/header/step/die)
- `setup_i3_kali.sh` - added `--lang` flag, translated 14 STEP_LABELS, integrated security steps
- `purge_xfce.sh` - added `--lang` flag, translated 10 STEP_LABELS
- `README.md` - updated color palette table and project structure description

### Fixed

- TMUX background inconsistency (#0a0aa0 → NEON_BG)
- All hardcoded #00FFFF occurrences replaced with theme variables

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
