# Tasks: VMware Clipboard Fix for i3

## Review Workload Forecast

```
Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low
```

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Wrapper script + i3 config update | Single PR | ~30 lines changed; independent |

## Phase 1: Wrapper Script Creation

- [ ] 1.1 Add wrapper script creation to `setup_i3_kali.sh` in `install_configs()` function after font install
- [ ] 1.2 Wrapper script: create `~/.local/bin/vmware-clipboard` with 3s sleep, DISPLAY=:0 export, process check, exec vmware-user-suid-wrapper with logging
- [ ] 1.3 Make wrapper executable: `chmod +x ~/.local/bin/vmware-clipboard`

## Phase 2: i3 Config Template Update

- [ ] 2.1 In `setup_i3_kali.sh` i3 config heredoc, change line 209 from `exec --no-startup-id vmware-user-suid-wrapper` to `exec --no-startup-id ~/.local/bin/vmware-clipboard`
- [ ] 2.2 Verify the heredoc uses correct variable expansion (no premature expansion of `~`)

## Phase 3: Verification

- [ ] 3.1 Run `setup_i3_kali.sh --dry-run` or test install to verify wrapper script is created
- [ ] 3.2 Verify generated i3 config at `~/.config/i3/config` contains wrapper path
- [ ] 3.3 Test wrapper script syntax: `bash -n ~/.local/bin/vmware-clipboard`
- [ ] 3.4 Restart i3 (`Mod+Shift+r`) and verify `pgrep -f vmware-user` shows running process
- [ ] 3.5 Test clipboard: copy on host → paste in guest terminal; copy in guest → paste on host