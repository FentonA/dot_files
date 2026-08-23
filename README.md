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
config/sway/common    every sway session shares this; launches no apps
config/sway/profiles/ one *.config per login session (fonn)
layouts/              *.layout — which app opens on which workspace
scripts/sway-layout   applies a layout at sway startup
```

## Sway session profiles

The login screen offers more than one sway session. Each is a `.desktop` entry
in `/usr/share/wayland-sessions` pointing at `sway-profile-session <name>`,
which starts the usual Sway 1.11 stack with a profile-specific config:

```
config/sway/common              bindings, modes, colors, rules, daemons — no apps
config/sway/config              the plain "Sway" session: common + all apps
config/sway/profiles/fonn.config  "Sway(fonn)": common + a four-screen layout
```

Shared changes go in `common` and every session picks them up.

**Screens.** `Sway(fonn)` opens one app per workspace, defined in
`layouts/fonn.layout` — `<workspace> <command>`, one per line, `-` for an app
that should live in the scratchpad instead of owning a screen. Edit that file
and log out; no sway reload needed, nothing else to touch.

`scripts/sway-layout` switches to the workspace *before* launching each app and
waits for its window, rather than launching everything and matching windows
afterwards. Matching is unreliable here: Slack and Obsidian are XWayland (class,
no app_id), and ghostty silently refuses to start unless `--class` is a valid
reverse-DNS GTK application id.

Two gotchas found the hard way, both already handled:

* The **snap** Slack (`/snap/bin/slack`, what `slack` on PATH resolves to)
  starts a process but never maps a window. The layout uses
  `flatpak run com.slack.Slack`.
* TickTick is XWayland, so the old `for_window [app_id="Ticktick"]` scratchpad
  rule could never match and TickTick squatted on a workspace. `common` now
  matches on `class` as well.
* sway's PATH at login has no `~/.local/bin` — that comes from the shell
  profile, and nothing in a sway startup is a login shell. `zen` lives only
  there, so it alone failed to start. `sway-layout` prepends it, and now checks
  a command exists before launching, so a missing binary says so instead of
  silently burning the 30s window timeout.

**Zen Spaces.** Zen has no command-line flag for Spaces; the Space it opens on
is whatever `zen.workspaces.active` holds at startup (`ZenSpaceManager.mjs`:
`#activeWorkspace ||= getStringPref("zen.workspaces.active", "")`).
`scripts/zen-space` sets that pref and then execs zen:

```
2   zen-space CareerPlug
```

It resolves the name to a UUID out of `zen-sessions.jsonlz4`, so recreating the
Space in Zen doesn't break the layout. It writes `prefs.js` immediately before
launch rather than using `user.js`, because `user.js` is reapplied on every
launch from every session and would pin the browser to one Space permanently.
It refuses to touch prefs while Zen is running — a live Zen rewrites the whole
file on exit and would discard the change.

**Installing a session** needs root, since GDM only reads
`/usr/share/wayland-sessions`:

```sh
sudo bash scripts/install-sway-sessions.sh
```

Re-run it after editing `sway-profile-session` or any `scripts/sway-*.desktop` —
those are copied, not symlinked, because GDM runs as another user and won't
follow a link into `$HOME`.

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
