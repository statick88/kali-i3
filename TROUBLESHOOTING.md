# Troubleshooting — kali-i3 NEON MINIMAL
## Quick reference

| Problem | Fix |
|---------|-----|
| Black screen after i3 login | `echo 'exec i3' >> ~/.xinitrc` |
| Polybar not showing | `polybar -c ~/.config/polybar/config.ini main` |
| SDDM breaks lightdm | Re-run: `sudo ./setup_i3_kali.sh --skip-security` |
| Package not found (arm64) | That package isn't available on arm64 — skip it |
| Alacritty dir missing | `mkdir -p ~/.config/alacritty` then re-run |
| gentle-ai path error | Already fixed in latest commit — pull latest |
| Powerlevel10k wizard appears | Should be fixed — pull latest. If not: `echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> ~/.zshrc` |
| TMUX plugins missing | Start tmux, press `Ctrl+B` then `I` (uppercase) |

## Problemas resueltos durante la instalación
### 1. SDDM rompe el display manager (lightdm)
**Síntoma**: `Failed to enable unit: display-manager.service` y sistema sin GUI.  
**Causa**: `step_switch_display_manager()` forzaba `systemctl enable sddm` y `disable/stop lightdm`.  
**Solución**: Parche aplicado — elimina `disable lightdm` y `stop lightdm`, mantiene `enable sddm || true`.  
**Archivo**: `setup_i3_kali.sh` líneas ~634-653.
### 2. Paquetes no encontrados en arm64
**Síntoma**: `E: No se ha podido localizar el paquete rustscan` / `fermodbuster`.  
**Causa**: Esos paquetes no están disponibles para arquitectura `arm64` en Kali.  
**Solución**: Eliminados del array `sec_tools` en `step_install_hexstrike_ai()`.  
**Archivo**: `setup_i3_kali.sh` líneas ~813-814.
### 3. Directorio alacritty no existe
**Síntoma**: `./setup_i3_kali.sh: línea 360: /home/statick/.config/alacritty/alacritty.yml: No existe el fichero o el directorio`  
**Causa**: Faltó `mkdir -p` previo al deploy del dotfile.  
**Solución**: Ejecutar `mkdir -p ~/.config/alacritty` antes de reanudar el instalador.
### 4. Path de gentle-ai con mayúsculas/minúsculas incorrectas
**Síntoma**: `version constraints conflict: module declares its path as github.com/gentleman-programming/gentle-ai`  
**Causa**: El script usaba `Gentleman-Programming` en lugar de `gentleman-programming`.  
**Solución**: Reemplazado el path en `step_install_gentle_ai()`.
## Comandos útiles
```bash
# Ver estado de checkpoints
cat ~/.config/i3-setup-state.json
# Ver logs
tail -n 100 /var/log/setup_i3_kali.log
# Reanudar instalación (idempotente)
cd /home/statick/kali-i3
sudo ./setup_i3_kali.sh --skip-security --gentle-ai
# Solo dotfiles (sin sudo)
./setup_i3_kali.sh --user-only
# Purgar XFCE (solo después de confirmar que i3 funciona)
sudo ./purge_xfce.sh
# Configurar Powerlevel10k
p10k configure
# Instalar plugins de TMUX
# Dentro de tmux: Ctrl+B, luego I mayúscula
