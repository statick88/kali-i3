#!/usr/bin/env bash
# Tests for lib/common.sh — logging and UI helpers

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
# Test: common.sh can be sourced without errors
# =============================================================================
test_common_source() {
    bash -c "source '${SCRIPT_DIR}/lib/common.sh'" 2>/dev/null \
        && pass "common.sh sources without error" \
        || fail "common.sh failed to source"
}

# =============================================================================
# Test: log function exists and produces output
# =============================================================================
test_log_function() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        log 'INFO' 'test message'
    " 2>/dev/null)
    [[ -n "${output}" ]] && pass "log function produces output" || fail "log function produced no output"
}

# =============================================================================
# Test: info() is a shortcut for log INFO
# =============================================================================
test_info_function() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        info 'test info'
    " 2>/dev/null)
    [[ "${output}" == *"INFO"* ]] && pass "info() logs at INFO level" || fail "info() should contain INFO"
}

# =============================================================================
# Test: ok() is a shortcut for log OK
# =============================================================================
test_ok_function() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        ok 'test ok'
    " 2>/dev/null)
    [[ "${output}" == *"OK"* ]] && pass "ok() logs at OK level" || fail "ok() should contain OK"
}

# =============================================================================
# Test: warn() is a shortcut for log WARN
# =============================================================================
test_warn_function() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        warn 'test warning'
    " 2>/dev/null)
    [[ "${output}" == *"WARN"* ]] && pass "warn() logs at WARN level" || fail "warn() should contain WARN"
}

# =============================================================================
# Test: err() is a shortcut for log ERROR
# =============================================================================
test_err_function() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        err 'test error'
    " 2>/dev/null)
    [[ "${output}" == *"ERROR"* ]] && pass "err() logs at ERROR level" || fail "err() should contain ERROR"
}

# =============================================================================
# Test: step() is a shortcut for log STEP
# =============================================================================
test_step_function() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        step 'test step'
    " 2>/dev/null)
    [[ "${output}" == *"STEP"* ]] && pass "step() logs at STEP level" || fail "step() should contain STEP"
}

# =============================================================================
# Test: die() logs error and exits with code 1
# =============================================================================
test_die_function() {
    local exit_code
    bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        die 'fatal error'
    " 2>/dev/null
    exit_code=$?
    [[ ${exit_code} -eq 1 ]] && pass "die() exits with code 1" || fail "die() should exit with code 1, got ${exit_code}"
}

# =============================================================================
# Test: header() produces decorative output
# =============================================================================
test_header_function() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        header 'Test Header'
    " 2>/dev/null)
    [[ "${output}" == *"Test Header"* ]] && pass "header() contains the title" || fail "header() should contain the title"
}

# =============================================================================
# Test: colors are available after sourcing common.sh (cascading source)
# =============================================================================
test_colors_cascade() {
    local val
    val=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        printf '%s' \"\${C_NEON_CYAN}\"
    " 2>/dev/null)
    [[ "${val}" == '\033[38;5;45m' ]] && pass "colors.sh cascades through common.sh" || fail "colors not available after sourcing common.sh"
}

# =============================================================================
# TRIANGULATION: die() outputs the error message before exiting
# =============================================================================
test_die_outputs_message() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        die 'critical failure'
    " 2>&1)
    [[ "${output}" == *"critical failure"* ]] && pass "die() outputs error message" || fail "die() should output the error message"
}

# =============================================================================
# TRIANGULATION: log() handles multi-word messages
# =============================================================================
test_log_multiword() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        LOG_FILE='/tmp/test-common-log-$$'
        log 'INFO' 'word1' 'word2' 'word3'
    " 2>/dev/null)
    [[ "${output}" == *"word1 word2 word3"* ]] && pass "log() handles multi-word messages" || fail "log() should join multiple arguments"
}

# Run all tests
main() {
    echo "=== lib/common.sh Tests ==="
    echo ""

    test_common_source
    test_log_function
    test_info_function
    test_ok_function
    test_warn_function
    test_err_function
    test_step_function
    test_die_function
    test_header_function
    test_colors_cascade
    test_die_outputs_message
    test_log_multiword

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
