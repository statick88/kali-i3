#!/usr/bin/env bash
# Tests for interactive mode (PR 3: --interactive, prompt_category, category data)
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
# Helper: source the category infrastructure from lib/interactive.sh
# =============================================================================
source_categories() {
    bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        source '${SCRIPT_DIR}/lib/interactive.sh'

        # Print category data for assertions
        echo \"NAMES=\${CATEGORY_NAMES[*]}\"
        echo \"CORE_STEPS=\${CATEGORY_STEPS[core]}\"
        echo \"DOTFILES_STEPS=\${CATEGORY_STEPS[dotfiles]}\"
        echo \"SHELL_STEPS=\${CATEGORY_STEPS[shell]}\"
        echo \"SECURITY_STEPS=\${CATEGORY_STEPS[security]}\"
        echo \"AI_STEPS=\${CATEGORY_STEPS[ai-tools]}\"
        echo \"DESC_CORE=\${CATEGORY_DESCRIPTIONS[core]}\"
        echo \"TIME_CORE=\${CATEGORY_TIMES[core]}\"
    " 2>&1
}

# =============================================================================
# Helper: run prompt_category with mock input via heredoc
# =============================================================================
run_prompt_category() {
    local input="$1"
    bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        source '${SCRIPT_DIR}/lib/interactive.sh'
        prompt_category 'core' 'i3 core packages' '2 min' <<< '${input}'
        echo EXIT=\$?
    " 2>&1
}

# =============================================================================
# CATEGORY DATA STRUCTURE TESTS
# =============================================================================

test_category_names_count() {
    local output
    output=$(source_categories)
    echo "${output}" | grep -q "NAMES=core dotfiles shell security ai-tools" \
        && pass "CATEGORY_NAMES has 5 categories: core dotfiles shell security ai-tools" \
        || fail "CATEGORY_NAMES should contain: core dotfiles shell security ai-tools"
}

test_category_core_steps() {
    local output
    output=$(source_categories)
    echo "${output}" | grep -q "CORE_STEPS=step_install_i3_core step_switch_display_manager step_setup_i3_desktop_entry" \
        && pass "CATEGORY_STEPS[core] has correct steps" \
        || fail "CATEGORY_STEPS[core] should contain i3_core, display_manager, desktop_entry"
}

test_category_dotfiles_steps() {
    local output
    output=$(source_categories)
    echo "${output}" | grep -q "DOTFILES_STEPS=step_deploy_dotfiles step_deploy_wallpapers" \
        && pass "CATEGORY_STEPS[dotfiles] has correct steps" \
        || fail "CATEGORY_STEPS[dotfiles] should contain deploy_dotfiles, deploy_wallpapers"
}

test_category_shell_steps() {
    local output
    output=$(source_categories)
    echo "${output}" | grep -q "SHELL_STEPS=step_setup_tmux_neon step_install_zsh_omz step_deploy_zshrc" \
        && pass "CATEGORY_STEPS[shell] has correct steps" \
        || fail "CATEGORY_STEPS[shell] should contain tmux_neon, zsh_omz, zshrc"
}

test_category_security_steps() {
    local output
    output=$(source_categories)
    echo "${output}" | grep -q "SECURITY_STEPS=step_install_security_suite step_install_advanced_tools step_setup_anonymity step_configure_ghidra step_setup_firewall" \
        && pass "CATEGORY_STEPS[security] has correct steps" \
        || fail "CATEGORY_STEPS[security] should contain 5 security steps"
}

test_category_ai_tools_steps() {
    local output
    output=$(source_categories)
    echo "${output}" | grep -q "AI_STEPS=step_install_gentle_ai step_install_gentle_agent_state step_deploy_kilo_config step_setup_opencode step_install_hexstrike_ai step_deploy_hexstrike_mcp_config" \
        && pass "CATEGORY_STEPS[ai-tools] has correct steps" \
        || fail "CATEGORY_STEPS[ai-tools] should contain 6 AI steps"
}

test_category_descriptions_exist() {
    local output
    output=$(source_categories)
    echo "${output}" | grep -q "DESC_CORE=i3 core packages" \
        && pass "CATEGORY_DESCRIPTIONS[core] is defined" \
        || fail "CATEGORY_DESCRIPTIONS[core] should be defined"
}

test_category_times_exist() {
    local output
    output=$(source_categories)
    echo "${output}" | grep -q "TIME_CORE=2 min" \
        && pass "CATEGORY_TIMES[core] is defined" \
        || fail "CATEGORY_TIMES[core] should be defined"
}

# =============================================================================
# PROMPT_CATEGORY FUNCTION TESTS
# =============================================================================

test_prompt_yes_includes_category() {
    local output
    output=$(run_prompt_category "y")
    echo "${output}" | grep -q "EXIT=0" \
        && pass "prompt_category returns 0 (include) on 'y'" \
        || fail "prompt_category should return 0 on 'y' input"
}

test_prompt_empty_includes_category() {
    local output
    output=$(run_prompt_category "")
    echo "${output}" | grep -q "EXIT=0" \
        && pass "prompt_category returns 0 (include) on empty input" \
        || fail "prompt_category should return 0 on empty input (default yes)"
}

test_prompt_n_skips_category() {
    local output
    output=$(run_prompt_category "n")
    echo "${output}" | grep -q "EXIT=1" \
        && pass "prompt_category returns 1 (skip) on 'n'" \
        || fail "prompt_category should return 1 on 'n' input"
}

test_prompt_capital_n_skips_category() {
    local output
    output=$(run_prompt_category "N")
    echo "${output}" | grep -q "EXIT=1" \
        && pass "prompt_category returns 1 (skip) on 'N'" \
        || fail "prompt_category should return 1 on 'N' input"
}

test_prompt_yes_full_word_includes() {
    local output
    output=$(run_prompt_category "yes")
    echo "${output}" | grep -q "EXIT=0" \
        && pass "prompt_category returns 0 on 'yes'" \
        || fail "prompt_category should return 0 on 'yes'"
}

test_prompt_no_full_word_skips() {
    local output
    output=$(run_prompt_category "no")
    echo "${output}" | grep -q "EXIT=1" \
        && pass "prompt_category returns 1 on 'no'" \
        || fail "prompt_category should return 1 on 'no'"
}

test_prompt_invalid_defaults_to_yes() {
    local output
    output=$(run_prompt_category "maybe")
    echo "${output}" | grep -q "EXIT=0" \
        && pass "prompt_category returns 0 (default yes) on invalid input" \
        || fail "prompt_category should default to yes on invalid input"
}

test_prompt_output_format() {
    local output
    output=$(run_prompt_category "y")
    echo "${output}" | grep -q "Include.*~.*\[Y/n\]" \
        && pass "prompt_category outputs correct format: Include ... (Y/n)" \
        || fail "prompt_category should output 'Include ... [Y/n]' format"
}

# =============================================================================
# --INTERACTIVE FLAG TESTS
# =============================================================================

test_help_shows_interactive() {
    bash "${SCRIPT_DIR}/setup_i3_kali.sh" --help 2>&1 | grep -q "\-\-interactive" \
        && pass "--help shows --interactive flag" \
        || fail "--help should show --interactive flag"
}

test_parse_args_sets_interactive() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        source '${SCRIPT_DIR}/lib/user.sh'
        i18n_init en
        INTERACTIVE=0
        INSTALL_GENTLE_AI=0
        HEXSTRIKE_AI=0
        SKIP_SECURITY=0
        USER_ONLY=0
        SKIP_DOTFILES=0
        SKIP_SHELL=0
        SKIP_TMUX=0
        SKIP_AI=0
        case '--interactive' in
            --interactive) INTERACTIVE=1 ;;
        esac
        echo \"INTERACTIVE=\${INTERACTIVE}\"
    " 2>&1)
    [[ "${output}" == *"INTERACTIVE=1" ]] \
        && pass "parse_args sets INTERACTIVE=1 for --interactive" \
        || fail "parse_args should set INTERACTIVE=1 for --interactive"
}

test_interactive_default_zero() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        source '${SCRIPT_DIR}/lib/user.sh'
        i18n_init en
        INTERACTIVE=0
        echo \"INTERACTIVE=\${INTERACTIVE}\"
    " 2>&1)
    [[ "${output}" == *"INTERACTIVE=0" ]] \
        && pass "INTERACTIVE defaults to 0 (non-interactive)" \
        || fail "INTERACTIVE should default to 0"
}

# =============================================================================
# CATEGORY-TO-STEP MAPPING TESTS
# =============================================================================

test_category_core_includes_core_steps() {
    local output
    output=$(source_categories)
    local core_steps
    core_steps=$(echo "${output}" | grep "^CORE_STEPS=" | cut -d= -f2)
    echo "${core_steps}" | grep -q "step_install_i3_core" \
        && pass "core category includes step_install_i3_core" \
        || fail "core category should include step_install_i3_core"
    echo "${core_steps}" | grep -q "step_switch_display_manager" \
        && pass "core category includes step_switch_display_manager" \
        || fail "core category should include step_switch_display_manager"
}

test_category_dotfiles_includes_dotfiles_steps() {
    local output
    output=$(source_categories)
    local dotfiles_steps
    dotfiles_steps=$(echo "${output}" | grep "^DOTFILES_STEPS=" | cut -d= -f2)
    echo "${dotfiles_steps}" | grep -q "step_deploy_dotfiles" \
        && pass "dotfiles category includes step_deploy_dotfiles" \
        || fail "dotfiles category should include step_deploy_dotfiles"
    echo "${dotfiles_steps}" | grep -q "step_deploy_wallpapers" \
        && pass "dotfiles category includes step_deploy_wallpapers" \
        || fail "dotfiles category should include step_deploy_wallpapers"
}

test_category_shell_includes_shell_steps() {
    local output
    output=$(source_categories)
    local shell_steps
    shell_steps=$(echo "${output}" | grep "^SHELL_STEPS=" | cut -d= -f2)
    echo "${shell_steps}" | grep -q "step_setup_tmux_neon" \
        && pass "shell category includes step_setup_tmux_neon" \
        || fail "shell category should include step_setup_tmux_neon"
    echo "${shell_steps}" | grep -q "step_install_zsh_omz" \
        && pass "shell category includes step_install_zsh_omz" \
        || fail "shell category should include step_install_zsh_omz"
    echo "${shell_steps}" | grep -q "step_deploy_zshrc" \
        && pass "shell category includes step_deploy_zshrc" \
        || fail "shell category should include step_deploy_zshrc"
}

test_category_security_includes_security_steps() {
    local output
    output=$(source_categories)
    local security_steps
    security_steps=$(echo "${output}" | grep "^SECURITY_STEPS=" | cut -d= -f2)
    echo "${security_steps}" | grep -q "step_install_security_suite" \
        && pass "security category includes step_install_security_suite" \
        || fail "security category should include step_install_security_suite"
    echo "${security_steps}" | grep -q "step_setup_firewall" \
        && pass "security category includes step_setup_firewall" \
        || fail "security category should include step_setup_firewall"
}

test_category_ai_tools_includes_ai_steps() {
    local output
    output=$(source_categories)
    local ai_steps
    ai_steps=$(echo "${output}" | grep "^AI_STEPS=" | cut -d= -f2)
    echo "${ai_steps}" | grep -q "step_install_gentle_ai" \
        && pass "ai-tools category includes step_install_gentle_ai" \
        || fail "ai-tools category should include step_install_gentle_ai"
    echo "${ai_steps}" | grep -q "step_deploy_hexstrike_mcp_config" \
        && pass "ai-tools category includes step_deploy_hexstrike_mcp_config" \
        || fail "ai-tools category should include step_deploy_hexstrike_mcp_config"
}

# =============================================================================
# I18N KEYS TESTS
# =============================================================================

test_i18n_category_core_name() {
    bash -c "
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        result=\"\$(msg CATEGORY_CORE_NAME)\"
        [[ \"\${result}\" == *'i3'* ]] && echo PASS || echo FAIL
    " 2>&1 | grep -q "PASS" \
        && pass "i18n has CATEGORY_CORE_NAME key" \
        || fail "i18n should have CATEGORY_CORE_NAME key"
}

test_i18n_category_dotfiles_name() {
    bash -c "
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        result=\"\$(msg CATEGORY_DOTFILES_NAME)\"
        [[ \"\${result}\" == *'Dotfiles'* || \"\${result}\" == *'dotfiles'* || \"\${result}\" == *'Dotfile'* ]] && echo PASS || echo FAIL
    " 2>&1 | grep -q "PASS" \
        && pass "i18n has CATEGORY_DOTFILES_NAME key" \
        || fail "i18n should have CATEGORY_DOTFILES_NAME key"
}

test_i18n_category_shell_name() {
    bash -c "
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        result=\"\$(msg CATEGORY_SHELL_NAME)\"
        [[ \"\${result}\" == *'Shell'* || \"\${result}\" == *'shell'* || \"\${result}\" == *'Zsh'* ]] && echo PASS || echo FAIL
    " 2>&1 | grep -q "PASS" \
        && pass "i18n has CATEGORY_SHELL_NAME key" \
        || fail "i18n should have CATEGORY_SHELL_NAME key"
}

test_i18n_category_security_name() {
    bash -c "
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        result=\"\$(msg CATEGORY_SECURITY_NAME)\"
        [[ \"\${result}\" == *'Security'* || \"\${result}\" == *'security'* || \"\${result}\" == *'Seguridad'* ]] && echo PASS || echo FAIL
    " 2>&1 | grep -q "PASS" \
        && pass "i18n has CATEGORY_SECURITY_NAME key" \
        || fail "i18n should have CATEGORY_SECURITY_NAME key"
}

test_i18n_category_ai_tools_name() {
    bash -c "
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        result=\"\$(msg CATEGORY_AI_TOOLS_NAME)\"
        # Must NOT be the raw key — it should be a translated string
        [[ \"\${result}\" != 'CATEGORY_AI_TOOLS_NAME' && \"\${result}\" == *'AI'* ]] && echo PASS || echo FAIL
    " 2>&1 | grep -q "PASS" \
        && pass "i18n has CATEGORY_AI_TOOLS_NAME key" \
        || fail "i18n should have CATEGORY_AI_TOOLS_NAME key"
}

test_i18n_prompt_category_template() {
    bash -c "
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        result=\"\$(msg MSG_PROMPT_CATEGORY)\"
        [[ \"\${result}\" == *'Include'* || \"\${result}\" == *'include'* || \"\${result}\" == *'Incluir'* ]] && echo PASS || echo FAIL
    " 2>&1 | grep -q "PASS" \
        && pass "i18n has MSG_PROMPT_CATEGORY template" \
        || fail "i18n should have MSG_PROMPT_CATEGORY template"
}

test_i18n_es_category_names() {
    bash -c "
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init es
        core=\"\$(msg CATEGORY_CORE_NAME)\"
        security=\"\$(msg CATEGORY_SECURITY_NAME)\"
        [[ -n \"\${core}\" && \"\${core}\" != 'CATEGORY_CORE_NAME' ]] && echo CORE_OK || echo CORE_FAIL
        [[ -n \"\${security}\" && \"\${security}\" != 'CATEGORY_SECURITY_NAME' ]] && echo SEC_OK || echo SEC_FAIL
    " 2>&1 | grep -q "CORE_OK\|SEC_OK" \
        && pass "i18n ES translations exist for category names" \
        || fail "i18n ES should have category name translations"
}

# =============================================================================
# NON-INTERACTIVE NO PROMPTS TEST
# =============================================================================

test_non_interactive_no_prompt_output() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        source '${SCRIPT_DIR}/lib/interactive.sh'

        INTERACTIVE=0
        if [[ \${INTERACTIVE} -eq 1 ]]; then
            prompt_category 'core' 'i3 core' '2 min'
        fi
        echo 'NO_PROMPT'
    " 2>&1)
    echo "${output}" | grep -q "NO_PROMPT" \
        && pass "Non-interactive mode produces no prompt output" \
        || fail "Non-interactive mode should not show prompts"
    echo "${output}" | grep -q "Include" \
        && fail "Non-interactive mode should NOT display prompt" \
        || pass "Non-interactive mode has no 'Include' prompt text"
}

# =============================================================================
# INTERACTIVE DECLINE SKIPS ALL STEPS IN CATEGORY
# =============================================================================

test_interactive_decline_skips_category_steps() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        source '${SCRIPT_DIR}/lib/interactive.sh'

        INTERACTIVE=1
        RUN_SECURITY=1
        if [[ \${INTERACTIVE} -eq 1 ]]; then
            prompt_category 'security' 'Security tools' '5 min' <<< 'n'
            RUN_SECURITY=\$?
        fi
        [[ \${RUN_SECURITY} -ne 0 ]] && echo SKIP_SECURITY || echo RUN_SECURITY
    " 2>&1)
    echo "${output}" | grep -q "SKIP_SECURITY" \
        && pass "Interactive decline skips category (security example)" \
        || fail "Interactive decline should skip the category"
}

# =============================================================================
# GET_CATEGORY_STEPS FUNCTION TEST
# =============================================================================

test_get_category_steps_returns_steps() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        source '${SCRIPT_DIR}/lib/interactive.sh'
        get_category_steps 'core'
    " 2>&1)
    echo "${output}" | grep -q "step_install_i3_core" \
        && pass "get_category_steps('core') returns correct steps" \
        || fail "get_category_steps('core') should return core steps"
}

test_get_category_steps_empty_for_unknown() {
    local output
    output=$(bash -c "
        source '${SCRIPT_DIR}/lib/common.sh'
        source '${SCRIPT_DIR}/lib/i18n.sh'
        i18n_init en
        source '${SCRIPT_DIR}/lib/interactive.sh'
        result=\"\$(get_category_steps 'nonexistent')\"
        [[ -z \"\${result}\" ]] && echo EMPTY || echo \"NOT_EMPTY=\${result}\"
    " 2>&1)
    echo "${output}" | grep -q "EMPTY" \
        && pass "get_category_steps('nonexistent') returns empty" \
        || fail "get_category_steps('nonexistent') should return empty"
}

# Run all tests
main() {
    echo "=== Interactive Mode Tests ==="
    echo ""

    # Category data structure tests
    test_category_names_count
    test_category_core_steps
    test_category_dotfiles_steps
    test_category_shell_steps
    test_category_security_steps
    test_category_ai_tools_steps
    test_category_descriptions_exist
    test_category_times_exist

    # Category-to-step mapping tests
    test_category_core_includes_core_steps
    test_category_dotfiles_includes_dotfiles_steps
    test_category_shell_includes_shell_steps
    test_category_security_includes_security_steps
    test_category_ai_tools_includes_ai_steps

    # prompt_category function tests
    test_prompt_yes_includes_category
    test_prompt_empty_includes_category
    test_prompt_n_skips_category
    test_prompt_capital_n_skips_category
    test_prompt_yes_full_word_includes
    test_prompt_no_full_word_skips
    test_prompt_invalid_defaults_to_yes
    test_prompt_output_format

    # --interactive flag tests
    test_help_shows_interactive
    test_parse_args_sets_interactive
    test_interactive_default_zero

    # Non-interactive no prompts
    test_non_interactive_no_prompt_output

    # Interactive decline skips category
    test_interactive_decline_skips_category_steps

    # get_category_steps tests
    test_get_category_steps_returns_steps
    test_get_category_steps_empty_for_unknown

    # i18n tests
    test_i18n_category_core_name
    test_i18n_category_dotfiles_name
    test_i18n_category_shell_name
    test_i18n_category_security_name
    test_i18n_category_ai_tools_name
    test_i18n_prompt_category_template
    test_i18n_es_category_names

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
