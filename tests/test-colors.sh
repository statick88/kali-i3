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
    [[ "${val}" == '\033[38;5;51m' ]] && pass "C_NEON_CYAN is defined correctly" || fail "C_NEON_CYAN has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_PINK is defined
# =============================================================================
test_c_neon_pink() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_PINK}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;206m' ]] && pass "C_NEON_PINK is defined correctly" || fail "C_NEON_PINK has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_PURPLE is defined
# =============================================================================
test_c_neon_purple() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_PURPLE}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;135m' ]] && pass "C_NEON_PURPLE is defined correctly" || fail "C_NEON_PURPLE has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_GREEN is defined
# =============================================================================
test_c_neon_green() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_GREEN}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;48m' ]] && pass "C_NEON_GREEN is defined correctly" || fail "C_NEON_GREEN has wrong value: ${val}"
}

# =============================================================================
# Test: C_NEON_RED is defined
# =============================================================================
test_c_neon_red() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/colors.sh'; printf '%s' \"\${C_NEON_RED}\"" 2>/dev/null)
    [[ "${val}" == '\033[38;5;197m' ]] && pass "C_NEON_RED is defined correctly" || fail "C_NEON_RED has wrong value: ${val}"
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
    test_readonly

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
