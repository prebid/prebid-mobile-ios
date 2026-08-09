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

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build clean (device + simulator)
- [x] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build of the working tree clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 727 tests, 0 failures
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite (1111 tests), run before merge
- [ ] Reviewer: confirm gap decisions in `docs/migration/playbook.md`
