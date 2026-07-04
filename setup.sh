#!/bin/bash

# --- 1. تجهيز البيئة والحزم الأساسية جداً ---
# التأكد من تحديث الحزم الأساسية وتثبيت الأدوات المساعدة التي قد تفتقدها نسخة المينيمال
sudo dnf install -y curl zenity networkmanager xorg-x11-server-Xwayland mesa-dri-drivers --nogpgcheck

IMG_DIR="/tmp/neoanime_assets"
mkdir -p "$IMG_DIR"
curl -s -L -o "$IMG_DIR/welcome.jpg" "https://github.com/hussinchahin435-maker/NeoAnime-Hypr/raw/main/6d990f3aa03a6957474e0faa23da4e67.jpg"

# --- 2. تخصيص اللغة والكيبورد ---
LANG_CHOICE=$(zenity --list --title="Celestia Installer (Fedora Minimal)" --text="اختر لغة التثبيت / Choose Language" --column="Lang" "العربية" "English" --hide-header --width=300 --height=150)
KB_LAYOUT=$(zenity --list --title="Keyboard Layout" --text="اختر تخطيط الكيبورد الافتراضي:" --column="Layout" "us,ara" "us" --hide-header --width=300 --height=150)

if [ "$LANG_CHOICE" == "العربية" ]; then
    MSG_START="جاري تثبيت واجهة سيليستيا وهايبرلاند على فيدورا..."; MSG_UPDATE="تحديث النظام وتفعيل المستودعات..."; MSG_CORE="تثبيت Hyprland والملحقات عبر DNF..."; MSG_CONFIG="ضبط الإعدادات والخلفية..."; MSG_DONE="اكتمل التثبيت بنجاح! سيتم تشغيل الواجهة الآن."
else
    MSG_START="Installing Celestia & Hyprland on Fedora..."; MSG_UPDATE="Updating system & enabling COPR..."; MSG_CORE="Installing Hyprland & core tools..."; MSG_CONFIG="Applying configs & wallpaper..."; MSG_DONE="Installation successful! Launching GUI..."
fi

# --- 3. محرك التثبيت ---
(
    # 10% - تفعيل مستودعات COPR لحزم Hyprland
    echo "10"; echo "# $MSG_UPDATE"
    sudo dnf copr enable -y tomaszgasior/hyprland &>/dev/null

    # 40% - تثبيت الواجهة مع تعريفات الصوت والـ VM والأدوات الأساسية
    echo "40"; echo "# $MSG_CORE"
    sudo dnf install -y hyprland kitty waybar rofi-wayland wlogout playerctl swww hyprlock grim slurp swappy fontawesome-fonts-all development-tools pipewire pipewire-utils wireplumber &>/dev/null
    
    # 70% - جلب الخلفية وإنشاء المجلدات
    echo "70"; echo "# $MSG_CONFIG"
    mkdir -p ~/.config/hypr ~/.config/waybar ~/Pictures
    curl -sL -o ~/Pictures/anime.png "https://raw.githubusercontent.com/dharmx/walls/main/anime/anime_room.png"

    # 90% - كتابة إعدادات Hyprland المخففة والسريعة للـ VM (بدون لاق)
    echo "90"; echo "# Writing Celestia configurations..."
    
    # Hyprland Config
    cat << EOF > ~/.config/hypr/hyprland.conf
monitor=,preferred,auto,1
exec-once = swww-daemon & sleep 1 && swww img ~/Pictures/anime.png
exec-once = waybar
exec-once = pipewire & wireplumber

input { kb_layout = $KB_LAYOUT; kb_options = grp:win_space_toggle; follow_mouse = 1 }
general { gaps_in = 2; gaps_out = 5; border_size = 2; col.active_border = rgba(ff79c6ff) rgba(bd93f9ff) 45deg; layout = dwindle }

# تعطيل الأنيميشن والبلور تماماً لضمان أداء صاروخي داخل الـ VM
decoration {
    rounding = 5
    drop_shadow = false
    blur {
        enabled = false
    }
}
animations {
    enabled = false
}

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
    "modules-right": ["hyprland/language", "pulseaudio"],
    "hyprland/language": { "format": "🌐 {}", "format-en": "EN", "format-ara": "AR" },
    "clock": { "format": "🕒 {:%I:%M %p}" }
}
EOF

    # Waybar Style
    cat << 'EOF' > ~/.config/waybar/style.css
* { border: none; border-radius: 8px; font-family: "Ubuntu"; font-size: 14px; }
window#waybar { background-color: rgba(26, 27, 38, 0.75); border-bottom: 2px solid #bd93f9; }
#clock, #pulseaudio, #hyprland-language { padding: 0 12px; background-color: rgba(41, 46, 66, 0.8); margin: 4px 2px; color: #c0caf5; }
#hyprland-language { color: #ff79c6; }
EOF

    echo "100"
) | zenity --progress --title="Celestia Installer" --text="$MSG_START" --percentage=0 --auto-close --width=500 --height=300 --details

# --- 4. إنهاء التثبيت والتشغيل التلقائي ---
rm -rf "$IMG_DIR"

# تشغيل Hyprland تلقائياً فور انتهاء السكربت
if command -v Hyprland &> /dev/null; then
    exec Hyprland
fi
