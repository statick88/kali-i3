#!/usr/bin/env bash
# =============================================================================
# lib/ssh.sh — SSH connection management for VM testing
# =============================================================================
# Provides ssh_connect(), ssh_execute(), ssh_disconnect(), ssh_copy().
# Requires: sshpass for password authentication.
# =============================================================================

SCRIPT_DIR_SSH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR_SSH}/common.sh"

# Default SSH options
: "${SSH_OPTS:=-o StrictHostKeyChecking=no -o ConnectTimeout=10 -o BatchMode=no}"
: "${SSH_PORT:=22}"
: "${SSH_KEY_FILE:=}"

# =============================================================================
# ssh_connect — Establish SSH connection to remote host
# =============================================================================
# Args: host user password [port]
# Returns: Connection handle (file descriptor) on stdout
# =============================================================================
ssh_connect() {
    local host="${1:-}"
    local user="${2:-}"
    local pass="${3:-}"
    local port="${4:-${SSH_PORT}}"

    if [[ -z "${host}" || -z "${user}" || -z "${pass}" ]]; then
        err "ssh_connect: host, user, and password are required"
        return 1
    fi

    # Check for sshpass
    if ! command -v sshpass &>/dev/null; then
        err "ssh_connect: sshpass is required but not installed"
        return 1
    fi

    # Test connection
    local ssh_cmd="sshpass -p '${pass}' ssh ${SSH_OPTS} -p ${port} ${user}@${host}"
    local test_output
    if ! test_output=$(eval "${ssh_cmd} 'echo OK'" 2>&1); then
        err "ssh_connect: connection failed to ${user}@${host}:${port}"
        return 1
    fi

    if [[ "${test_output}" != *"OK"* ]]; then
        err "ssh_connect: unexpected response from ${user}@${host}:${port}"
        return 1
    fi

    ok "ssh_connect: connected to ${user}@${host}:${port}"
    echo "${host}|${user}|${pass}|${port}"
    return 0
}

# =============================================================================
# ssh_execute — Execute command on remote host
# =============================================================================
# Args: handle command
# Returns: Command output on stdout, exit code via return
# =============================================================================
ssh_execute() {
    local handle="${1:-}"
    shift 2>/dev/null || true
    local command="$*"

    if [[ -z "${handle}" || -z "${command}" ]]; then
        err "ssh_execute: handle and command are required"
        return 1
    fi

    # Parse handle
    IFS='|' read -r host user pass port <<< "${handle}"

    # Build SSH command
    local ssh_cmd="sshpass -p '${pass}' ssh ${SSH_OPTS} -p ${port} ${user}@${host}"

    # Execute
    local output
    local exit_code=0
    output=$(eval "${ssh_cmd} '${command}'" 2>&1) || exit_code=$?

    if [[ ${exit_code} -ne 0 ]]; then
        warn "ssh_execute: command exited with code ${exit_code}"
        echo "${output}"
        return ${exit_code}
    fi

    echo "${output}"
    return 0
}

# =============================================================================
# ssh_execute_background — Execute command in background on remote host
# =============================================================================
# Args: handle command
# Returns: PID on stdout
# =============================================================================
ssh_execute_background() {
    local handle="${1:-}"
    shift 2>/dev/null || true
    local command="$*"

    if [[ -z "${handle}" || -z "${command}" ]]; then
        err "ssh_execute_background: handle and command are required"
        return 1
    fi

    # Parse handle
    IFS='|' read -r host user pass port <<< "${handle}"

    # Build SSH command
    local ssh_cmd="sshpass -p '${pass}' ssh ${SSH_OPTS} -p ${port} ${user}@${host}"

    # Execute in background
    eval "${ssh_cmd} '${command}'" &>/dev/null &
    local pid=$!
    echo "${pid}"
    return 0
}

# =============================================================================
# ssh_copy — Copy file to remote host
# =============================================================================
# Args: handle local_path remote_path
# Returns: 0 on success, non-zero on failure
# =============================================================================
ssh_copy() {
    local handle="${1:-}"
    local local_path="${2:-}"
    local remote_path="${3:-}"

    if [[ -z "${handle}" || -z "${local_path}" || -z "${remote_path}" ]]; then
        err "ssh_copy: handle, local_path, and remote_path are required"
        return 1
    fi

    if [[ ! -f "${local_path}" ]]; then
        err "ssh_copy: local file ${local_path} does not exist"
        return 1
    fi

    # Parse handle
    IFS='|' read -r host user pass port <<< "${handle}"

    # Build SCP command
    local scp_cmd="sshpass -p '${pass}' scp ${SSH_OPTS} -P ${port}"
    local remote="${user}@${host}:${remote_path}"

    # Copy
    if ! eval "${scp_cmd} '${local_path}' '${remote}'" 2>&1; then
        err "ssh_copy: failed to copy ${local_path} to ${remote}"
        return 1
    fi

    ok "ssh_copy: copied ${local_path} to ${remote}"
    return 0
}

# =============================================================================
# ssh_copy_from — Copy file from remote host
# =============================================================================
# Args: handle remote_path local_path
# Returns: 0 on success, non-zero on failure
# =============================================================================
ssh_copy_from() {
    local handle="${1:-}"
    local remote_path="${2:-}"
    local local_path="${3:-}"

    if [[ -z "${handle}" || -z "${remote_path}" || -z "${local_path}" ]]; then
        err "ssh_copy_from: handle, remote_path, and local_path are required"
        return 1
    fi

    # Parse handle
    IFS='|' read -r host user pass port <<< "${handle}"

    # Build SCP command
    local scp_cmd="sshpass -p '${pass}' scp ${SSH_OPTS} -P ${port}"
    local remote="${user}@${host}:${remote_path}"

    # Copy
    if ! eval "${scp_cmd} '${remote}' '${local_path}'" 2>&1; then
        err "ssh_copy_from: failed to copy ${remote} to ${local_path}"
        return 1
    fi

    ok "ssh_copy_from: copied ${remote} to ${local_path}"
    return 0
}

# =============================================================================
# ssh_disconnect — Close SSH connection (cleanup)
# =============================================================================
# Args: handle
# Returns: 0 on success
# =============================================================================
ssh_disconnect() {
    local handle="${1:-}"

    if [[ -z "${handle}" ]]; then
        warn "ssh_disconnect: no handle provided"
        return 0
    fi

    # Parse handle
    IFS='|' read -r host user pass port <<< "${handle}"

    ok "ssh_disconnect: disconnected from ${user}@${host}:${port}"
    return 0
}

# =============================================================================
# ssh_wait_for_host — Wait until host is reachable
# =============================================================================
# Args: host [timeout_seconds] [interval_seconds]
# Returns: 0 when reachable, 1 on timeout
# =============================================================================
ssh_wait_for_host() {
    local host="${1:-}"
    local timeout="${2:-60}"
    local interval="${3:-5}"
    local elapsed=0

    if [[ -z "${host}" ]]; then
        err "ssh_wait_for_host: host is required"
        return 1
    fi

    info "ssh_wait_for_host: waiting for ${host} (timeout: ${timeout}s)..."

    while [[ ${elapsed} -lt ${timeout} ]]; do
        if ping -c 1 -W 2 "${host}" &>/dev/null; then
            ok "ssh_wait_for_host: ${host} is reachable"
            return 0
        fi
        sleep "${interval}"
        elapsed=$((elapsed + interval))
    done

    err "ssh_wait_for_host: timeout waiting for ${host}"
    return 1
}
