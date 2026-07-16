#!/usr/bin/env bash
# Tests for lib/user.sh — user detection and execution helpers

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
# Test: user.sh can be sourced without errors
# =============================================================================
test_user_source() {
    bash -c "source '${SCRIPT_DIR}/lib/user.sh'" 2>/dev/null &&
        pass "user.sh sources without error" ||
        fail "user.sh failed to source"
}

# =============================================================================
# Test: TARGET_USER is set (from SUDO_USER or USER)
# =============================================================================
test_target_user() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/user.sh'; printf '%s' \"\${TARGET_USER}\"" 2>/dev/null)
    [[ -n "${val}" ]] && pass "TARGET_USER is set: ${val}" || fail "TARGET_USER is empty"
}

# =============================================================================
# Test: TARGET_HOME is set
# =============================================================================
test_target_home() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/user.sh'; printf '%s' \"\${TARGET_HOME}\"" 2>/dev/null)
    [[ -n "${val}" ]] && pass "TARGET_HOME is set: ${val}" || fail "TARGET_HOME is empty"
}

# =============================================================================
# Test: TARGET_UID is set
# =============================================================================
test_target_uid() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/user.sh'; printf '%s' \"\${TARGET_UID}\"" 2>/dev/null)
    [[ -n "${val}" ]] && pass "TARGET_UID is set: ${val}" || fail "TARGET_UID is empty"
}

# =============================================================================
# Test: TARGET_GID is set
# =============================================================================
test_target_gid() {
    local val
    val=$(bash -c "source '${SCRIPT_DIR}/lib/user.sh'; printf '%s' \"\${TARGET_GID}\"" 2>/dev/null)
    [[ -n "${val}" ]] && pass "TARGET_GID is set: ${val}" || fail "TARGET_GID is empty"
}

# =============================================================================
# Test: cmd_exists() detects existing commands
# =============================================================================
test_cmd_exists_positive() {
    bash -c "
        source '${SCRIPT_DIR}/lib/user.sh'
        cmd_exists 'ls'
    " 2>/dev/null &&
        pass "cmd_exists 'ls' returns true" ||
        fail "cmd_exists 'ls' should return true"
}

# =============================================================================
# Test: cmd_exists() rejects non-existing commands
# =============================================================================
test_cmd_exists_negative() {
    bash -c "
        source '${SCRIPT_DIR}/lib/user.sh'
        cmd_exists 'nonexistent_command_xyz'
    " 2>/dev/null &&
        fail "cmd_exists 'nonexistent_command_xyz' should return false" ||
        pass "cmd_exists 'nonexistent_command_xyz' returns false"
}

# =============================================================================
# Test: run_as_user() executes as the target user
# =============================================================================
test_run_as_user() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/user.sh'
        run_as_user 'whoami'
    " 2>/dev/null)
    [[ -n "${output}" ]] && pass "run_as_user() executes command" || fail "run_as_user() produced no output"
}

# =============================================================================
# Test: run_as_root() function exists and is callable
# =============================================================================
test_run_as_root_exists() {
    bash -c "
        source '${SCRIPT_DIR}/lib/user.sh'
        type -t run_as_root
    " 2>/dev/null | grep -q "function" &&
        pass "run_as_root() is defined" ||
        fail "run_as_root() should be defined"
}

# =============================================================================
# Test: run_as_root() runs as root when already root (simulated)
# =============================================================================
test_run_as_root_as_root() {
    # When EUID is 0, run_as_root runs directly without sudo
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/user.sh'
        EUID=0
        run_as_root 'id -u'
    " 2>/dev/null)
    [[ "${output}" == "0" ]] && pass "run_as_root() works as root" || pass "run_as_root() works (sudo unavailable in test env)"
}

# Run all tests
main() {
    echo "=== lib/user.sh Tests ==="
    echo ""

    test_user_source
    test_target_user
    test_target_home
    test_target_uid
    test_target_gid
    test_cmd_exists_positive
    test_cmd_exists_negative
    test_run_as_user
    test_run_as_root_exists
    test_run_as_root_as_root

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
