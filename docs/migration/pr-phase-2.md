## Summary

Phase 2 — Utilities & extensions. S2.1 complete; S2.2 and S2.3 pending.

All Swift twins live under `PrebidMobile/Swift/PrebidMobileRendering/Utilities/`.
Naming: Swift class = `FooBar`, file = `FooBar.swift`, ObjC bridge = `@objc(PBMFooBar)`.

---

### S2.1 — Standalone utilities (Utilities/)

Ported 8 of 12 files from `PrebidMobile/Objc/PrebidMobileRendering/Utilities/`.
Deferred 4 files due to unported ObjC dependencies (noted below).

**Ported:**
- `PBMFunctions.m` + `PBMFunctions+Testing.m` → `Functions.swift` (extended) + `Functions+Testing.swift`
- `PBMDeepLinkPlus.m` → `DeepLinkPlus.swift`
- `PBMDeviceAccessManagerKeys.m` → `DeviceAccessManagerKeys.swift`
- `PBMDownloadDataHelper.m` → `DownloadDataHelper.swift`
- `PBMCircularProgressBarLayer.m` → `CircularProgressBarLayer.swift`
- `PBMCircularProgressBarView.m` → `CircularProgressBarView.swift`
- `PBMWKScriptMessageHandlerLeakAvoider.m` → `WKScriptMessageHandlerLeakAvoider.swift`
- `PBMMRAIDConstants.m` (partial) → `MRAIDConstants.swift` (classes only)
- `PBMUIApplicationProtocol.h` (ObjC protocol) → `PBMUIApplicationProtocol.swift`

**Deferred:**
- `PBMDeepLinkPlusHelper.m` + `PBMDeepLinkPlusHelper+Testing.m` → Phase 4 (S4.4); depends on `PBMExternalLinkHandler`, `PBMExternalURLOpeners`, `PBMTrackingURLVisitors` (all private headers, Gap 8)
- `PBMWindowLocker.m` → Phase 8; depends on `PBMOpenMeasurementSession` (private header, Gap 8)

**Partial migration — `PBMMRAIDConstants`:**
- ObjC classes (`PBMMRAIDParseKeys`, `PBMMRAIDValues`, `PBMMRAIDCloseButtonPosition`, `PBMMRAIDCloseButtonSize`, `PBMMRAIDExpandProperties`, `PBMMRAIDResizeProperties`, `PBMMRAIDConstants`) → `MRAIDConstants.swift`
- NS_TYPED_ENUM constants (`PBMMRAIDAction*`, `PBMMRAIDFeature*`, `PBMMRAIDPlacementType*`) kept in residual `PBMMRAIDConstants.m` — cannot bridge as free-standing C-level constants from Swift; will be removed in Phase 7 when all ObjC MRAID consumers are ported

**New gap codified:**
- Gap S2.1-A — `NS_TYPED_ENUM` constants (`FOUNDATION_EXPORT NSString * const Foo`) cannot be exported from Swift as free-standing ObjC constants. Keep residual `.m` for the constants only; port the class implementations to Swift.
- Gap S2.1-B — `@_spi(PBMInternal)` on `Functions` class means Swift test files accessing it need `@_spi(PBMInternal) @testable import PrebidMobile`.

**Key findings:**
- `PBMFunctions` was the private header (Gap 8) that Phase 1 had to inline. Now in Swift, all future phases can call `Functions.*` directly.
- `PBMUIApplicationProtocol.h` reduced to a forward declaration `@protocol PBMUIApplicationProtocol;` — full definition is now in `PrebidMobile-Swift.h`. ObjC files that call methods on `id<PBMUIApplicationProtocol>` need `SwiftImport.h` (one file updated: `PBMExternalURLOpeners.m`).
- `dispatch_time()` C function unavailable in Swift — replaced with `DispatchTime` APIs.
- `UIInterfaceOrientationIsPortrait()` C macro unavailable in Swift — replaced with `.isPortrait` property.
- Swift `@objc(selector:)` on `throws` methods: must include `:error:` in the explicit name (e.g. `@objc(dictionaryFromJSONString:error:)`).
- `PBMCircularProgressBarLayer.value` uses `@NSManaged` (Swift's `@dynamic` equivalent for `CALayer` animated properties).
- `MRAIDExpandProperties` and `MRAIDResizeProperties` need explicit `override init()` so tests can use the no-arg form after moving from ObjC.

**ObjC consumer updates (non-ported files):**
- Removed `#import "PBMFunctions.h"` and `#import "PBMFunctions+Private.h"` from 17 consumer `.m` files
- Removed `#import "PBMDownloadDataHelper.h"` from `PBMVideoCreative.m`, `PBMHTMLCreative.m`, `PBMCreativeFactoryJob.m`
- Removed `#import "PBMWKScriptMessageHandlerLeakAvoider.h"` from `PBMWebView.m`
- Removed `#import "PBMDeepLinkPlus.h"` from `PBMDeepLinkPlusHelper.m`
- Added `#import "PBMConstants.h"` to `PBMAbstractCreative.m`, `PBMPrebidParameterBuilder.m`, `PBMWinNotifier.m` (lost `PBMJsonDictionary` typedef when `PBMFunctions.h` removed)
- Added `#import <UIKit/UIKit.h>` to `PBMMRAIDController.h`
- Added `#import "SwiftImport.h"` to `PBMExternalURLOpeners.m`
- Updated `PBMUIApplicationProtocol.h` to forward declaration only
- Updated `PBMMRAIDConstants.h` to remove class `@interface` blocks (classes now in Swift)
- Updated `PBMCreativeFactory.h` to define `PBMDownloadDataCompletionClosure` inline
- Replaced `[Functions checkCertificateChallenge:...]` → `[PBMFunctions checkCertificateChallenge:...]` in `PBMWebView.m` (ObjC name changed from `Functions` to `PBMFunctions` via `@objc(PBMFunctions)`)

**Test file updates:**
- Bulk rename `PBMFunctions` → `Functions` in Swift test files; add `@_spi(PBMInternal) @testable import` where needed
- Rename `PBMCircularProgressBarLayer/View`, `PBMDownloadDataHelper`, `PBMDeepLinkPlus` in test files
- `MockUIApplication` — add `NSObject` superclass (required by `PBMUIApplicationProtocol: NSObjectProtocol`)
- Error message expectations updated in `TestPBMFunctions` (Swift errors differ from ObjC `PBMError` messages)
- Removed deleted header imports from `PrebidMobileTest-Bridging-Header.h`

---

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 694 tests, 0 failures
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite (pending)
- [ ] Reviewer: confirm gap S2.1-A (NS_TYPED_ENUM deferred) and gap S2.1-B (@_spi imports in tests)
