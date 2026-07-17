#!/usr/bin/env bash
# shellcheck disable=SC2034  # Arrays used via eval indirection; cross-file sourcing
# =============================================================================
# lib/i18n.sh — Internationalization (i18n) infrastructure
# =============================================================================
# Provides message catalog with ES/EN support, language detection, and
# msg() function for translated output.
#
# Compatible with bash 3.2+ (macOS default) — uses indexed arrays instead of
# associative arrays for broad compatibility.
# =============================================================================

# Indexed array dictionaries for translations (bash 3.x compatible)
# Keys and values stored as parallel entries: KEY at even index, VALUE at odd
LANG_ES_keys=()
LANG_ES_vals=()
LANG_EN_keys=()
LANG_EN_vals=()

# Current active language
CURRENT_LANG="en"

# =============================================================================
# _i18n_set — Store a key/value pair in a catalog (internal helper)
# Usage: _i18n_set LANG_EN KEY "value"
# =============================================================================
_i18n_set() {
    local catalog="$1"
    local key="$2"
    local val="$3"
    local keys_var="${catalog}_keys"
    local vals_var="${catalog}_vals"
    local i count

    # Get current count of keys
    eval "count=\${#${keys_var}[@]}"

    # Check if key already exists — update if so
    for ((i = 0; i < count; i++)); do
        eval "current_key=\${${keys_var}[$i]}"
        if [[ "$current_key" == "$key" ]]; then
            eval "${vals_var}[$i]=\"\$val\""
            return
        fi
    done
    # Key not found — append
    eval "${keys_var}+=(\"\$key\")"
    eval "${vals_var}+=(\"\$val\")"
}

# =============================================================================
# _i18n_get — Retrieve a value by key from a catalog (internal helper)
# Usage: _i18n_get LANG_EN KEY
# Returns: value string (empty if not found)
# =============================================================================
_i18n_get() {
    local catalog="$1"
    local key="$2"
    local keys_var="${catalog}_keys"
    local vals_var="${catalog}_vals"
    local i count current_key current_val

    eval "count=\${#${keys_var}[@]}"

    for ((i = 0; i < count; i++)); do
        eval "current_key=\${${keys_var}[$i]}"
        if [[ "$current_key" == "$key" ]]; then
            eval "current_val=\${${vals_var}[$i]}"
            printf '%s' "$current_val"
            return 0
        fi
    done
    return 1
}

# =============================================================================
# i18n_init — Initialize i18n with a given language
# Priority: explicit argument > default "en"
# =============================================================================
i18n_init() {
    local lang="${1:-en}"
    CURRENT_LANG="${lang}"

    # --- General messages (MSG_*) ---
    _i18n_set LANG_EN MSG_WELCOME "Welcome to Kali i3 Setup"
    _i18n_set LANG_ES MSG_WELCOME "Bienvenido a la instalación de Kali i3"

    _i18n_set LANG_EN MSG_INSTALL_COMPLETE "Installation complete"
    _i18n_set LANG_ES MSG_INSTALL_COMPLETE "Instalación completa"

    _i18n_set LANG_EN MSG_PURGE_COMPLETE "XFCE purge complete"
    _i18n_set LANG_ES MSG_PURGE_COMPLETE "Purga de XFCE completa"

    _i18n_set LANG_EN MSG_ERROR_UNKNOWN_OPTION "Unknown option"
    _i18n_set LANG_ES MSG_ERROR_UNKNOWN_OPTION "Opción desconocida"

    _i18n_set LANG_EN MSG_ERROR_MUST_BE_ROOT "Must run as root (sudo)"
    _i18n_set LANG_ES MSG_ERROR_MUST_BE_ROOT "Debe ejecutar como root (sudo)"

    _i18n_set LANG_EN MSG_RESUMING_FROM "Resuming from step"
    _i18n_set LANG_ES MSG_RESUMING_FROM "Resumiendo desde el paso"

    _i18n_set LANG_EN MSG_LOG "Log"
    _i18n_set LANG_ES MSG_LOG "Registro"

    _i18n_set LANG_EN MSG_TARGET "Target"
    _i18n_set LANG_ES MSG_TARGET "Destino"

    _i18n_set LANG_EN MSG_REBOOT_PROMPT "Reboot now to start clean i3 session? [Y/n]:"
    _i18n_set LANG_ES MSG_REBOOT_PROMPT "Reiniciar ahora para iniciar sesión limpia de i3? [Y/n]:"

    _i18n_set LANG_EN MSG_REBOOT_MANUAL "Reboot manually when ready."
    _i18n_set LANG_ES MSG_REBOOT_MANUAL "Reinicie manualmente cuando esté listo."

    # --- Setup step labels (STEP_*) ---
    _i18n_set LANG_EN STEP_INSTALL_I3_CORE "Installing i3 core packages"
    _i18n_set LANG_ES STEP_INSTALL_I3_CORE "Instalando paquetes core de i3"

    _i18n_set LANG_EN STEP_SWITCH_DISPLAY_MANAGER "Switching to SDDM display manager"
    _i18n_set LANG_ES STEP_SWITCH_DISPLAY_MANAGER "Cambiando al gestor de pantalla SDDM"

    _i18n_set LANG_EN STEP_DEPLOY_DOTFILES "Deploy NEON minimal dotfiles"
    _i18n_set LANG_ES STEP_DEPLOY_DOTFILES "Desplegando dotfiles NEON minimal"

    _i18n_set LANG_EN STEP_DEPLOY_WALLPAPERS "Deploy minimal wallpaper"
    _i18n_set LANG_ES STEP_DEPLOY_WALLPAPERS "Desplegando fondo de pantalla minimal"

    _i18n_set LANG_EN STEP_SETUP_TMUX_NEON "Setup TMUX with NEON theme"
    _i18n_set LANG_ES STEP_SETUP_TMUX_NEON "Configurando TMUX con tema NEON"

    _i18n_set LANG_EN STEP_INSTALL_ZSH_OMZ "Install Zsh + Oh-My-Zsh + Powerlevel10k"
    _i18n_set LANG_ES STEP_INSTALL_ZSH_OMZ "Instalando Zsh + Oh-My-Zsh + Powerlevel10k"

    _i18n_set LANG_EN STEP_DEPLOY_ZSHRC "Deploy .zshrc configuration"
    _i18n_set LANG_ES STEP_DEPLOY_ZSHRC "Desplegando configuración .zshrc"

    _i18n_set LANG_EN STEP_SETUP_I3_DESKTOP_ENTRY "Register i3 desktop session"
    _i18n_set LANG_ES STEP_SETUP_I3_DESKTOP_ENTRY "Registrando sesión de escritorio i3"

    _i18n_set LANG_EN STEP_INSTALL_FIRA_CODE_FONT "Install FiraCode Nerd Font"
    _i18n_set LANG_ES STEP_INSTALL_FIRA_CODE_FONT "Instalando FiraCode Nerd Font"

    _i18n_set LANG_EN STEP_DEPLOY_HACKER_PROFILE "Deploy Hacker Security Profile"
    _i18n_set LANG_ES STEP_DEPLOY_HACKER_PROFILE "Desplegando perfil de seguridad Hacker"

    _i18n_set LANG_EN STEP_INSTALL_SECURITY_SUITE "Install Kali security tools suite"
    _i18n_set LANG_ES STEP_INSTALL_SECURITY_SUITE "Instalando suite de herramientas de seguridad Kali"

    _i18n_set LANG_EN STEP_INSTALL_GENTLE_AI "Install gentle-ai CLI"
    _i18n_set LANG_ES STEP_INSTALL_GENTLE_AI "Instalando CLI gentle-ai"

    _i18n_set LANG_EN STEP_INSTALL_GENTLE_AGENT_STATE "Install gentle-agent-state integration"
    _i18n_set LANG_ES STEP_INSTALL_GENTLE_AGENT_STATE "Instalando integración gentle-agent-state"

    _i18n_set LANG_EN STEP_DEPLOY_KILO_CONFIG "Configure Kilo Code settings"
    _i18n_set LANG_ES STEP_DEPLOY_KILO_CONFIG "Configurando ajustes de Kilo Code"

    _i18n_set LANG_EN STEP_SETUP_OPENCODE "Configure openCode settings"
    _i18n_set LANG_ES STEP_SETUP_OPENCODE "Configurando ajustes de openCode"

    _i18n_set LANG_EN STEP_INSTALL_HEXSTRIKE_AI "Install HexStrike AI"
    _i18n_set LANG_ES STEP_INSTALL_HEXSTRIKE_AI "Instalando HexStrike AI"

    _i18n_set LANG_EN STEP_DEPLOY_HEXSTRIKE_MCP_CONFIG "Deploy HexStrike AI MCP config"
    _i18n_set LANG_ES STEP_DEPLOY_HEXSTRIKE_MCP_CONFIG "Desplegando configuración MCP de HexStrike AI"

    _i18n_set LANG_EN STEP_POST_INSTALL_CLEANUP "Post-install cleanup"
    _i18n_set LANG_ES STEP_POST_INSTALL_CLEANUP "Limpieza post-instalación"

    # --- Security arsenal step labels (STEP_*) ---
    _i18n_set LANG_EN STEP_INSTALL_ADVANCED_TOOLS "Installing advanced security tools"
    _i18n_set LANG_ES STEP_INSTALL_ADVANCED_TOOLS "Instalando herramientas de seguridad avanzadas"

    _i18n_set LANG_EN STEP_SETUP_ANONYMITY "Setting up anonymity tools (Tor, Proxychains)"
    _i18n_set LANG_ES STEP_SETUP_ANONYMITY "Configurando herramientas de anonimato (Tor, Proxychains)"

    _i18n_set LANG_EN STEP_CONFIGURE_GHIDRA "Configure Ghidra Java environment"
    _i18n_set LANG_ES STEP_CONFIGURE_GHIDRA "Configurar entorno Java de Ghidra"

    _i18n_set LANG_EN STEP_SETUP_FIREWALL "Setting up UFW firewall"
    _i18n_set LANG_ES STEP_SETUP_FIREWALL "Configurando cortafuegos UFW"

    # --- Security arsenal messages (MSG_*) ---
    _i18n_set LANG_EN MSG_TOR_STARTED "Tor service started"
    _i18n_set LANG_ES MSG_TOR_STARTED "Servicio Tor iniciado"

    _i18n_set LANG_EN MSG_PROXYCHAINS_CONFIGURED "Proxychains configured for Tor"
    _i18n_set LANG_ES MSG_PROXYCHAINS_CONFIGURED "Proxychains configurado para Tor"

    _i18n_set LANG_EN MSG_UFW_ENABLED "UFW firewall enabled"
    _i18n_set LANG_ES MSG_UFW_ENABLED "Cortafuegos UFW habilitado"

    _i18n_set LANG_EN MSG_NETEXEC_INSTALLED "NetExec installed"
    _i18n_set LANG_ES MSG_NETEXEC_INSTALLED "NetExec instalado"

    _i18n_set LANG_EN MSG_SLIVER_INSTALLED "Sliver installed"
    _i18n_set LANG_ES MSG_SLIVER_INSTALLED "Sliver instalado"

    _i18n_set LANG_EN MSG_GHIDRA_JAVA_SET "JAVA_HOME set for Ghidra"
    _i18n_set LANG_ES MSG_GHIDRA_JAVA_SET "JAVA_HOME configurado para Ghidra"

    # --- Purge step labels (STEP_PURGE_*) ---
    _i18n_set LANG_EN STEP_PROTECT_CRITICAL_PACKAGES "Protecting critical system packages"
    _i18n_set LANG_ES STEP_PROTECT_CRITICAL_PACKAGES "Protegiendo paquetes críticos del sistema"

    _i18n_set LANG_EN STEP_STOP_DISPLAY_MANAGER "Stopping display manager"
    _i18n_set LANG_ES STEP_STOP_DISPLAY_MANAGER "Deteniendo gestor de pantalla"

    _i18n_set LANG_EN STEP_KILL_XFCE_PROCESSES "Terminating XFCE processes"
    _i18n_set LANG_ES STEP_KILL_XFCE_PROCESSES "Terminando procesos XFCE"

    _i18n_set LANG_EN STEP_PURGE_META_PACKAGES "Purging desktop meta-packages"
    _i18n_set LANG_ES STEP_PURGE_META_PACKAGES "Purgando meta-paquetes de escritorio"

    _i18n_set LANG_EN STEP_PURGE_DISPLAY_MANAGERS "Purging old display managers"
    _i18n_set LANG_ES STEP_PURGE_DISPLAY_MANAGERS "Purgando gestores de pantalla antiguos"

    _i18n_set LANG_EN STEP_PURGE_XFCE_PACKAGES "Purging XFCE packages"
    _i18n_set LANG_ES STEP_PURGE_XFCE_PACKAGES "Purgando paquetes XFCE"

    _i18n_set LANG_EN STEP_PURGE_GNOME_PACKAGES "Purging GNOME packages"
    _i18n_set LANG_ES STEP_PURGE_GNOME_PACKAGES "Purgando paquetes GNOME"

    _i18n_set LANG_EN STEP_PURGE_XFCE_CONFIGS "Removing XFCE configuration files"
    _i18n_set LANG_ES STEP_PURGE_XFCE_CONFIGS "Eliminando archivos de configuración XFCE"

    _i18n_set LANG_EN STEP_UNPROTECT_CRITICAL_PACKAGES "Unprotecting critical packages"
    _i18n_set LANG_ES STEP_UNPROTECT_CRITICAL_PACKAGES "Desprotegiendo paquetes críticos"

    _i18n_set LANG_EN STEP_CLEANUP_APT "Running APT cleanup"
    _i18n_set LANG_ES STEP_CLEANUP_APT "Ejecutando limpieza de APT"

    # --- Help text (HELP_*) ---
    _i18n_set LANG_EN HELP_USAGE "Usage: sudo %s [--user-only] [--skip-security] [--skip-dotfiles] [--skip-shell] [--skip-tmux] [--skip-ai] [--gentle-ai] [--hexstrike-ai] [--lang en|es] [--version]"
    _i18n_set LANG_ES HELP_USAGE "Uso: sudo %s [--user-only] [--skip-security] [--skip-dotfiles] [--skip-shell] [--skip-tmux] [--skip-ai] [--gentle-ai] [--hexstrike-ai] [--lang en|es] [--version]"

    _i18n_set LANG_EN HELP_USER_ONLY "Dotfiles only (no sudo required)"
    _i18n_set LANG_ES HELP_USER_ONLY "Solo dotfiles (no requiere sudo)"

    _i18n_set LANG_EN HELP_SKIP_SECURITY "Skip security tools installation"
    _i18n_set LANG_ES HELP_SKIP_SECURITY "Omitir instalación de herramientas de seguridad"

    _i18n_set LANG_EN HELP_SKIP_DOTFILES "Skip dotfiles and wallpapers deployment"
    _i18n_set LANG_ES HELP_SKIP_DOTFILES "Omitir despliegue de dotfiles y fondos de pantalla"

    _i18n_set LANG_EN HELP_SKIP_SHELL "Skip Zsh, Oh-My-Zsh, and .zshrc deployment"
    _i18n_set LANG_ES HELP_SKIP_SHELL "Omitir Zsh, Oh-My-Zsh y despliegue de .zshrc"

    _i18n_set LANG_EN HELP_SKIP_TMUX "Skip TMUX Neon setup"
    _i18n_set LANG_ES HELP_SKIP_TMUX "Omitir configuración de TMUX Neon"

    _i18n_set LANG_EN HELP_SKIP_AI "Skip AI tools installation (gentle-ai, HexStrike, opencode)"
    _i18n_set LANG_ES HELP_SKIP_AI "Omitir instalación de herramientas AI (gentle-ai, HexStrike, opencode)"

    _i18n_set LANG_EN HELP_GENTLE_AI "Install full Gentle-AI stack"
    _i18n_set LANG_ES HELP_GENTLE_AI "Instalar stack completo de Gentle-AI"

    _i18n_set LANG_EN HELP_HEXSTRIKE_AI "Install HexStrike AI + MCP server"
    _i18n_set LANG_ES HELP_HEXSTRIKE_AI "Instalar HexStrike AI + servidor MCP"

    _i18n_set LANG_EN HELP_VERSION "Show version from CHANGELOG.md"
    _i18n_set LANG_ES HELP_VERSION "Mostrar versión desde CHANGELOG.md"

    _i18n_set LANG_EN HELP_LANG "Set language (en|es), default: en"
    _i18n_set LANG_ES HELP_LANG "Establecer idioma (en|es), predeterminado: en"

    _i18n_set LANG_EN HELP_INTERACTIVE "Prompt before each category for selective install"
    _i18n_set LANG_ES HELP_INTERACTIVE "Solicitar antes de cada categoría para instalación selectiva"

    # --- Category names (CATEGORY_*) ---
    _i18n_set LANG_EN CATEGORY_CORE_NAME "i3 core packages and display manager"
    _i18n_set LANG_ES CATEGORY_CORE_NAME "Paquetes core de i3 y gestor de pantalla"

    _i18n_set LANG_EN CATEGORY_DOTFILES_NAME "NEON theme dotfiles and wallpapers"
    _i18n_set LANG_ES CATEGORY_DOTFILES_NAME "Dotfiles y fondos de pantalla tema NEON"

    _i18n_set LANG_EN CATEGORY_SHELL_NAME "Zsh, Oh-My-Zsh, Powerlevel10k, and .zshrc"
    _i18n_set LANG_ES CATEGORY_SHELL_NAME "Zsh, Oh-My-Zsh, Powerlevel10k y .zshrc"

    _i18n_set LANG_EN CATEGORY_SECURITY_NAME "Security tools, anonymity, firewall"
    _i18n_set LANG_ES CATEGORY_SECURITY_NAME "Herramientas de seguridad, anonimato, cortafuegos"

    _i18n_set LANG_EN CATEGORY_AI_TOOLS_NAME "AI coding assistants and MCP servers"
    _i18n_set LANG_ES CATEGORY_AI_TOOLS_NAME "Asistentes de codificación AI y servidores MCP"

    # --- Interactive prompt template ---
    _i18n_set LANG_EN MSG_PROMPT_CATEGORY "Include %s (~%s)? [Y/n] "
    _i18n_set LANG_ES MSG_PROMPT_CATEGORY "¿Incluir %s (~%s)? [Y/n] "
}

# =============================================================================
# msg — Look up a translation key and return the localized string
# Falls back to the key name if not found.
# =============================================================================
msg() {
    local key="$1"
    # Bash 3.x compatible uppercasing
    local lang_upper
    lang_upper="$(printf '%s' "${CURRENT_LANG}" | tr '[:lower:]' '[:upper:]')"
    local catalog_name="LANG_${lang_upper}"

    local value
    if value="$(_i18n_get "${catalog_name}" "${key}")"; then
        printf '%s' "${value}"
    else
        printf '%s' "${key}"
    fi
}
