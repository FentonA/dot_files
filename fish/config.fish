
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
alias anki="flatpak run --env=QT_QPA_PLATFORM=wayland net.ankiweb.Anki"
