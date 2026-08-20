#!/usr/bin/env python3
"""Guard: api-test-presence.

"Add a test for this" is the most common substantive ask in the upstream
repo's inline review history (24 comments). ortb-test-presence already
covers the ORTB models (the historical crash cluster); this guard extends
the same contract to the whole public surface: every public TYPE
(class/struct/enum/protocol/actor) in the API baseline's `swift` section
must be referenced by at least one test in PrebidMobileTests.

Input is the committed structured baseline (public-api.json) — the type
list can never disagree with the public-api-baseline guard. Same
deliberately-loose contract as ortb-test-presence: "referenced" means the
type name appears anywhere in test sources — it proves the type is
exercised at all, not that coverage is good (review owns quality). Same
safety property: an empty discovered scope FAILS instead of passing.

Ratchet: pre-existing gaps are grandfathered in
allowlists/api-test-presence.json (shrink-only; stale entries fail). That
list IS the untested-public-API backlog reviewers kept asking about.
"""

import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

BASELINE = os.path.join(ROOT, "scripts", "guards", "baselines", "public-api.json")
ALLOWLIST = os.path.join(ROOT, "scripts", "guards", "allowlists", "api-test-presence.json")
API_UPDATE_CMD = "./scripts/guards/run-guards.sh --update-api-baseline"
TESTS_ROOT = "PrebidMobileTests"
TYPE_KINDS = ("class", "struct", "enum", "protocol", "actor")


def public_types(sections):
    """Sorted public type names from the baseline's swift section (all
    scopes — nested public types need tests too)."""
    names = set()
    for kinds in sections.get("swift", {}).values():
        for kind in TYPE_KINDS:
            names.update(kinds.get(kind, {}))
    return sorted(names)


def untested(types, root=ROOT):
    contents = []
    for path in guardlib.walk_files(os.path.join(root, TESTS_ROOT), (".swift", ".m", ".h")):
        with open(path, encoding="utf-8", errors="replace") as fh:
            contents.append(fh.read())
    return sorted(t for t in types if not any(t in c for c in contents))


def main(_argv, root=ROOT):
    baseline_path = os.path.join(root, "scripts", "guards", "baselines", "public-api.json")
    types = public_types(guardlib.load_json(baseline_path, API_UPDATE_CMD))
    if not types:
        print("FAIL: the baseline lists no public types — the guard lost its target.")
        print("A probe checking an empty scope must not pass; fix the baseline first.")
        return 1

    allowlist_path = os.path.join(root, "scripts", "guards",
                                  "allowlists", "api-test-presence.json")
    allow = guardlib.read_allowlist(allowlist_path)
    new, stale = guardlib.ratchet(untested(types, root), allow)

    fail = False
    if new:
        print("FAIL: public type(s) with no test referencing them — public API ships with tests:")
        print("\n".join(new))
        fail = True
    if stale:
        print("FAIL: stale allowlist entries (now tested, or no longer public) — delete them")
        print("from scripts/guards/allowlists/api-test-presence.json in this PR:")
        print("\n".join(guardlib.describe_entries(allowlist_path, stale)))
        fail = True

    if not fail:
        print(f"OK: every public type is referenced by a test "
              f"({len(types)} types; allowlist: {len(allow)} grandfathered).")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(guardlib.cli(main)(sys.argv))
