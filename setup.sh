#!/bin/bash

# --- 1. SETUP & ASSETS ---
IMG_DIR="/tmp/neoanime_assets"
mkdir -p "$IMG_DIR"

curl -s -L -o "$IMG_DIR/welcome.jpg" "https://github.com/hussinchahin435-maker/NeoAnime-Hypr/raw/main/6d990f3aa03a6957474e0faa23da4e67.jpg"
curl -s -L -o "$IMG_DIR/cancel.jpg" "https://github.com/hussinchahin435-maker/NeoAnime-Hypr/raw/main/9948b8482680859cc1c7562d6431b68b.jpg"
curl -s -L -o "$IMG_DIR/success.jpg" "https://github.com/hussinchahin435-maker/NeoAnime-Hypr/raw/main/b08bf2c9acf2dbeaa50835511d2a1d48.jpg"

if ! command -v zenity &> /dev/null; then sudo pacman -S --noconfirm zenity; fi

# --- 2. FEDORA-STYLE MINIMAL WELCOME ---
if ! zenity --question \
    --title="NeoAnime-Hypr Setup" \
    --text="Welcome to the installation.\nThis setup is minimal, professional, and efficient.\n\nDo you want to proceed?" \
    --window-icon="$IMG_DIR/welcome.jpg" --width=450 --height=250; then
    zenity --error --title="Setup" --text="Installation aborted." --window-icon="$IMG_DIR/cancel.jpg" --width=300
    exit 1
fi

# --- 3. FULL INSTALLATION PROCESS (DETAILED) ---
(
echo "10" ; echo "# Initializing system configuration..."
sudo pacman -S --noconfirm mesa xf86-video-vmware xorg-xrandr &> /dev/null

echo "30" ; echo "# Installing desktop environment packages..."
yay -S --noconfirm waybar rofi-wayland wlogout playerctl swww hyprlock grim slurp swappy ttf-font-awesome base-devel &> /dev/null

echo "60" ; echo "# Creating environment directories..."
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/Pictures
curl -L -o ~/Pictures/anime.png "https://raw.githubusercontent.com/dharmx/walls/main/anime/anime_room.png" &> /dev/null

echo "80" ; echo "# Writing detailed configuration files..."

# Full Hyprland Config
cat << 'EOF2' > ~/.config/hypr/hyprland.conf
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
EOF2

# Full Waybar Config
cat << 'EOF3' > ~/.config/waybar/config
{
    "layer": "top", "position": "top", "height": 34, "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery"],
    "clock": { "format": "🕒 {:%I:%M %p}" },
    "pulseaudio": { "format": "🔊 {volume}%" },
    "network": { "format-wifi": " {essid}", "format-ethernet": "🖧 Connected" },
    "battery": { "format": "🔋 {capacity}%" }
}
EOF3

# Full Waybar Style (CSS)
cat << 'EOF4' > ~/.config/waybar/style.css
* { border: none; border-radius: 8px; font-family: "Ubuntu", sans-serif; font-size: 14px; }
window#waybar { background-color: rgba(26, 27, 38, 0.75); border-bottom: 2px solid #bd93f9; color: #c0caf5; }
#workspaces button.active { color: #ff79c6; background-color: rgba(189, 147, 249, 0.2); }
#clock, #pulseaudio, #network, #battery { padding: 0 12px; background-color: rgba(41, 46, 66, 0.8); margin: 4px 2px; }
#clock { color: #7aa2f7; }
#pulseaudio { color: #9ece6a; }
#network { color: #bb9af7; }
EOF4

echo "100" ; echo "# Installation completed successfully!"
) | zenity --progress --title="Installing NeoAnime-Hypr" --percentage=0 --auto-close --width=450 --height=150

# --- 4. SUCCESS WINDOW ---
zenity --info --title="Setup Complete" --text="Installation finished successfully.\nPlease reboot to apply all settings." \
    --window-icon="$IMG_DIR/success.jpg" --width=400

rm -rf "$IMG_DIR"
