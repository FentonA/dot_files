#!/usr/bin/env bash
# scripts/chrome-for-testing.sh
# Installs Google's Chrome-for-Testing + matching ChromeDriver into ~/.local
# and creates a `chromedriver` wrapper on PATH.
#
# Used for Selenium feature specs that need a non-snap-confined Chrome.
# Re-runnable: skips download if the binaries already exist.

set -e

CFT_DIR="$HOME/.local/chrome-for-testing"
WRAPPER="$HOME/.local/bin/chromedriver"
CHROME_SHIM="$HOME/.local/bin/google-chrome"
CHROME_BIN="$CFT_DIR/chrome-linux64/chrome"
DRIVER_BIN="$CFT_DIR/chromedriver-linux64/chromedriver"

mkdir -p "$CFT_DIR" "$HOME/.local/bin"

if [ -x "$CHROME_BIN" ] && [ -x "$DRIVER_BIN" ]; then
  echo "===> Chrome-for-Testing already installed at $CFT_DIR"
else
  echo "===> Resolving latest Chrome-for-Testing stable version..."
  META_JSON="$(curl -fsSL https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json)"
  VERSION="$(echo "$META_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['channels']['Stable']['version'])")"
  CHROME_URL="$(echo "$META_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin)['channels']['Stable']['downloads']['chrome']; print([x for x in d if x['platform']=='linux64'][0]['url'])")"
  DRIVER_URL="$(echo "$META_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin)['channels']['Stable']['downloads']['chromedriver']; print([x for x in d if x['platform']=='linux64'][0]['url'])")"

  echo "===> Installing Chrome-for-Testing $VERSION to $CFT_DIR"
  cd "$CFT_DIR"
  curl -fsSL -o chrome.zip "$CHROME_URL"
  curl -fsSL -o driver.zip "$DRIVER_URL"
  unzip -q -o chrome.zip
  unzip -q -o driver.zip
  rm -f chrome.zip driver.zip
fi

cat > "$WRAPPER" <<EOF
#!/bin/bash
exec "$DRIVER_BIN" "\$@"
EOF
chmod +x "$WRAPPER"

# Selenium auto-detects Chrome via `google-chrome` on PATH. Symlink ours there
# so the detected Chrome matches the chromedriver above (no version-mismatch
# warnings, no need to set SELENIUM_CHROME_BINARY).
ln -sf "$CHROME_BIN" "$CHROME_SHIM"

echo "===> chromedriver wrapper at $WRAPPER"
"$WRAPPER" --version
echo "===> google-chrome shim at $CHROME_SHIM -> $CHROME_BIN"
"$CHROME_SHIM" --version
