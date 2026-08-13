#!/usr/bin/env python3
"""Guard G3: swift-migration-direction.

The core SDK is migrating Objective-C → Swift. New source files belong in
PrebidMobile/Swift/; this check fails when a branch ADDS .h/.m/.mm files
under PrebidMobile/Objc/. Modifying existing ObjC files is fine.

Rare, genuinely unavoidable exceptions (e.g. a bridge shim Swift cannot
express) are granted explicitly: add the file path to
allowlists/swift-migration-direction.txt with a justification comment line
above it, in the same PR — the grant is then part of the reviewed diff.
After the PR merges, the entry is no longer needed and should be removed
(the guard nudges, but does not fail, on stale entries).

Diff-based, so it ratchets by construction.
"""

import os
import re
import subprocess
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

ALLOWLIST = os.path.join(ROOT, "scripts", "guards", "allowlists", "swift-migration-direction.txt")
_OBJC_SUFFIX_RE = re.compile(r"\.(h|m|mm)$")


def _git(*args):
    return subprocess.run(
        ("git",) + args, cwd=ROOT, capture_output=True, text=True, check=False
    )


def classify(added, granted):
    """(ungranted, used, stale) — fail / reviewer-note / cleanup-advisory."""
    added_set, granted_set = set(added), set(granted)
    return (
        sorted(added_set - granted_set),
        sorted(added_set & granted_set),
        sorted(granted_set - added_set),
    )


def main(_argv):
    base_ref = next(
        (ref for ref in ("origin/master", "master")
         if _git("rev-parse", "--verify", "-q", ref).returncode == 0),
        None,
    )
    if base_ref is None:
        print("SKIPPED: no master ref found to diff against (shallow clone?). CI is authoritative.")
        return 0

    merge_base = _git("merge-base", "HEAD", base_ref).stdout.strip()
    if not merge_base:
        print(f"SKIPPED: cannot compute merge-base with {base_ref}. CI is authoritative.")
        return 0

    diff = _git("diff", "--name-only", "--diff-filter=A",
                f"{merge_base}..HEAD", "--", "PrebidMobile/Objc/")
    added = sorted(p for p in diff.stdout.splitlines() if _OBJC_SUFFIX_RE.search(p))

    ungranted, used, stale = classify(added, guardlib.read_list(ALLOWLIST))

    if ungranted:
        print("FAIL: new Objective-C files added under PrebidMobile/Objc/ — new code goes in PrebidMobile/Swift/:")
        print("\n".join(ungranted))
        print("If ObjC is genuinely unavoidable (rare — e.g. a bridge shim Swift cannot express),")
        print("grant it explicitly: add the path to scripts/guards/allowlists/swift-migration-direction.txt")
        print("with a justification comment above it, in this same PR, and call it out for review.")
        return 1

    if used:
        print("NOTE: granted ObjC exception(s) in this branch — reviewers, check the justification:")
        print("\n".join(used))
    if stale:
        print("ADVISORY: allowlist entr(ies) no longer match a newly-added file (merged or gone) —")
        print("remove them from scripts/guards/allowlists/swift-migration-direction.txt:")
        print("\n".join(stale))

    print("OK: no ungranted Objective-C files added to the core.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
