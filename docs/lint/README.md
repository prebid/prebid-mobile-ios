# SwiftLint

Style and idiom linting for the Swift sources, scoped to the lines a branch **adds**.

```bash
./scripts/lint/run-swiftlint.sh              # what this branch added (advisory)
./scripts/lint/run-swiftlint.sh --blocking   # same, exit 1 on findings
./scripts/lint/run-swiftlint.sh --all        # whole tree — exploration only
```

Requires `swiftlint` (`brew install swiftlint`); CI pins **0.65.0**. Without it the script
reports SKIPPED and exits 2 — advisory, never a pass, same convention the guards use.

## This is not a guard

The [structural guards](../guards/README.md) and SwiftLint solve different problems, and
the split is deliberate:

| | Guards | SwiftLint |
|---|---|---|
| Enforces | architecture: API surface, adapter isolation, migration direction, test presence | per-file style and idiom |
| Scope | cross-file, ObjC + Swift, git history, Mach-O bytes | one Swift file at a time |
| Debt model | ratcheted — allowlists only shrink, a stale entry fails the run | none; legacy is simply out of scope |
| Status | blocking | advisory |

SwiftLint could express roughly two of the fourteen guards. The rest are cross-file
(`ortb-test-presence`, `api-test-presence`, `string-dup-ratchet`), ObjC (`swift-migration-
direction` — half the core is still `.h/.m`), git-diff-based, or not source at all
(`skiplist-ratchet` reads an xctestplan, `binary-size-ratchet` reads Mach-O segments).
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
run it on files **you are already changing**, and check the resulting diff, or the drive-by
formatting ban applies to you too.

## CI

[`.github/workflows/swiftlint.yml`](../../.github/workflows/swiftlint.yml) — ubuntu, pinned
binary, runs on every PR, **advisory**: findings go to the job summary, and the job's
`continue-on-error: true` keeps them from blocking. It sits at job level rather than on the
lint step so a failed install or checkout cannot block a PR either — an advisory check that
can go red on infrastructure is not advisory. Promoting it to blocking is the deletion of
that one line, once the noise floor is known from real PRs.

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
