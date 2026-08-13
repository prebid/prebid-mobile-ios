#!/usr/bin/env python3
"""Guard: deprecation-hygiene.

Deprecating API without telling the publisher what to use instead is a
recurring review ask (11 inline review comments in the upstream PR history,
e.g. "We should not only deprecate the hardcoded values but also provide a
new interface"). This guard makes it mechanical: every `@available`
attribute that marks a declaration `deprecated` in publisher-facing Swift
sources must carry a non-empty `message:` (or a `renamed:`) naming the
replacement.

Deliberately NOT flagged: bare `unavailable` — its dominant use is the
idiomatic private-init blocker (`@available(*, unavailable) private
override init()`), which has no replacement to name; flagging it would be
the false-positive class this repo's guard philosophy forbids. Removing
public API is the api-baseline guard's territory anyway.

Scope: PrebidMobile/Swift/ and non-test EventHandlers/ sources — the
surfaces publishers compile against. The current tree is fully compliant,
so the allowlist starts empty and the guard purely polices the future.
Rare, justified exceptions are grandfathered per file in
allowlists/deprecation-hygiene.txt (shrink-only; stale entries fail).
"""

import os
import re
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

ALLOWLIST = os.path.join(ROOT, "scripts", "guards", "allowlists", "deprecation-hygiene.txt")
SCOPES = (os.path.join("PrebidMobile", "Swift"), "EventHandlers")

_ATTR_START_RE = re.compile(r"@available\s*\(")
_DEPRECATION_RE = re.compile(r"\bdeprecated\b")
_REPLACEMENT_RE = re.compile(r'\b(message|renamed)\s*:\s*"[^"]')
_COMMENT_RE = re.compile(r"^\s*(//|\*|/\*)")


def _attributes(lines):
    """(lineno, joined_text) for each @available(...) attribute, joining
    wrapped attributes until their parens balance."""
    out = []
    buf, start, depth = "", 0, 0
    for lineno, raw in enumerate(lines, 1):
        line = raw.rstrip("\n")
        if not buf:
            if _COMMENT_RE.match(line):
                continue
            m = _ATTR_START_RE.search(line)
            if not m:
                continue
            buf, start = line[m.start():], lineno
            depth = buf.count("(") - buf.count(")")
        else:
            buf += " " + line.strip()
            depth += line.count("(") - line.count(")")
        if depth <= 0:
            out.append((start, buf))
            buf = ""
    return out


def file_violations(lines):
    """(lineno, attribute_text) for deprecation attributes lacking a
    replacement hint, in one file's lines."""
    return [
        (lineno, " ".join(attr.split()))
        for lineno, attr in _attributes(lines)
        if _DEPRECATION_RE.search(attr) and not _REPLACEMENT_RE.search(attr)
    ]


def violations(root=ROOT):
    """{relative file path: [(lineno, attribute), …]} across the scopes."""
    out = {}
    for scope in SCOPES:
        for path in guardlib.walk_files(os.path.join(root, scope), (".swift",)):
            rel = os.path.relpath(path, root)
            if "Tests" in rel:
                continue
            with open(path, encoding="utf-8", errors="replace") as fh:
                hits = file_violations(fh.readlines())
            if hits:
                out[rel] = hits
    return out


def main(_argv):
    found = violations()
    allow = guardlib.read_list(ALLOWLIST)
    new, stale = guardlib.ratchet(found.keys(), allow)

    fail = False
    if new:
        print("FAIL: deprecation without a replacement hint — every deprecated/unavailable")
        print('marker must tell the publisher what to use instead (message: "Use X…" or renamed:):')
        for f in new:
            for lineno, attr in found[f][:5]:
                print(f"{f}:{lineno}:{attr[:120]}")
        fail = True
    if stale:
        print("FAIL: stale allowlist entries (file clean or gone) — delete them from")
        print("scripts/guards/allowlists/deprecation-hygiene.txt in this PR:")
        print("\n".join(stale))
        fail = True

    if not fail:
        print(f"OK: every deprecation names its replacement (allowlist: {len(allow)} grandfathered).")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
