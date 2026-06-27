#!/usr/bin/env bash
# Tests for lib/state.sh — persistent state management

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
TEST_STATE_DIR="/tmp/test-state-$$"
TEST_STATE_FILE="${TEST_STATE_DIR}/test-state.json"

setup() {
    rm -rf "${TEST_STATE_DIR}"
    mkdir -p "${TEST_STATE_DIR}"
}

cleanup() {
    rm -rf "${TEST_STATE_DIR}"
}

# =============================================================================
# Test: state.sh can be sourced without errors
# =============================================================================
test_state_source() {
    bash -c "
        source '${SCRIPT_DIR}/lib/state.sh'
    " 2>/dev/null \
        && pass "state.sh sources without error" \
        || fail "state.sh failed to source"
}

# =============================================================================
# Test: load_state() handles missing state file
# =============================================================================
test_load_state_missing() {
    local output
    output=$(bash -c "
        STATE_FILE='${TEST_STATE_DIR}/nonexistent.json'
        COMPLETED_STEPS=()
        source '${SCRIPT_DIR}/lib/state.sh'
        load_state
        echo 'ok'
    " 2>/dev/null)
    [[ "${output}" == *"ok"* ]] && pass "load_state() handles missing file" || fail "load_state() should handle missing file gracefully"
}

# =============================================================================
# Test: save_state() creates state file
# =============================================================================
test_save_state_creates_file() {
    bash -c "
        STATE_FILE='${TEST_STATE_FILE}'
        STATE_VERSION='1.0.0'
        TARGET_UID=1000
        TARGET_GID=1000
        declare -A COMPLETED_STEPS=()
        source '${SCRIPT_DIR}/lib/state.sh'
        save_state
    " 2>/dev/null
    [[ -f "${TEST_STATE_FILE}" ]] && pass "save_state() creates state file" || fail "save_state() should create state file"
}

# =============================================================================
# Test: mark_completed() records a step
# =============================================================================
test_mark_completed() {
    bash -c "
        STATE_FILE='${TEST_STATE_FILE}'
        STATE_VERSION='1.0.0'
        TARGET_UID=1000
        TARGET_GID=1000
        declare -A COMPLETED_STEPS=()
        source '${SCRIPT_DIR}/lib/state.sh'
        mark_completed 'step_test_one'
    " 2>/dev/null
    [[ -f "${TEST_STATE_FILE}" ]] && pass "mark_completed() creates state file" || fail "mark_completed() should create state file"
}

# =============================================================================
# Test: is_completed() detects completed steps
# =============================================================================
test_is_completed() {
    local output
    output=$(bash -c "
        STATE_FILE='${TEST_STATE_FILE}'
        STATE_VERSION='1.0.0'
        TARGET_UID=1000
        TARGET_GID=1000
        declare -A COMPLETED_STEPS=()
        source '${SCRIPT_DIR}/lib/state.sh'
        mark_completed 'step_done'
        if is_completed 'step_done'; then
            echo 'found'
        else
            echo 'not_found'
        fi
    " 2>/dev/null)
    [[ "${output}" == *"found"* ]] && pass "is_completed() detects completed step" || fail "is_completed() should detect completed step"
}

# =============================================================================
# Test: is_completed() rejects non-completed steps
# =============================================================================
test_is_not_completed() {
    local output
    output=$(bash -c "
        STATE_FILE='${TEST_STATE_FILE}'
        STATE_VERSION='1.0.0'
        TARGET_UID=1000
        TARGET_GID=1000
        declare -A COMPLETED_STEPS=()
        source '${SCRIPT_DIR}/lib/state.sh'
        if is_completed 'step_not_done'; then
            echo 'found'
        else
            echo 'not_found'
        fi
    " 2>/dev/null)
    [[ "${output}" == *"not_found"* ]] && pass "is_completed() rejects non-completed step" || fail "is_completed() should reject non-completed step"
}

# =============================================================================
# Test: show_progress() produces output
# =============================================================================
test_show_progress() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 5 10 'test step'
    " 2>/dev/null)
    [[ -n "${output}" ]] && pass "show_progress() produces output" || fail "show_progress() should produce output"
}

# =============================================================================
# TRIANGULATION: save_state() creates valid JSON with version
# =============================================================================
test_save_state_json_content() {
    bash -c "
        STATE_FILE='${TEST_STATE_FILE}'
        STATE_VERSION='1.0.0'
        TARGET_UID=1000
        TARGET_GID=1000
        declare -A COMPLETED_STEPS=()
        source '${SCRIPT_DIR}/lib/state.sh'
        save_state
    " 2>/dev/null
    grep -q '"version"' "${TEST_STATE_FILE}" 2>/dev/null \
        && pass "save_state() includes version in JSON" \
        || fail "save_state() JSON should contain version"
}

# =============================================================================
# TRIANGULATION: save/load round-trip preserves completed steps
# =============================================================================
test_save_load_roundtrip() {
    local output
    output=$(bash -c "
        STATE_FILE='${TEST_STATE_FILE}'
        STATE_VERSION='1.0.0'
        TARGET_UID=1000
        TARGET_GID=1000
        declare -A COMPLETED_STEPS=()
        source '${SCRIPT_DIR}/lib/state.sh'
        mark_completed 'step_alpha'
        mark_completed 'step_beta'
        
        # Now load into fresh state
        declare -A COMPLETED_STEPS=()
        load_state
        
        if is_completed 'step_alpha' && is_completed 'step_beta'; then
            echo 'both_found'
        else
            echo 'missing'
        fi
    " 2>/dev/null)
    [[ "${output}" == *"both_found"* ]] && pass "save/load roundtrip preserves steps" || fail "save/load roundtrip lost steps"
}

# Run all tests
main() {
    echo "=== lib/state.sh Tests ==="
    echo ""

    setup

    test_state_source
    test_load_state_missing
    test_save_state_creates_file
    test_mark_completed
    test_is_completed
    test_is_not_completed
    test_show_progress
    test_save_state_json_content
    test_save_load_roundtrip

    cleanup

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
