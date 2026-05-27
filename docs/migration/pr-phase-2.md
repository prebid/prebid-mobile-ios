## Summary

Phase 2 — Utilities & extensions. All three steps complete (S2.1, S2.2, S2.3).

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

## Commits (branch `swift-migration-phase-2`)

- `632bd5dd` S2.1 — Port standalone utilities to Swift
- `16f89cb1` docs: update playbook with S2.1 gaps
- `990b6778` S2.2 — Port Foundation/UI category extensions to Swift
- `c81e0568` S2.3 — Port NSTimer wrapper to Swift; Phase 2 complete

### S2.2 — Foundation/UI category extensions (ExtensionsAndWrappers/)

Ported all 11 files (including Exposure/ subgroup).

**Key findings:**
- `@objc extension NSDictionary/NSMutableDictionary/NSString/NSURL/NSException` — ObjC category methods bridge cleanly to ObjC via `PrebidMobile-Swift.h`; no ObjC consumer `.m` changes needed beyond removing the deleted `#import`
- `ViewExposure` protocol and `ViewExposureChecker` are `@_spi(PBMInternal)` — new Swift implementations must carry the same annotation
- `Factory` (Swift name) not `PBMFactory` (ObjC name) for the runtime class registry
- `NSClassFromString("PBMViewExposure_Objc")` in `Factory.swift` requires the ObjC bridge name `@objc(PBMViewExposure_Objc)` preserved on the Swift class
- `NSString` nil-param bridging: ObjC `nil NSString*` → Swift `String` becomes `""`. For methods that had ObjC nil guards, change parameter type to `String?` so nil passes through correctly
- `logViewHierarchy()`: Swift name (lowercase) exposed via `@objc(LogViewHierarchy)` to keep ObjC selector intact while matching what Swift test code calls
- `ViewExposureChecker.exposure` debug path: accesses `Prebid.shared.forcedIsViewable` (ObjC category, private header) via KVC `value(forKey:)` to avoid Gap 8

**ObjC consumer updates:**
- Added `#import "SwiftImport.h"` to `PBMURLComponents.m` (used `NSString+PBMExtensions` methods)
- Removed `#import` of deleted headers from `PBMAbstractCreative.m`, `PBMAdViewManager.m`, `PBMMRAIDController.m`, etc. (12 files total)
- Removed deleted headers from `PrebidMobileTest-Bridging-Header.h` and two ObjC test files

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean (all steps)
### S2.3 — NSTimer wrapper

Ported `NSTimer+PBMScheduledTimerFactory` and `PBMWeakTimerTargetBox`. Also added `TimerInterface` as a Swift `@objc protocol` replacing the ObjC-only `PBMTimerInterface`.

**Key findings:**
- `NSInvocationOperation` unavailable in Swift — replaced with `NSObject.perform(_:with:)` (semantically equivalent for synchronous selector invocation)
- `PBMScheduledTimerFactory` ObjC block typedef cannot be exported from Swift as a named type — kept in `PBMScheduledTimerFactory.h` (header-only, no `.m`); Swift closure `(TimeInterval, AnyObject, Selector, Any?, Bool) -> TimerInterface` is structurally compatible with the ObjC typedef, so ObjC callers assign without explicit casts
- `PBMScheduledTimerFactory.h` needed `#import <Foundation/Foundation.h>` added directly after `PBMTimerInterface.h` was reduced to a forward declaration (lost the transitively-imported Foundation types)

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean (all phases)
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 694 tests, 0 failures (S2.3 final)
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite (pending)
- [ ] Reviewer: confirm gap S2.1-A (NS_TYPED_ENUM deferred) and gap S2.1-B (@_spi imports in tests)
