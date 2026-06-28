#!/usr/bin/env bash
# =============================================================================
# setup_i3_kali.sh — Complete i3-wm Migration & Pentesting Suite for Kali
# =============================================================================
# Specification: Idempotent, sudo-aware, modular phases, SDDM integration, Neon Minimal style
# Author: Kilo Code Generation
# Usage:   sudo ./setup_i3_kali.sh        # Full system install
#          ./setup_i3_kali.sh --user-only # Dotfiles only (no sudo)
#          ./setup_i3_kali.sh --skip-security # Skip security tools
#          ./setup_i3_kali.sh --gentle-ai # Install full Gentle-AI stack
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# CONSTANTS & GLOBALS
# =============================================================================
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"

# Source lib modules
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/i18n.sh"
source "${SCRIPT_DIR}/lib/user.sh"
source "${SCRIPT_DIR}/lib/apt.sh"

# State tracking
declare -A STATE=()
declare -A PKG_CACHE=()

# =============================================================================
# PERSISTENT STATE & PROGRESS (CHECKPOINTS)
# =============================================================================
readonly STATE_FILE="${TARGET_HOME}/.config/i3-setup-state.json"
readonly STATE_VERSION="1.0.0"

declare -A COMPLETED_STEPS=()
declare -A STEP_LABELS=()

# Populate STEP_LABELS with translated strings (must be called after i18n_init)
init_step_labels() {
    STEP_LABELS=(
        ["step_install_i3_core"]="$(msg STEP_INSTALL_I3_CORE)"
        ["step_switch_display_manager"]="$(msg STEP_SWITCH_DISPLAY_MANAGER)"
        ["step_deploy_dotfiles"]="$(msg STEP_DEPLOY_DOTFILES)"
        ["step_deploy_wallpapers"]="$(msg STEP_DEPLOY_WALLPAPERS)"
        ["step_setup_tmux_neon"]="$(msg STEP_SETUP_TMUX_NEON)"
        ["step_install_zsh_omz"]="$(msg STEP_INSTALL_ZSH_OMZ)"
        ["step_deploy_zshrc"]="$(msg STEP_DEPLOY_ZSHRC)"
        ["step_setup_i3_desktop_entry"]="$(msg STEP_SETUP_I3_DESKTOP_ENTRY)"
        ["step_install_security_suite"]="$(msg STEP_INSTALL_SECURITY_SUITE)"
        ["step_install_gentle_ai"]="$(msg STEP_INSTALL_GENTLE_AI)"
        ["step_install_gentle_agent_state"]="$(msg STEP_INSTALL_GENTLE_AGENT_STATE)"
        ["step_deploy_kilo_config"]="$(msg STEP_DEPLOY_KILO_CONFIG)"
        ["step_setup_opencode"]="$(msg STEP_SETUP_OPENCODE)"
        ["step_install_hexstrike_ai"]="$(msg STEP_INSTALL_HEXSTRIKE_AI)"
        ["step_deploy_hexstrike_mcp_config"]="$(msg STEP_DEPLOY_HEXSTRIKE_MCP_CONFIG)"
        ["step_post_install_cleanup"]="$(msg STEP_POST_INSTALL_CLEANUP)"
    )
}

# Source state management
source "${SCRIPT_DIR}/lib/state.sh"

# =============================================================================
# IDEMPOTENCY HELPERS
# =============================================================================
write_file_if_missing() {
    local dest="$1"
    local content="$2"
    local perms="${3:-644}"
    [[ -f "${dest}" ]] && return 0
    mkdir -p "$(dirname "${dest}")"
    printf "%s" "${content}" > "${dest}"
    chmod "${perms}" "${dest}"
    chown "${TARGET_UID}:${TARGET_GID}" "${dest}" 2>/dev/null || true
    ok "Created: ${dest}"
}

# =============================================================================
# STEP FUNCTIONS
# =============================================================================
step_install_i3_core() {
    header "Install Core i3-wm Environment (NEON MINIMAL)"

    local pkgs=(
        i3-wm i3status i3lock i3blocks
        polybar rofi picom feh
        kitty alacritty
        zsh zsh-syntax-highlighting zsh-autosuggestions
        fonts-firacode fonts-noto-color-emoji
        brightnessctl playerctl pamixer
        xclip xsel wl-clipboard
        flameshot maim slop
        papirus-icon-theme arc-theme lxappearance
    )
    apt_install_if_missing "${pkgs[@]}"
    ok "Core i3 packages installed"
}

step_deploy_dotfiles() {
    header "Deploy Dotfiles (NEON MINIMALIST Theme)"

    local cfg_dir="${TARGET_HOME}/.config"
    run_as_user "mkdir -p ${cfg_dir}/{i3,polybar,rofi,picom,kitty,zsh,gtk-3.0,gtk-4.0}"

    # i3 config - NEON MINIMAL
    cat > "${cfg_dir}/i3/config" <<I3CONF
# i3-wm Config - NEON MINIMAL Theme
# Background: ${NEON_BG}, Accent: ${NEON_ACCENT} (Azul Neon Atenuado), #FF006E (Pink), #7B2CBF (Purple)

set \$mod Mod4

# Colors (Neon Minimal Dark)
set \$bg      ${NEON_BG}
set \$bg-alt  ${NEON_BG_ALT}
set \$fg      ${NEON_FG}
set \$neon-cyan ${NEON_ACCENT}
set \$neon-pink #FF006E
set \$neon-purple #7B2CBF
set \$urgent #FF006E

client.focused    \$neon-cyan \$neon-cyan \$bg \$neon-cyan \$neon-cyan
client.unfocused  \$bg-alt   \$bg-alt    \$fg \$bg-alt   \$bg-alt
client.urgent     \$urgent   \$urgent    \$fg \$urgent   \$urgent
client.background \$bg

# Window rules
for_window [window_role="pop-up"] floating enable
for_window [window_type="dialog"] floating enable
for_window [class="Pavucontrol"] floating enable

# Autostart
exec --no-startup-id picom --config ~/.config/picom.conf
exec --no-startup-id feh --bg-fill ~/.config/wallpaper.png 2>/dev/null || true
exec --no-startup-id polybar -c ~/.config/polybar/config.ini main 2>/dev/null || true
exec --no-startup-id nm-applet --indicator 2>/dev/null || true

# Keybindings
bindsym \$mod+Return exec kitty
bindsym \$mod+Shift+Return exec alacritty
bindsym \$mod+d exec rofi -show drun
bindsym \$mod+Shift+d exec rofi -show run
bindsym \$mod+Shift+q kill

# Navigation (NEON minimal)
bindsym \$mod+h focus left
bindsym \$mod+j focus down
bindsym \$mod+k focus up
bindsym \$mod+l focus right

# Move
bindsym \$mod+Shift+h move left
bindsym \$mod+Shift+j move down
bindsym \$mod+Shift+k move up
bindsym \$mod+Shift+l move right

# Workspaces
bindsym \$mod+1 workspace 1
bindsym \$mod+2 workspace 2
bindsym \$mod+3 workspace 3
bindsym \$mod+4 workspace 4
bindsym \$mod+5 workspace 5
bindsym \$mod+6 workspace 6
bindsym \$mod+7 workspace 7
bindsym \$mod+8 workspace 8
bindsym \$mod+9 workspace 9
bindsym \$mod+0 workspace 10

bindsym \$mod+Shift+1 move container to workspace 1
bindsym \$mod+Shift+2 move container to workspace 2
bindsym \$mod+Shift+3 move container to workspace 3
bindsym \$mod+Shift+4 move container to workspace 4
bindsym \$mod+Shift+5 move container to workspace 5
bindsym \$mod+Shift+6 move container to workspace 6
bindsym \$mod+Shift+7 move container to workspace 7
bindsym \$mod+Shift+8 move container to workspace 8
bindsym \$mod+Shift+9 move container to workspace 9
bindsym \$mod+Shift+0 move container to workspace 10

# Screenshots
bindsym Print exec flameshot gui

# Volume
bindsym XF86AudioRaiseVolume exec pamixer -i 5
bindsym XF86AudioLowerVolume exec pamixer -d 5
bindsym XF86AudioMute exec pamixer -t

# Reload
bindsym \$mod+Shift+c reload
bindsym \$mod+Shift+x exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

bar {
    mode hide
    hidden_state hide
}
I3CONF

    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/i3/config"
    ok "Created: i3/config (NEON MINIMAL)"

    # Polybar config - NEON MINIMAL with Fira Code
    cat > "${cfg_dir}/polybar/config.ini" <<POLYCONF
[colors]
background = ${NEON_BG}
foreground = ${NEON_FG}
primary = ${NEON_ACCENT}
secondary = #FF006E
alert = #7B2CBF

[bar/main]
width = 100%
height = 28
radius = 0

padding-right = 4
module-margin-right = 2
font-0 = "FiraCode Nerd Font:size=10"
background = ${NEON_BG}
foreground = ${NEON_FG}
border-size = 0
border-color = #00000000
modules-left = i3
modules-center = date
modules-right = space pulseaudio memory cpu network

[module/i3]
type = internal/i3
format = <label-state>
label-focused = "%index%"
label-focused-background = ${NEON_BG_ALT}
label-focused-foreground = ${NEON_ACCENT}
label-focused-padding = 2
label-unfocused = "%index%"
label-unfocused-background = ${NEON_BG}
label-unfocused-foreground = ${NEON_FG}
label-unfocused-padding = 2

[module/date]
type = internal/date
interval = 1
date = %a %d %b
time = %H:%M
label = %date% %time%

[module/pulseaudio]
type = internal/pulseaudio
format-volume = "VOL %percentage%%"
format-muted = "MUTE"

[module/memory]
type = internal/memory
format = "MEM %percentage_used%%"

[module/cpu]
type = internal/cpu
format = "CPU %percentage%%"

[module/network]
type = internal/network
interface = eth0
interval = 3
format-connected = "NET %local_ip%"
format-disconnected = "NET OFF"

[settings]
screenchange-reload = true
POLYCONF

    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/polybar/config.ini"
    ok "Created: polybar/config.ini (NEON MINIMAL)"

    # Rofi config - NEON MINIMAL
    cat > "${cfg_dir}/rofi/config.rasi" <<ROFI
configuration {
    show-icons: true;
    icon-theme: "Papirus-Dark";
    font: "FiraCode Nerd Font 10";
}
window {
    background-color: ${NEON_BG};
    border: 0px;
    border-radius: 0px;
}
listview {
    background-color: ${NEON_BG};
    border-color: ${NEON_BG_ALT};
    border-radius: 0px;
}
element {
    background-color: ${NEON_BG};
    border-radius: 0px;
    element-text-color: ${NEON_FG};
}
element-selected {
    background-color: ${NEON_ACCENT};
    border-radius: 0px;
    element-text-color: ${NEON_BG};
}
prompt {
    background-color: ${NEON_BG};
    border-color: #FF006E;
    border-radius: 0px;
    text-color: ${NEON_ACCENT};
}
ROFI
    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/rofi/config.rasi"
    ok "Created: rofi/config.rasi (NEON MINIMAL)"

    # Picom config
    cat > "${cfg_dir}/picom.conf" <<PICOM
backend = "glx";
vsync = true;
blur-background = true;
blur-background-frame = true;
shadow = true;
shadow-radius = 12;
shadow-color = ${NEON_ACCENT};
fading = true;
fade-delta = 4;
PICOM
    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/picom.conf"
    ok "Created: picom.conf"

    # Kitty config - NEON MINIMAL
    cat > "${cfg_dir}/kitty/kitty.conf" <<KITTY
font_family FiraCode Nerd Font
font_size 11.0
bold_font auto
italic_font auto

background ${NEON_BG}
foreground ${NEON_FG}
cursor ${NEON_ACCENT}
cursor_text_color ${NEON_BG}

color0 ${NEON_BG}
color1 #FF006E
color2 #7B2CBF
color3 ${NEON_ACCENT}
color4 #FF006E
color5 #7B2CBF
color6 ${NEON_ACCENT}
color7 ${NEON_FG}
color8 ${NEON_BG_ALT}
color9 #FF006E
color10 ${NEON_ACCENT}
color11 #7B2CBF
color12 ${NEON_ACCENT}
color13 #FF006E
color14 #7B2CBF
color15 #FFFFFF

selection_background ${NEON_ACCENT}
selection_foreground ${NEON_BG}
selection_shape block

window_padding_width 12
window_border_width 0
window_margin_width 0
scrollback_lines 10000
KITTY
    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/kitty/kitty.conf"
    ok "Created: kitty/kitty.conf (NEON MINIMAL)"

    # Alacritty config - NEON MINIMAL
    cat > "${cfg_dir}/alacritty/alacritty.yml" <<ALACRITTY
font:
  normal:
    family: FiraCode Nerd Font
    style: Regular
  bold:
    family: FiraCode Nerd Font
  italic:
    family: FiraCode Nerd Font
  size: 11.0

window:
  opacity: 0.95
  padding:
    x: 12
    y: 12
  decorations: none

colors:
  primary:
    background: "${NEON_BG}"
    foreground: "${NEON_FG}"
  cursor:
    cursor: "${NEON_ACCENT}"
    text: "${NEON_BG}"
  vi_mode_cursor:
    cursor: "#FF006E"
    text: "${NEON_BG}"
  selection:
    text: "${NEON_BG}"
    background: "${NEON_ACCENT}"
  normal:
    black:   "${NEON_BG}"
    red:     "#FF006E"
    green:   "${NEON_ACCENT}"
    yellow:  "#7B2CBF"
    blue:    "${NEON_ACCENT}"
    magenta: "#FF006E"
    cyan:    "#7B2CBF"
    white:   "${NEON_FG}"
  bright:
    black:   "${NEON_BG_ALT}"
    red:     "#FF006E"
    green:   "${NEON_ACCENT}"
    yellow:  "#7B2CBF"
    blue:    "${NEON_ACCENT}"
    magenta: "#FF006E"
    cyan:    "#7B2CBF"
    white:   "#FFFFFF"
ALACRITTY
    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/alacritty/alacritty.yml"
    ok "Created: alacritty/alacritty.yml (NEON MINIMAL)"

    # GTK settings - NEON MINIMAL
    cat > "${cfg_dir}/gtk-3.0/settings.ini" <<'GTKCONF'
[Settings]
gtk-theme-name = Arc-Dark
gtk-icon-theme-name = Papirus-Dark
gtk-font-name = FiraCode Nerd Font 10
gtk-cursor-theme-name = Breeze
GTKCONF
    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/gtk-3.0/settings.ini"

    cat > "${cfg_dir}/gtk-4.0/settings.ini" <<'GTK4'
[Settings]
gtk-theme-name = Arc-Dark
gtk-icon-theme-name = Papirus-Dark
gtk-font-name = FiraCode Nerd Font 10
GTK4
    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/gtk-4.0/settings.ini"


    ok "Dotfiles deployed (NEON MINIMAL)"
}

step_deploy_wallpapers() {
    header "Deploy Wallpaper (NEON MINIMAL)"

    local cfg_dir="${TARGET_HOME}/.config"
    local wallpaper="${cfg_dir}/wallpaper.png"
    local descargas="${TARGET_HOME}/Descargas"

    run_as_user "mkdir -p ${cfg_dir}"

    if [[ -d "${descargas}" ]]; then
        local images=()
        while IFS= read -r -d '' file; do
            images+=("${file}")
        done < <(find "${descargas}" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0 2>/dev/null | sort -z)

        if [[ ${#images[@]} -gt 0 ]]; then
            run_as_user "cp '${images[0]}' '${wallpaper}'"
            chown "${TARGET_UID}:${TARGET_GID}" "${wallpaper}" 2>/dev/null || true
            ok "Wallpaper deployed from ~/Descargas: $(basename "${images[0]}")"
            return 0
        fi
    fi

    if cmd_exists convert; then
        run_as_user "convert -size 1920x1080 gradient:#0A0A0A-#121214 '${wallpaper}'"
        chown "${TARGET_UID}:${TARGET_GID}" "${wallpaper}" 2>/dev/null || true
        ok "Wallpaper generated: ImageMagick gradient #0A0A0A-#121214"
    else
        warn "ImageMagick not found — generating solid wallpaper fallback"
        run_as_user "python3 -c \"from PIL import Image; img=Image.new('RGB',(1920,1080),color='#0A0A0A'); img.save('${wallpaper}')\"" 2>/dev/null \
            || run_as_user "printf 'P6\n1920 1080\n255\n' > '${wallpaper}' && python3 -c \"import sys; open(sys.argv[1],'ab').write(bytes([0x0A]*1920*1080*3))\" '${wallpaper}' 2>/dev/null || true"
        chown "${TARGET_UID}:${TARGET_GID}" "${wallpaper}" 2>/dev/null || true
        ok "Wallpaper generated: solid #0A0A0A fallback"
    fi
}

step_setup_tmux_neon() {
    header "Setup TMUX (NEON MINIMAL)"

    apt_install_if_missing tmux

    local cfg_dir="${TARGET_HOME}/.config/tmux"
    local scripts_dir="${cfg_dir}/scripts"
    run_as_user "mkdir -p ${cfg_dir}/tmux.conf.d ${scripts_dir}"

    cat > "${cfg_dir}/tmux.conf" <<TMUXCONF
# TMUX Config - NEON MINIMAL Theme
# Background: ${NEON_BG}, Accent: ${NEON_ACCENT} (Azul Neon Atenuado), #FF006E (pink), #7B2CBF (purple)

# Plugins (TPM)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Theme - Neon Minimal
set -g status on
set -g status-position bottom
set -g status-bg "${NEON_BG}"
set -g status-fg "${NEON_FG}"
set -g status-left-length 60
set -g status-right-length 60

# Status left - Kali Linux logo + session
set -g status-left "#[fg=${NEON_ACCENT}, bg=${NEON_BG}] 🔱 KALI #[fg=${NEON_FG}, bg=${NEON_BG}] #S #[default]"

# Status right - Minimal date/time
set -g status-right "#[fg=#7b2cbf, bg=${NEON_BG}] %d/%m #[fg=${NEON_ACCENT}, bg=${NEON_BG}] %H:%M #[default]"

# Window status
setw -g window-status-current-bg "${NEON_ACCENT}"
setw -g window-status-current-fg "${NEON_BG}"
setw -g window-status-current-format " #I:#W "

setw -g window-status-bg "${NEON_BG}"
setw -g window-status-fg "#7b2cbf"
setw -g window-status-format " #I:#W "

# Pane borders - Neon colors
set -g pane-border-bg "${NEON_BG}"
set -g pane-border-fg "#ff006e"
set -g pane-active-border-bg "${NEON_BG}"
set -g pane-active-border-fg "${NEON_ACCENT}"

# Messages
set -g message-bg "${NEON_ACCENT}"
set -g message-fg "${NEON_BG}"

# Reload config
bind r source-file ~/.config/tmux/tmux.conf \; display-message "🔱 KALI tmux.conf reloaded"

# Source agent-state hooks (requires gentle-agent-state)
if-shell "test -f ~/.config/tmux/tmux.conf.d/agents.conf" 'source-file ~/.config/tmux/tmux.conf.d/agents.conf'
TMUXCONF
    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/tmux.conf"
    ok "Created: tmux/tmux.conf (NEON MINIMAL)"

    cat > "${scripts_dir}/agent-status.sh" <<'AGENTSTATUS'
#!/usr/bin/env bash
# Gentle Agent State Integration for TMUX
# NEON MINIMAL style

STATE_FILE="${HOME}/.config/agent-state/current.state"

if [[ -f "${STATE_FILE}" ]]; then
    state=$(cat "${STATE_FILE}" 2>/dev/null)
else
    state="idle"
fi

case "${state}" in
    idle) echo "#[fg=#7b2cbf] ⚪ " ;;
    working) echo "#[fg=#00ffff] 🟢 " ;;
    error) echo "#[fg=#ff006e] 🔴 " ;;
    *) echo "#[fg=#7b2cbf] ⚪ " ;;
esac
AGENTSTATUS
    chmod +x "${scripts_dir}/agent-status.sh"
    chown "${TARGET_UID}:${TARGET_GID}" "${scripts_dir}/agent-status.sh"
    ok "Created: tmux/scripts/agent-status.sh"

    cat > "${scripts_dir}/update-status.sh" <<'UPDATESTATUS'
#!/usr/bin/env bash
# Update tmux status on events
# NEON MINIMAL style

tmux refresh-client -S 2>/dev/null || true
UPDATESTATUS
    chmod +x "${scripts_dir}/update-status.sh"
    chown "${TARGET_UID}:${TARGET_GID}" "${scripts_dir}/update-status.sh"
    ok "Created: tmux/scripts/update-status.sh"

    cat > "${cfg_dir}/tmux.conf.d/agents.conf" <<AGENTS
# TMUX Agent State Hooks - NEON MINIMAL

set -g status-left "#[fg=${NEON_ACCENT}, bg=${NEON_BG}] 🔱 KALI #[fg=#7b2cbf, bg=${NEON_BG}] #S #(\$HOME/.config/tmux/scripts/agent-status.sh)#[default]"

# Hook for gentle-agent-state updates
set-hook -g after-split-window 'run-shell ~/.config/tmux/scripts/update-status.sh 2>/dev/null'
set-hook -g after-new-window 'run-shell ~/.config/tmux/scripts/update-status.sh 2>/dev/null'
AGENTS
    chown "${TARGET_UID}:${TARGET_GID}" "${cfg_dir}/tmux.conf.d/agents.conf"
    ok "Created: tmux/tmux.conf.d/agents.conf"

    # Setup TPM if available
    if cmd_exists git; then
        local tpm_dir="${TARGET_HOME}/.config/tmux/plugins/tpm"
        if [[ ! -d "${tpm_dir}" ]]; then
            run_as_user "git clone https://github.com/tmux-plugins/tpm ${tpm_dir}" 2>/dev/null || true
        fi
        ok "TPM configured (install with prefix+I in tmux)"
    fi

    # Symlink tmux.conf to ~/.tmux.conf for compatibility
    run_as_user "ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf"
    ok "TMUX configured (NEON MINIMAL)"
}

step_install_zsh_omz() {
    header "Install Zsh, Oh-My-Zsh, Powerlevel10k"

    apt_install_if_missing git curl

    if [[ ! -d "${TARGET_HOME}/.oh-my-zsh" ]]; then
        sudo -u "${TARGET_USER}" -H bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' || true
    fi

    if [[ ! -d "${TARGET_HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        sudo -u "${TARGET_USER}" -H bash -c 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k' || true
    fi

    sudo -u "${TARGET_USER}" -H chsh -s /bin/zsh 2>/dev/null || true
    ok "Zsh + Oh-My-Zsh + Powerlevel10k installed"
}

step_deploy_zshrc() {
    header "Deploy .zshrc Configuration (NEON)"

    cat > "${TARGET_HOME}/.zshrc" <<'ZSHRC'
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

# System-wide zsh plugins (installed via apt)
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || true
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null || true

source $ZSH/oh-my-zsh.sh

HISTSIZE=100000
SAVEHIST=100000

alias ll="ls -lh"
alias la="ls -lah"

# Pentest shortcuts
alias msf="msfconsole -q"

# Path
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
ZSHRC

    chown "${TARGET_UID}:${TARGET_GID}" "${TARGET_HOME}/.zshrc"
    ok ".zshrc deployed"
}

step_switch_display_manager() {
    header "Switch Display Manager: LightDM -> SDDM (NEON)"

    apt_install_if_missing sddm
    run_as_root "systemctl enable sddm" || true

    run_as_root "mkdir -p /etc/sddm.conf.d"
    cat > /etc/sddm.conf.d/kali-i3.conf <<'SDDMCONF'
[Theme]
Current=breeze

[Autologin]
User=
Session=i3.desktop
SDDMCONF

    ok "SDDM configured as display manager"
}

step_setup_i3_desktop_entry() {
    header "Register i3 Session in /usr/share/xsessions/"

    run_as_root "mkdir -p /usr/share/xsessions"
    cat > /usr/share/xsessions/i3.desktop <<'DESK'
[Desktop Entry]
Name=i3
Comment=Improved tiling window manager
Exec=i3
TryExec=i3
Type=Application
DesktopNames=i3
Keywords=tiling;wm;windowmanager;
DESK

    ok "i3.desktop registered"
}

step_install_security_suite() {
    header "Install Security Tools Suite (NEON)"

    apt_install_if_missing \
        metasploit-framework nmap masscan \
        gobuster ffuf \
        dnsutils smbclient \
        responder wireshark \
        sqlmap hydra john hashcat \
        ghidra radare2 gdb python3-pwntools yara binwalk imagemagick

    if ! cmd_exists docker; then
        apt_install_if_missing docker.io
        run_as_root "systemctl enable --now docker"
        run_as_root "usermod -aG docker ${TARGET_USER}"
    fi

    run_as_root "mkdir -p /opt/empire-docker"
    cat > /opt/empire-docker/docker-compose.yml <<'EMP'
version: "3.8"
services:
  empire:
    image: bcsecurity/empire:latest
    ports:
      - "1337:1337"
    restart: unless-stopped
EMP

    ok "Security suite installed (NEON)"
}

step_install_gentle_ai() {
    header "Install gentle-ai CLI (NEON) - Go Install"

    if cmd_exists go; then
        run_as_user "go install github.com/gentleman-programming/gentle-ai/cmd/gentle-ai@latest"
        local go_bin="$(sudo -u "${TARGET_USER}" -H bash -c 'echo $HOME/go/bin')/gentle-ai"
        ok "gentle-ai CLI installed to ${go_bin}"
    else
        warn "Go not installed, skipping gentle-ai"
    fi
}

step_install_gentle_agent_state() {
    header "Install gentle-agent-state (NEON) - tmux/Zellij Integration"

    local agent_state_dir="${TARGET_HOME}/.config/agent-state/scripts"
    run_as_user "mkdir -p ${agent_state_dir}"

    run_as_user "git clone https://github.com/Gentleman-Programming/gentle-agent-state.git ${agent_state_dir}/gentle-agent-state 2>/dev/null || true"

    cat > "${agent_state_dir}/gentle-agent.sh" <<'GENTLE_AGENT'
#!/usr/bin/env bash
# Gentle Agent State Integration
# Auto-generated by setup_i3_kali.sh

if command -v gentle-ai >/dev/null 2>&1; then
    gentle-ai --status 2>/dev/null || true
fi
GENTLE_AGENT

    chmod +x "${agent_state_dir}/gentle-agent.sh"
    chown "${TARGET_UID}:${TARGET_GID}" "${agent_state_dir}/gentle-agent.sh"
    ok "gentle-agent-state scripts deployed to ${agent_state_dir}"
}

step_deploy_kilo_config() {
    header "Configure Kilo Code (~/.config/kilo) - NEON"

    local kilo_dir="${TARGET_HOME}/.config/kilo"
    run_as_user "mkdir -p ${kilo_dir}"

    cat > "${kilo_dir}/agent.json" <<KILOCONF
{
  "name": "kali-i3-neon",
  "description": "NEON MINIMAL i3-wm setup for Kali Linux",
  "theme": "neon-dark",
  "colors": {
    "background": "${NEON_BG}",
    "foreground": "${NEON_FG}",
    "accent": "${NEON_ACCENT}",
    "magenta": "#FF006E",
    "purple": "#7B2CBF"
  }
}
KILOCONF
    chown "${TARGET_UID}:${TARGET_GID}" "${kilo_dir}/agent.json"

    cat > "${kilo_dir}/kilo.json" <<'KJSON'
{
  "name": "kali-i3",
  "version": "2.0.0",
  "agents": {
    "default": {
      "model": "anthropic.claude-3-5-sonnet-20241022"
    }
  },
  "permissions": {
    "write": true,
    "network": true
  }
}
KJSON
    chown "${TARGET_UID}:${TARGET_GID}" "${kilo_dir}/kilo.json"
    ok "Kilo config deployed to ${kilo_dir}"
}

step_setup_opencode() {
    header "Configure openCode (~/.config/opencode) - NEON"

    local opencode_dir="${TARGET_HOME}/.config/opencode"
    run_as_user "mkdir -p ${opencode_dir}"

    cat > "${opencode_dir}/.opencode.json" <<OPENCODE
{
  "name": "kali-i3-neon",
  "preset": "gentleman",
  "theme": {
    "background": "${NEON_BG}",
    "foreground": "${NEON_FG}",
    "accent": "${NEON_ACCENT}",
    "borderRadius": 0,
    "neonPink": "#FF006E",
    "neonPurple": "#7B2CBF"
  },
  "agents": {
    "default": {
      "model": "openai/gpt-4-turbo-preview"
    }
  }
}
OPENCODE
    chown "${TARGET_UID}:${TARGET_GID}" "${opencode_dir}/.opencode.json"
    ok "openCode config deployed to ${opencode_dir}"
}

step_install_hexstrike_ai() {
    header "Install HexStrike AI (NEON) - Pentesting MCP"

    local hexstrike_dir="${TARGET_HOME}/tools/hexstrike-ai"
    local sec_tools=(
        nmap masscan gobuster ffuf nuclei
        sqlmap hydra john hashcat
    )

    if [[ ! -d "${hexstrike_dir}" ]]; then
        run_as_user "mkdir -p ${TARGET_HOME}/tools"
        run_as_user "git clone https://github.com/0x4m4/hexstrike-ai.git ${hexstrike_dir}" || err "Failed to clone hexstrike-ai"
    fi

    if [[ -f "${hexstrike_dir}/requirements.txt" ]]; then
        if [[ ! -d "${hexstrike_dir}/venv" ]]; then
            run_as_user "cd ${hexstrike_dir} && python3 -m venv venv"
        fi
        run_as_user "cd ${hexstrike_dir} && ./venv/bin/pip install -r requirements.txt"
    else
        warn "requirements.txt not found in ${hexstrike_dir}"
    fi

    apt_install_if_missing "${sec_tools[@]}"
    ok "HexStrike AI installed to ${hexstrike_dir}"
}

step_deploy_hexstrike_mcp_config() {
    header "Deploy HexStrike AI MCP Configuration (NEON)"

    local opencode_dir="${TARGET_HOME}/.config/opencode/mcp"
    local claude_dir="${TARGET_HOME}/.claude"
    local agent_state_dir="${TARGET_HOME}/.config/agent-state"

    run_as_user "mkdir -p ${opencode_dir} ${claude_dir} ${agent_state_dir}"

    cat > "${opencode_dir}/hexstrike.json" <<'HEXSTRIKE_MCP'
{
  "server": "http://localhost:8888",
  "enabled": true,
  "tools": [
    "nmap_scan",
    "feroxbuster",
    "masscan",
    "gobuster_dir",
    "ffuf_fuzz",
    "sqlmap_scan",
    "hydra_brute",
    "john_crack",
    "hashcat_crack",
    "nuclei_scan"
  ]
}
HEXSTRIKE_MCP
    chown "${TARGET_UID}:${TARGET_GID}" "${opencode_dir}/hexstrike.json"

    if [[ -d "${claude_dir}" ]]; then
        cat > "${claude_dir}/mcp.json" <<'CLAUDE_MCP'
{
  "mcpServers": {
    "hexstrike-ai": {
      "url": "http://localhost:8888",
      "enabled": true
    }
  }
}
CLAUDE_MCP
        chown "${TARGET_UID}:${TARGET_GID}" "${claude_dir}/mcp.json"
    fi

    cat > "${agent_state_dir}/mcp.json" <<'AGENT_MCP'
{
  "servers": [
    {
      "name": "hexstrike-ai",
      "url": "http://localhost:8888",
      "tools": [
        "nmap_scan",
        "feroxbuster",
        "masscan",
        "gobuster_dir",
        "ffuf_fuzz",
        "sqlmap_scan",
        "hydra_brute",
        "john_crack",
        "hashcat_crack",
        "nuclei_scan"
      ]
    }
  ]
}
AGENT_MCP
    chown "${TARGET_UID}:${TARGET_GID}" "${agent_state_dir}/mcp.json"

    ok "HexStrike AI MCP configs deployed"
}

step_post_install_cleanup() {
    header "Post-Install Cleanup (NEON)"

    run_as_root "apt-get autoremove -y"
    run_as_root "apt-get clean && apt-get autoclean -y"
    run_as_root "rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"
    run_as_root "chown -R ${TARGET_UID}:${TARGET_GID} ${TARGET_HOME}/.config 2>/dev/null || true"

    ok "Cleanup complete"
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================
USER_ONLY=0
SKIP_SECURITY=0
INSTALL_GENTLE_AI=0
HEXSTRIKE_AI=0
I18N_LANG="en"

parse_args() {
    # First pass: extract --lang before processing other args
    local -a remaining=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lang)
                shift
                [[ $# -gt 0 ]] || die "Missing value for --lang"
                I18N_LANG="$1"
                ;;
            *)
                remaining+=("$1")
                ;;
        esac
        shift
    done

    # Second pass: re-init i18n with resolved language, then process remaining args
    i18n_init "${I18N_LANG}"
    set -- "${remaining[@]}"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --user-only) USER_ONLY=1 ;;
            --skip-security) SKIP_SECURITY=1 ;;
            --gentle-ai) INSTALL_GENTLE_AI=1 ;;
            --hexstrike-ai) HEXSTRIKE_AI=1 ;;
            --version)
                local version
                version=$(grep '## \[' "${SCRIPT_DIR}/CHANGELOG.md" | grep -v 'Unreleased' | head -1 | sed 's/## \[\([^]]*\)\].*/\1/')
                echo "${SCRIPT_NAME} ${version}"
                exit 0
                ;;
            -h|--help)
                echo "Usage: sudo ${SCRIPT_NAME} [--user-only] [--skip-security] [--gentle-ai] [--hexstrike-ai] [--lang en|es] [--version]"
                echo "  --user-only     $(msg HELP_USER_ONLY)"
                echo "  --skip-security $(msg HELP_SKIP_SECURITY)"
                echo "  --gentle-ai     $(msg HELP_GENTLE_AI)"
                echo "  --hexstrike-ai  $(msg HELP_HEXSTRIKE_AI)"
                echo "  --lang LANG     $(msg HELP_LANG)"
                echo "  --version       $(msg HELP_VERSION)"
                exit 0 ;;
            *) die "Unknown option: $1" ;;
        esac
        shift
    done
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    # Initialize i18n with default language (en) before parsing args
    i18n_init "${I18N_LANG}"

    parse_args "$@"

    # Re-initialize i18n with final language (in case --lang was passed)
    i18n_init "${I18N_LANG}"

    # Populate STEP_LABELS with translated strings
    init_step_labels

    if [[ $EUID -ne 0 && ${USER_ONLY} -eq 0 ]]; then
        die "Must run as root (sudo) for system changes. Use --user-only for dotfiles only."
    fi

    run_as_root "touch ${LOG_FILE}"
    run_as_root "chown ${TARGET_UID}:${TARGET_GID} ${LOG_FILE}" 2>/dev/null || true

    load_state

    local -a ALL_STEPS=()

    if [[ ${USER_ONLY} -eq 0 ]]; then
        ALL_STEPS+=(
            "step_install_i3_core"
            "step_switch_display_manager"
        )
    fi

    ALL_STEPS+=(
        "step_deploy_dotfiles"
        "step_deploy_wallpapers"
        "step_setup_tmux_neon"
        "step_install_zsh_omz"
        "step_deploy_zshrc"
        "step_setup_i3_desktop_entry"
    )

    if [[ ${SKIP_SECURITY} -eq 0 && ${USER_ONLY} -eq 0 ]]; then
        ALL_STEPS+=("step_install_security_suite")
    fi

    if [[ ${INSTALL_GENTLE_AI} -eq 1 ]]; then
        ALL_STEPS+=(
            "step_install_gentle_ai"
            "step_install_gentle_agent_state"
            "step_deploy_kilo_config"
            "step_setup_opencode"
        )
    fi

    if [[ ${INSTALL_GENTLE_AI} -eq 1 || ${HEXSTRIKE_AI} -eq 1 ]]; then
        ALL_STEPS+=(
            "step_install_hexstrike_ai"
            "step_deploy_hexstrike_mcp_config"
        )
    fi

    ALL_STEPS+=("step_post_install_cleanup")

    local total=${#ALL_STEPS[@]}
    local completed=0

    if [[ ${#COMPLETED_STEPS[@]} -gt 0 ]]; then
        local -a completed_list=()
        for step in "${!COMPLETED_STEPS[@]}"; do
            completed_list+=("${step}")
        done
        step "${C_NEON_CYAN}Resuming from step: ${#completed_list[@]}/${total} completed${C_RESET}"
        completed=${#completed_list[@]}
    fi

    info "Log: ${LOG_FILE}"
    info "Target: ${TARGET_USER} (${TARGET_HOME})"

    for step_name in "${ALL_STEPS[@]}"; do
        if is_completed "${step_name}"; then
            show_progress "${completed}" "${total}" "${STEP_LABELS[$step_name]:-$step_name} (already done)"
            ((completed++))
            continue
        fi

        show_progress "${completed}" "${total}" "${STEP_LABELS[$step_name]:-$step_name}"

        ${step_name}

        mark_completed "${step_name}"
        ((completed++))
    done

    cat <<EOF

${C_NEON_GREEN}══════════════════════════════════════════════════════════════════${C_RESET}
${C_NEON_GREEN}  $(msg MSG_INSTALL_COMPLETE)${C_RESET}
${C_NEON_GREEN}══════════════════════════════════════════════════════════════════${C_RESET}

${C_NEON_CYAN}Session:${C_RESET} i3 (available at login)
${C_NEON_PINK}Shell:${C_RESET} Zsh + Oh-My-Zsh + Powerlevel10k
${C_NEON_PURPLE}Terminal:${C_RESET} Kitty / Alacritty (FiraCode Nerd Font)
${C_NEON_CYAN}Bar:${C_RESET} Polybar (Neon Dark ${NEON_BG})
${C_NEON_PINK}Launcher:${C_RESET} Rofi (Neon minimal)
${C_NEON_CYAN}TMUX:${C_RESET} tmux.conf + TPM (Neon ${NEON_BG} bg)

${C_NEON_PURPLE}Reboot and select 'i3' in SDDM.${C_RESET}
${C_NEON_CYAN}Then run:${C_RESET} sudo ./purge_xfce.sh

EOF
}

main "$@"
