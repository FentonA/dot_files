
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/alffenton/miniconda3/bin/conda
    eval /Users/alffenton/miniconda3/bin/conda "shell.fish" hook $argv | source
end
# <<< conda initialize <<<

set -x PATH ~/.rbenv/bin $PATH
rbenv init - fish | source
source ~/.asdf/asdf.fish
set -x XKB_DEFAULT_OPTIONS ctrl:swapcaps
export PATH="$HOME/.local/bin:$PATH"
set -x XDG_DATA_DIRS ~/.local/share $XDG_DATA_DIRS

# Selenium feature specs: pin Chrome to the chrome-for-testing build so it
# matches the matching chromedriver wrapper at ~/.local/bin/chromedriver.
# Avoids snap-chromium version drift / sandboxing issues.
# Install via: bash ~/dot_files/scripts/chrome-for-testing.sh
if test -x $HOME/.local/chrome-for-testing/chrome-linux64/chrome
    set -x SELENIUM_CHROME_BINARY $HOME/.local/chrome-for-testing/chrome-linux64/chrome
end

alias anki="flatpak run --env=QT_QPA_PLATFORM=wayland net.ankiweb.Anki"
