#!/usr/bin/env bash
# =============================================================================
# lib/colors.sh — Gentleman Theme color constants
# =============================================================================
# Extracted from setup_i3_kali.sh and purge_xfce.sh
# Source this file to get color variables.
# =============================================================================

# ANSI escape constants (terminal colors)
readonly C_RESET='\033[0m'
readonly C_NEON_CYAN='\033[38;5;220m'   # Gold accent (#e0c15a)
readonly C_NEON_PINK='\033[38;5;168m'   # Muted pink (#cb7c94)
readonly C_NEON_PURPLE='\033[38;5;60m'   # Muted blue-grey (#263356)
readonly C_NEON_GREEN='\033[38;5;150m'   # Sage green (#b7cc85)
readonly C_NEON_YELLOW='\033[38;5;222m'  # Yellow (#ffe066)
readonly C_NEON_RED='\033[38;5;167m'     # Alert red/pink (#cb7c94)

# Hex palette constants — Gentleman Theme
readonly NEON_BG='#06080f'
readonly NEON_BG_ALT='#121620'
readonly NEON_FG='#f3f6f9'
readonly NEON_ACCENT='#e0c15a'
readonly NEON_ACCENT_BRIGHT='#ffe066'
readonly NEON_ALERT='#cb7c94'
readonly NEON_SELECTION='#263356'
readonly NEON_PINK='#FF006E'
readonly NEON_PURPLE='#7B2CBF'
readonly NEON_WHITE='#FFFFFF'
readonly NEON_BORDER='#00000000'

# ANSI escape constants for pink/purple accents
readonly C_ACCENT_PINK='\033[38;5;198m'   # Hot pink (#FF006E)
readonly C_ACCENT_PURPLE='\033[38;5;93m'  # Purple (#7B2CBF)

# Export so heredocs and child processes can reference them
export NEON_BG NEON_BG_ALT NEON_FG NEON_ACCENT NEON_ACCENT_BRIGHT NEON_ALERT NEON_SELECTION
export NEON_PINK NEON_PURPLE NEON_WHITE NEON_BORDER
