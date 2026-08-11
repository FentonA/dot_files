# fish/config.fish — symlinked to ~/.config/fish/config.fish
#
# Runs on Pop/Ubuntu, Arch, and macOS. Every block is guarded: a tool that isn't
# installed degrades to a no-op instead of printing an error on every shell
# start. Nothing here may assume a specific $HOME, distro, or CPU arch.

# ── PATH ──────────────────────────────────────────────────────────────────────
# fish_add_path is idempotent, so re-sourcing this file won't stack duplicates.
fish_add_path -p $HOME/.local/bin
fish_add_path -p $HOME/.cargo/bin

# ── homebrew (macOS) ──────────────────────────────────────────────────────────
# /opt/homebrew on Apple Silicon, /usr/local on Intel. brew shellenv is what
# puts brew-installed binaries on PATH, so it has to run before anything below
# goes looking for them.
for brew_prefix in /opt/homebrew /usr/local
    if test -x $brew_prefix/bin/brew
        eval ($brew_prefix/bin/brew shellenv)
        break
    end
end

# ── version managers ──────────────────────────────────────────────────────────
if test -d $HOME/.rbenv
    fish_add_path -p $HOME/.rbenv/bin
    rbenv init - fish | source
end

# asdf <= 0.15 ships asdf.fish; 0.16+ is a Go binary with no shell script and
# wants its shims on PATH instead. bootstrap pins 0.14.0, but handle both so a
# machine that upgraded asdf independently still gets working shims.
if test -f $HOME/.asdf/asdf.fish
    source $HOME/.asdf/asdf.fish
else if test -d $HOME/.asdf/shims
    fish_add_path -p $HOME/.asdf/shims
end

# ── conda ─────────────────────────────────────────────────────────────────────
for conda_root in $HOME/miniconda3 $HOME/anaconda3 /opt/homebrew/Caskroom/miniconda/base
    if test -f $conda_root/bin/conda
        eval $conda_root/bin/conda "shell.fish" hook $argv | source
        break
    end
end

# ── linux desktop ─────────────────────────────────────────────────────────────
if test (uname) = Linux
    set -x XKB_DEFAULT_OPTIONS ctrl:swapcaps
    set -x XDG_DATA_DIRS $HOME/.local/share $XDG_DATA_DIRS

    # Selenium feature specs: pin Chrome to the chrome-for-testing build so it
    # matches the chromedriver wrapper at ~/.local/bin/chromedriver. Avoids snap
    # chromium version drift / sandboxing issues.
    # Install via: bash ~/dot_files/scripts/chrome-for-testing.sh
    if test -x $HOME/.local/chrome-for-testing/chrome-linux64/chrome
        set -x SELENIUM_CHROME_BINARY $HOME/.local/chrome-for-testing/chrome-linux64/chrome
    end

    if type -q flatpak
        alias anki="flatpak run --env=QT_QPA_PLATFORM=wayland net.ankiweb.Anki"
    end
end

# ── machine- and job-local config (untracked) ─────────────────────────────────
# Anything employer-specific or secret-adjacent lives in ~/.config/fish/*.local.fish
# and stays out of this repo — swish.local.fish, careerplug.local.fish, etc.
# The glob quietly matches nothing on a machine that has none, which is the
# point: config.fish used to `source careerplug.fish` unconditionally and errored
# on every shell start once that file was gone.
for local_config in $HOME/.config/fish/*.local.fish
    test -f $local_config; and source $local_config
end
