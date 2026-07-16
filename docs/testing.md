# Testing

The project includes **27 test files** covering library unit tests, integration tests, and VM-based validation.

## Test Structure

```
tests/
├── run-tests.sh                    # Main test runner
├── lib/test-helpers.sh             # Shared assertion utilities
├── test-common.sh                  # lib/common.sh tests
├── test-colors.sh                  # lib/colors.sh tests
├── test-state.sh                   # lib/state.sh (checkpoint persistence)
├── test-i18n.sh                    # lib/i18n.sh (EN/ES)
├── test-apt.sh                     # lib/apt.sh (package management)
├── test-user.sh                    # lib/user.sh (user detection)
├── test-ssh.sh                     # lib/ssh.sh (SSH connections)
├── test-screenshot.sh              # lib/screenshot.sh (capture)
├── test-interactive.sh             # lib/interactive.sh (category selection)
├── test-skip-flags.sh              # CLI flag parsing
├── test-progress.sh                # Progress tracking
├── test-sddm-theme.sh              # SDDM theme deployment
├── test-integration.sh             # Full pipeline integration tests
├── test-unit.sh                    # Library unit tests (aggregated)
├── test-theme.sh                   # Theme color consistency
├── test-purge-xfce.sh              # XFCE removal tests
├── test-approval-setup.sh          # Approval-based setup tests
├── test-approval-purge.sh          # Approval-based purge tests
├── test-arsenal.sh                 # Security tool arsenal verification
├── vm/
│   ├── run.sh                      # VM test execution wrapper
│   ├── config.sh                   # VM connection configuration
│   └── lib/
│       ├── ssh-connect.sh          # SSH connection helpers for VM
│       └── ...                     # Additional VM test utilities
```

## Running Tests

### Run all tests

```bash
cd kali-i3
bash tests/run-tests.sh
```

Output:

```
[TEST] test-common.sh
[PASS] test-common: info function outputs correctly
[PASS] test-common: ok function outputs correctly
[PASS] test-common: err function outputs correctly
...
──────────────────────
Total: 45   Passed: 43   Failed: 2
```

### Run a single test file

```bash
bash tests/test-common.sh
```

### Run VM tests (requires running VM)

```bash
# Configure VM connection in tests/vm/config.sh
bash tests/vm/run.sh
```

## Test Helpers

`tests/lib/test-helpers.sh` provides shared assertion functions:

```bash
assert_eq "expected" "actual" "description"
assert_contains "substring" "string" "description"
assert_file_exists "/path/to/file" "description"
assert_file_not_exists "/path/to/file" "description"
assert_dir_exists "/path/to/dir" "description"
assert_success "command" "description"
assert_failure "command" "description"
pass "description"    # Mark test as passed
fail "description"    # Mark test as failed
```

## Test Categories

### Unit Tests

Test individual library functions in isolation:

| Test File | Tests |
|-----------|-------|
| `test-common.sh` | Logging functions, assertion helpers, utility functions |
| `test-colors.sh` | Color variable definitions, palette consistency |
| `test-state.sh` | Checkpoint init, mark done, save/load, resume |
| `test-i18n.sh` | Message translation (EN/ES), language switching |
| `test-apt.sh` | Package caching, retry logic, timeout handling |
| `test-user.sh` | User detection, run_as_user, run_as_root |

### Integration Tests

Test multiple modules working together:

| Test File | Tests |
|-----------|-------|
| `test-integration.sh` | Full phase execution, checkpoint resume, error recovery |
| `test-skip-flags.sh` | CLI flag parsing, phase skipping behavior |
| `test-progress.sh` | Progress tracking across phases |
| `test-interactive.sh` | Category selection, user input handling |

### Theme Tests

Verify visual consistency:

| Test File | Tests |
|-----------|-------|
| `test-theme.sh` | Color values match across i3, tmux, SDDM configs |
| `test-sddm-theme.sh` | SDDM theme files exist and are valid |

### Security Arsenal Tests

Verify security tools are installed:

| Test File | Tests |
|-----------|-------|
| `test-arsenal.sh` | Tool binaries exist and are callable (nmap, masscan, etc.) |

### VM Tests

Run inside a virtual machine via SSH:

| Test File | Tests |
|-----------|-------|
| `vm/run.sh` | VM connectivity, full install on clean VM, screenshot validation |

## Writing New Tests

Create a new file `tests/test-feature.sh`:

```bash
#!/usr/bin/env bash
# =============================================================================
# tests/test-feature.sh — Tests for new feature
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

# Source dependencies
source "${LIB_DIR}/common.sh"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

# Test: feature does X
test_feature_does_x() {
    local result
    result=$(feature_function "input")
    assert_eq "expected_output" "${result}" "feature_function returns correct output"
}

# Run all tests
main() {
    test_feature_does_x
}

main
```

Make it executable: `chmod +x tests/test-feature.sh`

## CI/CD

Tests run automatically on every push via GitHub Actions. The workflow:

1. Checkout code
2. Run `tests/run-tests.sh`
3. If any test fails, the build fails
4. VM tests run on a scheduled basis (weekly)

## Test Metrics

The test runner outputs metrics in JSON format when `METRICS_OUTPUT` is set:

```bash
METRICS_OUTPUT=metrics.json bash tests/run-tests.sh
```

Metrics include:

- Total tests run
- Pass/fail counts
- Execution time per test
- Coverage by module
