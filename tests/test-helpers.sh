#!/usr/bin/env bash
# Tests for tests/lib/test-helpers.sh — shared test boilerplate

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

# This test lives in tests/test-helpers.sh, helpers live in tests/lib/test-helpers.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="${SCRIPT_DIR}/lib/test-helpers.sh"

# =============================================================================
# Test: test-helpers.sh can be sourced without errors
# =============================================================================
test_helpers_source() {
    bash -c "source '${HELPERS}'" 2>/dev/null \
        && pass "test-helpers.sh sources without error" \
        || fail "test-helpers.sh failed to source"
}

# =============================================================================
# Test: pass() function is available
# =============================================================================
test_pass_function() {
    local output
    output=$(bash -c "
        source '${HELPERS}'
        pass 'test pass msg'
    " 2>/dev/null)
    [[ "${output}" == *"PASS"* ]] && pass "pass() function works" || fail "pass() should produce output with PASS"
}

# =============================================================================
# Test: fail() function is available
# =============================================================================
test_fail_function() {
    local output
    output=$(bash -c "
        source '${HELPERS}'
        fail 'test fail msg'
    " 2>/dev/null)
    [[ "${output}" == *"FAIL"* ]] && pass "fail() function works" || fail "fail() should produce output with FAIL"
}

# =============================================================================
# Test: Color constants are available
# =============================================================================
test_color_constants() {
    bash -c "
        source '${HELPERS}'
        # Test that RED, GREEN, NC are defined
        [[ -n \"\${RED}\" && -n \"\${GREEN}\" && -n \"\${NC}\" ]] && exit 0 || exit 1
    " 2>/dev/null \
        && pass "Color constants (RED, GREEN, NC) are defined" \
        || fail "Color constants should be defined"
}

# =============================================================================
# Test: Counter variables are initialized
# =============================================================================
test_counters() {
    bash -c "
        source '${HELPERS}'
        # Test that counters are initialized
        [[ \"\${TESTS_RUN}\" -eq 0 && \"\${TESTS_PASS}\" -eq 0 && \"\${TESTS_FAIL}\" -eq 0 ]] && exit 0 || exit 1
    " 2>/dev/null \
        && pass "Counter variables are initialized to 0" \
        || fail "Counters should start at 0"
}

# Run all tests
main() {
    echo "=== tests/lib/test-helpers.sh Tests ==="
    echo ""

    test_helpers_source
    test_pass_function
    test_fail_function
    test_color_constants
    test_counters

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
