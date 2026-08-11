# Anki code-drill card templates

Front is a Monaco editor with vim mode; the back shows a git-style unified diff
of what you typed against the note's `Back` field. Shared by the `Basic` and
`Rust Code` notetypes (both on their `Card 1` template).

These files are the **source**. The copies Anki actually renders live inside
`collection.anki2`, and `apply.py` is what pushes source → collection.

## Applying changes

**Anki must be RUNNING.** `apply.py` talks to the AnkiConnect add-on, which is
an HTTP server *inside* Anki at `127.0.0.1:8765`.

```sh
python3 ~/anki-templates/apply.py           # push once, then verify
python3 ~/anki-templates/apply.py --watch   # re-push on every save
python3 ~/anki-templates/apply.py --check   # compare live vs disk, change nothing
```

Flip to the next card to see the change — Anki caches the rendered card.

`original/` is the pre-customization backup of both notetypes, kept for reference.

## Setting this up on a new machine

1. Install Anki (flatpak `net.ankiweb.Anki`) and sync down the collection —
   AnkiWeb carries the notes, decks, notetypes, and `collection.media`.
2. **Install the AnkiConnect add-on: code `2055492159`** (Tools → Add-ons → Get
   Add-ons). Add-ons do *not* sync via AnkiWeb, so this is always a manual step.
   Restart Anki. Defaults bind `127.0.0.1:8765`, which is what `apply.py` wants.
3. `bash bootstrap.sh` (or just `scripts/symlinks.sh`) to link `~/anki-templates`
   here.
4. `python3 ~/anki-templates/apply.py --check` — should report "matches disk".

The two vendored JS files the templates load, `_highlight.js` and
`_monaco-vim.umd.js`, live in `collection.media/`. The leading `_` is load-bearing:
it tells Anki's "check media" not to delete files no note references. They ride
along with media sync, so step 1 restores them; `apply.py` warns if they're absent.

## What is deliberately not in this repo

- `collection.anki2` — binary, rewritten every review session, and AnkiWeb
  already backs it up. Local snapshots are in `Anki2/User 1/backups/`.
- `prefs21.db` — window geometry plus your AnkiWeb **sync key**. Never commit it.
