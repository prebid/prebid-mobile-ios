## Summary

Phase 1 — ORTB bid-request models (all 25 files in `PrebidMobile/Objc/PrebidMobileRendering/ORTB/`). Ports in 4 steps; S1.1–S1.3 complete, S1.4 remaining.

All Swift twins live under `PrebidMobile/Swift/PrebidMobileRendering/Prebid/PBMCore/ORTB/`.
Naming: Swift class = `ORTBFoo`, file = `ORTBFoo.swift`, ObjC bridge = `@objc(PBMORTBFoo)`.

---

### S1.1 — ORTB leaf models (7 types)

`ORTBFormat`, `ORTBPublisher`, `ORTBGeo`, `ORTBDeal`, `ORTBSourceExtOMID`, `ORTBImpExtSkadn`, `ORTBDeviceExtAtts`

Key findings: Gaps 6–9 discovered (framework visibility, ObjC selector bridge, empty arrays, private headers). Naming convention established.

### S1.2 — Composite request blocks (5 types)

`ORTBBanner`, `ORTBVideo`, `ORTBPmp`, `ORTBImpExtPrebid`, `ORTBImp`

Key findings: Gap 10 — `JSONObject.dict` is `private(set)`; use `var result = json.dict` for untyped sub-dict injection. Test files need `perl -pi` rename after each step.

### S1.3 — Top-level objects (10 types)

`ORTBAppExtPrebid`, `ORTBAppExt`, `ORTBApp`, `ORTBDeviceExtPrebidInterstitial`, `ORTBDeviceExtPrebid`, `ORTBDevice`, `ORTBUser`, `ORTBRegs`, `ORTBSource`, `ORTBRendererConfig`

Key findings:
- `ORTBRendererConfig` is plain `NSObject` (not `PBMORTBAbstract`) — no `PBMJsonCodable`, just a custom designated init.
- `ORTBAppExt.data` typed `[String: [String]]?` (not `Any`) to match ObjC generic.
- `ORTBDevice.jsonDictionary`: conditional `ifa`/`dpid`/`mac` block; merges `extPrebid` + `extAtts` into `ext`.
- `ORTBRegs.coppa`: validated computed property — only 0 or 1 accepted.
- `ORTBUser.appendEids(_:)`: `@objc` method preserved for ObjC callers.
- Gap 10 applies in `ORTBRegs`, `ORTBSource`, `ORTBUser`.
- Flaky test clarified: `PBMBidRequesterTest.testBanner_300x250` fails in full-suite (simulator load) but passes in isolation — confirmed not a regression.

### S1.4 — Root container ✅

`ORTBBidRequestExtPrebid`, `ORTBBidRequest`. `PBMORTBAbstract.m` deleted (headers kept for Phase 3/4). `PBMORTB.h` stripped to just `SwiftImport.h`. No separate `PBMORTBParameterBuilder` existed in the ORTB directory.

Key findings:
- `ORTBBidRequest` needs `NSCopying` — ObjC abstract base had it; Swift `NSObject` does not. Implemented via JSON round-trip.
- `ORTBUser.ext` (and any `NSMutableDictionary *` property): `JSONSerialization` returns immutable `NSDictionary`; cast to `NSMutableDictionary?` silently returns nil. Fix: wrap with `NSMutableDictionary(dictionary:)` on decode. Broke `SharedIdTests` (EIDs disappeared after round-trip).
- Deleting `PBMORTBAbstract.m` cascades into test files: `from(jsonString:)` shim added to `ORTBParityHelper.swift`; `codeAndDecode<T: PBMORTBAbstract>` overload removed; `testAbstractMethods()` removed; `extension PBMORTBAbstract: PBMJsonCodable` removed.

---

## Gaps discovered (all codified in playbook.md)

| Gap | Summary |
|-----|---------|
| 3 | `ORTBFormat` needs `isEqual`/`hash` override for NSSet dedup |
| 6 | `@objc public class` + `@objc public var` required for framework archive build |
| 7 | Explicit `@objc(initWithJsonDictionary:)` and `@objc(toJsonDictionary)` annotations |
| 8 | ObjC private headers not visible to Swift — inline logic instead |
| 9 | `pbmCopyWithoutEmptyVals` keeps empty arrays — do not suppress |
| 10 | `JSONObject.dict` is `private(set)` — use `var result = json.dict` for ext injection |
| — | Non-`PBMJsonCodable` types: plain `NSObject` subclasses ported without protocol |
| — | Typed ObjC generics: use `[String: [String]]?` not `[String: Any]?` when it matters |

## Commits (branch `swift-migration-phase-1`)

- `fe2a5b6e` S1.1 — Port ORTB leaf models to Swift
- `d015b44b` S1.1 — Rename Swift twins: drop PBM prefix
- `4ee63c52` docs: codify no-PBM-prefix naming rule in playbook
- `5a82caa3` docs: update pr-phase-1 with S1.1 completion
- `9f86c80f` S1.2 — Port composite ORTB request blocks
- `02b6fe8b` docs: update playbook with S1.2 learnings
- `2781f57b` S1.3 — Port top-level ORTB request objects
- `d43722b9` docs: update playbook and pr-phase-1 with S1.3 learnings
- `a6fa9c76` S1.4 — Port root ORTB container; Phase 1 complete

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 693 tests, 0 failures (Phase 1 final)
- [x] `./scripts/testPrebidMobile.sh --latest` — 1110 tests, 0 failures (Phase 1 final)
- [x] JSON round-trip parity: `ORTBParityHelper` harness in place; `from(jsonString:)` shim added
- [ ] Reviewer: confirm all gap decisions in playbook.md before merging
