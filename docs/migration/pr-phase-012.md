# [swift-migration] Phases 0–2 — Setup, ORTB request models, Utilities & extensions

Squashed combination of `swift-migration-phase-0`, `swift-migration-phase-1`, and
`swift-migration-phase-2` into three commits on top of `master`, per the
[migration plan](../../../../pi_vault/TaskNotes/Tasks/%5BPI%5D%5BPREBID%5D%20Develop%20a%20plan%20to%20migrate%20the%20iOS%20SDK%20to%20Swift.md)
("[PI][PREBID] Develop a plan to migrate the iOS SDK to Swift"). Part of an ObjC → Swift
migration of `PrebidMobile/Objc/` covering ~119 `.m` + 152 `.h` files across 9 phases; this
PR lands the first three.

## Summary

### Phase 0 — Setup & tooling (no migration)

- **S0.1 — Functional-gap audit & playbook** (`docs/migration/playbook.md`): codified 5 gaps
  before any Swift twins were written — dropping `NSCopying` (no live callsite), empty
  child-dict suppression in `JSONObject`, `isEqual`/`hash` for `PBMORTBFormat` (`NSSet`
  dedup), the `@objc NSObject` requirement for Phase 1–3 twins, and `init?` vs. the old
  broken-instance fallback.
- **S0.2 — Parity harness**: `ORTBParityHelper.swift` with `assertORTBParity<ObjCType, SwiftType>`
  plus baseline fixtures for Phase 1 leaf types.
- **S0.3 — Tooling hardening**: removed dead CircleCI provisioning from all four build/test
  scripts (repo runs exclusively on GitHub Actions `macos-15` now); hardened
  `testPrebidMobile.sh` (pre-deletes the test simulator before recreating it, scoped the
  clean-build step to an explicit scheme/destination); fixed a flaky
  `PrebidEventDelegateTests` crash (`assertForOverFulfill`); added the `/build-sdk` skill and
  updated `/xcodebuild`; started tracking `CLAUDE.md` (removed from `.gitignore`).

### Phase 1 — ORTB bid-request models (25 files)

Ports every ObjC `PBMORTB*` request-side model in
`PrebidMobile/Objc/PrebidMobileRendering/ORTB/` to Swift, in dependency order:

- **S1.1** — leaf models (`ORTBFormat`, `ORTBPublisher`, `ORTBGeo`, `ORTBDeal`,
  `ORTBSourceExtOMID`, `ORTBImpExtSkadn`, `ORTBDeviceExtAtts`)
- **S1.2** — composite request blocks (`ORTBBanner`, `ORTBVideo`, `ORTBPmp`,
  `ORTBImpExtPrebid`, `ORTBImp`)
- **S1.3** — top-level objects (`ORTBApp`, `ORTBAppExt(Prebid)`, `ORTBDevice`,
  `ORTBDeviceExtPrebid(Interstitial)`, `ORTBUser`, `ORTBRegs`, `ORTBSource`,
  `ORTBRendererConfig`)
- **S1.4** — root container (`ORTBBidRequest`, `ORTBBidRequestExtPrebid`); deleted
  `PBMORTBAbstract.m` (headers kept — still imported by Phase 3/4 ObjC parameter builders)

Naming convention established and applied from here on: Swift class drops the `PBM`
prefix (`ORTBFoo`), ObjC callers keep seeing the original name via `@objc(PBMORTBFoo)`.

10 gaps discovered and codified in the playbook (framework-build visibility requiring
`@objc public`, explicit ObjC selector bridge annotations, private-header invisibility to
Swift, empty-array preservation, `JSONObject.dict`'s `private(set)`, `NSCopying` via JSON
round-trip on `ORTBBidRequest`, `NSMutableDictionary` decode from `JSONSerialization`, and
the `PBMORTBAbstract` deletion cascade into test helpers).

### Phase 2 — Utilities & extensions (parallel-safe with Phase 1)

Ports `PrebidMobile/Objc/PrebidMobileRendering/Utilities/` and `ExtensionsAndWrappers/`:

- **S2.1** — standalone utilities: `Functions` (+ `Functions+Testing`), MRAID constant
  classes, `DeepLinkPlus`, `DeviceAccessManagerKeys`, `DownloadDataHelper`,
  `CircularProgressBar{Layer,View}`, `WKScriptMessageHandlerLeakAvoider`. Deferred:
  `PBMDeepLinkPlusHelper` (Phase 4) and `PBMWindowLocker` (Phase 8) — both depend on
  private-header types not yet ported. `PBMMRAIDConstants.m` partially remains (only the
  `NS_TYPED_ENUM` string globals, which have no Swift-bridgeable equivalent).
- **S2.2** — Foundation/UIKit category extensions: `NSDictionary`, `NSMutableDictionary`,
  `NSString`, `NSURL`, `NSException`, `UIView`, `UIWindow` `+PBMExtensions`,
  `TouchDownRecognizer`, and the view-exposure trio (`ViewExposureImpl`,
  `ViewExposureChecker`, `UIView+PBMViewExposure`).
- **S2.3** — `NSTimer` wrapper: `TimerInterface`, `NSTimer+PBMScheduledTimerFactory`,
  `WeakTimerTargetBox`. `NSInvocationOperation` replaced with `NSObject.perform(_:with:)`.

13 additional gaps codified (S2.1-A through S2.3-C) — `@_spi(PBMInternal)` propagation,
`dispatch_time()`/`UIInterfaceOrientationIsPortrait()` replacements, `@objc(name:error:)`
selector labels on throwing methods, `@dynamic` → `@NSManaged`, ObjC protocol
forward-declaration pattern, Foundation-nil string bridging, and header-reduction fallout.

## What changed vs. the original phase branches

The three phase branches (`swift-migration-phase-0/1/2`) were squashed into one commit per
phase and rebased onto current `master`. Two conflicts surfaced during the rebase, both
resolved as a union of intent (nothing from either side was dropped):

- **`.gitignore`** — kept master's new `EventHandlers/Package.resolved` entry; dropped the
  `CLAUDE.md`/`.claude/` ignore block per Phase 0's intent (this migration tracks those
  files).
- **`PrebidMobile.xcodeproj/project.pbxproj`** — kept Phase 1's two new `PBXBuildFile`
  entries (`ORTBBidRequestExtPrebid.swift`, `ORTBDeviceExtPrebidInterstitial.swift`); the
  conflict was purely adjacent-line positioning in the sorted list.

## S2.5 — Review fixes (correctness blockers from PR review)

Three defects found in review, all in Phase 2 utilities. Each is invisible to the current CI
matrix, which is why they shipped — the fixes therefore include a new CI gate.

- **`DownloadDataHelper.downloadData(for:maxSize:)` — `[weak self]` broke the download.**
  The ObjC original captured `self` strongly, and that capture was the only thing keeping the
  helper alive: callers such as `PBMCreativeFactoryJob` create it as a bare local and return
  immediately. With a weak capture the helper deallocates between the HEAD and the GET, the GET
  never runs, and the completion closure never fires (the video simply never preloads). Restored
  the strong capture with a comment explaining why. Tests missed it because they hold the helper
  in a scope spanning `waitForExpectations` (Gap S2.5-B).

- **`Functions.dispatchTimeAfterTimeInterval` — mach ticks vs. nanoseconds.**
  The port ran the incoming `dispatch_time_t` through `DispatchTime(uptimeNanoseconds:)`, which
  *converts* nanoseconds to ticks, double-scaling an already-tick value. Correct in the simulator
  (1:1 timebase) and off by ~41x on arm64 devices (125/3). Rewritten to branch on
  `DISPATCH_TIME_NOW` / `DISPATCH_TIME_FOREVER` and convert explicitly via `mach_timebase_info`.
  Playbook Gap S2.1-C prescribed the buggy pattern and has been corrected so later phases don't
  repeat it.

- **Three ObjC files no longer compiled under SwiftPM.**
  `PBMPrebidParameterBuilder.m`, `PBMCreativeViewabilityTracker.m` and `PBMAdViewManager.m` were
  getting UIKit transitively through headers this PR deleted. CocoaPods masks this (the generated
  `PrebidMobile-Swift.h` re-exports the umbrella headers); SwiftPM's `@import PrebidMobile;` does
  not. Added explicit `#import <UIKit/UIKit.h>` to each (Gap S2.5-A).

- **New CI gate: `scripts/buildPrebidMobilePackage.sh` + `build-spm-package` job.**
  No existing check compiles this working tree under SwiftPM — `buildPrebidSPM.sh` builds
  `PrebidDemoSPM`, which consumes the *published* package via `XCRemoteSwiftPackageReference`. The
  new script runs `swift build --target __PrebidMobileInternal` against the iOS simulator triple
  (passing the SDK and the OMSDK xcframework slice explicitly, since SwiftPM resolves binary
  targets against the host platform). Verified it reproduces the reviewer's exact error when the
  UIKit import is removed.

## S2.6 — Review fixes (round 2)

**ORTB decode parity (Gap S2.5-C).** `initWithJsonDictionary:` writes ivars directly and
unconditionally, so an absent key wipes the default seeded by `init` and the key is omitted on
re-encode. Three ports used `json[.k] ?? default` instead and therefore invented wire keys:
`ORTBDeal` (`bidfloor`, `bidfloorcur`, `wseat`, `wadomain`), `ORTBImp` (`instl`, `clickbrowser`,
`secure`) and `ORTBBidRequest` (`imp` fell back to the one-element default when `"imp"` was absent
or empty). All 24 request-side models were audited against the ObjC originals; the remaining `??`
fallbacks are faithful — either ObjC substituted the same value explicitly (`ORTBPmp.deals`,
`ORTBBanner.format`), or the property is never encoded / is guarded by a non-empty check
(`ORTBPublisher.cat`, `ORTBApp.cat`/`sectioncat`/`pagecat`, `ORTBImpExtSkadn.skadnetids`).

**Parity harness was dead code.** `assertORTBParity` and `ORTBFixtures` had no callers, and the
doc comment claimed more than the assertion checked (it verifies Swift-internal encode/re-encode
idempotence, not ObjC equivalence). Comment corrected, and both are now exercised from
`ORTBAbstractTest`. Added `assertORTBNoResurrectedDefaults` plus partial-payload fixtures, which
is the only shape of test that can catch the class of bug above — a fully-populated round trip
cannot, because the resurrected default is stable across both encodes.

**`ORTBFormat` equality.** ObjC's `[self.w isEqual:other.w]` returns `NO` for two all-nil formats;
Swift's `nil == nil` is `true`, so `NSSet` dedup differs. Kept the Swift semantics — matching ObjC
requires a non-reflexive `isEqual:` — and documented why it's unreachable in production (the only
dedup callsite builds every element via `+ortbFormatWithSize:`). Codified as Gap S2.5-D.

**Weakened tests restored.**
- `PrebidEventDelegateTests`: replaced `assertForOverFulfill = false` with real isolation — the
  payloads are tagged per test instance so the delegate can ignore another test's in-flight
  response instead of silently tolerating a double-call from the code under test.
- `TestPBMFunctions`: the two `!error.localizedDescription.isEmpty` assertions now check the
  actual failure again (`NSCocoaErrorDomain` 3840 for malformed JSON; the `Invalid JSON data`
  message for a non-object top level).

**Tooling / docs.**
- Restored a scoped `.claude/` ignore block: shared agent config stays tracked, per-developer
  machine state (`settings.local.json`, `shell-snapshots/`, …) is ignored.
- Added a `command -v pod` guard to the four scripts that lost the CircleCI `gem install
  cocoapods` line, so a missing CocoaPods fails immediately with an actionable message rather
  than mid-script.
- `agents/review/SKILL.md`: three-dot `origin/master...HEAD` for `git diff` (two-dot shows
  commits landed on master after the branch was cut as spurious reversions), and the "tests not
  weakened" check now names the specific anti-patterns.
- Corrected the test-plan claim in `AGENTS.md` and the review skill: both `.xctestplan`s select by
  *exclusion* (`skippedTests`), so new test classes need no registration.
- Narrowed the playbook's flaky-test section to the single allowlisted test with an explicit
  three-point confirmation, replacing the general "re-run once and move on" framing.
- Collapsed `docs/migration/` to one PR doc: deleted the five superseded drafts
  (`pr-phase-0/1/1-review/2/2-description.md`), which described branches that no longer exist.

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build clean (device + simulator)
- [x] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build of the working tree clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 754 tests, 0 failures (727 + the three
      new `ORTBAbstractTest` methods, re-run after S2.6)
- [x] `PrebidEventDelegateTests` run separately — it is in the PR plan's `skippedTests`, so the
      retagged isolation fix was verified with `-testPlan PrebidMobileTests -only-testing`
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite (1111 tests), run before merge
- [ ] Reviewer: confirm gap decisions in `docs/migration/playbook.md`
