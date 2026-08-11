# dot_files

Config for fish, tmux/tmuxinator, neovim, ghostty, sway/waybar/wofi/dunst, and
the Anki card templates.

Targets **Pop/Ubuntu (apt)**, **Arch (pacman)**, and **macOS (brew)**.

## Install

```sh
git clone git@github.com:FentonA/dot_files.git ~/dot_files
bash ~/dot_files/bootstrap.sh
```

Re-running is safe — every step is idempotent. To relink configs without
touching packages:

```sh
bash ~/dot_files/scripts/symlinks.sh
```

## What runs where

| | apt | pacman | brew |
|---|---|---|---|
| CLI packages, GUI apps, gh, kubectl, rust, asdf | ✅ | ✅ | ✅ |
| Symlinks | ✅ | ✅ | ✅ (skips sway/waybar/wofi/dunst) |
| keyboard.sh, autostart.sh, systemd, swapfile, sysctl | ✅ | ✅ | ⏭️ skipped |

On macOS, remap Caps Lock by hand in **System Settings → Keyboard → Modifier
Keys**, and set autostart via **Login Items**. There's no xkb and no systemd to
script against.

## Conventions

**Symlinks are idempotent.** `scripts/symlinks.sh` uses `ln -sfn`, never
`ln -sf`, for anything that resolves to a directory. Without `-n`, `ln` follows
an existing symlink-to-directory and creates the new link *inside* it — that's
how `nvim/nvim -> ~/dot_files/nvim`, a self-referential loop, ended up committed
to this repo for four months. Anything real already at a destination is moved to
`<name>.pre-dotfiles.bak` rather than overwritten.

**Nothing writes into the repo at runtime.** The configs under `~/.config` are
symlinks back here, so any script that appends to one is editing your working
tree. `bootstrap.sh` used to `echo 'set -x PATH ~/.cargo/bin' >> config.fish` on
every run; cargo's PATH now lives in `fish/config.fish` directly. Watch for this
in `scripts/keyboard.sh`, which appends `XKB_DEFAULT_OPTIONS` unless it's
already present — it's inert today only because `config.fish` sets it.

**Job- and machine-specific shell config is untracked.** `fish/config.fish`
sources `~/.config/fish/*.local.fish` at the end:

```sh
~/.config/fish/swish.local.fish       # employer env vars, aliases, kafka brokers
~/.config/fish/careerplug.local.fish
```

The glob matches nothing on a machine without them, which is the point:
`config.fish` used to `source careerplug.fish` unconditionally, so every shell
on a machine lacking that file opened with an error.

**Everything in `fish/config.fish` is guarded.** rbenv, asdf, conda, homebrew,
and the Linux desktop vars are each behind an existence check. A missing tool
degrades to a no-op instead of erroring on shell start. Keep it that way — this
file runs on every shell, on three OSes.

## Layout

```
bootstrap.sh          master installer; forks on apt/pacman/brew
scripts/symlinks.sh   all symlinks, idempotent, OS-guarded
scripts/*.sh          keyboard, aws, autostart, gh-notify, chrome-for-testing
fish/config.fish      shell config (guarded, portable)
fish/functions/       linked individually so `funcsave` doesn't dirty the repo
nvim/                 LazyVim config
tmuxinator/           per-project tmux sessions — clickk, career-plug, swish
anki-templates/       Anki code-drill card templates (see its own README)
config/               sway, waybar, wofi (linux only)
```

## Not tracked here, on purpose

- `tfenv/versions/` — tfenv installs these. A linux_amd64 `terraform` binary
  (84M) used to be committed; it was dead weight in every clone and wouldn't
  execute on Apple Silicon. Note it's still in git *history*, so clones still
  pay for it until someone rewrites history.
- `~/.claude/settings.local.json` — Claude Code rewrites it whenever you grant a
  permission, so linking it into the repo would mean a dirty working tree
  constantly. The stale copy under `.claude/` is kept only for reference.
- `~/.aws/credentials` — `scripts/aws.sh` writes the profile *structure* with
  `REPLACE_ME` placeholders. Keys never live here.
