#!/usr/bin/env bash
# =============================================================================
# tests/vm/config.sh — VM testing configuration
# =============================================================================

# VM connection settings
VM_HOST="192.168.100.4"
VM_USER="statick"
VM_PASS="666"
VM_PORT="22"

# SSH connection timeout (seconds)
VM_CONNECT_TIMEOUT=30

# Script to test on VM
REMOTE_SCRIPT_PATH="/tmp/kali-i3/setup_i3_kali.sh"
LOCAL_SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/../../setup_i3_kali.sh"

# Phase logging
PHASE_LOG_DIR="/tmp/kali-i3-phases"
PHASE_SCREENSHOT_DIR="/tmp/kali-i3-screenshots"

# Test phases
PHASES=(
    "prereqs"
    "colors"
    "i18n"
    "user"
    "apt"
    "security"
    "interactive"
    "state"
    "restore"
    "final"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
