# Design: VM Testing and Documentation Enhancement

## Technical Approach

Implement a three-layer architecture: (1) VM testing harness for automated script validation, (2) MkDocs Material documentation site, (3) script optimizations based on testing findings. The harness will SSH into target VM, execute phases, capture screenshots/metrics, and generate reports. Documentation will be generated from tested state. Optimizations will address error handling, i18n gaps, and performance.

## Architecture Decisions

### Decision: Testing Harness Architecture

**Choice**: Separate Bash modules with SSH orchestration  
**Alternatives considered**:  
- Python SSH library (paramiko) - Rejected: adds dependency, breaks Bash-only constraint  
- Single monolithic script - Rejected: violates modular principle, hard to maintain  
- Docker-based testing - Rejected: VM testing requires real hardware/networking  

**Rationale**: Bash modules maintain consistency with existing codebase, allow direct reuse of lib functions, and avoid new dependencies.

### Decision: Documentation Framework

**Choice**: MkDocs Material with GitHub Actions deployment  
**Alternatives considered**:  
- Hugo - Rejected: steeper learning curve, less Markdown-native  
- Jekyll - Rejected: Ruby dependency, slower builds  
- Static HTML - Rejected: manual maintenance, no search  

**Rationale**: MkDocs Material provides client-side search, mobile responsiveness, and simple Markdown workflow. GitHub Actions enables automated deployment.

### Decision: Screenshot Capture Method

**Choice**: `maim` with X11 forwarding over SSH  
**Alternatives considered**:  
- `import` (ImageMagick) - Rejected: older, less reliable on remote displays  
- VNC screenshot - Rejected: adds VNC dependency, complex setup  
- Manual capture - Rejected: not automated  

**Rationale**: `maim` is lightweight, works reliably with X11 forwarding, and produces clean PNGs.

### Decision: Performance Metrics Storage

**Choice**: JSON files with `jq` processing  
**Alternatives considered**:  
- SQLite database - Rejected: adds dependency, overkill for single run  
- CSV files - Rejected: harder to nested data  
- In-memory only - Rejected: lost on crash  

**Rationale**: JSON is human-readable, processable with `jq`, and survives crashes.

## Data Flow

```
┌─────────────────────────────────────────────────────────┐
│                    HOST MACHINE                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │ test-runner │───▶│  ssh-client │───▶│   reporter  │ │
│  │   (main)    │    │  (connect)  │    │  (aggregate)│ │
│  └─────────────┘    └─────────────┘    └─────────────┘ │
│         │                   │                   │       │
│         ▼                   ▼                   ▼       │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │ phase-logs/ │    │ screenshots/│    │ report.json │ │
│  └─────────────┘    └─────────────┘    └─────────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          │ SSH (port 22)
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    TARGET VM (192.168.100.6)             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │setup_i3_kali│───▶│   lib/*.sh  │───▶│   i3wm      │ │
│  │    .sh      │    │  (modules)  │    │  (desktop)   │ │
│  └─────────────┘    └─────────────┘    └─────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Component Design

### 1. Testing Harness (`tests/vm/`)

```
tests/vm/
├── run-vm-test.sh          # Main orchestrator
├── lib/
│   ├── ssh-connect.sh      # SSH connection management
│   ├── phase-executor.sh   # Step function execution
│   ├── screenshot-capture.sh # Screenshot handling
│   ├── metrics-collector.sh # Performance data
│   └── report-generator.sh # JSON/markdown reports
└── fixtures/
    └── known-issues.json   # Error pattern definitions
```

**Interfaces**:
- `ssh-connect.sh`: `connect_vm <host> <user> <pass> <retries>` → exit code
- `phase-executor.sh`: `execute_phase <step_name> <log_dir>` → stdout/stderr captured
- `screenshot-capture.sh`: `capture_phase <phase_num> <step_name> <output_dir>` → filename
- `metrics-collector.sh`: `record_metric <step_name> <start_time> <end_time>` → JSON line
- `report-generator.sh`: `generate_report <run_dir>` → report.json, summary.md

### 2. Documentation Site (`docs/`)

```
docs/
├── mkdocs.yml              # MkDocs configuration
├── index.md                # Home page
├── getting-started/
│   ├── prerequisites.md
│   ├── installation.md
│   └── first-boot.md
├── architecture/
│   ├── overview.md
│   ├── module-dependencies.md
│   └── execution-flow.md
├── configuration/
│   ├── cli-flags.md
│   └── environment-vars.md
├── modules/
│   ├── apt.md
│   ├── colors.md
│   ├── common.md
│   ├── i18n.md
│   ├── interactive.md
│   ├── security.md
│   ├── state.md
│   └── user.md
├── troubleshooting/
│   ├── installation-issues.md
│   ├── configuration-issues.md
│   ├── display-manager.md
│   ├── network.md
│   ├── security-tools.md
│   └── performance.md
├── contributing/
│   └── guide.md
└── assets/
    └── screenshots/        # From VM testing
```

**Interfaces**:
- `mkdocs.yml`: Defines navigation, theme, plugins
- GitHub Actions workflow: `.github/workflows/docs.yml`
- Screenshot integration: `![alt text](../assets/screenshots/phase-XX-name.png)`

### 3. Script Optimizations (`lib/`, `setup_i3_kali.sh`)

**Error Handling Improvements**:
- Network failure detection in `apt_install_if_missing()`
- Permission denied handling in `write_file_if_missing()`
- Missing dependency detection before execution
- Disk space check at script start

**i18n Coverage**:
- Add missing translations for all 21 step labels
- Implement fallback to English with warning
- Complete en/es/fr/pt/de coverage

**Performance Optimizations**:
- Parallel package installation for independent groups
- Cache-aware `apt update` (skip if <24h old)
- Config diff before write (skip if identical)
- State checkpoint optimization (skip completed steps)

**Edge Case Handling**:
- Existing i3 installation detection
- Multiple user account handling
- Non-standard home directory resolution
- Interrupted execution recovery

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `tests/vm/run-vm-test.sh` | Create | Main VM test orchestrator |
| `tests/vm/lib/*.sh` | Create | SSH, execution, screenshot, metrics, reporting modules |
| `tests/vm/fixtures/known-issues.json` | Create | Error pattern definitions |
| `docs/mkdocs.yml` | Create | MkDocs Material configuration |
| `docs/**/*.md` | Create | Documentation pages (7 top-level, 8 module sub-pages) |
| `docs/assets/screenshots/` | Create | Screenshot storage directory |
| `.github/workflows/docs.yml` | Create | GitHub Actions deployment workflow |
| `lib/apt.sh` | Modify | Add network error handling, parallel install |
| `lib/common.sh` | Modify | Add disk space check, dependency detection |
| `lib/i18n.sh` | Modify | Add missing translations, fallback handling |
| `lib/state.sh` | Modify | Add checkpoint optimization |
| `setup_i3_kali.sh` | Modify | Add validation checks, performance improvements |
| `tests/test-vm-harness.sh` | Create | Unit tests for testing harness |
| `tests/test-optimizations.sh` | Create | Unit tests for script improvements |

## Interfaces / Contracts

### SSH Connection Contract
```bash
# Input: host, user, password, max_retries
# Output: exit code (0=success, 1=failed)
# Side effects: establishes SSH session, logs attempts
connect_vm "192.168.100.6" "statick" "666" 5
```

### Phase Execution Contract
```bash
# Input: step_name, log_directory
# Output: exit code (0=success, 1=failed)
# Side effects: captures stdout/stderr, creates log file
execute_phase "step_install_i3_core" "/tmp/vm-test/phase-logs"
```

### Screenshot Capture Contract
```bash
# Input: phase_number, step_name, output_directory
# Output: filename (relative path)
# Side effects: captures X11 display, saves PNG
capture_phase 1 "step_install_i3_core" "/tmp/vm-test/screenshots"
```

### Metrics Collection Contract
```bash
# Input: step_name, start_time, end_time, packages_installed, packages_skipped, packages_failed
# Output: JSON line appended to metrics file
# Side effects: appends to metrics.jsonl
record_metric "step_install_i3_core" 1678901234 1678901250 15 3 0
```

### Report Generation Contract
```bash
# Input: run_directory
# Output: report.json, summary.md
# Side effects: creates files in run directory
generate_report "/tmp/vm-test/run-2026-07-16"
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | SSH connection logic | Mock SSH with local shell, test retry/timeout |
| Unit | Phase execution | Test log capture, error handling |
| Unit | Screenshot capture | Test filename generation, directory creation |
| Unit | Metrics collection | Test JSON formatting, file appending |
| Unit | Report generation | Test JSON/markdown output structure |
| Integration | Full VM test run | Execute against test VM, validate artifacts |
| Integration | Documentation build | `mkdocs build` with link checking |
| E2E | Script optimization | Run optimized script on VM, compare metrics |
| E2E | Documentation site | Deploy to gh-pages, verify all pages load |

## Threat Matrix

**N/A** — No routing, shell, subprocess, VCS/PR automation, executable-file classification, or process-integration boundary.

## Migration / Rollout

1. **Phase 1**: Create testing harness (tests/vm/)
2. **Phase 2**: Execute VM tests, capture baseline metrics
3. **Phase 3**: Implement script optimizations based on findings
4. **Phase 4**: Create documentation site with tested state
5. **Phase 5**: Single PR with all changes (<800 lines)

**Rollback**: Each phase is independent; revert specific commits if needed.

## Open Questions

- [ ] Should testing harness support multiple VM targets simultaneously?
- [ ] Should documentation include video tutorials or just screenshots?
- [ ] Should optimizations be configurable via flags or always enabled?
- [ ] Should test reports be uploaded to GitHub as artifacts?
