#!/bin/bash

# Create a temporary directory for helper images
IMG_DIR="/tmp/neoanime_assets"
mkdir -p "$IMG_DIR"

# Download the wizard images using the exact long names from your repository
curl -s -L -o "$IMG_DIR/welcome.jpg" "https://raw.githubusercontent.com/hussinchahin435-maker/NeoAnime-Hypr/main/6d990f3aa03a6957474e0faa23da4e67.jpg"
curl -s -L -o "$IMG_DIR/cancel.jpg" "https://raw.githubusercontent.com/hussinchahin435-maker/NeoAnime-Hypr/main/9948b8482680859cc1c7562d6431b68b.jpg"
curl -s -L -o "$IMG_DIR/success.jpg" "https://raw.githubusercontent.com/hussinchahin435-maker/NeoAnime-Hypr/main/b08bf2c9acf2dbeaa50835511d2a1d48.jpg"

# Ensure zenity is installed for the GUI
if ! command -v zenity &> /dev/null; then
    echo "Installing zenity for the GUI wizard..."
    yay -S --noconfirm zenity
fi

# 1. Welcome & Question Window with Image 1 (6d990f3a...)
zenity --question \
    --title="NeoAnime-Hypr Setup" \
    --text="Welcome to NeoAnime-Hypr Setup Wizard!\n\nDo you want to start the installation now?" \
    --window-icon="$IMG_DIR/welcome.jpg" \
    --icon-name="$IMG_DIR/welcome.jpg" \
    --width=450

if [ $? -ne 0 ]; then
    # 2. Cancel Window with Image 2 (9948b848...)
    zenity --error \
        --title="Installation Canceled" \
        --text="Installation canceled by user. See you next time!" \
        --window-icon="$IMG_DIR/cancel.jpg" \
        --icon-name="$IMG_DIR/cancel.jpg" \
        --width=450
    exit 1
fi

# 3. Progress Bar with incremental percentage updates
(
echo "10" ; echo "# Initializing system configuration..."
sleep 1

echo "20" ; echo "# Installing Arch VM video drivers via Pacman..."
sudo pacman -S --noconfirm mesa xf86-video-vmware xorg-xrandr &> /dev/null

echo "40" ; echo "# Installing core desktop packages via Yay (This may take a moment)..."
yay -S --noconfirm waybar rofi-wayland wlogout playerctl swww hyprlock grim slurp swappy ttf-font-awesome base-devel &> /dev/null

echo "60" ; echo "# Creating environment directories..."
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/Pictures

echo "70" ; echo "# Downloading default anime wallpaper..."
curl -L -o ~/Pictures/anime.png "https://raw.githubusercontent.com/dharmx/walls/main/anime/anime_room.png" &> /dev/null

echo "80" ; echo "# Generating configuration files and VM patches..."

# Generate hyprland.conf with Arch VM fixes
cat << 'EOF2' > ~/.config/hypr/hyprland.conf
monitor=,preferred,auto,1

env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_NO_HARDWARE_CURSORS,1
env = National_RENDERER,pixman
env = WLR_RENDERER,pixman
env = QSG_RENDER_LOOP,basic

exec-once = swww-daemon & sleep 1 && swww img ~/Pictures/anime.png
exec-once = waybar

input {
    kb_layout = us,ara
    kb_options = grp:win_space_toggle
    follow_mouse = 1
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(ff79c6ff) rgba(bd93f9ff) 45deg
    col.inactive_border = rgba(282a36aa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = false
    }
}

animations {
    enabled = false
}

$mainMod = SUPER

bind = $mainMod, T, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod, X, exec, wlogout
bind = $mainMod, L, exec, hyprlock
bind = $mainMod, E, exec, dolphin

bind = $mainMod, UP, exec, playerctl play-pause
bind = $mainMod, RIGHT, exec, playerctl next
bind = $mainMod, LEFT, exec, playerctl previous

bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF2

# Generate Waybar Config
cat << 'EOF3' > ~/.config/waybar/config
{
    "layer": "top",
    "position": "top",
    "height": 34,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery"],
    "clock": {
        "format": "🕒 {:%I:%M %p}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    "pulseaudio": {
        "format": "🔊 {volume}%"
    },
    "network": {
        "format-wifi": "  {essid}",
        "format-ethernet": "🖧  Connected"
    },
    "battery": {
        "format": "🔋 {capacity}%"
    }
}
EOF3

# Generate Waybar Style CSS
cat << 'EOF4' > ~/.config/waybar/style.css
* {
    border: none;
    border-radius: 8px;
    font-family: "Ubuntu", sans-serif;
    font-size: 14px;
}
window#waybar {
    background-color: rgba(26, 27, 38, 0.75);
    border-bottom: 2px solid #bd93f9;
    color: #c0caf5;
}
#workspaces button.active {
    color: #ff79c6;
    background-color: rgba(189, 147, 249, 0.2);
}
#clock, #pulseaudio, #network, #battery {
    padding: 0 12px;
    background-color: rgba(41, 46, 66, 0.8);
    margin: 4px 2px;
}
#clock { color: #7aa2f7; }
#pulseaudio { color: #9ece6a; }
#network { color: #bb9af7; }
EOF4

echo "90" ; echo "# Finalizing installation components..."
sleep 1

echo "100" ; echo "# Done!"
) | zenity --progress \
    --title="Installing NeoAnime-Hypr" \
    --text="Preparing environment..." \
    --percentage=0 \
    --auto-close \
    --width=450

# 4. Success Window with Image 3 (b08bf2c9...)
zenity --info \
    --title="Success!" \
    --text="NeoAnime-Hypr installation complete!\n\nAll settings have been patched for Arch VM compatibility.\nPlease log out and select Hyprland from your login screen." \
    --window-icon="$IMG_DIR/success.jpg" \
    --icon-name="$IMG_DIR/success.jpg" \
    --width=450

# Cleanup temporary files
rm -rf "$IMG_DIR"

