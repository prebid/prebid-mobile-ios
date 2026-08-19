#!/usr/bin/env bash
#
# SwiftLint, scoped to the lines this branch adds.
#
# NOT a guard. The structural guards (./scripts/guards/run-guards.sh) own the
# architecture rules and their ratchets; this owns the per-file style/idiom
# layer they ignore. See .swiftlint.yml for the rule set and why each omitted
# rule is omitted.
#
# Whole-tree linting reports ~13k pre-existing violations — a number no one can
# act on, and which .claude/rules/code-patterns.md forbids fixing as a drive-by.
# So the default mode reports only violations on lines the branch ADDED versus
# the merge-base with master: new code arrives clean, legacy lines stay silent
# until someone edits them on purpose.
#
# Usage:
#   ./scripts/lint/run-swiftlint.sh              # added lines only, advisory (exit 0)
#   ./scripts/lint/run-swiftlint.sh --blocking   # added lines only, exit 1 on findings
#   ./scripts/lint/run-swiftlint.sh --all        # whole tree, advisory (exploration)
#
# Exit codes: 0 = clean (or advisory), 1 = findings with --blocking,
#             2 = SKIPPED (swiftlint not installed) — advisory, never a pass.
#             Matches the guards' EXIT_SKIPPED convention.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT" || exit 1

EXIT_SKIPPED=2

# Keep in sync with .github/workflows/swiftlint.yml — a version bump changes
# which rules exist and what they find.
SWIFTLINT_PINNED="0.65.0"

MODE="diff"
BLOCKING=0
case "${1:-}" in
    --all)      MODE="all" ;;
    --blocking) BLOCKING=1 ;;
    "")         ;;
    *)
        echo "Unknown option: $1"
        sed -n '16,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
        exit 2
        ;;
esac

if ! command -v swiftlint >/dev/null 2>&1; then
    echo "SKIPPED: swiftlint not installed (brew install swiftlint). CI is authoritative."
    exit $EXIT_SKIPPED
fi

INSTALLED="$(swiftlint version 2>/dev/null)"
if [ "$INSTALLED" != "$SWIFTLINT_PINNED" ]; then
    echo "NOTE: swiftlint $INSTALLED installed, CI pins $SWIFTLINT_PINNED — findings may differ."
fi

# ── whole-tree mode ─────────────────────────────────────────────────────────
if [ "$MODE" = "all" ]; then
    echo "── swiftlint: whole tree (exploration; never blocking) ──"
    swiftlint lint --quiet --config .swiftlint.yml
    echo ""
    echo "Advisory only. Do not 'fix' this list in an unrelated PR."
    exit 0
fi

# ── diff mode ───────────────────────────────────────────────────────────────
BASE_REF=""
for ref in origin/master master; do
    if git rev-parse --verify -q "$ref" >/dev/null 2>&1; then BASE_REF="$ref"; break; fi
done
if [ -z "$BASE_REF" ]; then
    echo "SKIPPED: no master ref to diff against (shallow clone?). CI is authoritative."
    exit $EXIT_SKIPPED
fi

MERGE_BASE="$(git merge-base HEAD "$BASE_REF" 2>/dev/null)"
if [ -z "$MERGE_BASE" ]; then
    echo "SKIPPED: cannot compute merge-base with $BASE_REF. CI is authoritative."
    exit $EXIT_SKIPPED
fi

# Added lines, as "<path>:<line>" pairs. --unified=0 so each hunk covers only
# changed lines; uncommitted work is included so a local run matches what you
# are about to commit.
ADDED="$(git diff --unified=0 --no-color --diff-filter=AM "$MERGE_BASE" -- '*.swift' \
    | awk '
        /^\+\+\+ /      { path = substr($0, 7); next }
        /^@@ /          {
            # @@ -old,len +new,len @@
            split($3, h, ",")
            start = substr(h[1], 2) + 0
            len = (h[2] == "" ? 1 : h[2] + 0)
            for (i = 0; i < len; i++) print path ":" (start + i)
        }
    ')"

FILES="$(echo "$ADDED" | sed 's/:[0-9]*$//' | sort -u | while read -r f; do
    [ -n "$f" ] && [ -f "$f" ] && echo "$f"
done)"

if [ -z "$FILES" ]; then
    echo "── swiftlint: no added Swift lines versus $BASE_REF — nothing to lint ──"
    exit 0
fi

echo "── swiftlint: lines added versus $BASE_REF ($(echo "$FILES" | wc -l | tr -d ' ') file(s)) ──"

# --force-exclude so .swiftlint.yml's `excluded` still applies to paths passed
# explicitly on the command line. NUL-delimited so paths with spaces survive;
# xargs may split a long list into several swiftlint runs, so the filter below
# tolerates several concatenated JSON arrays.
RAW_FILE="$(mktemp -t swiftlint-raw)"
trap 'rm -f "$RAW_FILE"' EXIT

echo "$FILES" | tr '\n' '\0' | xargs -0 swiftlint lint --quiet --force-exclude \
    --config .swiftlint.yml --reporter json >"$RAW_FILE" 2>/dev/null

FINDINGS="$(ADDED_LINES="$ADDED" RAW_FILE="$RAW_FILE" ROOT="$ROOT" python3 - <<'PY'
import json, os, sys

added = set(os.environ.get("ADDED_LINES", "").splitlines())
root = os.environ["ROOT"]
raw = open(os.environ["RAW_FILE"]).read().strip()

# xargs may have invoked swiftlint more than once; each run emits its own
# top-level JSON array, so decode them one after another rather than assuming
# the output is a single document.
violations, decoder, pos = [], json.JSONDecoder(), 0
while pos < len(raw):
    try:
        chunk, end = decoder.raw_decode(raw, pos)
    except json.JSONDecodeError:
        print("SWIFTLINT-OUTPUT-UNPARSEABLE", file=sys.stderr)
        sys.exit(3)
    violations.extend(chunk)
    pos = end
    while pos < len(raw) and raw[pos] in " \t\r\n":
        pos += 1

for v in violations:
    path = os.path.relpath(v.get("file", ""), root)
    line = v.get("line")
    if line is None or f"{path}:{line}" not in added:
        continue
    print(f"{path}:{line}:{v.get('character') or 0}: "
          f"{v.get('severity', 'warning')}: {v.get('reason', '')} ({v.get('rule_id', '')})")
PY
)"
FILTER_STATUS=$?

if [ "$FILTER_STATUS" -eq 3 ]; then
    echo "SKIPPED: could not parse swiftlint output. CI is authoritative."
    exit $EXIT_SKIPPED
fi

if [ -z "$FINDINGS" ]; then
    echo "✅ no findings on added lines"
    exit 0
fi

echo "$FINDINGS"
COUNT="$(echo "$FINDINGS" | wc -l | tr -d ' ')"
echo ""
echo "$COUNT finding(s) on lines this branch added."
echo "Fix them, or run: swiftlint --fix --config .swiftlint.yml <file>  (then re-check the diff)."

if [ "$BLOCKING" -eq 1 ]; then
    exit 1
fi
echo "Advisory: not failing the run."
exit 0
