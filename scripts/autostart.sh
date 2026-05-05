#!/usr/bin/env bash
# autostart.sh - Configures apps to start on login
# Detects i3, Hyprland, or GNOME and configures accordingly

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Apps to autostart
AUTOSTART_APPS=(
  "ghostty"
  "slack"
  "discord"
)

detect_wm() {
  if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "hyprland"
  elif [ -n "$I3SOCK" ]; then
    echo "i3"
  elif [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    echo "gnome"
  elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    echo "kde"
  else
    echo "unknown"
  fi
}

setup_i3() {
  echo "===> Configuring i3 autostart..."
  I3_CONFIG="$HOME/.config/i3/config"
  mkdir -p ~/.config/i3

  # Remove old autostart lines
  sed -i '/^exec --no-startup-id ghostty/d' "$I3_CONFIG" 2>/dev/null || true
  sed -i '/^exec --no-startup-id slack/d' "$I3_CONFIG" 2>/dev/null || true
  sed -i '/^exec --no-startup-id discord/d' "$I3_CONFIG" 2>/dev/null || true
  sed -i '/^exec --no-startup-id dunst/d' "$I3_CONFIG" 2>/dev/null || true

  # Add fresh autostart lines
  cat >>"$I3_CONFIG" <<'EOF'

# Autostart
exec --no-startup-id dunst
exec --no-startup-id ghostty
exec --no-startup-id slack
exec --no-startup-id discord
EOF
  echo "===> i3 autostart configured"
}

setup_hyprland() {
  echo "===> Configuring Hyprland autostart..."
  HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
  mkdir -p ~/.config/hypr

  # Remove old exec-once lines for our apps
  sed -i '/^exec-once = ghostty/d' "$HYPR_CONFIG" 2>/dev/null || true
  sed -i '/^exec-once = slack/d' "$HYPR_CONFIG" 2>/dev/null || true
  sed -i '/^exec-once = discord/d' "$HYPR_CONFIG" 2>/dev/null || true
  sed -i '/^exec-once = dunst/d' "$HYPR_CONFIG" 2>/dev/null || true

  cat >>"$HYPR_CONFIG" <<'EOF'

# Autostart
exec-once = dunst
exec-once = ghostty
exec-once = slack
exec-once = discord
EOF
  echo "===> Hyprland autostart configured"
}

setup_gnome() {
  echo "===> Configuring GNOME autostart..."
  mkdir -p ~/.config/autostart

  for app in "${AUTOSTART_APPS[@]}"; do
    cat >~/.config/autostart/${app}.desktop <<EOF
[Desktop Entry]
Type=Application
Name=$app
Exec=$app
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
  done

  # dunst
  cat >~/.config/autostart/dunst.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=dunst
Exec=dunst
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
  echo "===> GNOME autostart configured"
}

setup_systemd_user() {
  echo "===> Configuring systemd user services for autostart..."
  mkdir -p ~/.config/systemd/user

  for app in "${AUTOSTART_APPS[@]}"; do
    cat >~/.config/systemd/user/${app}.service <<EOF
[Unit]
Description=$app
After=graphical-session.target

[Service]
ExecStart=$(which $app 2>/dev/null || echo "/usr/bin/$app")
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF
    systemctl --user enable ${app}.service 2>/dev/null || true
  done
  echo "===> systemd user services configured"
}

WM=$(detect_wm)
echo "===> Detected: $WM"

case "$WM" in
i3) setup_i3 ;;
hyprland) setup_hyprland ;;
gnome) setup_gnome ;;
*)
  echo "===> WM not detected, setting up both .desktop files and systemd..."
  setup_gnome
  ;;
esac

echo "===> Autostart configuration complete"
