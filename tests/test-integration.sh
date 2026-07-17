#!/usr/bin/env bash
# shellcheck disable=SC2155  # mktemp/dirname in declare is acceptable in tests
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

# =============================================================================
# Test: --lang flag appears in --help output
# =============================================================================
test_lang_flag_in_help() {
    local script_dir="$(dirname "$0")/.."
    bash "${script_dir}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-lang" &&
        pass "Help shows --lang flag" ||
        fail "Help should show --lang flag"
}

# =============================================================================
# Test: STEP_LABELS in setup_i3_kali.sh use msg() calls
# =============================================================================
test_setup_step_labels_use_msg() {
    local script_dir="$(dirname "$0")/.."
    local count
    count=$(grep -c 'msg ' "${script_dir}/setup_i3_kali.sh" 2>/dev/null || echo 0)
    [[ ${count} -gt 0 ]] && pass "setup_i3_kali.sh uses msg() for STEP_LABELS (${count} occurrences)" ||
        fail "setup_i3_kali.sh should use msg() for STEP_LABELS"
}

# =============================================================================
# Test: purge_xfce.sh STEP_LABELS use msg() calls
# =============================================================================
test_purge_step_labels_use_msg() {
    local script_dir="$(dirname "$0")/.."
    local count
    count=$(grep -c 'msg ' "${script_dir}/purge_xfce.sh" 2>/dev/null || echo 0)
    [[ ${count} -gt 0 ]] && pass "purge_xfce.sh uses msg() for STEP_LABELS (${count} occurrences)" ||
        fail "purge_xfce.sh should use msg() for STEP_LABELS"
}

# =============================================================================
# Test: setup_i3_kali.sh sources i18n.sh
# =============================================================================
test_setup_sources_i18n() {
    local script_dir="$(dirname "$0")/.."
    grep -q 'i18n.sh' "${script_dir}/setup_i3_kali.sh" 2>/dev/null &&
        pass "setup_i3_kali.sh references i18n.sh" ||
        fail "setup_i3_kali.sh should source i18n.sh"
}

# =============================================================================
# Test: purge_xfce.sh sources i18n.sh
# =============================================================================
test_purge_sources_i18n() {
    local script_dir="$(dirname "$0")/.."
    grep -q 'i18n.sh' "${script_dir}/purge_xfce.sh" 2>/dev/null &&
        pass "purge_xfce.sh references i18n.sh" ||
        fail "purge_xfce.sh should source i18n.sh"
}

# Run all tests
main() {
    echo "=== Integration Tests ==="
    echo ""

    test_dry_run
    test_args_validation
    test_syntax_check
    test_lang_flag_in_help
    test_setup_step_labels_use_msg
    test_purge_step_labels_use_msg
    test_setup_sources_i18n
    test_purge_sources_i18n

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
