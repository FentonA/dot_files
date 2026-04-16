#!/usr/bin/env bash
# bootstrap.sh - Master installer
# Usage: bash bootstrap.sh
# Works on: Ubuntu/Pop OS (apt) and Arch (pacman)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║        dotfiles bootstrap            ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Detect OS ─────────────────────────────────────────────────────────────────
if command -v apt &>/dev/null; then
  PKG_MANAGER="apt"
elif command -v pacman &>/dev/null; then
  PKG_MANAGER="pacman"
else
  echo "Unsupported package manager. Exiting."
  exit 1
fi
echo "===> Package manager: $PKG_MANAGER"

# ── Core CLI packages ──────────────────────────────────────────────────────────
echo "===> Installing core packages..."
if [ "$PKG_MANAGER" = "apt" ]; then
  sudo apt update -qq
  sudo apt install -y \
    git curl unzip fish tmux neovim ripgrep fd-find gnupg \
    postgresql-client libpq-dev redis-tools \
    nginx docker.io lm-sensors ruby jq \
    dunst rofi wl-clipboard xclip \
    fprintd libpam-fprintd \
    awscli
elif [ "$PKG_MANAGER" = "pacman" ]; then
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm \
    git curl unzip fish tmux neovim ripgrep fd gnupg \
    postgresql-libs redis \
    nginx docker jq \
    dunst rofi wl-clipboard xclip \
    fprintd \
    aws-cli
fi

# ── GUI Apps ───────────────────────────────────────────────────────────────────
echo "===> Installing GUI apps..."
if [ "$PKG_MANAGER" = "apt" ]; then
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
elif [ "$PKG_MANAGER" = "pacman" ]; then
  if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd -
  fi
  yay -S --noconfirm slack-desktop discord zen-browser ghostty 2>/dev/null || true
fi

# ── asdf ───────────────────────────────────────────────────────────────────────
echo "===> Installing asdf..."
if [ ! -d "$HOME/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
fi

# ── Symlinks ───────────────────────────────────────────────────────────────────
echo "===> Creating symlinks..."
bash "$DOTFILES_DIR/scripts/symlinks.sh"

# ── Keyboard ───────────────────────────────────────────────────────────────────
echo "===> Configuring keyboard..."
bash "$DOTFILES_DIR/scripts/keyboard.sh"

# ── AWS ────────────────────────────────────────────────────────────────────────
echo "===> Setting up AWS profiles..."
bash "$DOTFILES_DIR/scripts/aws.sh"

# ── Autostart ──────────────────────────────────────────────────────────────────
echo "===> Configuring autostart..."
bash "$DOTFILES_DIR/scripts/autostart.sh"

# ── Fish as default shell ──────────────────────────────────────────────────────
echo "===> Setting fish as default shell..."
FISH_PATH=$(which fish)
grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
chsh -s "$FISH_PATH"

# ── Fish functions ─────────────────────────────────────────────────────────────
echo "===> Installing fish functions..."
mkdir -p ~/.config/fish/functions
cp "$DOTFILES_DIR/config/fish/functions/"*.fish ~/.config/fish/functions/ 2>/dev/null || true

# ── Services ───────────────────────────────────────────────────────────────────
echo "===> Starting services..."
sudo systemctl enable --now docker 2>/dev/null || true
sudo usermod -aG docker "$USER" 2>/dev/null || true

# ── Swap ───────────────────────────────────────────────────────────────────────
if ! swapon --show | grep -q '/swapfile'; then
  echo "===> Creating 8G swapfile..."
  sudo fallocate -l 8G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# ── Redis memory fix ───────────────────────────────────────────────────────────
grep -q 'vm.overcommit_memory' /etc/sysctl.conf ||
  echo 'vm.overcommit_memory = 1' | sudo tee -a /etc/sysctl.conf

# ── Rust ───────────────────────────────────────────────────────────────────────
echo "===> Installing Rust..."
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Add cargo to fish
grep -q 'cargo/bin' ~/.config/fish/config.fish 2>/dev/null || \
  echo 'set -x PATH ~/.cargo/bin $PATH' >> ~/.config/fish/config.fish

elif [ "$PKG_MANAGER" = "pacman" ]; then
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm \
    git curl unzip fish tmux neovim ripgrep fd gnupg \
    postgresql-libs redis \
    nginx docker jq \
    dunst rofi wl-clipboard xclip \
    fprintd \
    aws-cli \
    rustup
fi

# ── GitHub CLI ─────────────────────────────────────────────────────────────────
echo "===> Installing GitHub CLI..."
if [ "$PKG_MANAGER" = "apt" ]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt update && sudo apt install -y gh
elif [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm github-cli
fi

# ── gh extensions ──────────────────────────────────────────────────────────────
if command -v gh &>/dev/null; then
    gh extension install meiji163/gh-notify 2>/dev/null || true
fi

# ── GitHub notification cron ───────────────────────────────────────────────────
CRON_JOB="*/5 * * * * /home/$USER/dot_files/scripts/gh-notify.sh"
crontab -l 2>/dev/null | grep -q 'gh-notify' || \
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# ── kubectl ────────────────────────────────────────────────────────────────────
echo "===> Installing kubectl..."
if ! command -v kubectl &>/dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     Bootstrap complete!              ║"
echo "║                                      ║"
echo "║  Next steps:                         ║"
echo "║  1. Fill in ~/.aws/credentials       ║"
echo "║  2. Log out and back in              ║"
echo "║  3. Run: fprintd-enroll              ║"
echo "╚══════════════════════════════════════╝"
