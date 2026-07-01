#!/bin/bash

# --- 1. Settings & Assets ---
IMG_DIR="/tmp/neoanime_assets"
mkdir -p "$IMG_DIR"

# Download Images
curl -s -L -o "$IMG_DIR/welcome.jpg" "https://github.com/hussinchahin435-maker/NeoAnime-Hypr/raw/main/6d990f3aa03a6957474e0faa23da4e67.jpg"
curl -s -L -o "$IMG_DIR/cancel.jpg" "https://github.com/hussinchahin435-maker/NeoAnime-Hypr/raw/main/9948b8482680859cc1c7562d6431b68b.jpg"
curl -s -L -o "$IMG_DIR/success.jpg" "https://github.com/hussinchahin435-maker/NeoAnime-Hypr/raw/main/b08bf2c9acf2dbeaa50835511d2a1d48.jpg"

if ! command -v zenity &> /dev/null; then sudo pacman -S --noconfirm zenity; fi

# --- 2. Fedora-Style Minimal Welcome ---
if ! zenity --question --title="Setup" --text="Welcome to NeoAnime-Hypr.\nDo you want to start installation?" \
    --window-icon="$IMG_DIR/welcome.jpg" --width=400 --height=200; then
    zenity --error --title="Setup" --text="Installation aborted." --window-icon="$IMG_DIR/cancel.jpg" --width=300
    exit 1
fi

# --- 3. Progress Process ---
(
    echo "10"; echo "# Preparing system..."
    sudo pacman -S --noconfirm mesa xf86-video-vmware xorg-xrandr &> /dev/null
    
    echo "40"; echo "# Installing desktop environment..."
    yay -S --noconfirm waybar rofi-wayland wlogout playerctl swww hyprlock grim slurp swappy ttf-font-awesome base-devel &> /dev/null
    
    echo "70"; echo "# Applying configurations..."
    mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/Pictures
    
    cat << 'EOF' > ~/.config/hypr/hyprland.conf
monitor=,preferred,auto,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_NO_HARDWARE_CURSORS,1
env = National_RENDERER,pixman
env = WLR_RENDERER,pixman
env = QSG_RENDER_LOOP,basic
exec-once = swww-daemon & sleep 1 && swww img ~/Pictures/anime.png
exec-once = waybar
input { kb_layout = us,ara; kb_options = grp:win_space_toggle; follow_mouse = 1 }
general { gaps_in = 5; gaps_out = 10; border_size = 2; col.active_border = rgba(ff79c6ff) rgba(bd93f9ff) 45deg; layout = dwindle }
decoration { rounding = 10; blur { enabled = false } }
animations { enabled = false }
$mainMod = SUPER
bind = $mainMod, T, exec, kitty
bind = $mainMod, Q, killactive
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod, X, exec, wlogout
bind = $mainMod, L, exec, hyprlock
bind = $mainMod, E, exec, dolphin
bind = $mainMod, UP, exec, playerctl play-pause
bind = $mainMod, RIGHT, exec, playerctl next
bind = $mainMod, LEFT, exec, playerctl previous
bindm = $mainMod, mouse:272, movewindow
EOF

    cat << 'EOF' > ~/.config/waybar/config
{
    "layer": "top", "position": "top", "height": 34,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery"],
    "clock": { "format": "🕒 {:%I:%M %p}" },
    "pulseaudio": { "format": "🔊 {volume}%" },
    "network": { "format-wifi": " {essid}", "format-ethernet": "🖧 Connected" },
    "battery": { "format": "🔋 {capacity}%" }
}
EOF

    echo "100"; echo "# Finished."
) | zenity --progress --title="Installing NeoAnime-Hypr" --percentage=0 --auto-close --width=400 --height=100

# --- 4. Success ---
zenity --info --title="Setup Complete" --text="Installation successful!\nPlease reboot to finish." \
    --window-icon="$IMG_DIR/success.jpg" --width=400

rm -rf "$IMG_DIR"
