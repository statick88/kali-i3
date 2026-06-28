#!/usr/bin/env bash
# =============================================================================
# tests/test-sddm-theme.sh — SDDM Neon Minimal Theme Tests
# =============================================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

# =============================================================================
# TESTS
# =============================================================================

test_theme_directory_exists() {
    local theme_dir="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal"
    if [[ -d "${theme_dir}" ]]; then
        pass "Theme directory exists"
    else
        fail "Theme directory missing: ${theme_dir}"
    fi
}

test_theme_conf_exists() {
    local theme_conf="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/theme.conf"
    if [[ -f "${theme_conf}" ]]; then
        pass "theme.conf exists"
    else
        fail "theme.conf missing"
    fi
}

test_theme_conf_has_neon_bg() {
    local theme_conf="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/theme.conf"
    if grep -q "color=#0A0A10" "${theme_conf}" 2>/dev/null; then
        pass "theme.conf has neon background #0A0A10"
    else
        fail "theme.conf missing neon background"
    fi
}

test_metadata_desktop_exists() {
    local metadata="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/metadata.desktop"
    if [[ -f "${metadata}" ]]; then
        pass "metadata.desktop exists"
    else
        fail "metadata.desktop missing"
    fi
}

test_metadata_has_name() {
    local metadata="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/metadata.desktop"
    if grep -q "Name=Neon Minimal" "${metadata}" 2>/dev/null; then
        pass "metadata.desktop has Name=Neon Minimal"
    else
        fail "metadata.desktop missing name"
    fi
}

test_metadata_references_main_qml() {
    local metadata="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/metadata.desktop"
    if grep -q "MainScript=Main.qml" "${metadata}" 2>/dev/null; then
        pass "metadata.desktop references Main.qml"
    else
        fail "metadata.desktop missing MainScript"
    fi
}

test_main_qml_exists() {
    local main_qml="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/Main.qml"
    if [[ -f "${main_qml}" ]]; then
        pass "Main.qml exists"
    else
        fail "Main.qml missing"
    fi
}

test_main_qml_has_neon_bg() {
    local main_qml="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/Main.qml"
    if grep -q '"#0A0A10"' "${main_qml}" 2>/dev/null; then
        pass "Main.qml has neon background"
    else
        fail "Main.qml missing neon background"
    fi
}

test_main_qml_has_neon_accent() {
    local main_qml="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/Main.qml"
    if grep -q '"#008B8B"' "${main_qml}" 2>/dev/null; then
        pass "Main.qml has neon accent #008B8B"
    else
        fail "Main.qml missing neon accent"
    fi
}

test_main_qml_has_firacode() {
    local main_qml="${SCRIPT_DIR}/../dotfiles/sddm/themes/neon-minimal/Main.qml"
    if grep -q "FiraCode Nerd Font" "${main_qml}" 2>/dev/null; then
        pass "Main.qml uses FiraCode Nerd Font"
    else
        fail "Main.qml missing FiraCode font"
    fi
}

test_setup_script_deploys_theme() {
    local setup="${SCRIPT_DIR}/../setup_i3_kali.sh"
    if grep -q "neon-minimal" "${setup}" 2>/dev/null; then
        pass "setup_i3_kali.sh deploys neon-minimal theme"
    else
        fail "setup_i3_kali.sh missing neon-minimal deployment"
    fi
}

test_setup_script_configures_neon_theme() {
    local setup="${SCRIPT_DIR}/../setup_i3_kali.sh"
    if grep -q "Current=neon-minimal" "${setup}" 2>/dev/null; then
        pass "setup_i3_kali.sh configures Current=neon-minimal"
    else
        fail "setup_i3_kali.sh missing Current=neon-minimal config"
    fi
}

test_no_breeze_reference_in_config() {
    local setup="${SCRIPT_DIR}/../setup_i3_kali.sh"
    if grep -q "Current=breeze" "${setup}" 2>/dev/null; then
        fail "setup_i3_kali.sh still references breeze theme"
    else
        pass "No breeze theme reference in config"
    fi
}

# =============================================================================
# RUN ALL TESTS
# =============================================================================

run_all_tests() {
    local total=0
    local passed=0
    local failed=0

    local tests=(
        test_theme_directory_exists
        test_theme_conf_exists
        test_theme_conf_has_neon_bg
        test_metadata_desktop_exists
        test_metadata_has_name
        test_metadata_references_main_qml
        test_main_qml_exists
        test_main_qml_has_neon_bg
        test_main_qml_has_neon_accent
        test_main_qml_has_firacode
        test_setup_script_deploys_theme
        test_setup_script_configures_neon_theme
        test_no_breeze_reference_in_config
    )

    for test in "${tests[@]}"; do
        total=$((total + 1))
        if ${test}; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "SDDM Theme Tests: ${passed}/${total} passed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    [[ ${failed} -eq 0 ]]
}

run_all_tests
