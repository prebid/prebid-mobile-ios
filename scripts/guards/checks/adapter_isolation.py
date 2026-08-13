#!/usr/bin/env python3
"""Guard G1: adapter-isolation.

Adapters and event handlers (EventHandlers/**) must only use the public
PrebidMobile API. Specifically, non-test adapter sources must not:
  1. import __PrebidMobileInternal (the internal ObjC SPM target)
  2. use @_spi imports (SPI is the SDK's internal seam)
  3. include anything from PrebidMobile/Objc/PrivateHeaders
  4. reference PBM-prefixed symbols that are not part of the public API

Rule 4 works against a vocabulary computed from the SDK itself: PBM*
identifiers that appear on public/open declaration lines in the core, plus
@objc(PBM...) renames of public Swift types, plus PBM* types the adapters
define themselves. Anything outside that vocabulary is an internal symbol.

Ratchet: grandfathered violations live in allowlists/adapter-isolation.txt
as "path:symbol" lines. The list may only shrink — stale entries fail the
run and must be deleted in the same PR that fixes them.
"""

import os
import re
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

ALLOWLIST = os.path.join(ROOT, "scripts", "guards", "allowlists", "adapter-isolation.txt")

_SEAM_RE = re.compile(r"import __PrebidMobileInternal|@_spi\(|PrivateHeaders/")
_PBM_RE = re.compile(r"\bPBM[A-Za-z0-9_]+")
_OBJC_RENAME_RE = re.compile(r"@objc\((PBM[A-Za-z0-9_]+)\)")
_PUBLIC_LINE_RE = re.compile(r"\b(public|open)\b")
_DECL_LINE_RE = re.compile(r"\b(class|protocol|enum|struct|typealias|let|var|func) +PBM[A-Za-z0-9_]+")
_COMMENT_RE = re.compile(r"^\s*(//|\*)")


def adapter_sources(root=ROOT):
    hits = []
    for path in guardlib.walk_files(os.path.join(root, "EventHandlers"), (".swift", ".h", ".m")):
        rel = os.path.relpath(path, root)
        if "Tests" in rel or any(part.startswith(".") for part in rel.split(os.sep)):
            continue
        hits.append(rel)
    return sorted(hits)


def _lines(root, rel):
    with open(os.path.join(root, rel), encoding="utf-8", errors="replace") as fh:
        return fh.readlines()


def seam_hits(root=ROOT, sources=None):
    """'path:lineno:line' for rules 1-3 (never allowlisted). Comment lines
    are skipped — a doc comment MENTIONING @_spi is not a seam."""
    out = []
    for rel in sources if sources is not None else adapter_sources(root):
        for lineno, line in enumerate(_lines(root, rel), 1):
            if _SEAM_RE.search(line) and not _COMMENT_RE.match(line):
                out.append(f"{rel}:{lineno}:{line.rstrip()}")
    return out


def public_vocabulary(root=ROOT):
    """PBM identifiers that are legitimately visible to adapters."""
    vocab = set()
    for path in guardlib.walk_files(os.path.join(root, "PrebidMobile"), (".swift",)):
        with open(path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                if _PUBLIC_LINE_RE.search(line) and not line.lstrip().startswith("//"):
                    vocab.update(_PBM_RE.findall(line))
                vocab.update(_OBJC_RENAME_RE.findall(line))
    for rel in adapter_sources(root):
        if not rel.endswith(".swift"):
            continue
        for line in _lines(root, rel):
            if _DECL_LINE_RE.search(line):
                vocab.update(_PBM_RE.findall(line))
    return vocab


def symbol_violations(root=ROOT):
    """'path:symbol' for PBM references outside the public vocabulary."""
    vocab = public_vocabulary(root)
    out = []
    for rel in adapter_sources(root):
        if not rel.endswith(".swift"):
            continue
        symbols = set()
        for line in _lines(root, rel):
            if _COMMENT_RE.match(line):  # PBM names in doc comments don't count
                continue
            symbols.update(_PBM_RE.findall(line))
        out.extend(f"{rel}:{sym}" for sym in sorted(symbols - vocab))
    return sorted(out)


def main(_argv):
    fail = False

    seams = seam_hits()
    if seams:
        print("FAIL: adapter code reaches into SDK internals (never allowed):")
        print("\n".join(seams))
        fail = True

    new, stale = guardlib.ratchet(symbol_violations(), guardlib.read_list(ALLOWLIST))
    if new:
        print("FAIL: new internal PBM symbol usage in adapters (fix, or discuss with maintainers):")
        print("\n".join(new))
        fail = True
    if stale:
        print("FAIL: stale allowlist entries — the violation is gone; delete these lines from")
        print("      scripts/guards/allowlists/adapter-isolation.txt (the list only shrinks):")
        print("\n".join(stale))
        fail = True

    if not fail:
        print("OK: adapters use only the public PrebidMobile API.")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
