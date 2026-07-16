#!/usr/bin/env bash
# =============================================================================
# tests/lib/test-helpers.sh — Shared test boilerplate
# =============================================================================
# Source this file at the top of each test file to get:
#   pass(), fail(), color constants, counter variables
# =============================================================================

# Test counters
TESTS_RUN=0
TESTS_PASS=0
TESTS_FAIL=0

# Colors for output
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
