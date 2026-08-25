# Anki code-drill card templates

Front is a Monaco editor with vim mode; the back shows a git-style unified diff
of what you typed against the note's `Back` field. Shared by the `Basic` and
`Rust Code` notetypes (both on their `Card 1` template).

These files are the **source**. The copies Anki actually renders live inside
`collection.anki2`, and `apply.py` is what pushes source → collection.

## Python or Rust

The editor picks a language per card, shown in the badge at the right of the vim
status bar (`rust · deck`, `python · typed`, …). First rule that hits wins:

| # | Source | Rule |
|---|--------|------|
| 1 | tag | `rust`, `rs`, `python`, `py` — anywhere in a hierarchical tag, so `rust::low-latency::allocation` counts |
| 2 | note type | name contains `rust` / `python` (`Rust Code`) |
| 3 | deck | `DECK_RULES` at the top of `card-front.html` |
| 4 | question | scored keyword sniff of the question text |
| 5 | default | python |

1–3 **lock** the card: typing Python into a `Rust::` card won't switch it. 4–5
leave it open, so the sniff re-runs ~350 ms after you stop typing and can flip
the buffer's language mid-answer (`python · typed`).

Override anytime — the override locks:

- `Alt+L` (or click the badge) toggles
- `:lang rust` / `:lang py`, or bare `:rust` / `:python` in vim mode

`DECK_RULES` is the "just assign a language to a deck" knob — a list of
`[regex, lang]` matched against the full `::` deck path, most specific first.
Decks left out of it (System Designs, Swish Prep::Estimation/Stats) auto-detect
instead of being pinned.

The back side reuses the decision for the diff filename (`your-answer.rs`) and
for highlight.js. On *unlocked* cards only, the reference answer gets the last
word — locked cards ignore it, because prose answers comparing the two languages
("tokio vs asyncio") sniff the wrong way.

## Writing code in the Back field

Anki's editor has no code-block button, so the template understands **markdown
fences**. In the field, type or paste:

    ```rust
    fn main() {
        println!("hi");
    }
    ```

`rust` / `rs` / `python` / `py` are recognised; a bare ``` uses the card's
language. At review time the fence becomes a real `<pre><code>` block:
highlighted, diffed on its own (prose outside the fence is shown but not
diffed), and the tag overrides every other language rule for that card.

Paste normally — Ctrl+V. Anki escapes `<`, `>`, `&` and stores indentation as
`&nbsp;`, and the fence body is read back as *text*, so `Vec<usize>` and leading
whitespace survive without hand-escaping. Nothing else changes: fence-less notes
render exactly as before, and the older Pygments-table answers still diff fine.

Escape hatch for full control: **Ctrl+Shift+X** opens the field's HTML editor,
where you can write `<pre><code class="language-rust">…</code></pre>` by hand
(entities must be escaped yourself there).

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
