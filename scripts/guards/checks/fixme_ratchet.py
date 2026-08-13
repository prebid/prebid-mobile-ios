#!/usr/bin/env python3
"""Guard: fixme-ratchet.

FIXME/TODO markers in core sources are deferred behavior decisions — upstream
issue #1299 (interstitial orientation lock never engages) is a FIXME that
shipped as behavior. The count is a committed ratchet: it may only shrink.

  growth  → FAIL: remove the marker (fix it, or file an issue and delete it)
  shrink  → FAIL until the baseline is updated in the same PR (ratchet win)
  update  → ./scripts/guards/run-guards.sh --update-fixme-baseline
"""

import os
import re
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

BASELINE = os.path.join(ROOT, "scripts", "guards", "baselines", "fixme-count.txt")
UPDATE_CMD = "./scripts/guards/run-guards.sh --update-fixme-baseline"
_MARKER_RE = re.compile(r"(//|/\*).*(FIXME|TODO)", re.IGNORECASE)


def count(root=ROOT):
    total = 0
    src_root = os.path.join(root, "PrebidMobile")
    for path in guardlib.walk_files(src_root, (".swift", ".h", ".m", ".mm")):
        with open(path, encoding="utf-8", errors="replace") as fh:
            total += sum(1 for line in fh if _MARKER_RE.search(line))
    return total


def main(argv):
    current = count()

    if len(argv) > 1 and argv[1] == "--update":
        guardlib.write_lines(BASELINE, [str(current)])
        print(f"Recorded {current} FIXME/TODO marker(s) in scripts/guards/baselines/fixme-count.txt")
        return 0

    code, messages = guardlib.check_count(
        current, BASELINE, "FIXME/TODO", UPDATE_CMD,
        grow_hint=[
            "The ratchet only shrinks. Fix the marked issue, or file a GitHub issue and",
            "delete the marker. Inspect with:",
            "      grep -rniE '(//|/\\*).*(FIXME|TODO)' PrebidMobile --include='*.swift' --include='*.h' --include='*.m'",
        ],
    )
    print("\n".join(messages))
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
