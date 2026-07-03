#!/bin/bash

# --- 1. الأصول والمجلدات المؤقتة ---
IMG_DIR="/tmp/neoanime_assets"
mkdir -p "$IMG_DIR"
curl -s -L -o "$IMG_DIR/welcome.jpg" "https://github.com/hussinchahin435-maker/NeoAnime-Hypr/raw/main/6d990f3aa03a6957474e0faa23da4e67.jpg"

if ! command -v zenity &> /dev/null; then sudo pacman -S --noconfirm zenity; fi

# --- 2. تخصيص اللغة والكيبورد ---
LANG_CHOICE=$(zenity --list --title="Celestia Installer" --text="اختر لغة التثبيت / Choose Language" --column="Lang" "العربية" "English" --hide-header --width=300 --height=150)
KB_LAYOUT=$(zenity --list --title="Keyboard Layout" --text="اختر تخطيط الكيبورد الافتراضي:" --column="Layout" "us,ara" "us" --hide-header --width=300 --height=150)

if [ "$LANG_CHOICE" == "العربية" ]; then
    MSG_START="جاري تثبيت واجهة سيليستيا وهايبرلاند..."; MSG_UPDATE="تحديث المستودعات..."; MSG_CORE="تثبيت Hyprland والملحقات..."; MSG_CONFIG="ضبط الإعدادات والخلفية..."; MSG_DONE="اكتمل التثبيت بنجاح! يرجى إعادة التشغيل."
else
    MSG_START="Installing Celestia & Hyprland..."; MSG_UPDATE="Updating repos..."; MSG_CORE="Installing Hyprland & core tools..."; MSG_CONFIG="Applying configs & wallpaper..."; MSG_DONE="Installation successful! Please reboot."
fi

# --- 3. محرك التثبيت ---
(
    # 10% - التحديث
    echo "10"; echo "# $MSG_UPDATE"
    sudo pacman -Syu --noconfirm &>/dev/null

    # 40% - تثبيت هايبرلاند والبرامج الأساسية
    echo "40"; echo "# $MSG_CORE"
    # تثبيت الحزم الأساسية من pacman أولاً
    sudo pacman -S --noconfirm hyprland kitty waybar rofi-wayland wlogout playerctl swww hyprlock grim slurp swappy ttf-font-awesome base-devel &>/dev/null
    
    # 70% - جلب الخلفية وإنشاء المجلدات
    echo "70"; echo "# $MSG_CONFIG"
    mkdir -p ~/.config/hypr ~/.config/waybar ~/Pictures
    curl -sL -o ~/Pictures/anime.png "https://raw.githubusercontent.com/dharmx/walls/main/anime/anime_room.png"

    # 90% - كتابة الكونفج الخاص بواجهتك
    echo "90"; echo "# Writing Celestia configurations..."
    
    # Hyprland Config
    cat << EOF > ~/.config/hypr/hyprland.conf
monitor=,preferred,auto,1
exec-once = swww-daemon & sleep 1 && swww img ~/Pictures/anime.png
exec-once = waybar
input { kb_layout = $KB_LAYOUT; kb_options = grp:win_space_toggle; follow_mouse = 1 }
general { gaps_in = 5; gaps_out = 10; border_size = 2; col.active_border = rgba(ff79c6ff) rgba(bd93f9ff) 45deg; layout = dwindle }
decoration { rounding = 10 }
bind = SUPER, T, exec, kitty
bind = SUPER, Q, killactive
bind = SUPER, R, exec, rofi -show drun
bind = SUPER, X, exec, wlogout
bind = SUPER, L, exec, hyprlock
EOF

    # Waybar Config
    cat << 'EOF' > ~/.config/waybar/config
{
    "layer": "top", "position": "top", "height": 34,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["hyprland/language", "pulseaudio", "battery"],
    "hyprland/language": { "format": "🌐 {}", "format-en": "EN", "format-ara": "AR" },
    "clock": { "format": "🕒 {:%I:%M %p}" }
}
EOF

    # Waybar Style
    cat << 'EOF' > ~/.config/waybar/style.css
* { border: none; border-radius: 8px; font-family: "Ubuntu"; font-size: 14px; }
window#waybar { background-color: rgba(26, 27, 38, 0.75); border-bottom: 2px solid #bd93f9; }
#clock, #pulseaudio, #battery, #hyprland-language { padding: 0 12px; background-color: rgba(41, 46, 66, 0.8); margin: 4px 2px; color: #c0caf5; }
#hyprland-language { color: #ff79c6; }
EOF

    echo "100"
) | zenity --progress --title="Celestia Installer" --text="$MSG_START" --percentage=0 --auto-close --width=500 --height=300 --details

# --- 4. إنهاء العملية ---
zenity --info --text="$MSG_DONE" --width=300
rm -rf "$IMG_DIR"
