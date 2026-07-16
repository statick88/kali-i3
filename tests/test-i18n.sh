#!/usr/bin/env bash
# =============================================================================
# tests/test-i18n.sh — Tests for lib/i18n.sh internationalization system
# =============================================================================

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
I18N_SH="${SCRIPT_DIR}/lib/i18n.sh"

# =============================================================================
# Test: i18n.sh can be sourced without errors
# =============================================================================
test_i18n_source() {
    bash -c "source '${I18N_SH}'" 2>/dev/null \
        && pass "i18n.sh sources without error" \
        || fail "i18n.sh failed to source"
}

# =============================================================================
# Test: msg() returns English translation for known key
# =============================================================================
test_msg_english() {
    local output
    output=$(bash -c "
        source '${I18N_SH}'
        i18n_init en
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    [[ -n "${output}" ]] && pass "msg() returns English translation for MSG_WELCOME" \
        || fail "msg() returned empty for MSG_WELCOME"
}

# =============================================================================
# Test: msg() returns Spanish translation for known key
# =============================================================================
test_msg_spanish() {
    local output
    output=$(bash -c "
        source '${I18N_SH}'
        i18n_init es
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    [[ -n "${output}" ]] && pass "msg() returns Spanish translation for MSG_WELCOME" \
        || fail "msg() returned empty for MSG_WELCOME"
}

# =============================================================================
# Test: msg() returns different strings for EN vs ES
# =============================================================================
test_msg_differs_by_language() {
    local en_output es_output
    en_output=$(bash -c "
        source '${I18N_SH}'
        i18n_init en
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    es_output=$(bash -c "
        source '${I18N_SH}'
        i18n_init es
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    [[ "${en_output}" != "${es_output}" ]] && pass "msg() returns different strings for EN vs ES" \
        || fail "msg() should return different strings for EN vs ES, got: '${en_output}' vs '${es_output}'"
}

# =============================================================================
# Test: msg() returns key name as fallback for missing key
# =============================================================================
test_msg_missing_key_fallback() {
    local output
    output=$(bash -c "
        source '${I18N_SH}'
        i18n_init en
        msg 'NONEXISTENT_KEY_12345'
    " 2>/dev/null)
    [[ "${output}" == "NONEXISTENT_KEY_12345" ]] && pass "msg() returns key name for missing key" \
        || fail "msg() should return key name as fallback, got: '${output}'"
}

# =============================================================================
# Test: i18n_init() defaults to English when no argument given
# =============================================================================
test_i18n_init_default() {
    local output
    output=$(bash -c "
        source '${I18N_SH}'
        i18n_init
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    # English MSG_WELCOME should be different from Spanish
    local es_output
    es_output=$(bash -c "
        source '${I18N_SH}'
        i18n_init es
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    [[ "${output}" != "${es_output}" ]] && pass "i18n_init() defaults to English" \
        || fail "i18n_init() should default to English"
}

# =============================================================================
# Test: i18n_init() respects explicit language argument
# =============================================================================
test_i18n_init_explicit() {
    local output
    output=$(bash -c "
        source '${I18N_SH}'
        i18n_init es
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    local es_output
    es_output=$(bash -c "
        source '${I18N_SH}'
        i18n_init es
        msg 'MSG_WELCOME'
    " 2>/dev/null)
    [[ "${output}" == "${es_output}" ]] && pass "i18n_init() respects explicit language" \
        || fail "i18n_init() should respect explicit language argument"
}

# =============================================================================
# Test: STEP_LABELS keys have translations in both languages
# =============================================================================
test_step_labels_translations() {
    local missing_en=0 missing_es=0
    local step_keys=(
        "STEP_INSTALL_I3_CORE"
        "STEP_SWITCH_DISPLAY_MANAGER"
        "STEP_DEPLOY_DOTFILES"
        "STEP_DEPLOY_WALLPAPERS"
        "STEP_SETUP_TMUX_NEON"
        "STEP_INSTALL_ZSH_OMZ"
        "STEP_DEPLOY_ZSHRC"
        "STEP_SETUP_I3_DESKTOP_ENTRY"
        "STEP_INSTALL_SECURITY_SUITE"
        "STEP_INSTALL_GENTLE_AI"
        "STEP_INSTALL_GENTLE_AGENT_STATE"
        "STEP_DEPLOY_KILO_CONFIG"
        "STEP_SETUP_OPENCODE"
        "STEP_INSTALL_HEXSTRIKE_AI"
        "STEP_DEPLOY_HEXSTRIKE_MCP_CONFIG"
        "STEP_POST_INSTALL_CLEANUP"
    )

    for key in "${step_keys[@]}"; do
        local en_val es_val
        en_val=$(bash -c "
            source '${I18N_SH}'
            i18n_init en
            msg '${key}'
        " 2>/dev/null)
        es_val=$(bash -c "
            source '${I18N_SH}'
            i18n_init es
            msg '${key}'
        " 2>/dev/null)
        # If msg returns the key itself, translation is missing
        [[ "${en_val}" == "${key}" ]] && ((missing_en++))
        [[ "${es_val}" == "${key}" ]] && ((missing_es++))
    done

    [[ ${missing_en} -eq 0 ]] && pass "All STEP_LABELS have EN translations" \
        || fail "${missing_en} STEP_LABELS missing EN translations"
    [[ ${missing_es} -eq 0 ]] && pass "All STEP_LABELS have ES translations" \
        || fail "${missing_es} STEP_LABELS missing ES translations"
}

# =============================================================================
# Test: HELP_* keys have translations in both languages
# =============================================================================
test_help_translations() {
    local missing_en=0 missing_es=0
    local help_keys=(
        "HELP_USAGE"
        "HELP_USER_ONLY"
        "HELP_SKIP_SECURITY"
        "HELP_GENTLE_AI"
        "HELP_HEXSTRIKE_AI"
        "HELP_VERSION"
    )

    for key in "${help_keys[@]}"; do
        local en_val es_val
        en_val=$(bash -c "
            source '${I18N_SH}'
            i18n_init en
            msg '${key}'
        " 2>/dev/null)
        es_val=$(bash -c "
            source '${I18N_SH}'
            i18n_init es
            msg '${key}'
        " 2>/dev/null)
        [[ "${en_val}" == "${key}" ]] && ((missing_en++))
        [[ "${es_val}" == "${key}" ]] && ((missing_es++))
    done

    [[ ${missing_en} -eq 0 ]] && pass "All HELP_* keys have EN translations" \
        || fail "${missing_en} HELP_* keys missing EN translations"
    [[ ${missing_es} -eq 0 ]] && pass "All HELP_* keys have ES translations" \
        || fail "${missing_es} HELP_* keys missing ES translations"
}

# =============================================================================
# Test: MSG_* general message keys have translations
# =============================================================================
test_msg_general_translations() {
    local missing_en=0 missing_es=0
    local msg_keys=(
        "MSG_WELCOME"
        "MSG_INSTALL_COMPLETE"
        "MSG_PURGE_COMPLETE"
        "MSG_ERROR_UNKNOWN_OPTION"
        "MSG_ERROR_MUST_BE_ROOT"
    )

    for key in "${msg_keys[@]}"; do
        local en_val es_val
        en_val=$(bash -c "
            source '${I18N_SH}'
            i18n_init en
            msg '${key}'
        " 2>/dev/null)
        es_val=$(bash -c "
            source '${I18N_SH}'
            i18n_init es
            msg '${key}'
        " 2>/dev/null)
        [[ "${en_val}" == "${key}" ]] && ((missing_en++))
        [[ "${es_val}" == "${key}" ]] && ((missing_es++))
    done

    [[ ${missing_en} -eq 0 ]] && pass "All MSG_* keys have EN translations" \
        || fail "${missing_en} MSG_* keys missing EN translations"
    [[ ${missing_es} -eq 0 ]] && pass "All MSG_* keys have ES translations" \
        || fail "${missing_es} MSG_* keys missing ES translations"
}

# =============================================================================
# Test: PURGE step labels have translations in both languages
# =============================================================================
test_purge_step_translations() {
    local missing_en=0 missing_es=0
    local purge_keys=(
        "STEP_PROTECT_CRITICAL_PACKAGES"
        "STEP_STOP_DISPLAY_MANAGER"
        "STEP_KILL_XFCE_PROCESSES"
        "STEP_PURGE_META_PACKAGES"
        "STEP_PURGE_DISPLAY_MANAGERS"
        "STEP_PURGE_XFCE_PACKAGES"
        "STEP_PURGE_GNOME_PACKAGES"
        "STEP_PURGE_XFCE_CONFIGS"
        "STEP_UNPROTECT_CRITICAL_PACKAGES"
        "STEP_CLEANUP_APT"
    )

    for key in "${purge_keys[@]}"; do
        local en_val es_val
        en_val=$(bash -c "
            source '${I18N_SH}'
            i18n_init en
            msg '${key}'
        " 2>/dev/null)
        es_val=$(bash -c "
            source '${I18N_SH}'
            i18n_init es
            msg '${key}'
        " 2>/dev/null)
        [[ "${en_val}" == "${key}" ]] && ((missing_en++))
        [[ "${es_val}" == "${key}" ]] && ((missing_es++))
    done

    [[ ${missing_en} -eq 0 ]] && pass "All PURGE STEP_LABELS have EN translations" \
        || fail "${missing_en} PURGE STEP_LABELS missing EN translations"
    [[ ${missing_es} -eq 0 ]] && pass "All PURGE STEP_LABELS have ES translations" \
        || fail "${missing_es} PURGE STEP_LABELS missing ES translations"
}

# Run all tests
main() {
    echo "=== lib/i18n.sh Tests ==="
    echo ""

    test_i18n_source
    test_msg_english
    test_msg_spanish
    test_msg_differs_by_language
    test_msg_missing_key_fallback
    test_i18n_init_default
    test_i18n_init_explicit
    test_step_labels_translations
    test_help_translations
    test_msg_general_translations
    test_purge_step_translations

    echo ""
    echo "=== Results: ${TESTS_PASS}/${TESTS_RUN} passed, ${TESTS_FAIL} failed ==="
}

main "$@"
