# Proposal: VMware Clipboard Fix for i3

## Intent

The `vmware-user-suid-wrapper` process (required for clipboard synchronization between host and guest) fails to stay running in i3 due to GTK initialization warnings. This breaks copy/paste functionality between the VMware host and Kali i3 guest. The fix ensures the clipboard daemon starts correctly with proper X11 display context.

## Scope

### In Scope
- Add a wrapper script that delays startup until X11 is ready and sets proper DISPLAY
- Modify i3 config to use the wrapper script instead of direct `vmware-user-suid-wrapper` call
- Ensure clipboard sync works bidirectionally (host→guest and guest→host)

### Out of Scope
- VMware Tools kernel module changes
- File sharing (HGFS) - already working
- Resolution/Display scaling - handled separately

## Capabilities

### New Capabilities
- `vmware-clipboard`: Clipboard synchronization daemon lifecycle management for i3/VMware

### Modified Capabilities
- `i3-config`: Update autostart entry to use the new wrapper script

## Approach

Create a shell wrapper script (`~/.local/bin/vmware-clipboard`) that:
1. Waits 3-5 seconds for X11 to fully initialize
2. Sets `DISPLAY=:0` explicitly
3. Executes `vmware-user-suid-wrapper` in background

Update `setup_i3_kali.sh` to deploy this wrapper and modify the i3 config template to reference it instead of the raw binary.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `setup_i3_kali.sh` | Modified | Add wrapper script creation and i3 config template update |
| `dotfiles/i3/config` (generated) | Modified | Change `exec vmware-user-suid-wrapper` → `exec ~/.local/bin/vmware-clipboard` |
| `~/.local/bin/vmware-clipboard` | New | Wrapper script for proper clipboard daemon startup |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Wrapper script fails silently | Low | Add logging to `~/.local/share/vmware-clipboard.log` |
| X11 display not ready after delay | Low | Use 5s delay; X11 is always ready by i3 startup |
| Multiple clipboard daemons | Low | Script checks for existing process before starting |

## Rollback Plan

1. Revert `setup_i3_kali.sh` changes to i3 config template
2. Remove `~/.local/bin/vmware-clipboard` script
3. Restore original `exec --no-startup-id vmware-user-suid-wrapper` in i3 config

## Dependencies

- `open-vm-tools-desktop` package (already installed)
- X11 session (i3 runs on X11)

## Success Criteria

- [ ] `pgrep -f vmware-user` shows running process after i3 restart
- [ ] Copy text on host → paste in guest terminal works
- [ ] Copy text in guest → paste on host works
- [ ] No GTK warnings in journalctl for vmware-user