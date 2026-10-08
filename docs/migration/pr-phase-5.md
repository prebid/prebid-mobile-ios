# [swift-migration] Phase 5 (reduced): InterstitialLayoutConfigurator, ModalState, AdViewManager

Suggested PR title: `[swift-migration] Phase 5 (reduced): InterstitialLayoutConfigurator, ModalState, AdViewManager`

Branch on top of `master` (`e60618c2`). Steps: **S5.0 + S5.1 + S5.2 (this)**.

## Scope boundary

Phase 5 is **intentionally reduced to three files**. The plan's Phase 5 file list was stale
(playbook **S5.x-scope**); re-measured, only three of the 17 remaining `.m` files had all-Swift-visible
dependencies:

| Step | File | Status |
|------|------|--------|
| **S5.0** (added to the plan) | `PBMInterstitialLayoutConfigurator.{h,m}` | **ported** — a surviving caller (`PBMAdViewManager.m`) needed it first, so it had to go before S5.2 |
| **S5.1** (reduced to ModalState) | `PBMModalState.m` | **ported** |
| **S5.2** | `PBMAdViewManager.m` | **ported** |
| — | `PBMDeferredModalState.m` | **untouched on purpose** — dead code, goes on the post-migration cleanup list |

Everything else from the original Phase 5 is deferred, and the reason is not "ran out of time":

| Files | Re-assigned to | Why |
|-------|----------------|-----|
| VAST cluster, `PBMAdLoadManagerBase`/`PBMAdLoadManagerVAST`, `PBMVideoCreative`, `PBMVideoView` | Phase 6 | `PBMAdLoadManagerBase` alone needs the two ObjC protocols (`PBMAdLoadManagerProtocol`/`Delegate`) moved to Swift `@objc` protocols, which rewrites `MockPBMAdLoadManagerVAST` and `PBMAdLoadManager+pbmTestExtension.h`, and does not unblock `PBMVastTransactionFactory`/`PBMTransactionFactory_Objc` |
| `PBMWebView`, `PBMMRAIDController`, `PBMMRAIDJavascriptCommands`, `PBMAbstractCreative` | Phase 7 | blocked: `PBMAbstractCreative` is subclassed by `PBMHTMLCreative`/`PBMVideoCreative`, and imports `PBMSafariVCOpener`/OMSDK |
| `PBMCreativeFactoryJob` | after `HTMLCreative`/`VideoCreative` exist, then `CreativeFactory`, then `Transaction` | chain of last-ObjC-dependency |

Do not ask to complete these here; see playbook "Phase 5 gaps".

## S5.0 — `PBMInterstitialLayoutConfigurator`

| File | Non-test consumers |
|------|---------------------|
| `PBMInterstitialLayoutConfigurator.m` + `PrivateHeaders/PBMInterstitialLayoutConfigurator.h` | `PBMAdViewManager.m` (ported in S5.2; now called from Swift) |

`InterstitialLayoutConfigurator.swift`: `@objc(PBMInterstitialLayoutConfigurator) @_spi(PBMInternal) public class`
with four static methods, each with an explicit `@objc(selector:)` (playbook **S5.0-A**).
`layout && layout != Undefined` → `layout != .undefined` (undefined is raw value 0). `NSSet<NSValue *>` → `Set<CGSize>`.
No ObjC caller remains after S5.2, so the `@objc` bridge names are only kept for runtime-name stability.

Test: `PBMInterstitialLayoutConfiguratorTest.swift` renamed references to `InterstitialLayoutConfigurator` and
switched to `@_spi(PBMInternal) @testable import`. Test bridging header: dropped the `PBMInterstitialLayoutConfigurator.h` import.

## S5.1 — `PBMModalState`

`ModalStateImpl.swift`: `@objc(PBMModalState_Objc) @_spi(PBMInternal) public class ModalStateImpl: NSObject, ModalState`.
`Factory.swift`'s `NSClassFromString("PBMModalState_Objc")` is unchanged and resolves to it.

- `isRotationEnabled`: ObjC checked `[lastView isKindOfClass:[PBMWebView class]]`. `PBMWebView` is not visible to Swift, so
  the check is `as? WebView_Protocol`, and `rotationEnabled` was added to `WebView_Protocol` as
  `@objc(isRotationEnabled) var rotationEnabled: Bool { get }` (ObjC property uses `getter=isRotationEnabled`). Playbook **S5.1-A**.
- Handler properties were `copy` in ObjC; Swift closures are values, so no explicit copy is needed.
- `PBMModalState.h` (two block typedefs) **kept**: seven ObjC files still import it.

## S5.2 — `PBMAdViewManager`

`AdViewManagerImpl.swift`: `@objc(PBMAdViewManager_Objc) @_spi(PBMInternal) public class AdViewManagerImpl: NSObject, AdViewManager`.
`Factory.swift`'s `NSClassFromString("PBMAdViewManager_Objc")` is unchanged. `@weakify/@strongify` → `[weak self]` + `guard let self`
(the ObjC original used `@weakify`, so this is faithful). The `.m` no longer imports `PBMAdLoadManagerProtocol.h`/`PBMAdLoadManagerDelegate.h`.

### Behavior deviations (Swift types forbid the ObjC behavior or it was a nil-messaging accident)

| # | Site | ObjC | Swift | Status |
|---|------|------|-------|--------|
| 1 | `onTransactionIsReady`, `adLoaded` with no `adDetails` | passed `nil` to `adLoaded:` | `adLoaded(_:)` takes a non-optional `AdDetails`; falls back to `AdDetails(rawResponse: "", transactionId: "")` so the callback still fires | **forced** (S5.2-A). Nothing sets `adDetails` on the model today, so this path is the common one — dropping the call would hang every load |
| 2 | `show()`, interstitial with `interstitialDisplayProperties == nil` | carried on with `nil` properties: `configureProperties` was a no-op on nil, `interstitialLayout` read as 0, and `showAsInterstitial:displayProperties:nil` was sent | logs an error and returns | **forced**: `InterstitialDisplayProperties` is non-optional in `configureProperties`/`showAsInterstitial`, so ObjC's continue-with-nil cannot be reproduced. Only reachable if a delegate returns nil from an optional protocol member; all in-repo delegates return a new object |
| 3 | `setupCreative`, `creative.creativeModel.adConfiguration == nil` | assigned nil into the nonnull `adConfiguration` | keeps the previous `adConfiguration` | **forced**: `AdViewManager.adConfiguration` is non-optional, so nil cannot be stored. Not reachable today: `CreativeModel.adConfiguration` is set for every creative the transaction factories build. Consequence if it ever happened: stale configuration instead of ObjC's nil-messaging defaults |
| 4 | `init` | `PBMAssert(connection)` | dropped | **forced**: non-optional `connection` makes it unreachable (S3.1-H: measured, no ObjC caller of `initWithConnection:`) |
| 5 | `creativeFullScreenDidFinish` with no modal view controller | `displayWithRootViewController:nil` | skips `display(rootViewController:)` | **forced**: `display(rootViewController:)` takes a non-optional `UIViewController` |
| 6 | `onTransactionIsReady`, `getFirstCreative()` is nil | `setupCreative:nil` → `autoDisplayOnLoad = !nil.isInterstitialAd = YES`, `adConfiguration = nil`, then `show` logs "No creative to display" | replays `autoDisplayOnLoad = true; show()` (found in review; the first port silently skipped the whole branch) | observable effects reproduced (**S5.2-C**) |
| 7 | `revenueForNextCreative` | `[currentTransaction revenueForCreativeAfter:currentCreative]` (nil-tolerant on both) | `guard`s, delegating to `revenueForCreative(after:)` when a creative exists and, when there is none, `getFirstCreative()?.creativeModel.revenue` | equivalent: ObjC `revenueForCreativeAfter:nil` → `getCreativeAfter:nil` → first creative, falling back to the passed creative (nil) |

Items 2, 3 and 5 were reviewed for a non-deviating alternative; none exists without changing the `AbstractCreative`/`AdViewManager` protocol
signatures, which is out of scope for a line-for-line port.

### `#if DEBUG` members

`AdViewManager` declares `currentCreative`, `externalTransaction` and both `setupCreative` overloads under `#if DEBUG`.
`AdViewManagerImpl` implements them unconditionally and `public`, so a Release/framework build still exposes them (`@_spi`-scoped, not
visible to SDK clients). Playbook **S5.2-B**; clean-up with the S9.2 visibility demotions. `buildPrebidMobile.sh` (Release archives) passes.

## Files deleted (4)

`PBMInterstitialLayoutConfigurator.m`, `PrivateHeaders/PBMInterstitialLayoutConfigurator.h`, `Modals/PBMModalState.m`, `AdView/PBMAdViewManager.m`
`PBMModalState.h` is **kept** (seven ObjC importers).

`project.pbxproj`: −4 ObjC build-file refs, −4 ObjC file refs (+ group entries), +3 Swift refs
(`InterstitialLayoutConfigurator.swift`, `AdViewManagerImpl.swift`, `ModalStateImpl.swift`), −1 header from the Headers phase.
`plutil -lint`: OK.

Orphan-header count: 35 → **36** (`PBMModalState.h` is now header-only; `PBMInterstitialLayoutConfigurator.h` went with its `.m`). Table updated.

## Open items for the reviewer

- `AdViewManagerImpl.swift`: SwiftLint `type_body_length` warning (248 > 100 lines) and three `todo` warnings (copied ObjC `TODO`s). Left as warnings, same as `BidRequesterImpl`.
- `WebView.swift`: a pre-existing SwiftLint `type_name` **error** on `WebView_Protocol` (underscore) is reported when linting that file;
  it is the existing protocol name and is bridged as `PBMWebView_Protocol`, so not renamed here.
- `PBMInterstitialLayoutConfiguratorTest.swift` has trailing-whitespace warnings carried over from the original file.
- Behavior deviations 1–7 above, in particular #2 (nil display properties) and #6.
- `PBMDeferredModalState` is dead code and deliberately untouched (playbook "Post-migration cleanup list").

## Test plan

- [x] `buildPrebidMobile.sh` (clean DerivedData) — all 4 XCFrameworks built; "All 24 Swift interfaces typecheck" (Gap 6 check)
- [x] `buildPrebidMobilePackage.sh` — SwiftPM package build succeeded
- [x] `buildPrebidSPM.sh` — succeeded, **but it builds the published 3.4.0 packages, so it does not exercise this branch**
- [ ] `verifySPM.sh` — **not run**: documented as CI-only (records SwiftPM fingerprints against a local commit of the current version). Needs CI
- [x] `plutil -lint` on `project.pbxproj` — OK
- [x] `swiftlint` on the 3 new files, `WebView.swift`, and the touched test — 0 errors in new code; warnings: `type_body_length` + 3 `todo` on `AdViewManagerImpl`, trailing whitespace in the test (pre-existing: 12 lines in HEAD). `WebView.swift` shows the pre-existing `type_name` error on `WebView_Protocol` (not introduced here)
- [x] `testPrebidMobile.sh --latest --quick` (clean DerivedData) — 967 tests, 0 failures after retry. `PrebidServerStatusRequesterTests.testRequestStatus_Success` timed out once and passed on retry: it makes a live HTTPS call to `prebid-server-test-j.prebid.org` and this PR touches nothing in that path. Not on the playbook's flaky allowlist; noted, not added
- [x] Full-plan-only classes with `-only-testing` (ModalManagerTest*, ModalViewControllerTest, ModalPresentationControllerTest, PBMAbstractCreativeTest, PBMHTMLCreativeTest + `_*` variants, VideoCreativeDelegateTest, AdViewManagerTest, BaseInterstitialAdUnitTest, PBMInterstitialLayoutConfiguratorTest) — 138 tests, 0 failures
- [x] `testPrebidMobile.sh --latest` (full) — 1378 tests, 0 failures
- [x] `testPrebidMobileAdapters.sh` — exit 0. GAM and AdMob suites passed; the MAX scheme ran **0 tests** (`PrebidMobileMAXAdaptersTests` has no test sources on `master` either, so this is not caused by this PR)
