#!/usr/bin/env bash
# Approval tests for purge_xfce.sh — POST-refactor verification

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
# Bash syntax check
# =============================================================================
test_syntax() {
    bash -n "${SCRIPT_DIR}/purge_xfce.sh" 2>/dev/null \
        && pass "purge_xfce.sh passes bash -n" \
        || fail "purge_xfce.sh has syntax errors"
}

# =============================================================================
# Script sources lib modules
# =============================================================================
test_sources_common() {
    grep -q 'source.*lib/common.sh' "${SCRIPT_DIR}/purge_xfce.sh" \
        && pass "Script sources lib/common.sh" || fail "Script should source lib/common.sh"
}

test_sources_user() {
    grep -q 'source.*lib/user.sh' "${SCRIPT_DIR}/purge_xfce.sh" \
        && pass "Script sources lib/user.sh" || fail "Script should source lib/user.sh"
}

test_sources_state() {
    grep -q 'source.*lib/state.sh' "${SCRIPT_DIR}/purge_xfce.sh" \
        && pass "Script sources lib/state.sh" || fail "Script should source lib/state.sh"
}

# =============================================================================
# Script does NOT define extracted functions inline
# =============================================================================
test_no_log_inline() {
    grep -q "^log()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define log() inline" \
        || pass "log() not defined inline (correctly extracted)"
}

test_no_info_inline() {
    grep -q "^info()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define info() inline" \
        || pass "info() not defined inline (correctly extracted)"
}

test_no_ok_inline() {
    grep -q "^ok()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define ok() inline" \
        || pass "ok() not defined inline (correctly extracted)"
}

test_no_warn_inline() {
    grep -q "^warn()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define warn() inline" \
        || pass "warn() not defined inline (correctly extracted)"
}

test_no_err_inline() {
    grep -q "^err()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define err() inline" \
        || pass "err() not defined inline (correctly extracted)"
}

test_no_step_inline() {
    grep -q "^step()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define step() inline" \
        || pass "step() not defined inline (correctly extracted)"
}

test_no_show_progress_inline() {
    grep -q "^show_progress()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define show_progress() inline" \
        || pass "show_progress() not defined inline (correctly extracted)"
}

test_no_load_state_inline() {
    grep -q "^load_state()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define load_state() inline" \
        || pass "load_state() not defined inline (correctly extracted)"
}

test_no_save_state_inline() {
    grep -q "^save_state()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define save_state() inline" \
        || pass "save_state() not defined inline (correctly extracted)"
}

test_no_run_as_root_inline() {
    grep -q "^run_as_root()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define run_as_root() inline" \
        || pass "run_as_root() not defined inline (correctly extracted)"
}

test_no_run_as_user_inline() {
    grep -q "^run_as_user()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define run_as_user() inline" \
        || pass "run_as_user() not defined inline (correctly extracted)"
}

test_no_c_reset_inline() {
    grep -q "^readonly C_RESET=" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define C_RESET inline" \
        || pass "C_RESET not defined inline (correctly extracted)"
}

test_no_c_neon_inline() {
    grep -q "^readonly C_NEON_" "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define C_NEON_* inline" \
        || pass "C_NEON_* not defined inline (correctly extracted)"
}

test_no_target_user_inline() {
    grep -q '^readonly TARGET_USER=' "${SCRIPT_DIR}/purge_xfce.sh" \
        && fail "Script should NOT define TARGET_USER inline" \
        || pass "TARGET_USER not defined inline (correctly extracted)"
}

# =============================================================================
# Script keeps pkg_installed() inline (different from lib/apt.sh version)
# =============================================================================
test_keeps_pkg_installed() {
    grep -q "^pkg_installed()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && pass "Script keeps pkg_installed() inline" || fail "Script should keep pkg_installed() inline"
}

# =============================================================================
# Script has main() function
# =============================================================================
test_has_main() {
    grep -q "^main()" "${SCRIPT_DIR}/purge_xfce.sh" \
        && pass "Script has main() function" || fail "Script should have main()"
}

test_calls_main() {
    tail -1 "${SCRIPT_DIR}/purge_xfce.sh" | grep -q 'main "\$@"' \
        && pass "Script calls main \"\$@\"" || fail "Script should call main \"\$@\""
}

# Run all tests
main() {
    echo "=== Approval Tests: purge_xfce.sh (post-refactor) ==="
    echo ""

    test_syntax
    test_sources_common
    test_sources_user
    test_sources_state
    test_no_log_inline
    test_no_info_inline
    test_no_ok_inline
    test_no_warn_inline
    test_no_err_inline
    test_no_step_inline
    test_no_show_progress_inline
    test_no_load_state_inline
    test_no_save_state_inline
    test_no_run_as_root_inline
    test_no_run_as_user_inline
    test_no_c_reset_inline
    test_no_c_neon_inline
    test_no_target_user_inline
    test_keeps_pkg_installed
    test_has_main
    test_calls_main

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
