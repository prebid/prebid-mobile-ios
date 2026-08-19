---
name: review
description: Review a pull request for the Prebid Mobile iOS SDK
---

Review the current branch's changes against `master` (or another base if specified).
Produce a structured review covering correctness, architecture, tests, and
repo-specific concerns. Adapt depth to the PR type — migration PRs get extra
migration-checklist items; feature/fix PRs skip migration sections.

## Step 1 — Orient

```bash
git fetch origin master                    # local master may be stale
git log --oneline origin/master..HEAD      # commits in this PR
git diff --stat origin/master...HEAD       # files changed
git diff origin/master...HEAD              # full diff (read selectively)
```

Use the **three-dot** range for `git diff`: it diffs against the merge base, so commits landed
on `master` after the branch was cut don't show up as spurious reversions in the PR. (`git log`
keeps the two-dot form — for `log` it already means "reachable from HEAD, not from master".)

Identify the PR type:
- **ObjC→Swift migration** — files under `PrebidMobile/Objc/` deleted and matching files under `PrebidMobile/Swift/...` added
- **Feature / bug fix** — changes to existing Swift or ObjC logic
- **Tooling / CI** — script or config changes
- **Docs only** — `.md` files only

## Step 2 — Run the standard checks

```bash
# Build all XCFrameworks (catches CocoaPods + SPM + Carthage regressions)
./scripts/buildPrebidMobile.sh

# PR test suite (must pass; re-run once if only PBMBidRequesterTest.testBanner_300x250 fails)
./scripts/testPrebidMobile.sh --latest --quick

# SwiftLint (warnings are ok; errors block merge)
swiftlint --config .swiftlint.yml
```

If the full suite is warranted (final PR in a phase, or touching networking):
```bash
./scripts/testPrebidMobile.sh --latest
```

## Step 3 — Code review

### For any PR

**Correctness**
- Logic matches the intent described in the commit message / PR description
- No obvious off-by-one, nil-crash, or force-unwrap in production paths
- Error paths are handled; no silent swallowing of errors
- Thread safety: any shared mutable state accessed from multiple queues?

**Swift quality**
- No single-letter variable names (`d`, `n`, `e`, etc.)
- No unnecessary `@objc` on internal-only Swift code
- `public` access only where needed; prefer `internal`
- Prefer `let` over `var` where value never changes

**iOS SDK specifics**
- No changes to public API surface without explicit intent (check `PrebidMobile/Swift/` public types)
- `fetchDemand` call sites and ad unit lifecycle unaffected
- Min deployment target stays iOS 13.0 — no API calls that require higher
- No new ObjC dependency added to the Swift layer without justification
- Never log consent strings, IDFA, or EIDs (`ORTBUser.ext`) — this SDK handles all three

**Ad rendering — the SDK draws into someone else's window**
- SDK-drawn controls (close, skip, mute, Learn More) keep a **≥44×44pt** tap target. Note
  `AdViewButtonDecorator.getButtonSize()` computes `0.1 × screenWidth`, which is under 44pt on most
  of the device fleet — don't propagate that pattern.
- No `UIScreen.main.bounds` for sizing or positioning. The host app's window may be a fraction of
  the screen under Split View, Slide Over, or Stage Manager; size from the containing view's bounds.
  Likewise avoid `UIApplication.statusBarOrientation` (deprecated since iOS 13) — read the trait
  environment instead.
- Overlay chrome composited over arbitrary advertiser content meets contrast floors: **4.5:1** for
  text, **3:1** for UI components. A translucent scrim over unknown video does not guarantee either.
- Text the SDK draws either scales with Dynamic Type (`UIFontMetrics.scaledFont(for:)`) or is
  deliberately capped for a fixed-height overlay — not silently frozen at a point size.
- When ad chrome changes, spot-check with VoiceOver on, text at Accessibility XXXL, and Reduce
  Transparency enabled.

**Tests**
- New tests run in the PR plan. `PrebidMobilePRTests.xctestplan` selects by *exclusion*
  (`skippedTests`), so new classes are picked up automatically — only verify the class isn't
  listed there.
- Existing tests not weakened. In particular, `assertForOverFulfill = false`, `XCTAssert(true)`,
  and assertions relaxed to `!error.localizedDescription.isEmpty` hide the failure instead of
  fixing it; prefer isolating the test (e.g. tagging fixtures per test instance so a shared
  singleton's callbacks can be filtered).
- No mocked database / network when a real one is feasible

### For ObjC→Swift migration PRs (additional checks)

**File structure**
- Swift twins land under `PrebidMobile/Swift/PrebidMobileRendering/ORTB/Request/` (or mirrored path)
- Filename: `ORTBFoo.swift` (no `PBM` prefix)
- Class declaration: `@objc(PBMORTBFoo) public class ORTBFoo: NSObject, PBMJsonCodable`

**ObjC bridge completeness (Gaps 6 & 7)**
- Class is `@objc public class` — not just `public class`
- All `@objc`-visible properties have `@objc public var`
- Init: `@objc(initWithJsonDictionary:) public required init(jsonDictionary:)` — non-optional, calls `super.init()` first
- Encode: `@objc(toJsonDictionary) public var jsonDictionary: [String: Any]`

**JSON parity**
- Every ObjC property has a corresponding Swift property with the **exact same JSON key string**
- Empty arrays are included as-is (not suppressed) — `pbmCopyWithoutEmptyVals` only strips nil/NSNull (Gap 9)
- Child ORTB objects use `json[.key] = childObj` — empty-dict suppression is automatic (Gap 2)
- `lat`/`lon` on `ORTBGeo` must use `NSDecimalNumber(decimal:)` on encode to preserve decimal precision

**NSMutableDictionary properties (Gap discovered S1.4)**
- Any property typed `NSMutableDictionary *` in ObjC must be decoded as:
  `NSMutableDictionary(dictionary: extDict)` — NOT `as? NSMutableDictionary` (silently returns nil)

**NSCopying (Gap discovered S1.4)**
- If the ObjC type conformed to `<NSCopying>`, the Swift twin must also conform
- Implement via JSON round-trip: `Self(jsonDictionary: jsonDictionary)`

**`JSONObject.dict` private(set) (Gap 10)**
- Cannot write `json.dict["ext"] = val` from outside the struct
- Use `var result = json.dict; result["ext"] = val; return result` for untyped sub-dict injection

**ObjC file cleanup**
- `.m` file deleted ✓
- `PrivateHeaders/*.h` deleted ✓
- `PBMORTBAbstract+Protected.h` import removed from the deleted `.m` (not from Phase 3/4 consumers)
- `PBMORTB.h` umbrella updated (deleted type removed from imports)
- Remaining ObjC consumers updated: `#import "PBMORTBFoo.h"` → `#import "SwiftImport.h"`
- Xcode project: `.m`/`.h` refs removed, `.swift` ref added (check `project.pbxproj` diff)

**Test file updates**
- Swift test files use new `ORTBFoo` names (not `PBMORTBFoo`) — no `'has been renamed'` compiler errors
- Used `perl -pi -e 's/PBMORTBFoo\b/ORTBFoo/g'` (not `sed`, which has unreliable `\b` on macOS)
- `codeAndDecode<T: PBMORTBAbstract>` overload removed once `PBMORTBAbstract.m` is deleted
- Decode coverage includes a **partial** JSON payload, not only a fully-populated fixture —
  round-tripping a full fixture cannot catch a resurrected class default (Gap S2.5-C)

**Docs**
- `docs/migration/playbook.md` updated if a new gap was discovered
- The PR's `docs/migration/pr-phase-*.md` updated with step summary and ticked test-plan boxes,
  and no superseded draft docs left alongside it

## Step 4 — Known flaky test

`PBMBidRequesterTest.testBanner_300x250` fails intermittently under full-suite
simulator load but passes in isolation. Do NOT flag this as a regression unless
it also fails when run alone:

```bash
xcodebuild ... -only-testing PrebidMobileTests/PBMBidRequesterTest/testBanner_300x250 \
  test-without-building
```

## Step 5 — Produce the review

Structure the output as:

```
## Summary
One paragraph: what the PR does, and the overall verdict (approve / request changes / comment).

## Blockers
Numbered list of must-fix items (empty if none).

## Suggestions
Numbered list of non-blocking improvements.

## Migration checklist (migration PRs only)
[ ] ObjC bridge annotations present
[ ] JSON key strings match ObjC originals
[ ] ObjC files deleted, consumers patched, project.pbxproj clean
[ ] Test files renamed, new classes registered in PRTests plan
[ ] Playbook updated if new gap discovered
[ ] Build + quick tests green

## Nits
One-liners: style, naming, comment quality. Low priority.
```

Keep the review concise. Lead with blockers. Skip sections that have nothing to report.
