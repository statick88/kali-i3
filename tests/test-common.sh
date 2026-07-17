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
    bash -c "source '${SCRIPT_DIR}/lib/common.sh'" 2>/dev/null &&
        pass "common.sh sources without error" ||
        fail "common.sh failed to source"
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
    " 2>&1)
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
    " 2>&1)
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
    " 2>&1)
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
    " 2>&1)
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
    " 2>&1)
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
    " 2>&1)
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
    [[ "${val}" == '\033[38;5;37m' ]] && pass "colors.sh cascades through common.sh" || fail "colors not available after sourcing common.sh"
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
    " 2>&1)
    [[ "${output}" == *"word1 word2 word3"* ]] && pass "log() handles multi-word messages" || fail "log() should join multiple arguments"
}

# =============================================================================
# Test: i18n.sh cascades through common.sh
# =============================================================================
test_i18n_cascade() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        i18n_init en
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    [[ -n "${output}" ]] && pass "i18n.sh cascades through common.sh" || fail "i18n not available after sourcing common.sh"
}

# =============================================================================
# Test: ok() uses translated message when i18n is initialized
# =============================================================================
test_ok_i18n_translation() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        i18n_init es
        LOG_FILE='/tmp/test-common-log-$$'
        ok 'MSG_WELCOME'
    " 2>&1)
    [[ "${output}" == *"Bienvenido"* ]] && pass "ok() uses Spanish translation" ||
        fail "ok() should use Spanish translation, got: ${output}"
}

# =============================================================================
# Test: warn() uses translated message when i18n is initialized
# =============================================================================
test_warn_i18n_translation() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        i18n_init es
        LOG_FILE='/tmp/test-common-log-$$'
        warn 'MSG_ERROR_UNKNOWN_OPTION'
    " 2>&1)
    [[ "${output}" == *"Opción desconocida"* ]] && pass "warn() uses Spanish translation" ||
        fail "warn() should use Spanish translation, got: ${output}"
}

# =============================================================================
# Test: err() uses translated message when i18n is initialized
# =============================================================================
test_err_i18n_translation() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        i18n_init es
        LOG_FILE='/tmp/test-common-log-$$'
        err 'MSG_ERROR_MUST_BE_ROOT'
    " 2>&1)
    [[ "${output}" == *"root"* || "${output}" == *"sudo"* ]] && pass "err() uses Spanish translation" ||
        fail "err() should use Spanish translation, got: ${output}"
}

# =============================================================================
# Test: step() uses translated message when i18n is initialized
# =============================================================================
test_step_i18n_translation() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        i18n_init es
        LOG_FILE='/tmp/test-common-log-$$'
        step 'STEP_INSTALL_I3_CORE'
    " 2>&1)
    [[ "${output}" == *"Instalando paquetes"* ]] && pass "step() uses Spanish translation" ||
        fail "step() should use Spanish translation, got: ${output}"
}

# =============================================================================
# Test: header() still works with translated content
# =============================================================================
test_header_i18n_translation() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        i18n_init es
        header MSG_WELCOME
    " 2>/dev/null)
    [[ "${output}" == *"Bienvenido"* ]] && pass "header() works with translated content" ||
        fail "header() should work with translated content, got: ${output}"
}

# =============================================================================
# Test: Logging functions still output level tag (OK, WARN, etc.) with i18n
# =============================================================================
test_log_level_preserved_with_i18n() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        i18n_init es
        LOG_FILE='/tmp/test-common-log-$$'
        ok 'MSG_WELCOME'
    " 2>&1)
    [[ "${output}" == *"OK"* ]] && pass "ok() preserves OK level tag with i18n" ||
        fail "ok() should still contain OK level tag"
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
    test_i18n_cascade
    test_ok_i18n_translation
    test_warn_i18n_translation
    test_err_i18n_translation
    test_step_i18n_translation
    test_header_i18n_translation
    test_log_level_preserved_with_i18n

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
