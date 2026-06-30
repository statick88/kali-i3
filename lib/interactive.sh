#!/usr/bin/env bash
# =============================================================================
# lib/interactive.sh — Interactive mode category selection
# =============================================================================
# Provides prompt_category() and category data structures for --interactive mode.
# =============================================================================

# Category names (ordered)
CATEGORY_NAMES=(core dotfiles shell security ai-tools)

# Category-to-step mapping (indexed arrays — parallel keys/values for portability)
_CATEGORY_KEYS=(core dotfiles shell security ai-tools)
CATEGORY_STEPS=(
    "step_install_i3_core step_switch_display_manager step_setup_i3_desktop_entry"
    "step_deploy_dotfiles step_deploy_wallpapers"
    "step_setup_tmux_neon step_install_zsh_omz step_deploy_zshrc step_deploy_hacker_profile"
    "step_install_security_suite step_install_advanced_tools step_setup_anonymity step_configure_ghidra step_setup_firewall"
    "step_install_gentle_ai step_install_gentle_agent_state step_deploy_kilo_config step_setup_opencode step_install_hexstrike_ai step_deploy_hexstrike_mcp_config"
)

# Human-readable descriptions (hardcoded EN — msg() not available at source time)
CATEGORY_DESCRIPTIONS=(
    "i3 core packages and display manager"
    "NEON theme dotfiles and wallpapers"
    "Zsh, Oh-My-Zsh, Powerlevel10k, and .zshrc"
    "Security tools, anonymity, firewall"
    "AI coding assistants and MCP servers"
)

# Estimated time per category
CATEGORY_TIMES=(
    "2 min"
    "1 min"
    "3 min"
    "5 min"
    "4 min"
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

# _category_index — find index of category in _CATEGORY_KEYS
_category_index() {
    local i
    for i in "${!_CATEGORY_KEYS[@]}"; do
        [[ "${_CATEGORY_KEYS[$i]}" == "$1" ]] && echo "$i" && return 0
    done
    return 1
}

# get_category_steps — return the steps for a given category
get_category_steps() {
    local idx
    idx=$(_category_index "$1") || return 1
    echo "${CATEGORY_STEPS[$idx]:-}"
}
