#!/bin/bash
# Install system dependencies for nvim-fresh

if command -v brew &> /dev/null; then
  brew install ripgrep fd neovim
elif command -v apt &> /dev/null; then
  sudo apt install -y ripgrep fd-find neovim
elif command -v pacman &> /dev/null; then
  sudo pacman -S ripgrep fd neovim
fi

echo "✅ Dependencies installed"
