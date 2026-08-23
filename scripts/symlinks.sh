#!/usr/bin/env bash
# scripts/symlinks.sh - Creates all config symlinks
#
# Safe to re-run. Two rules make that true:
#   * ln -sfn, never ln -sf, for anything that resolves to a directory. Without
#     -n, ln follows an existing symlink-to-dir and creates the link *inside*
#     it — a second run used to leave you with ~/.config/nvim/nvim.
#   * anything real already sitting at the destination is moved aside to
#     .pre-dotfiles.bak rather than clobbered.
#
# Linux-only desktop configs (sway/waybar/wofi/dunst) are skipped on macOS.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "===> Symlinking configs from $DOTFILES_DIR..."

case "$(uname)" in
Darwin) OS=mac ;;
*) OS=linux ;;
esac

link() {
  local src="$1" dest="$2"

  if [ ! -e "$src" ]; then
    echo "  skip (not in repo): ${src#$DOTFILES_DIR/}"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  # Move aside anything real in the way. A pre-existing symlink is ours (or
  # stale) and gets replaced silently; a real file or dir is the user's and
  # never gets destroyed without a copy left behind.
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.pre-dotfiles.bak"
    echo "  backed up $dest -> $(basename "$dest").pre-dotfiles.bak"
  fi

  ln -sfn "$src" "$dest"
  echo "  $dest"
}

# ── fish ──────────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/fish/config.fish" ~/.config/fish/config.fish

# Functions are linked individually rather than linking the whole directory:
# fish's `funcsave` writes into ~/.config/fish/functions, and if that were a
# link into the repo every saved one-off would show up as an untracked change.
# The glob means new files in the repo are picked up without editing this list.
mkdir -p ~/.config/fish/functions
for fn in "$DOTFILES_DIR"/fish/functions/*.fish; do
  [ -e "$fn" ] || continue
  link "$fn" ~/.config/fish/functions/"$(basename "$fn")"
done

# ── tmux ──────────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
link "$DOTFILES_DIR/tmux/.tmux.conf" ~/.config/tmux/.tmux.conf

# ── nvim ──────────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/nvim" ~/.config/nvim

# ── ghostty ───────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
# Ghostty on macOS reads the XDG path too, but its own docs point at the
# Application Support path, so link both and stay out of the argument.
if [ "$OS" = mac ]; then
  link "$DOTFILES_DIR/ghostty/config" \
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
fi

# ── tmuxinator ────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/tmuxinator" ~/.config/tmuxinator

# ── anki card templates (see anki-templates/README.md) ────────────────────────
link "$DOTFILES_DIR/anki-templates" ~/anki-templates

# ── sway startup layouts ──────────────────────────────────────────────────────
# The layout *files* are linked on every OS (harmless, and keeps the repo the
# single source of truth); the script itself only goes on PATH where sway can
# actually run it.
link "$DOTFILES_DIR/layouts" ~/.config/sway-layouts

# ── linux desktop ─────────────────────────────────────────────────────────────
# sway/waybar/wofi/dunst are Wayland-only; none of it means anything on macOS.
if [ "$OS" = linux ]; then
  link "$DOTFILES_DIR/dunst/dunstrc" ~/.config/dunst/dunstrc
  # `common` holds everything the session profiles share; `config` and each
  # profiles/*.config include it. Sway resolves a relative `include` against the
  # including file's own directory, so all three have to sit together under
  # ~/.config/sway for `include common` / `include ../common` to resolve.
  link "$DOTFILES_DIR/config/sway/common" ~/.config/sway/common
  link "$DOTFILES_DIR/config/sway/config" ~/.config/sway/config
  link "$DOTFILES_DIR/config/sway/profiles" ~/.config/sway/profiles
  link "$DOTFILES_DIR/config/waybar/config" ~/.config/waybar/config
  link "$DOTFILES_DIR/config/waybar/style.css" ~/.config/waybar/style.css
  link "$DOTFILES_DIR/config/wofi/style.css" ~/.config/wofi/style.css

  # sway-layout onto PATH. ~/.local/bin is already there ahead of
  # /usr/local/bin, so it shadows nothing and needs no rehash.
  mkdir -p ~/.local/bin
  link "$DOTFILES_DIR/scripts/sway-layout" ~/.local/bin/sway-layout

  # The login-screen half (the session launcher in /opt and the .desktop entries
  # in /usr/share/wayland-sessions) needs root and is NOT done here — run
  # scripts/install-sway-sessions.sh with sudo for that.
else
  echo "  skip (linux only): dunst, sway, waybar, wofi"
fi

echo "===> Symlinks created"
