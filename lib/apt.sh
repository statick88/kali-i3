#!/usr/bin/env bash
# =============================================================================
# lib/apt.sh — APT helper functions with caching
# =============================================================================
# Provides pkg_installed() (cached), apt_update_once(), apt_install_if_missing()
#
# Requires: STATE and PKG_CACHE associative arrays from caller
# =============================================================================

pkg_installed() {
    local pkg="$1"
    [[ -n "${PKG_CACHE[$pkg]:-}" ]] && return "${PKG_CACHE[$pkg]}"
    dpkg -l "${pkg}" 2>/dev/null | grep -q '^ii' && PKG_CACHE["$pkg"]=0 || PKG_CACHE["$pkg"]=1
    [[ "${PKG_CACHE[$pkg]}" -eq 0 ]]
}

apt_update_once() {
    [[ "${STATE[apt_updated]:-0}" -eq 1 ]] && return 0
    run_as_root "apt-get update -qq"
    STATE[apt_updated]=1
}

apt_install_if_missing() {
    local pkgs=("$@")
    local to_install=()
    for pkg in "${pkgs[@]}"; do
        pkg_installed "${pkg}" || to_install+=("${pkg}")
    done
    [[ ${#to_install[@]} -eq 0 ]] && return 0
    apt_update_once
    run_as_root "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ${to_install[*]}"
}
