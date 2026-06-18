#!/usr/bin/env bash
#
# sway-next-build.sh - build Sway 1.11 + wlroots 0.19 + xdg-desktop-portal-wlr
# 0.8.x from source into an isolated /opt/sway-next prefix, and register a
# separate GDM session for it. This is what enables PER-WINDOW screenshare on
# Sway (the ext-image-copy-capture-v1 + foreign-toplevel capture-source stack),
# which Ubuntu 24.04's Sway 1.9 / wlroots 0.17 / xdpw 0.7.1 cannot do.
#
# SAFE BY DESIGN: nothing here touches the apt-installed Sway 1.9. The new stack
# lives under /opt/sway-next with a different wlroots soname, and a new greeter
# entry "Sway 1.11 (per-window screenshare)". To roll back, just pick the old
# "Sway" session at the GDM login screen (see REVERT at the bottom).
#
# Run with: sudo bash scripts/sway-next-build.sh
# Re-runnable (idempotent): re-running rebuilds and reinstalls cleanly.
#
# Full uninstall:  sudo bash scripts/sway-next-build.sh --uninstall

set -euo pipefail

PREFIX=/opt/sway-next
SRC="$PREFIX/src"
LIBDIR="$PREFIX/lib/x86_64-linux-gnu"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pinned versions (see notes at end for the compatibility rationale).
LIBDISPLAY_INFO_TAG=0.2.0
LIBLIFTOFF_TAG=v0.5.0
PIXMAN_TAG=pixman-0.44.2
LIBINPUT_TAG=1.27.1
WLROOTS_TAG=0.19.2
SWAY_TAG=1.11
XDPW_TAG=v0.8.2

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Run as root: sudo bash scripts/sway-next-build.sh"

# ---------------------------------------------------------------------------
# Uninstall path
# ---------------------------------------------------------------------------
if [ "${1:-}" = "--uninstall" ]; then
  log "Removing $PREFIX, the GDM session entry, and the ld.so.conf.d entry"
  rm -rf "$PREFIX"
  rm -f /usr/share/wayland-sessions/sway-next.desktop
  rm -f /etc/ld.so.conf.d/sway-next.conf
  ldconfig
  echo "Done. Log into the old 'Sway' session (it was never modified)."
  exit 0
fi

# ---------------------------------------------------------------------------
# 1. Build dependencies
# ---------------------------------------------------------------------------
log "Installing build dependencies (apt)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
  build-essential pkg-config git ca-certificates meson ninja-build cmake scdoc \
  libpixman-1-dev libdrm-dev libgbm-dev libwayland-dev wayland-protocols \
  libwayland-egl-backend-dev libxkbcommon-dev libudev-dev libseat-dev \
  libinput-dev libxcb1-dev libxcb-composite0-dev libxcb-icccm4-dev \
  libxcb-res0-dev libxcb-ewmh-dev libcairo2-dev libpango1.0-dev \
  libgdk-pixbuf-2.0-dev libjson-c-dev libpcre2-dev libevdev-dev \
  libsystemd-dev libpipewire-0.3-dev libspa-0.2-dev libvulkan-dev \
  glslang-tools libegl1-mesa-dev libgles2-mesa-dev libgl1-mesa-dev \
  hwdata libxml2-dev libmtdev-dev libinih-dev

mkdir -p "$SRC"

# Build env so each component finds the ones built before it in this prefix.
export PKG_CONFIG_PATH="$LIBDIR/pkgconfig:$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$LIBDIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Bake an rpath into every built binary/library so they resolve their /opt
# dependencies (wlroots, pixman, libdisplay-info, libliftoff) WITHOUT putting
# $LIBDIR on the global ldconfig path. That keeps the new pixman (same soname as
# the system one) from shadowing it for the rest of the system, including the
# old Sway 1.9 session. RUNPATH is per-object, so building every component with
# it makes the chain (sway -> wlroots -> pixman) resolve entirely within /opt.
export LDFLAGS="-Wl,-rpath,$LIBDIR${LDFLAGS:+ $LDFLAGS}"

# clone_or_update <url> <dir> <tag>
clone_or_update() {
  local url="$1" dir="$2" tag="$3"
  if [ -d "$SRC/$dir/.git" ]; then
    git -C "$SRC/$dir" fetch --tags --depth 1 origin "$tag"
  else
    git clone --depth 1 --branch "$tag" "$url" "$SRC/$dir"
  fi
  git -C "$SRC/$dir" checkout -q "$tag"
}

# meson_build <dir> <installed-artifact> [extra meson args...]
# Skips the component if <installed-artifact> (relative to $PREFIX) already
# exists, so re-running after a failure only rebuilds what is missing. Set
# FORCE=1 to rebuild everything from scratch.
meson_build() {
  local dir="$1" check="$2"; shift 2
  if [ "${FORCE:-0}" != "1" ] && [ -e "$PREFIX/$check" ]; then
    echo "    skip $dir ($check already installed; FORCE=1 to rebuild)"
    return
  fi
  rm -rf "$SRC/$dir/build"
  meson setup "$SRC/$dir/build" "$SRC/$dir" \
    --prefix="$PREFIX" --libdir="lib/x86_64-linux-gnu" \
    --buildtype=release "$@"
  ninja -C "$SRC/$dir/build"
  ninja -C "$SRC/$dir/build" install
}

# ---------------------------------------------------------------------------
# 2. libdisplay-info 0.2.0  (wlroots 0.19 needs >= 0.2.0; 24.04 ships 0.1.1)
# ---------------------------------------------------------------------------
log "Building libdisplay-info $LIBDISPLAY_INFO_TAG"
clone_or_update https://gitlab.freedesktop.org/emersion/libdisplay-info.git libdisplay-info "$LIBDISPLAY_INFO_TAG"
meson_build libdisplay-info lib/x86_64-linux-gnu/pkgconfig/libdisplay-info.pc

# ---------------------------------------------------------------------------
# 3. libliftoff 0.5.0  (wlroots 0.19 needs >= 0.5.0; 24.04 ships 0.4.1)
# ---------------------------------------------------------------------------
log "Building libliftoff $LIBLIFTOFF_TAG"
clone_or_update https://gitlab.freedesktop.org/emersion/libliftoff.git libliftoff "$LIBLIFTOFF_TAG"
meson_build libliftoff lib/x86_64-linux-gnu/pkgconfig/libliftoff.pc

# ---------------------------------------------------------------------------
# 3b. pixman 0.44  (wlroots 0.19 needs >= 0.43.0; 24.04 ships 0.42.2)
# ---------------------------------------------------------------------------
log "Building pixman $PIXMAN_TAG"
clone_or_update https://gitlab.freedesktop.org/pixman/pixman.git pixman "$PIXMAN_TAG"
meson_build pixman lib/x86_64-linux-gnu/pkgconfig/pixman-1.pc -Dtests=disabled -Ddemos=disabled

# ---------------------------------------------------------------------------
# 3c. libinput 1.27  (sway 1.11 needs >= 1.26.0; 24.04 ships 1.25.0). Built
# before wlroots so wlroots and sway both link the same /opt copy. libwacom is
# off (no tablet on this laptop) to avoid the extra dependency.
# ---------------------------------------------------------------------------
log "Building libinput $LIBINPUT_TAG"
clone_or_update https://gitlab.freedesktop.org/libinput/libinput.git libinput "$LIBINPUT_TAG"
meson_build libinput lib/x86_64-linux-gnu/pkgconfig/libinput.pc -Ddocumentation=false -Dtests=false -Dlibwacom=false -Ddebug-gui=false

# ---------------------------------------------------------------------------
# 4. wlroots 0.19  (adds ext-image-copy-capture-v1 + foreign-toplevel source)
# ---------------------------------------------------------------------------
log "Building wlroots $WLROOTS_TAG"
clone_or_update https://gitlab.freedesktop.org/wlroots/wlroots.git wlroots "$WLROOTS_TAG"
# xcb-errors is not packaged on 24.04; it is an auto feature, leave it to
# disable itself. Vulkan + GLES2 renderers and the DRM backend stay on.
meson_build wlroots lib/x86_64-linux-gnu/pkgconfig/wlroots-0.19.pc -Dexamples=false -Dxcb-errors=disabled

# ---------------------------------------------------------------------------
# 5. Sway 1.11  (the compositor half of the per-window capture support)
# ---------------------------------------------------------------------------
log "Building Sway $SWAY_TAG"
clone_or_update https://github.com/swaywm/sway.git sway "$SWAY_TAG"
meson_build sway bin/sway -Dwerror=false

# ---------------------------------------------------------------------------
# 6. xdg-desktop-portal-wlr 0.8.x  (the portal half: window picker + capture)
# ---------------------------------------------------------------------------
log "Building xdg-desktop-portal-wlr $XDPW_TAG"
clone_or_update https://github.com/emersion/xdg-desktop-portal-wlr.git xdph-wlr "$XDPW_TAG"
# xdpw 0.8.2 sets werror=true but wlr_screencast.c is missing #include <unistd.h>
# for close(), which gcc 13 rejects under -Werror. Turn werror off (close()
# returning int is correct on this platform) rather than patch upstream source.
meson_build xdph-wlr libexec/xdg-desktop-portal-wlr -Dsd-bus-provider=libsystemd -Dwerror=false

# Make the new backend self-contained for D-Bus activation: point its service
# file at the absolute binary and drop SystemdService= so dbus execs it directly
# (systemd would not search this non-standard prefix for the unit).
WLR_SERVICE="$PREFIX/share/dbus-1/services/org.freedesktop.impl.portal.desktop.wlr.service"
if [ -f "$WLR_SERVICE" ]; then
  log "Pinning $WLR_SERVICE to the /opt binary"
  {
    echo "[D-BUS Service]"
    echo "Name=org.freedesktop.impl.portal.desktop.wlr"
    echo "Exec=$PREFIX/libexec/xdg-desktop-portal-wlr"
  } > "$WLR_SERVICE"
fi

# ---------------------------------------------------------------------------
# 7. Runtime linking + session launcher + greeter entry
# ---------------------------------------------------------------------------
# No global ldconfig entry on purpose: the binaries carry an rpath to $LIBDIR
# (see LDFLAGS above), so the /opt stack is fully self-resolving and does not
# shadow system libraries for the old session or anything else.

log "Installing session launcher and greeter entry"
install -Dm755 "$SCRIPT_DIR/sway-next-session" "$PREFIX/bin/sway-next-session"
install -Dm644 "$SCRIPT_DIR/sway-next.desktop" /usr/share/wayland-sessions/sway-next.desktop

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
cat <<EOF

$(printf '\033[1;32m==> Build complete.\033[0m')

Installed (isolated, apt Sway 1.9 untouched):
  $PREFIX/bin/sway                         $("$PREFIX/bin/sway" --version 2>/dev/null || echo '?')
  $PREFIX/libexec/xdg-desktop-portal-wlr   (xdpw $XDPW_TAG)
  /usr/share/wayland-sessions/sway-next.desktop

NEXT:
  1. Log out of Sway.
  2. At the GDM login screen, click the gear / session menu and choose
     "Sway 1.11 (per-window screenshare)".
  3. Test: open Chromium, start "Share your screen" (e.g. in Meet or
     chrome://webrtc-internals test), and confirm the portal picker now offers
     a WINDOW tab listing individual windows, not just the whole output.

REVERT:
  Just pick the old "Sway" session at the GDM login screen. To remove the
  build entirely:  sudo bash scripts/sway-next-build.sh --uninstall
EOF
