#!/usr/bin/env python3
"""Push card-front.html / card-back.html / card-style.css into Anki over the
AnkiConnect API, so Anki stays open and the change lands immediately.

    python3 apply.py            # push once
    python3 apply.py --watch    # push on every save
    python3 apply.py --check    # report what Anki currently has

Anki must be RUNNING (the opposite of the old sqlite applier — AnkiConnect is
an add-on inside Anki). Flip to the next card to see the change.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ENDPOINT = "http://127.0.0.1:8765"

# Every notetype that gets the code-drill treatment, and which of its
# templates to overwrite.
MODELS = {
    "Basic": "Card 1",
    "Rust Code": "Card 1",
}

MEDIA = os.path.expanduser(
    "~/.var/app/net.ankiweb.Anki/data/Anki2/User 1/collection.media"
)
REQUIRED_MEDIA = ["_monaco-vim.umd.js", "_highlight.js"]

SOURCES = {
    "front": "card-front.html",
    "back": "card-back.html",
    "css": "card-style.css",
}


def invoke(action, **params):
    payload = json.dumps({"action": action, "version": 6, "params": params})
    req = urllib.request.Request(
        ENDPOINT, data=payload.encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            body = json.load(r)
    except urllib.error.URLError as e:
        sys.exit(
            f"cannot reach AnkiConnect at {ENDPOINT} ({e.reason}).\n"
            "Start Anki — AnkiConnect is an add-on and only serves while Anki is open."
        )
    if body.get("error"):
        sys.exit(f"AnkiConnect error on {action}: {body['error']}")
    return body["result"]


def read_sources():
    out = {}
    for key, name in SOURCES.items():
        path = os.path.join(HERE, name)
        if not os.path.exists(path):
            sys.exit(f"missing source file: {path}")
        out[key] = open(path, encoding="utf-8").read()
    return out


def check_media():
    missing = [f for f in REQUIRED_MEDIA if not os.path.exists(os.path.join(MEDIA, f))]
    if missing:
        print(f"  warning: not in collection.media: {', '.join(missing)}")


def push(src, quiet=False):
    known = set(invoke("modelNames"))
    for model, template in MODELS.items():
        if model not in known:
            print(f"  skip {model!r}: no such notetype")
            continue
        invoke("updateModelTemplates", model={
            "name": model,
            "templates": {template: {"Front": src["front"], "Back": src["back"]}},
        })
        invoke("updateModelStyling", model={"name": model, "css": src["css"]})
        if not quiet:
            print(f"  pushed {model!r} / {template!r}")


def verify(src):
    ok = True
    for model, template in MODELS.items():
        got = invoke("modelTemplates", modelName=model).get(template, {})
        css = invoke("modelStyling", modelName=model)["css"]
        for label, want, have in (
            ("front", src["front"], got.get("Front", "")),
            ("back", src["back"], got.get("Back", "")),
            ("css", src["css"], css),
        ):
            if want.strip() != have.strip():
                print(f"  MISMATCH {model} {label}: {len(have)} bytes in Anki, "
                      f"{len(want)} on disk")
                ok = False
    return ok


def stamps():
    return {
        n: os.path.getmtime(os.path.join(HERE, n))
        for n in SOURCES.values()
        if os.path.exists(os.path.join(HERE, n))
    }


def main():
    args = sys.argv[1:]

    if "--check" in args:
        for model, template in MODELS.items():
            got = invoke("modelTemplates", modelName=model).get(template, {})
            css = invoke("modelStyling", modelName=model)["css"]
            print(f"{model} / {template}: front={len(got.get('Front',''))} "
                  f"back={len(got.get('Back',''))} css={len(css)} bytes")
        print("\nmatches disk" if verify(read_sources()) else "\ndiffers from disk")
        return

    check_media()
    src = read_sources()
    push(src)
    print("verified" if verify(src) else "verification FAILED")

    if "--watch" not in args:
        return

    print("\nwatching for changes — ctrl-c to stop")
    last = stamps()
    while True:
        time.sleep(1)
        now = stamps()
        if now == last:
            continue
        last = now
        try:
            src = read_sources()
            push(src, quiet=True)
            print(f"[{time.strftime('%H:%M:%S')}] pushed "
                  + ("ok" if verify(src) else "BUT VERIFY FAILED"))
        except SystemExit as e:
            print(f"[{time.strftime('%H:%M:%S')}] {e}")


if __name__ == "__main__":
    main()
