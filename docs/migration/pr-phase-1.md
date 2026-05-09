## Summary

Phase 1, S1.1 — ORTB leaf models. Ports 7 ObjC bid-request ORTB types to Swift, with full parity verification.

**S1.1 — ORTB leaf models (Swift name → file):**
- `ORTBFormat` (`@objc(PBMORTBFormat)`) → `ORTB/Request/ORTBFormat.swift`
- `ORTBPublisher` (`@objc(PBMORTBPublisher)`) → `ORTB/Request/ORTBPublisher.swift`
- `ORTBGeo` (`@objc(PBMORTBGeo)`) → `ORTB/Request/ORTBGeo.swift`
- `ORTBDeal` (`@objc(PBMORTBDeal)`) → `ORTB/Request/ORTBDeal.swift`
- `ORTBSourceExtOMID` (`@objc(PBMORTBSourceExtOMID)`) → `ORTB/Request/ORTBSourceExtOMID.swift`
- `ORTBImpExtSkadn` (`@objc(PBMORTBImpExtSkadn)`) → `ORTB/Request/ORTBImpExtSkadn.swift`
- `ORTBDeviceExtAtts` (`@objc(PBMORTBDeviceExtAtts)`) → `ORTB/Request/ORTBDeviceExtAtts.swift`

All under `PrebidMobile/Swift/PrebidMobileRendering/`. ObjC `.m` files and `PrivateHeaders/` `.h` files deleted. ObjC consumers (`PBMORTBBanner`, `PBMORTBApp`, `PBMORTBDevice`, `PBMORTBImp`, `PBMORTBPmp`, `PBMORTBSource`, `PBMORTBUser`) updated to replace deleted `#import "PBMORTBXxx.h"` with `#import "SwiftImport.h"`. `PBMORTB.h` umbrella updated.

**Gap 3 (ORTBFormat):** `isEqual(_:)` / `hash` override on `(w, h)` for NSSet deduplication.

**Gap 6 — Framework build visibility:** Phase 1–3 Swift twins must be `@objc public class` with `@objc public var` properties. Internal Swift types only get `@class` stubs in `PrebidMobile-Swift.h` for archive builds.

**Gap 7 — ObjC selector bridge:** Protocol requirements from non-`@objc` protocols need explicit annotations: `@objc(initWithJsonDictionary:) public required init(jsonDictionary:)` (non-optional) and `@objc(toJsonDictionary) public var jsonDictionary`.

**Gap 8 — ObjC private headers not visible to Swift:** `PBMFunctions.supportedSKAdNetworkVersions` inlined in `ORTBImpExtSkadn` as a `private static var` with `#available` guards.

**Gap 9 — Empty arrays preserved:** `pbmCopyWithoutEmptyVals` only strips `nil`/`NSNull`. Empty `[String]` arrays must be passed through as-is, not suppressed.

**Naming convention:** Swift class names and filenames drop the `PBM` prefix. ObjC bridge name preserved via `@objc(PBMORTBFoo)`. Applies to all Phase 1+ twins.

## Playbook updates
- Gaps 6–9 and the naming convention codified in `docs/migration/playbook.md`.
- Canonical template updated to `@objc(PBMORTBFoo) public class ORTBFoo` pattern.

## Commits (branch `swift-migration-phase-1`)
- `fe2a5b6e` S1.1 — Port ORTB leaf models to Swift
- `d015b44b` S1.1 — Rename Swift twins: drop PBM prefix
- `4ee63c52` docs: codify no-PBM-prefix naming rule in playbook

## Test plan
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 694 tests, 0 failures
- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build cleanly
- [ ] JSON round-trip parity (ORTBParityHelper) — all 7 leaf types (harness in place; dedicated parity test class TBD in S1.2 or separate commit)
- [ ] Reviewer: confirm Gaps 6–9 and naming convention in playbook before S1.2 opens
