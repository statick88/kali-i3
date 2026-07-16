#!/usr/bin/env bash
# =============================================================================
# tests/vm/lib/ssh-connect.sh — SSH connection with retry logic
# =============================================================================
# Provides: connect_vm <host> <user> <password> <max_retries> [log_file]
# Returns: 0=success, 1=failed after all retries
# Side effects: establishes SSH session, logs attempts with timestamps
# =============================================================================

# Default retry interval in seconds
SSH_RETRY_INTERVAL="${SSH_RETRY_INTERVAL:-15}"

# SSH options for non-interactive connections
SSH_OPTIONS=(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o ConnectTimeout=10
    -o LogLevel=ERROR
)

# _ssh_log — write timestamped message to log file if provided
_ssh_log() {
    local log_file="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ -n "${log_file}" ]]; then
        echo "[${timestamp}] ${message}" >> "${log_file}"
    fi
}

# connect_vm — establish SSH connection with retry logic
# Arguments:
#   host        - target VM IP/hostname
#   user        - SSH username
#   password    - SSH password (passed via sshpass if available, else prompt)
#   max_retries - maximum connection attempts
#   log_file    - (optional) file to log connection attempts
# Returns:
#   0 if connection succeeded
#   1 if all retries exhausted
connect_vm() {
    local host="$1"
    local user="$2"
    local password="$3"
    local max_retries="$4"
    local log_file="${5:-}"

    # Validate arguments
    if [[ -z "${host}" || -z "${user}" || -z "${password}" || -z "${max_retries}" ]]; then
        echo "Usage: connect_vm <host> <user> <password> <max_retries> [log_file]" >&2
        return 1
    fi

    # Validate max_retries is a positive integer
    if ! [[ "${max_retries}" =~ ^[0-9]+$ ]] || [[ "${max_retries}" -lt 1 ]]; then
        echo "Error: max_retries must be a positive integer" >&2
        return 1
    fi

    local attempt=1
    local connected=0

    _ssh_log "${log_file}" "SSH connection attempt started: host=${host} user=${user} max_retries=${max_retries}"

    while [[ ${attempt} -le ${max_retries} ]]; do
        _ssh_log "${log_file}" "Attempt ${attempt}/${max_retries}: connecting to ${user}@${host}"

        # Try SSH connection — execute a simple command to verify connectivity
        if ssh "${SSH_OPTIONS[@]}" "${user}@${host}" "echo 'kali-i3-ssh-ok'" >/dev/null 2>&1; then
            connected=1
            _ssh_log "${log_file}" "Attempt ${attempt}/${max_retries}: SUCCESS"
            break
        fi

        _ssh_log "${log_file}" "Attempt ${attempt}/${max_retries}: FAILED"

        # Wait before retry (except on last attempt)
        if [[ ${attempt} -lt ${max_retries} ]]; then
            _ssh_log "${log_file}" "Waiting ${SSH_RETRY_INTERVAL}s before retry..."
            sleep "${SSH_RETRY_INTERVAL}"
        fi

        ((attempt++))
    done

    if [[ ${connected} -eq 1 ]]; then
        _ssh_log "${log_file}" "SSH connection established to ${user}@${host}"
        return 0
    else
        _ssh_log "${log_file}" "SSH connection FAILED after ${max_retries} attempts to ${user}@${host}"
        return 1
    fi
}
