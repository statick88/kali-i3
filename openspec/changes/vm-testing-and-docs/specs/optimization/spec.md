# Optimization Specification

## Purpose

Define improvements to `setup_i3_kali.sh` based on VM testing: error handling, i18n coverage, performance, and edge cases.

## Requirements

### Requirement: Error Handling Improvements

#### Scenario: Network failure during apt install

- GIVEN VM has no internet
- WHEN `apt_install_if_missing` fails with network error
- THEN script logs specific error with retry suggestion, continues to next step or exits cleanly

#### Scenario: Permission denied on config deployment

- GIVEN target directory has restrictive permissions
- WHEN `write_file_if_missing` fails
- THEN script logs failed path, suggests fix, attempts alternative or warns

#### Scenario: Missing dependency detection

- REQUIRED tool (`git`, `curl`, `ssh`) is not installed
- WHEN script attempts to use the tool
- THEN script detects before execution and provides install command or clear failure message

#### Scenario: Disk space check

- GIVEN VM disk nearly full
- WHEN script begins
- THEN checks available space (minimum 2GB recommended), warns if insufficient

### Requirement: i18n Coverage Gaps

#### Scenario: Missing translation fallback

- GIVEN string has no translation in current locale
- WHEN displayed
- THEN English fallback used, warning logged for missing key

#### Scenario: Step label completeness

- GIVEN all 21 step functions have labels
- WHEN i18n initializes
- THEN every step has translations for en, es, fr, pt, de (no raw key fallback)

#### Scenario: Error message translation

- GIVEN error encountered
- WHEN message displayed
- THEN translated to current locale with raw context for debugging

### Requirement: Performance Optimization

#### Scenario: Parallel package installation

- GIVEN multiple independent package groups
- WHEN `apt_install_if_missing` called for each
- THEN independent groups run in parallel, total time reduced ≥20%

#### Scenario: Cache-aware package checks

- GIVEN apt cache is fresh (<24h)
- WHEN checking installed packages
- THEN `apt update` skipped if cache is current

#### Scenario: Config diff before write

- GIVEN config file exists at target path
- WHEN deploying config
- THEN compares existing vs new, skips write if identical

#### Scenario: State checkpoint optimization

- GIVEN script resumes from checkpoint
- WHEN completed steps encountered
- THEN skipped, logged as "already completed"

### Requirement: Edge Case Handling

#### Scenario: Existing i3 installation

- GIVEN i3-wm already installed
- WHEN step_install_i3_core runs
- THEN detects existing install, skips package install, logs "already installed"

#### Scenario: Multiple user accounts

- GIVEN VM has multiple accounts
- WHEN `--user-only` used for specific user
- THEN only target user's dotfiles deployed, others unaffected

#### Scenario: Non-standard home directory

- GIVEN user home is not `/home/username`
- WHEN deploying dotfiles
- THEN resolves home from `/etc/passwd`, all paths relative to actual home

#### Scenario: Interrupted execution recovery

- GIVEN script interrupted (Ctrl+C, SSH disconnect)
- WHEN re-run
- THEN state file loaded, completed steps skipped, resumes from last incomplete step

### Requirement: Logging Improvements

#### Scenario: Structured log format

- WHEN any log message generated
- THEN format: timestamp, severity (DEBUG/INFO/WARN/ERROR/FATAL), step name, message

#### Scenario: Verbose mode

- GIVEN `--verbose` flag
- WHEN script executes
- THEN DEBUG-level messages and detailed timing shown

### Requirement: Validation Checks

#### Scenario: Root privilege check

- GIVEN script run without sudo
- WHEN root-required steps reached
- THEN detects missing privilege, exits with sudo suggestion

#### Scenario: OS distribution check

- GIVEN script designed for Kali Linux
- WHEN run on different distro
- THEN detects mismatch, warns user, allows execution with compatibility warnings

## Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Backward Compat | MUST NOT break `--user-only` or `--skip-security` workflows |
| Performance | Execution time MUST NOT increase >5% |
| Test Coverage | All error handling paths MUST have unit tests |
| Documentation | All new options MUST be in Configuration Reference |

## Constraints

- Changes MUST stay under 800 lines total
- Error handling MUST NOT add interactive prompts during unattended execution
- i18n additions MUST include all 5 supported languages
