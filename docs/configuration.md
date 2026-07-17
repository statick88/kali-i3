# Configuration

## CLI Flags

The script accepts the following flags. All are optional — defaults run the full interactive install.

| Flag | Description |
|------|-------------|
| `--user-only` | Skip root checks, run as current user only (unattended mode) |
| `--skip-security` | Skip Phase 6–7 (security suite, anonymity, firewall) |
| `--skip-dotfiles` | Skip Phase 1 (wallpapers, i3 config, tmux config) |
| `--skip-shell` | Skip Phase 3–4 (Zsh, Oh-My-Zsh, hacker profile) |
| `--skip-tmux` | Skip Phase 2 (tmux configuration) |
| `--skip-ai` | Skip Phase 8–9 (gentle-ai, HexStrike AI, agent state) |
| `--interactive` | Enable interactive mode — prompts for each category |
| `--lang {en,es}` | Set output language (default: `en`) |
| `--phase N` | Run only phase N (0–9) |
| `--gentle-ai` | Enable gentle-ai agent integration |
| `--hexstrike-ai` | Enable HexStrike AI agent integration |
| `--dry-run` | Show what would be installed without making changes |

## Usage Examples

### Full unattended install

```bash
sudo ./setup_i3_kali.sh --user-only
```

### Skip security tools (just desktop setup)

```bash
sudo ./setup_i3_kali.sh --skip-security
```

### Only install security tools

```bash
sudo ./setup_i3_kali.sh --skip-dotfiles --skip-shell --skip-ai
```

### Run a single phase

```bash
sudo ./setup_i3_kali.sh --phase 6   # Only security suite
```

### Interactive mode with Spanish output

```bash
sudo ./setup_i3_kali.sh --interactive --lang es
```

### Dry run (no changes)

```bash
sudo ./setup_i3_kali.sh --dry-run
```

## Environment Variables

The script uses these environment variables (auto-set by library modules):

| Variable | Source | Description |
|----------|--------|-------------|
| `NEON_BG` | `lib/colors.sh` | Background color `#0A0A10` |
| `NEON_FG` | `lib/colors.sh` | Foreground color `#E0E0E0` |
| `NEON_ACCENT` | `lib/colors.sh` | Primary accent `#008B8B` |
| `NEON_CYAN` | `lib/colors.sh` | Secondary accent `#00BCD4` |
| `NEON_ALERT` | `lib/colors.sh` | Alert color `#C71585` |
| `NEON_GREEN` | `lib/colors.sh` | Success color `#00FF66` |
| `TARGET_USER` | `lib/user.sh` | Detected non-root user |
| `TARGET_HOME` | `lib/user.sh` | Home directory of target user |
| `TARGET_UID` | `lib/user.sh` | UID of target user |
| `TARGET_GID` | `lib/user.sh` | GID of target user |
| `SSH_OPTS` | `lib/ssh.sh` | SSH connection options |
| `SSH_PORT` | `lib/ssh.sh` | SSH port (default: 22) |

## AI Agent Environment Variables

Set in the hacker profile (`~/.config/zsh/hacker_profile.zsh`):

```bash
export GENTLE_AI_AGENT="kali-i3"
export GENTLE_AI_WORKSPACE="${HOME}/.config/agent-state"
export KALI_MCP_ENDPOINT="http://localhost:8888"
export HEXSTRIKE_MCP_ENDPOINT="http://localhost:8888"
```

## Checkpoint State

Progress is stored at:

```
~/.cache/kali-i3/progress.json
```

Format:

```json
{
  "completed_phases": [0, 1, 2, 3, 4, 5],
  "current_phase": 6,
  "last_updated": "2024-01-15T10:30:00Z"
}
```

To reset progress and start fresh:

```bash
rm ~/.cache/kali-i3/progress.json
```

## Logging

All output goes to stdout with structured prefixes:

```
[INFO] message       # Informational
[ OK ] message       # Success
[WARN] message       # Warning (non-fatal)
[ERR!] message       # Error (operation failed)
[STEP] message       # Step progress
[FATAL] message      # Fatal error (exits)
────────────────────────────
Phase 6: Security Suite        # Section header
```

Logs can be redirected:

```bash
sudo ./setup_i3_kali.sh 2>&1 | tee setup.log
```
