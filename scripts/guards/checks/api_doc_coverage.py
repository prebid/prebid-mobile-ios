#!/usr/bin/env python3
"""Guard: api-doc-coverage.

"Please describe the method in details" is the third most common actionable
ask in the upstream repo's inline review history (14 comments), and the repo
rule already exists in prose (.claude/rules/code-patterns.md: "Public
declarations carry doc comments — Jazzy publishes them"). This guard makes
it a ratchet: the number of UNDOCUMENTED public declarations per file may
only shrink. New public API arrives documented; existing debt (roughly half
the surface, measured at guard-landing time) is grandfathered as per-file
counts, so a cross-file swap fails in the file that grew.

"Documented" = a `///` line or `/** … */` block immediately above the
declaration head (attribute/modifier lines in between are fine) — detected
by the same extractor that builds the public-API baseline
(api_baseline.swift_decls), so the two guards can never disagree about what
is public. Counted kinds exclude `case` (enum cases are usually documented
on the enum) and `extension` (the extended type carries the docs).

  growth  → FAIL: document the new/changed declaration (///)
  shrink  → FAIL until the baseline is updated in the same PR (ratchet win)
  update  → ./scripts/guards/run-guards.sh --update-api-doc-baseline
"""

import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
sys.path.insert(0, _HERE)
import guardlib  # noqa: E402
import api_baseline  # noqa: E402

BASELINE = os.path.join(ROOT, "scripts", "guards", "baselines", "api-doc-counts.txt")
UPDATE_CMD = "./scripts/guards/run-guards.sh --update-api-doc-baseline"
SKIP_KINDS = {"case", "extension"}


def undocumented_counts(root=ROOT):
    """{relative path: count of undocumented public declarations}."""
    counts = {}
    src_root = os.path.join(root, "PrebidMobile", "Swift")
    for path in guardlib.walk_files(src_root, (".swift",)):
        with open(path, encoding="utf-8", errors="replace") as fh:
            decls = api_baseline.swift_decls(fh.readlines(), include_docs=True)
        n = sum(
            1 for section, _parent, kind, _name, documented in decls
            if section == "swift" and kind not in SKIP_KINDS and not documented
        )
        if n:
            counts[os.path.relpath(path, root)] = n
    return counts


def main(argv):
    current = undocumented_counts()

    if len(argv) > 1 and argv[1] == "--update":
        guardlib.write_lines(BASELINE, guardlib.format_keyed_counts(current))
        total = sum(current.values())
        print(f"Recorded {total} undocumented public declaration(s) across "
              f"{len(current)} file(s) in scripts/guards/baselines/api-doc-counts.txt")
        return 0

    code, messages = guardlib.check_keyed_counts(
        current, BASELINE, "undocumented public API", UPDATE_CMD,
        grow_hint=[
            "New or changed public declarations must carry a doc comment (///) —",
            "Jazzy publishes them (repo rule: .claude/rules/code-patterns.md).",
        ],
    )
    print("\n".join(messages))
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
