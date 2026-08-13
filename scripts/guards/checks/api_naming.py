#!/usr/bin/env python3
"""Guard: api-naming.

Naming asks are the single most frequent review theme in the upstream PR
history (26 inline comments). Most are judgment calls no guard should make;
this check enforces only the crisp, codified rule
(.claude/rules/code-patterns.md): the `PBM` prefix belongs on the
Objective-C side only — Swift types exposed to ObjC use `@objc(PBMName)`
renames, and the *Swift-visible* public name stays unprefixed. A
PBM-prefixed name in the public Swift surface is a migration leftover.

Input is the committed API baseline (scripts/guards/baselines/public-api.json)
— the structured model, not source re-parsing — so this guard can never
disagree with public-api-baseline about what the surface is. It checks the
`swift` section only (`swift-spi` is internal; PBM there is expected).

Permanent, documented exception (not allowlist debt): `PBMMediation*`
constants are deliberately public — they are the mediation adapters'
wire-contract keys, and renaming them would break publishers (see the
known-trap note in CLAUDE.md).

Ratchet: existing leftovers are grandfathered in
allowlists/api-naming.json (shrink-only; stale entries fail). Fixing one
means renaming the Swift symbol and deprecating the old name per the
deprecation-hygiene guard.
"""

import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

BASELINE = os.path.join(ROOT, "scripts", "guards", "baselines", "public-api.json")
ALLOWLIST = os.path.join(ROOT, "scripts", "guards", "allowlists", "api-naming.json")
EXEMPT_PREFIX = "PBMMediation"  # deliberate publisher contract — see CLAUDE.md
API_UPDATE_CMD = "./scripts/guards/run-guards.sh --update-api-baseline"


def _is_pbm(name):
    return name.startswith("PBM") and not name.startswith(EXEMPT_PREFIX)


def violations(sections):
    """Sorted violation tokens from a baseline's swift section:
    '<kind> <name>' for declarations, 'parent <path>' for scope keys that
    only exist via extensions of ObjC-named types."""
    swift = sections.get("swift", {})
    out = set()
    for parent, kinds in swift.items():
        for kind, names in kinds.items():
            out.update(f"{kind} {name}" for name in names if _is_pbm(name))
        head = parent.split(".", 1)[0]
        if _is_pbm(head):
            out.add(f"parent {head}")
    # a parent that is itself a flagged declaration is already reported once
    declared = {tok.split(" ", 1)[1] for tok in out if not tok.startswith("parent ")}
    return sorted(tok for tok in out
                  if not (tok.startswith("parent ") and tok.split(" ", 1)[1] in declared))


def main(_argv):
    sections = guardlib.load_json(BASELINE, API_UPDATE_CMD)
    allow = guardlib.read_allowlist(ALLOWLIST)
    new, stale = guardlib.ratchet(violations(sections), allow)

    fail = False
    if new:
        print("FAIL: PBM-prefixed name in the public Swift surface — the PBM prefix belongs")
        print("on the ObjC side only (@objc(PBMName) rename); name the Swift symbol without it:")
        print("\n".join(new))
        fail = True
    if stale:
        print("FAIL: stale allowlist entries (symbol renamed or gone) — delete them from")
        print("scripts/guards/allowlists/api-naming.json in this PR (the list only shrinks):")
        print("\n".join(guardlib.describe_entries(ALLOWLIST, stale)))
        fail = True

    if not fail:
        print(f"OK: no new PBM-prefixed public Swift names (allowlist: {len(allow)} grandfathered).")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(guardlib.cli(main)(sys.argv))
