---
name: sdk-review
description: Review a branch/PR against master — or audit the full tree — with this repo's review checklist. Guards first, then the human-judgment items guards can't see (privacy logging, API stability, rendering/accessibility, test integrity), plus the ObjC→Swift migration checklist for migration PRs. Verdict-first structured review reported in the conversation, including guard candidates.
---

# PR review / audit for prebid-mobile-ios

`/sdk-review [target]` — `target` is a branch, a commit range (default `master...HEAD`),
or `full` (audit the whole tree).

Findings are reported in the conversation, in the §6 format. This skill writes no files:
it never commits a review report, and never edits source, tests, or guard data — fixes
are a follow-up the maintainer asks for explicitly.

Out of scope for this checklist: SwiftLint (advisory and diff-scoped, and it reports for
itself — see `docs/lint/README.md`) and build/test commands (the quality-gate ladder in
`.claude/rules/quality-gates.md` owns rung sequencing).

## 1. Orient

```bash
git fetch origin master
git log --oneline origin/master..HEAD      # two-dot: commits on the branch
git diff origin/master...HEAD              # three-dot: merge-base diff
```

Use the **three-dot** form for `diff` — it compares against the merge-base, so a stale
branch doesn't show phantom reversions of other people's work. `log` keeps two dots.

Classify the PR and adapt depth:
- **Migration** (ObjC→Swift) → everything below plus the migration checklist.
- **Feature/fix** → standard checklist; wire-format changes trigger `/verify-spec`.
- **Tooling/CI** → focus on the guard/workflow semantics and the release path.
- **Docs-only** → correctness of commands and paths only.

## 2. Mechanical checks first — never hand-review what a guard checks

```bash
./scripts/guards/run-guards.sh
```

| Concern | Already guarded by |
|---|---|
| Force-unwraps, off-main delegate callbacks, strong delegates | `ast-rule-ratchet` |
| Public API changes, SPI/ObjC-internal surface, SPM product exports | `public-api-baseline` |
| Raw `print()`/`NSLog()` | `logging-hygiene` |
| New ObjC files in the core | `swift-migration-direction` |
| Adapters reaching into internals | `adapter-isolation` |
| ORTB models without tests | `ortb-test-presence` |
| New FIXME/TODO markers | `fixme-ratchet` |

Guards green → those dimensions are done; don't re-litigate them by hand. Baseline or
allowlist diffs in the PR are the review surface: each must be intentional and called out.
If review finds a violation class no guard covers, that's a `/guard` candidate — say so
in the review output.

## 3. Human-judgment checklist (all PRs)

Things no guard can see:

- **Privacy in logs**: never log consent strings, IDFA, or EIDs — not even at debug level.
  Check every new `Log.*` call's interpolations.
- **Publisher API stability**: `fetchDemand` behavior untouched unless the PR says
  otherwise; iOS 13.0 deployment floor preserved (`@available` additions are fine,
  raising the floor is not).
- **Rendering / accessibility** (for creative-UI changes):
  - SDK-drawn controls need ≥44×44 pt tap targets — the existing `getButtonSize()`
    pattern of 0.1 × screen width falls short on small screens; flag new uses.
  - Avoid `UIScreen.main.bounds` for layout — wrong under Split View / Stage Manager;
    use the hosting view's bounds.
  - Contrast floors: 4.5:1 for text, 3:1 for controls; Dynamic Type via
    `UIFontMetrics.scaledFont(for:)` where the creative renders text.
- **Test integrity** (see `.claude/rules/testing-patterns.md`):
  - No weakening: `assertForOverFulfill = false`, trivial assertions
    (`XCTAssertNotNil` on something that can't be nil), or deleted assertions.
  - New test classes must NOT appear in the quick plan's `skippedTests`
    (guard: `skiplist-ratchet` catches the count; review catches the intent).
  - Prefer existing `Mock*` doubles and MockServer rules over new hand-rolled stubs.
- **Threading**: new shared mutable state uses the concurrent-queue-with-barrier pattern
  (`PrebidMobilePluginRegister` is canonical); background work stays off main with only
  the callback hop dispatched.

Layer spot-checks, when the diff touches them:

- **public-api**: is `public` deliberate (`internal` wouldn't do)? Doc comments present
  (Jazzy publishes them)? PR title reflects the API change (titles become release notes)?
- **ortb**: spec permalink cited in code + PR; wire-format test asserts the change;
  Prebid-extension vs OpenRTB-core distinguished (`/verify-spec` for anything nontrivial).
- **networking**: MockServer rules, not ad-hoc URLSession stubs; timeout/retry behavior
  tested.
- **objc-bridge**: logic moved Swift-ward rather than duplicated; PrivateHeaders stayed
  private; `@_spi` not leaked toward adapters.
- **build-system**: all three build systems consistent (xcodeproj / `Package.swift` /
  podspecs); `.jazzy.yaml` drift (the baseline guard reports it as an advisory).
- **ci-scripts**: still runnable on the pinned runner images; no drift between the quick
  and full CI paths.

## 4. Migration checklist (ObjC→Swift PRs only)

- **Bridge completeness**: Swift class declared `@objc(PBMORTBFoo) public class`; ObjC
  callers keep the `PBM` name; `@objc public` on every bridged property; required
  initializer exposed as `initWithJsonDictionary:` and calling `super.init()` first;
  encode exposed as `@objc(toJsonDictionary)`.
- **JSON parity traps**:
  - Key strings byte-identical to the ObjC original; empty arrays preserved; child
    objects get empty-dict suppression.
  - `NSMutableDictionary` values must be decoded with the initializer — `as?` casting
    silently yields nil.
  - `lat`/`lon` and other decimals via `NSDecimalNumber(decimal:)`, not `Double`.
  - Parity is proven by round-trip tests including a **partial** JSON fixture (missing
    keys), not just the full-object fixture.
- **Cleanup completeness**: `.m` and private header deleted; `PBMORTB.h` umbrella
  updated; consumers moved to `SwiftImport.h`; `project.pbxproj` consistent with
  `Package.swift` and the podspec (three-build-systems rule).
- **Test renames** with `perl -pi -e` rather than `sed` (BSD sed's `\b` is unreliable).
- **Docs**: migration playbook and phase doc updated; superseded drafts removed.

## 5. Known flaky test

`PBMBidRequesterTest.testBanner_300x250` is intermittently flaky under parallel load.
Only flag it if it fails in isolation:
`-only-testing:PrebidMobileTests/PBMBidRequesterTest/testBanner_300x250`.

## 6. Output format

In order, skipping empty sections, blockers first:

1. **Summary** — 2-3 sentences + verdict: `approve` / `request changes` / `comment`.
2. **Blockers** — each with file:line and why it blocks.
3. **Suggestions** — non-blocking improvements.
4. **Migration checklist** — migration PRs only: the section-4 items as checkboxes.
5. **Guard candidates** — violation classes found by hand that a guard could catch;
   hand each to `/guard` so review vigilance is never needed for it again.
6. **Nits** — style only, freely ignorable.