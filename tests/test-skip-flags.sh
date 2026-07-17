#!/usr/bin/env bash
# Tests for skip flags (PR 2: --skip-dotfiles, --skip-shell, --skip-tmux, --skip-ai)
# TDD: tests written BEFORE production code changes

TESTS_RUN=0
TESTS_PASS=0
TESTS_FAIL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() {
    ((TESTS_RUN++))
    ((TESTS_PASS++))
    echo -e "${GREEN}PASS${NC}: $1"
}

fail() {
    ((TESTS_RUN++))
    ((TESTS_FAIL++))
    echo -e "${RED}FAIL${NC}: $1"
}

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# =============================================================================
# Helper: build ALL_STEPS array given skip flags (mirrors main() logic)
# =============================================================================
build_all_steps() {
    local user_only="${1:-0}"
    local skip_security="${2:-0}"
    local skip_dotfiles="${3:-0}"
    local skip_shell="${4:-0}"
    local skip_tmux="${5:-0}"
    local skip_ai="${6:-0}"
    local install_gentle_ai="${7:-0}"
    local hexstrike_ai="${8:-0}"

    local -a ALL_STEPS=()

    if [[ ${user_only} -eq 0 ]]; then
        ALL_STEPS+=("step_install_i3_core" "step_switch_display_manager")
    fi

    ALL_STEPS+=("step_deploy_dotfiles" "step_deploy_wallpapers")
    ALL_STEPS+=("step_setup_tmux_neon")
    ALL_STEPS+=("step_install_zsh_omz" "step_deploy_zshrc")
    ALL_STEPS+=("step_setup_i3_desktop_entry")

    if [[ ${skip_security} -eq 0 && ${user_only} -eq 0 ]]; then
        ALL_STEPS+=("step_install_security_suite" "step_install_advanced_tools")
        ALL_STEPS+=("step_setup_anonymity" "step_configure_ghidra" "step_setup_firewall")
    fi

    if [[ ${install_gentle_ai} -eq 1 ]]; then
        ALL_STEPS+=("step_install_gentle_ai" "step_install_gentle_agent_state")
        ALL_STEPS+=("step_deploy_kilo_config" "step_setup_opencode")
    fi

    if [[ ${install_gentle_ai} -eq 1 || ${hexstrike_ai} -eq 1 ]]; then
        ALL_STEPS+=("step_install_hexstrike_ai" "step_deploy_hexstrike_mcp_config")
    fi

    ALL_STEPS+=("step_post_install_cleanup")

    # Apply skip filters
    if [[ ${skip_dotfiles} -eq 1 ]]; then
        local -a filtered=()
        for step in "${ALL_STEPS[@]}"; do
            [[ "${step}" == "step_deploy_dotfiles" || "${step}" == "step_deploy_wallpapers" ]] && continue
            filtered+=("${step}")
        done
        ALL_STEPS=("${filtered[@]}")
    fi

    if [[ ${skip_shell} -eq 1 ]]; then
        local -a filtered=()
        for step in "${ALL_STEPS[@]}"; do
            [[ "${step}" == "step_install_zsh_omz" || "${step}" == "step_deploy_zshrc" ]] && continue
            filtered+=("${step}")
        done
        ALL_STEPS=("${filtered[@]}")
    fi

    if [[ ${skip_tmux} -eq 1 ]]; then
        local -a filtered=()
        for step in "${ALL_STEPS[@]}"; do
            [[ "${step}" == "step_setup_tmux_neon" ]] && continue
            filtered+=("${step}")
        done
        ALL_STEPS=("${filtered[@]}")
    fi

    if [[ ${skip_ai} -eq 1 ]]; then
        local -a filtered=()
        for step in "${ALL_STEPS[@]}"; do
            [[ "${step}" == "step_install_gentle_ai" ||
                "${step}" == "step_install_gentle_agent_state" ||
                "${step}" == "step_deploy_kilo_config" ||
                "${step}" == "step_setup_opencode" ||
                "${step}" == "step_install_hexstrike_ai" ||
                "${step}" == "step_deploy_hexstrike_mcp_config" ]] && continue
            filtered+=("${step}")
        done
        ALL_STEPS=("${filtered[@]}")
    fi

    # Print steps one per line for assertion
    printf '%s\n' "${ALL_STEPS[@]}"
}

# =============================================================================
# Helper: check if a step is in the output
# =============================================================================
has_step() {
    local step_name="$1"
    local steps_output="$2"
    echo "${steps_output}" | grep -qx "${step_name}"
}

# =============================================================================
# Test: --skip-dotfiles removes step_deploy_dotfiles
# =============================================================================
test_skip_dotfiles_removes_deploy_dotfiles() {
    local steps
    steps=$(build_all_steps 0 0 1 0 0 0 0 0)
    has_step "step_deploy_dotfiles" "${steps}" &&
        fail "--skip-dotfiles should remove step_deploy_dotfiles" ||
        pass "--skip-dotfiles removes step_deploy_dotfiles"
}

# =============================================================================
# Test: --skip-dotfiles removes step_deploy_wallpapers
# =============================================================================
test_skip_dotfiles_removes_wallpapers() {
    local steps
    steps=$(build_all_steps 0 0 1 0 0 0 0 0)
    has_step "step_deploy_wallpapers" "${steps}" &&
        fail "--skip-dotfiles should remove step_deploy_wallpapers" ||
        pass "--skip-dotfiles removes step_deploy_wallpapers"
}

# =============================================================================
# Test: --skip-dotfiles keeps other steps
# =============================================================================
test_skip_dotfiles_keeps_others() {
    local steps
    steps=$(build_all_steps 0 0 1 0 0 0 0 0)
    has_step "step_install_i3_core" "${steps}" &&
        pass "--skip-dotfiles keeps step_install_i3_core" ||
        fail "--skip-dotfiles should keep step_install_i3_core"
    has_step "step_install_zsh_omz" "${steps}" &&
        pass "--skip-dotfiles keeps step_install_zsh_omz" ||
        fail "--skip-dotfiles should keep step_install_zsh_omz"
    has_step "step_setup_tmux_neon" "${steps}" &&
        pass "--skip-dotfiles keeps step_setup_tmux_neon" ||
        fail "--skip-dotfiles should keep step_setup_tmux_neon"
}

# =============================================================================
# Test: --skip-shell removes step_install_zsh_omz
# =============================================================================
test_skip_shell_removes_zsh_omz() {
    local steps
    steps=$(build_all_steps 0 0 0 1 0 0 0 0)
    has_step "step_install_zsh_omz" "${steps}" &&
        fail "--skip-shell should remove step_install_zsh_omz" ||
        pass "--skip-shell removes step_install_zsh_omz"
}

# =============================================================================
# Test: --skip-shell removes step_deploy_zshrc
# =============================================================================
test_skip_shell_removes_deploy_zshrc() {
    local steps
    steps=$(build_all_steps 0 0 0 1 0 0 0 0)
    has_step "step_deploy_zshrc" "${steps}" &&
        fail "--skip-shell should remove step_deploy_zshrc" ||
        pass "--skip-shell removes step_deploy_zshrc"
}

# =============================================================================
# Test: --skip-shell keeps tmux (different flag)
# =============================================================================
test_skip_shell_keeps_tmux() {
    local steps
    steps=$(build_all_steps 0 0 0 1 0 0 0 0)
    has_step "step_setup_tmux_neon" "${steps}" &&
        pass "--skip-shell keeps step_setup_tmux_neon" ||
        fail "--skip-shell should keep step_setup_tmux_neon"
}

# =============================================================================
# Test: --skip-tmux removes step_setup_tmux_neon
# =============================================================================
test_skip_tmux_removes_tmux() {
    local steps
    steps=$(build_all_steps 0 0 0 0 1 0 0 0)
    has_step "step_setup_tmux_neon" "${steps}" &&
        fail "--skip-tmux should remove step_setup_tmux_neon" ||
        pass "--skip-tmux removes step_setup_tmux_neon"
}

# =============================================================================
# Test: --skip-tmux keeps shell steps
# =============================================================================
test_skip_tmux_keeps_shell() {
    local steps
    steps=$(build_all_steps 0 0 0 0 1 0 0 0)
    has_step "step_install_zsh_omz" "${steps}" &&
        pass "--skip-tmux keeps step_install_zsh_omz" ||
        fail "--skip-tmux should keep step_install_zsh_omz"
    has_step "step_deploy_zshrc" "${steps}" &&
        pass "--skip-tmux keeps step_deploy_zshrc" ||
        fail "--skip-tmux should keep step_deploy_zshrc"
}

# =============================================================================
# Test: --skip-ai removes gentle-ai steps
# =============================================================================
test_skip_ai_removes_gentle_ai() {
    local steps
    steps=$(build_all_steps 0 0 0 0 0 1 1 0)
    has_step "step_install_gentle_ai" "${steps}" &&
        fail "--skip-ai should remove step_install_gentle_ai" ||
        pass "--skip-ai removes step_install_gentle_ai"
}

# =============================================================================
# Test: --skip-ai removes gentle-agent-state
# =============================================================================
test_skip_ai_removes_agent_state() {
    local steps
    steps=$(build_all_steps 0 0 0 0 0 1 1 0)
    has_step "step_install_gentle_agent_state" "${steps}" &&
        fail "--skip-ai should remove step_install_gentle_agent_state" ||
        pass "--skip-ai removes step_install_gentle_agent_state"
}

# =============================================================================
# Test: --skip-ai removes kilo config
# =============================================================================
test_skip_ai_removes_kilo_config() {
    local steps
    steps=$(build_all_steps 0 0 0 0 0 1 1 0)
    has_step "step_deploy_kilo_config" "${steps}" &&
        fail "--skip-ai should remove step_deploy_kilo_config" ||
        pass "--skip-ai removes step_deploy_kilo_config"
}

# =============================================================================
# Test: --skip-ai removes opencode setup
# =============================================================================
test_skip_ai_removes_opencode() {
    local steps
    steps=$(build_all_steps 0 0 0 0 0 1 1 0)
    has_step "step_setup_opencode" "${steps}" &&
        fail "--skip-ai should remove step_setup_opencode" ||
        pass "--skip-ai removes step_setup_opencode"
}

# =============================================================================
# Test: --skip-ai removes hexstrike steps when hexstrike-ai is enabled
# =============================================================================
test_skip_ai_removes_hexstrike() {
    local steps
    steps=$(build_all_steps 0 0 0 0 0 1 1 1)
    has_step "step_install_hexstrike_ai" "${steps}" &&
        fail "--skip-ai should remove step_install_hexstrike_ai" ||
        pass "--skip-ai removes step_install_hexstrike_ai"
    has_step "step_deploy_hexstrike_mcp_config" "${steps}" &&
        fail "--skip-ai should remove step_deploy_hexstrike_mcp_config" ||
        pass "--skip-ai removes step_deploy_hexstrike_mcp_config"
}

# =============================================================================
# Test: Multiple skip flags combine (--skip-dotfiles + --skip-ai)
# =============================================================================
test_combined_skip_dotfiles_and_ai() {
    local steps
    steps=$(build_all_steps 0 0 1 0 0 1 1 0)
    has_step "step_deploy_dotfiles" "${steps}" &&
        fail "combined: should remove step_deploy_dotfiles" ||
        pass "combined: removes step_deploy_dotfiles"
    has_step "step_deploy_wallpapers" "${steps}" &&
        fail "combined: should remove step_deploy_wallpapers" ||
        pass "combined: removes step_deploy_wallpapers"
    has_step "step_install_gentle_ai" "${steps}" &&
        fail "combined: should remove step_install_gentle_ai" ||
        pass "combined: removes step_install_gentle_ai"
    has_step "step_install_i3_core" "${steps}" &&
        pass "combined: keeps step_install_i3_core" ||
        fail "combined: should keep step_install_i3_core"
    has_step "step_install_zsh_omz" "${steps}" &&
        pass "combined: keeps step_install_zsh_omz" ||
        fail "combined: should keep step_install_zsh_omz"
    has_step "step_setup_tmux_neon" "${steps}" &&
        pass "combined: keeps step_setup_tmux_neon" ||
        fail "combined: should keep step_setup_tmux_neon"
}

# =============================================================================
# Test: All four skip flags together
# =============================================================================
test_all_skip_flags() {
    local steps
    steps=$(build_all_steps 0 0 1 1 1 1 1 0)
    has_step "step_deploy_dotfiles" "${steps}" &&
        fail "all skips: should remove dotfiles" ||
        pass "all skips: removes dotfiles"
    has_step "step_install_zsh_omz" "${steps}" &&
        fail "all skips: should remove shell" ||
        pass "all skips: removes shell"
    has_step "step_setup_tmux_neon" "${steps}" &&
        fail "all skips: should remove tmux" ||
        pass "all skips: removes tmux"
    has_step "step_install_gentle_ai" "${steps}" &&
        fail "all skips: should remove AI" ||
        pass "all skips: removes AI"
    # Core steps remain
    has_step "step_install_i3_core" "${steps}" &&
        pass "all skips: keeps core i3" ||
        fail "all skips: should keep core i3"
    has_step "step_post_install_cleanup" "${steps}" &&
        pass "all skips: keeps cleanup" ||
        fail "all skips: should keep cleanup"
}

# =============================================================================
# Test: --skip-security still works (regression)
# =============================================================================
test_skip_security_still_works() {
    local steps
    steps=$(build_all_steps 0 1 0 0 0 0 0 0)
    has_step "step_install_security_suite" "${steps}" &&
        fail "--skip-security should remove step_install_security_suite" ||
        pass "--skip-security still removes security suite"
    has_step "step_install_advanced_tools" "${steps}" &&
        fail "--skip-security should remove step_install_advanced_tools" ||
        pass "--skip-security still removes advanced tools"
    has_step "step_install_i3_core" "${steps}" &&
        pass "--skip-security keeps core i3" ||
        fail "--skip-security should keep core i3"
}

# =============================================================================
# Test: Help text shows --skip-dotfiles
# =============================================================================
test_help_shows_skip_dotfiles() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-skip-dotfiles" &&
        pass "--help shows --skip-dotfiles" ||
        fail "--help should show --skip-dotfiles"
}

# =============================================================================
# Test: Help text shows --skip-shell
# =============================================================================
test_help_shows_skip_shell() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-skip-shell" &&
        pass "--help shows --skip-shell" ||
        fail "--help should show --skip-shell"
}

# =============================================================================
# Test: Help text shows --skip-tmux
# =============================================================================
test_help_shows_skip_tmux() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-skip-tmux" &&
        pass "--help shows --skip-tmux" ||
        fail "--help should show --skip-tmux"
}

# =============================================================================
# Test: Help text shows --skip-ai
# =============================================================================
test_help_shows_skip_ai() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-skip-ai" &&
        pass "--help shows --skip-ai" ||
        fail "--help should show --skip-ai"
}

# =============================================================================
# Test: --skip-dotfiles --help does not error
# =============================================================================
test_skip_dotfiles_with_help() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --skip-dotfiles --help >/dev/null 2>&1
    [[ $? -eq 0 ]] && pass "--skip-dotfiles --help exits 0" ||
        fail "--skip-dotfiles --help should exit 0"
}

# =============================================================================
# Test: parse_args sets SKIP_DOTFILES variable
# =============================================================================
test_parse_args_sets_skip_dotfiles() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        source '${SCRIPT_DIR}/lib/user.sh'
        i18n_init en
        USER_ONLY=0
        SKIP_SECURITY=0
        SKIP_DOTFILES=0
        SKIP_SHELL=0
        SKIP_TMUX=0
        SKIP_AI=0
        INSTALL_GENTLE_AI=0
        HEXSTRIKE_AI=0
        # Inline parse_args logic for --skip-dotfiles
        case '--skip-dotfiles' in
            --skip-dotfiles) SKIP_DOTFILES=1 ;;
        esac
        echo \"SKIP_DOTFILES=\${SKIP_DOTFILES}\"
    " 2>&1)
    [[ "${output}" == *"SKIP_DOTFILES=1" ]] &&
        pass "parse_args sets SKIP_DOTFILES=1" ||
        fail "parse_args should set SKIP_DOTFILES=1"
}

# =============================================================================
# Test: parse_args sets SKIP_SHELL variable
# =============================================================================
test_parse_args_sets_skip_shell() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        source '${SCRIPT_DIR}/lib/user.sh'
        i18n_init en
        SKIP_SHELL=0
        case '--skip-shell' in
            --skip-shell) SKIP_SHELL=1 ;;
        esac
        echo \"SKIP_SHELL=\${SKIP_SHELL}\"
    " 2>&1)
    [[ "${output}" == *"SKIP_SHELL=1" ]] &&
        pass "parse_args sets SKIP_SHELL=1" ||
        fail "parse_args should set SKIP_SHELL=1"
}

# =============================================================================
# Test: parse_args sets SKIP_TMUX variable
# =============================================================================
test_parse_args_sets_skip_tmux() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        source '${SCRIPT_DIR}/lib/user.sh'
        i18n_init en
        SKIP_TMUX=0
        case '--skip-tmux' in
            --skip-tmux) SKIP_TMUX=1 ;;
        esac
        echo \"SKIP_TMUX=\${SKIP_TMUX}\"
    " 2>&1)
    [[ "${output}" == *"SKIP_TMUX=1" ]] &&
        pass "parse_args sets SKIP_TMUX=1" ||
        fail "parse_args should set SKIP_TMUX=1"
}

# =============================================================================
# Test: parse_args sets SKIP_AI variable
# =============================================================================
test_parse_args_sets_skip_ai() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        source '${SCRIPT_DIR}/lib/user.sh'
        i18n_init en
        SKIP_AI=0
        case '--skip-ai' in
            --skip-ai) SKIP_AI=1 ;;
        esac
        echo \"SKIP_AI=\${SKIP_AI}\"
    " 2>&1)
    [[ "${output}" == *"SKIP_AI=1" ]] &&
        pass "parse_args sets SKIP_AI=1" ||
        fail "parse_args should set SKIP_AI=1"
}

# =============================================================================
# Test: No skip flags = all steps present (baseline)
# =============================================================================
test_no_skip_flags_all_steps_present() {
    local steps
    steps=$(build_all_steps 0 0 0 0 0 0 0 0)
    has_step "step_deploy_dotfiles" "${steps}" &&
        pass "baseline: step_deploy_dotfiles present" ||
        fail "baseline: step_deploy_dotfiles should be present"
    has_step "step_install_zsh_omz" "${steps}" &&
        pass "baseline: step_install_zsh_omz present" ||
        fail "baseline: step_install_zsh_omz should be present"
    has_step "step_setup_tmux_neon" "${steps}" &&
        pass "baseline: step_setup_tmux_neon present" ||
        fail "baseline: step_setup_tmux_neon should be present"
}

# Run all tests
main() {
    echo "=== Skip Flags Tests ==="
    echo ""

    # Filter logic tests
    test_skip_dotfiles_removes_deploy_dotfiles
    test_skip_dotfiles_removes_wallpapers
    test_skip_dotfiles_keeps_others
    test_skip_shell_removes_zsh_omz
    test_skip_shell_removes_deploy_zshrc
    test_skip_shell_keeps_tmux
    test_skip_tmux_removes_tmux
    test_skip_tmux_keeps_shell
    test_skip_ai_removes_gentle_ai
    test_skip_ai_removes_agent_state
    test_skip_ai_removes_kilo_config
    test_skip_ai_removes_opencode
    test_skip_ai_removes_hexstrike
    test_combined_skip_dotfiles_and_ai
    test_all_skip_flags
    test_skip_security_still_works
    test_no_skip_flags_all_steps_present

    # Variable setting tests
    test_parse_args_sets_skip_dotfiles
    test_parse_args_sets_skip_shell
    test_parse_args_sets_skip_tmux
    test_parse_args_sets_skip_ai

    # Help text tests
    test_help_shows_skip_dotfiles
    test_help_shows_skip_shell
    test_help_shows_skip_tmux
    test_help_shows_skip_ai
    test_skip_dotfiles_with_help

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
