# SwiftLint

Style and idiom linting for the Swift sources, scoped to the lines a branch **adds**. A
violation on one of those lines fails the run, locally and on the PR.

```bash
./scripts/lint/run-swiftlint.sh              # what this branch added — exit 1 on findings
./scripts/lint/run-swiftlint.sh --advisory   # same, report only
./scripts/lint/run-swiftlint.sh --all        # whole tree — exploration only
```

Blocking is the default so a local run gives the same verdict as CI. A check that is green
on your machine and red on the PR teaches people to stop reading it.

Requires `swiftlint` (`brew install swiftlint`); CI pins **0.65.0**, and the script warns
when your local version differs, because a different version finds different things.
Without swiftlint at all the script exits 2 rather than 0 — it never reports a skip as a
pass, same convention the guards use.

## This is not a guard

The [structural guards](../guards/README.md) and SwiftLint solve different problems, and
the split is deliberate:

| | Guards | SwiftLint |
|---|---|---|
| Enforces | architecture: API surface, adapter isolation, migration direction, test presence | per-file style and idiom |
| Scope | cross-file, ObjC + Swift, git history, Mach-O bytes | one Swift file at a time |
| Debt model | ratcheted — allowlists only shrink, a stale entry fails the run | none; legacy is simply out of scope |
| Debt it can demand you fix | anything the rule matches | only lines you added |

SwiftLint could express roughly two of the thirteen guards. The rest are cross-file
(`ortb-test-presence`, `api-test-presence`, `string-dup-ratchet`), ObjC (`swift-migration-
direction` — half the core is still `.h/.m`), git-diff-based, or not source at all
(`skiplist-ratchet` reads an xctestplan, not Swift).
More importantly, SwiftLint has no equivalent of the ratchet: its baselines suppress
pre-existing violations but never fail when an entry goes stale, so debt stops being
monotonically decreasing. **Guards are not being migrated to SwiftLint.**

## One owner per rule

Rules a guard already enforces are deliberately absent from `only_rules` in
[`.swiftlint.yml`](../../.swiftlint.yml) — two systems counting the same thing with
different numbers is worse than either alone:

| SwiftLint rule | Owned instead by |
|---|---|
| `force_cast`, `force_try`, `force_unwrapping` | `ast-rule-ratchet` → `force-unwrap` |
| `weak_delegate` | `ast-rule-ratchet` → `weak-delegate` |
| `todo` | `fixme-ratchet` |
| `missing_docs` | `api-doc-coverage` |

For scale: SwiftLint's `missing_docs` finds 108 declarations; `api-doc-coverage` tracks
818 across 128 files. Its `weak_delegate` finds exactly the 3 the guard baselines. Adopting
the SwiftLint version of either would change the number without changing the code.

## Why diff-scoped

A whole-tree run reports **~13.3k violations** (9.4k of them trailing whitespace). That
backlog is not being fixed: `.claude/rules/code-patterns.md` forbids formatting churn as a
side effect of another change, and a 13k-line reformat would bury every real diff in the
release it landed in.

So the runner intersects SwiftLint's findings with the lines the branch added versus the
merge-base with `master`. Touching a file with 388 legacy violations reports only what you
wrote. New code arrives clean; old code is cleaned when someone has a reason to be there.

Autocorrect the mechanical ones with `swiftlint --fix --config .swiftlint.yml <file>` — but
note it rewrites the **whole file**, not your lines. On a legacy file that turns one finding
into a few hundred unrelated reformatted lines, which the drive-by formatting ban forbids
and which will bury your actual change in review. Check the resulting diff before staging
it; on an old file it is usually faster to fix your own lines by hand.

## CI

[`.github/workflows/swiftlint.yml`](../../.github/workflows/swiftlint.yml) — ubuntu, pinned
binary, runs on every PR, **blocking**. Findings are echoed into the job summary so a
contributor reads what to fix without opening the log.

Nothing is skipped silently: a missing swiftlint, an unusable diff, or a failed install
exits non-zero rather than passing. A gate that quietly turns itself off is worse than no
gate, because the green check still claims the code was checked.

The one thing the gate never does is demand you fix code you did not write — that is what
keeps a blocking style check tolerable on a tree with 13k pre-existing violations.

## Changing the rule set

`only_rules` is used rather than `disabled_rules`/`opt_in_rules` so a SwiftLint version bump
cannot silently introduce a rule — the same determinism requirement that pins ast-grep for
the guards. Adding a rule means: check what it finds on the current tree
(`./scripts/lint/run-swiftlint.sh --all`), confirm it does not duplicate a guard, and bump
the pin in both `scripts/lint/run-swiftlint.sh` and the workflow together if a new version
is needed.

Metrics rules (`file_length`, `type_body_length`, `function_body_length`,
`cyclomatic_complexity`, `nesting`) are omitted on purpose: they report at the declaration
line, which a diff-scoped run has usually not touched, so they fire by association with a
large file rather than with the change.
