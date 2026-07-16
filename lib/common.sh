#!/usr/bin/env bash
# =============================================================================
# lib/common.sh — Logging and UI helpers
# =============================================================================
# Sources colors.sh and provides log(), info(), ok(), warn(), err(), die(),
# step(), header() functions.
# =============================================================================

SCRIPT_DIR_COMMON="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR_COMMON}/colors.sh"
source "${SCRIPT_DIR_COMMON}/i18n.sh"

# Default LOG_FILE if not set by caller
: "${LOG_FILE:=/tmp/kali-i3-common.log}"

log() {
    local level="$1"; shift
    local msg="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local color=""
    case "${level}" in
        INFO)  color="${C_NEON_TEAL}" ;;
        OK)    color="${C_NEON_GREEN}" ;;
        WARN)  color="${C_NEON_YELLOW}" ;;
        ERROR) color="${C_NEON_RED}" ;;
        STEP)  color="${C_NEON_TEAL_BRIGHT}" ;;
        *)     color="${C_RESET}" ;;
    esac
    printf "${color}[%s] [%s] %s${C_RESET}\n" "${timestamp}" "${level}" "${msg}" >&2
    printf "[%s] [%s] %s\n" "${timestamp}" "${level}" "${msg}" >> "${LOG_FILE}" 2>/dev/null || true
}

# --- Logging wrappers with i18n support ---
# Each function translates its message via msg() before logging.

info()  { log "INFO"  "$(msg "$1")"; }
ok()    { log "OK"    "$(msg "$1")"; }
warn()  { log "WARN"  "$(msg "$1")"; }
err()   { log "ERROR" "$(msg "$1")"; }
step()  { log "STEP"  "$(msg "$1")"; }

die() { err "$@"; exit 1; }

header() {
    local title
    title="$(msg "$1")"
    printf "\n${C_NEON_TEAL}══════════════════════════════════════════════════════════════════════════════${C_RESET}\n"
    printf "${C_NEON_TEAL}   %s${C_RESET}\n" "${title}"
    printf "${C_NEON_TEAL}══════════════════════════════════════════════════════════════════════════════${C_RESET}\n\n"
}