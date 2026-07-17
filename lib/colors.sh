#!/usr/bin/env bash
# shellcheck disable=SC2034  # Sourced cross-file — vars used by common.sh, setup, purge
# =============================================================================
# lib/colors.sh — NEON MINIMAL Theme color constants
# =============================================================================
# Paleta NEON MINIMAL (Azul Neón Atenuado — discreto, profesional)
#   Background:      #0A0A10  (negro azulado profundo)
#   Background Alt:  #1E1E2F  (superficie elevada)
#   Foreground:      #E0E0E0  (blanco suave)
#   Accent:          #008B8B  (teal — color principal, discreto)
#   Accent Bright:   #00A3A6  (teal brillante — focus/hover)
#   Accent Dim:      #006B6B  (teal oscuro — bordes sutiles)
#   Accent Cyan:     #00BCD4  (cian complementario — acentos secundarios)
#   Alert:           #C71585  (magenta apagado — solo para urgente/error crítico)
#   Muted:           #4A5568  (gris azulado — texto secundario, bordes)
#   Selection:       #1E1E2F  (igual que bg-alt)
# =============================================================================

# ANSI escape constants (terminal 256-color approximations)
readonly C_RESET='\033[0m'
readonly C_NEON_TEAL='\033[38;5;30m'        # Accent teal (#008B8B)
readonly C_NEON_TEAL_BRIGHT='\033[38;5;45m' # Bright teal (#00A3A6)
readonly C_NEON_TEAL_DIM='\033[38;5;23m'    # Dim teal (#006B6B)
readonly C_NEON_CYAN='\033[38;5;37m'        # Cyan complementario (#00BCD4)
readonly C_NEON_FG='\033[38;5;252m'         # Foreground (#E0E0E0)
readonly C_NEON_GREEN='\033[38;5;150m'      # Sage green (success/ok)
readonly C_NEON_YELLOW='\033[38;5;222m'     # Amber (warn)
readonly C_NEON_RED='\033[38;5;197m'        # Muted red (error/critical)
readonly C_NEON_MUTED='\033[38;5;241m'      # Muted gray-blue (secondary text)

# Hex palette constants — NEON MINIMAL Theme
readonly NEON_BG='#0A0A10'
readonly NEON_BG_ALT='#1E1E2F'
readonly NEON_FG='#E0E0E0'
readonly NEON_ACCENT='#008B8B'
readonly NEON_ACCENT_BRIGHT='#00A3A6'
readonly NEON_ACCENT_DIM='#006B6B'
readonly NEON_CYAN='#00BCD4'
readonly NEON_ALERT='#C71585'
readonly NEON_MUTED='#4A5568'
readonly NEON_SELECTION='#1E1E2F'

# Legacy aliases (used in i3 config template — will be updated)
readonly NEON_PINK='#008B8B'   # was #FF006E — now maps to accent teal
readonly NEON_PURPLE='#006B6B' # was #7B2CBF — now maps to dim teal
readonly NEON_WHITE='#FFFFFF'
readonly NEON_BORDER='#00000000'

# Export so heredocs and child processes can reference them
export NEON_BG NEON_BG_ALT NEON_FG NEON_ACCENT NEON_ACCENT_BRIGHT NEON_ACCENT_DIM NEON_CYAN NEON_ALERT NEON_MUTED NEON_SELECTION
export NEON_PINK NEON_PURPLE NEON_WHITE NEON_BORDER
