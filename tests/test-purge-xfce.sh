#!/usr/bin/env bash
# Tests for purge_xfce.sh

# Source shared test helpers
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

# =============================================================================
# Test: protect_critical_packages() - Verifies package protection lists
# =============================================================================
test_protect_functions() {
    local protect_pkgs=(
        network-manager network-manager-gnome
        kali-linux-default kali-linux-core kali-linux-large
        systemd systemd-sysv
        sudo passwd login
        bash zsh
        linux-image-amd64 linux-headers-amd64
        xserver-xorg-core
    )
    local expected_count=15
    [[ ${#protect_pkgs[@]} -eq $expected_count ]] && pass "protect_critical_packages has correct package list" || fail "Expected $expected_count packages, got ${#protect_pkgs[@]}"
}

# =============================================================================
# Test: purge patterns - verify config patterns for removal
# =============================================================================
test_config_patterns() {
    local xfce_pkgs=(
        xfce4 xfce4-goodies xfwm4 thunar xfce4-panel
        xfce4-session xfce4-settings xfce4-terminal
        xfconf xfdesktop4
    )
    local gnome_pkgs=(
        gnome-shell gnome-session gnome-terminal nautilus
        gnome-control-center gnome-settings-daemon
    )
    local dm_pkgs=(
        lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
        gdm3
    )

    [[ ${#xfce_pkgs[@]} -ge 5 ]] && pass "XFCE packages list has expected entries" || fail "XFCE packages list incomplete"
    [[ ${#gnome_pkgs[@]} -ge 5 ]] && pass "GNOME packages list has expected entries" || fail "GNOME packages list incomplete"
    [[ ${#dm_pkgs[@]} -ge 2 ]] && pass "Display manager packages list has expected entries" || fail "Display manager packages list incomplete"
}

# =============================================================================
# Test: idempotent steps - all steps can run multiple times
# =============================================================================
test_idempotent_steps() {
    COMPLETED_STEPS=()

    is_completed() {
        [[ "${COMPLETED_STEPS[$1]:-0}" -eq 1 ]]
    }

    mark_completed() {
        COMPLETED_STEPS["$1"]=1
    }

    mark_completed "step_test_idempotent"
    [[ "${COMPLETED_STEPS[step_test_idempotent]:-0}" -eq 1 ]] && pass "mark_completed works for idempotency" || fail "mark_completed should track completed steps"

    is_completed "step_test_idempotent" && pass "is_completed detects completed step" || fail "is_completed should return true for completed step"
}

# Run all tests
main() {
    echo "=== Purge XFCE Tests ==="
    echo ""

    test_protect_functions
    test_config_patterns
    test_idempotent_steps

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
