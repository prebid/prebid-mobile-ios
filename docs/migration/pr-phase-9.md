# [swift-migration] Phase 9: retire ObjC leftovers, remove the empty SPM target

Suggested PR title: `[swift-migration] Phase 9: retire ObjC leftovers, remove the empty SPM target`

Branch `swift-migration-phase-9` on top of `master` (`c597bc07`, after Phase 8 / #1406). Steps: **S9.1 – S9.3** (below). One PR.

**Result: `PrebidMobile/Objc` holds one header, `SwiftImport.h` (was 14).** The ObjC SPM target `__PrebidMobileInternal` is gone.

## Scope boundary

Phase 9 lands header retirement, the SPM target removal, the `Factory` lookups and the test clean-up. It deliberately does **not** land:
S9.2 visibility demotion, the remaining `@objc(PBM…)` annotations, the VAST `NSMutableArray` retyping, or the `MockServer/*.m` port. See the playbook hand-off.

## Steps

| Step | Contents |
|------|----------|
| **S9.1** | Delete 13 headers: `PBMAdLoadFlowController`, `PBMORTB_NotImplemented`, `PBMORTBAbstract+Protected`, `PBMORTBAbstract`, `PBMORTB`, `PBMUIApplicationProtocol`, `PBMWKNavigationActionCompatible`, `PBMWKWebViewCompatible` and their two categories, `PBMConstants`, `PBMMacros`, `Log+Extensions`. Bridging header trimmed; `UIKit`, `WebKit` and `SwiftImport.h` imported explicitly. `ServerConnectionTest` `JsonDictionary` → `[String: Any]` |
| **S9.1 (tests)** | Port `PBMWebViewObjCTest` → `PBMWebViewTest.testLoadHTMLNil`. Delete `LogObjCTest`, `PBMMacrosTest` (ObjC macros nothing uses) and `PBMFunctionsObjCTest` (fully commented out). **Keep as ObjC:** `PrebidObjcTests`, `TargetingObjCTests`, `AdUnitObjCTests`, `AdUnitSuccessorObjCTests`, `AdViewUtilsObjCTests`, `UtilsObjCTests`, `NSString+pbmExtensionsObjCTest`, `NSMutableDictionaryTests`, `PBMFunctionsPrivateTest`: they prove the API is callable from Objective-C (S9.1-A) |
| **S9.2 (SPM)** | `__PrebidMobileInternal` removed from `Package.swift`, `PrebidMobile/Package.swift` (target and product), and `buildPrebidMobilePackage.sh`; `PrebidMobile_SPM` define and header search path go with it |
| **S9.3** | `Factory` constructs `BidRequesterImpl`, `WinNotifierImpl`, `AdViewManagerImpl`, `ViewExposureImpl`, `ModalStateImpl` directly; the five `NSClassFromString("PBM*_Objc")` lookups and `@objc(PBM*_Objc)` names are deleted |
| **extra** | `NSString.PBMsubstringFromString(_:)` length bug fixed (S9.x-G); `AGENTS.md` architecture section rewritten; `phase-8-plan.md` deleted; PR test plan stale skip entries for the deleted ObjC tests removed |

## Behavior deviations (reviewer: please read)

| # | Site | Before | After | Status |
|---|------|--------|-------|--------|
| 1 | `NSString.PBMsubstringFromString(_:)` | `substring(with: NSRange(end, length - range.length))`: raised `NSRangeException` when the match was not at index 0 and text continued after it | `substring(from: end)`; same result at index 0 and at end of string | **verified**, new mid-string case in `TestStringExtension` |
| 2 | `Factory.*Type` lookups | `NSClassFromString(...) as!` crashes at first use if the runtime name were missing | direct construction, compile-time checked | verified by build + full suite |
| 3 | Runtime class names `PBMBidRequester_Objc`, `PBMWinNotifier_Objc`, `PBMAdViewManager_Objc`, `PBMViewExposure_Objc`, `PBMModalState_Objc` | resolvable by `NSClassFromString` | gone; Swift mangled names | grep: no remaining lookup in SDK, tests, adapters or Example. All were `@_spi(PBMInternal)` |
| 4 | Test coverage | `LogObjCTest` (7), `PBMMacrosTest` (1), `PBMFunctionsObjCTest` (3, empty bodies), `PBMWebViewObjCTest` (1) | `PBMWebViewTest.testLoadHTMLNil` (Swift) | macro tests deleted because no code uses the macros; the nil-HTML case keeps its meaning (`loadHTML(_ html: String?)` is still optional) |

## Open items for the reviewer

- **Not run:** `verifySPM.sh` / `buildPrebidSPM.sh` (CI-only; `verifySPM.sh` writes to the machine's SwiftPM fingerprint store). The local SPM build is clean (394 files compiled).
- **Demo-app OMSDK check** was not done in Phases 7, 8 or 9.
- `swiftlint` on the changed files: one error, `ServerConnectionTest_Redirect` type name, pre-existing and not touched here.
- The test count rose from the Phase 8 figure (1410) to 1412 because `master` gained tests from other PRs since; a baseline on `c597bc07` was not run.
- `AGENTS.md` test counts updated to the measured 1016 (PR subset) and 1412 (full).

## Test plan

- [x] `buildPrebidMobile.sh`: 4 XCFrameworks built; "All 24 Swift interfaces typecheck"
- [x] `buildPrebidMobilePackage.sh` after `rm -rf .build`: **394 files** compiled, exit 0
- [x] `testPrebidMobile.sh --latest` (full): **1412 tests, 0 failures**, `TEST EXECUTE SUCCEEDED`
- [x] `testPrebidMobileAdapters.sh`: exit 0
- [x] `testPrebidMobile.sh --latest --quick` (PR subset), after the skip-list edit: **1016 tests, 0 failures**, `TEST EXECUTE SUCCEEDED`
- [ ] `verifySPM.sh`, `buildPrebidSPM.sh`: CI only
- [ ] Manual demo-app OMSDK check
