#!/usr/bin/env bash
# bootstrap.sh - Master installer
# Usage: bash bootstrap.sh
# Works on: Ubuntu/Pop OS (apt), Arch (pacman), macOS (brew)
#
# Every step is idempotent — re-running on a configured machine should be a
# no-op, not a second install. Anything that only makes sense on a Linux desktop
# (systemd, fprintd, swapfile, sway/waybar/dunst, flatpak) is behind an $OS
# guard so the macOS path doesn't half-run and die.
#
# Check the whole file parses before trusting it:  bash -n bootstrap.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║        dotfiles bootstrap            ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Detect OS and package manager ─────────────────────────────────────────────
case "$(uname)" in
Darwin)
  OS=mac
  PKG_MANAGER=brew
  ;;
Linux)
  OS=linux
  # pacman first: an Arch box with an `apt` binary lying around shouldn't be
  # mistaken for Debian.
  if command -v pacman &>/dev/null; then
    PKG_MANAGER=pacman
  elif command -v apt &>/dev/null; then
    PKG_MANAGER=apt
  else
    echo "Unsupported Linux distro (need apt or pacman). Exiting."
    exit 1
  fi
  ;;
*)
  echo "Unsupported OS: $(uname). Exiting."
  exit 1
  ;;
esac
echo "===> OS: $OS / package manager: $PKG_MANAGER"

# ── Homebrew (macOS) ──────────────────────────────────────────────────────────
if [ "$OS" = mac ] && ! command -v brew &>/dev/null; then
  echo "===> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # The installer doesn't touch the *current* shell's PATH.
  for prefix in /opt/homebrew /usr/local; do
    [ -x "$prefix/bin/brew" ] && eval "$($prefix/bin/brew shellenv)" && break
  done
fi

# ── Core CLI packages ─────────────────────────────────────────────────────────
echo "===> Installing core packages..."
case "$PKG_MANAGER" in
apt)
  sudo apt update -qq
  sudo apt install -y \
    git curl unzip fish tmux neovim ripgrep fd-find gnupg \
    postgresql-client libpq-dev redis-tools \
    nginx docker.io lm-sensors ruby jq \
    dunst rofi wl-clipboard xclip \
    fprintd libpam-fprintd \
    awscli
  ;;
pacman)
  sudo pacman -Syu --noconfirm
  # rustup comes from the repos here rather than via rustup.rs — that was the
  # intent of the block that used to sit, unreachable, after the Rust section.
  sudo pacman -S --noconfirm --needed \
    git curl unzip fish tmux neovim ripgrep fd gnupg \
    postgresql-libs redis \
    nginx docker jq \
    dunst rofi wl-clipboard xclip \
    fprintd \
    aws-cli \
    rustup
  ;;
brew)
  brew install \
    git curl unzip fish tmux neovim ripgrep fd gnupg \
    libpq redis \
    nginx jq \
    awscli
  # Docker Desktop is a cask, not the `docker` formula (that's just the CLI).
  brew install --cask docker 2>/dev/null || true
  ;;
esac

# ── GUI apps ──────────────────────────────────────────────────────────────────
echo "===> Installing GUI apps..."
case "$PKG_MANAGER" in
apt)
  if ! command -v flatpak &>/dev/null; then
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
  flatpak install -y flathub com.slack.Slack 2>/dev/null || true
  flatpak install -y flathub com.discordapp.Discord 2>/dev/null || true
  flatpak install -y flathub app.zen_browser.zen 2>/dev/null || true
  if ! command -v ghostty &>/dev/null; then
    sudo snap install ghostty 2>/dev/null || true
  fi
  ;;
pacman)
  if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
  fi
  yay -S --noconfirm slack-desktop discord zen-browser ghostty 2>/dev/null || true
  ;;
brew)
  brew install --cask slack discord zen ghostty 2>/dev/null || true
  ;;
esac

# ── asdf ──────────────────────────────────────────────────────────────────────
# Pinned to v0.14.0 because config.fish sources ~/.asdf/asdf.fish, which 0.16+
# (a Go rewrite) no longer ships. config.fish falls back to ~/.asdf/shims if
# you ever bump this.
echo "===> Installing asdf..."
if [ ! -d "$HOME/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
fi

# ── Rust ──────────────────────────────────────────────────────────────────────
# Arch got rustup from pacman above; everywhere else use the official installer.
echo "===> Installing Rust..."
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
# ~/.cargo/bin lands on PATH via fish/config.fish — deliberately NOT appended
# here. config.fish is a symlink into this repo, so the old `echo >> config.fish`
# wrote into your git working tree on every bootstrap.
rustup default stable 2>/dev/null || true

# ── Symlinks ──────────────────────────────────────────────────────────────────
echo "===> Creating symlinks..."
bash "$DOTFILES_DIR/scripts/symlinks.sh"

# ── GitHub CLI ────────────────────────────────────────────────────────────────
echo "===> Installing GitHub CLI..."
if ! command -v gh &>/dev/null; then
  case "$PKG_MANAGER" in
  apt)
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
      sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
      sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt update && sudo apt install -y gh
    ;;
  pacman) sudo pacman -S --noconfirm --needed github-cli ;;
  brew) brew install gh ;;
  esac
fi

if command -v gh &>/dev/null; then
  gh extension install meiji163/gh-notify 2>/dev/null || true
fi

# ── kubectl ───────────────────────────────────────────────────────────────────
echo "===> Installing kubectl..."
if ! command -v kubectl &>/dev/null; then
  if [ "$PKG_MANAGER" = brew ]; then
    brew install kubectl
  else
    # Don't hardcode amd64 — Arch on ARM is a real thing.
    case "$(uname -m)" in
    x86_64) KARCH=amd64 ;;
    aarch64 | arm64) KARCH=arm64 ;;
    *) KARCH="" ;;
    esac
    if [ -n "$KARCH" ]; then
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$KARCH/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      rm kubectl
    else
      echo "  skip: unrecognized arch $(uname -m)"
    fi
  fi
fi

# ── AWS profiles ──────────────────────────────────────────────────────────────
echo "===> Setting up AWS profiles..."
bash "$DOTFILES_DIR/scripts/aws.sh"

# ── Linux desktop only ────────────────────────────────────────────────────────
# Keyboard remap (X11/Wayland xkb), autostart (i3/Hyprland/GNOME), fingerprint,
# swap, and the docker service are all Linux concepts. On macOS: remap Caps Lock
# in System Settings > Keyboard > Modifier Keys, and autostart via Login Items.
if [ "$OS" = linux ]; then
  echo "===> Configuring keyboard..."
  bash "$DOTFILES_DIR/scripts/keyboard.sh"

  echo "===> Configuring autostart..."
  bash "$DOTFILES_DIR/scripts/autostart.sh"

  echo "===> Starting services..."
  sudo systemctl enable --now docker 2>/dev/null || true
  sudo usermod -aG docker "$USER" 2>/dev/null || true

  if ! swapon --show | grep -q '/swapfile'; then
    echo "===> Creating 8G swapfile..."
    sudo fallocate -l 8G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  fi

  # Redis forks to snapshot; without this it fails under memory pressure.
  grep -q 'vm.overcommit_memory' /etc/sysctl.conf ||
    echo 'vm.overcommit_memory = 1' | sudo tee -a /etc/sysctl.conf
else
  echo "===> Skipping linux-only setup (keyboard, autostart, systemd, swap, sysctl)"
  echo "     macOS: remap Caps Lock in System Settings > Keyboard > Modifier Keys"
fi

# ── GitHub notification cron ──────────────────────────────────────────────────
# $DOTFILES_DIR, not a hardcoded /home/$USER — the repo lives under /Users on mac.
CRON_JOB="*/5 * * * * $DOTFILES_DIR/scripts/gh-notify.sh"
crontab -l 2>/dev/null | grep -q 'gh-notify' ||
  (
    crontab -l 2>/dev/null
    echo "$CRON_JOB"
  ) | crontab -

# ── Fish as default shell ─────────────────────────────────────────────────────
echo "===> Setting fish as default shell..."
FISH_PATH=$(command -v fish)
if [ -n "$FISH_PATH" ]; then
  grep -q "^$FISH_PATH\$" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
  [ "$SHELL" = "$FISH_PATH" ] || chsh -s "$FISH_PATH"
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     Bootstrap complete!              ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  Next steps:"
echo "  1. Fill in ~/.aws/credentials"
echo "  2. Log out and back in (docker group + default shell)"
if [ "$OS" = linux ]; then
  echo "  3. Run: fprintd-enroll"
fi
echo ""
echo "  Job-specific shell config goes in ~/.config/fish/<name>.local.fish"
echo "  (untracked, auto-sourced). See README.md."
echo ""
