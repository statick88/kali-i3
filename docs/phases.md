# Phases

The setup runs in **10 sequential phases**, each containing one or more step functions. Progress is tracked via checkpoints — if the script is interrupted, it resumes at the last incomplete phase.

---

## Phase 0 — i3 Core + SDDM

**Goal:** Install the i3 window manager and switch the display manager from LightDM to SDDM.

| Step | Function | What it does |
|------|----------|--------------|
| 0.1 | `step_install_i3_core()` | Installs `i3`, `i3status`, `i3lock`, `dunst`, `rofi`, `picom`, `feh` via apt |
| 0.2 | `step_switch_display_manager()` | Installs SDDM, enables it via systemd, deploys the NEON MINIMAL QML theme to `/usr/share/sddm/themes/`, creates `/etc/sddm.conf.d/kali-i3.conf` |

**Dependencies:** `lib/apt.sh`, `lib/user.sh`, `lib/colors.sh`

**SDDM theme files deployed:**

- `dotfiles/sddm/themes/neon-minimal/theme.conf`
- `dotfiles/sddm/themes/neon-minimal/metadata.desktop`
- `dotfiles/sddm/themes/neon-minimal/Main.qml`

---

## Phase 1 — Dotfiles

**Goal:** Deploy i3 config, tmux config, and wallpapers.

| Step | Function | What it does |
|------|----------|--------------|
| 1.1 | `step_deploy_dotfiles()` | Copies i3 config and tmux config to `~/.config/`, deploys wallpapers to `~/wallpapers/` |

**Deployed files:**

- `~/.config/i3/config` — i3 keybindings, NEON color scheme, workspace setup
- `~/.config/tmux/tmux.conf` — tmux with NEON status bar, 256-color, mouse support
- `~/wallpapers/` — NEON background images

---

## Phase 2 — tmux

**Goal:** Configure tmux with the NEON MINIMAL status bar.

| Step | Function | What it does |
|------|----------|--------------|
| 2.1 | `step_configure_tmux()` | Deploys tmux config with NEON-themed status bar (`#0A0A10` background, `#008B8B` accent) |

**tmux config highlights:**

- Status bar: `#0A0A10` background, `#008B8B` session/info, `#00BCD4` window
- Prefix: `Ctrl+A` (remapped from `Ctrl+B`)
- 256-color and true-color support
- Mouse mode enabled

---

## Phase 3 — Zsh + Oh-My-Zsh + Powerlevel10k

**Goal:** Install and configure Zsh as the default shell with Oh-My-Zsh and the Powerlevel10k theme.

| Step | Function | What it does |
|------|----------|--------------|
| 3.1 | `step_install_zsh_omz()` | Installs Zsh, clones Oh-My-Zsh (unattended), clones Powerlevel10k, sets Zsh as default shell |
| 3.2 | `step_deploy_zshrc()` | Deploys `.zshrc` with plugins (git, syntax-highlighting, autosuggestions), 100k history, pentest aliases (`msf`, `ll`, `la`), PATH for `~/.local/bin` and `~/go/bin` |

**.zshrc highlights:**

- Theme: `powerlevel10k/powerlevel10k`
- Plugins: `git`, `zsh-syntax-highlighting`, `zsh-autosuggestions`
- History: 100,000 lines
- Auto-sources `~/.config/zsh/hacker_profile.zsh` if it exists

---

## Phase 4 — Hacker Profile

**Goal:** Deploy a comprehensive hacker profile with security tool aliases and AI agent environment variables.

| Step | Function | What it does |
|------|----------|--------------|
| 4.1 | `step_deploy_hacker_profile()` | Creates `~/.config/zsh/hacker_profile.zsh` with 50+ aliases across 10 categories |

**Alias categories:**

| Category | Example Aliases |
|----------|----------------|
| Network Recon | `nmap-quick`, `nmap-full`, `nmap-vuln`, `masscan-quick` |
| Web App Testing | `gobuster-dir`, `ffuf-quick`, `nuclei-scan`, `sqlmap-auto`, `wpscan-enum` |
| Exploitation | `msf`, `sliver`, `covenant` |
| Wireless | `airodump`, `aireplay`, `aircrack`, `wifite-auto` |
| Password Attacks | `john-fast`, `hashcat-quick`, `hydra-ssh`, `hydra-rdp` |
| Reverse Shells | `rlwrap-nc`, `socat-shell`, `python-shell` |
| File Transfer | `serve-http`, `serve-https`, `wget-get` |
| Binary Analysis | `ghidra-headless`, `radare2`, `gdb-peda`, `checksec` |
| Docker/Container | `dive-image`, `trivy-scan`, `grype-scan` |
| AI Agent | `gentle_status()`, `gentle_log()`, env vars for gentle-ai, Kali MCP, HexStrike MCP |

Also deploys quick helper functions: `nmap-top100()`, `nmap-top1000()`, `gobuster-common()`, `gobuster-big()`.

---

## Phase 5 — Desktop Entry

**Goal:** Register i3 as a desktop session so SDDM can find it.

| Step | Function | What it does |
|------|----------|--------------|
| 5.1 | `step_setup_i3_desktop_entry()` | Creates `/usr/share/xsessions/i3.desktop` with `Exec=i3` |

---

## Phase 6 — Security Suite

**Goal:** Install the main security tools suite and advanced tools.

| Step | Function | What it does |
|------|----------|--------------|
| 6.1 | `step_install_security_suite()` | Installs ~20 tools via apt (Metasploit, Nmap, Masscan, Gobuster, FFuf, SQLMap, Hydra, John, Hashcat, Ghidra, Radare2, GDB, pwntools, YARA, Binwalk, Wireshark, Responder, etc.), enables Docker, deploys Empire docker-compose |
| 6.2 | `step_install_advanced_tools()` | Installs NetExec and Sliver C2 via their respective install methods |

**Docker deployment:**

- Enables `docker.io`, adds user to docker group
- Creates `/opt/empire-docker/docker-compose.yml` for Empire C2 framework

**Exponential backoff:** `security.sh` retries failed installs with increasing delays (2s → 4s → 8s) to handle transient network issues.

---

## Phase 7 — Anonymity + Ghidra + Firewall

**Goal:** Set up Tor, Proxychains, Ghidra Java environment, and UFW firewall.

| Step | Function | What it does |
|------|----------|--------------|
| 7.1 | `step_setup_anonymity()` | Installs Tor, configures Proxychains with Tor SOCKS5 proxy |
| 7.2 | `step_configure_ghidra()` | Ensures the correct Java version is installed for Ghidra |
| 7.3 | `step_setup_firewall()` | Enables UFW with default deny incoming, allow outgoing |

**Proxychains config:**

- Routes all TCP traffic through Tor (`127.0.0.1:9050`)
- DNS resolution through the proxy
- Strict chain mode

---

## Phase 8 — AI Tools

**Goal:** Install gentle-ai CLI, deploy agent state scripts, and configure AI coding assistants.

| Step | Function | What it does |
|------|----------|--------------|
| 8.1 | `step_install_gentle_ai()` | Builds and installs `gentle-ai` CLI via `go install` |
| 8.2 | `step_install_gentle_agent_state()` | Clones `gentle-agent-state` repo, deploys `gentle-agent.sh` wrapper script |
| 8.3 | `step_deploy_kilo_config()` | Creates `~/.config/kilo/agent.json` and `kilo.json` with NEON theme settings |
| 8.4 | `step_setup_opencode()` | Creates `~/.config/opencode/.opencode.json` with NEON theme and model config |

**AI environment variables (set in hacker profile):**

```bash
export GENTLE_AI_AGENT="kali-i3"
export GENTLE_AI_WORKSPACE="${HOME}/.config/agent-state"
export KALI_MCP_ENDPOINT="http://localhost:8888"
export HEXSTRIKE_MCP_ENDPOINT="http://localhost:8888"
```

---

## Phase 9 — HexStrike AI + Cleanup

**Goal:** Install HexStrike AI and clean up temporary files.

| Step | Function | What it does |
|------|----------|--------------|
| 9.1 | `step_install_hexstrike_ai()` | Clones HexStrike AI repo, creates Python venv, installs requirements, verifies tool binaries |
| 9.2 | `step_cleanup()` | Clears apt cache (`apt-get clean`), removes temp files, logs final summary with phase timing |

**HexStrike AI verification:**

The script verifies that key security tool binaries are accessible after installation: `nmap`, `masscan`, `gobuster`, `ffuf`, `nuclei`, `sqlmap`, `hydra`, `john`, `hashcat`.

---

## Phase Timing

Each phase logs its start and end time via `lib/phase-logger.sh`. After all phases complete, a summary table is printed showing:

```
Phase 0: i3 Core + SDDM        — 45s
Phase 1: Dotfiles              — 12s
Phase 2: tmux                  — 3s
Phase 3: Zsh + Oh-My-Zsh       — 67s
Phase 4: Hacker Profile        — 5s
Phase 5: Desktop Entry         — 2s
Phase 6: Security Suite        — 180s
Phase 7: Anonymity + Ghidra    — 55s
Phase 8: AI Tools              — 90s
Phase 9: HexStrike AI + Cleanup — 35s
──────────────────────────────────
Total                           — 494s
```

## Checkpoint Resume

If the script is interrupted at any phase:

1. Progress is saved to `~/.cache/kali-i3/progress.json`
2. On re-run, completed phases are skipped automatically
3. The script resumes at the first incomplete phase

```bash
# Example: interrupted at phase 6, re-running skips phases 0-5
sudo ./setup_i3_kali.sh
# Output: [SKIP] Phase 0 already completed
#         [SKIP] Phase 1 already completed
#         ...
#         [STEP] Phase 6: Security Suite (resuming)
```
