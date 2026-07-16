# VM Testing Specification

## Purpose

Validate `setup_i3_kali.sh` execution on a disposable VMware VM with SSH connectivity, phased execution, screenshot capture, and issue documentation.

## Requirements

### Requirement: SSH Connectivity Validation

The testing harness SHALL establish and validate SSH connectivity to the target VM before script execution.

#### Scenario: Successful SSH connection

- GIVEN VM at 192.168.100.6 is running with SSH active
- WHEN harness attempts SSH with user `statick` and password `666`
- THEN connection succeeds within 10 seconds

#### Scenario: SSH retry on failure

- GIVEN VM is booting or SSH temporarily unavailable
- WHEN initial connection fails
- THEN harness retries up to 5 times with 15-second intervals
- AND logs each attempt with timestamp and error code

#### Scenario: SSH connection timeout

- GIVEN VM is unreachable after all retries
- WHEN harness exhausts retry budget
- THEN harness exits with code 1 and no script execution is attempted

### Requirement: Script Execution Phases

The harness SHALL execute `setup_i3_kali.sh` and capture output for each of the 21 step functions.

#### Scenario: Full execution with phase logging

- GIVEN SSH connection is validated
- WHEN harness executes `sudo ./setup_i3_kali.sh`
- THEN each step function is logged separately with completion status (success/failure/skipped)
- AND total execution time is measured

#### Scenario: Step-level output capture

- GIVEN script is executing on the VM
- WHEN a step function begins and ends
- THEN stdout/stderr is captured in `/tmp/vm-test/phase-logs/{step_name}.log`

#### Scenario: Non-interactive execution

- GIVEN script has interactive prompts
- WHEN harness runs the script
- THEN all prompts are bypassed using `--no-interactive` flag

### Requirement: Screenshot Capture

The harness SHALL capture screenshots at defined points during and after execution.

#### Scenario: Per-phase screenshot

- GIVEN a step function completes successfully
- WHEN harness captures screenshot
- THEN saved as `phase-{NN}-{step_name}.png` (zero-padded, kebab-case)

#### Scenario: Final desktop screenshot

- GIVEN script execution completes
- WHEN harness captures final state
- THEN desktop screenshot saved as `phase-99-final-desktop.png`

### Requirement: Issue Documentation

The harness SHALL document errors, warnings, and unexpected behavior.

#### Scenario: Error capture

- GIVEN script encounters an error (non-zero exit or error patterns)
- WHEN error is detected
- THEN issue file created with: Severity, Step, Error Message, Expected/Actual Behavior, Logs, Screenshot Reference

#### Scenario: Warning aggregation

- GIVEN warnings detected (`WARN`, `DEPRECATED` patterns)
- WHEN execution completes
- THEN all warnings aggregated into summary with count and first occurrence

### Requirement: Performance Metrics

The harness SHALL collect performance data during execution.

#### Scenario: Step timing

- GIVEN script executes on VM
- WHEN each step begins/ends
- THEN elapsed time recorded in milliseconds in structured JSON

#### Scenario: Package installation metrics

- GIVEN apt packages are installed
- WHEN `apt_install_if_missing` completes
- THEN packages installed/skipped/failed counts and duration recorded

### Requirement: Test Report Generation

The harness SHALL generate a consolidated test report.

#### Scenario: JSON report

- GIVEN all phases complete
- WHEN report is generated
- THEN saved as `/tmp/vm-test/report.json` with: overall status, per-step results, timing, screenshots, issues

#### Scenario: Human-readable summary

- GIVEN JSON report exists
- WHEN harness completes
- THEN markdown summary printed with pass/fail count, duration, screenshot links

## Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Reliability | Harness MUST complete without crashing even if script fails |
| Timeout | Total execution MUST complete within 45 minutes |
| Storage | Artifacts MUST NOT exceed 500MB total |
| Idempotency | Running twice MUST produce independent results |

## Dependencies

- SSH client (`ssh`, `sshpass`), `maim`/`import` for screenshots, `jq` for JSON
- Target VM: 192.168.100.6 (user: `statick`, pass: `666`)
