# NEON i3-wm Migration Suite for Kali Linux

Migrate a stock Kali Linux install from XFCE to a minimalist i3-wm environment with a curated pentesting suite. One command, three phases: install, verify, purge.

## Quick start

```bash
git clone <repo-url> && cd kali-i3
sudo ./setup_i3_kali.sh          # full install
sudo ./purge_xfce.sh             # remove XFCE after verifying i3 works
```

## What you get

| Component | Detail |
|-----------|--------|
| Window manager | i3-wm with NEON MINIMAL theme (`#0A0A10` bg, `#008B8B` accent) |
| Shell | Zsh + Oh-My-Zsh + Powerlevel10k |
| Terminals | Kitty + Alacritty (FiraCode Nerd Font) |
| Bar | Polybar (neon dark) |
| Launcher | Rofi (border radius 0) |
| Compositor | Picom (blur + shadows) |
| TMUX | NEON theme with KALI logo + agent-state hooks |
| Security tools | Metasploit, Nmap, Masscan, Rustscan, Ghidra, Radare2, and more |
| AI integration | gentle-ai, HexStrike AI MCP (optional) |

## Options

| Flag | What it does |
|------|--------------|
| `--user-only` | Deploy dotfiles only (no sudo, no system packages) |
| `--skip-security` | Skip security tools suite installation |
| `--gentle-ai` | Install full Gentle-AI stack (gentle-ai, gentle-agent-state, Kilo, openCode) |
| `--hexstrike-ai` | Install HexStrike AI + MCP server integration |
| `--version` | Show version |
| `--help` | Show usage |

## Project structure

```
kali-i3/
  setup_i3_kali.sh     # main installer (idempotent, checkpointed)
  purge_xfce.sh        # safe XFCE removal (protects critical packages)
  lib/                 # shared bash library
    colors.sh          # NEON color constants + Azul Neón Atenuado palette
    common.sh          # logging: log, info, ok, warn, err, die, step, header
    user.sh            # user context: TARGET_USER, run_as_root, run_as_user
    state.sh           # checkpoint persistence: load/save/mark/is_completed
    apt.sh             # apt helpers: pkg_installed (cached), apt_install_if_missing
  tests/               # test suite (181 tests)
    lib/test-helpers.sh
    run-tests.sh       # test runner
    test-*.sh          # unit, integration, approval tests
  docs/
    INSTALLATION.md    # step-by-step installation guide
```

## Architecture

Three-phase safe installation:

1. **Install** — packages, dotfiles, display manager, security tools
2. **Verify** — confirm i3 works, polybar/rofi/picom running
3. **Purge** — remove XFCE/GNOME/LightDM (only after you confirm i3 works)

Idempotent checkpoints (`~/.config/i3-setup-state.json`) let you resume if interrupted.

## Color palette

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#0A0A10` | Main background |
| Background Alt | `#1E1E2F` | Secondary background, selection |
| Foreground | `#E0E0E0` | Text color |
| Accent | `#008B8B` | Focused windows, accents (Azul Neón Atenuado) |
| Accent Bright | `#00A3A6` | Bright accent variant |
| Alert | `#C71585` | Urgent, errors |
| Selection | `#1E1E2F` | Selection highlights |

## Testing

```bash
bash tests/run-tests.sh          # run all tests (unit + integration + approval)
bash -n lib/*.sh                 # syntax check lib modules
bash -n setup_i3_kali.sh         # syntax check main script
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch workflow and conventional commits.

## License

See [LICENSE](LICENSE).
