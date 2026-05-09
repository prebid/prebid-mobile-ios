## Summary

Phase 1, S1.1 — ORTB leaf models. Ports 7 ObjC bid-request ORTB types to Swift, with full parity verification.

**S1.1 — ORTB leaf models:**
- `PBMORTBFormat` → `PrebidMobile/Swift/PrebidMobileRendering/ORTB/Request/PBMORTBFormat.swift`
- `PBMORTBPublisher` → `...PBMORTBPublisher.swift`
- `PBMORTBGeo` → `...PBMORTBGeo.swift`
- `PBMORTBDeal` → `...PBMORTBDeal.swift`
- `PBMORTBSourceExtOMID` → `...PBMORTBSourceExtOMID.swift`
- `PBMORTBImpExtSkadn` → `...PBMORTBImpExtSkadn.swift`
- `PBMORTBDeviceExtAtts` → `...PBMORTBDeviceExtAtts.swift`

ObjC `.m` files and `PrivateHeaders/` `.h` files deleted. ObjC consumers (`PBMORTBBanner`, `PBMORTBApp`, `PBMORTBDevice`, `PBMORTBImp`, `PBMORTBPmp`, `PBMORTBSource`, `PBMORTBUser`) updated to replace deleted `#import "PBMORTBXxx.h"` with `#import "SwiftImport.h"`. `PBMORTB.h` umbrella updated.

**Gap 3 (PBMORTBFormat):** `isEqual(_:)` / `hash` override implemented using `w` and `h` fields, matching ObjC behaviour.

**New gap discovered (Gap 6) — Framework build visibility:** Phase 1–3 Swift twins must be `@objc public class` with `@objc public var` properties. Intra-module ObjC consumers (in the same framework target) can only call methods that appear with full `@interface` in `PrebidMobile-Swift.h`. For a framework archive build, Swift types with `internal` access only appear as `@class` forward stubs — the ObjC consumers get "forward declaration" errors. The fix: `public` on the class and all `@objc` properties.

**New gap discovered (Gap 7) — ObjC selector bridge:** Protocol requirements from non-`@objc` protocols (`PBMJsonDecodable.init?`, `PBMJsonEncodable.jsonDictionary`) do NOT get automatic `@objc` inference. Must use explicit bridge annotations:
- Init: `@objc(initWithJsonDictionary:) public required init(jsonDictionary:)` (non-optional, matching `ORTBAppContent` pattern)
- Encode: `@objc(toJsonDictionary) public var jsonDictionary: [String: Any]`

**New finding — empty arrays NOT stripped:** `pbmCopyWithoutEmptyVals` only strips `nil` / `NSNull` values. Empty arrays (`[]`) are preserved. Swift twins must not suppress empty `[String]` properties — pass them through as-is.

**`PBMFunctions.supportedSKAdNetworkVersions` not visible from Swift (Gap 8):** ObjC private headers are not bridged to Swift in a framework build. Inlined directly in `PBMORTBImpExtSkadn.swift` as `static var supportedSKAdNetworkVersions: [String]` with `#available` guards matching the ObjC logic.

## Playbook updates
- Gaps 6, 7, 8 added to `docs/migration/playbook.md`.
- Canonical template updated to `@objc public class` / `@objc(initWithJsonDictionary:) public required init` / `@objc(toJsonDictionary) public var jsonDictionary`.

## Test plan
- [ ] `./scripts/testPrebidMobile.sh --latest --quick` — 694 tests, 0 failures
- [ ] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build cleanly
- [ ] JSON round-trip parity (ORTBParityHelper) — all 7 leaf types
- [ ] Reviewer: confirm Gap 6/7/8 additions to playbook before S1.2 opens
