#!/bin/bash

if ! command -v zenity &> /dev/null; then
    echo "Installing zenity for the GUI wizard..."
    yay -S --noconfirm zenity
fi

zenity --info \
    --title="NeoAnime-Hypr Setup" \
    --text="Welcome to NeoAnime-Hypr Setup Wizard!\n\nThis script will configure your Hyprland environment with an anime theme and VM compatibility fixes." \
    --width=400

zenity --question \
    --title="Proceed Installation?" \
    --text="Do you want to start the installation now?" \
    --width=300

if [ $? -ne 0 ]; then
    zenity --error --text="Installation canceled by user."
    exit 1
fi

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
#clock { color: #7aa2f7;
