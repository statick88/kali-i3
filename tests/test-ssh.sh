#!/usr/bin/env bash
# =============================================================================
# tests/test-ssh.sh — Tests for lib/ssh.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

# Source test helpers
source "${SCRIPT_DIR}/lib/test-helpers.sh"

# Source the module under test
source "${LIB_DIR}/ssh.sh"

# =============================================================================
# Test: ssh.sh can be sourced without errors
# =============================================================================
test_ssh_source() {
    bash -c "source '${LIB_DIR}/ssh.sh'" 2>/dev/null &&
        pass "ssh.sh sources without error" ||
        fail "ssh.sh failed to source"
}

# =============================================================================
# Test: ssh_connect requires arguments
# =============================================================================
test_ssh_connect_requires_args() {
    local output
    output=$(ssh_connect 2>&1) && {
        fail "ssh_connect should fail without arguments"
        return
    }
    # Strip ANSI color codes and timestamp for matching
    local clean_output
    clean_output=$(echo "${output}" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\[.*\] \[.*\] //')
    [[ "${clean_output}" == *"host, user, and password are required"* ]] &&
        pass "ssh_connect requires arguments" ||
        fail "ssh_connect should mention 'host, user, and password are required' in error"
}

# =============================================================================
# Test: ssh_execute requires arguments
# =============================================================================
test_ssh_execute_requires_args() {
    local output
    output=$(ssh_execute 2>&1) && {
        fail "ssh_execute should fail without arguments"
        return
    }
    # Strip ANSI color codes and timestamp for matching
    local clean_output
    clean_output=$(echo "${output}" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\[.*\] \[.*\] //')
    [[ "${clean_output}" == *"handle and command are required"* ]] &&
        pass "ssh_execute requires arguments" ||
        fail "ssh_execute should mention 'handle and command are required' in error"
}

# =============================================================================
# Test: ssh_copy requires arguments
# =============================================================================
test_ssh_copy_requires_args() {
    local output
    output=$(ssh_copy 2>&1) && {
        fail "ssh_copy should fail without arguments"
        return
    }
    # Strip ANSI color codes and timestamp for matching
    local clean_output
    clean_output=$(echo "${output}" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\[.*\] \[.*\] //')
    [[ "${clean_output}" == *"handle, local_path, and remote_path are required"* ]] &&
        pass "ssh_copy requires arguments" ||
        fail "ssh_copy should mention 'handle, local_path, and remote_path are required' in error"
}

# =============================================================================
# Test: ssh_copy requires local file to exist
# =============================================================================
test_ssh_copy_requires_local_file() {
    local output
    output=$(ssh_copy "host|user|pass|22" "/nonexistent/file" "/tmp/dest" 2>&1) && {
        fail "ssh_copy should fail with nonexistent file"
        return
    }
    [[ "${output}" == *"does not exist"* ]] &&
        pass "ssh_copy requires local file to exist" ||
        fail "ssh_copy should mention 'does not exist' in error"
}

# =============================================================================
# Test: ssh_disconnect works without handle
# =============================================================================
test_ssh_disconnect_no_handle() {
    local output
    output=$(ssh_disconnect 2>&1)
    [[ $? -eq 0 ]] &&
        pass "ssh_disconnect works without handle" ||
        fail "ssh_disconnect should succeed without handle"
}

# =============================================================================
# Test: ssh_wait_for_host requires host
# =============================================================================
test_ssh_wait_for_host_requires_host() {
    local output
    output=$(ssh_wait_for_host 2>&1) && {
        fail "ssh_wait_for_host should fail without host"
        return
    }
    [[ "${output}" == *"required"* ]] &&
        pass "ssh_wait_for_host requires host" ||
        fail "ssh_wait_for_host should mention 'required' in error"
}

# =============================================================================
# Test: SSH_OPTS default value
# =============================================================================
test_ssh_opts_default() {
    [[ "${SSH_OPTS}" == *"StrictHostKeyChecking=no"* ]] &&
        pass "SSH_OPTS has default value" ||
        fail "SSH_OPTS should have StrictHostKeyChecking=no"
}

# =============================================================================
# Test: SSH_PORT default value
# =============================================================================
test_ssh_port_default() {
    [[ "${SSH_PORT}" == "22" ]] &&
        pass "SSH_PORT defaults to 22" ||
        fail "SSH_PORT should default to 22"
}

# =============================================================================
# Run all tests
# =============================================================================
run_all_tests() {
    test_ssh_source
    test_ssh_connect_requires_args
    test_ssh_execute_requires_args
    test_ssh_copy_requires_args
    test_ssh_copy_requires_local_file
    test_ssh_disconnect_no_handle
    test_ssh_wait_for_host_requires_host
    test_ssh_opts_default
    test_ssh_port_default
}

# Main
run_all_tests

# Summary
echo ""
echo "========================================="
echo "Tests: ${TESTS_RUN} | Pass: ${TESTS_PASS} | Fail: ${TESTS_FAIL}"
echo "========================================="

[[ ${TESTS_FAIL} -eq 0 ]] && exit 0 || exit 1
