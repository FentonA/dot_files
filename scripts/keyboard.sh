#!/usr/bin/env bash
# scripts/keyboard.sh - CapsLock <-> Ctrl swap, works across X11/Wayland/Arch

set -e

echo "===> Configuring keyboard (CapsLock <-> Ctrl)..."

# ── Detect display server ──────────────────────────────────────────────────────
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  SESSION="wayland"
else
  SESSION="x11"
fi

# ── System-level config (works on all distros) ─────────────────────────────────
if [ -f /etc/default/keyboard ]; then
  sudo sed -i 's/XKBOPTIONS=".*"/XKBOPTIONS="ctrl:swapcaps"/' /etc/default/keyboard
  # If the line doesn't exist at all
  grep -q 'XKBOPTIONS' /etc/default/keyboard ||
    echo 'XKBOPTIONS="ctrl:swapcaps"' | sudo tee -a /etc/default/keyboard
  sudo dpkg-reconfigure -phigh console-setup 2>/dev/null || true
fi

# ── X11 xorg config (Arch / i3 / X11 sessions) ────────────────────────────────
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf >/dev/null <<'EOF'
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbOptions" "ctrl:swapcaps"
EndSection
EOF

# ── Wayland / fish env var ─────────────────────────────────────────────────────
FISH_CONFIG="$HOME/.config/fish/config.fish"
grep -q 'XKB_DEFAULT_OPTIONS' "$FISH_CONFIG" 2>/dev/null ||
  echo 'set -x XKB_DEFAULT_OPTIONS ctrl:swapcaps' >>"$FISH_CONFIG"

# ── GNOME gsettings (if applicable) ───────────────────────────────────────────
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swapcaps']" 2>/dev/null || true
fi

# ── Apply immediately for current session ─────────────────────────────────────
if [ "$SESSION" = "x11" ]; then
  setxkbmap -option ctrl:swapcaps 2>/dev/null || true
fi

echo "===> Keyboard configured (takes full effect after reboot)"
