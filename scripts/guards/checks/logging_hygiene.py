#!/usr/bin/env python3
"""Guard: logging-hygiene.

Publishers see the SDK's console output inside THEIR apps — raw print()/
debugPrint()/NSLog() bypasses the Log facade's levels and custom-logger
routing (PrebidLogger), so it can't be silenced or redirected. Upstream
issues #1295 (stray console output) and #1279 (misleading console warning)
are the motivating class. Use Log.error/warn/info/debug/verbose instead.

Structurally exempt: PrebidMobile/Swift/Logging/ — the console logger is
the one sanctioned place that ultimately calls print().

Ratchet: pre-existing violations are grandfathered per file in
allowlists/logging-hygiene.txt (shrink-only; stale entries fail).
"""

import os
import re
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

ALLOWLIST = os.path.join(ROOT, "scripts", "guards", "allowlists", "logging-hygiene.txt")
EXEMPT_DIR = os.path.join("PrebidMobile", "Swift", "Logging")
_CALL_RE = re.compile(r"(^|[^A-Za-z_.])(print|debugPrint|NSLog)\(")
_COMMENT_RE = re.compile(r"^\s*(//|\*|/\*)")


def _match_lines(path):
    """(lineno, text) for non-comment raw console calls in one file."""
    hits = []
    with open(path, encoding="utf-8", errors="replace") as fh:
        for lineno, line in enumerate(fh, 1):
            if _CALL_RE.search(line) and not _COMMENT_RE.match(line):
                hits.append((lineno, line.rstrip("\n")))
    return hits


def violations(root=ROOT):
    """{relative file path: [(lineno, line), …]} for violating files."""
    out = {}
    for path in guardlib.walk_files(os.path.join(root, "PrebidMobile"),
                                    (".swift", ".m", ".mm"),
                                    exclude_dir_parts=(EXEMPT_DIR,)):
        hits = _match_lines(path)
        if hits:
            out[os.path.relpath(path, root)] = hits
    return out


def main(_argv):
    found = violations()
    allow = guardlib.read_list(ALLOWLIST)
    new, stale = guardlib.ratchet(found.keys(), allow)

    fail = False
    if new:
        print("FAIL: raw print()/NSLog() in production code — route through the Log facade")
        print("(Log.error/warn/info/debug/verbose), which respects levels and custom loggers:")
        for f in new:
            for lineno, line in found[f][:5]:
                print(f"{f}:{lineno}:{line}")
        fail = True
    if stale:
        print("FAIL: stale allowlist entries (file clean or gone) — delete them from")
        print("scripts/guards/allowlists/logging-hygiene.txt in this PR:")
        print("\n".join(stale))
        fail = True

    if not fail:
        print(f"OK: no raw console output outside the Log facade (allowlist: {len(allow)} grandfathered file(s)).")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
