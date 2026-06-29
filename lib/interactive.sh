#!/usr/bin/env bash
# =============================================================================
# lib/interactive.sh — Interactive mode category selection
# =============================================================================
# Provides prompt_category() and category data structures for --interactive mode.
# =============================================================================

# Category names (ordered)
CATEGORY_NAMES=(core dotfiles shell security ai-tools)

# Category-to-step mapping
declare -A CATEGORY_STEPS=(
    [core]="step_install_i3_core step_switch_display_manager step_setup_i3_desktop_entry"
    [dotfiles]="step_deploy_dotfiles step_deploy_wallpapers"
    [shell]="step_setup_tmux_neon step_install_zsh_omz step_deploy_zshrc step_deploy_hacker_profile"
    [security]="step_install_security_suite step_install_advanced_tools step_setup_anonymity step_configure_ghidra step_setup_firewall"
    [ai-tools]="step_install_gentle_ai step_install_gentle_agent_state step_deploy_kilo_config step_setup_opencode step_install_hexstrike_ai step_deploy_hexstrike_mcp_config"
)

# Human-readable descriptions (hardcoded EN — msg() not available at source time)
declare -A CATEGORY_DESCRIPTIONS=(
    [core]="i3 core packages and display manager"
    [dotfiles]="NEON theme dotfiles and wallpapers"
    [shell]="Zsh, Oh-My-Zsh, Powerlevel10k, and .zshrc"
    [security]="Security tools, anonymity, firewall"
    [ai-tools]="AI coding assistants and MCP servers"
)

# Estimated time per category
declare -A CATEGORY_TIMES=(
    [core]="2 min"
    [dotfiles]="1 min"
    [shell]="3 min"
    [security]="5 min"
    [ai-tools]="4 min"
)

# prompt_category — ask user whether to include a category
# Usage: prompt_category "category_name" "description" "estimated_time"
# Returns: 0 = include (yes), 1 = skip (no)
prompt_category() {
    local category_name="$1"
    local description="$2"
    local estimated_time="$3"
    local response

    printf "%s" "$(printf "$(msg MSG_PROMPT_CATEGORY)" "${description}" "${estimated_time}")"
    read -r response

    case "${response}" in
        [nN]|[nN][oO]) return 1 ;;
        *) return 0 ;;
    esac
}

# get_category_steps — return the steps for a given category
get_category_steps() {
    local category_name="$1"
    echo "${CATEGORY_STEPS[${category_name}]:-}"
}
