#!/usr/bin/env bash
# =============================================================================
# lib/state.sh — Persistent state management and progress display
# =============================================================================
# Provides load_state(), save_state(), mark_completed(), is_completed(),
# show_progress()
#
# Requires: STATE_FILE, STATE_VERSION, COMPLETED_STEPS to be set by caller
# =============================================================================

load_state() {
    [[ -f "${STATE_FILE}" ]] || return 0
    [[ -r "${STATE_FILE}" ]] || return 0

    local version
    version=$(grep '"version"' "${STATE_FILE}" | head -1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/') || return 0

    if [[ "${version}" != "${STATE_VERSION}" ]]; then
        warn "State file version mismatch (found: ${version}, expected: ${STATE_VERSION}), starting fresh"
        return 0
    fi

    local in_array=0
    while IFS= read -r line; do
        if [[ "${in_array}" -eq 0 ]]; then
            [[ "${line}" =~ \[ ]] && in_array=1
        else
            [[ "${line}" =~ ^[[:space:]]*\]$ ]] && break
            local step
            step=$(echo "${line}" | sed 's/.*"\(.*\)".*/\1/')
            [[ -n "${step}" ]] && COMPLETED_STEPS["${step}"]=1
        fi
    done < "${STATE_FILE}"
}

save_state() {
    local -a steps=()
    for key in "${!COMPLETED_STEPS[@]}"; do
        [[ "${COMPLETED_STEPS[$key]}" -eq 1 ]] && steps+=("${key}")
    done

    local tmpfile="${STATE_FILE}.tmp.$$"
    {
        printf '{\n'
        printf '  "version": "%s",\n' "${STATE_VERSION}"
        printf '  "completed_steps": [\n'
        local first=1
        for step in "${steps[@]}"; do
            [[ ${first} -eq 0 ]] && printf ',\n'
            printf '    "%s"' "${step}"
            first=0
        done
        printf '\n  ]\n'
        printf '}\n'
    } > "${tmpfile}"

    mv -f "${tmpfile}" "${STATE_FILE}"
    chown "${TARGET_UID}:${TARGET_GID}" "${STATE_FILE}" 2>/dev/null || true
}

mark_completed() {
    COMPLETED_STEPS["$1"]=1
    save_state
}

is_completed() {
    [[ "${COMPLETED_STEPS[$1]:-0}" -eq 1 ]]
}

show_progress() {
    local current=$1
    local total=$2
    local label="${3:-$1}"
    local percent=$(( current * 100 / total ))
    local filled=$(( percent / 5 ))
    [[ ${filled} -gt 20 ]] && filled=20
    local empty=$(( 20 - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    printf "\r${C_NEON_PINK}[${C_NEON_GREEN}%s${C_NEON_PINK}]${C_NEON_CYAN} %3d%%${C_RESET} - %-40s" "${bar}" "${percent}" "${label}"
    printf "\n"
}
