# [swift-migration] Phase 2 — Utilities & extensions

Ports all files in `PrebidMobile/Objc/PrebidMobileRendering/Utilities/` and
`ExtensionsAndWrappers/` to Swift in three steps (S2.1–S2.3), building on the
conventions established in Phase 1.

**Base branch:** `swift-migration-phase-1`

---

## What changed

### S2.1 — Standalone utilities (`Utilities/`)

**New Swift files:**

| Swift | Replaces ObjC |
|-------|--------------|
| `Functions.swift` (extended) + `Functions+Testing.swift` | `PBMFunctions.m` + `PBMFunctions+Testing.m` |
| `PBMUIApplicationProtocol.swift` | `PBMUIApplicationProtocol.h` (protocol moved from ObjC) |
| `MRAIDConstants.swift` | `PBMMRAIDConstants.m` (classes only — see note) |
| `DeepLinkPlus.swift` | `PBMDeepLinkPlus.m` |
| `DeviceAccessManagerKeys.swift` | `PBMDeviceAccessManagerKeys.m` |
| `DownloadDataHelper.swift` | `PBMDownloadDataHelper.m` |
| `CircularProgressBarLayer.swift` | `PBMCircularProgressBarLayer.m` |
| `CircularProgressBarView.swift` | `PBMCircularProgressBarView.m` |
| `WKScriptMessageHandlerLeakAvoider.swift` | `PBMWKScriptMessageHandlerLeakAvoider.m` |

**Intentionally deferred (still ObjC):**
- `PBMDeepLinkPlusHelper` — deferred to Phase 4; depends on `PBMExternalLinkHandler` / `PBMExternalURLOpeners` / `PBMTrackingURLVisitors` (private headers, Gap 8)
- `PBMWindowLocker` — deferred to Phase 8; depends on `PBMOpenMeasurementSession` (private header, Gap 8)

**Partial migration — `PBMMRAIDConstants`:**  
ObjC classes (`PBMMRAIDParseKeys`, `PBMMRAIDValues`, etc.) moved to `MRAIDConstants.swift`.  
The `NS_TYPED_ENUM` string constants (`PBMMRAIDActionLog`, `PBMMRAIDFeatureCalendar`, etc.) remain in a residual `PBMMRAIDConstants.m` — these are `FOUNDATION_EXPORT NSString * const` globals, which cannot be reproduced as named ObjC-visible constants from Swift. They will be deleted in Phase 7 when the last ObjC MRAID consumer is ported (new gap S2.1-A in playbook).

---

### S2.2 — Foundation/UIKit category extensions (`ExtensionsAndWrappers/`)

**New Swift files:**

| Swift | Replaces ObjC |
|-------|--------------|
| `NSDictionary+PBMExtensions.swift` | `NSDictionary+PBMExtensions.m` |
| `NSMutableDictionary+PBMExtensions.swift` | `NSMutableDictionary+PBMExtensions.m` |
| `NSString+PBMExtensions.swift` | `NSString+PBMExtensions.m` |
| `NSURL+PBMExtensions.swift` | `NSURL+PBMExtensions.m` |
| `NSException+PBMExtensions.swift` | `NSException+PBMExtensions.m` |
| `UIView+PBMExtensions.swift` | `UIView+PBMExtensions.m` |
| `UIWindow+PBMExtensions.swift` | `UIWindow+PBMExtensions.m` |
| `Exposure/ViewExposureImpl.swift` | `Exposure/PBMViewExposure.m` |
| `Exposure/ViewExposureChecker.swift` | `Exposure/PBMViewExposureChecker.m` |
| `Exposure/UIView+PBMViewExposure.swift` | `Exposure/UIView+PBMViewExposure.m` |

`ViewExposureImpl` carries `@objc(PBMViewExposure_Objc)` to satisfy the `NSClassFromString("PBMViewExposure_Objc")` lookup in `Factory.swift`.

**Dropped, not ported — `PBMTouchDownRecognizer`:** removed upstream by "fix: register click on touch up" (#1294), which replaced `PBMWebView`/`PBMVideoView`'s tap-down recognizer with a plain `UITapGestureRecognizer` + `shouldReceiveTouch:`. Rebasing onto that fix superseded the Swift port; `TouchDownRecognizer.swift` and its test were dropped rather than reconciled.

---

### S2.3 — NSTimer wrapper (`ExtensionsAndWrappers/NSTimer/`)

**New Swift files:**

| Swift | Replaces ObjC |
|-------|--------------|
| `TimerInterface.swift` | `PBMTimerInterface.h` (protocol, header-only — moved to Swift) |
| `NSTimer+PBMScheduledTimerFactory.swift` | `NSTimer+PBMScheduledTimerFactory.m` |
| `WeakTimerTargetBox.swift` | `PBMWeakTimerTargetBox.m` |

`NSInvocationOperation` (ObjC-only) replaced with `NSObject.perform(_:with:)`.  
`PBMScheduledTimerFactory` ObjC block typedef kept in `PBMScheduledTimerFactory.h` (header-only, not deleted) — Swift closure type is structurally compatible with the typedef so ObjC callers assign without casts.

---

## Non-trivial decisions / gaps codified in playbook

| Gap | Summary |
|-----|---------|
| S2.1-A | `NS_TYPED_ENUM` constants can't be free-standing ObjC constants from Swift; keep residual `.m` |
| S2.1-B | `Functions` is `@_spi(PBMInternal)` — test files that access it need `@_spi(PBMInternal) @testable import` |
| S2.1-C | `dispatch_time()` unavailable → `(DispatchTime(uptimeNanoseconds:) + interval).rawValue` |
| S2.1-D | `UIInterfaceOrientationIsPortrait()` unavailable → `.isPortrait` property |
| S2.1-E | `@objc(name:)` on `throws` must include `:error:` in the selector label |
| S2.1-F | CALayer `@dynamic` → `@NSManaged` in Swift |
| S2.1-G | Porting `@objc protocol` to Swift: reduce ObjC header to forward-decl `@protocol Foo;` |
| S2.2-A | `@objc extension` on Foundation types bridges automatically via `PrebidMobile-Swift.h` |
| S2.2-B | ObjC `nil NSString*` → Swift `""` — use `String?` params to preserve nil-guards |
| S2.2-C | `@_spi` protocol conformers must inherit `@_spi` on the conforming class |
| S2.2-D | Use Swift name `Factory` (not ObjC bridge name `PBMFactory`) in Swift code |
| S2.2-E | ObjC capital-initial method `LogViewHierarchy` → `@objc(LogViewHierarchy) func logViewHierarchy()` |
| S2.2-F | `#ifdef DEBUG` ObjC category property → KVC `value(forKey:)` in Swift (Gap 8 workaround) |
| S2.3-A | `NSInvocationOperation` → `NSObject.perform(_:with:)` |
| S2.3-B | ObjC block typedef is header-only; structural block-type compatibility means no cast needed |
| S2.3-C | Reducing a header to forward-decl loses transitive Foundation types; add `#import <Foundation/Foundation.h>` to dependents |

Full details in [`docs/migration/playbook.md`](docs/migration/playbook.md).

---

## ObjC consumer changes (files not yet ported)

- Removed deleted `#import` lines from 17 `.m` files (consumers of `PBMFunctions.h`, `PBMFunctions+Private.h`, etc.)
- Added `#import "PBMConstants.h"` to 3 files that lost the `PBMJsonDictionary` typedef
- Added `#import "SwiftImport.h"` to `PBMExternalURLOpeners.m` and `PBMURLComponents.m`
- Added `#import <UIKit/UIKit.h>` to `PBMMRAIDController.h`
- Added `#import <Foundation/Foundation.h>` to `PBMScheduledTimerFactory.h`
- Reduced `PBMUIApplicationProtocol.h` and `PBMTimerInterface.h` to forward declarations
- Updated `PBMMRAIDConstants.h` — removed class `@interface` blocks (classes now in Swift)
- Updated `PBMCreativeFactory.h` — defined `PBMDownloadDataCompletionClosure` inline (formerly in deleted `PBMDownloadDataHelper.h`)
- Updated `PrebidMobileTest-Bridging-Header.h` — removed all deleted header imports
- Updated `MockUIApplication` — added `NSObject` superclass (required by `PBMUIApplicationProtocol: NSObjectProtocol`)

---

## Test results

| Run | Result |
|-----|--------|
| `./scripts/buildPrebidMobile.sh` | ✅ All 4 XCFrameworks clean |
| `./scripts/testPrebidMobile.sh --latest --quick` | ✅ 694 tests, 0 failures |
| `./scripts/testPrebidMobile.sh --latest` | ⏳ Pending (full suite — run before merge) |

---

## Reviewer checklist

- [ ] Gap S2.1-A: residual `PBMMRAIDConstants.m` (constants only) is intentional — confirmed
- [ ] Gap S2.1-B: `@_spi(PBMInternal) @testable import` in test files is intentional — confirmed
- [ ] `@objc(PBMViewExposure_Objc)` on `ViewExposureImpl` is required for `NSClassFromString` in `Factory.swift` — confirmed
- [ ] `PBMScheduledTimerFactory.h` kept (header-only typedef) — confirmed intentional
- [ ] `PBMDeepLinkPlusHelper` and `PBMWindowLocker` left in ObjC — deferral rationale accepted
