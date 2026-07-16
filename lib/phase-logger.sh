#!/usr/bin/env bash
# =============================================================================
# lib/phase-logger.sh — Phase execution logging and metrics
# =============================================================================

# Default log directory
: "${PHASE_LOG_DIR:=/tmp/kali-i3-phases}"

# Initialize phase logging
phase_logger_init() {
    local log_dir="${1:-${PHASE_LOG_DIR}}"
    mkdir -p "${log_dir}" 2>/dev/null || true
    echo "${log_dir}"
}

# Start a phase timer
phase_start() {
    local phase_name="$1"
    local log_dir="${2:-${PHASE_LOG_DIR}}"
    
    # Record start time
    local start_time
    start_time=$(date +%s%N)
    echo "${start_time}" > "${log_dir}/${phase_name}.start"
    
    # Log phase start
    echo "=== Phase: ${phase_name} ==="
    echo "Start: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Create phase log file
    echo "Phase: ${phase_name}" > "${log_dir}/${phase_name}.log"
    echo "Start: $(date '+%Y-%m-%d %H:%M:%S')" >> "${log_dir}/${phase_name}.log"
    echo "---" >> "${log_dir}/${phase_name}.log"
}

# End a phase timer
phase_end() {
    local phase_name="$1"
    local exit_code="${2:-0}"
    local log_dir="${3:-${PHASE_LOG_DIR}}"
    
    # Get start time
    local start_time=0
    if [[ -f "${log_dir}/${phase_name}.start" ]]; then
        start_time=$(cat "${log_dir}/${phase_name}.start")
    fi
    
    # Calculate duration
    local end_time
    end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    local duration_s=$(( duration_ms / 1000 ))
    local duration_min=$(( duration_s / 60 ))
    
    # Log phase end
    echo "---" >> "${log_dir}/${phase_name}.log"
    echo "End: $(date '+%Y-%m-%d %H:%M:%S')" >> "${log_dir}/${phase_name}.log"
    echo "Duration: ${duration_s}s (${duration_min}m ${duration_s}s)" >> "${log_dir}/${phase_name}.log"
    echo "Exit Code: ${exit_code}" >> "${log_dir}/${phase_name}.log"
    
    # Print summary
    echo "End: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Duration: ${duration_s}s"
    echo "Exit Code: ${exit_code}"
    echo "=== End Phase: ${phase_name} ==="
    echo ""
    
    # Cleanup
    rm -f "${log_dir}/${phase_name}.start" 2>/dev/null || true
    
    # Return exit code
    return "${exit_code}"
}

# Log phase step
phase_step() {
    local phase_name="$1"
    local step_name="$2"
    local log_dir="${3:-${PHASE_LOG_DIR}}"
    
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "[${timestamp}] Step: ${step_name}" >> "${log_dir}/${phase_name}.log" 2>/dev/null || true
    echo "  Step: ${step_name}"
}

# Log phase error
phase_error() {
    local phase_name="$1"
    local error_msg="$2"
    local log_dir="${3:-${PHASE_LOG_DIR}}"
    
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "[${timestamp}] ERROR: ${error_msg}" >> "${log_dir}/${phase_name}.log" 2>/dev/null || true
    echo "  ERROR: ${error_msg}"
}

# Get phase summary
phase_summary() {
    local phase_name="$1"
    local log_dir="${2:-${PHASE_LOG_DIR}}"
    
    if [[ -f "${log_dir}/${phase_name}.log" ]]; then
        cat "${log_dir}/${phase_name}.log"
    else
        echo "No log found for phase: ${phase_name}"
        return 1
    fi
}

# Get all phases summary
phases_summary() {
    local log_dir="${1:-${PHASE_LOG_DIR}}"
    
    echo "=== Phase Summary ==="
    echo ""
    
    for log_file in "${log_dir}"/*.log; do
        if [[ -f "${log_file}" ]]; then
            local phase_name
            phase_name=$(basename "${log_file}" .log)
            echo "Phase: ${phase_name}"
            grep -E "^(Start|End|Duration|Exit Code):" "${log_file}" 2>/dev/null || true
            echo ""
        fi
    done
}

# Export phase metrics as JSON
phases_metrics_json() {
    local log_dir="${1:-${PHASE_LOG_DIR}}"
    local output_file="${2:-${log_dir}/metrics.json}"
    
    echo "{" > "${output_file}"
    echo "  \"phases\": [" >> "${output_file}"
    
    local first=true
    for log_file in "${log_dir}"/*.log; do
        if [[ -f "${log_file}" ]]; then
            local phase_name
            phase_name=$(basename "${log_file}" .log)
            
            # Skip metrics.json
            [[ "${phase_name}" == "metrics" ]] && continue
            
            if ! $first; then
                echo "    ," >> "${output_file}"
            fi
            first=false
            
            local start_time
            start_time=$(grep "^Start:" "${log_file}" 2>/dev/null | cut -d' ' -f2-)
            local end_time
            end_time=$(grep "^End:" "${log_file}" 2>/dev/null | cut -d' ' -f2-)
            local duration
            duration=$(grep "^Duration:" "${log_file}" 2>/dev/null | cut -d' ' -f2-)
            local exit_code
            exit_code=$(grep "^Exit Code:" "${log_file}" 2>/dev/null | cut -d' ' -f3-)
            
            cat >> "${output_file}" <<EOF
    {
      "name": "${phase_name}",
      "start": "${start_time:-}",
      "end": "${end_time:-}",
      "duration": "${duration:-}",
      "exit_code": ${exit_code:-0}
    }
EOF
        fi
    done
    
    echo "  ]" >> "${output_file}"
    echo "}" >> "${output_file}"
    
    echo "${output_file}"
}
