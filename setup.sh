#!/bin/bash

echo "============================================="
echo "   🚀 Starting NeoAnime-Hypr Setup Wizard"
echo "============================================="

# 1. تثبيت كل الحزم المطلوبة دفعة واحدة
echo "📦 1/4 Installing core packages via Yay..."
yay -S --noconfirm waybar rofi-wayland wlogout playerctl swww hyprlock grim slurp swappy ttf-font-awesome base-devel

# 2. إنشاء مجلدات النظام للإعدادات والصور
echo "📂 2/4 Creating configuration directories..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi
mkdir -p ~/Pictures

# 3. تحميل خلفية أنمي وتثبيتها لمنع السواد الممل
echo "🖼️ 3/4 Downloading default anime wallpaper..."
curl -L -o ~/Pictures/anime.png "https://raw.githubusercontent.com/dharmx/walls/main/anime/anime_room.png"

# 4. بناء ملف إعدادات Hyprland المدمج والخفيف (66 سطراً)
echo "⚙️ 4/4 Generating hyprland.conf (Optimized & Clean)..."
cat << 'EOF' > ~/.config/hypr/hyprland.conf
monitor=,preferred,auto,1

env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = QSG_RENDER_LOOP,basic
env = WLR_NO_HARDWARE_CURSORS,1

# التشغيل التلقائي للخلفية والبار
exec-once = swww-daemon & sleep 1 && swww img ~/Pictures/anime.png
exec-once = waybar

# الكيبورد العربي والتبديل بـ Super + Space
input {
    kb_layout = us,ara
    kb_options = grp:win_space_toggle
    follow_mouse = 1
}

# مظهر النوافذ بألوان الأنمي والنيون
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

# اختصارات النظام وقوائم JaKooLit الذكية
bind = $mainMod, T, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod, X, exec, wlogout
bind = $mainMod, L, exec, hyprlock
bind = $mainMod, E, exec, dolphin

# تحكم ميديا خفيف (بديل Caelestia)
bind = $mainMod, UP, exec, playerctl play-pause
bind = $mainMod, RIGHT, exec, playerctl next
bind = $mainMod, LEFT, exec, playerctl previous

# التنقل
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF

# 5. بناء ثيم الأنمي الشفاف لـ Waybar
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
echo " Log out and choose Hyprland from your login screen."
echo "============================================="
