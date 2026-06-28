#!/usr/bin/env bash
# =============================================================================
# lib/colors.sh — NEON MINIMAL color constants
# =============================================================================
# Extracted from setup_i3_kali.sh and purge_xfce.sh
# Source this file to get color variables.
# =============================================================================

# ANSI escape constants (terminal colors)
readonly C_RESET='\033[0m'
readonly C_NEON_CYAN='\033[38;5;45m'
readonly C_NEON_PINK='\033[38;5;168m'
readonly C_NEON_PURPLE='\033[38;5;97m'
readonly C_NEON_GREEN='\033[38;5;40m'
readonly C_NEON_YELLOW='\033[38;5;220m'
readonly C_NEON_RED='\033[38;5;160m'

# Hex palette constants — Azul Neón Atenuado theme
readonly NEON_BG='#0A0A10'
readonly NEON_BG_ALT='#1E1E2F'
readonly NEON_FG='#E0E0E0'
readonly NEON_ACCENT='#008B8B'
readonly NEON_ACCENT_BRIGHT='#00A3A6'
readonly NEON_ALERT='#C71585'
readonly NEON_SELECTION='#1E1E2F'

# Export so heredocs and child processes can reference them
export NEON_BG NEON_BG_ALT NEON_FG NEON_ACCENT NEON_ACCENT_BRIGHT NEON_ALERT NEON_SELECTION
