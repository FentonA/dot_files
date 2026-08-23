#!/usr/bin/env bash
# install-sway-sessions.sh - registers the profile sessions with the login screen.
#
#   sudo bash ~/dot_files/scripts/install-sway-sessions.sh
#
# Needs root for exactly two reasons, both outside $HOME:
#   * GDM only reads session entries from /usr/share/wayland-sessions. It does
#     not look in ~/.local/share, so a user-level install would never show up in
#     the session picker.
#   * the launcher goes next to sway-next-session in /opt/sway-next/bin, so the
#     whole source-built stack stays in one place.
#
# Everything else — the sway configs, the profile files, the scripts on PATH —
# is installed unprivileged by scripts/symlinks.sh. Run that first.
#
# Safe to re-run. Re-run it after editing sway-profile-session or either
# .desktop file, since those are copied rather than symlinked (GDM runs as a
# different user and will not follow a link into your home directory).
set -eu

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SESSIONS=/usr/share/wayland-sessions
BINDIR=/opt/sway-next/bin

[ "$(id -u)" -eq 0 ] || { echo "run me with sudo"; exit 1; }

[ -x "$BINDIR/sway-next-session" ] || {
  echo "error: $BINDIR/sway-next-session is missing."
  echo "The profile sessions build on the source-built Sway 1.11 stack."
  echo "Run scripts/sway-next-build.sh first, or edit sway-profile-session to"
  echo "exec the distro sway instead."
  exit 1
}

echo "===> Installing session launcher to $BINDIR..."
install -m 0755 "$DOTFILES_DIR/scripts/sway-profile-session" "$BINDIR/sway-profile-session"
echo "  $BINDIR/sway-profile-session"

echo "===> Installing session entries to $SESSIONS..."
mkdir -p "$SESSIONS"
for entry in "$DOTFILES_DIR"/scripts/sway-*.desktop; do
  base="$(basename "$entry")"
  case "$base" in
    sway-next.desktop) continue ;;   # owned by sway-next-build.sh, not us
  esac
  install -m 0644 "$entry" "$SESSIONS/$base"
  echo "  $SESSIONS/$base  ($(sed -n 's/^Name=//p' "$entry"))"
done

echo
echo "===> Done. Log out and pick the session from the gear/list on the login screen."
echo "     The plain \"Sway\" sessions are untouched, so they stay as a fallback."
