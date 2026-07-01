#!/bin/bash

# --- CONSTANTS & CONFIG ---
readonly ASSET_DIR="/tmp/neoanime_assets"
readonly LOG_FILE="/tmp/neoanime_install.log"
mkdir -p "$ASSET_DIR"

# --- CORE FUNCTIONS ---
log() { echo "[$(date +'%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

cleanup() { rm -rf "$ASSET_DIR"; }
trap cleanup EXIT

# --- 1. UI & INITIALIZATION ---
# استخدام Zenity كواجهة تفاعلية
LANG_CHOICE=$(zenity --list --title="NeoAnime-Hypr Setup" --text="Choose your preferred language / اختر اللغة المفضلة:" \
    --column="Language" "English" "العربية" --hide-header --width=300 --height=150 2>/dev/null)

[ -z "$LANG_CHOICE" ] && exit 0

KB_LAYOUT=$(zenity --list --title="Keyboard Setup" --text="Select keyboard layout:" \
    --column="Layout" "us" "us,ara" --hide-header --width=300 --height=150 2>/dev/null)

# إعداد النصوص (Localization)
if [ "$LANG_CHOICE" == "العربية" ]; then
    TXT_INSTALL="جاري التثبيت..."; TXT_SUCCESS="تم الإعداد بنجاح!"; TXT_FAIL="حدث خطأ أثناء التثبيت."
else
    TXT_INSTALL="Installing..."; TXT_SUCCESS="Setup successful!"; TXT_FAIL="An error occurred."
fi

# --- 2. EXECUTION ENGINE ---
# تنفيذ المهام داخل دالة مع مخرجات موجهة للسجل
run_tasks() {
    local steps=(10 40 70 90 100)
    
    # 10% - Update
    echo "10"; log "Updating system..."; sudo pacman -Syu --noconfirm &>> "$LOG_FILE"
    
    # 40% - Dependencies
    echo "40"; log "Installing dependencies..."; yay -S --noconfirm waybar rofi-wayland wlogout playerctl swww hyprlock grim slurp swappy ttf-font-awesome &>> "$LOG_FILE"
    
    # 70% - Assets
    echo "70"; log "Setting up assets..."; mkdir -p ~/.config/hypr ~/.config/waybar ~/Pictures
    curl -sL -o ~/Pictures/anime.png "https://raw.githubusercontent.com/dharmx/walls/main/anime/anime_room.png" &>> "$LOG_FILE"
    
    # 90% - Configuration
    echo "90"; log "Applying configurations...";
    cat << EOF > ~/.config/hypr/hyprland.conf
monitor=,preferred,auto,1
exec-once = swww-daemon & sleep 1 && swww img ~/Pictures/anime.png
exec-once = waybar
input { kb_layout = $KB_LAYOUT; kb_options = grp:win_space_toggle; follow_mouse = 1 }
general { gaps_in = 5; gaps_out = 10; border_size = 2; col.active_border = rgba(ff79c6ff) rgba(bd93f9ff) 45deg; layout = dwindle }
bind = SUPER, T, exec, kitty
bind = SUPER, Q, killactive
bind = SUPER, R, exec, rofi -show drun
EOF
    # (إضافة هنا باقي ملفات waybar بنفس الطريقة)
    
    echo "100"; log "Installation complete."
}

# --- 3. FINAL PROGRESS DISPLAY ---
run_tasks | zenity --progress \
    --title="NeoAnime-Hypr" \
    --text="$TXT_INSTALL" \
    --percentage=0 \
    --auto-close \
    --width=500 \
    --height=300 \
    --details

# --- 4. VERIFICATION ---
if [ $? -eq 0 ]; then
    zenity --info --text="$TXT_SUCCESS" --width=300
else
    zenity --error --text="$TXT_FAIL" --width=300
fi
