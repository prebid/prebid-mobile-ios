#!/usr/bin/env python3
"""Guard: skiplist-ratchet.

PrebidMobileTests/PrebidMobilePRTests.xctestplan is the quick PR plan — a
skip-list of slow/timing-sensitive tests. Repo policy (CLAUDE.md,
test-integrity): the skipped-tests list may ONLY shrink; never add entries
to make a run pass.

The baseline enumerates every skipped test identifier
(baselines/skiplist.txt, '<target>/<Class>/<test>()' per line), so a SWAP —
un-skipping one test while skipping another — fails by name, which a bare
count could never see.

  new skip      → FAIL naming the test: fix it, never hide it
  removed skip  → FAIL until the baseline is updated in the same PR
                  (a visible ratchet win, naming the exact test)
  update        → ./scripts/guards/run-guards.sh --update-skiplist-baseline
"""

import json
import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

PLAN = os.path.join(ROOT, "PrebidMobileTests", "PrebidMobilePRTests.xctestplan")
BASELINE = os.path.join(ROOT, "scripts", "guards", "baselines", "skiplist.txt")
UPDATE_CMD = "./scripts/guards/run-guards.sh --update-skiplist-baseline"


def skipped_identifiers(plan_path=PLAN):
    """Target-prefixed skipped-test identifiers, sorted."""
    with open(plan_path, encoding="utf-8") as fh:
        plan = json.load(fh)
    ids = []
    for target in plan.get("testTargets", []):
        name = target.get("target", {}).get("name", "?")
        ids.extend(f"{name}/{t}" for t in target.get("skippedTests", []))
    return guardlib.c_sorted(ids)


def main(argv):
    try:
        current = skipped_identifiers()
    except (OSError, ValueError) as exc:
        print(f"FAIL: cannot parse {os.path.relpath(PLAN, ROOT)}: {exc}")
        return 1

    if len(argv) > 1 and argv[1] == "--update":
        guardlib.write_lines(BASELINE, current)
        print(f"Recorded {len(current)} skipped test(s) in scripts/guards/baselines/skiplist.txt")
        return 0

    if not os.path.exists(BASELINE):
        print("FAIL: baseline missing. Record it with:")
        print("      " + UPDATE_CMD)
        return 1

    new, removed = guardlib.ratchet(current, guardlib.read_list(BASELINE))

    fail = False
    if new:
        print("FAIL: test(s) newly added to the quick-plan skip-list — the list only")
        print("shrinks; never add entries to make CI pass (CLAUDE.md, test-integrity).")
        print("Fix the test, or report the failure as a blocker:")
        print("\n".join(new))
        fail = True
    if removed:
        print("FAIL: test(s) removed from the skip-list — a ratchet win, but the baseline")
        print("must be updated in the same PR:")
        print("      " + UPDATE_CMD)
        print("\n".join(removed))
        fail = True

    if not fail:
        print(f"OK: quick-plan skip-list unchanged ({len(current)} skipped tests, enumerated).")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
