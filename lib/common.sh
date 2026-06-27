#!/usr/bin/env bash
# =============================================================================
# lib/common.sh — Logging and UI helpers
# =============================================================================
# Sources colors.sh and provides log(), info(), ok(), warn(), err(), die(),
# step(), header() functions.
# =============================================================================

SCRIPT_DIR_COMMON="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR_COMMON}/colors.sh"

# Default LOG_FILE if not set by caller
: "${LOG_FILE:=/tmp/kali-i3-common.log}"

log() {
    local level="$1"; shift
    local msg="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local color=""
    case "${level}" in
        INFO)  color="${C_NEON_CYAN}" ;;
        OK)    color="${C_NEON_GREEN}" ;;
        WARN)  color="${C_NEON_PURPLE}" ;;
        ERROR) color="${C_NEON_RED}" ;;
        STEP)  color="${C_NEON_PINK}" ;;
        *)     color="${C_RESET}" ;;
    esac
    printf "${color}[%s] [%s] %s${C_RESET}\n" "${timestamp}" "${level}" "${msg}"
    printf "[%s] [%s] %s\n" "${timestamp}" "${level}" "${msg}" >> "${LOG_FILE}" 2>/dev/null || true
}

info()  { log "INFO"  "$@"; }
ok()    { log "OK"    "$@"; }
warn()  { log "WARN"  "$@"; }
err()   { log "ERROR" "$@"; }
step()  { log "STEP"  "$@"; }

die() { err "$@"; exit 1; }

header() {
    printf "\n${C_NEON_PINK}══════════════════════════════════════════════════════════════════════════════${C_RESET}\n"
    printf "${C_NEON_PINK}   %s${C_RESET}\n" "$1"
    printf "${C_NEON_PINK}══════════════════════════════════════════════════════════════════════════════${C_RESET}\n\n"
}
