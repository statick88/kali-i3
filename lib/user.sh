#!/usr/bin/env bash
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
    sudo -u "${TARGET_USER}" -H bash -c "$*"
}

run_as_root() {
    [[ "$(id -u)" -eq 0 ]] && bash -c "$*" || sudo bash -c "$*"
}
