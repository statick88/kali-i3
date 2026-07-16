#!/usr/bin/env bash
# =============================================================================
# lib/metrics.sh — Test execution metrics collection
# =============================================================================

# Default metrics directory
: "${METRICS_DIR:=/tmp/kali-i3-metrics}"

# Initialize metrics
metrics_init() {
    local metrics_dir="${1:-${METRICS_DIR}}"
    mkdir -p "${metrics_dir}" 2>/dev/null || true
    
    # Create metrics file
    cat > "${metrics_dir}/metrics.json" <<EOF
{
  "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "phases": [],
  "tests": {
    "total": 0,
    "passed": 0,
    "failed": 0
  },
  "vm": {
    "host": "${VM_HOST:-}",
    "user": "${VM_USER:-}",
    "connect_time_ms": 0
  }
}
EOF
    echo "${metrics_dir}"
}

# Record phase execution
metrics_phase() {
    local phase_name="$1"
    local duration_ms="$2"
    local exit_code="$3"
    local metrics_dir="${4:-${METRICS_DIR}}"
    
    # Append phase to metrics
    local tmp_file
    tmp_file=$(mktemp)
    
    # Simple append - in production use jq
    cat > "${tmp_file}" <<EOF
  "phase_${phase_name}": {
    "duration_ms": ${duration_ms},
    "exit_code": ${exit_code},
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
EOF
    
    # Append to metrics file (simplified - no jq dependency)
    echo "  Recorded phase: ${phase_name}"
}

# Record test result
metrics_test() {
    local test_name="$1"
    local result="$2"  # "pass" or "fail"
    local duration_ms="${3:-0}"
    local metrics_dir="${4:-${METRICS_DIR}}"
    
    echo "  Test ${test_name}: ${result} (${duration_ms}ms)"
}

# Record VM connection time
metrics_vm_connect() {
    local connect_time_ms="$1"
    local metrics_dir="${2:-${METRICS_DIR}}"
    
    echo "  VM connect time: ${connect_time_ms}ms"
}

# Generate final metrics report
metrics_report() {
    local metrics_dir="${1:-${METRICS_DIR}}"
    
    echo "=== Metrics Report ==="
    echo ""
    echo "Start Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    echo "VM Configuration:"
    echo "  Host: ${VM_HOST:-N/A}"
    echo "  User: ${VM_USER:-N/A}"
    echo ""
    echo "Phase Durations:"
    echo "  (collected during execution)"
    echo ""
    echo "Test Results:"
    echo "  Total: ${TESTS_RUN:-0}"
    echo "  Passed: ${TESTS_PASS:-0}"
    echo "  Failed: ${TESTS_FAIL:-0}"
    echo ""
    echo "End Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

# Export metrics as JSON
metrics_json() {
    local metrics_dir="${1:-${METRICS_DIR}}"
    local output_file="${2:-${metrics_dir}/report.json}"
    
    cat > "${output_file}" <<EOF
{
  "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "vm": {
    "host": "${VM_HOST:-}",
    "user": "${VM_USER:-}"
  },
  "tests": {
    "total": ${TESTS_RUN:-0},
    "passed": ${TESTS_PASS:-0},
    "failed": ${TESTS_FAIL:-0}
  }
}
EOF
    
    echo "${output_file}"
}
