#!/usr/bin/env bash
# Approval tests for setup_i3_kali.sh — POST-refactor verification
# Verifies behavior is preserved after extracting to lib/ modules.

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
# External behavior preserved
# =============================================================================
test_help_exits_zero() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help >/dev/null 2>&1
    [[ $? -eq 0 ]] && pass "--help exits 0" || fail "--help should exit 0"
}

test_help_shows_usage() {
    local output
    output=$(bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1)
    [[ "${output}" == *"Usage"* ]] && pass "--help shows Usage" || fail "--help should show Usage"
}

test_help_shows_user_only() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-user-only" \
        && pass "--help shows --user-only" || fail "--help should show --user-only"
}

test_help_shows_skip_security() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-skip-security" \
        && pass "--help shows --skip-security" || fail "--help should show --skip-security"
}

test_help_shows_gentle_ai() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-gentle-ai" \
        && pass "--help shows --gentle-ai" || fail "--help should show --gentle-ai"
}

test_help_shows_hexstrike_ai() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-hexstrike-ai" \
        && pass "--help shows --hexstrike-ai" || fail "--help should show --hexstrike-ai"
}

test_help_shows_version() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-version" \
        && pass "--help shows --version" || fail "--help should show --version"
}

# =============================================================================
# --version flag works
# =============================================================================
test_version_flag() {
    local output
    output=$(bash "${SCRIPT_DIR}/setup_i3_kali.sh" --version 2>&1)
    [[ "${output}" =~ [0-9]+\.[0-9]+\.[0-9]+ ]] && pass "--version shows version from CHANGELOG" || fail "--version should show version"
}

# =============================================================================
# Bash syntax check
# =============================================================================
test_syntax() {
    bash -n "${SCRIPT_DIR}/setup_i3_kali.sh" 2>/dev/null \
        && pass "setup_i3_kali.sh passes bash -n" \
        || fail "setup_i3_kali.sh has syntax errors"
}

# =============================================================================
# Script sources lib modules
# =============================================================================
test_sources_common() {
    grep -q 'source.*lib/common.sh' "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && pass "Script sources lib/common.sh" || fail "Script should source lib/common.sh"
}

test_sources_user() {
    grep -q 'source.*lib/user.sh' "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && pass "Script sources lib/user.sh" || fail "Script should source lib/user.sh"
}

test_sources_state() {
    grep -q 'source.*lib/state.sh' "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && pass "Script sources lib/state.sh" || fail "Script should source lib/state.sh"
}

test_sources_apt() {
    grep -q 'source.*lib/apt.sh' "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && pass "Script sources lib/apt.sh" || fail "Script should source lib/apt.sh"
}

# =============================================================================
# Script does NOT define extracted functions inline (confirming extraction)
# =============================================================================
test_no_log_inline() {
    grep -q "^log()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define log() inline (moved to lib/common.sh)" \
        || pass "log() not defined inline (correctly extracted)"
}

test_no_info_inline() {
    grep -q "^info()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define info() inline" \
        || pass "info() not defined inline (correctly extracted)"
}

test_no_ok_inline() {
    grep -q "^ok()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define ok() inline" \
        || pass "ok() not defined inline (correctly extracted)"
}

test_no_warn_inline() {
    grep -q "^warn()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define warn() inline" \
        || pass "warn() not defined inline (correctly extracted)"
}

test_no_err_inline() {
    grep -q "^err()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define err() inline" \
        || pass "err() not defined inline (correctly extracted)"
}

test_no_step_inline() {
    grep -q "^step()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define step() inline" \
        || pass "step() not defined inline (correctly extracted)"
}

test_no_header_inline() {
    grep -q "^header()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define header() inline" \
        || pass "header() not defined inline (correctly extracted)"
}

test_no_die_inline() {
    grep -q "^die()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define die() inline" \
        || pass "die() not defined inline (correctly extracted)"
}

test_no_show_progress_inline() {
    grep -q "^show_progress()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define show_progress() inline" \
        || pass "show_progress() not defined inline (correctly extracted)"
}

test_no_load_state_inline() {
    grep -q "^load_state()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define load_state() inline" \
        || pass "load_state() not defined inline (correctly extracted)"
}

test_no_save_state_inline() {
    grep -q "^save_state()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define save_state() inline" \
        || pass "save_state() not defined inline (correctly extracted)"
}

test_no_pkg_installed_inline() {
    grep -q "^pkg_installed()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define pkg_installed() inline" \
        || pass "pkg_installed() not defined inline (correctly extracted)"
}

test_no_apt_update_inline() {
    grep -q "^apt_update_once()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define apt_update_once() inline" \
        || pass "apt_update_once() not defined inline (correctly extracted)"
}

test_no_apt_install_inline() {
    grep -q "^apt_install_if_missing()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define apt_install_if_missing() inline" \
        || pass "apt_install_if_missing() not defined inline (correctly extracted)"
}

test_no_cmd_exists_inline() {
    grep -q "^cmd_exists()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define cmd_exists() inline" \
        || pass "cmd_exists() not defined inline (correctly extracted)"
}

test_no_run_as_user_inline() {
    grep -q "^run_as_user()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define run_as_user() inline" \
        || pass "run_as_user() not defined inline (correctly extracted)"
}

test_no_run_as_root_inline() {
    grep -q "^run_as_root()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define run_as_root() inline" \
        || pass "run_as_root() not defined inline (correctly extracted)"
}

test_no_c_reset_inline() {
    grep -q "^readonly C_RESET=" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define C_RESET inline" \
        || pass "C_RESET not defined inline (correctly extracted)"
}

test_no_c_neon_inline() {
    grep -q "^readonly C_NEON_" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define C_NEON_* inline" \
        || pass "C_NEON_* not defined inline (correctly extracted)"
}

test_no_target_user_inline() {
    grep -q '^readonly TARGET_USER=' "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && fail "Script should NOT define TARGET_USER inline" \
        || pass "TARGET_USER not defined inline (correctly extracted)"
}

# =============================================================================
# Script has main() function
# =============================================================================
test_has_main() {
    grep -q "^main()" "${SCRIPT_DIR}/setup_i3_kali.sh" \
        && pass "Script has main() function" || fail "Script should have main()"
}

test_calls_main() {
    tail -1 "${SCRIPT_DIR}/setup_i3_kali.sh" | grep -q 'main "\$@"' \
        && pass "Script calls main \"\$@\"" || fail "Script should call main \"\$@\""
}

# =============================================================================
# die() is used for unknown options (bug fix)
# =============================================================================
test_die_on_unknown_option() {
    local output
    output=$(bash "${SCRIPT_DIR}/setup_i3_kali.sh" --invalid-option 2>&1)
    local exit_code=$?
    [[ ${exit_code} -eq 1 ]] && pass "Unknown option exits with code 1" || fail "Unknown option should exit 1, got ${exit_code}"
}

# Run all tests
main() {
    echo "=== Approval Tests: setup_i3_kali.sh (post-refactor) ==="
    echo ""

    test_help_exits_zero
    test_help_shows_usage
    test_help_shows_user_only
    test_help_shows_skip_security
    test_help_shows_gentle_ai
    test_help_shows_hexstrike_ai
    test_help_shows_version
    test_version_flag
    test_syntax
    test_sources_common
    test_sources_user
    test_sources_state
    test_sources_apt
    test_no_log_inline
    test_no_info_inline
    test_no_ok_inline
    test_no_warn_inline
    test_no_err_inline
    test_no_step_inline
    test_no_header_inline
    test_no_die_inline
    test_no_show_progress_inline
    test_no_load_state_inline
    test_no_save_state_inline
    test_no_pkg_installed_inline
    test_no_apt_update_inline
    test_no_apt_install_inline
    test_no_cmd_exists_inline
    test_no_run_as_user_inline
    test_no_run_as_root_inline
    test_no_c_reset_inline
    test_no_c_neon_inline
    test_no_target_user_inline
    test_has_main
    test_calls_main
    test_die_on_unknown_option

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
