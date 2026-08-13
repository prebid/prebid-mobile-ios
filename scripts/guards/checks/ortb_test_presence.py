#!/usr/bin/env python3
"""Guard: ortb-test-presence.

Every ORTB model file must be referenced by at least one test in
PrebidMobileTests. A year of upstream issues shows the failure mode is
concentrated on untested decode paths: #1300/#1255 (SKAdNetwork fields
decoded with spec-violating types), #1259 (decimal conversion).

Models are DISCOVERED by file name, not by hardcoded paths: every
`ORTB*.swift` under PrebidMobile/ is in scope, wherever it lives — the
naming convention (ORTBFoo ↔ @objc(PBMORTBFoo)) is far more stable than the
directory layout, which the Swift migration keeps reshaping. Moving or
adding a model can never silently drop it from checking. If discovery finds
no model at all, the guard FAILS rather than passing on an empty scope — a
probe that lost its target must never read as clean.

"Referenced" = the model file's type/base name appears anywhere in
PrebidMobileTests sources. Deliberately loose: it proves the type is
exercised at all, not that coverage is good — the spec-grounding gate and
review handle quality.

Ratchet: pre-existing gaps are grandfathered in
allowlists/ortb-test-presence.txt (one path per line, shrink-only). Stale
entries fail the run and must be deleted in the same PR.
"""

import os
import re
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

ALLOWLIST = os.path.join(ROOT, "scripts", "guards", "allowlists", "ortb-test-presence.txt")
SOURCE_ROOT = "PrebidMobile"
TESTS_ROOT = "PrebidMobileTests"
_MODEL_FILE_RE = re.compile(r"^ORTB\w*\.swift$")


def model_files(root=ROOT):
    """Every ORTB*.swift under the source root, wherever it lives."""
    return sorted(
        path
        for path in guardlib.walk_files(os.path.join(root, SOURCE_ROOT), (".swift",))
        if _MODEL_FILE_RE.match(os.path.basename(path))
    )


def violations(models, root=ROOT):
    test_contents = []
    for path in guardlib.walk_files(os.path.join(root, TESTS_ROOT), (".swift", ".m")):
        with open(path, encoding="utf-8", errors="replace") as fh:
            test_contents.append(fh.read())

    missing = []
    for path in models:
        base = os.path.splitext(os.path.basename(path))[0]
        if not any(base in content for content in test_contents):
            missing.append(os.path.relpath(path, root))
    return sorted(missing)


def main(_argv, root=ROOT):
    models = model_files(root)
    if not models:
        print(f"FAIL: discovered no ORTB*.swift models under {SOURCE_ROOT}/ — the guard lost")
        print("its target (models renamed away from the ORTB prefix?). Fix the discovery in")
        print("scripts/guards/checks/ortb_test_presence.py; a guard checking an empty scope")
        print("must not pass.")
        return 1

    allow = guardlib.read_list(ALLOWLIST)
    new, stale = guardlib.ratchet(violations(models, root), allow)

    fail = False
    if new:
        print("FAIL: ORTB model file(s) with no test referencing them:")
        print("\n".join(new))
        print("Add a wire-format/decoding test in PrebidMobileTests that exercises the type")
        print("(cite the OpenRTB spec section in the docstring — see the spec-grounding gate).")
        fail = True
    if stale:
        print("FAIL: stale allowlist entries (now tested, or the file is gone) — delete them")
        print("from scripts/guards/allowlists/ortb-test-presence.txt in this PR:")
        print("\n".join(stale))
        fail = True

    if not fail:
        print(f"OK: every ORTB model is referenced by a test "
              f"({len(models)} discovered models; allowlist: {len(allow)} grandfathered).")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
