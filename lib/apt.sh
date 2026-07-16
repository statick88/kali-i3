#!/usr/bin/env bash
# =============================================================================
# lib/apt.sh — APT helper functions with caching and resilience
# =============================================================================
# Provides pkg_installed() (cached), apt_update_once(), apt_install_with_retry(),
# apt_install_if_missing()
#
# Requires: STATE and PKG_CACHE associative arrays from caller
# =============================================================================

readonly APT_INSTALL_TIMEOUT="${APT_INSTALL_TIMEOUT:-120}"
readonly APT_INSTALL_RETRIES="${APT_INSTALL_RETRIES:-3}"

HAS_TIMEOUT=0
command -v timeout >/dev/null 2>&1 && HAS_TIMEOUT=1

# _pkg_cache_find — return index of pkg in PKG_CACHE_KEYS, or -1
_pkg_cache_find() {
    local i
    for i in "${!PKG_CACHE_KEYS[@]}"; do
        [[ "${PKG_CACHE_KEYS[$i]}" == "$1" ]] && echo "$i" && return 0
    done
    echo -1
}

# _pkg_cache_set — add or update a pkg in the cache
_pkg_cache_set() {
    local pkg="$1" val="$2" idx
    idx=$(_pkg_cache_find "${pkg}")
    if [[ "$idx" -ge 0 ]]; then
        PKG_CACHE_VALS[$idx]="$val"
    else
        PKG_CACHE_KEYS+=("$pkg")
        PKG_CACHE_VALS+=("$val")
    fi
}

pkg_installed() {
    local pkg="$1" idx
    idx=$(_pkg_cache_find "${pkg}")
    if [[ "$idx" -ge 0 ]]; then
        return "${PKG_CACHE_VALS[$idx]}"
    fi
    if dpkg -l "${pkg}" 2>/dev/null | grep -q '^ii'; then
        _pkg_cache_set "${pkg}" 0
    else
        _pkg_cache_set "${pkg}" 1
    fi
    idx=$(_pkg_cache_find "${pkg}")
    [[ "${PKG_CACHE_VALS[$idx]}" -eq 0 ]]
}

# STATE tracking — indexed array with keys STATE_KEYS / STATE_VALS
# Callers declare: STATE_KEYS=(); STATE_VALS=()
_state_find() {
    local key="$1" i
    for i in "${!STATE_KEYS[@]}"; do
        [[ "${STATE_KEYS[$i]}" == "$key" ]] && echo "$i" && return 0
    done
    echo -1
}

_state_get() {
    local idx; idx=$(_state_find "$1")
    [[ "$idx" -ge 0 ]] && echo "${STATE_VALS[$idx]}" || echo ""
}

_state_set() {
    local key="$1" val="$2" idx
    idx=$(_state_find "${key}")
    if [[ "$idx" -ge 0 ]]; then
        STATE_VALS[$idx]="$val"
    else
        STATE_KEYS+=("$key")
        STATE_VALS+=("$val")
    fi
}

apt_update_once() {
    [[ "$(_state_get apt_updated)" -eq 1 ]] && return 0
    run_as_root "apt-get update -qq"
    _state_set apt_updated 1
}

apt_install_with_retry() {
    local pkg="$1"
    local attempt=1
    local delay=2

    # Skip if already installed
    if pkg_installed "${pkg}"; then
        echo -e "  \033[0;36mok/installed\033[0m ${pkg} (already installed)"
        return 0
    fi

    while [[ ${attempt} -le ${APT_INSTALL_RETRIES} ]]; do
        local rc=0
        local install_cmd="DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ${pkg}"
        if [[ ${HAS_TIMEOUT} -eq 1 ]]; then
            run_as_root "timeout ${APT_INSTALL_TIMEOUT}s bash -c '${install_cmd}'" || rc=$?
        else
            run_as_root "bash -c '${install_cmd}'" || rc=$?
        fi

        if [[ ${rc} -eq 0 ]]; then
            echo -e "  \033[0;32mok/installed\033[0m ${pkg}"
            return 0
        fi

        if [[ ${attempt} -lt ${APT_INSTALL_RETRIES} ]]; then
            echo -e "  \033[0;33mwarn/retrying\033[0m ${pkg} (attempt ${attempt}/${APT_INSTALL_RETRIES}, retrying in ${delay}s)"
            sleep "${delay}"
            delay=$((delay * 2))
        fi

        ((attempt++))
    done

    echo -e "  \033[0;31merr/failed\033[0m ${pkg} after ${APT_INSTALL_RETRIES} attempts"
    return 1
}

apt_install_if_missing() {
    local pkgs=("$@")
    local to_install=()
    local failed_pkgs=()
    local installed=0

    # Check which packages need installation
    for pkg in "${pkgs[@]}"; do
        pkg_installed "${pkg}" || to_install+=("${pkg}")
    done

    # All already installed
    [[ ${#to_install[@]} -eq 0 ]] && return 0

    apt_update_once

    # Install each package individually with retry
    for pkg in "${to_install[@]}"; do
        if apt_install_with_retry "${pkg}"; then
            installed=$((installed + 1))
        else
            failed_pkgs+=("${pkg}")
        fi
    done

    local already_present=$(( ${#pkgs[@]} - ${#to_install[@]} ))
    local failed=${#failed_pkgs[@]}

    echo -e "\033[0;36mSummary:\033[0m ${installed} installed, ${failed} failed, ${already_present} already present"

    [[ ${failed} -eq 0 ]] && return 0 || return 1
}
