## Summary

Phase 1 ports all 25 ObjC ORTB bid-request model files to Swift in four steps (S1.1–S1.4), establishing naming and bridging conventions used throughout the migration. The implementation is clean and methodical: bridge annotations complete, JSON key strings match ObjC originals, all gaps (6–10, NSMutableDictionary decode, NSCopying) are handled correctly, ObjC consumers patched, `project.pbxproj` clean. Test suite passes: 693 tests (quick), 1110 (full).

**Verdict: Approve.** Two low-priority suggestions noted below.

---

## Blockers

None.

---

## Suggestions

**1. `ORTBBidRequestExtPrebid`: `targeting` / `cache` silently drop on JSON decode**

`init(jsonDictionary:)` doesn't restore `targeting` or `cache` from JSON (matches ObjC). This is intentional, but a future reader will likely assume the omission is a bug. A one-line comment would prevent a misguided "fix":

```swift
// targeting and cache are write-only via API; not populated on decode (matches ObjC parity)
@objc public var targeting: NSMutableDictionary = NSMutableDictionary()
@objc public var cache: NSMutableDictionary?
```

**2. `ORTBRegs`: new `gpp`/`gppSID` decode has no test coverage**

ObjC `initWithJsonDictionary:` only decoded `coppa`. Swift now also decodes `gpp` and `gppSID` — strictly better round-trip. But `testRegsToJsonString()` only exercises `coppa`. Consider adding a round-trip test for `gpp`/`gppSID` now that they decode correctly.

---

## Migration checklist

- [x] `@objc public class` + `@objc public var` on all types/properties
- [x] `@objc(initWithJsonDictionary:)` and `@objc(toJsonDictionary)` annotations
- [x] JSON key strings match ObjC originals
- [x] `NSMutableDictionary(dictionary:)` decode pattern on all `NSMutableDictionary *` properties (`ORTBUser.ext`, `ORTBImp.extData`)
- [x] `ORTBGeo.lat`/`lon` use `NSDecimalNumber(decimal:)` for float precision
- [x] `ORTBBidRequest` implements `NSCopying` via JSON round-trip
- [x] `ORTBFormat` overrides `isEqual`/`hash` for NSSet dedup
- [x] `JSONObject.dict` private(set) workaround applied in `ORTBDevice`, `ORTBUser`, `ORTBRegs`, `ORTBSource`, `ORTBImp`
- [x] All 24 ObjC `.m` deleted; all private `.h` deleted; `project.pbxproj` clean
- [x] `PBMORTB.h` stripped to `#import "SwiftImport.h"` only
- [x] `PBMORTBAbstract.h` + `+Protected.h` retained for Phase 3/4 consumers
- [x] ObjC consumers patched (`PBMAppInfoParameterBuilder.m`, `PBMORTBParameterBuilder.m`, `PBMPrebidParameterBuilder.m`)
- [x] `extension PBMORTBAbstract: PBMJsonCodable` removed from `PBMORTBTest.swift`
- [x] All test files renamed (`PBMORTBFoo` → `ORTBFoo`) via `perl -pi`
- [x] `SharedIdTests` updated to `ORTBBidRequest`
- [x] `from(jsonString:)` shim added to `ORTBParityHelper`, `codeAndDecode<T: PBMORTBAbstract>` overload removed
- [x] Playbook and `pr-phase-1.md` updated
- [x] Build + quick/full tests green

---

## Nits

- `PBMORTBAbstractTest` class name (line 21) and the comment on line 41 ("objects descending from PBMORTBAbstract") are legacy labels; harmless but could be cleaned up to `ORTBAbstractTest` in a follow-up.
- `ORTBRendererConfig` has no comment explaining why it's a plain `NSObject` (not `PBMJsonCodable`). Fine since it's in the playbook, but a one-liner at the class declaration would be self-documenting for reviewers who don't read the playbook.
