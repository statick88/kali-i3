#!/usr/bin/env bash
# Unit tests for setup_i3_kali.sh functions

# Source shared test helpers
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

# =============================================================================
# Test: pkg_installed() - Returns 0/1 correctly
# =============================================================================
test_pkg_installed() {
    pkg_installed() {
        dpkg -l "$1" 2>/dev/null | grep -q '^ii'
    }

    pkg_installed "nonexistent-package-xyz" || pass "pkg_installed returns non-zero for missing package" || fail "pkg_installed should return non-zero for missing package"
}

# =============================================================================
# Test: cmd_exists() - Detects commands correctly
# =============================================================================
test_cmd_exists() {
    cmd_exists() {
        command -v "$1" >/dev/null 2>&1
    }

    cmd_exists "ls" && pass "cmd_exists finds 'ls'" || fail "cmd_exists should find 'ls'"
    cmd_exists "nonexistent-command-xyz" || pass "cmd_exists returns false for missing command" || fail "cmd_exists should return false for missing command"
}

# =============================================================================
# Test: write_file_if_missing() - Creates file only if missing
# =============================================================================
test_file_functions() {
    write_file_if_missing() {
        local dest="$1"
        local content="$2"
        local perms="${3:-644}"
        [[ -f "${dest}" ]] && return 0
        mkdir -p "$(dirname "${dest}")" 2>/dev/null || true
        printf "%s" "${content}" >"${dest}"
        chmod "${perms}" "${dest}" 2>/dev/null || true
    }

    local tmpfile="/tmp/test_write_file_$$"

    rm -f "${tmpfile}" 2>/dev/null || true
    write_file_if_missing "${tmpfile}" "test content" "644" || true
    [[ -f "${tmpfile}" ]] && [[ "$(cat "${tmpfile}" 2>/dev/null)" == "test content" ]] && pass "write_file_if_missing creates file" || fail "write_file_if_missing should create file"

    local first_content
    first_content=$(cat "${tmpfile}" 2>/dev/null)
    write_file_if_missing "${tmpfile}" "new content" "644" || true
    local second_content
    second_content=$(cat "${tmpfile}" 2>/dev/null)
    [[ "${first_content}" == "${second_content}" ]] && pass "write_file_if_missing does not overwrite existing file" || fail "write_file_if_missing should not overwrite existing file"

    rm -f "${tmpfile}" 2>/dev/null || true
}

# =============================================================================
# Test: state functions (load/save/is_completed/mark_completed)
# =============================================================================
test_state_functions() {
    COMPLETED_STEPS=()

    is_completed() {
        [[ "${COMPLETED_STEPS[$1]:-0}" -eq 1 ]]
    }

    mark_completed() {
        COMPLETED_STEPS["$1"]=1
    }

    is_completed "nonexistent_step" || pass "is_completed returns false for nonexistent step" || fail "is_completed should return false for nonexistent step"

    mark_completed "step_test_one"
    [[ "${COMPLETED_STEPS[step_test_one]:-0}" -eq 1 ]] && pass "mark_completed sets step in COMPLETED_STEPS" || fail "mark_completed should set step in COMPLETED_STEPS"
}

# =============================================================================
# Test: show_progress() - Outputs correctly
# =============================================================================
test_progress_bar() {
    C_NEON_PINK='\033[38;5;206m'
    C_NEON_GREEN='\033[38;5;48m'
    C_NEON_CYAN='\033[38;5;51m'
    C_RESET='\033[0m'

    show_progress() {
        local current=$1
        local total=$2
        local label="${3:-$1}"
        local percent=$((current * 100 / total))
        printf "\r${C_NEON_PINK}[${C_NEON_GREEN}%s${C_NEON_PINK}]${C_NEON_CYAN} %3d%%${C_RESET} - %s\n" "█████" "${percent}" "${label}"
    }

    local output
    output=$(show_progress 5 10 "test step" 2>&1)
    [[ -n "${output}" ]] && pass "show_progress produces output" || fail "show_progress should produce output"
    [[ "${output}" == *"50%"* ]] && pass "show_progress shows correct percentage" || fail "show_progress should show 50%"
}

# Run all tests
main() {
    echo "=== Unit Tests ==="
    echo ""

    test_pkg_installed
    test_cmd_exists
    test_file_functions
    test_state_functions
    test_progress_bar

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
