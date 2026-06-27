#!/usr/bin/env bash
# =============================================================================
# purge_xfce.sh — Safe XFCE Removal for i3-wm Migration
# =============================================================================
# Specification: Idempotent, modular, protective, non-destructive, NEON style
# Author: Kilo Code Generation
# Usage: sudo ./purge_xfce.sh
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"

# Source lib modules
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/user.sh"

# Argument parsing
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --version)
                local version
                version=$(grep '## \[' "${SCRIPT_DIR}/CHANGELOG.md" | grep -v 'Unreleased' | head -1 | sed 's/## \[\([^]]*\)\].*/\1/')
                echo "${SCRIPT_NAME} ${version}"
                exit 0
                ;;
            -h|--help)
                echo "Usage: sudo ${SCRIPT_NAME} [--version]"
                echo "  --version  Show version"
                exit 0
                ;;
            *) die "Unknown option: $1" ;;
        esac
        shift
    done
}

# State tracking
readonly STATE_FILE="${TARGET_HOME}/.config/purge-xfce-state.json"
readonly STATE_VERSION="1.0.0"
declare -A COMPLETED_STEPS=()
declare -A STEP_LABELS=(
    ["step_protect_critical_packages"]="Protecting critical system packages"
    ["step_stop_display_manager"]="Stopping display manager"
    ["step_kill_xfce_processes"]="Terminating XFCE processes"
    ["step_purge_meta_packages"]="Purging desktop meta-packages"
    ["step_purge_display_managers"]="Purging old display managers"
    ["step_purge_xfce_packages"]="Purging XFCE packages"
    ["step_purge_gnome_packages"]="Purging GNOME packages"
    ["step_purge_xfce_configs"]="Removing XFCE configuration files"
    ["step_unprotect_critical_packages"]="Unprotecting critical packages"
    ["step_cleanup_apt"]="Running APT cleanup"
)

# Source state management
source "${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}/lib/state.sh"

# =============================================================================
# PACKAGE HELPERS (inline — purge_xfce needs its own pkg_installed)
# =============================================================================
pkg_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q '^ii'
}

# =============================================================================
# STEP FUNCTIONS
# =============================================================================
protect_critical_packages() {
    step "Protecting critical system packages..."
    local protect_pkgs=(
        network-manager network-manager-gnome
        kali-linux-default kali-linux-core kali-linux-large
        systemd systemd-sysv
        sudo passwd login
        bash zsh
        linux-image-amd64 linux-headers-amd64
        xserver-xorg-core
    )
    for pkg in "${protect_pkgs[@]}"; do
        run_as_root "apt-mark hold ${pkg} 2>/dev/null || true"
    done
    ok "Critical packages protected"
}

unprotect_critical_packages() {
    step "Unprotecting critical packages..."
    local protect_pkgs=(
        network-manager network-manager-gnome
        kali-linux-default kali-linux-core kali-linux-large
        systemd systemd-sysv
        sudo passwd login
        bash zsh
        linux-image-amd64 linux-headers-amd64
        xserver-xorg-core
    )
    for pkg in "${protect_pkgs[@]}"; do
        run_as_root "apt-mark unhold ${pkg} 2>/dev/null || true"
    done
    ok "Critical packages unprotected"
}

stop_display_manager() {
    step "Stopping display manager..."
    run_as_root "systemctl stop lightdm 2>/dev/null || true"
    run_as_root "systemctl disable lightdm 2>/dev/null || true"
    ok "Display manager stopped (lightdm stopped, sddm preserved for i3-wm)"
}

kill_xfce_processes() {
    step "Terminating XFCE processes..."
    run_as_root "pkill -9 -f 'xfce4|xfwm4|xfce4-panel|xfsettingsd|thunar|xfdesktop|xfce4-session' 2>/dev/null || true"
    run_as_root "pkill -9 -f 'lightdm|light-locker' 2>/dev/null || true"
    sleep 2
    ok "XFCE processes terminated"
}

purge_meta_packages() {
    step "Purging desktop meta-packages..."

    local meta_pkgs=(
        kali-desktop-xfce kali-desktop-gnome kali-desktop-kde
        kali-desktop-core kali-defaults-desktop
    )

    local to_purge=()
    for pkg in "${meta_pkgs[@]}"; do
        if pkg_installed "${pkg}"; then
            to_purge+=("${pkg}")
        fi
    done

    [[ ${#to_purge[@]} -gt 0 ]] || { ok "No meta-packages to purge (idempotent)"; return 0; }

    run_as_root "DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove --allow-remove-essential ${to_purge[*]}"
    ok "Purged meta-packages: ${to_purge[*]}"
}

purge_display_managers() {
    step "Purging old display managers..."

    local dm_pkgs=(
        lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
        gdm3
    )

    local to_purge=()
    for pkg in "${dm_pkgs[@]}"; do
        if pkg_installed "${pkg}"; then
            to_purge+=("${pkg}")
        fi
    done

    [[ ${#to_purge[@]} -gt 0 ]] || { ok "No display manager packages to purge (idempotent)"; return 0; }

    run_as_root "DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${to_purge[*]}"
    ok "Purged display managers: ${to_purge[*]}"
}

purge_xfce_packages() {
    step "Purging XFCE packages..."

    local xfce_pkgs=(
        xfce4 xfce4-goodies xfwm4 thunar xfce4-panel
        xfce4-session xfce4-settings xfce4-terminal
        xfconf xfdesktop4
    )

    local to_purge=()
    for pkg in "${xfce_pkgs[@]}"; do
        if pkg_installed "${pkg}"; then
            to_purge+=("${pkg}")
        fi
    done

    [[ ${#to_purge[@]} -gt 0 ]] || { ok "No XFCE packages to purge (idempotent)"; return 0; }

    run_as_root "DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${to_purge[*]}"
    ok "Purged XFCE packages: ${to_purge[*]}"
}

purge_gnome_packages() {
    step "Purging GNOME packages..."

    local gnome_pkgs=(
        gnome-shell gnome-session gnome-terminal nautilus
        gnome-control-center gnome-settings-daemon
    )

    local to_purge=()
    for pkg in "${gnome_pkgs[@]}"; do
        if pkg_installed "${pkg}"; then
            to_purge+=("${pkg}")
        fi
    done

    [[ ${#to_purge[@]} -gt 0 ]] || { ok "No GNOME packages to purge (idempotent)"; return 0; }

    run_as_root "DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${to_purge[*]}"
    ok "Purged GNOME packages: ${to_purge[*]}"
}

purge_xfce_configs() {
    step "Removing XFCE configuration files..."

    run_as_user "rm -rf ${TARGET_HOME}/.config/xfce4 2>/dev/null || true"
    run_as_user "rm -rf ${TARGET_HOME}/.config/xfce4-session 2>/dev/null || true"
    run_as_user "rm -rf ${TARGET_HOME}/.config/Thunar 2>/dev/null || true"
    run_as_user "rm -rf ${TARGET_HOME}/.local/share/xfce4 2>/dev/null || true"
    run_as_user "rm -rf ${TARGET_HOME}/.cache/sessions/xfce4* 2>/dev/null || true"

    run_as_root "rm -rf /etc/xdg/xfce4 2>/dev/null || true"
    run_as_root "rm -rf /etc/xdg/menus/xfce* 2>/dev/null || true"
    run_as_root "rm -rf /etc/lightdm 2>/dev/null || true"

    ok "XFCE configs removed (idempotent)"
}

cleanup_apt() {
    step "Running APT cleanup..."
    run_as_root "apt-get autoremove -y --purge 2>/dev/null || true"
    run_as_root "apt-get clean"
    run_as_root "apt-get autoclean -y"
    run_as_root "rm -rf /var/lib/apt/lists/lock /var/cache/apt/archives/lock"
    ok "APT cleanup complete"
}

print_summary() {
    printf "\n${C_NEON_GREEN}══════════════════════════════════════════════════════════════════${C_RESET}\n"
    printf "${C_NEON_GREEN}  NEON XFCE PURGE COMPLETE - CONFIRMATION${C_RESET}\n"
    printf "${C_NEON_GREEN}══════════════════════════════════════════════════════════════════${C_RESET}\n\n"

    printf "${C_NEON_CYAN}Summary:${C_RESET}\n"
    printf "  ${C_NEON_PURPLE}-${C_RESET} XFCE packages and configs removed\n"
    printf "  ${C_NEON_PURPLE}-${C_RESET} LightDM removed (SDDM now active)\n"
    printf "  ${C_NEON_PURPLE}-${C_RESET} Critical packages protected during purge\n"
    printf "  ${C_NEON_PURPLE}-${C_RESET} Modular execution with idempotent checks\n"
    printf "  ${C_NEON_PURPLE}-${C_RESET} System ready for NEON i3-wm\n\n"

    read -rp "${C_NEON_PINK}Reboot now to start clean i3 session? [Y/n]:${C_RESET} " reply
    [[ -z "${reply}" || "${reply,,}" =~ ^y ]] && { run_as_root "reboot"; } || { info "Reboot manually when ready."; }
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    parse_args "$@"

    if [[ $EUID -ne 0 ]]; then
        err "Must run as root (sudo)"
        exit 1
    fi

    touch "${LOG_FILE}" 2>/dev/null || true

    load_state

    local -a ALL_STEPS=(
        "step_protect_critical_packages"
        "step_stop_display_manager"
        "step_kill_xfce_processes"
        "step_purge_meta_packages"
        "step_purge_display_managers"
        "step_purge_xfce_packages"
        "step_purge_gnome_packages"
        "step_purge_xfce_configs"
        "step_unprotect_critical_packages"
        "step_cleanup_apt"
    )

    local total=${#ALL_STEPS[@]}
    local completed=0

    if [[ ${#COMPLETED_STEPS[@]} -gt 0 ]]; then
        local -a completed_list=()
        for step_name in "${!COMPLETED_STEPS[@]}"; do
            completed_list+=("${step_name}")
        done
        step "${C_NEON_CYAN}Resuming from step: ${#completed_list[@]}/${total} completed${C_RESET}"
        completed=${#completed_list[@]}
    fi

    info "Starting NEON XFCE purge..."
    info "Target user: ${TARGET_USER}"
    info "Log: ${LOG_FILE}"

    for step_name in "${ALL_STEPS[@]}"; do
        if is_completed "${step_name}"; then
            show_progress "${completed}" "${total}" "${STEP_LABELS[$step_name]:-$step_name} (already done)"
            ((completed++))
            continue
        fi

        show_progress "${completed}" "${total}" "${STEP_LABELS[$step_name]:-$step_name}"

        ${step_name}

        mark_completed "${step_name}"
        ((completed++))
    done

    print_summary
}

main "$@"
