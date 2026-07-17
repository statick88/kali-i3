# Architecture

## Overview

The project follows a **modular library architecture** — a main orchestrator script (`setup_i3_kali.sh`) sources specialized library modules from `lib/` to perform specific tasks. This keeps the codebase maintainable, testable, and idiomatic Bash.

```
kali-i3/
├── setup_i3_kali.sh          # Main orchestrator — phases, argument parsing, step functions
├── lib/                       # Library modules (sourced by main script and tests)
│   ├── common.sh              # Logging, UI helpers, assertions
│   ├── colors.sh              # NEON MINIMAL palette (#0A0A10, #008B8B, #00BCD4)
│   ├── state.sh               # Checkpoint persistence (JSON, bash 3.x compatible)
│   ├── i18n.sh                # English/Spanish internationalization
│   ├── apt.sh                 # Package install with caching, retry, timeout
│   ├── user.sh                # TARGET_USER/TARGET_HOME detection, run_as_user
│   ├── security.sh            # Security tool install with exponential backoff
│   ├── interactive.sh         # 5 interactive categories (core, dotfiles, shell, security, ai)
│   ├── ssh.sh                 # SSH connection management for VM testing
│   ├── screenshot.sh          # Screenshot capture (maim/import/scrot) for VM tests
│   ├── metrics.sh             # Test execution metrics (JSON output)
│   └── phase-logger.sh        # Phase timing and structured logging
├── dotfiles/                   # Config files deployed by the script
│   ├── i3/                    # i3 window manager config
│   ├── tmux/                  # tmux config + NEON status bar
│   ├── sddm/themes/           # NEON MINIMAL SDDM theme (QML + conf)
│   └── wallpapers/            # NEON background images
├── tests/                      # 27 test files
│   ├── run-tests.sh           # Test runner (runs all test-*.sh files)
│   ├── lib/test-helpers.sh    # Shared test utilities (assert functions)
│   ├── test-*.sh              # Unit and integration tests
│   └── vm/                    # VM-based tests (SSH execution, screenshots)
│       ├── run.sh             # VM test runner
│       ├── config.sh          # VM connection config
│       └── lib/               # SSH connect, screenshot helpers
├── scripts/                    # Utility scripts (theme deploy, etc.)
└── openspec/                   # Spec-driven development artifacts
```

## Module Responsibilities

### `common.sh` — Logging and UI

Provides the core logging functions used everywhere:

```bash
info "message"      # [INFO] in teal
ok "message"        # [ OK] in green
warn "message"      # [WARN] in yellow
err "message"       # [ERR!] in red
step "message"      # [STEP] in cyan (numbered step)
die "message"       # [FATAL] + exit 1
header "message"    # Full-width section header
```

Also includes assertion helpers (`assert_eq`, `assert_contains`, `assert_file_exists`) used by the test suite.

### `colors.sh` — NEON MINIMAL Palette

Defines the color constants used across the entire setup:

| Variable | Hex | Usage |
|----------|-----|-------|
| `NEON_BG` | `#0A0A10` | Background (tmux, i3, SDDM) |
| `NEON_FG` | `#E0E0E0` | Foreground text |
| `NEON_ACCENT` | `#008B8B` | Primary accent (teal) |
| `NEON_CYAN` | `#00BCD4` | Secondary accent (cyan) |
| `NEON_ALERT` | `#C71585` | Error/alert highlights |
| `NEON_GREEN` | `#00FF66` | Success indicators |

### `state.sh` — Checkpoint Persistence

Tracks which phases have completed so the script can resume after interruption:

- Progress stored as JSON in `~/.cache/kali-i3/progress.json`
- Uses **bash 3.x compatible indexed arrays** (not associative arrays)
- Functions: `state_init()`, `state_mark_done()`, `state_is_done()`, `state_save()`, `state_load()`

### `apt.sh` — Package Management

Wraps `apt-get` with reliability features:

- **Caching** — tracks installed packages to avoid redundant installs
- **Retry** — retries failed installs up to 3 times with exponential backoff
- **Timeout** — 120-second timeout per package to prevent hangs
- **Dry run** — `--dry-run` flag shows what would be installed

### `user.sh` — User Detection

Automatically detects the target user:

- If run as root: detects the non-root user who invoked `sudo`
- Sets `TARGET_USER`, `TARGET_HOME`, `TARGET_UID`, `TARGET_GID`
- `run_as_user "command"` — executes as the target user
- `run_as_root "command"` — executes as root

### `security.sh` — Tool Installation

Installs security tools with retry logic and exponential backoff. Handles tools that fail to install from standard repos by falling back to alternative methods (manual download, snap, pip, etc.).

### `interactive.sh` — Category Selection

Presents 5 interactive categories when running in interactive mode:

1. **Core** — i3, SDDM, display manager
2. **Dotfiles** — wallpapers, i3 config, tmux config
3. **Shell** — Zsh, Oh-My-Zsh, Powerlevel10k, hacker profile
4. **Security** — security suite, advanced tools, anonymity
5. **AI Tools** — gentle-ai, HexStrike AI, agent state

### `ssh.sh` / `screenshot.sh` — VM Testing

Used by the VM test harness (`tests/vm/`):

- `ssh_connect()` — establish SSH connection with password auth
- `ssh_execute()` — run commands on remote VM
- `screenshot_capture()` — take screenshots via SSH using maim/import/scrot

## Design Decisions

### Why Bash 3.x?

The script must run on macOS (bash 3.2 is the default) for development and CI, while targeting Kali Linux for execution. This means no associative arrays — the checkpoint system uses indexed arrays with a manual key-value lookup pattern.

### Why checkpoints?

Pentesting setups can take 30+ minutes. If the script fails at phase 7, you shouldn't have to re-run phases 0–6. The checkpoint system persists progress to disk so interrupted runs can resume.

### Why modular libraries?

Each `lib/*.sh` module is like a room in a house — it has a specific purpose, and if one room floods, the others stay dry. The main script sources only what it needs. Tests can call individual functions directly without bootstrapping the full pipeline.

### Why interactive + unattended?

Interactive mode lets users choose what to install during a first run. Unattended mode (`--user-only`) is essential for automation, CI, and repeatable deployments across multiple machines.
