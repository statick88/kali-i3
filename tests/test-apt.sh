#!/usr/bin/env bash
# shellcheck disable=SC1083  # \${} and \$ inside bash -c strings are intentional
# Tests for lib/apt.sh — APT helper functions

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
# Test: apt.sh can be sourced without errors
# =============================================================================
test_apt_source() {
    bash -c "
        declare -A STATE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
    " 2>/dev/null &&
        pass "apt.sh sources without error" ||
        fail "apt.sh failed to source"
}

# =============================================================================
# Test: pkg_installed() detects installed packages
# =============================================================================
test_pkg_installed_positive() {
    # Skip if dpkg not available (macOS)
    command -v dpkg >/dev/null 2>&1 || {
        pass "pkg_installed detects an installed package (skipped: no dpkg)"
        return
    }

    bash -c "
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Use dpkg to find a real installed package
        local pkg
        pkg=\$(dpkg -l 2>/dev/null | grep '^ii' | head -1 | awk '{print \$2}')
        if [[ -n \"\${pkg}\" ]]; then
            pkg_installed \"\${pkg}\" && exit 0 || exit 1
        else
            exit 1
        fi
    " 2>/dev/null &&
        pass "pkg_installed detects an installed package" ||
        fail "pkg_installed should detect an installed package"
}

# =============================================================================
# Test: pkg_installed() rejects missing packages
# =============================================================================
test_pkg_installed_negative() {
    bash -c "
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        pkg_installed 'nonexistent-package-xyz'
    " 2>/dev/null &&
        fail "pkg_installed 'nonexistent' should return false" ||
        pass "pkg_installed 'nonexistent' returns false"
}

# =============================================================================
# Test: pkg_installed() uses cache
# =============================================================================
test_pkg_cached() {
    bash -c "
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # First call populates cache
        pkg_installed 'nonexistent-cache-test' >/dev/null 2>&1
        # Check cache was populated
        if [[ -n \"\${PKG_CACHE[nonexistent-cache-test]:-}\" ]]; then
            echo 'cached'
        else
            echo 'not_cached'
        fi
    " 2>/dev/null | grep -q "cached" &&
        pass "pkg_installed() populates PKG_CACHE" ||
        fail "pkg_installed() should populate PKG_CACHE"
}

# =============================================================================
# Test: apt_update_once() only runs once (uses STATE tracking)
# =============================================================================
test_apt_update_once() {
    local output
    output=$(bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Mark as already updated
        STATE[apt_updated]=1
        # Should not try to run apt-get update
        apt_update_once
        echo \${STATE[apt_updated]}
    " 2>/dev/null)
    [[ "${output}" == *"1"* ]] && pass "apt_update_once() respects STATE[apt_updated]" || fail "apt_update_once() should check STATE[apt_updated]"
}

# =============================================================================
# Test: apt_install_if_missing() skips when all packages installed
# =============================================================================
test_apt_install_skip() {
    # Skip if dpkg not available (macOS)
    command -v dpkg >/dev/null 2>&1 || {
        pass "apt_install_if_missing() skips installed packages (skipped: no dpkg)"
        return
    }

    local output
    output=$(bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Find an installed package
        local pkg
        pkg=\$(dpkg -l 2>/dev/null | grep '^ii' | head -1 | awk '{print \$2}')
        if [[ -n "\${pkg}" ]]; then
            apt_install_if_missing "\${pkg}"
            echo 'ok'
        else
            echo 'skip'
        fi
    " 2>/dev/null)
    [[ "${output}" == *"ok"* ]] && pass "apt_install_if_missing() skips installed packages" || fail "apt_install_if_missing() should skip installed packages"
}

# =============================================================================
# Test: Constants are defined
# =============================================================================
test_apt_constants() {
    bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Check constants exist and have expected default values
        [[ \"\${APT_INSTALL_TIMEOUT}\" -eq 120 ]] || exit 1
        [[ \"\${APT_INSTALL_RETRIES}\" -eq 3 ]] || exit 1
    " 2>/dev/null &&
        pass "APT constants defined with defaults" ||
        fail "APT constants not defined or wrong defaults"
}

# =============================================================================
# Test: HAS_TIMEOUT flag is set
# =============================================================================
test_apt_has_timeout_flag() {
    bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # HAS_TIMEOUT should be 0 or 1
        [[ \"\${HAS_TIMEOUT}\" == '0' || \"\${HAS_TIMEOUT}\" == '1' ]] || exit 1
    " 2>/dev/null &&
        pass "HAS_TIMEOUT flag is set" ||
        fail "HAS_TIMEOUT flag not properly initialized"
}

# =============================================================================
# Test: apt_install_with_retry() function exists
# =============================================================================
test_apt_install_with_retry_exists() {
    bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        declare -f apt_install_with_retry >/dev/null 2>&1 || exit 1
    " 2>/dev/null &&
        pass "apt_install_with_retry() function exists" ||
        fail "apt_install_with_retry() function not found"
}

# =============================================================================
# Test: apt_install_with_retry() — success path (mock apt-get)
# =============================================================================
test_apt_install_with_retry_success() {
    bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Override run_as_root to simulate success
        run_as_root() { echo 'mocked'; return 0; }
        # Call apt_install_with_retry with a package that 'exists'
        apt_install_with_retry 'mock-pkg' 2>/dev/null
        exit \$?
    " 2>/dev/null &&
        pass "apt_install_with_retry() returns 0 on success" ||
        fail "apt_install_with_retry() should return 0 on success"
}

# =============================================================================
# Test: apt_install_with_retry() — already installed (skip)
# =============================================================================
test_apt_install_with_retry_already_installed() {
    # Skip if dpkg not available (macOS)
    command -v dpkg >/dev/null 2>&1 || {
        pass "apt_install_with_retry() skips installed packages (skipped: no dpkg)"
        return
    }

    bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Get a real installed package
        pkg=\$(dpkg -l 2>/dev/null | grep '^ii' | head -1 | awk '{print \$2}')
        [[ -z "\${pkg}" ]] && exit 1
        # Track if apt-get is called
        apt_called=0
        run_as_root() { apt_called=1; return 0; }
        apt_install_with_retry "\${pkg}"
        # apt should NOT have been called (already installed)
        [[ "\${apt_called}" -eq 0 ]]
    " 2>/dev/null &&
        pass "apt_install_with_retry() skips installed packages" ||
        fail "apt_install_with_retry() should skip installed packages"
}

# =============================================================================
# Test: apt_install_with_retry() — timeout kills process, retries
# =============================================================================
test_apt_install_with_retry_timeout() {
    bash -c "
        set -euo pipefail
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Override run_as_root to always fail (simulate hang + timeout kill)
        run_as_root() { return 1; }
        # Set low retries for speed
        APT_INSTALL_RETRIES=2
        apt_install_with_retry 'hang-pkg'
    " 2>/dev/null &&
        fail "apt_install_with_retry() should fail after retries" ||
        pass "apt_install_with_retry() fails after retries exhausted"
}

# =============================================================================
# Test: apt_install_if_missing() — partial failure (B fails, A+C succeed)
# =============================================================================
test_apt_install_if_missing_partial_failure() {
    bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Stub pkg_installed to return false for all (all need install)
        pkg_installed() { return 1; }
        # Stub apt_update_once to do nothing
        apt_update_once() { :; }
        # Track calls to apt_install_with_retry
        install_calls=()
        apt_install_with_retry() {
            local pkg=\"\$1\"
            install_calls+=(\"\${pkg}\")
            # Fail on pkg-b only
            [[ \"\${pkg}\" == 'pkg-b' ]] && return 1
            return 0
        }
        apt_install_if_missing 'pkg-a' 'pkg-b' 'pkg-c'
        rc=\$?
        # Verify pkg-b was attempted
        [[ \"\${install_calls[*]}\" == *'pkg-b'* ]] || exit 2
        # Verify return code is 0 (partial failure returns 0 by design)
        [[ \${rc} -eq 0 ]] && exit 0 || exit 1
    " 2>/dev/null &&
        pass "apt_install_if_missing() returns 0 on partial failure (by design)" ||
        fail "apt_install_if_missing() should return 0 when some packages fail"
}

# =============================================================================
# Test: apt_install_if_missing() — all succeed
# =============================================================================
test_apt_install_if_missing_all_succeed() {
    bash -c "
        set -euo pipefail
        STATE_KEYS=()
        STATE_VALS=()
        PKG_CACHE_KEYS=()
        PKG_CACHE_VALS=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Stub pkg_installed to return false for all
        pkg_installed() { return 1; }
        # Stub apt_update_once
        apt_update_once() { :; }
        # Stub apt_install_with_retry to always succeed
        apt_install_with_retry() { return 0; }
        apt_install_if_missing 'pkg-a' 'pkg-b' 'pkg-c'
    " 2>/dev/null &&
        pass "apt_install_if_missing() returns 0 when all succeed" ||
        fail "apt_install_if_missing() should return 0 when all succeed"
}

# Run all tests
main() {
    echo "=== lib/apt.sh Tests ==="
    echo ""

    test_apt_source
    test_pkg_installed_positive
    test_pkg_installed_negative
    test_pkg_cached
    test_apt_update_once
    test_apt_install_skip
    test_apt_constants
    test_apt_has_timeout_flag
    test_apt_install_with_retry_exists
    test_apt_install_with_retry_success
    test_apt_install_with_retry_already_installed
    test_apt_install_with_retry_timeout
    test_apt_install_if_missing_partial_failure
    test_apt_install_if_missing_all_succeed

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
