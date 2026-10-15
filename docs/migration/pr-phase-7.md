# [swift-migration] Phase 7: HTML/MRAID creative cluster, factory chain

Suggested PR title: `[swift-migration] Phase 7: HTML/MRAID creative cluster, factory chain`

Branch `swift-migration-phase-7` on top of `master` (`7eefdd87`, after Phase 6 / #1385). Steps: **S7.1 – S7.4** (below). One PR, built by parallel agents in
separate worktrees and merged in dependency order (waves 1A, 1B, 2, 3, 4), with an independent review after waves 2 and 3.

## Scope boundary

Phase 7 ports everything the Phase 6 hand-off assigned to it. **Left in ObjC on purpose:**

| Left in ObjC | Why | Where it goes |
|--------------|-----|---------------|
| `PBMOpenMeasurementWrapper`, `PBMOpenMeasurementSession`, `PBMOpenMeasurementEventTracker`, `PBMOpenMeasurementFriendlyObstructionTypeBridge`, `OMSDKVersionProvider.m` | Phase 8 (OMSDK). Decision for this PR (option (a)): the creatives reach OMSDK only through the existing Swift `OMSession`/`OMSessionWrapper` protocols; the wrappers were not pulled forward and the group was not split | Phase 8 |
| `PBMCreativeViewabilityTracker.m`, `PBMMRAIDConstants.m`, `PBMDeferredModalState.m`, `Prebid+TestExtension.m` | not in the Phase 7 list: the tracker already has a Swift twin behind `Factory.swift`; `PBMMRAIDConstants` is the `NS_TYPED_ENUM` residue (S2.1-A); `PBMDeferredModalState` is dead code (cleanup list) | Phase 8/9, cleanup |

`.m` files under `PrebidMobile/Objc`: **25 → 9**. Orphan headers: **28 → 17**.

### The one seam this PR adds

`Factory.swift` resolves `PBMOpenMeasurementWrapper` by `NSClassFromString` and reads its `shared` selector as an `OMSessionWrapper`. It replaces the single ObjC line `PBMOpenMeasurementWrapper.shared` in `PBMTransaction.m`. The Swift target cannot name the ObjC class and no Swift accessor for the wrapper exists, so nothing narrower worked. This is exactly the throwaway-seam trade-off of playbook S4.5-B: it was accepted here because the alternative was pulling Phase 8 forward; it is marked for deletion in Phase 8.

## Steps

| Step | Contents | Why this order |
|------|----------|----------------|
| **S7.1** (waves 1A, 1B) | 1A: `WindowLocker`, `SafariVCOpener`, `DeepLinkPlusHelper` (+ five block-typedef headers retired). 1B: `MRAIDJavascriptCommands`, `MRAIDCommand`, `HTMLFormatter` | leaves. 1B's three were not in the hand-off list: the Swift target cannot see ObjC, and their only consumers (`WebView`, `MRAIDController`, `HTMLCreative`) move later, so they had to go first |
| **S7.2** (wave 2) | `WebView` (+ `WebViewState`), `MRAIDController`, `WebViewDelegate`, `ExposureChangeDelegate` | the web layer under the creatives; `MockPBMWebView` rewritten as a Swift subclass |
| **S7.3** (wave 3) | `AbstractCreativeImpl` (`@objc(PBMAbstractCreative_Objc)`), `HTMLCreative`, `VideoCreative` as one group; `PBMVastGlobals` and `PBMModalState.h` deleted | S6.1-A: a Swift base moves with all its ObjC subclasses. `VideoCreative` was the last ObjC user of `VideoView` |
| **S7.4** (wave 4) | `CreativeFactoryJob`, `CreativeFactory`, `TransactionImpl`; `Factory.TransactionType` and its `NSClassFromString("PBMTransaction_Objc")` lookup removed | last ObjC consumers (S4.3-B): each one's last ObjC dependency is the next one's port |

## Parity evidence

Throwaway ObjC dumps (printing `nil` and `""` differently) were captured **from the ObjC** before it was deleted, committed as literal expectations, and re-run against the Swift port (playbook S6.x-G-A). ObjC and Swift share the bridged name, so they cannot coexist in one build: the ObjC output was frozen first.

| Test | Inputs | Result |
|------|--------|--------|
| `MRAIDParityTests` (`MRAIDJavascriptCommands`, `MRAIDCommand`, `HTMLFormatter`) | 348 comparable lines: 48 MRAID URLs, 37 HTML strings, 150 numeric formatting cases (NaN, ±inf, -0.0, rounding ties) | byte-identical |
| `WebViewParityTests` (`isMRAIDLink`, `commandFromURL`, `CGRectForResizeProperties`, `anyToJSONDict`, mraid env JS) | 431 lines + 50 JS property probes. Resize results assume a 402x874 pt screen; the test skips elsewhere | identical after one fix (`isMRAIDLink` used the grapheme-aware `String.hasPrefix`, S7.2-A) |
| `CreativeParityTests` (`hasVastTag`, `calculateCloseDelay`, reward/post-reward time) | 589 lines (270 close-delay, 289 reward-time, 30 `hasVastTag`/misc). Captured first as 9,928 lines (full cross product, byte-identical on the first run), then cut to boundary values per parameter: nil, 0, a normal value, negative, NaN, infinity | identical (the 589 lines are an unchanged subset of the ObjC capture) |
| `CreativeFactoryParityTests` (timeout selection, transaction navigation, `updateAdConfiguration`) | 160 lines | identical |

The stateful parts (WKWebView, modals, timers, resolution queues, KVO) are covered by the existing suites (`PBMWebViewTest`, `PBMMRAIDControllerTest`, `PBMHTMLCreativeTest*`, `PBMVideoCreativeTest`, `PBMCreativeFactoryJobTest`, `TransactionTests`, `AdViewManagerTest`, …), all green. Cases where the ObjC **crashed** cannot be in a dump; they are marked "forced" below.

## Review findings fixed in this PR

An independent read-only reviewer, given only the diff, found two real bugs after wave 2; both are fixed (commit `0000696c`):
- `AbstractCreative.dismissInterstitialModalState` was declared non-optional while the ObjC conformer left it `nullable`: `mraid.close()`/`unload()` on an interstitial before the modal was pushed would have called a null block. Now `VoidBlock?` (S7.3-A).
- `SafariVCOpener.modalManager` was non-optional while `PBMAbstractCreative.m` passes a property that is nil until `onTransactionIsReady`. Now Optional.

The wave-3 review found no confirmed crash, selector mismatch or nil trap.

## Behavior deviations (reviewer: please read)

Swift types forbid the ObjC behavior, or the ObjC behavior was a crash or nil-messaging accident. Full per-site tables are in the agents' notes (deleted with this doc's final commit; the rows below are the ones that can change observable behavior). "Verified" means the ObjC was run.

| # | Site | ObjC | Swift | Status |
|---|------|------|-------|--------|
| 1 | `HTMLCreative.webView(_:receivedMRAIDLink:)` and `SafariVCOpener.openClickthrough` | `@try/@catch (NSException)`: UIKit/WebKit exceptions (e.g. "present modally an active controller") were logged and swallowed | not ported: Swift cannot catch ObjC exceptions. `MRAIDController`'s own 14 `NSException` throws became a Swift `throws` with unchanged messages | **forced**; a UIKit exception from an MRAID command that arrives mid-presentation would now crash instead of logging. Flagged by review, not mitigated (no ObjC shim added). Follow-up: #1403 |
| 2 | `mraid.expand/resize` properties with a non-number/non-string value (`null`, `{}`, `[1]`) | `-integerValue`/`-boolValue` on `NSNull`/`NSDictionary`/`NSArray`: unrecognized-selector crash. **Verified: 7 of 7 probes crashed** | value rejected like a missing key; completion gets `nil` | **forced**, strictly safer; creative-controlled input |
| 3 | `MRAIDCommand` with the scheme not at index 0 (`" mraid:open"`, `"http://a/mraid:expand"`) | `PBMsubstringFromString` ran past the end: `NSInvalidArgumentException` (4/4), caught and logged by the controller | throws "URL does not contain MRAID scheme", controller logs a warning | **forced**; message text differs. Exposes an existing off-by-length bug in `NSString.PBMsubstringFromString` (nothing calls it now) |
| 4 | `HTMLFormatter.ensureHTMLHasBodyAndHTMLTags(nil)` | `NSRegularExpression` raised on nil | non-optional parameter | unreachable: the only caller returns early on nil HTML |
| 5 | `CGRectForResizeProperties` integer arithmetic | `(NSInteger)` saturates, `+` wraps | `saturatingInteger` + `&+` | in the dump (216 lines incl. `Int.min`/`Int.max` offsets); Swift `Int(_:)`/`+` would trap |
| 6 | OMSDK gate in `HTMLCreative`/`VideoCreative` | `[x isKindOfClass:[PBMOpenMeasurementSession class]]` | non-nil check on the session obtained through `OMSession` | equivalent in production (the only producer is `PBMOpenMeasurementWrapper`); any other `OMSession` conformer now passes. Test mocks subclass the ObjC session, so they pass both. `Transaction.measurementSession` became `OMSession?` |
| 7 | `AbstractCreative.modalManagerDidFinishPop/LeaveApp` | `SafariVCOpener` could pass nil | parameter is `ModalState?` | same |
| 8 | `MRAIDController` expand/resize when the presenting view controller is gone between the command and its async callback | passed nil into `pushModal:` and carried on | logs and returns before the later state updates | **forced** (non-optional parameter); only reachable if the weak controller is freed in that window. Flagged by review |
| 9 | Display timer / creative-factory timeout with a NaN delay | `dispatch_time(NOW, (int64_t)NaN)` = fires now | `.now() + NaN` would mean "never"; NaN mapped to 0 | **reasoned from the C cast, not run against the ObjC**. inf, huge and negative were probed in Swift (S7.4-D) |
| 10 | Reward times | `-intValue` wraps at 32 bits | `int32Value` | verified by probe |
| 11 | `NSURL(string: "")` for `targetURL`/`clickThroughURL`/`videoFileURL`/creative-factory URLs | valid empty URL | `NSURL(string:)` kept (`URL(string: "")` is nil) | verified by probe |
| 12 | `SafariVCOpener`, no `UIApplication` | `[UIApplication sharedApplication]` nil → exit block | `Functions.resolvedApplication`, then an opener that only runs the exit block | read from the ObjC, **not run** |
| 13 | `MRAIDController` long init (`deviceAccessManagerClass:`, `sdkConfiguration:`) | stored, never read | not ported | dead |
| 14 | `deepLinkPlusHandlerWithExternalLinkHandler:`, `initWithCoder:` on `PBMWebView` | no callers; `initWithCoder:` returned a web-view-less view | not ported; `initWithCoder:` returns nil | dead / measured |
| 15 | `getCreativeAfter:`/`revenueForCreativeAfter:` with `nil`; `CreativeFactoryJob` nil model | tolerated nil | non-optional | unreachable: Swift callers guard first, no ObjC caller survives |
| 16 | `@available(iOS 13/14/14.5)` branches | present | dropped | deployment target is iOS 15 |
| 17 | Logging | `PBMLog*`/`PBMAssert` macros | `Log.*` | message text identical, file/function prefix differs |

`@weakify`/`@strongify` → `[weak self]` only where the ObjC used them; strong captures are commented (playbook S2.5-B).

## `@_spi` / visibility

New SDK types are `@objc(PBMFoo) @_spi(PBMInternal) public` (Gap 6), except `TransactionImpl` and the factory/job (internal, no `@objc` name: nothing looks them up, S6.x-J-C). `WebView`, `MRAIDController` and the three creatives keep their `@objc(PBM…)` names for runtime-name stability (S6.x-J-D); demotion belongs to S9.2.

## Files

- **Deleted:** 42 ObjC `.m`/`.h` files under `PrebidMobile/Objc` (16 `.m`, 26 headers), plus 9 test-side files (eight `+…TestExtension` headers/files and `PBMMRAIDControllerObjCTest.m`).
- **Added:** 15 Swift files under `PrebidMobile/Swift/PrebidMobileRendering/` and 8 test files (four parity tests with their expectations).
- **`project.pbxproj`:** edited only through the `xcodeproj` gem; merge conflicts (additive) resolved by keeping both sides and re-stripping deleted entries by name; after every merge: `plutil -lint` OK, no dangling build files, no references to missing files other than the product/SDK refs, one ref and one Sources entry per new Swift file.
- **Test bridging header:** every ported header import removed.
- **`PrebidMobilePRTests.xctestplan`:** two `PBMMRAIDControllerObjCTest` skip entries removed (the class is gone).
- **`Factory.swift`:** `TransactionType` and its lookup removed; one new lookup for the OMSDK wrapper (above).

## Open items for the reviewer

- **Dropped `@try/@catch`** (deviation 1; follow-up investigation: #1403) and the early return in expand/resize (deviation 8).
- **`CreativeParityExpectations.swift` was trimmed from about 9,900 to about 590 lines** after review feedback. The full cross product matched the ObjC on the first run; the committed subset keeps the boundary values per parameter. The trimmed file was re-run (`CreativeParityTests.testParity` passes), but the cut is a filter of the original ObjC capture, so it checks fewer combinations than the first run did.
- **`WebViewParityTests` takes about 17 s** (15 s of it one JavaScript-property test) and runs on every PR; the resize expectations skip on screens other than 402x874 pt.
- `WebView_Protocol` now has one conformer; the two `as? WebView_Protocol` casts and the protocol can go (cleanup, not done here).
- SwiftLint: `type_body_length` warnings on the new large classes, carried `TODO`s, trailing whitespace carried from the originals, and the existing `type_name` error on `WebView_Protocol`.
- `NSMutableArray` retyping in the VAST models (S6.1-B) is still open.

## Test plan

- [x] `buildPrebidMobile.sh` — all 4 XCFrameworks built; "All 24 Swift interfaces typecheck" (Gap 6 check)
- [x] `buildPrebidMobilePackage.sh` — SwiftPM package build succeeded (also after every merged wave; this is the check that catches lost transitive imports, S7.1-D)
- [ ] `verifySPM.sh` — **not run**: documented as CI-only. Needs CI
- [ ] `buildPrebidSPM.sh` — **not run**: it builds the *published* packages, so it would not exercise this branch
- [x] `plutil -lint` on `project.pbxproj` + `xcodeproj` gem check — OK after every merge
- [x] `testPrebidMobile.sh --latest --quick` — baseline on `master`-equivalent tree 990 tests, 0 failures; after wave 2: **first run failed** (2 network-wait tests, `PrebidServerStatusRequesterTests.testRequestStatus_Success` and `PrebidTest.testInitializeSDK`, each timed out on all 3 retries; the endpoint answered HTTP 200 in 0.7 s from this machine and both classes passed alone, 29 tests), **second run 996 tests, 0 failures**; after wave 3: 997 tests, 0 failures. Neither test is on the flaky allowlist (the first also timed out once in Phase 5), so this is reported as an unexplained flake, not dismissed
- [x] `testPrebidMobile.sh --latest` (full, final tree) — **1408 tests, 0 failures**, no retries (Phase 6 ended at 1385)
- [x] `testPrebidMobileAdapters.sh` — exit 0. GAM (17 tests) and AdMob (5 tests) passed; the MAX scheme ran **0 tests** (no test sources on `master` either)
- [x] Parity tests (`MRAIDParityTests`, `WebViewParityTests`, `CreativeParityTests`, `CreativeFactoryParityTests`) — Swift output matches the ObjC's captured output
- [x] `swiftlint` on every new file — 0 serious violations in new code; warnings listed under Open items
- [ ] **Manual check in the demo app — not done.** No HTML banner, MRAID expand/resize/close, interstitial, rewarded video or VAST video was run on a device or in the demo app; `WebView` (WKWebView, KVO, JS injection), the creatives and `VideoView` are covered by unit tests and line-by-line review only. **Recommended before merge.** The UI tests (`PrebidMRAIDResizeUITest`) were not run
- [ ] Deviations 9 (NaN timers) and 12 (no `UIApplication`) were reasoned from the ObjC, not run against it
