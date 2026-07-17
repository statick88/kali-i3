# VMware Clipboard Specification

## Purpose

This specification defines the behavior for enabling VMware clipboard synchronization (copy/paste between host and guest) in the Kali i3 environment. The clipboard daemon must start automatically with the i3 session and maintain clipboard sync throughout the session lifecycle.

## Requirements

### Requirement: Clipboard Daemon Auto-Start

The system SHALL start the VMware clipboard daemon automatically when the i3 session initializes.

#### Scenario: Daemon starts with i3 session

- GIVEN a fresh i3 session login
- WHEN i3 completes startup
- THEN vmware-user-suid-wrapper process is running
- AND clipboard synchronization is active

#### Scenario: Daemon restarts after crash

- GIVEN clipboard daemon was running
- WHEN daemon process terminates unexpectedly
- THEN system SHOULD attempt restart within 30 seconds
- AND clipboard synchronization resumes automatically

### Requirement: Clipboard Bidirectional Sync

The system SHALL synchronize clipboard content bidirectionally between host (VMware Workstation/Fusion) and guest (Kali i3).

#### Scenario: Copy from host, paste in guest

- GIVEN clipboard daemon is running
- WHEN user copies text on host OS
- THEN text is available for paste in guest applications
- AND paste works in terminal, browser, and GUI apps

#### Scenario: Copy from guest, paste on host

- GIVEN clipboard daemon is running
- WHEN user copies text in guest application
- THEN text is available for paste on host OS
- AND paste works in host applications

#### Scenario: Large clipboard content

- GIVEN clipboard daemon is running
- WHEN user copies >100KB text or image
- THEN sync completes within 5 seconds
- AND no data loss occurs

### Requirement: X11 Display Integration

The clipboard daemon SHALL connect to the active X11 display for clipboard operations.

#### Scenario: Daemon uses correct DISPLAY

- GIVEN i3 is running on :0
- WHEN vmware-user-suid-wrapper starts
- THEN daemon connects to DISPLAY=:0
- AND clipboard operations use X11 selections (CLIPBOARD, PRIMARY)

#### Scenario: Multiple X11 displays

- GIVEN multiple X sessions exist
- WHEN i3 session starts on specific display
- THEN daemon binds only to that session's display
- AND does not interfere with other sessions