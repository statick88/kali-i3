#!/usr/bin/env bash
# =============================================================================
# lib/security.sh — Security tool installation functions
# =============================================================================
# Provides idempotent install functions for security arsenal tools with
# exponential backoff retry for network operations.
# =============================================================================

set -euo pipefail

# =============================================================================
# retry_with_backoff — Retry a command with exponential backoff
# Usage: retry_with_backoff <command> [args...]
# Max 3 retries, delays: 1s, 2s, 4s
# =============================================================================
retry_with_backoff() {
    local cmd="$1"
    shift
    local max_retries=3
    local delay=1
    local attempt=1
    local exit_code=0
    
    while [[ ${attempt} -le ${max_retries} ]]; do
        if "${cmd}" "$@"; then
            return 0
        else
            exit_code=$?
        fi
        if [[ ${attempt} -eq ${max_retries} ]]; then
            echo "Failed after ${max_retries} attempts" >&2
            return ${exit_code}
        fi
        sleep ${delay}
        delay=$((delay * 2))
        attempt=$((attempt + 1))
    done
}

# =============================================================================
# install_netexec — Install NetExec (nxc) via pipx
# Idempotent: checks if nxc command exists
# =============================================================================
install_netexec() {
    if command -v nxc &>/dev/null; then
        echo "NetExec already installed"
        return 0
    fi
    
    echo "Installing NetExec..."
    retry_with_backoff apt-get install -y pipx
    pipx install netexec
    echo "NetExec installed"
}

# =============================================================================
# install_sliver — Install Sliver C2 framework from GitHub releases
# Idempotent: checks if sliver command exists
# =============================================================================
install_sliver() {
    if command -v sliver &>/dev/null; then
        echo "Sliver already installed"
        return 0
    fi
    
    echo "Installing Sliver..."
    local arch
    arch=$(uname -m)
    case "${arch}" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)       echo "Unsupported architecture: ${arch}" >&2; return 1 ;;
    esac
    
    local url="https://github.com/sliverarmory/sliver/releases/latest/download/sliver-server_linux_${arch}.gz"
    local tmp_file
    tmp_file=$(mktemp)
    
    retry_with_backoff wget -q -O "${tmp_file}" "${url}"
    gunzip "${tmp_file}"
    chmod +x "${tmp_file%.gz}"
    mv "${tmp_file%.gz}" /usr/local/bin/sliver
    rm -f "${tmp_file}"
    echo "Sliver installed"
}

# =============================================================================
# setup_tor — Install and enable Tor service
# Idempotent: checks if tor is already enabled
# =============================================================================
setup_tor() {
    if systemctl is-enabled tor &>/dev/null; then
        echo "Tor already enabled"
        return 0
    fi
    
    echo "Installing Tor..."
    retry_with_backoff apt-get install -y tor
    systemctl enable --now tor
    echo "Tor service enabled and started"
}

# =============================================================================
# setup_proxychains — Install and configure proxychains4 for Tor
# Idempotent: checks if proxychains4 is installed and configured
# =============================================================================
setup_proxychains() {
    if ! command -v proxychains4 &>/dev/null; then
        echo "Installing proxychains4..."
        retry_with_backoff apt-get install -y proxychains4
    fi
    
    local conf_file="/etc/proxychains4.conf"
    if [[ -f "${conf_file}" ]]; then
        # Check if already configured for Tor
        if grep -q "socks5 127.0.0.1 9050" "${conf_file}" && \
           grep -q "proxy_dns" "${conf_file}"; then
            echo "proxychains4 already configured for Tor"
            return 0
        fi
    fi
    
    echo "Configuring proxychains4 for Tor..."
    cat > "${conf_file}" <<'EOF'
# proxychains4 configuration for Tor
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
socks5 127.0.0.1 9050
EOF
    echo "proxychains4 configured"
}

# =============================================================================
# configure_ghidra_java — Set JAVA_HOME for Ghidra if installed
# Idempotent: checks if Ghidra directory exists
# =============================================================================
configure_ghidra_java() {
    local ghidra_dir="/opt/ghidra"
    if [[ ! -d "${ghidra_dir}" ]]; then
        echo "Ghidra not installed, skipping JAVA_HOME configuration"
        return 0
    fi
    
    # Detect OpenJDK path
    local java_home
    java_home=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
    
    if [[ -n "${java_home}" ]]; then
        echo "Setting JAVA_HOME for Ghidra: ${java_home}"
        export JAVA_HOME="${java_home}"
        # Could also write to /etc/environment or profile.d
    else
        echo "Java not found, cannot set JAVA_HOME for Ghidra"
        return 1
    fi
}

# =============================================================================
# setup_ufw — Install and configure UFW firewall
# Idempotent: checks if UFW is already active
# =============================================================================
setup_ufw() {
    if ufw status | grep -q "Status: active"; then
        echo "UFW already active"
        return 0
    fi
    
    echo "Installing UFW..."
    retry_with_backoff apt-get install -y ufw
    
    echo "Configuring UFW..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw --force enable
    echo "UFW enabled with basic rules"
}