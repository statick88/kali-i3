#!/usr/bin/env bash
# Test runner - executes all tests with reporting

set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

LOG_FILE="/tmp/kali-i3-test-report-$$"

# Global counters
GRAND_PASS=0
GRAND_FAIL=0

run_test_file() {
    local test_file="$1"
    local tmpout="/tmp/test-output-$$"

    echo ""
    echo -e "${BOLD}${BLUE}=== Running: $(basename "${test_file}") ===${NC}"
    echo ""

    # Run in subshell to capture exit code properly
    (bash "${test_file}" 2>&1 || true) >"${tmpout}"
    cat "${tmpout}"

    # Count results (ANSI color codes may appear between PASS/FAIL and :)
    local passed failed
    passed=$(grep -cP 'PASS.*?:' "${tmpout}" 2>/dev/null)
    passed=${passed:-0}
    failed=$(grep -cP 'FAIL.*?:' "${tmpout}" 2>/dev/null)
    failed=${failed:-0}

    GRAND_PASS=$((GRAND_PASS + passed))
    GRAND_FAIL=$((GRAND_FAIL + failed))

    rm -f "${tmpout}"
}

main() {
    echo "Starting test run..." | tee "${LOG_FILE}"
    echo "Report will be saved to: ${LOG_FILE}"

    local tests_dir
    tests_dir="$(cd "$(dirname "$0")" && pwd)"

    # Run all test files
    for test_file in "${tests_dir}"/test-*.sh; do
        [[ -f "${test_file}" ]] && run_test_file "${test_file}"
    done

    echo ""
    echo "========================================" | tee -a "${LOG_FILE}"
    echo -e "${BOLD}FINAL RESULTS${NC}" | tee -a "${LOG_FILE}"
    echo "========================================" | tee -a "${LOG_FILE}"
    echo -e "Passed: ${GREEN}${GRAND_PASS}${NC}" | tee -a "${LOG_FILE}"
    echo -e "Failed: ${RED}${GRAND_FAIL}${NC}" | tee -a "${LOG_FILE}"

    [[ ${GRAND_FAIL} -eq 0 ]]
}

main "$@"
