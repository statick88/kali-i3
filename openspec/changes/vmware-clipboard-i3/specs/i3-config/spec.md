# i3 Configuration Specification

## Purpose

This specification defines the i3 window manager configuration for Kali Linux, including autostart applications, keybindings, and desktop integration. This is a MODIFIED spec adding VMware clipboard daemon autostart.

## Requirements

### Requirement: Autostart Applications

The system SHALL launch configured applications automatically on i3 session start.

#### Scenario: Core autostart apps launch

- GIVEN i3 session starts
- WHEN autostart commands execute
- THEN picom, feh, polybar, nm-applet are running
- AND vmware-user-suid-wrapper is running

#### Scenario: Failed autostart does not block session

- GIVEN an autostart command fails
- WHEN i3 continues startup
- THEN i3 session completes successfully
- AND failed command is logged for debugging

### Requirement: Keybindings

The system SHALL provide standard keybindings for terminal, launcher, screenshot, and volume control.

#### Scenario: Terminal launch

- GIVEN i3 is running
- WHEN user presses Mod+Enter
- THEN kitty terminal opens

#### Scenario: Application launcher

- GIVEN i3 is running
- WHEN user presses Mod+d
- THEN rofi drun menu appears

### Requirement: VMware Integration

The system SHALL integrate VMware clipboard and display synchronization.

#### Scenario: VMware clipboard daemon autostart

- GIVEN i3 session starts
- WHEN autostart executes
- THEN vmware-user-suid-wrapper starts with DISPLAY=:0
- AND clipboard sync is active within 5 seconds
- (Previously: vmware-user-suid-wrapper was listed but failed to stay running due to GTK initialization timing)

#### Scenario: Display resolution auto-set

- GIVEN VMware tools are installed
- WHEN display configuration changes
- THEN resolution adjusts to match host
- AND no manual xrandr required