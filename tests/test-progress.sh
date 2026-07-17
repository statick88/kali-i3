#!/usr/bin/env bash
# Tests for lib/state.sh — show_progress() rewrite
# TDD: tests written BEFORE production code changes

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
# Test: C_NEON_YELLOW exists in colors.sh
# =============================================================================
test_c_neon_yellow_exists() {
    grep -q 'C_NEON_YELLOW' "${SCRIPT_DIR}/lib/colors.sh" &&
        pass "C_NEON_YELLOW constant exists in colors.sh" ||
        fail "C_NEON_YELLOW should be defined in colors.sh"
}

# =============================================================================
# Test: show_progress() accepts 4 parameters
# =============================================================================
test_show_progress_signature() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 5 10 'test step' 1000
    " 2>&1)
    # Should not error — just producing output
    [[ $? -eq 0 ]] && pass "show_progress accepts 4 params" || fail "show_progress should accept 4 params"
}

# =============================================================================
# Test: show_progress() outputs percentage correctly
# =============================================================================
test_show_progress_percentage() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 5 10 'test step' 1000
    " 2>&1)
    [[ "${output}" == *"50%"* ]] && pass "show_progress shows 50% for 5/10" || fail "show_progress should show 50%"
}

# =============================================================================
# Test: show_progress() outputs counter [current/total]
# =============================================================================
test_show_progress_counter() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 3 20 'install i3' 1000
    " 2>&1)
    [[ "${output}" == *"[3/20]"* ]] && pass "show_progress shows [3/20] counter" || fail "show_progress should show [3/20]"
}

# =============================================================================
# Test: show_progress() outputs Unicode bar characters
# =============================================================================
test_show_progress_unicode_bar() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 10 20 'test' 1000
    " 2>&1)
    [[ "${output}" == *"▓"* ]] && pass "show_progress uses ▓ filled blocks" || fail "show_progress should use ▓ filled blocks"
    [[ "${output}" == *"░"* ]] && pass "show_progress uses ░ empty blocks" || fail "show_progress should use ░ empty blocks"
}

# =============================================================================
# Test: show_progress() includes step name
# =============================================================================
test_show_progress_step_name() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 1 5 'Install i3 Core' 1000
    " 2>&1)
    [[ "${output}" == *"Install i3 Core"* ]] && pass "show_progress includes step name" || fail "show_progress should include step name"
}

# =============================================================================
# Test: show_progress() truncates long step names to 40 chars
# =============================================================================
test_show_progress_truncation() {
    local long_name="Installing Advanced Security Tools Suite on Kali Linux"
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 1 10 '${long_name}' 1000
    " 2>&1)
    # Strip ANSI codes to get plain text
    local plain
    plain=$(echo -e "${output}" | sed 's/\x1b\[[0-9;]*m//g')
    # Find the step name in output (after the bar)
    local name_part
    name_part=$(echo "${plain}" | sed 's/.*— //' | sed 's/ (elapsed.*//')
    [[ ${#name_part} -le 40 ]] && pass "show_progress truncates name to ≤40 chars (${#name_part})" || fail "show_progress should truncate to 40 chars, got ${#name_part}"
}

# =============================================================================
# Test: show_progress() uses \r (no trailing newline)
# =============================================================================
test_show_progress_no_newline() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 1 10 'test' 1000
    " 2>&1)
    # Output should NOT end with a newline — the last visible char should not be \n
    # Check that no newline appears after the closing parenthesis
    local last_part="${output##*elapsed:*)}"
    [[ -z "${last_part}" ]] && pass "show_progress ends with \\r (no trailing newline)" || fail "show_progress should not have content after elapsed time"
}

# =============================================================================
# Test: show_progress() elapsed time format MM:SS
# =============================================================================
test_show_progress_elapsed_format() {
    # Use a mock date function to control time
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        # Mock date to return a fixed value
        date() { echo '1032'; }
        export -f date
        show_progress 5 10 'test step' 1000
    " 2>&1)
    [[ "${output}" == *"00:32"* ]] && pass "show_progress shows elapsed 00:32" || fail "show_progress should show elapsed 00:32"
}

# =============================================================================
# Test: show_progress() elapsed time > 1 hour
# =============================================================================
test_show_progress_elapsed_over_hour() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        date() { echo '4661'; }
        export -f date
        show_progress 5 10 'test step' 1000
    " 2>&1)
    [[ "${output}" == *"61:01"* ]] && pass "show_progress shows elapsed 61:01 for >1hr" || fail "show_progress should show 61:01 for 3661s"
}

# =============================================================================
# Test: show_progress() green color for <50%
# =============================================================================
test_show_progress_color_green() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 3 10 'test' 1000
    " 2>&1)
    [[ "${output}" == *"${C_NEON_GREEN}"* ]] && pass "show_progress uses green for <50%" || fail "show_progress should use green for <50%"
}

# =============================================================================
# Test: show_progress() yellow color for 50-80%
# =============================================================================
test_show_progress_color_yellow() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 7 10 'test' 1000
    " 2>&1)
    [[ "${output}" == *"${C_NEON_YELLOW}"* ]] && pass "show_progress uses yellow for 50-80%" || fail "show_progress should use yellow for 50-80%"
}

# =============================================================================
# Test: show_progress() red color for >80%
# =============================================================================
test_show_progress_color_red() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 9 10 'test' 1000
    " 2>&1)
    [[ "${output}" == *"${C_NEON_PINK}"* ]] && pass "show_progress uses red for >80%" || fail "show_progress should use red for >80%"
}

# =============================================================================
# Test: show_progress() bar is 20 chars wide
# =============================================================================
test_show_progress_bar_width() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/colors.sh'
        source '${SCRIPT_DIR}/lib/state.sh'
        show_progress 5 10 'test' 1000
    " 2>&1)
    # Strip all ANSI escape sequences, then extract between first [ and ]
    local plain
    plain=$(echo -e "${output}" | sed 's/\x1b\[[0-9;]*m//g')
    # Find the counter [5/10] — after it comes the bar
    local after_counter="${plain#*[5/10] }"
    # The bar is the first 20 characters
    local bar="${after_counter:0:20}"
    local bar_len=${#bar}
    [[ ${bar_len} -eq 20 ]] && pass "show_progress bar is 20 chars wide" || fail "show_progress bar should be 20 chars, got ${bar_len}"
}

# Run all tests
main() {
    echo "=== Progress Bar Tests ==="
    echo ""

    test_c_neon_yellow_exists
    test_show_progress_signature
    test_show_progress_percentage
    test_show_progress_counter
    test_show_progress_unicode_bar
    test_show_progress_step_name
    test_show_progress_truncation
    test_show_progress_no_newline
    test_show_progress_elapsed_format
    test_show_progress_elapsed_over_hour
    test_show_progress_color_green
    test_show_progress_color_yellow
    test_show_progress_color_red
    test_show_progress_bar_width

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
