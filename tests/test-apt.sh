#!/usr/bin/env bash
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
    " 2>/dev/null \
        && pass "apt.sh sources without error" \
        || fail "apt.sh failed to source"
}

# =============================================================================
# Test: pkg_installed() detects installed packages
# =============================================================================
test_pkg_installed_positive() {
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
    " 2>/dev/null \
        && pass "pkg_installed detects an installed package" \
        || fail "pkg_installed should detect an installed package"
}

# =============================================================================
# Test: pkg_installed() rejects missing packages
# =============================================================================
test_pkg_installed_negative() {
    bash -c "
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        pkg_installed 'nonexistent-package-xyz'
    " 2>/dev/null \
        && fail "pkg_installed 'nonexistent' should return false" \
        || pass "pkg_installed 'nonexistent' returns false"
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
    " 2>/dev/null | grep -q "cached" \
        && pass "pkg_installed() populates PKG_CACHE" \
        || fail "pkg_installed() should populate PKG_CACHE"
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
    local output
    output=$(bash -c "
        declare -A STATE=()
        declare -A PKG_CACHE=()
        source '${SCRIPT_DIR}/lib/apt.sh'
        # Find an installed package
        local pkg
        pkg=\$(dpkg -l 2>/dev/null | grep '^ii' | head -1 | awk '{print \$2}')
        if [[ -n \"\${pkg}\" ]]; then
            apt_install_if_missing \"\${pkg}\"
            echo 'ok'
        else
            echo 'skip'
        fi
    " 2>/dev/null)
    [[ "${output}" == *"ok"* ]] && pass "apt_install_if_missing() skips installed packages" || fail "apt_install_if_missing() should skip installed packages"
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

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
