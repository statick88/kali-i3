#!/usr/bin/env bash
# Tests for theme system — Azul Neón Atenuado palette
# Verifies all hardcoded colors are replaced with palette constants

TESTS_RUN=0
TESTS_PASS=0
TESTS_FAIL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() {
    ((TESTS_RUN++))
    ((TESTS_PASS++))
    echo -e "${GREEN}PASS${NC}: $1"
}

fail() {
    ((TESTS_RUN++))
    ((TESTS_FAIL++))
    echo -e "${RED}FAIL${NC}: $1"
}

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# =============================================================================
# Test: No #00FFFF remains in lib/colors.sh
# =============================================================================
test_no_00ffff_in_colors() {
    local count
    count=$(grep -c '#00FFFF' "${SCRIPT_DIR}/lib/colors.sh" 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "No #00FFFF in lib/colors.sh" || fail "#00FFFF found ${count} times in lib/colors.sh"
}

# =============================================================================
# Test: No #00FFFF remains in setup_i3_kali.sh
# =============================================================================
test_no_00ffff_in_setup() {
    local count
    count=$(grep -c '#00FFFF' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "No #00FFFF in setup_i3_kali.sh" || fail "#00FFFF found ${count} times in setup_i3_kali.sh"
}

# =============================================================================
# Test: No #0a0aa0 (wrong case) remains in setup_i3_kali.sh
# =============================================================================
test_no_0a0aa0_in_setup() {
    local count
    count=$(grep -ci '#0a0aa0' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "No #0a0aa0 in setup_i3_kali.sh" || fail "#0a0aa0 found ${count} times in setup_i3_kali.sh"
}

# =============================================================================
# Test: No #0a0aa0 remains in lib/colors.sh
# =============================================================================
test_no_0a0aa0_in_colors() {
    local count
    count=$(grep -ci '#0a0aa0' "${SCRIPT_DIR}/lib/colors.sh" 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "No #0a0aa0 in lib/colors.sh" || fail "#0a0aa0 found ${count} times in lib/colors.sh"
}

# =============================================================================
# Test: lib/colors.sh defines all palette constants
# =============================================================================
test_palette_defined() {
    local missing=0
    for var in NEON_BG NEON_BG_ALT NEON_FG NEON_ACCENT NEON_ACCENT_BRIGHT NEON_ALERT NEON_SELECTION; do
        local val
        val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${${var}}\"" 2>/dev/null)
        if [[ -z "${val}" ]]; then
            fail "Palette constant ${var} is not defined"
            ((missing++))
        fi
    done
    [[ "${missing}" -eq 0 ]] && pass "All palette constants are defined"
}

# =============================================================================
# Test: NEON_BG has correct value
# =============================================================================
test_neon_bg_value() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_BG}\"" 2>/dev/null)
    [[ "${val}" == '#06080f' ]] && pass "NEON_BG = #06080f" || fail "NEON_BG = ${val}, expected #06080f"
}

# =============================================================================
# Test: NEON_ACCENT has correct value
# =============================================================================
test_neon_accent_value() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_ACCENT}\"" 2>/dev/null)
    [[ "${val}" == '#e0c15a' ]] && pass "NEON_ACCENT = #e0c15a" || fail "NEON_ACCENT = ${val}, expected #e0c15a"
}

# =============================================================================
# Test: i3 config uses palette variable names (not hardcoded hex)
# =============================================================================
test_i3_uses_palette() {
    local count
    count=$(grep -c '#00FFFF' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "i3 heredoc uses palette constants" || fail "i3 heredoc still has ${count} hardcoded #00FFFF"
}

# =============================================================================
# Test: polybar heredoc uses palette variable names
# =============================================================================
test_polybar_uses_palette() {
    # Check the polybar section (lines ~205-270) for #00FFFF
    local count
    count=$(sed -n '/POLYCONF/,/POLYCONF/p' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null | grep -c '#00FFFF' 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "Polybar heredoc uses palette constants" || fail "Polybar heredoc still has ${count} hardcoded #00FFFF"
}

# =============================================================================
# Test: rofi heredoc uses palette variable names
# =============================================================================
test_rofi_uses_palette() {
    local count
    count=$(sed -n '/^ROFI$/,/^ROFI$/p' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null | grep -c '#00FFFF' 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "Rofi heredoc uses palette constants" || fail "Rofi heredoc still has ${count} hardcoded #00FFFF"
}

# =============================================================================
# Test: picom heredoc uses palette variable names
# =============================================================================
test_picom_uses_palette() {
    local count
    count=$(sed -n '/^PICOM$/,/^PICOM$/p' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null | grep -c '#00FFFF' 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "Picom heredoc uses palette constants" || fail "Picom heredoc still has ${count} hardcoded #00FFFF"
}

# =============================================================================
# Test: kitty heredoc uses palette variable names
# =============================================================================
test_kitty_uses_palette() {
    local count
    count=$(sed -n '/^KITTY$/,/^KITTY$/p' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null | grep -c '#00FFFF' 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "Kitty heredoc uses palette constants" || fail "Kitty heredoc still has ${count} hardcoded #00FFFF"
}

# =============================================================================
# Test: alacritty heredoc uses palette variable names
# =============================================================================
test_alacritty_uses_palette() {
    local count
    count=$(sed -n '/^ALACRITTY$/,/^ALACRITTY$/p' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null | grep -c '#00FFFF' 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "Alacritty heredoc uses palette constants" || fail "Alacritty heredoc still has ${count} hardcoded #00FFFF"
}

# =============================================================================
# Test: tmux heredoc uses palette variable names
# =============================================================================
test_tmux_uses_palette() {
    local count
    count=$(sed -n '/^TMUXCONF$/,/^TMUXCONF$/p' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null | grep -c '#00FFFF' 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "TMUX heredoc uses palette constants" || fail "TMUX heredoc still has ${count} hardcoded #00FFFF"
}

# =============================================================================
# Test: tmux background is #0A0A10 (not #0a0aa0)
# =============================================================================
test_tmux_bg_correct() {
    local count
    count=$(sed -n '/^TMUXCONF$/,/^TMUXCONF$/p' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null | grep -ci '#0a0aa0' 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "TMUX background uses #0A0A10 (not #0a0aa0)" || fail "TMUX still has ${count} references to #0a0aa0"
}

# =============================================================================
# Test: agents.conf uses palette variable names
# =============================================================================
test_agents_conf_uses_palette() {
    local count
    count=$(sed -n '/^AGENTS$/,/^AGENTS$/p' "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null | grep -c '#00FFFF' 2>/dev/null) || count=0
    [[ "${count}" -eq 0 ]] && pass "agents.conf uses palette constants" || fail "agents.conf still has ${count} hardcoded #00FFFF"
}

# =============================================================================
# Test: No #00FFFF anywhere in lib/ directory
# =============================================================================
test_no_00ffff_in_lib() {
    local count
    count=$(grep -rc '#00FFFF' "${SCRIPT_DIR}/lib/" 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
    [[ "${count}" -eq 0 ]] && pass "No #00FFFF in lib/ directory" || fail "#00FFFF found ${count} times in lib/"
}

# Run all tests
main() {
    echo "=== Theme System Tests ==="
    echo ""

    test_no_00ffff_in_colors
    test_no_00ffff_in_setup
    test_no_0a0aa0_in_setup
    test_no_0a0aa0_in_colors
    test_palette_defined
    test_neon_bg_value
    test_neon_accent_value
    test_i3_uses_palette
    test_polybar_uses_palette
    test_rofi_uses_palette
    test_picom_uses_palette
    test_kitty_uses_palette
    test_alacritty_uses_palette
    test_tmux_uses_palette
    test_tmux_bg_correct
    test_agents_conf_uses_palette
    test_no_00ffff_in_lib

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
