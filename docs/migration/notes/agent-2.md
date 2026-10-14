# Agent 2 notes (Phase 7): PBMWebView, PBMMRAIDController, PBMWebViewDelegate, PBMExposureChangeDelegate

## Files

Ported to Swift, ObjC deleted:

| Swift | Deleted ObjC |
|-------|--------------|
| `PrebidMobile/Swift/PrebidMobileRendering/AdTypes/AdView/WebView.swift` (holds `WebView`, `WebViewState`, `JSEvaluatingBlock`, and the existing `WebView_Protocol`) | `AdTypes/AdView/PBMWebView.m`, `PrivateHeaders/PBMWebView.h`, `PrivateHeaders/PBMWebView+Internal.h` |
| `.../AdTypes/AdView/MRAIDController.swift` | `AdTypes/AdView/PBMMRAIDController.m`, `PrivateHeaders/PBMMRAIDController.h` |
| `.../AdTypes/AdView/WebViewDelegate.swift` (`@objc(PBMWebViewDelegate)` protocol) | `PrivateHeaders/PBMWebViewDelegate.h` |
| `.../AdTypes/AdView/ExposureChangeDelegate.swift` (`@objc(PBMExposureChangeDelegate)` protocol) | `PrivateHeaders/PBMExposureChangeDelegate.h` |

Test side deleted: `PBMWebView+PBMTestExtension.h`, `PBMMRAIDController+pbmTestExtension.h` (S3.1-C, members are `internal` + `@testable`, nothing was widened), `PBMMRAIDControllerObjCTest.m`
(its only test, `testCommandWithBadParams`, is now a Swift test in `PBMMRAIDControllerTest`). Five bridging-header imports removed (`PBMWebView.h`, `PBMWebViewDelegate.h`, `PBMMRAIDController.h`, and the two test-extension headers).

Class names: `WebView` and `MRAIDController`. Checked for collisions first: SwiftUI's `WebView` (iOS 26 `_WebKit_SwiftUI`) is not imported anywhere in the SDK or tests, and no other `WebView` exists in `PrebidMobile` or `EventHandlers`, so S3.3-A did not apply.
Both are `@objc(PBMFoo) @_spi(PBMInternal) public` (Gap 6). `WebView` is non-final (`MockPBMWebView` subclasses it); the mock stayed an ordinary internal class and built without the `fileprivate` workaround of S3.1-E because `WebView` is `@objc public`.

Surviving ObjC consumer: `PBMHTMLCreative.m` only (the others the brief listed, `PBMAbstractCreative.m` and `PBMVideoCreative.m`, never touched these types; checked with `rg`). It keeps compiling through `SwiftImport.h`. Explicit selectors on every member it
calls: `initWithFrame:creativeModel:targeting:`, `loadHTML:baseURL:injectMraidJs:`, `prepareForMRAIDWithRootViewController:`, `addFriendlyObstructionsToMeasurementSession:`, `internalWebView`, `delegate`, `rewardedAdURL`, `initWithCreative:viewControllerForPresenting:webView:creativeViewDelegate:downloadBlock:`,
`webView:handleMRAIDURL:`, `updateForClose:`, `mraidState`. The two class methods the old ObjC used (`isMRAIDLink:`, `anyToJSONDict:`, `isVisibleView:`, `webViewStateDescription:`) have no surviving ObjC caller (measured with `rg -w`), so they are plain `static` Swift
methods with no `@objc` (S5.0-A applies only when a caller survives). `PBMHTMLCreative.m` only needed two explicit imports it had been getting through `PBMWebView.h`/`PBMMRAIDController.h`: `@import WebKit;` and `#import "PBMOpenMeasurementSession.h"` (S2.5-A; SPM build confirms).

## Parity evidence (S6.x-G-A)

The throwaway ObjC dump ran against the ObjC classes before anything was deleted (copies in `/tmp/p7-2/oracle/WebViewParityDump.m` and `WebViewJSProbe.m`, never committed; frozen output in `/tmp/p7-2/objc-dump.orig.txt`, `objc-probe.orig.txt`).
It prints `nil` and `""` differently and escapes everything outside printable ASCII as `\u{XXXX}`.

**431 comparable dump lines + 50 JavaScript property probes = 481 inputs, byte-identical** (`WebViewParityTests`, expectations committed literally in `WebViewParityExpectations.swift`; model: `MRAIDParityTests`):

| Group | Lines |
|-------|------:|
| `+isMRAIDLink:` (case, whitespace, combining marks, ZWJ, full-width colon, BOM, lone surrogate, 2000 chars) | 41 |
| `commandFromURL:` (valid, malformed percent-encoding, missing args, odd casing, `İ`, unicode, empty, nil URL; the 26 throwing cases compare the exception reason, name `com.prebid` in 26/26) | 66 |
| `+CGRectForResizeProperties:fromView:` (7 orphan frames, nil properties, 11 sizes x 9 offsets x 2 offscreen = 198 combos incl. `NSIntegerMin/Max`, 7 view frames x 3 parent frames, 10 huge-origin cases up to 1e300) | 216 |
| `+anyToJSONDict:` (nil, NSNull, numbers, nested/deep(100), NaN, 1e999, lone surrogate, NSMutableString, NSData, dictionary, array, BOM, trailing garbage) | 55 |
| `+webViewStateDescription:` | 3 |
| `+isVisibleView:` | 10 |
| `isOrientationLocked` (nil VC, all 32 masks) | 33 |
| `buildMraidEnvObject` (COPPA nil/0/1/2/1.0/-1; SDK version, bundle id and IFA masked, rest literal) | 6 |
| `MRAID_getExpandProperties`/`MRAID_getResizeProperties` by stubbing `window.mraid` (26 + 24 JS expressions: numbers, strings, bools, floats, `1e300`, missing keys, `null`) | 50 |

First Swift run found two real differences, both fixed (see deviations 1 and 7): `isMRAIDLink` (`mraid:\u{301}x`) and the NUL-containing inputs (the NUL was an artefact of my `%c` with 0 in the oracle; the committed inputs are the NUL-free strings the oracle actually ran).
`NaN` frames are not in the dump (UIKit asserts `CALayer position contains NaN` before the code is reached; the oracle crashed on them, so they were replaced by 1e300 / 9.3e18 origins). The resize results depend on the screen size: expectations were captured at 402x874 pt (iPhone 17 / 17 Pro) and the test
`XCTSkip`s on any other screen.

Behaviour that is stateful or `WKWebView`-bound is covered by the existing `PBMWebViewTest` (37 tests), `PBMMRAIDControllerTest`, and the `PBMHTMLCreativeTest_*` family, all green.

## Deviation table (each VERIFIED by running the ObjC unless marked)

| # | Site | ObjC (measured) | Swift | Status |
|---|------|-----------------|-------|--------|
| 1 | `+isMRAIDLink:` | `-[NSString hasPrefix:]` is a literal anchored search: `"mraid:\u{301}x"` is a link | `NSString` cast + `hasPrefix` resolves to Swift's grapheme-aware `String.hasPrefix`, which said NO (found by the parity run) | fixed: `range(of:options:[.anchored,.literal])`. Same result on all 41 inputs |
| 2 | `MRAID_getExpandProperties` / `MRAID_getResizeProperties` with a non-number/non-string value (`null`, `{}`, `[1]`; `JSON.stringify` turns `NaN`/`Infinity` into `null`) | `-integerValue`/`-boolValue` sent to `NSNull`/`NSDictionary`/`NSArray`: **"unrecognized selector", app crash. Probed one case per process: 7 of 7 crashed** (4 expand, 3 resize) | the value is rejected like a missing one: logged, completion handler gets `nil` | forced by Swift types, strictly safer; creative-controlled input. Test: `testUnsupportedValueTypesInJSPropertiesAreRejected`. Lenient NSNumber/NSString parsing kept NSString-based (S6.x-G-B): `'12abc'` -> 12, `'abc'` -> 0, `1e300` -> `Int.max`, bool `'yes'` -> true, all in the probe |
| 3 | `handleMRAIDCommandOnOrientationPropertiesChanged`, `forceOrientation` not a string | `isEqualToString:` to a non-string: unrecognized-selector crash (reasoned from the code, not probed) | treated as a missing key (`as? String`) | strictly safer |
| 4 | `+CGRectForResizeProperties:fromView:` integer arithmetic | `(NSInteger)globalPoint.x + properties.offsetX` wraps; `(NSInteger)` saturates (probed: `1e19` -> `Int.max`, NaN unreachable) | `saturatingInteger` + `&+`, then `CGFloat(...)`. Swift `Int(_:)` and `+` would have trapped on creative-supplied `Int.max` offsets (S6.x-K-A) | in the dump (216 lines, incl. `Int.min`/`Int.max` offsets and 1e300 origins), byte-identical |
| 5 | `basicRect.size.height > basicRect.size.height` (compares with itself) | always false | kept verbatim with a comment | literal |
| 6 | `MRAIDController` init | the long designated init with `deviceAccessManagerClass:`/`sdkConfiguration:` stored both and **never read them** (grepped the whole `.m`) | not ported; the test extension that exposed it is deleted. `PBMHTMLCreativeTest_NoMRAID` uses the short init | dead code |
| 7 | `observeValue(forKeyPath:)` for `outputVolume` | the "0.5" `NSString` in the test works through `-floatValue` | `NSNumber` and `NSString` handled; missing -> `onAudioVolumeChange(nil)` as ObjC | covered by `testAudioVolumeChange` |
| 8 | `initWithCoder:` | `return [super initWithCoder:]`, a view with no web view (crashes on first use) | returns `nil` | nothing instantiates it from a nib (measured) |
| 9 | `loadHTML:` | nil guard logged "Input HTML is nil" | `html: String?` stays optional (S3.1-H: `PBMHTMLCreative.m` and `PBMWebViewObjCTest.m` can reach it), same log | same |
| 10 | `-[PBMWebView expand:]` nil URL, `evaluateJavaScript:` nil command | logged / ran with nil | parameters non-optional: both are `internal` and only Swift code calls them with non-nil values (`MRAIDController`, `MRAIDJavascriptCommands` return `String`) | **unreachable**; `PBMWebViewObjCTest.testExpandNil` and `testEvaluateJSNil` deleted (S3.1-C, not preserved by widening access) |
| 11 | `MRAID_updateCurrentAppOrientation`, `onStatusBarOrientationChanged` | `UIApplication.sharedApplication` (nil host-less -> orientation 0 -> "landscape"/"false") | `Functions.resolvedApplication?.statusBarOrientation` (S2.5-E), same nil outcome | verified by reading, covered by the two existing orientation tests |
| 12 | `creativeMraidDidExpand/Collapse`, `modalManagerDid...` with a nil `creative` (weak, deallocating) | message-to-nil / `nil` passed on | skipped when the weak `creative` or the popped state is nil (the Swift parameters are non-optional) | only reachable while the creative is deallocating (S5.2-C: stated, not a reachable difference) |
| 13 | `pushModal` with `viewControllerForPresentingModals` that became nil between the check and the async completion | `nil` passed into the nonnull ObjC/Swift parameter | logged and returned | the sync guard `viewControllerForPresentingModals == nil` is unchanged |
| 14 | `loadVideo` | `self.downloadBlock(...)` called unconditionally (nil block = crash); `PBMVideoView` built with the creative's event manager | optional chaining; the whole block is skipped if the creative is gone | only differs for the nil cases |
| 15 | `NSInvocation`/`@try` in `webView:handleMRAIDURL:` | `NSException` thrown from 14 sites, caught and logged by `@try` | `throws` with a private `MRAIDCommandError`, caught and logged with `Log.warn(error.localizedDescription)`; the message strings are unchanged | forced (Swift cannot throw `NSException`). `PBMHTMLCreative.m` keeps its own `@try` for ObjC callers (it can no longer catch anything from Swift, harmless) |
| 16 | Logging | `PBMLogError/Warn/Info` | `Log.error/warn/info` | text identical, file/function prefix differs |
| 17 | `MRAIDCommand` failure from the controller | thrown `NSException` carrying the `PBMError` description | `MRAIDCommandError(message: error.localizedDescription)` | in the dump (26 throwing cases compared by reason) |
| 18 | `pollForViewability` interval | `0.2f` (float widened to double, 0.20000000298...) | `0.2` | difference < 1 microsecond, not observable |

## Risk list decisions (the brief's 11 points)

1. **`WKScriptMessageHandler` "log"**: preserved exactly. `userContentController.add(WKScriptMessageHandlerLeakAvoider(delegate: self), name: "log")` after `super.init`. The ObjC never removed the handler (the leak avoider holds the web view weakly), so none is removed here either.
2. **KVO / observers**: `AVAudioSession.outputVolume` observer added in `setupVolumeObserver` behind `isVolumeObserverSetup`, removed in `deinit` only if set (string key path `"outputVolume"` kept, S6.x block-based-KVO note). The two notification observers (`UIApplication.didChangeStatusBarFrameNotification` at init, `AVAudioSession.interruptionNotification` in `setupVolumeObserver`) are selector-based and, as in ObjC, never removed explicitly. Same add timing and symmetry.
3. **mraid.js injection**: untouched ordering. `WKUserScript` then `evaluateJavaScript`; `mraidState` changes in the inner completion; the readyState poll re-arms with `DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100))` (no raw `dispatch_time_t` involved, so `Functions.dispatchTimeAfterTimeInterval` was not needed). The env object is built twice (`buildMraidEnvObject()` is called for the script and again for the evaluation), like the ObjC.
4. **`@weakify/@strongify`**: `[weak self]` only where the ObjC had `@weakify`/`__weak`; strong captures kept strong with a comment: the outer block of `evaluateJavaScript`, `expand`'s async hop, the inner mraid-state completion, `loadVideo`'s main-queue block and the `onModalPushedBlock` capturing `videoView`.
5. **JS strings**: `MRAID_ENV` built entry by entry with the same `,\n  ` joins; compared on 6 COPPA values. `"(null)"` for a nil bundle identifier. The injected `viewport`/style script literal is byte-identical (concatenated string pieces, same content).
6. **Class methods**: see "Surviving ObjC consumer" (no survivors; all in the dump).
7. **`commandFromURL:` / `CGRectForResizeProperties`**: parity evidence above (66 + 216 lines).
8. **Nonnull sites (`NS_ASSUME_NONNULL`)**: deviations 9, 10, 12, 13, 14.
9. **Integer arithmetic / String vs NSString**: deviations 1, 2, 4. `isEqualToString:` for the rewarded URL kept literal via `NSString.isEqual(to:)`; `-integerValue` stays `NSString`-based.
10. **`UIApplication.shared`**: never read directly (`rg` of the two files finds only a comment).
11. **Mutable collections**: none in these classes.

`PBMORTB.h` (Gap 4): `PBMWebView.m` imported it but used no ORTB type (`rg PBMORTB` finds only the import line), so Gap 4 was dead for this file. After the deletion `PBMORTB.h` has no `.m` importer left, only the test bridging header.

## `ModalStateImpl`'s `as? WebView_Protocol`

`WebView_Protocol` now has exactly one conformer (`WebView`; measured: `rg WebView_Protocol` finds only the two `as?` casts, `ModalStateImpl.swift:38` and `ModalViewController.swift:201`). Both casts could now be `as? WebView`, and the protocol could be deleted. I did **not** change them: they are covered by `ModalManagerTest*`/`ModalViewControllerTest` (green) but replacing a protocol cast is a separate cleanup, and `WebView_Protocol` is `@objc(PBMWebView_Protocol)` public SPI.

## Gap candidates for the playbook (I did not edit it)

- **S7.2-A, `-[NSString hasPrefix:]` vs `String.hasPrefix`.** Casting to `NSString` does not select the ObjC method: Swift still resolves `hasPrefix` to the grapheme-aware `String` one (and `hasSuffix` likewise). For a 1:1 port use `range(of:options:[.anchored, .literal])` (found by a combining-mark input in the parity dump). Related to S6.x-K-A (2).
- **S7.2-B, `@objc` is needed on Swift properties that tests read through key-value coding.** `PBMWebViewTest.testExpand` waits on `NSPredicate("state == ...")` and `"mraidState.rawValue == ..."`; both properties lose KVC without `@objc` (the test times out, not a compile error).
- **S7.2-C, S3.1-F again for an ObjC class that conforms to a Swift `@objc` protocol.** `PBMHTMLCreative` conforms to `PBMWebViewDelegate`; Swift tests see the ObjC selectors (`webView:receivedMRAIDLink:`) only if `PBMHTMLCreative+pbmTestExtension.h` re-declares them. The header now carries the five delegate methods. Delete them with `PBMHTMLCreative`.
- **S7.2-D, ObjC `JSON`-derived property reads crash on the wrong type.** `-integerValue`/`-boolValue` on `NSNull`/`NSArray`/`NSDictionary` is an unrecognized-selector crash (probed). Any port of code that reads untyped creative JSON should reject the wrong type instead of reproducing the crash (cf. S6.x-K-A (3): run the ObjC before writing "ObjC crashed here").
- **S7.2-E, test helpers named like the ported class.** `PBMMRAIDControllerTest_Base` had `var MRAIDController: PBMMRAIDController!`; after the blanket rename the property shadowed the type. Renamed to `mraidController`. The same blanket rename must skip `@objc(` strings and string literals (`ACCESSIBILITY_WEB_VIEW_LABEL = "PBMWebView"`, the `"PBMWebView is ready to display"` log string are intentionally unchanged).
- **S7.2-F, Swift cannot hold a lone surrogate, nor NUL via `%c`.** A parity dump that includes such inputs has to build them as `NSString(characters:length:)`; the expectation key is written by hand (`\u{D83D}`).
- **S7.2-G, `XCTSkipUnless` for screen-dependent parity.** `CGRectForResizeProperties` depends on `UIScreen.main.bounds`; the parity test pins the screen in its first line.
- Existing: `PBMWebView.h`'s `NS_SWIFT_NAME`s are gone; the Swift names are the plain ones (`MRAID_getExpandProperties(completionHandler:)`, `MRAID_error(_:action:)`, `updateMRAIDLayoutInfo(_:)`, `changeToMRAIDState(_:)`). The typed-enum parameters (`PBMMRAIDAction`, `PBMMRAIDPlacementType`) are `String` on the Swift side (S2.1-A residue, as for `MRAIDJavascriptCommands`); `MockPBMWebView` converts with `PBMMRAIDAction(rawValue:)`.

## project.pbxproj deltas (xcodeproj gem only, `plutil -lint` OK)

- Removed: `PBMWebView.m`, `PBMMRAIDController.m` (Sources), `PBMWebView.h`, `PBMWebView+Internal.h`, `PBMMRAIDController.h`, `PBMWebViewDelegate.h`, `PBMExposureChangeDelegate.h` (Headers), `PBMWebView+PBMTestExtension.h`, `PBMMRAIDController+pbmTestExtension.h`, `PBMMRAIDControllerObjCTest.m`. The temporary `WebViewParityDump.m` and `WebViewJSProbe.m` were added and removed again (net zero).
- Added to target `PrebidMobile` (group `Swift/PrebidMobileRendering/AdTypes/AdView`): `WebViewDelegate.swift`, `ExposureChangeDelegate.swift`, `MRAIDController.swift`. `WebView.swift` already existed.
- Added to target `PrebidMobileTests` (`RenderingTests/Tests`): `WebViewParityTests.swift`, `WebViewParityExpectations.swift`.
- Validation (`/tmp/p7-2/check.rb`): 0 dangling `PBXBuildFile`s; the only file refs to missing files are `PrebidMobile.framework`, `PrebidMobileTests.xctest`, `CoreLocation.framework`; each new Swift file has exactly 1 ref and 1 Sources entry; no stale refs to any deleted file. `Podfile.lock` unchanged.
- `PrebidMobilePRTests.xctestplan`: removed the two `PBMMRAIDControllerObjCTest` entries from `skippedTests` (the class is gone). The new tests run on every PR (neither plan matches them; `WebViewParityTests` takes about 17 s, 15 s of it the JavaScript-property test).

## Orphan headers

Retired three: `PBMExposureChangeDelegate.h`, `PBMWebViewDelegate.h`, `PBMWebView+Internal.h` (the last had a `.m`, so it was not in the orphan table). The `comm` snippet now prints **19** orphan headers (22 after wave 1A). Remaining `.m` files under `PrebidMobile/Objc`: **16**.
Still alive and affected: `PBMORTB.h` (only the test bridging header imports it now), `PBMMRAIDConstants.h` (bridging header, `PBMHTMLCreative.m`, `PBMMRAIDConstants.m`), `PBMModalState.h` (bridging header, `PBMHTMLCreative.m`, `PBMAbstractCreative.m`, `PBMVideoCreative.m`; `PBMMRAIDController.m` no longer imports it), `PBMVoidBlock.h` (lost `PBMWebView.m`, `PBMMRAIDController.m`), `PBMCreativeFactory.h`
(`PBMMRAIDController.h` was an importer; `PBMHTMLCreative.h`, `PBMTransaction.m`, `PBMCreativeFactory.m`, bridging header remain). `PBMCreativeFactoryDownloadDataCompletionClosure` is replaced in Swift by `((URL, @escaping PBMDownloadDataCompletionClosure) -> Void)?` (S2.3-B); `PBMHTMLCreative.m` still passes its ObjC block unchanged.

## Verification

- Xcode: `xcodebuild -workspace PrebidMobile.xcworkspace -scheme PrebidMobileTests -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/phase7-dd-2 build-for-testing`: **TEST BUILD SUCCEEDED** (final tree).
- SPM: `scripts/buildPrebidMobilePackage.sh`: **succeeded** first time (the two explicit imports in `PBMHTMLCreative.m` had already been added).
- SwiftLint on the 4 new SDK files, the two parity files and the mock: 0 new errors. The one `error` it reports is `Type Name Violation: 'WebView_Protocol'` on a declaration that existed before this wave; the rest are warnings (comment spacing carried from the ObjC, two carried `TODO`s, `type_body_length` on `WebView`, one orphaned doc comment).
- Baseline before the port (ObjC, same simulator): 89 tests, 0 failures. After the port, the same classes plus the new ones: 92 + 11 tests across two runs, **0 failures**, on the existing booted `iPhone 17` simulator (`83B1468E-...`, iOS 26.0; no simulators created or deleted, not `iPhone-17-Pro-PrebidMobile`):
  `PBMWebViewTest` (37), `PBMWebViewObjCTest` (1), `PBMMRAIDControllerTest` (3, incl. the ported `testCommandWithBadParams`), `PBMMRAIDControllerCGRectForResizePropertiesTest` (1), `MRAIDJavascriptCommandsTests`, `MRAIDParityTests`, `PBMMRAIDCommandTest`, `WebViewParityTests` (3), `PBMHTMLCreativeTest`, `PBMHTMLCreativeTest_NoMRAID`/`_MRAIDExpand`/`_MRAIDResize`/`_MRAIDClose`/`_MRAIDOpen`/`_MRAIDOrientationChange`/`_MRAIDPlayVideo`/`_ModalManagerDelegate`,
  `ModalManagerTestDisplayInInterstitial`/`ModalManagerTestPresentationType`/`ModalManagerTestOther`, `ModalViewControllerTest`, `ModalPresentationControllerTest`, `AdViewManagerTest`, `PBMAbstractCreativeTest`, `PBMVideoCreativeTestCloseDelay`, `PBMRewardedVideoCreativeTest`, `LocationManagerTest`.
  (`ModalManagerTest` is three classes, named above; `PBMHTMLCreativeTest_*` matched by name.) One mid-port failure (`testExpand`, KVC on `mraidState`) was a real regression and is fixed (S7.2-B); the final tree passes.
- Not run: the full or PR test plan, adapter tests, `buildPrebidMobile.sh`/`testPrebidMobile.sh` (forbidden), `verifySPM.sh`, the UI tests (`PrebidMRAIDResizeUITest` finds the view by the unchanged accessibility identifier `"PBMWebView"`). Device-only behaviour (arm64 `dispatch_time` ticks) is not involved.

## Notes for the integrator

- Conflicts to expect: `project.pbxproj` (additive), the test bridging header (5 lines removed: `PBMMRAIDController.h`, `PBMWebView.h`, `PBMWebViewDelegate.h`, `PBMWebView+PBMTestExtension.h`, `PBMMRAIDController+PBMTestExtension.h`), `PrebidMobilePRTests.xctestplan` (2 lines removed), and `PBMHTMLCreative+pbmTestExtension.h` (five re-declared delegate methods added; wave 3 deletes the header with `PBMHTMLCreative`).
- When `PBMHTMLCreative` moves (wave 3): call `WebView(frame:creativeModel:targeting:)`, `MRAIDController(creative:...)`, `webView.loadHTML(...)` directly; drop every `@objc(selector)` annotation listed above (the `internalWebView`, `delegate`, `rewardedAdURL`, `mraidState`, `isRotationEnabled` ones too); `WebViewDelegate`/`ExposureChangeDelegate` and the `@objc(PBMFoo)` names can then drop their `@objc`. The parameters kept optional for `PBMHTMLCreative.m` (`loadHTML(_:)`'s `html`, `prepareForMRAID(withRootViewController:)`'s controller, the `MRAIDController` init) can become non-optional where the Swift caller cannot pass nil.
- `PBMWebViewObjCTest.m` is the last ObjC test on `PBMWebView` (one test, `testLoadHTMLNil`); it goes with `PBMHTMLCreative` or can become Swift now.
- Swift now owns the `PBMOpenMeasurementSession` seam: `WebView.addFriendlyObstructions(to:)` takes `OMSession?` and is an empty method, like the ObjC (`PBMHTMLCreative.m` still gates the call on `isKindOfClass:PBMOpenMeasurementSession`). No new seam and no `NSClassFromString` was added (S4.5-B).
- `MRAIDController.swift` is 709 lines and `WebView.swift` 958 (the `.m` were 702 and 946).
