#!/usr/bin/env bash
# =============================================================================
# lib/i18n.sh — Internationalization (i18n) infrastructure
# =============================================================================
# Provides message catalog with ES/EN support, language detection, and
# msg() function for translated output.
# =============================================================================

# Associative array dictionaries for translations
declare -A LANG_ES LANG_EN

# Current active language
CURRENT_LANG="en"

# =============================================================================
# i18n_init — Initialize i18n with a given language
# Priority: explicit argument > default "en"
# =============================================================================
i18n_init() {
    local lang="${1:-en}"
    CURRENT_LANG="${lang}"

    # --- General messages (MSG_*) ---
    LANG_EN[MSG_WELCOME]="Welcome to Kali i3 Setup"
    LANG_ES[MSG_WELCOME]="Bienvenido a la instalación de Kali i3"

    LANG_EN[MSG_INSTALL_COMPLETE]="Installation complete"
    LANG_ES[MSG_INSTALL_COMPLETE]="Instalación completa"

    LANG_EN[MSG_PURGE_COMPLETE]="XFCE purge complete"
    LANG_ES[MSG_PURGE_COMPLETE]="Purga de XFCE completa"

    LANG_EN[MSG_ERROR_UNKNOWN_OPTION]="Unknown option"
    LANG_ES[MSG_ERROR_UNKNOWN_OPTION]="Opción desconocida"

    LANG_EN[MSG_ERROR_MUST_BE_ROOT]="Must run as root (sudo)"
    LANG_ES[MSG_ERROR_MUST_BE_ROOT]="Debe ejecutar como root (sudo)"

    LANG_EN[MSG_RESUMING_FROM]="Resuming from step"
    LANG_ES[MSG_RESUMING_FROM]="Resumiendo desde el paso"

    LANG_EN[MSG_LOG]="Log"
    LANG_ES[MSG_LOG]="Registro"

    LANG_EN[MSG_TARGET]="Target"
    LANG_ES[MSG_TARGET]="Destino"

    LANG_EN[MSG_REBOOT_PROMPT]="Reboot now to start clean i3 session? [Y/n]:"
    LANG_ES[MSG_REBOOT_PROMPT]="Reiniciar ahora para iniciar sesión limpia de i3? [Y/n]:"

    LANG_EN[MSG_REBOOT_MANUAL]="Reboot manually when ready."
    LANG_ES[MSG_REBOOT_MANUAL]="Reinicie manualmente cuando esté listo."

    # --- Setup step labels (STEP_*) ---
    LANG_EN[STEP_INSTALL_I3_CORE]="Installing i3 core packages"
    LANG_ES[STEP_INSTALL_I3_CORE]="Instalando paquetes core de i3"

    LANG_EN[STEP_SWITCH_DISPLAY_MANAGER]="Switching to SDDM display manager"
    LANG_ES[STEP_SWITCH_DISPLAY_MANAGER]="Cambiando al gestor de pantalla SDDM"

    LANG_EN[STEP_DEPLOY_DOTFILES]="Deploy NEON minimal dotfiles"
    LANG_ES[STEP_DEPLOY_DOTFILES]="Desplegando dotfiles NEON minimal"

    LANG_EN[STEP_DEPLOY_WALLPAPERS]="Deploy minimal wallpaper"
    LANG_ES[STEP_DEPLOY_WALLPAPERS]="Desplegando fondo de pantalla minimal"

    LANG_EN[STEP_SETUP_TMUX_NEON]="Setup TMUX with NEON theme"
    LANG_ES[STEP_SETUP_TMUX_NEON]="Configurando TMUX con tema NEON"

    LANG_EN[STEP_INSTALL_ZSH_OMZ]="Install Zsh + Oh-My-Zsh + Powerlevel10k"
    LANG_ES[STEP_INSTALL_ZSH_OMZ]="Instalando Zsh + Oh-My-Zsh + Powerlevel10k"

    LANG_EN[STEP_DEPLOY_ZSHRC]="Deploy .zshrc configuration"
    LANG_ES[STEP_DEPLOY_ZSHRC]="Desplegando configuración .zshrc"

    LANG_EN[STEP_SETUP_I3_DESKTOP_ENTRY]="Register i3 desktop session"
    LANG_ES[STEP_SETUP_I3_DESKTOP_ENTRY]="Registrando sesión de escritorio i3"

    LANG_EN[STEP_INSTALL_SECURITY_SUITE]="Install Kali security tools suite"
    LANG_ES[STEP_INSTALL_SECURITY_SUITE]="Instalando suite de herramientas de seguridad Kali"

    LANG_EN[STEP_INSTALL_GENTLE_AI]="Install gentle-ai CLI"
    LANG_ES[STEP_INSTALL_GENTLE_AI]="Instalando CLI gentle-ai"

    LANG_EN[STEP_INSTALL_GENTLE_AGENT_STATE]="Install gentle-agent-state integration"
    LANG_ES[STEP_INSTALL_GENTLE_AGENT_STATE]="Instalando integración gentle-agent-state"

    LANG_EN[STEP_DEPLOY_KILO_CONFIG]="Configure Kilo Code settings"
    LANG_ES[STEP_DEPLOY_KILO_CONFIG]="Configurando ajustes de Kilo Code"

    LANG_EN[STEP_SETUP_OPENCODE]="Configure openCode settings"
    LANG_ES[STEP_SETUP_OPENCODE]="Configurando ajustes de openCode"

    LANG_EN[STEP_INSTALL_HEXSTRIKE_AI]="Install HexStrike AI"
    LANG_ES[STEP_INSTALL_HEXSTRIKE_AI]="Instalando HexStrike AI"

    LANG_EN[STEP_DEPLOY_HEXSTRIKE_MCP_CONFIG]="Deploy HexStrike AI MCP config"
    LANG_ES[STEP_DEPLOY_HEXSTRIKE_MCP_CONFIG]="Desplegando configuración MCP de HexStrike AI"

    LANG_EN[STEP_POST_INSTALL_CLEANUP]="Post-install cleanup"
    LANG_ES[STEP_POST_INSTALL_CLEANUP]="Limpieza post-instalación"

    # --- Security arsenal step labels (STEP_*) ---
    LANG_EN[STEP_INSTALL_ADVANCED_TOOLS]="Installing advanced security tools"
    LANG_ES[STEP_INSTALL_ADVANCED_TOOLS]="Instalando herramientas de seguridad avanzadas"

    LANG_EN[STEP_SETUP_ANONYMITY]="Setting up anonymity tools (Tor, Proxychains)"
    LANG_ES[STEP_SETUP_ANONYMITY]="Configurando herramientas de anonimato (Tor, Proxychains)"

    LANG_EN[STEP_CONFIGURE_GHIDRA]="Configure Ghidra Java environment"
    LANG_ES[STEP_CONFIGURE_GHIDRA]="Configurar entorno Java de Ghidra"

    LANG_EN[STEP_SETUP_FIREWALL]="Setting up UFW firewall"
    LANG_ES[STEP_SETUP_FIREWALL]="Configurando cortafuegos UFW"

    # --- Security arsenal messages (MSG_*) ---
    LANG_EN[MSG_TOR_STARTED]="Tor service started"
    LANG_ES[MSG_TOR_STARTED]="Servicio Tor iniciado"

    LANG_EN[MSG_PROXYCHAINS_CONFIGURED]="Proxychains configured for Tor"
    LANG_ES[MSG_PROXYCHAINS_CONFIGURED]="Proxychains configurado para Tor"

    LANG_EN[MSG_UFW_ENABLED]="UFW firewall enabled"
    LANG_ES[MSG_UFW_ENABLED]="Cortafuegos UFW habilitado"

    LANG_EN[MSG_NETEXEC_INSTALLED]="NetExec installed"
    LANG_ES[MSG_NETEXEC_INSTALLED]="NetExec instalado"

    LANG_EN[MSG_SLIVER_INSTALLED]="Sliver installed"
    LANG_ES[MSG_SLIVER_INSTALLED]="Sliver instalado"

    LANG_EN[MSG_GHIDRA_JAVA_SET]="JAVA_HOME set for Ghidra"
    LANG_ES[MSG_GHIDRA_JAVA_SET]="JAVA_HOME configurado para Ghidra"

    # --- Purge step labels (STEP_PURGE_*) ---
    LANG_EN[STEP_PROTECT_CRITICAL_PACKAGES]="Protecting critical system packages"
    LANG_ES[STEP_PROTECT_CRITICAL_PACKAGES]="Protegiendo paquetes críticos del sistema"

    LANG_EN[STEP_STOP_DISPLAY_MANAGER]="Stopping display manager"
    LANG_ES[STEP_STOP_DISPLAY_MANAGER]="Deteniendo gestor de pantalla"

    LANG_EN[STEP_KILL_XFCE_PROCESSES]="Terminating XFCE processes"
    LANG_ES[STEP_KILL_XFCE_PROCESSES]="Terminando procesos XFCE"

    LANG_EN[STEP_PURGE_META_PACKAGES]="Purging desktop meta-packages"
    LANG_ES[STEP_PURGE_META_PACKAGES]="Purgando meta-paquetes de escritorio"

    LANG_EN[STEP_PURGE_DISPLAY_MANAGERS]="Purging old display managers"
    LANG_ES[STEP_PURGE_DISPLAY_MANAGERS]="Purgando gestores de pantalla antiguos"

    LANG_EN[STEP_PURGE_XFCE_PACKAGES]="Purging XFCE packages"
    LANG_ES[STEP_PURGE_XFCE_PACKAGES]="Purgando paquetes XFCE"

    LANG_EN[STEP_PURGE_GNOME_PACKAGES]="Purging GNOME packages"
    LANG_ES[STEP_PURGE_GNOME_PACKAGES]="Purgando paquetes GNOME"

    LANG_EN[STEP_PURGE_XFCE_CONFIGS]="Removing XFCE configuration files"
    LANG_ES[STEP_PURGE_XFCE_CONFIGS]="Eliminando archivos de configuración XFCE"

    LANG_EN[STEP_UNPROTECT_CRITICAL_PACKAGES]="Unprotecting critical packages"
    LANG_ES[STEP_UNPROTECT_CRITICAL_PACKAGES]="Desprotegiendo paquetes críticos"

    LANG_EN[STEP_CLEANUP_APT]="Running APT cleanup"
    LANG_ES[STEP_CLEANUP_APT]="Ejecutando limpieza de APT"

    # --- Help text (HELP_*) ---
    LANG_EN[HELP_USAGE]="Usage: sudo %s [--user-only] [--skip-security] [--skip-dotfiles] [--skip-shell] [--skip-tmux] [--skip-ai] [--gentle-ai] [--hexstrike-ai] [--lang en|es] [--version]"
    LANG_ES[HELP_USAGE]="Uso: sudo %s [--user-only] [--skip-security] [--skip-dotfiles] [--skip-shell] [--skip-tmux] [--skip-ai] [--gentle-ai] [--hexstrike-ai] [--lang en|es] [--version]"

    LANG_EN[HELP_USER_ONLY]="Dotfiles only (no sudo required)"
    LANG_ES[HELP_USER_ONLY]="Solo dotfiles (no requiere sudo)"

    LANG_EN[HELP_SKIP_SECURITY]="Skip security tools installation"
    LANG_ES[HELP_SKIP_SECURITY]="Omitir instalación de herramientas de seguridad"

    LANG_EN[HELP_SKIP_DOTFILES]="Skip dotfiles and wallpapers deployment"
    LANG_ES[HELP_SKIP_DOTFILES]="Omitir despliegue de dotfiles y fondos de pantalla"

    LANG_EN[HELP_SKIP_SHELL]="Skip Zsh, Oh-My-Zsh, and .zshrc deployment"
    LANG_ES[HELP_SKIP_SHELL]="Omitir Zsh, Oh-My-Zsh y despliegue de .zshrc"

    LANG_EN[HELP_SKIP_TMUX]="Skip TMUX Neon setup"
    LANG_ES[HELP_SKIP_TMUX]="Omitir configuración de TMUX Neon"

    LANG_EN[HELP_SKIP_AI]="Skip AI tools installation (gentle-ai, HexStrike, opencode)"
    LANG_ES[HELP_SKIP_AI]="Omitir instalación de herramientas AI (gentle-ai, HexStrike, opencode)"

    LANG_EN[HELP_GENTLE_AI]="Install full Gentle-AI stack"
    LANG_ES[HELP_GENTLE_AI]="Instalar stack completo de Gentle-AI"

    LANG_EN[HELP_HEXSTRIKE_AI]="Install HexStrike AI + MCP server"
    LANG_ES[HELP_HEXSTRIKE_AI]="Instalar HexStrike AI + servidor MCP"

    LANG_EN[HELP_VERSION]="Show version from CHANGELOG.md"
    LANG_ES[HELP_VERSION]="Mostrar versión desde CHANGELOG.md"

    LANG_EN[HELP_LANG]="Set language (en|es), default: en"
    LANG_ES[HELP_LANG]="Establecer idioma (en|es), predeterminado: en"
}

# =============================================================================
# msg — Look up a translation key and return the localized string
# Falls back to the key name if not found.
# =============================================================================
msg() {
    local key="$1"
    local catalog_name="LANG_${CURRENT_LANG^^}"
    local -n catalog_ref="${catalog_name}" 2>/dev/null

    if [[ -v "${catalog_name}[${key}]" ]]; then
        local -n ref="${catalog_name}"
        printf '%s' "${ref[${key}]}"
    else
        printf '%s' "${key}"
    fi
}
