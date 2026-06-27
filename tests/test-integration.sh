#!/usr/bin/env bash
# Integration tests for setup_i3_kali.sh

# Source shared test helpers
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

# =============================================================================
# Test: --help runs without errors
# =============================================================================
test_dry_run() {
    local script_dir="$(dirname "$0")/.."
    bash "${script_dir}/setup_i3_kali.sh" --help >/dev/null 2>&1
    local result=$?
    [[ $result -eq 0 ]] && pass "setup_i3_kali.sh --help runs without error" || fail "setup_i3_kali.sh --help returned $result"
}

# =============================================================================
# Test: Argument validation - valid flags accepted
# =============================================================================
test_args_validation() {
    local script_dir="$(dirname "$0")/.."

    bash "${script_dir}/setup_i3_kali.sh" --help 2>&1 | grep -q "Usage" && pass "Help shows usage information" || fail "Help should show usage information"
    bash "${script_dir}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-user-only" && pass "Help shows --user-only flag" || fail "Help should show --user-only flag"
    bash "${script_dir}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-skip-security" && pass "Help shows --skip-security flag" || fail "Help should show --skip-security flag"
    bash "${script_dir}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-gentle-ai" && pass "Help shows --gentle-ai flag" || fail "Help should show --gentle-ai flag"
}

# =============================================================================
# Test: bash -n syntax check on both scripts
# =============================================================================
test_syntax_check() {
    local script_dir="$(dirname "$0")/.."

    bash -n "${script_dir}/setup_i3_kali.sh" 2>/dev/null && pass "setup_i3_kali.sh passes bash syntax check" || fail "setup_i3_kali.sh has syntax errors"
    bash -n "${script_dir}/purge_xfce.sh" 2>/dev/null && pass "purge_xfce.sh passes bash syntax check" || fail "purge_xfce.sh has syntax errors"
}

# Run all tests
main() {
    echo "=== Integration Tests ==="
    echo ""

    test_dry_run
    test_args_validation
    test_syntax_check

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
