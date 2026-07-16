#!/usr/bin/env bash
# =============================================================================
# tests/vm/test-ssh.sh — Unit tests for tests/vm/lib/ssh-connect.sh
# =============================================================================
# TDD RED phase: Tests written BEFORE implementation
# Tests SSH connection with retry logic, logging, and error handling
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TESTHelpers="${SCRIPT_DIR}/tests/lib/test-helpers.sh"
source "${TESTHelpers}"

TEST_SSH_DIR="/tmp/test-ssh-$$"
SSH_CONNECT="${SCRIPT_DIR}/tests/vm/lib/ssh-connect.sh"

setup() {
    rm -rf "${TEST_SSH_DIR}"
    mkdir -p "${TEST_SSH_DIR}"
}

cleanup() {
    rm -rf "${TEST_SSH_DIR}"
    # Restore real SSH if mocked
    unset -f ssh 2>/dev/null || true
}

# =============================================================================
# Test: ssh-connect.sh can be sourced without errors
# =============================================================================
test_ssh_connect_source() {
    bash -c "source '${SSH_CONNECT}'" 2>/dev/null \
        && pass "ssh-connect.sh sources without error" \
        || fail "ssh-connect.sh failed to source"
}

# =============================================================================
# Test: connect_vm function exists
# =============================================================================
test_connect_vm_exists() {
    local output
    output=$(bash -c "
        source '${SSH_CONNECT}'
        type connect_vm 2>/dev/null && echo 'exists'
    " 2>/dev/null)
    [[ "${output}" == *"exists"* ]] \
        && pass "connect_vm function exists" \
        || fail "connect_vm function not found"
}

# =============================================================================
# Test: connect_vm requires 4 arguments
# =============================================================================
test_connect_vm_requires_args() {
    local output
    output=$(bash -c "
        source '${SSH_CONNECT}'
        connect_vm 2>&1
    " 2>&1)
    local exit_code=$?
    [[ ${exit_code} -ne 0 ]] \
        && pass "connect_vm rejects missing arguments" \
        || fail "connect_vm should reject missing arguments"
}

# =============================================================================
# Test: connect_vm returns 0 on successful SSH
# =============================================================================
test_connect_vm_success() {
    # Mock SSH to succeed
    local output
    output=$(bash -c "
        # Override ssh with a mock that succeeds
        ssh() { return 0; }
        export -f ssh
        source '${SSH_CONNECT}'
        connect_vm '192.168.100.6' 'testuser' 'testpass' 1
    " 2>/dev/null)
    local exit_code=$?
    [[ ${exit_code} -eq 0 ]] \
        && pass "connect_vm returns 0 on success" \
        || fail "connect_vm should return 0 on success (got: ${exit_code})"
}

# =============================================================================
# Test: connect_vm returns 1 when all retries exhausted
# =============================================================================
test_connect_vm_retry_exhausted() {
    local output
    output=$(bash -c "
        # Override ssh to always fail
        ssh() { return 1; }
        export -f ssh
        source '${SSH_CONNECT}'
        connect_vm '192.168.100.6' 'testuser' 'testpass' 2
    " 2>&1)
    local exit_code=$?
    [[ ${exit_code} -eq 1 ]] \
        && pass "connect_vm returns 1 when retries exhausted" \
        || fail "connect_vm should return 1 when retries exhausted (got: ${exit_code})"
}

# =============================================================================
# Test: connect_vm retries the correct number of times
# =============================================================================
test_connect_vm_retry_count() {
    local output
    output=$(bash -c "
        SSH_CALL_COUNT=0
        ssh() {
            ((SSH_CALL_COUNT++))
            return 1
        }
        export -f ssh
        source '${SSH_CONNECT}'
        connect_vm '192.168.100.6' 'testuser' 'testpass' 3
        echo \"calls: \${SSH_CALL_COUNT}\"
    " 2>/dev/null)
    [[ "${output}" == *"calls: 3"* ]] \
        && pass "connect_vm retries correct number of times (3)" \
        || fail "connect_vm should retry 3 times (got: ${output})"
}

# =============================================================================
# Test: connect_vm succeeds on retry after initial failures
# =============================================================================
test_connect_vm_succeeds_on_retry() {
    local output
    output=$(bash -c "
        SSH_CALL_COUNT=0
        ssh() {
            ((SSH_CALL_COUNT++))
            # Fail first 2 times, succeed on 3rd
            [[ \${SSH_CALL_COUNT} -lt 3 ]] && return 1
            return 0
        }
        export -f ssh
        source '${SSH_CONNECT}'
        connect_vm '192.168.100.6' 'testuser' 'testpass' 5
        echo \"calls: \${SSH_CALL_COUNT}\"
    " 2>/dev/null)
    local exit_code=$?
    [[ ${exit_code} -eq 0 ]] && [[ "${output}" == *"calls: 3"* ]] \
        && pass "connect_vm succeeds on retry after failures" \
        || fail "connect_vm should succeed on 3rd attempt (exit: ${exit_code}, output: ${output})"
}

# =============================================================================
# Test: connect_vm creates log file with timestamps
# =============================================================================
test_connect_vm_logging() {
    local log_file="${TEST_SSH_DIR}/ssh.log"
    bash -c "
        ssh() { return 0; }
        export -f ssh
        source '${SSH_CONNECT}'
        connect_vm '192.168.100.6' 'testuser' 'testpass' 1 '${log_file}' >/dev/null 2>&1
    " 2>/dev/null
    [[ -f "${log_file}" ]] \
        && pass "connect_vm creates log file" \
        || fail "connect_vm should create log file"
}

# =============================================================================
# Test: connect_vm logs attempt count
# =============================================================================
test_connect_vm_logs_attempts() {
    local log_file="${TEST_SSH_DIR}/ssh-attempts.log"
    bash -c "
        ssh() { return 1; }
        export -f ssh
        source '${SSH_CONNECT}'
        connect_vm '192.168.100.6' 'testuser' 'testpass' 3 '${log_file}' >/dev/null 2>&1
    " 2>/dev/null
    if [[ -f "${log_file}" ]]; then
        local attempts
        attempts=$(grep -c "attempt" "${log_file}" 2>/dev/null || echo "0")
        [[ ${attempts} -ge 3 ]] \
            && pass "connect_vm logs all retry attempts" \
            || fail "connect_vm should log >=3 attempts (got: ${attempts})"
    else
        fail "connect_vm log file not created"
    fi
}

# =============================================================================
# Test: connect_vm includes host/user in log
# =============================================================================
test_connect_vm_log_content() {
    local log_file="${TEST_SSH_DIR}/ssh-content.log"
    bash -c "
        ssh() { return 0; }
        export -f ssh
        source '${SSH_CONNECT}'
        connect_vm '192.168.100.6' 'statick' 'testpass' 1 '${log_file}' >/dev/null 2>&1
    " 2>/dev/null
    if [[ -f "${log_file}" ]]; then
        grep -q "192.168.100.6" "${log_file}" 2>/dev/null \
            && pass "connect_vm log includes host" \
            || fail "connect_vm log should include host"
        grep -q "statick" "${log_file}" 2>/dev/null \
            && pass "connect_vm log includes user" \
            || fail "connect_vm log should include user"
    else
        fail "connect_vm log file not created"
    fi
}

# =============================================================================
# Run all tests
# =============================================================================
main() {
    echo "=== tests/vm/lib/ssh-connect.sh Tests ==="
    echo ""

    setup

    test_ssh_connect_source
    test_connect_vm_exists
    test_connect_vm_requires_args
    test_connect_vm_success
    test_connect_vm_retry_exhausted
    test_connect_vm_retry_count
    test_connect_vm_succeeds_on_retry
    test_connect_vm_logging
    test_connect_vm_logs_attempts
    test_connect_vm_log_content

    cleanup

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
