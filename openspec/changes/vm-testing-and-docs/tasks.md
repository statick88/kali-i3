# Tasks: VM Testing and Documentation Enhancement

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 600–800 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 (Testing Harness) → PR 2 (Documentation Site) → PR 3 (Script Optimizations) |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: pending
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Focused test command | Runtime harness | Rollback boundary |
|------|------|-----------|----------------------|-----------------|-------------------|
| 1 | Testing harness core (SSH, executor, reporter) | PR 1 | `bash tests/vm/run-vm-test.sh --dry-run` | SSH into 192.168.100.6, run full script | tests/vm/* only |
| 2 | Documentation site (MkDocs + content) | PR 2 | `mkdocs build --strict` | Local build + link check | docs/* + .github/workflows/docs.yml |
| 3 | Script optimizations (error handling, i18n, perf) | PR 3 | `bash tests/test-optimizations.sh` | Run setup_i3_kali.sh on VM, compare metrics | lib/* + setup_i3_kali.sh |

## Phase 1: Testing Harness Foundation

- [ ] 1.1 Create `tests/vm/lib/ssh-connect.sh` — SSH connection with retry logic (5 retries, 15s interval), `connect_vm` function, logging attempts with timestamps
- [ ] 1.2 Create `tests/vm/lib/phase-executor.sh` — `execute_phase` function that captures stdout/stderr per step, writes to `/tmp/vm-test/phase-logs/{step_name}.log`
- [ ] 1.3 Create `tests/vm/run-vm-test.sh` — Main orchestrator that sources lib modules, validates SSH, loops through 21 steps, invokes executor/screenshot/metrics

## Phase 2: Testing Harness Extensions

- [ ] 2.1 Create `tests/vm/lib/screenshot-capture.sh` — `capture_phase` using `maim` over X11 forwarding, filenames `phase-{NN}-{step_name}.png`, final desktop as `phase-99-final-desktop.png`
- [ ] 2.2 Create `tests/vm/lib/metrics-collector.sh` — `record_metric` appending JSON lines to `metrics.jsonl` with step name, duration, package counts
- [ ] 2.3 Create `tests/vm/lib/report-generator.sh` — `generate_report` producing `report.json` and `summary.md` from collected metrics/logs
- [ ] 2.4 Create `tests/vm/fixtures/known-issues.json` — Error pattern definitions (severity, regex, suggested fix) for common failures

## Phase 3: Documentation Site Setup

- [ ] 3.1 Create `docs/mkdocs.yml` — MkDocs Material config: nav structure, theme (dark/light toggle), search plugin, emoji extension
- [ ] 3.2 Create `docs/index.md` — Home page with tagline, feature highlights, quick install command, badges
- [ ] 3.3 Create `.github/workflows/docs.yml` — GitHub Actions workflow: build on push to main, deploy to gh-pages, mkdocs build --strict

## Phase 4: Documentation Content

- [ ] 4.1 Create `docs/getting-started/` — prerequisites.md, installation.md, first-boot.md with screenshot placeholders
- [ ] 4.2 Create `docs/architecture/` — overview.md (module dependency diagram), module-dependencies.md, execution-flow.md
- [ ] 4.3 Create `docs/configuration/` — cli-flags.md (--user-only, --skip-security, --gentle-ai, --no-interactive, --lang), environment-vars.md
- [ ] 4.4 Create `docs/modules/` — 8 sub-pages (apt, colors, common, i18n, interactive, security, state, user) with function signatures, params, return values
- [ ] 4.5 Create `docs/troubleshooting/` — 6 categorized pages (installation, configuration, display-manager, network, security-tools, performance) with 20+ issues
- [ ] 4.6 Create `docs/contributing/guide.md` — Development setup, code style, testing instructions, PR process

## Phase 5: Script Optimizations — Error Handling

- [ ] 5.1 Modify `lib/apt.sh` — Add network failure detection in `apt_install_if_missing()`: detect timeout/connection refused, log retry suggestion, return distinct exit code
- [ ] 5.2 Modify `lib/common.sh` — Add disk space check at script start (minimum 2GB), dependency detection (`git`, `curl`, `ssh`) before first use
- [ ] 5.3 Modify `lib/common.sh` — Add `write_file_if_missing` permission-denied handling: log failed path, suggest `chmod`/`chown`, attempt fallback

## Phase 6: Script Optimizations — i18n & Performance

- [ ] 6.1 Modify `lib/i18n.sh` — Add missing translations for all 21 step labels across en/es/fr/pt/de, implement English fallback with warning for missing keys
- [ ] 6.2 Modify `lib/state.sh` — Add checkpoint optimization: skip completed steps on resume, log "already completed"
- [ ] 6.3 Modify `lib/apt.sh` — Add cache-aware `apt update` (skip if <24h old), config diff before write (skip if identical)
- [ ] 6.4 Modify `setup_i3_kali.sh` — Add root privilege check, OS distribution detection, existing i3 installation detection

## Phase 7: Integration Testing

- [ ] 7.1 Create `tests/test-vm-harness.sh` — Unit tests for SSH connection (mock local shell), phase execution (log capture), screenshot (filename gen), metrics (JSON format)
- [ ] 7.2 Create `tests/test-optimizations.sh` — Unit tests for error handling paths, i18n fallback, disk space check, dependency detection
- [ ] 7.3 Run full VM test: `bash tests/vm/run-vm-test.sh` against 192.168.100.6, validate all 21 steps complete, review screenshots/metrics

## Phase 8: Cleanup & Review

- [ ] 8.1 Run `shellcheck` on all new/modified shell scripts, fix any warnings
- [ ] 8.2 Verify `mkdocs build --strict` passes with zero broken links
- [ ] 8.3 Final review: ensure all tasks from specs are covered, no regressions in existing tests
