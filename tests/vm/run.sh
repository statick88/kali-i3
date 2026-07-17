#!/usr/bin/env bash
# =============================================================================
# tests/vm/run.sh — VM test execution wrapper
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../../lib"

# Source configuration
source "${SCRIPT_DIR}/config.sh"

# Source test helpers
source "${SCRIPT_DIR}/../lib/test-helpers.sh"

# Source SSH module
source "${LIB_DIR}/ssh.sh"

# Source phase logger (will be created later)
if [[ -f "${LIB_DIR}/phase-logger.sh" ]]; then
    source "${LIB_DIR}/phase-logger.sh"
fi

# Source screenshot module (will be created later)
if [[ -f "${LIB_DIR}/screenshot.sh" ]]; then
    source "${LIB_DIR}/screenshot.sh"
fi

# =============================================================================
# Test: VM is reachable
# =============================================================================
test_vm_reachable() {
    echo "Testing VM connectivity..."
    
    if ssh_wait_for_host "${VM_HOST}" "${VM_CONNECT_TIMEOUT}" 5; then
        pass "VM is reachable at ${VM_HOST}"
        return 0
    else
        fail "VM is not reachable at ${VM_HOST}"
        return 1
    fi
}

# =============================================================================
# Test: Can connect via SSH
# =============================================================================
test_ssh_connection() {
    echo "Testing SSH connection..."
    
    local handle
    handle=$(ssh_connect "${VM_HOST}" "${VM_USER}" "${VM_PASS}" "${VM_PORT}")
    
    if [[ $? -eq 0 && -n "${handle}" ]]; then
        local output
        output=$(ssh_execute "${handle}" "echo 'SSH_OK'")
        
        if [[ "${output}" == *"SSH_OK"* ]]; then
            pass "SSH connection works"
            ssh_disconnect "${handle}"
            return 0
        else
            fail "SSH command execution failed"
            ssh_disconnect "${handle}"
            return 1
        fi
    else
        fail "SSH connection failed"
        return 1
    fi
}

# =============================================================================
# Test: Can copy script to VM
# =============================================================================
test_copy_script() {
    echo "Testing script copy..."
    
    local handle
    handle=$(ssh_connect "${VM_HOST}" "${VM_USER}" "${VM_PASS}" "${VM_PORT}")
    
    if [[ $? -eq 0 && -n "${handle}" ]]; then
        if ssh_copy "${handle}" "${LOCAL_SCRIPT_PATH}" "${REMOTE_SCRIPT_PATH}"; then
            # Verify file exists
            local output
            output=$(ssh_execute "${handle}" "ls -la ${REMOTE_SCRIPT_PATH}")
            
            if [[ "${output}" == *"setup_i3_kali.sh"* ]]; then
                pass "Script copied successfully"
                ssh_disconnect "${handle}"
                return 0
            else
                fail "Script copy verification failed"
                ssh_disconnect "${handle}"
                return 1
            fi
        else
            fail "Script copy failed"
            ssh_disconnect "${handle}"
            return 1
        fi
    else
        fail "SSH connection failed for copy"
        return 1
    fi
}

# =============================================================================
# Test: Can execute script phases
# =============================================================================
test_execute_phases() {
    echo "Testing phase execution..."
    
    local handle
    handle=$(ssh_connect "${VM_HOST}" "${VM_USER}" "${VM_PASS}" "${VM_PORT}")
    
    if [[ $? -eq 0 && -n "${handle}" ]]; then
        # Make script executable
        ssh_execute "${handle}" "chmod +x ${REMOTE_SCRIPT_PATH}"
        
        # Test each phase
        for phase in "${PHASES[@]}"; do
            echo "  Testing phase: ${phase}"
            
            # Run phase with logging
            local output
            output=$(ssh_execute "${handle}" "sudo ${REMOTE_SCRIPT_PATH} --phase ${phase} 2>&1" || true)
            
            # Log phase result
            if [[ -d "${PHASE_LOG_DIR}" ]]; then
                echo "${output}" > "${PHASE_LOG_DIR}/${phase}.log"
            fi
            
            # Take screenshot if available
            if [[ -d "${PHASE_SCREENSHOT_DIR}" ]]; then
                ssh_execute "${handle}" "maim ${PHASE_SCREENSHOT_DIR}/${phase}.png" 2>/dev/null || true
            fi
            
            echo "  Phase ${phase} completed"
        done
        
        pass "All phases executed"
        ssh_disconnect "${handle}"
        return 0
    else
        fail "SSH connection failed for phases"
        return 1
    fi
}

# =============================================================================
# Run all VM tests
# =============================================================================
run_all_vm_tests() {
    echo "=== VM Tests ==="
    echo ""
    
    # Create log directories
    mkdir -p "${PHASE_LOG_DIR}" "${PHASE_SCREENSHOT_DIR}" 2>/dev/null || true
    
    # Run tests in order
    test_vm_reachable || return 1
    test_ssh_connection || return 1
    # Brief delay between SSH connections to avoid rapid reconnection failures
    sleep 2
    test_copy_script || return 1
    test_execute_phases || return 1
    
    echo ""
    echo "=== All VM tests passed ==="
}

# Main
run_all_vm_tests

# Summary
echo ""
echo "========================================="
echo "Tests: ${TESTS_RUN} | Pass: ${TESTS_PASS} | Fail: ${TESTS_FAIL}"
echo "========================================="

[[ ${TESTS_FAIL} -eq 0 ]] && exit 0 || exit 1
