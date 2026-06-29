#!/usr/bin/env bash
# Tests for lib/colors.sh — color constant definitions

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
# Test: colors.sh can be sourced without errors
# =============================================================================
test_colors_source() {
    bash -c "source '${SCRIPT_DIR}/lib/colors.sh'" 2>/dev/null \
        && pass "colors.sh sources without error" \
        || fail "colors.sh failed to source"
}

# =============================================================================
# Test: C_RESET is defined (literal \033[0m string for printf interpretation)
# =============================================================================
test_c_reset() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_RESET}\"" 2>/dev/null)
    [[ "${val}" == '\033[0m' ]] && pass "C_RESET is defined correctly" || fail "C_RESET has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_CYAN is defined
# =============================================================================
test_c_neon_cyan() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_CYAN}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;220m' ]] && pass "C_NEON_CYAN is defined correctly" || fail "C_NEON_CYAN has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_PINK is defined
# =============================================================================
test_c_neon_pink() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_PINK}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;168m' ]] && pass "C_NEON_PINK is defined correctly" || fail "C_NEON_PINK has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_PURPLE is defined
# =============================================================================
test_c_neon_purple() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_PURPLE}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;60m' ]] && pass "C_NEON_PURPLE is defined correctly" || fail "C_NEON_PURPLE has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_GREEN is defined
# =============================================================================
test_c_neon_green() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_GREEN}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;150m' ]] && pass "C_NEON_GREEN is defined correctly" || fail "C_NEON_GREEN has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_RED is defined
# =============================================================================
test_c_neon_red() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_RED}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;167m' ]] && pass "C_NEON_RED is defined correctly" || fail "C_NEON_RED has wrong value: ${val}"
}

# =============================================================================
# Test: NEON_BG is defined
# =============================================================================
test_neon_bg() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_BG}\"" 2>/dev/null)
    [[ "${val}" == '#06080f' ]] && pass "NEON_BG is defined correctly" || fail "NEON_BG has wrong value: ${val}"
}

# =============================================================================
# Test: NEON_BG_ALT is defined
# =============================================================================
test_neon_bg_alt() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_BG_ALT}\"" 2>/dev/null)
    [[ "${val}" == '#121620' ]] && pass "NEON_BG_ALT is defined correctly" || fail "NEON_BG_ALT has wrong value: ${val}"
}

# =============================================================================
# Test: NEON_FG is defined
# =============================================================================
test_neon_fg() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_FG}\"" 2>/dev/null)
    [[ "${val}" == '#f3f6f9' ]] && pass "NEON_FG is defined correctly" || fail "NEON_FG has wrong value: ${val}"
}

# =============================================================================
# Test: NEON_ACCENT is defined
# =============================================================================
test_neon_accent() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_ACCENT}\"" 2>/dev/null)
    [[ "${val}" == '#e0c15a' ]] && pass "NEON_ACCENT is defined correctly" || fail "NEON_ACCENT has wrong value: ${val}"
}

# =============================================================================
# Test: NEON_ACCENT_BRIGHT is defined
# =============================================================================
test_neon_accent_bright() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_ACCENT_BRIGHT}\"" 2>/dev/null)
    [[ "${val}" == '#ffe066' ]] && pass "NEON_ACCENT_BRIGHT is defined correctly" || fail "NEON_ACCENT_BRIGHT has wrong value: ${val}"
}

# =============================================================================
# Test: NEON_ALERT is defined
# =============================================================================
test_neon_alert() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_ALERT}\"" 2>/dev/null)
    [[ "${val}" == '#cb7c94' ]] && pass "NEON_ALERT is defined correctly" || fail "NEON_ALERT has wrong value: ${val}"
}

# =============================================================================
# Test: NEON_SELECTION is defined
# =============================================================================
test_neon_selection() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${NEON_SELECTION}\"" 2>/dev/null)
    [[ "${val}" == '#263356' ]] && pass "NEON_SELECTION is defined correctly" || fail "NEON_SELECTION has wrong value: ${val}"
}

# =============================================================================
# Test: All constants are readonly
# =============================================================================
test_readonly() {
    bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        C_RESET='hacked'
    " 2>/dev/null \
        && fail "C_RESET should be readonly" \
        || pass "Constants are readonly"
}

# =============================================================================
# Test: NEON_* palette constants are readonly
# =============================================================================
test_neon_readonly() {
    bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        NEON_BG='hacked'
    " 2>/dev/null \
        && fail "NEON_BG should be readonly" \
        || pass "NEON palette constants are readonly"
}

# Run all tests
main() {
    echo "=== lib/colors.sh Tests ==="
    echo ""

    test_colors_source
    test_c_reset
    test_c_neon_cyan
    test_c_neon_pink
    test_c_neon_purple
    test_c_neon_green
    test_c_neon_red
    test_neon_bg
    test_neon_bg_alt
    test_neon_fg
    test_neon_accent
    test_neon_accent_bright
    test_neon_alert
    test_neon_selection
    test_readonly
    test_neon_readonly

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
