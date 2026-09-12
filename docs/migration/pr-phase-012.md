# [swift-migration] Phases 0–2 — Setup, ORTB request models, Utilities & extensions

Squashed `swift-migration-phase-0/1/2` into three commits on `master`, per the migration plan
(TaskNotes "[PI][PREBID] Develop a plan to migrate the iOS SDK to Swift"). Part of an ObjC → Swift
migration of `PrebidMobile/Objc/` (~119 `.m` + 152 `.h` across 9 phases); this PR lands the first three.

## Summary

### Phase 0 — Setup & tooling (no migration)

- **S0.1 — Functional-gap audit & playbook** (`docs/migration/playbook.md`): codified 5 gaps before
  any Swift twins were written (NSCopying, empty child-dict suppression, `ORTBFormat` isEqual/hash,
  `@objc NSObject` requirement, `init?` vs. broken-instance fallback).
- **S0.2 — Parity harness**: `ORTBParityHelper.swift` (`assertORTBParity`) + baseline fixtures.
- **S0.3 — Tooling hardening**: removed dead CircleCI provisioning (GHA `macos-15` only); hardened
  `testPrebidMobile.sh` (pre-deletes the simulator, scoped clean-build step); fixed a flaky
  `PrebidEventDelegateTests` crash; added `/build-sdk` skill, updated `/xcodebuild`; started
  tracking `CLAUDE.md`.

### Phase 1 — ORTB bid-request models (25 files)

Ports every ObjC `PBMORTB*` request-side model in dependency order: **S1.1** leaf models
(`ORTBFormat`, `ORTBPublisher`, `ORTBGeo`, `ORTBDeal`, `ORTBSourceExtOMID`, `ORTBImpExtSkadn`,
`ORTBDeviceExtAtts`); **S1.2** composite blocks (`ORTBBanner`, `ORTBVideo`, `ORTBPmp`,
`ORTBImpExtPrebid`, `ORTBImp`); **S1.3** top-level objects (`ORTBApp`, `ORTBAppExt(Prebid)`,
`ORTBDevice`, `ORTBDeviceExtPrebid(Interstitial)`, `ORTBUser`, `ORTBRegs`, `ORTBSource`,
`ORTBRendererConfig`); **S1.4** root container (`ORTBBidRequest`, `ORTBBidRequestExtPrebid`),
deleted `PBMORTBAbstract.m` (headers kept — still imported by Phase 3/4 ObjC builders).

Naming convention established: Swift class drops `PBM` (`ORTBFoo`), ObjC keeps seeing the original
name via `@objc(PBMORTBFoo)`. 10 gaps codified in the playbook (framework-build visibility,
explicit ObjC selector bridges, private-header invisibility, empty-array preservation, `dict`'s
`private(set)`, NSCopying via JSON round-trip, `NSMutableDictionary` decode, `PBMORTBAbstract`
deletion cascade).

### Phase 2 — Utilities & extensions (parallel-safe with Phase 1)

- **S2.1** — standalone utilities: `Functions` (+Testing), MRAID constants, `DeepLinkPlus`,
  `DeviceAccessManagerKeys`, `DownloadDataHelper`, `CircularProgressBar{Layer,View}`,
  `WKScriptMessageHandlerLeakAvoider`. Deferred: `PBMDeepLinkPlusHelper` (Phase 4),
  `PBMWindowLocker` (Phase 8). `PBMMRAIDConstants.m` partially remains (`NS_TYPED_ENUM` globals only).
- **S2.2** — Foundation/UIKit category extensions (`NSDictionary`, `NSMutableDictionary`,
  `NSString`, `NSURL`, `NSException`, `UIView`, `UIWindow` `+PBMExtensions`, `TouchDownRecognizer`,
  view-exposure trio).
- **S2.3** — `NSTimer` wrapper: `TimerInterface`, `NSTimer+PBMScheduledTimerFactory`,
  `WeakTimerTargetBox`; `NSInvocationOperation` → `NSObject.perform(_:with:)`.

13 gaps codified (S2.1-A..S2.3-C) — `@_spi` propagation, `dispatch_time()`/
`UIInterfaceOrientationIsPortrait()` replacements, `@objc(name:error:)` labels, `@dynamic` →
`@NSManaged`, ObjC protocol forward-declaration, Foundation-nil string bridging, header-reduction
fallout.

## What changed vs. the original phase branches

Rebased onto current `master`; two conflicts resolved as a union of intent: **`.gitignore`** kept
master's `EventHandlers/Package.resolved` entry, dropped the `CLAUDE.md`/`.claude/` ignore per
Phase 0. **`project.pbxproj`** kept Phase 1's two new `PBXBuildFile` entries (purely adjacent-line
positioning conflict).

## Review fixes (rounds S2.5–S2.8)

Three correctness blockers, all in Phase 2 utilities — invisible to the CI matrix at the time,
hence a new CI gate:

- **`DownloadDataHelper` — `[weak self]` broke the download.** ObjC captured `self` strongly (the
  only thing keeping the helper alive across a bare-local HEAD+GET). Restored the strong capture
  with a comment (Gap S2.5-B).
- **`Functions.dispatchTimeAfterTimeInterval` — mach ticks vs. nanoseconds.** Ran the incoming
  `dispatch_time_t` through `DispatchTime(uptimeNanoseconds:)`, double-scaling an already-tick
  value (~41x off on arm64 devices). Rewritten to branch on `DISPATCH_TIME_NOW`/`FOREVER` and
  convert explicitly via `mach_timebase_info`, with sign-branched saturating arithmetic and a
  clamped interval (playbook Gap S2.1-C corrected). 8 new tests in `TestFunctions`.
- **Three ObjC files stopped compiling under SwiftPM** (`PBMPrebidParameterBuilder.m`,
  `PBMCreativeViewabilityTracker.m`, `PBMAdViewManager.m`) — lost UIKit transitively through
  deleted headers; CocoaPods masks this, SwiftPM doesn't. Added explicit `#import <UIKit/UIKit.h>`
  (Gap S2.5-A). **New CI gate:** `scripts/buildPrebidMobilePackage.sh` (`build-spm-package` job) —
  compiles `__PrebidMobileInternal` directly against the working tree, unlike `buildPrebidSPM.sh`
  which builds the *published* package.

**ORTB decode parity (Gap S2.5-C).** Three ports used `json[.k] ?? default` instead of unconditional
assignment, inventing wire keys on re-encode: `ORTBDeal` (`bidfloor`, `bidfloorcur`, `wseat`,
`wadomain`), `ORTBImp` (`instl`, `clickbrowser`, `secure`), `ORTBBidRequest` (`imp` fell back to a
one-element default). All 24 request-side models audited; remaining `??` fallbacks confirmed
faithful. Added `assertORTBNoResurrectedDefaults` + partial-payload fixtures (a full round-trip
fixture can't catch this class of bug).

**`ORTBFormat` equality** — kept Swift's `nil == nil` semantics over ObjC's non-reflexive
`isEqual:`; documented why it's unreachable in production (Gap S2.5-D).

**Weakened tests restored:** `PrebidEventDelegateTests` isolation via per-instance tagging instead
of `assertForOverFulfill = false`; `TestPBMFunctions` re-asserts actual error content instead of
`!isEmpty`.

**`Functions.safeAreaInsets`/`statusBarHeight`** — resolved `UIApplication.shared` through the ObjC
runtime instead of reading it directly (crash class for host-less test bundles), routed through the
`Functions.application` test seam, and unified into one `resolvedApplication`/`sharedApplication`
pair (Gap S2.5-E). Added `pbmKeyWindow` to `PBMUIApplicationProtocol` (not `keyWindow` — deprecated,
undefined under multiple scenes). Three weak test assertions replaced with real ones
(`testSafeAreaInsetsUsesInjectedApplication`, `testSafeAreaInsetsWithoutKeyWindow`, exact-value
host-less test).

**Tooling:** `command -v pod` guard added to all four scripts; `set -e` added to
`testPrebidDemo.sh` (and the two siblings' latent `PIPESTATUS`-after-`set -e` bug fixed via
`|| TEST_STATUS=$?`); `.gitignore` gained `.claude/worktrees/`; `agents/xcodebuild/SKILL.md`
`dispatch_time` row repointed at `Functions.dispatchTimeAfterTimeInterval` (flagged `@_spi`-only
reachability); playbook flaky-test section narrowed to the single allowlisted test.

**Deferred:** the ~11 other `UIApplication.shared` call sites outside `Functions.swift` (enumerated
in Gap S2.5-E, fix when touched); memoizing `sharedApplication` (resolution is nil until
`UIApplicationMain` runs — caching adds a staleness hazard to save one selector lookup); factoring
the duplicated `command -v pod` guard into a shared script; redesigning
`PrebidEventDelegateTests` isolation by delegate identity instead of UUID tag.

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build clean (device + simulator)
- [x] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build of the working tree clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — **765 tests, 0 failures** (final, post-S2.8);
      only retry was the allowlisted flake `PBMBidRequesterTest.testBanner_300x250`
- [x] `PrebidEventDelegateTests` (in the PR plan's `skippedTests`) run separately via `-only-testing`
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite (1111 tests), run before merge
- [ ] Reviewer: confirm gap decisions in `docs/migration/playbook.md`
