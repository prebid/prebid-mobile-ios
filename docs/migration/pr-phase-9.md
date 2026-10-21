# [swift-migration] Phase 9: consumer-defined public API, ObjC leftovers retired, SPM target removed

Suggested PR title: `[swift-migration] Phase 9: consumer-defined public API, ObjC leftovers retired, SPM target removed`

Branch `swift-migration-phase-9` on top of `master` (`c597bc07`, after Phase 8 / #1406). Steps: **S9.1 – S9.4** (below). One PR.

**Result: `PrebidMobile/Objc` holds one header, `SwiftImport.h` (was 14).** The ObjC SPM target `__PrebidMobileInternal` is gone.

## Scope boundary

Phase 9 lands header retirement, the SPM target removal, the `Factory` lookups, the test clean-up, the consumer-defined visibility demotion (S9.2) and the VAST array retyping (S9.4). It deliberately does **not** land:
- pruning members of the classes that stay public (`Targeting`, `Prebid`, `Log`, ...): documented members that the apps do not reference are kept (S9.2-F);
- the `MockServer/*.m` port (test infrastructure), and `OMIDContext+pbmTestExtension.m` (must stay);
- the manual demo-app OMSDK check;
- dropping `NSObject` from internal classes: a follow-up epic, tracked in [#1408](https://github.com/prebid/prebid-mobile-ios/issues/1408).
See the playbook hand-off.

## Steps

| Step | Contents |
|------|----------|
| **S9.1** | Delete 13 headers: `PBMAdLoadFlowController`, `PBMORTB_NotImplemented`, `PBMORTBAbstract+Protected`, `PBMORTBAbstract`, `PBMORTB`, `PBMUIApplicationProtocol`, `PBMWKNavigationActionCompatible`, `PBMWKWebViewCompatible` and their two categories, `PBMConstants`, `PBMMacros`, `Log+Extensions`. Bridging header trimmed; `UIKit`, `WebKit` and `SwiftImport.h` imported explicitly. `ServerConnectionTest` `JsonDictionary` → `[String: Any]` |
| **S9.1 (tests)** | Port `PBMWebViewObjCTest` → `PBMWebViewTest.testLoadHTMLNil`. Delete `LogObjCTest`, `PBMMacrosTest` (ObjC macros nothing uses) and `PBMFunctionsObjCTest` (fully commented out). **Keep as ObjC:** `PrebidObjcTests`, `TargetingObjCTests`, `AdUnitObjCTests`, `AdUnitSuccessorObjCTests`, `AdViewUtilsObjCTests`, `UtilsObjCTests`, `NSString+pbmExtensionsObjCTest`, `NSMutableDictionaryTests`: they prove the API is callable from Objective-C (S9.1-A) |
| **S9.1 (SPM)** | `__PrebidMobileInternal` removed from `Package.swift`, `PrebidMobile/Package.swift` (target and product), and `buildPrebidMobilePackage.sh`; `PrebidMobile_SPM` define and header search path go with it |
| **S9.3** | `Factory` constructs `BidRequesterImpl`, `WinNotifierImpl`, `AdViewManagerImpl`, `ViewExposureImpl`, `ModalStateImpl` directly; the five `NSClassFromString("PBM*_Objc")` lookups and `@objc(PBM*_Objc)` names are deleted |
| **S9.2** | `@_spi(PBMInternal)` removed from 113 declarations in 91 files (now internal); public `.swiftinterface` diff: **0 lines**. Two extensions keep it (S9.2-C). `PBMFunctionsPrivateTest.m` deleted (its subject is no longer ObjC-visible); `AdUnitObjCTests.m` declares `AdUnitSwizzleHelper` itself (S9.2-D) |
| **S9.2b-e** | Public API redefined by consumer usage (S9.2-F): every top-level type outside the demo apps, InternalTestApp, the adapters, the ObjC API tests and the non-`@testable` API tests loses `public`/`open`/`@objc`; then unreferenced members of the types that stay public, `public extension`s on system classes and top-level globals. Public types 236 → 147, none newly public; public members 1694 → 950; `@objc` in the public interface 2515 → 1505. `PBMSwiftMigrationHelper` deleted; two ObjC helper tests ported to Swift; two KVC tests rewritten (typed key paths, block predicates) |
| **S9.4** | The 13 VAST `NSMutableArray` properties are typed Swift arrays (S9.4-A); redundant casts and the wrong-typed-element parser tests adjusted |
| **extra** | `NSString.PBMsubstringFromString(_:)` length bug fixed (S9.x-G); `AGENTS.md` architecture section rewritten; `phase-8-plan.md` deleted; PR test plan stale skip entries for the deleted ObjC tests removed |

## Behavior deviations (reviewer: please read)

| # | Site | Before | After | Status |
|---|------|--------|-------|--------|
| 1 | `NSString.PBMsubstringFromString(_:)` | `substring(with: NSRange(end, length - range.length))`: raised `NSRangeException` when the match was not at index 0 and text continued after it | `substring(from: end)`; same result at index 0 and at end of string | **verified**, new mid-string case in `TestStringExtension` |
| 2 | `Factory.*Type` lookups | `NSClassFromString(...) as!` crashes at first use if the runtime name were missing | direct construction, compile-time checked | verified by build + full suite |
| 3 | Runtime class names `PBMBidRequester_Objc`, `PBMWinNotifier_Objc`, `PBMAdViewManager_Objc`, `PBMViewExposure_Objc`, `PBMModalState_Objc` | resolvable by `NSClassFromString` | gone; Swift mangled names | grep: no remaining lookup in SDK, tests, adapters or Example. All were `@_spi(PBMInternal)` |
| 4 | SPI surface | `@_spi(PBMInternal) public` declarations, visible to a client that opts in with `@_spi(PBMInternal) import PrebidMobile` | internal | nothing in `EventHandlers` or `Example` references it; public interface byte-identical. A third party using the undocumented SPI group would break |
| 5 | `public`/`@objc` on engine classes | public and ObjC-visible | internal | defined by consumer usage; see S9.2-F. A third-party app that used an engine class directly (not in the demo apps/adapters/tests) would stop compiling or linking; that is the accepted risk |
| 6 | Test coverage | `LogObjCTest` (7), `PBMMacrosTest` (1), `PBMFunctionsObjCTest` (3, empty bodies), `PBMWebViewObjCTest` (1), `PBMFunctionsPrivateTest` (2, S9.2) | `PBMWebViewTest.testLoadHTMLNil` (Swift) | macro tests deleted because no code uses the macros; the nil-HTML case keeps its meaning (`loadHTML(_ html: String?)` is still optional) |

## Open items for the reviewer

- **Not run:** `verifySPM.sh` / `buildPrebidSPM.sh` (CI-only; `verifySPM.sh` writes to the machine's SwiftPM fingerprint store). The local SPM build is clean (394 files compiled).
- **Demo-app OMSDK check** was not done in Phases 7, 8 or 9.
- `swiftlint` on the changed files: one error, `ServerConnectionTest_Redirect` type name, pre-existing and not touched here.
- The test count rose from the Phase 8 figure (1410) to 1412 because `master` gained tests from other PRs since; a baseline on `c597bc07` was not run.
- `AGENTS.md` test counts updated to the measured 1016 (PR subset) and 1412 (full).

## Test plan

- [x] `buildPrebidMobile.sh`: 4 XCFrameworks built; "All 24 Swift interfaces typecheck"
- [x] `buildPrebidMobilePackage.sh` after `rm -rf .build`: **394 files** compiled, exit 0
- [x] `testPrebidMobile.sh --latest` (full): **1410 tests, 0 failures**, `TEST EXECUTE SUCCEEDED` (re-run after S9.2e; clean SPM build compiles 393 files)
- [x] `testPrebidMobileAdapters.sh`: exit 0 (re-run after S9.2e)
- [x] Consumers build: `InternalTestApp`, `InternalTestApp-Skadn`, `PrebidDemoSwift`, `PrebidDemoObjectiveC` (generic simulator destination) after S9.2e
- [x] Public `.swiftinterface` after S9.2 (SPI only): 0 changed lines; after S9.2b-e: 236 → 147 public types, no newly public type (intended shrink)
- [x] `testPrebidMobile.sh --latest --quick` (PR subset) on the final tree: **1016 tests, 0 failures** (two runs). One earlier run failed `PrebidTest.testInitializeSDK` on all three retries: it calls the live `prebid-server-test-j.prebid.org` with a 3 s timeout; the server answered in 0.6 s afterwards and the test passes in the full suite and in both re-runs, so it is network flakiness, not this PR
- [ ] `verifySPM.sh`, `buildPrebidSPM.sh`: CI only
- [ ] Manual demo-app OMSDK check
