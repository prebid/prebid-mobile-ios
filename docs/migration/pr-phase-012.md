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

## S2.7 — Review fixes (round 3)

- **`Functions.safeAreaInsets`** read `UIApplication.shared.keyWindow` directly — the crash class the
  previous round closed in `attemptToOpen`/`statusBarHeight`, and reachable from production via
  `deviceMaxSize` → `PBMMRAIDController`/`PBMWebView`. Now resolved through the ObjC runtime.
  `Functions.swift` no longer reads `UIApplication.shared` anywhere. New playbook Gap S2.5-E.
  (Incomplete — the resolution skipped the `Functions.application` seam; closed in round 4.)
- **`Functions.statusBarHeight`** consulted only `sharedApplication`, bypassing the
  `Functions.application` test seam. Now `Functions.application ?? sharedApplication`, matching
  `attemptToOpen`, pinned by `testStatusBarHeightUsesInjectedApplication`.
- **`dispatchTimeAfterTimeInterval(_:startTime:)`** — three edge-case defects in the branch this PR
  added: a negative interval wrapped to near-`UInt64.max` ("almost forever") instead of a past
  deadline; `Int64(seconds * NSEC_PER_SEC)` trapped on `.nan`/`.infinity`; and `nanoseconds * denom`
  could overflow before the division on a 125/3 timebase. Now sign-branched with saturating
  arithmetic and a clamped interval. `mach_timebase_info` is resolved once into a `static let`.
- **Coverage for that branch**, which had none: the only 2-arg test lives in `PBMFunctionsPrivateTest`,
  a class the PR plan skips entirely. Eight tests added to `TestFunctions` (in the PR plan) covering
  the tick round trip, negative/underflow, the `FOREVER` sentinel and non-finite saturation.
- **`ORTBBidRequest` `imp` decoding** — the lenient `compactMap` is intentional (ObjC's unchecked
  `NSArray<NSDictionary *> *` cast corrupted the whole array on one bad element); now documented as a
  deliberate divergence and pinned by `testDecodingRequestWithMalformedImpElements` with a new
  mixed-type fixture.
- **`agents/xcodebuild/SKILL.md`** still mapped the `'dispatch_time' has been replaced` error to the
  `DispatchTime(uptimeNanoseconds:)` pattern the playbook labels "WRONG — do not use", which would
  have led a contributor straight back into the ~41x arm64 bug. Row now points at
  `Functions.dispatchTimeAfterTimeInterval`.
- **Playbook Gap S2.1-C** reference implementation refreshed — it still showed the superseded
  `&+ UInt64(bitPattern:)` default branch — plus the signed-arithmetic and saturation rules.
- **`scripts/testPrebidDemo.sh`** was the only one of the four scripts without `set -e`, so a failed
  `pod install` fell through into `xcodebuild` against a partial Pods checkout. Added, matching the
  siblings' plain `set -e` (not `-euo pipefail`, which would break the unguarded `"$1"` check).
- **`.gitignore`** — added `.claude/worktrees/`, per-developer state the scoped list missed.
- **Test-count arithmetic** in this doc corrected against a measured run.
- **Deferred — the remaining `UIApplication.shared` reads.** All pre-existing and outside this PR's
  diff. Enumerated in playbook Gap S2.5-E with a re-measure command, to be fixed when those files
  are touched. Closing them here would widen an already large PR.
- **Declined — memoizing `sharedApplication`.** The resolution is `nil` until `UIApplicationMain`
  runs, so a cache must be mutable and non-nil-only, adding a staleness hazard and a
  shared-mutable-state race to save one selector lookup plus an `objc_msgSend`. The
  `mach_timebase_info` caching in the same review round *was* applied: that value is an immutable
  hardware constant, so it carries none of the same risk.
- **Deferred — factoring the duplicated `command -v pod` guard** into a shared sourced script. A
  real improvement, but it touches all four scripts and the CI paths that call them; better as its
  own PR than bundled into a migration PR.
- **Deferred — redesigning `PrebidEventDelegateTests` isolation** to filter by delegate identity
  instead of the UUID tag. Agreed it is less machinery, but the current mechanism is tested and
  working, and the class is skipped in the PR plan, so a rewrite would be verified only in the full
  suite.

## S2.8 — Review fixes (round 4)

Round 3's own fixes, reviewed. The theme: a rule applied to three call sites but not expressed in
one place drifts at the site nobody looked at twice.

- **`safeAreaInsets` still bypassed the injection seam** — the defect round 3 claimed to have
  closed. It resolved the application through the ObjC runtime (so it no longer trapped host-less)
  but read `Functions.application` nowhere, because `PBMUIApplicationProtocol` had no way to
  express a key window. A test setting `Functions.application` saw the mock in `statusBarHeight`
  and the real singleton in `safeAreaInsets` — and `deviceMaxSize` mixes both. Added
  `pbmKeyWindow` to the protocol, implemented on `UIApplication` via `connectedScenes`. Named
  `pbmKeyWindow`, not `keyWindow`: the latter would bind the conformance to the property
  deprecated since iOS 13, whose result is undefined under multiple scenes — the case that matters
  for an SDK rendering inside a host app's window.
- **One resolution point instead of three.** `resolvedUIApplication` and `sharedApplication` were
  two accessors performing the same runtime lookup with duplicated doc comments, and each call
  site re-spelled the `Functions.application ?? …` precedence. Collapsed to a single
  `sharedApplication` plus `resolvedApplication`, which every call site now reads. That is also
  the efficiency fix: `deviceMaxSize` resolves once and passes the application into
  `safeAreaInsets(application:)` and `statusBarHeight(application:)` rather than paying the
  lookup twice on the viewability path.
- **Three weak assertions in `TestPBMFunctions`.** `testSafeAreaInsetsWithoutApplicationHost`
  asserted `insets.top >= 0`, which `.zero` satisfies — i.e. the test passed *because of* the bug
  above. Replaced with `testSafeAreaInsetsUsesInjectedApplication` (a `MockKeyWindow` with
  dictated insets, asserted through both `safeAreaInsets` and `deviceMaxSize`),
  `testSafeAreaInsetsWithoutKeyWindow`, and a host-less test that now pins the exact `.zero` /
  `deviceScreenSize` values. The non-finite dispatch-time assertions checked only `!= 0` and
  `> startTime`, both of which a wrapping `&*` in the tick conversion would also satisfy; they now
  assert the deadline lands more than a century out (a floor expressed through `DispatchTime`, so
  it holds on any `mach_timebase_info` rather than only the simulator's 1:1), and the
  `DISPATCH_TIME_NOW` NaN case is bracketed by a `now` window taken before and after the call.
- **Playbook Gap S2.5-E** corrected: the literal re-measure command returned 11 files / 17 matches,
  not the 10 / 15 claimed, because `Functions.swift` names the API twice in prose. The count is now
  stated net of comments, and the gap gained the "one resolution point" and "route every
  application-derived read through the protocol" rules that round 3 followed only partially. A CI
  ratchet over those counts was prototyped and dropped: during an active migration the per-file
  budget needs an edit on every conversion, which redlights CI on good changes for a rule that
  belongs in SwiftLint `custom_rules` once SwiftLint is actually wired into a workflow
  (`scripts/swiftLint.sh` still pins 0.31.0 and is invoked by nobody).
- **`agents/xcodebuild/SKILL.md`**: the `dispatch_time` row points at `Functions`, which is
  `@_spi(PBMInternal)` and therefore unreachable from another module. Added the caveat, and noted
  that the remaining raw `dispatch_time()` calls in the ObjC sample app are correct as written —
  the Gap S2.1-C hazard is the Swift-side misconversion, not the C function.
- **Dead failure diagnostics under `set -e`.** Round 3 added `set -e` to `testPrebidDemo.sh`,
  which made its trailing `if [[ ${PIPESTATUS[0]} == 0 ]]` report unreachable. Fixed there and in
  the two siblings that had the same latent pattern before this PR (`testPrebidMobile.sh`,
  `testPrebidMobileAdapters.sh`): the status is captured with `|| TEST_STATUS=$?`. In
  `testPrebidMobileAdapters.sh` that also required an explicit `|| return $?` after
  `build-for-testing`, since invoking the function in a `||` list suspends `set -e` inside it.

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build clean (device + simulator)
- [x] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build of the working tree clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — **765 tests, 0 failures**, re-run after the
      S2.8 round. S2.7 took the count to 763 by adding 9 (eight dispatch-time / application-seam
      tests in `TestFunctions` plus `ORTBAbstractTest.testDecodingRequestWithMalformedImpElements`;
      the earlier "754 (727 + three new)" note was arithmetically wrong). S2.8 nets +2: the weak
      `testSafeAreaInsetsWithoutApplicationHost` is replaced by three real ones. The only retried
      test was the allowlisted flake `PBMBidRequesterTest.testBanner_300x250` (green on retry 2)
- [x] `PrebidEventDelegateTests` run separately — it is in the PR plan's `skippedTests`, so the
      retagged isolation fix was verified with `-testPlan PrebidMobileTests -only-testing`
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite (1111 tests), run before merge
- [ ] Reviewer: confirm gap decisions in `docs/migration/playbook.md`
