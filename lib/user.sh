#!/usr/bin/env bash
# shellcheck disable=SC2034  # Variables sourced and used externally by setup/purge
# shellcheck disable=SC2155  # readonly var=$(cmd) is intentional: atomic readonly assignment
# =============================================================================
# lib/user.sh — User detection and execution helpers
# =============================================================================
# Provides TARGET_USER, TARGET_HOME, TARGET_UID, TARGET_GID,
# run_as_root(), run_as_user(), cmd_exists()
# =============================================================================

readonly TARGET_USER="${SUDO_USER:-${USER}}"
readonly TARGET_HOME="$(eval echo "~${TARGET_USER}")"
readonly TARGET_UID="$(id -u "${TARGET_USER}")"
readonly TARGET_GID="$(id -g "${TARGET_USER}")"

cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

run_as_user() {
    # Takes a single command string and executes it as the target user
    # Callers MUST properly quote variables and arguments within the string
    sudo -u "${TARGET_USER}" -H bash -c "$1"
}

run_as_root() {
    # Takes a single command string and executes it as root
    # Callers MUST properly quote variables and arguments within the string
    [[ "$(id -u)" -eq 0 ]] && bash -c "$1" || sudo bash -c "$1"
}
