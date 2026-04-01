#!/usr/bin/env bash
# scripts/symlinks.sh - Creates all config symlinks
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "===> Symlinking configs from $DOTFILES_DIR..."

# fish
mkdir -p ~/.config/fish
ln -sf "$DOTFILES_DIR/config/fish/config.fish" ~/.config/fish/config.fish

# tmux
ln -sf "$DOTFILES_DIR/config/tmux/.tmux.conf" ~/.tmux.conf
mkdir -p ~/.config/tmux
ln -sf "$DOTFILES_DIR/config/tmux/.tmux.conf" ~/.config/tmux/.tmux.conf

# nvim
mkdir -p ~/.config
ln -sf "$DOTFILES_DIR/config/nvim" ~/.config/nvim

# ghostty
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/config/ghostty/config" ~/.config/ghostty/config

# tmuxinator
rm -rf ~/.config/tmuxinator
ln -sf "$DOTFILES_DIR/config/tmuxinator" ~/.config/tmuxinator

# dunst
mkdir -p ~/.config/dunst
ln -sf "$DOTFILES_DIR/config/dunst/dunstrc" ~/.config/dunst/dunstrc

# sway
mkdir -p ~/.config/sway
ln -sf "$DOTFILES_DIR/config/sway/config" ~/.config/sway/config

# waybar
mkdir -p ~/.config/waybar
ln -sf "$DOTFILES_DIR/config/waybar/config" ~/.config/waybar/config
ln -sf "$DOTFILES_DIR/config/waybar/style.css" ~/.config/waybar/style.css

# wofi
mkdir -p ~/.config/wofi
ln -sf "$DOTFILES_DIR/config/wofi/style.css" ~/.config/wofi/style.css

echo "===> Symlinks created"
