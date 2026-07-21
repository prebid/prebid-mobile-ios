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
git log --oneline master..HEAD          # commits in this PR
git diff --stat master..HEAD            # files changed
git diff master..HEAD                   # full diff (read selectively)
```

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

**Tests**
- New test class registered in `PrebidMobileTests/PrebidMobilePRTests.xctestplan`
- Existing tests not weakened (no `assertForOverFulfill = false` added without comment)
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
- New test class registered in `PrebidMobilePRTests.xctestplan`

**Docs**
- `docs/migration/playbook.md` updated if a new gap was discovered
- `docs/migration/pr-phase-N.md` updated with step summary and ticked test-plan boxes

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
