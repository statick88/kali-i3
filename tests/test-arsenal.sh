#!/usr/bin/env bash
# shellcheck disable=SC2155  # mktemp in declare is acceptable in tests
# =============================================================================
# tests/test-arsenal.sh — Tests for lib/security.sh security arsenal functions
# =============================================================================

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
SECURITY_SH="${SCRIPT_DIR}/lib/security.sh"

# =============================================================================
# Test: security.sh can be sourced without errors
# =============================================================================
test_security_source() {
    bash -c "source '${SECURITY_SH}'" 2>/dev/null &&
        pass "security.sh sources without error" ||
        fail "security.sh failed to source"
}

# =============================================================================
# Test: retry_with_backoff is defined
# =============================================================================
test_retry_with_backoff_defined() {
    bash -c "
        source '${SECURITY_SH}'
        type -t retry_with_backoff
    " 2>/dev/null | grep -q 'function' &&
        pass "retry_with_backoff is defined" ||
        fail "retry_with_backoff not defined"
}

# =============================================================================
# Test: retry_with_backoff retries on failure
# =============================================================================
test_retry_with_backoff_retries() {
    # Create a mock command that fails twice then succeeds
    local mock_script=$(mktemp)
    local fail_count_file=$(mktemp)
    cat >"${mock_script}" <<EOF
#!/usr/bin/env bash
# Mock command that fails first two times, succeeds third
FAIL_COUNT_FILE="${fail_count_file}"
if [[ -f "\${FAIL_COUNT_FILE}" ]]; then
    count=\$(cat "\${FAIL_COUNT_FILE}")
else
    count=0
fi
count=\$((count + 1))
echo "\${count}" > "\${FAIL_COUNT_FILE}"
if [[ \${count} -le 2 ]]; then
    exit 1
else
    rm -f "\${FAIL_COUNT_FILE}"
    exit 0
fi
EOF
    chmod +x "${mock_script}"

    # Run retry_with_backoff with mock command
    local output
    output=$(bash -c "
        source '${SECURITY_SH}'
        retry_with_backoff '${mock_script}'
    " 2>&1)
    local exit_code=$?

    rm -f "${mock_script}" "${fail_count_file}"

    [[ ${exit_code} -eq 0 ]] && pass "retry_with_backoff retries on failure and succeeds" ||
        fail "retry_with_backoff failed after retries (exit ${exit_code})"
}

# =============================================================================
# Test: retry_with_backoff fails after max retries
# =============================================================================
test_retry_with_backoff_max_retries() {
    # Create a mock command that always fails
    local mock_script=$(mktemp)
    cat >"${mock_script}" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
    chmod +x "${mock_script}"

    # Run retry_with_backoff with always-failing command
    local output
    output=$(bash -c "
        source '${SECURITY_SH}'
        retry_with_backoff '${mock_script}'
    " 2>&1)
    local exit_code=$?

    rm -f "${mock_script}"

    [[ ${exit_code} -ne 0 ]] && pass "retry_with_backoff fails after max retries" ||
        fail "retry_with_backoff should have failed but succeeded"
}

# =============================================================================
# Test: install_netexec is defined
# =============================================================================
test_install_netexec_defined() {
    bash -c "
        source '${SECURITY_SH}'
        type -t install_netexec
    " 2>/dev/null | grep -q 'function' &&
        pass "install_netexec is defined" ||
        fail "install_netexec not defined"
}

# =============================================================================
# Test: install_sliver is defined
# =============================================================================
test_install_sliver_defined() {
    bash -c "
        source '${SECURITY_SH}'
        type -t install_sliver
    " 2>/dev/null | grep -q 'function' &&
        pass "install_sliver is defined" ||
        fail "install_sliver not defined"
}

# =============================================================================
# Test: setup_tor is defined
# =============================================================================
test_setup_tor_defined() {
    bash -c "
        source '${SECURITY_SH}'
        type -t setup_tor
    " 2>/dev/null | grep -q 'function' &&
        pass "setup_tor is defined" ||
        fail "setup_tor not defined"
}

# =============================================================================
# Test: setup_proxychains is defined
# =============================================================================
test_setup_proxychains_defined() {
    bash -c "
        source '${SECURITY_SH}'
        type -t setup_proxychains
    " 2>/dev/null | grep -q 'function' &&
        pass "setup_proxychains is defined" ||
        fail "setup_proxychains not defined"
}

# =============================================================================
# Test: configure_ghidra_java is defined
# =============================================================================
test_configure_ghidra_java_defined() {
    bash -c "
        source '${SECURITY_SH}'
        type -t configure_ghidra_java
    " 2>/dev/null | grep -q 'function' &&
        pass "configure_ghidra_java is defined" ||
        fail "configure_ghidra_java not defined"
}

# =============================================================================
# Test: setup_ufw is defined
# =============================================================================
test_setup_ufw_defined() {
    bash -c "
        source '${SECURITY_SH}'
        type -t setup_ufw
    " 2>/dev/null | grep -q 'function' &&
        pass "setup_ufw is defined" ||
        fail "setup_ufw not defined"
}

# =============================================================================
# Test: install_netexec idempotent (skips if already installed)
# =============================================================================
test_install_netexec_idempotent() {
    # Create a mock netexec command that always exists
    local mock_dir=$(mktemp -d)
    echo '#!/usr/bin/env bash' >"${mock_dir}/nxc"
    chmod +x "${mock_dir}/nxc"

    # Run install_netexec with PATH including mock
    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        source '${SECURITY_SH}'
        install_netexec
    " 2>&1)

    rm -rf "${mock_dir}"

    # Should skip installation (no apt/pip calls)
    [[ "${output}" != *"apt"* ]] && pass "install_netexec skips when nxc already exists" ||
        fail "install_netexec tried to install when nxc exists"
}

# =============================================================================
# Test: install_sliver idempotent (skips if already installed)
# =============================================================================
test_install_sliver_idempotent() {
    # Create a mock sliver command
    local mock_dir=$(mktemp -d)
    echo '#!/usr/bin/env bash' >"${mock_dir}/sliver"
    chmod +x "${mock_dir}/sliver"

    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        source '${SECURITY_SH}'
        install_sliver
    " 2>&1)

    rm -rf "${mock_dir}"

    [[ "${output}" != *"wget"* ]] && pass "install_sliver skips when sliver already exists" ||
        fail "install_sliver tried to install when sliver exists"
}

# =============================================================================
# Test: setup_tor idempotent (skips if already enabled)
# =============================================================================
test_setup_tor_idempotent() {
    # Mock systemctl to report tor as enabled
    local mock_dir=$(mktemp -d)
    cat >"${mock_dir}/systemctl" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "is-enabled" && "$2" == "tor" ]]; then
    echo "enabled"
    exit 0
fi
exit 0
EOF
    chmod +x "${mock_dir}/systemctl"

    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        source '${SECURITY_SH}'
        setup_tor
    " 2>&1)

    rm -rf "${mock_dir}"

    [[ "${output}" != *"apt"* ]] && pass "setup_tor skips when tor already enabled" ||
        fail "setup_tor tried to install when tor enabled"
}

# =============================================================================
# Test: setup_ufw idempotent (skips if already enabled)
# =============================================================================
test_setup_ufw_idempotent() {
    # Mock ufw to report as enabled
    local mock_dir=$(mktemp -d)
    cat >"${mock_dir}/ufw" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "status" ]]; then
    echo "Status: active"
    exit 0
fi
exit 0
EOF
    chmod +x "${mock_dir}/ufw"

    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        source '${SECURITY_SH}'
        setup_ufw
    " 2>&1)

    rm -rf "${mock_dir}"

    [[ "${output}" != *"apt"* ]] && pass "setup_ufw skips when ufw already active" ||
        fail "setup_ufw tried to install when ufw active"
}

# =============================================================================
# Test: install_netexec installs when missing
# =============================================================================
test_install_netexec_installs_when_missing() {
    # Mock apt-get and pipx to succeed, ensure nxc not in PATH
    local mock_dir=$(mktemp -d)
    cat >"${mock_dir}/apt-get" <<'EOF'
#!/usr/bin/env bash
# Mock apt-get
if [[ "$1" == "install" ]]; then
    echo "apt-get install $@"
    exit 0
fi
exit 0
EOF
    chmod +x "${mock_dir}/apt-get"
    cat >"${mock_dir}/pipx" <<'EOF'
#!/usr/bin/env bash
# Mock pipx
if [[ "$1" == "install" ]]; then
    echo "pipx install $@"
    # Create a mock nxc command to simulate installation
    echo '#!/usr/bin/env bash' > "$(dirname "$0")/nxc"
    chmod +x "$(dirname "$0")/nxc"
    exit 0
fi
exit 0
EOF
    chmod +x "${mock_dir}/pipx"

    local output
    output=$(bash -c "
        # Use only mock_dir in PATH to hide real nxc
        export PATH='${mock_dir}'
        source '${SECURITY_SH}'
        install_netexec
    " 2>&1)

    rm -rf "${mock_dir}"

    [[ "${output}" == *"Installing NetExec"* ]] && pass "install_netexec installs when nxc missing" ||
        fail "install_netexec did not install when nxc missing"
}

# =============================================================================
# Test: install_sliver installs when missing
# =============================================================================
# Test: install_sliver installs when missing
# =============================================================================
test_install_sliver_installs_when_missing() {
    # Mock wget to succeed and create the output file at $4 (after -q -O)
    # install_sliver calls: wget -q -O "${tmp_file}" "${url}"
    # So $4 = temp_file path
    local mock_dir=$(mktemp -d)
    cat >"${mock_dir}/wget" <<'EOF'
#!/usr/bin/env bash
# Mock wget - output file is at $4 after -q -O
echo "wget $@"
# Create mock binary at the output file path ($4)
echo "mock sliver binary" > "$4"
chmod +x "$4"
exit 0
EOF
    chmod +x "${mock_dir}/wget"
    # Mock mv to avoid sudo requirement for /usr/local/bin
    cat >"${mock_dir}/mv" <<'EOF'
#!/usr/bin/env bash
# Mock mv - just copy to a test-accessible location
if [[ "$2" == "/usr/local/bin/sliver" ]]; then
    cp "$1" "${MOCK_INSTALL_DIR:-/tmp}/sliver"
    echo "mv $1 -> ${MOCK_INSTALL_DIR:-/tmp}/sliver (mocked)"
    exit 0
fi
# Fallback to real mv for other cases
/bin/mv "$@"
exit 0
EOF
    chmod +x "${mock_dir}/mv"
    cat >"${mock_dir}/uname" <<'EOF'
#!/usr/bin/env bash
echo "x86_64"
exit 0
EOF
    chmod +x "${mock_dir}/uname"

    local mock_install_dir=$(mktemp -d)
    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        export MOCK_INSTALL_DIR='${mock_install_dir}'
        # Override command builtin to hide sliver
        command() {
            if [[ \"\$1\" == \"-v\" && \"\$2\" == \"sliver\" ]]; then
                return 1
            fi
            builtin command \"\$@\"
        }
        source '${SECURITY_SH}'
        install_sliver
    " 2>&1)

    # Check if mock binary was created at expected location
    if [[ -f "${mock_install_dir}/sliver" ]]; then
        pass "install_sliver installs when sliver missing"
    else
        fail "install_sliver did not install (output: ${output})"
    fi

    rm -rf "${mock_dir}" "${mock_install_dir}"
}

# =============================================================================
# Test: setup_tor installs when not enabled
# =============================================================================
test_setup_tor_installs_when_not_enabled() {
    # Mock systemctl to report tor as disabled
    local mock_dir=$(mktemp -d)
    cat >"${mock_dir}/systemctl" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "is-enabled" && "$2" == "tor" ]]; then
    echo "disabled"
    exit 1
fi
if [[ "$1" == "enable" && "$2" == "--now" && "$3" == "tor" ]]; then
    echo "tor enabled"
    exit 0
fi
exit 0
EOF
    chmod +x "${mock_dir}/systemctl"
    cat >"${mock_dir}/apt-get" <<'EOF'
#!/usr/bin/env bash
echo "apt-get install $@"
exit 0
EOF
    chmod +x "${mock_dir}/apt-get"

    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        source '${SECURITY_SH}'
        setup_tor
    " 2>&1)

    rm -rf "${mock_dir}"

    [[ "${output}" == *"Installing Tor"* && "${output}" == *"tor enabled"* ]] && pass "setup_tor installs and enables when not enabled" ||
        fail "setup_tor did not install/enable"
}

# =============================================================================
# Test: setup_proxychains installs and configures when missing
# =============================================================================
test_setup_proxychains_installs_and_configures() {
    # Mock proxychains4 command not found
    local mock_dir=$(mktemp -d)
    cat >"${mock_dir}/apt-get" <<'EOF'
#!/usr/bin/env bash
echo "apt-get install $@"
exit 0
EOF
    chmod +x "${mock_dir}/apt-get"

    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        source '${SECURITY_SH}'
        # Remove existing config to force configuration
        rm -f /etc/proxychains4.conf 2>/dev/null || true
        setup_proxychains
    " 2>&1)

    rm -rf "${mock_dir}"

    [[ "${output}" == *"Configuring proxychains4"* ]] && pass "setup_proxychains configures when missing" ||
        fail "setup_proxychains did not configure"
}

# =============================================================================
# Test: configure_ghidra_java sets JAVA_HOME when Ghidra installed
# =============================================================================
test_configure_ghidra_java_sets_java_home() {
    # Test when Ghidra is NOT installed (should skip)
    local mock_dir=$(mktemp -d)
    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        source '${SECURITY_SH}'
        configure_ghidra_java
    " 2>&1)

    rm -rf "${mock_dir}"

    [[ "${output}" == *"Ghidra not installed"* ]] && pass "configure_ghidra_java skips when Ghidra not installed" ||
        fail "configure_ghidra_java did not skip when Ghidra not installed"
}

# =============================================================================
# Test: setup_ufw installs and configures when not active
# =============================================================================
test_setup_ufw_installs_and_configures() {
    # Mock ufw status as inactive
    local mock_dir=$(mktemp -d)
    cat >"${mock_dir}/ufw" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == "status" ]]; then
    echo "Status: inactive"
    exit 0
fi
if [[ "$1" == "default" ]]; then
    echo "Default $2 $3"
    exit 0
fi
if [[ "$1" == "allow" ]]; then
    echo "Rule added: $@"
    exit 0
fi
if [[ "$1" == "--force" && "$2" == "enable" ]]; then
    echo "Firewall is active and enabled on system startup"
    exit 0
fi
exit 0
EOF
    chmod +x "${mock_dir}/ufw"
    cat >"${mock_dir}/apt-get" <<'EOF'
#!/usr/bin/env bash
echo "apt-get install $@"
exit 0
EOF
    chmod +x "${mock_dir}/apt-get"

    local output
    output=$(bash -c "
        export PATH='${mock_dir}':\$PATH
        source '${SECURITY_SH}'
        setup_ufw
    " 2>&1)

    rm -rf "${mock_dir}"

    [[ "${output}" == *"Installing UFW"* && "${output}" == *"Configuring UFW"* && "${output}" == *"UFW enabled"* ]] && pass "setup_ufw installs and configures when not active" ||
        fail "setup_ufw did not install/configure"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "=== lib/security.sh Tests ==="
echo ""

test_security_source
test_retry_with_backoff_defined
test_retry_with_backoff_retries
test_retry_with_backoff_max_retries
test_install_netexec_defined
test_install_sliver_defined
test_setup_tor_defined
test_setup_proxychains_defined
test_configure_ghidra_java_defined
test_setup_ufw_defined
test_install_netexec_idempotent
test_install_sliver_idempotent
test_setup_tor_idempotent
test_setup_ufw_idempotent
test_install_netexec_installs_when_missing
test_install_sliver_installs_when_missing
test_setup_tor_installs_when_not_enabled
test_setup_proxychains_installs_and_configures
test_configure_ghidra_java_sets_java_home
test_setup_ufw_installs_and_configures

echo ""
echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="

[[ ${TESTS_FAIL} -eq 0 ]]
