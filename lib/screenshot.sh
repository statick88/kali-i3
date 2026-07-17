#!/usr/bin/env bash
# =============================================================================
# lib/screenshot.sh — Screenshot capture for VM testing
# =============================================================================

# Dependencies check
check_screenshot_deps() {
    local deps_ok=true

    # Check for maim (preferred)
    if command -v maim &>/dev/null; then
        SCREENSHOT_TOOL="maim"
    elif command -v import &>/dev/null; then
        SCREENSHOT_TOOL="import"
    elif command -v scrot &>/dev/null; then
        SCREENSHOT_TOOL="scrot"
    else
        warn "No screenshot tool found (maim, import, or scrot)"
        SCREENSHOT_TOOL=""
        deps_ok=false
    fi

    # Check for sshpass
    if ! command -v sshpass &>/dev/null; then
        warn "sshpass is required for remote screenshots"
        deps_ok=false
    fi

    $deps_ok
}

# Take screenshot on local machine
screenshot_local() {
    local output_path="${1:-/tmp/screenshot_$(date +%s).png}"

    case "${SCREENSHOT_TOOL}" in
    maim)
        if maim "${output_path}"; then
            echo "${output_path}"
            return 0
        fi
        ;;
    import)
        if import -window root "${output_path}"; then
            echo "${output_path}"
            return 0
        fi
        ;;
    scrot)
        if scrot "${output_path}"; then
            echo "${output_path}"
            return 0
        fi
        ;;
    esac

    err "Failed to capture local screenshot"
    return 1
}

# Take screenshot on remote VM via SSH
screenshot_remote() {
    local handle="$1"
    local output_path="${2:-/tmp/screenshot_$(date +%s).png}"

    if [[ -z "${handle}" ]]; then
        err "screenshot_remote: handle is required"
        return 1
    fi

    # Check if remote has screenshot tool
    local remote_tool=""
    local tool_check
    tool_check=$(ssh_execute "${handle}" "command -v maim || command -v import || command -v scrot" 2>/dev/null || true)

    if [[ "${tool_check}" == *"maim"* ]]; then
        remote_tool="maim"
    elif [[ "${tool_check}" == *"import"* ]]; then
        remote_tool="import"
    elif [[ "${tool_check}" == *"scrot"* ]]; then
        remote_tool="scrot"
    else
        warn "No screenshot tool on remote VM"
        return 1
    fi

    # Take screenshot on remote
    local remote_ts
    remote_ts="$(date +%s)"
    local remote_path="/tmp/remote_screenshot_${remote_ts}.png"
    case "${remote_tool}" in
    maim)
        ssh_execute "${handle}" "maim ${remote_path}" 2>/dev/null
        ;;
    import)
        ssh_execute "${handle}" "import -window root ${remote_path}" 2>/dev/null
        ;;
    scrot)
        ssh_execute "${handle}" "scrot ${remote_path}" 2>/dev/null
        ;;
    esac

    # Copy screenshot back
    if ssh_copy_from "${handle}" "${remote_path}" "${output_path}" 2>/dev/null; then
        # Cleanup remote
        ssh_execute "${handle}" "rm -f ${remote_path}" 2>/dev/null || true
        echo "${output_path}"
        return 0
    fi

    err "Failed to capture remote screenshot"
    return 1
}

# Take screenshot with phase name
screenshot_phase() {
    local phase="$1"
    local output_dir="${2:-/tmp/kali-i3-screenshots}"

    mkdir -p "${output_dir}" 2>/dev/null || true

    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"
    local output_path="${output_dir}/${phase}_${timestamp}.png"

    screenshot_local "${output_path}"
}

# Batch screenshots for all phases
screenshot_all_phases() {
    local phases=("prereqs" "colors" "i18n" "user" "apt" "security" "interactive" "state" "restore" "final")
    local output_dir="${1:-/tmp/kali-i3-screenshots}"

    mkdir -p "${output_dir}" 2>/dev/null || true

    for phase in "${phases[@]}"; do
        echo "Capturing phase: ${phase}"
        screenshot_phase "${phase}" "${output_dir}" || warn "Failed to capture ${phase}"
    done
}
