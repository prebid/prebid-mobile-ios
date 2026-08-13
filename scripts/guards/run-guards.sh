#!/usr/bin/env bash
#
# Structural guards for prebid-mobile-ios.
#
# Fast, deterministic architecture checks that run locally and in CI
# (.github/workflows/guards.yml). See docs/guards/README.md for what each
# guard enforces and how to fix a failure.
#
# Usage:
#   ./scripts/guards/run-guards.sh                             # run all guards
#   ./scripts/guards/run-guards.sh --update-api-baseline       # regenerate the public-API baseline
#   ./scripts/guards/run-guards.sh --update-fixme-baseline     # re-record the FIXME/TODO count
#   ./scripts/guards/run-guards.sh --update-ast-rule-baseline  # re-record the ast-grep rule counts
#   ./scripts/guards/run-guards.sh --update-skiplist-baseline  # re-record the xctestplan skip-list count
#
# Exit code: non-zero if any blocking guard fails. Advisory guards report
# findings but never fail the run.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export GUARDS_DIR="$ROOT/scripts/guards"
cd "$ROOT"

if [ "${1:-}" = "--update-api-baseline" ]; then
    python3 "$GUARDS_DIR/checks/api_baseline.py" --update
    exit $?
fi

if [ "${1:-}" = "--update-fixme-baseline" ]; then
    python3 "$GUARDS_DIR/checks/fixme_ratchet.py" --update
    exit $?
fi

if [ "${1:-}" = "--update-skiplist-baseline" ]; then
    python3 "$GUARDS_DIR/checks/skiplist_ratchet.py" --update
    exit $?
fi

if [ "${1:-}" = "--update-api-doc-baseline" ]; then
    python3 "$GUARDS_DIR/checks/api_doc_coverage.py" --update
    exit $?
fi

if [ "${1:-}" = "--update-string-dup-baseline" ]; then
    python3 "$GUARDS_DIR/checks/string_dup_ratchet.py" --update
    exit $?
fi

# ── ast-grep rule count ratchet (shared by the update flag and the guard) ───
AST_RULES="main-thread-delegate-callbacks force-unwrap weak-delegate"
AST_BASELINE="$GUARDS_DIR/baselines/ast-rule-counts.txt"
AST_GREP_PINNED="0.45.1"   # keep in sync with the install step in .github/workflows/guards.yml

ast_rule_counts() { # emits "<rule-id> <count>" per rule, from one scan
    local scan id
    # NB: relative scan path — the rules' `files:` globs match relative paths only.
    # A failed scan (e.g. a malformed rule file) must NOT read as zero findings —
    # that would look like a ratchet win and invite a zeroed baseline.
    if ! scan=$(ast-grep scan -c "$GUARDS_DIR/sgconfig.yml" PrebidMobile/Swift --json=stream 2>/dev/null); then
        return 2
    fi
    for id in $AST_RULES; do
        printf '%s %s\n' "$id" "$(printf '%s' "$scan" | grep -c "\"ruleId\":\"$id\"" || true)"
    done
}

if [ "${1:-}" = "--update-ast-rule-baseline" ]; then
    if ! command -v ast-grep >/dev/null 2>&1; then
        echo "FAIL: ast-grep is required to update the rule-count baseline (brew install ast-grep)."
        exit 1
    fi
    if ! COUNTS=$(ast_rule_counts); then
        echo "FAIL: ast-grep scan failed (malformed rule file?) — baseline not written."
        echo "Debug with: ast-grep scan -c scripts/guards/sgconfig.yml PrebidMobile/Swift"
        exit 1
    fi
    printf '%s\n' "$COUNTS" > "$AST_BASELINE"
    echo "Recorded ast-grep rule counts in scripts/guards/baselines/ast-rule-counts.txt:"
    cat "$AST_BASELINE"
    echo "Commit the diff in the same PR and justify any increase for review."
    exit 0
fi

FAILED=()
PASSED=()
ADVISORY_NOTES=()

run_guard() { # <id> <script> [args...]
    local id="$1"; shift
    echo ""
    echo "── guard: $id ──────────────────────────────────────────"
    if "$@"; then
        PASSED+=("$id")
    else
        FAILED+=("$id")
    fi
}

run_guard adapter-isolation        python3 "$GUARDS_DIR/checks/adapter_isolation.py"
run_guard public-api-baseline      python3 "$GUARDS_DIR/checks/api_baseline.py"
run_guard swift-migration-direction python3 "$GUARDS_DIR/checks/swift_migration_direction.py"
run_guard fixme-ratchet            python3 "$GUARDS_DIR/checks/fixme_ratchet.py"
run_guard ortb-test-presence       python3 "$GUARDS_DIR/checks/ortb_test_presence.py"
run_guard logging-hygiene          python3 "$GUARDS_DIR/checks/logging_hygiene.py"
run_guard skiplist-ratchet         python3 "$GUARDS_DIR/checks/skiplist_ratchet.py"
run_guard deprecation-hygiene      python3 "$GUARDS_DIR/checks/deprecation_hygiene.py"
run_guard api-doc-coverage         python3 "$GUARDS_DIR/checks/api_doc_coverage.py"
run_guard api-naming               python3 "$GUARDS_DIR/checks/api_naming.py"
run_guard api-test-presence        python3 "$GUARDS_DIR/checks/api_test_presence.py"
run_guard string-dup-ratchet       python3 "$GUARDS_DIR/checks/string_dup_ratchet.py"

# ── ast-rule-ratchet (BLOCKING — per-rule count may not grow) ───────────────
# The three pattern rules (main-thread-delegate-callbacks, force-unwrap,
# weak-delegate) carry grandfathered findings recorded as counts in
# baselines/ast-rule-counts.txt. Growth fails (fix the new site, or update the
# baseline with justification in the PR); shrinkage fails until the baseline
# is updated in the same PR — a visible ratchet win.
echo ""
echo "── guard: ast-rule-ratchet ──────────────────────────────"
if command -v ast-grep >/dev/null 2>&1; then
    AST_GREP_LOCAL=$(ast-grep --version 2>/dev/null | awk '{print $NF}')
    if [ "$AST_GREP_LOCAL" != "$AST_GREP_PINNED" ]; then
        echo "NOTE: local ast-grep $AST_GREP_LOCAL differs from CI's pinned $AST_GREP_PINNED —"
        echo "      counts may disagree with CI, which is authoritative."
    fi
    if [ ! -f "$AST_BASELINE" ]; then
        echo "FAIL: baseline missing. Record it with:"
        echo "      ./scripts/guards/run-guards.sh --update-ast-rule-baseline"
        FAILED+=(ast-rule-ratchet)
    elif ! CURRENT_COUNTS=$(ast_rule_counts); then
        echo "FAIL: ast-grep scan failed (malformed rule file?) — counts are unavailable,"
        echo "      NOT zero. Do not update any baseline off this state. Debug with:"
        echo "      ast-grep scan -c scripts/guards/sgconfig.yml PrebidMobile/Swift"
        FAILED+=(ast-rule-ratchet)
    else
        RATCHET_FAIL=0
        for id in $AST_RULES; do
            cur=$(printf '%s\n' "$CURRENT_COUNTS" | awk -v r="$id" '$1==r {print $2}')
            rec=$(awk -v r="$id" '$1==r {print $2}' "$AST_BASELINE")
            rec=${rec:-0}
            if [ "$cur" -gt "$rec" ]; then
                echo "FAIL: $id count grew ($rec → $cur). Fix the new site(s), or update the"
                echo "      baseline with justification in this PR. Inspect with:"
                echo "      ast-grep scan -c scripts/guards/sgconfig.yml PrebidMobile/Swift"
                RATCHET_FAIL=1
            elif [ "$cur" -lt "$rec" ]; then
                echo "FAIL: $id count shrank ($rec → $cur) — a ratchet win, but the baseline"
                echo "      must be updated in the same PR:"
                echo "      ./scripts/guards/run-guards.sh --update-ast-rule-baseline"
                RATCHET_FAIL=1
            else
                echo "OK: $id unchanged ($cur)."
            fi
        done
        if [ "$RATCHET_FAIL" -eq 1 ]; then
            FAILED+=(ast-rule-ratchet)
        else
            PASSED+=(ast-rule-ratchet)
        fi
    fi
else
    ADVISORY_NOTES+=("ast-rule-ratchet: SKIPPED (ast-grep not installed; CI is authoritative)")
    echo "SKIPPED: ast-grep not installed (brew install ast-grep). CI runs this check."
fi

# ── summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═════════════════════════════════════════════════════════"
echo "Guards passed: ${#PASSED[@]:-0} (${PASSED[*]:-})"
for note in "${ADVISORY_NOTES[@]:-}"; do
    [ -n "$note" ] && echo "Advisory: $note"
done
if [ "${#FAILED[@]}" -gt 0 ]; then
    echo "Guards FAILED: ${FAILED[*]}"
    echo "See docs/guards/README.md for how to fix each guard."
    exit 1
fi
echo "All blocking guards passed."
