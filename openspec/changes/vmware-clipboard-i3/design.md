# Design: VMware Clipboard Fix for i3

## Technical Approach

Create a wrapper script that delays VMware clipboard daemon startup until X11 is fully initialized, then update the i3 config template in `setup_i3_kali.sh` to use this wrapper instead of calling `vmware-user-suid-wrapper` directly.

## Architecture Decisions

### Decision: Wrapper Script Location

**Choice**: `~/.local/bin/vmware-clipboard`
**Alternatives considered**: `/usr/local/bin/`, systemd user service, i3 exec with sleep
**Rationale**: User-local bin follows XDG spec, no root needed, survives package updates, i3 exec runs in user context anyway

### Decision: Startup Delay

**Choice**: 3 second sleep in wrapper
**Alternatives considered**: Poll X11 readiness, systemd After=graphical.target, i3 startup notification
**Rationale**: Simple, reliable, 3s covers all observed X11 init times on Kali VMware; polling adds complexity

### Decision: DISPLAY Export

**Choice**: Explicit `export DISPLAY=:0` in wrapper
**Alternatives considered**: Rely on inherited env, use `$DISPLAY` from i3
**Rationale**: i3 inherits DISPLAY but vmware-user-suid-wrapper sometimes loses it; explicit export guarantees correct display

## Data Flow

```
i3 Session Start
      │
      ▼
i3 reads config → exec --no-startup-id ~/.local/bin/vmware-clipboard
      │
      ▼
Wrapper script runs:
  1. sleep 3
  2. export DISPLAY=:0
  3. exec vmware-user-suid-wrapper &
      │
      ▼
vmware-user-suid-wrapper loads libdndcp.so plugin
      │
      ▼
Clipboard sync active (bidirectional X11 ↔ VMware host)
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `setup_i3_kali.sh` | Modify | Add wrapper script creation in install phase; update i3 config template |
| `~/.local/bin/vmware-clipboard` | Create (via setup) | Wrapper script with delay + DISPLAY export + daemon launch |

## Interfaces / Contracts

```bash
# ~/.local/bin/vmware-clipboard
#!/bin/bash
# VMware Clipboard Wrapper for i3
# Ensures proper X11 display context for clipboard daemon

sleep 3
export DISPLAY=:0

# Prevent multiple instances
if pgrep -x "vmware-user-suid-wrapper" >/dev/null; then
    exit 0
fi

exec vmware-user-suid-wrapper >> ~/.local/share/vmware-clipboard.log 2>&1 &
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | Wrapper script syntax | `bash -n ~/.local/bin/vmware-clipboard` |
| Integration | i3 config generation | Run setup script, verify config contains wrapper path |
| E2E | Clipboard sync | Copy on host → paste in guest; copy in guest → paste on host |

## Migration / Rollout

No migration required. Existing users re-run setup script; new users get fix by default. Wrapper script is idempotent (checks for existing process).

## Open Questions

- [ ] Should wrapper also handle vmware-user (non-suid) for Wayland fallback? (i3 is X11-only currently)
- [ ] Add systemd user service as alternative for non-i3 desktops? (Out of scope)