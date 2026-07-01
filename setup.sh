#!/bin/bash

echo "============================================="
echo "   🚀 Starting NeoAnime-Hypr Setup Wizard"
echo "============================================="

yay -S --noconfirm waybar rofi-wayland wlogout playerctl swww hyprlock grim slurp swappy ttf-font-awesome base-devel

mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi
mkdir -p ~/Pictures

curl -L -o ~/Pictures/anime.png "https://raw.githubusercontent.com/dharmx/walls/main/anime/anime_room.png"

cat << 'EOF' > ~/.config/hypr/hyprland.conf
monitor=,preferred,auto,1

env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = QSG_RENDER_LOOP,basic
env = WLR_NO_HARDWARE_CURSORS,1

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
    drop_shadow = false
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
EOF

cat << 'EOF' > ~/.config/waybar/config
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
EOF

cat << 'EOF' > ~/.config/waybar/style.css
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
EOF

echo "============================================="
echo " ✨ NeoAnime-Hypr installation complete!"
echo "============================================="
