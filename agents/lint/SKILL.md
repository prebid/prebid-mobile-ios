---
name: lint
description: Run SwiftLint on the PrebidMobile Swift sources
---

Lint via the repo script, which scopes SwiftLint to the lines the branch **adds**
(diff versus the merge-base with master) — the same check CI runs:

```
./scripts/lint/run-swiftlint.sh              # added lines only — exit 1 on findings
./scripts/lint/run-swiftlint.sh --advisory   # same, report only
./scripts/lint/run-swiftlint.sh --all        # whole tree, report only (exploration)
```

If SwiftLint is not installed, offer to install it via Homebrew (the script warns when
the local version differs from CI's pin):
```
brew install swiftlint
```

After linting, summarize the findings on added lines and fix them by hand. Do **not**
run `swiftlint --fix` over legacy files to clear a finding — it rewrites the whole file,
and the ~13k pre-existing whole-tree violations are explicitly not to be fixed as a
drive-by. See `docs/lint/README.md` for why linting is diff-scoped and which rules are
deliberately left to the structural guards.
