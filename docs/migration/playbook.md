# Swift Migration Playbook

Per-class file-level porting guide for migrating `PrebidMobile/Objc/` to Swift.
Full phasing plan: TaskNotes task "[PI][PREBID] Develop a plan to migrate the iOS SDK to Swift"
(authoritative step list — a PR titled "Phase N" is not self-evidently all of Phase N).

## Per-class steps

For each `Foo.m` + `Foo.h`:

1. Create `Foo.swift` at the mirrored path under `PrebidMobile/Swift/...`.
2. Declare `@objc class PBMORTBFoo: NSObject, PBMJsonCodable` — see Gap 4.
3. Port property declarations 1:1, preserving exact JSON key strings.
4. Implement `init?(jsonDictionary:)` using `JSONObject<KeySet>` subscripts (pattern in `ORTBBid.swift`).
5. Implement `var jsonDictionary: [String: Any]` using `JSONObject<KeySet>` — the subscript setter for `PBMJsonCodable` values already suppresses empty child dicts (Gap 2); no `nullIfEmpty` needed.
6. `fromJsonString:`/`toJsonStringWithError:` — do **not** reimplement; inherited from `PBMJsonDecodable`/`PBMJsonEncodable` default extensions.
7. Replace `PBMJsonDictionary` typedef with `[String: Any]` at every site touched.
8. Do **not** add `NSCopying` (Gap 1).
9. Update ObjC consumers to import `PrebidMobile-Swift.h` (automatic once the `.h`/`.m` are deleted).
10. Delete `Foo.m`, `Foo.h`, and any matching entry in `PrebidMobile/Objc/PrivateHeaders/`.
11. Verify: `./scripts/testPrebidMobile.sh --latest --quick`.

## Gap audit findings (S0.1)

- **Gap 1 — no `NSCopying`.** Zero callers of `PBMORTBAbstract`'s JSON-round-trip `copyWithZone:` on ORTB models. Swift twins skip it (exception: root containers actually `.copy()`'d — S1.4).
- **Gap 2 — empty child dict suppression.** ObjC does `[[child toJsonDictionary] nullIfEmpty]` so an empty child never serializes as `"app": {}`. `JSONObject`'s `PBMJsonCodable` subscript setter replicates this:
  ```swift
  set {
      let childDict = newValue?.jsonDictionary
      dict[key.rawValue] = (childDict?.isEmpty == true) ? nil : childDict
  }
  ```
- **Gap 3 — `ORTBFormat` needs `isEqual`/`hash`.** Deduped via `NSSet` (`w`/`h` keyed). Swift twin overrides both:
  ```swift
  override func isEqual(_ object: Any?) -> Bool {
      guard let other = object as? PBMORTBFormat else { return false }
      return w == other.w && h == other.h
  }
  override var hash: Int { (w?.hashValue ?? 0) ^ (h?.hashValue ?? 0) }
  ```
- **Gap 4 — Phase 1–3 twins are `@objc NSObject` subclasses.** Response-side types are plain Swift (Swift-only consumers). Request-side (Phase 1) models are still read by ObjC parameter builders → need `NSObject` bridging. *Correction (S3.2):* still consumed post-Phase-3 by `PBMPrebidParameterBuilder.m`, `PBMBidRequester.m`, `PBMBidResponseTransformer.m`, `PBMWebView.m` — keep `NSObject` until all four are ported (S9.x).
- **Gap 5 — `init?(jsonDictionary:)` returns `nil` on failure**, unlike ObjC's broken-instance fallback — correct as-is; audit tests relying on the broken instance.
- **Gap 6 — framework build visibility.** `internal` Swift types appear only as `@class` stubs in `PrebidMobile-Swift.h` under a framework archive build → ObjC "forward declaration" errors. All Phase 1–3 twins must be `@objc public class` + `@objc public var`. Demote to `internal` only in S9.2 (blocked on Gap 4).
- **Gap 7 — explicit ObjC selector bridges required.** Non-`@objc`-protocol requirements (`PBMJsonDecodable.init?`, `PBMJsonEncodable.jsonDictionary`) don't get automatic `@objc` inference even on `public NSObject` subclasses:
  ```swift
  @objc(initWithJsonDictionary:) public required init(jsonDictionary: [String: Any]) { super.init(); ... }
  @objc(toJsonDictionary) public var jsonDictionary: [String: Any] { ... }
  ```
- **Gap 8 — ObjC private headers invisible to Swift in framework builds.** Never call ObjC private-header functions (e.g. `PBMFunctions.h`) from Swift twins — inline the logic (e.g. `PBMORTBImpExtSkadn` inlines `supportedSKAdNetworkVersions` with `#available` guards).
- **Gap 9 — empty arrays are preserved.** `pbmCopyWithoutEmptyVals`/`pbmRemoveEmptyVals` strip only `nil`/`NSNull`, never `[]`. Don't add `.isEmpty ? nil : array` guards on `[String]` properties.
- **Naming convention — no `PBM` prefix (S1.1).** Swift class = `ORTBFoo` (file `ORTBFoo.swift`), ObjC bridge name preserved via `@objc(PBMORTBFoo)`. Applies Phase 1 onward — exception: S3.3-A.

## Canonical Swift twin template

```swift
// PrebidMobile/Swift/PrebidMobileRendering/Prebid/PBMCore/ORTB/Request/ORTBFoo.swift
import Foundation

@objc(PBMORTBFoo)
public class ORTBFoo: NSObject, PBMJsonCodable {

    @objc public var someField: NSNumber?
    @objc public var anotherField: String?

    public override init() { super.init() }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        someField    = json[.someField]
        anotherField = json[.anotherField]
    }

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.someField]    = someField
        json[.anotherField] = anotherField
        return json.dict
    }

    private enum Key: String {
        case someField    = "somefield"
        case anotherField = "anotherfield"
    }
}
```

Key points: no `PBM` prefix on the Swift name/file; `@objc(PBMORTBFoo)` bridge; `@objc public class` + `@objc public var` (Gap 6); explicit `@objc(initWithJsonDictionary:)`/`@objc(toJsonDictionary)` (Gap 7); `super.init()` first in the JSON init; no `NSCopying`; no `toJsonStringWithError:`/`fromJsonString:` (inherited); child `PBMJsonCodable` empty-dict suppression is automatic (Gap 2); empty `[String]` arrays pass through as-is (Gap 9). For a key not in the typed `Key` enum (dynamic `ext` sub-dict), mutate the dict returned by `json.dict` — it's `private(set)` (Gap 10 below).

**Gap 10 (S1.2) — untyped sub-dict encoding.** When the wire format needs a raw `[String: Any]` outside the typed `Key` enum (e.g. `ORTBImp.ext`):
```swift
public var jsonDictionary: [String: Any] {
    var json = JSONObject<Key>()
    // ... typed subscript assignments
    var result = json.dict
    let ext = extDictionary
    if !ext.isEmpty { result["ext"] = ext }
    return result
}
```

## Swift test file updates after each migration step

`'PBMORTBFoo' has been renamed to 'ORTBFoo'` compiler errors → bulk-rename with `perl -pi` (BSD `sed -i ''` doesn't reliably handle `\b`):
```bash
perl -pi -e 's/PBMORTBFoo\b/ORTBFoo/g' PrebidMobileTests/path/to/TestFile.swift
```
Scan at minimum: `PBMORTBAbstractTest.swift`, `PBMORTBBidRequestTest.swift`, `PrebidParameterBuilderTest.swift`, and any other Swift test touching the migrated types. Catch stragglers:
```bash
xcodebuild ... build-for-testing 2>&1 | grep "error:" | grep "has been renamed"
```

## Known flaky test — `PBMBidRequesterTest.testBanner_300x250` only

Allowlist of exactly this one test, not a general "re-run and move on" policy. Pre-existing timing flakiness (`Asynchronous wait failed`), reproducible on `master` with no Swift twins present (confirmed S1.3: fails 2x in full-suite runs, passes in isolation — simulator resource pressure under full-suite load, not a regression).

**Rule:** before dismissing a failure as this flake, confirm all three: (1) it's the only failure, (2) it passes alone (`-only-testing .../testBanner_300x250`), (3) your step touched nothing in the bid-request/networking path. Any other flaky-looking failure must be investigated. Never silence it by relaxing the test.

## S1.3/S1.4 porting notes

- **Non-`PBMJsonCodable` types.** Some ORTB classes are plain `NSObject` subclasses (custom init, no JSON bridge) — check the superclass before porting. Port as plain `@objc public class ORTBFoo: NSObject` with the custom init, no `PBMJsonCodable`. Example: `ORTBRendererConfig`.
- **Typed generic dicts.** A parameterized `NSDictionary<KeyType, ValueType>*` needs the matching concrete Swift type, not `[String: Any]` — e.g. `PBMORTBAppExt.data` → `[String: [String]]?`. `[String: Any]?` compiles but breaks `.sorted()` calls in tests.
- **Non-optional ObjC properties in test code.** A non-`nullable` property ported to `NSNumber?` needs `?.` chains in tests changed to `.`. Catch with `grep "cannot use optional chaining on non-optional"`.
- **`NSCopying` on root containers.** `NSObject` subclasses do NOT inherit `NSCopying` — `.copy()` crashes at runtime if not added explicitly, via JSON round-trip:
  ```swift
  public func copy(with zone: NSZone? = nil) -> Any { Self(jsonDictionary: jsonDictionary) }
  ```
  Phase 1: only `ORTBBidRequest` needed this (its `.copy()` is called by test code).
- **`NSMutableDictionary` from JSON decode.** `JSONSerialization` always returns immutable `NSDictionary`, so `jsonDictionary["ext"] as? NSMutableDictionary` silently yields `nil` for an ObjC `NSMutableDictionary *` property (`PBMORTBUser.ext`, `PBMORTBRegs.ext`). Decode via:
  ```swift
  if let extDict = jsonDictionary["ext"] as? [String: Any] {
      ext = NSMutableDictionary(dictionary: extDict)
  }
  ```
  Forgetting this silently drops round-tripped `ext` contents (e.g. EIDs disappear after serialize/deserialize).
- **Deleting `PBMORTBAbstract` — cascade.** Removes `from(jsonString:)`, `copyWithZone:`, abstract fallback impls. Checklist: (1) replace `PBMORTBAbstract.from(jsonString:)`/`SomeType.from(jsonString:)` test calls with the `PBMJsonDecodable.from(jsonString:)` shim in `ORTBParityHelper.swift`; (2) remove `extension PBMORTBAbstract: SomeProtocol` test blocks; (3) remove `codeAndDecode<T: PBMORTBAbstract>` overloads (the `PBMJsonCodable` overload covers all Swift types); (4) delete `testAbstractMethods()` tests; (5) **keep** `PBMORTBAbstract.h`/`+Protected.h` — Phase 3/4 ObjC parameter builders still import them.

## Validation checklist per PR

- [ ] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [ ] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build clean (catches header-visibility breakage the CocoaPods build masks — Gap S2.5-A)
- [ ] `./scripts/testPrebidMobile.sh --latest --quick` — clean pass (re-run once if only `PBMBidRequesterTest.testBanner_300x250` fails)
- [ ] Swift test files updated: no `'PBMORTBFoo' has been renamed` errors
- [ ] (Phase 1 & 3) JSON round-trip parity test passes (S0.2 harness)
- [ ] (Phase 1 & 3) Each migrated model has a **partial**-payload decode test asserting the re-encoded key set — a full fixture can't catch a resurrected default (Gap S2.5-C)
- [ ] No `"app": {}` / `"device": {}` empty-object regressions in captured bid requests
- [ ] PR doc states its **scope boundary** — which `S<phase>.<step>`s it lands and which ObjC files it deliberately leaves behind (added S3.2)

## Phase 2 gaps (S2.1)

- **S2.1-A** — `NS_TYPED_ENUM` constants can't bridge as free-standing ObjC constants from Swift. Keep a residual ObjC `.m` with only the constant assignments; port class implementations to Swift separately. Delete the residual `.m` once its last ObjC consumer is ported.
- **S2.1-B** — `@_spi(PBMInternal)` needs `@_spi` import in test files: `@_spi(PBMInternal) @testable import PrebidMobile`.
- **S2.1-C — `dispatch_time()` unavailable in Swift; don't use `DispatchTime(uptimeNanoseconds:)` on a raw `dispatch_time_t`.** That initializer *converts* ns→mach-ticks, so round-tripping an already-tick value double-scales it (invisible on simulator 1:1 timebase, ~41x off on arm64 devices at 125/3). Branch on sentinels, convert explicitly, saturate, and clamp the interval before converting (`Int64(seconds * NSEC_PER_SEC)` traps on `.nan`/`.infinity`; multiplying before dividing can overflow past ~97 years). Cache `mach_timebase_info` once. Simulator timebase is 1:1, so only device testing validates the tick-conversion branches — reason about units at review time. See `Functions.dispatchTimeAfterTimeInterval` / `TestFunctions.testDispatchTimeAfterTimeInterval*` for the reference implementation.
- **S2.1-D** — `UIInterfaceOrientationIsPortrait()` → `orientation.isPortrait`.
- **S2.1-E** — `@objc(name:)` on a `throws` method needs the error label: `@objc(dictionaryFromJSONString:error:)`.
- **S2.1-F** — ObjC `@dynamic value;` (CALayer) → Swift `@NSManaged var value: CGFloat`.
- **S2.1-G** — porting an `@objc protocol`: reduce the ObjC private header to a forward declaration (`@protocol PBMFoo;`); full definition comes from `PrebidMobile-Swift.h` via `SwiftImport.h`. Any `.m` calling methods on `id<PBMFoo>` needs `#import "SwiftImport.h"`.

## Phase 2 gaps (S2.2)

- **S2.2-A** — `@objc extension NSDictionary/NSString/...` with `@objc public func` members appear as ObjC categories in `PrebidMobile-Swift.h`; free once the original `.h` is deleted.
- **S2.2-B — string nil-guard preservation.** ObjC `nil` → `nonnull NSString *` bridges to Swift `""`, not `nil`. If ObjC had a nil guard, declare the Swift parameter `String?` (even if the header said `nonnull`) so `nil` actually passes through.
- **S2.2-C** — a class conforming to an `@_spi(PBMInternal)` protocol must itself be `@_spi(PBMInternal)` (and so must any property/method returning that type).
- **S2.2-D** — always call `@_spi` classes by their Swift name (`Factory`), never the ObjC bridge name, from Swift code.
- **S2.2-E** — capitalized ObjC method names (`LogViewHierarchy`) import as `logViewHierarchy()`. If both ObjC and Swift callers exist, name the Swift method lowercase and add `@objc(LogViewHierarchy)`.
- **S2.2-F** — DEBUG-only category properties (e.g. `Prebid.forcedIsViewable`) aren't visible to Swift (Gap 8) — access via KVC inside `#if DEBUG`: `Prebid.shared.value(forKey: "forcedIsViewable") as? Bool ?? false`.

## Phase 2 gaps (S2.3)

- **S2.3-A** — `NSInvocationOperation` has no Swift equivalent; use `target.perform(selector, with: argument)` guarded by `target.responds(to: selector)`.
- **S2.3-B** — ObjC block typedefs can't export as a named ObjC-visible Swift type. For a header-only typedef `.h` (no `.m`), keep the header; the Swift implementation just uses a structurally-matching closure type — no cast needed.
- **S2.3-C** — reducing a header to a forward declaration can transitively break its importers (dropped `@import Foundation;` broke a header relying on it). After any such reduction, check every importer for the dropped types.

## Phase 2 gaps (S2.4 — rebase hazards)

- **S2.4-A** — rebasing onto a commit that independently deleted the ported class. A clean auto-merge only means no *overlapping lines* — not that the port is still wanted (`PBMTouchDownRecognizer`: master replaced it with `UITapGestureRecognizer` on different lines, so the port sailed through as dead code). **Rule:** after every rebase, diff upstream commits against this phase's ported classes; delete any Swift port whose ObjC original was deleted upstream (not just modified), after confirming no post-rebase code references it.
- **S2.4-B** — post-migration commits can reintroduce stale ObjC-name references in tests (copy-paste from an older test). **Rule:** after rebasing, build once (renamed-symbol errors name the file), then grep every `@objc(PBMFoo)` name this phase ported against all `*.swift` files outside its declaration line.

## Phase 2 gaps (review, S2.5)

- **S2.5-A — deleting an ObjC header can break the SPM build only.** A `.m` that got UIKit transitively through a deleted header still compiles under CocoaPods (generated `-Swift.h` re-exports umbrella headers) but fails under SwiftPM (`@import PrebidMobile;` doesn't re-export UIKit). Neither `buildPrebidMobile.sh` nor `buildPrebidSPM.sh` (builds the *published* package) catches this. **Rule:** any `.m` referencing UIKit types must `#import <UIKit/UIKit.h>` explicitly. Verify with `./scripts/buildPrebidMobilePackage.sh` (wired into `PR_checks.yml` as `build-spm-package`).
- **S2.5-B — don't reflexively add `[weak self]` when porting ObjC blocks.** An ObjC block with no `__weak`/`@weakify` captures `self` strongly — sometimes the only thing keeping it alive (`PBMDownloadDataHelper`: a weak capture let it deallocate between the HEAD and GET, silently dropping the completion). **Rule:** port capture semantics literally; only add `[weak self]` where ObjC used `__weak`/`@weakify`, or a retain cycle is demonstrable. Comment strong captures kept deliberately.
- **S2.5-C — `?? default` in `init(jsonDictionary:)` resurrects defaults the wire format never sent.** ObjC's `initWithJsonDictionary:` calls `[self init]` (seeding defaults) then writes ivars **unconditionally** — an absent key overwrites the default with `nil`, omitted on re-encode. `bidfloor = json[.bidfloor] ?? 0.0` is wrong; it invents a wire key ObjC never sent. **Rule:** assign unconditionally (`x = json[.k]`, never `?? default`) in the JSON init; keep the default only in the property declaration/plain `init()` (forces the property optional even under `NS_ASSUME_NONNULL_BEGIN`). Same for collections (`ORTBBidRequest.imp` seeds one element in `init()` but must clear to `[]` if `"imp"` is absent/empty). **Exceptions where `?? default` is faithful:** ObjC explicitly substituted a value for a missing key (`ORTBPmp.deals`, `ORTBBanner.format`), or the property is never re-encoded/is guarded by a non-empty check — child-object fallbacks (`json[.pmp] ?? ORTBPmp()`) are fine since empty child dicts are suppressed on encode (Gap 2). A full round-trip fixture can't detect this bug — cover with a *partial* payload asserting the re-encoded key set (`assertORTBNoResurrectedDefaults` in `ORTBParityHelper.swift`).
- **S2.5-D — `[nil isEqual:nil]` is `NO`; Swift `nil == nil` is `true`.** Changes `NSSet` dedup behavior for all-nil instances when translating `isEqual:` built from optional-property comparisons. `ORTBFormat`: accepted as-is (Swift semantics kept) since the only dedup callsite always populates `w`/`h`, so all-nil never reaches the `NSSet`; reproducing ObjC exactly would break `isEqual:` reflexivity. **Rule:** decide explicitly whether all-nil instances must stay distinct; if ObjC semantics can't be reproduced without breaking reflexivity, keep Swift semantics and comment why.
- **S2.5-E — `UIApplication.shared` is non-optional in Swift but nil host-less** (e.g. unit-test bundle); the non-optional import can't be tested for nil and crashes at first use. **Rule:** never read `UIApplication.shared` directly in ported code — resolve via the ObjC runtime so nil stays observable:
  ```swift
  static var sharedApplication: UIApplication? {
      let selector = NSSelectorFromString("sharedApplication")
      guard let applicationClass = UIApplication.self as AnyObject as? NSObjectProtocol,
            applicationClass.responds(to: selector),
            let application = applicationClass.perform(selector)?.takeUnretainedValue()
      else { return nil }
      return application as? UIApplication
  }
  static var resolvedApplication: PBMUIApplicationProtocol? { Functions.application ?? sharedApplication }
  ```
  Three follow-ons: (1) always consult the `Functions.application` test seam first, in one place (`resolvedApplication`); (2) route every application-derived read (e.g. `safeAreaInsets`, needs the key window) through the protocol; (3) do not memoize — resolution is `nil` until `UIApplicationMain` runs, so a cached `nil` can outlive its cause; the lookup is cheap.

  Scope: applied in `Functions.swift` only. Other files/call sites reading `UIApplication.shared` directly still need this rule applied when touched. Re-measure: `grep -rn --include='*.swift' -F 'UIApplication.shared' PrebidMobile` (not CI-gated).

## Phase 3 gaps (S3.1/S3.2)

- **S3.1-A — withdrawn.** Originally claimed `dict[key] = maybeNil` stores a boxed `Optional.none` instead of removing the key, unlike ObjC. **False**, re-verified: `NSMutableDictionary`/`[String: Any]` remove the key for a single-level-optional `nil`, and optional chaining flattens. Only a *nested* optional (`String??` holding `.some(nil)`) boxes, and that triggers a `coerced ... to 'Any?'` warning. **Rule:** translate literally, `dict[key] = maybeNil`; if the coercion warning appears, flatten rather than silence with `as Any?`.
- **S3.1-B** — a protocol only Swift test mocks conform to can't be `@objc` (would force `@objc` onto every conformer, including a plain-Swift mock). **Rule:** injection-seam protocols consumed only by Swift stay plain `protocol Foo: AnyObject`, with the real type conformed retroactively (`extension Bundle: BundleProtocol {}`).
- **S3.1-C** — an ObjC `Foo+pbmTestExtension.h` class extension can't re-open a Swift class (can't add stored properties/loosen access). **Rule:** delete the test-extension header **and the looseness it existed to serve** — don't widen production properties to optional just to keep an error-path test alive; check call sites first (if unreachable, delete the test, don't preserve via `TODO`).
- **S3.1-D** — `@objcMembers` fails if any member's signature has a non-ObjC type (e.g. a `BundleProtocol` parameter). **Rule:** annotate only the ObjC-called members with an explicit selector instead: `@objc(buildParamsDictWithAdConfiguration:extraParameterBuilders:)`.
- **S3.1-E** — a Swift *test* subclass of a now-internal SDK Swift class breaks `<Module>Tests-Swift.h>` (Swift emits every internal-or-wider `NSObject`-derived test class into the generated header, including its `@interface : Superclass` line, which fails to compile against an internal/non-`@objc` superclass). Surfaces at the end of the build. **Rule:** mark test-only SDK subclasses `fileprivate`/`private` rather than widening the SDK class to `@objc public`.
- **S3.1-F** — an ObjC class conforming to a Swift `@objc protocol` doesn't inherit the Swift method spelling (`@objc(buildBidRequest:) func build(_:)`; an ObjC conformer implementing `buildBidRequest:` satisfies ObjC but Swift callers only see `buildBidRequest(_:)`). **Rule:** re-declare the method in the ObjC conformer's header with `NS_SWIFT_NAME`.
- **S3.1-G** — `ATTrackingManager.AuthorizationStatus.rawValue` is `UInt`; compare via `.uintValue`, not `.intValue`.
- **S3.1-H — dropping `PBMAssert` turns a Release-mode log into a Release-mode trap.** ObjC's `PBMAssert(a && b && c)` compiles out in Release — a `nil` logged and continued. A Swift non-optional `let` makes the same `nil` a compile error (Swift caller) or an unconditional trap (ObjC caller). Fine only when every constructor call is provably Swift — measure, don't assume (`SKAdNetworksParameterBuilder`'s `adConfiguration` shipped as an undocumented `AdConfiguration?` for exactly this reason before being fixed to match its non-nullable ObjC header). **Rule:** measure first:
  ```bash
  grep -rn --include='*.m' --include='*.h' 'initWith\|alloc] init' PrebidMobile EventHandlers
  ```
  Swift-only ⇒ drop the assert, non-optional parameter. **If an ObjC caller survives, the bridged parameter must stay `Optional`** regardless of `NS_ASSUME_NONNULL` (compile-time only) — ObjC→Swift bridging traps on `nil` for a non-optional parameter before the initializer body runs, so a graceful in-body guard isn't achievable without an optional parameter. Guard-unwrap at the top and `Log.error` + return-nil on the nil case. (`PBMURLComponents` hit this for real via the surviving `PBMVastRequester.m` caller — S3.3-A.)
- **S3.2-A — Gap 4/Gap 6 apply per-type by measured importer check, not per-phase.** The Phase 3 builders have no surviving ObjC consumers except `ParameterBuilder`/`ParameterBuilderService` — the eight builders are plain `internal`. Don't inherit whatever visibility the ObjC original had "on reflex" (`InternalUserConsentDataManager` was ported `@objcMembers`; measured to have only Swift consumers, so it's a plain `final class`, no `NSObject` base). **Rule:**
  ```bash
  grep -rn --include='*.h' --include='*.m' --include='*.mm' 'Foo' PrebidMobile EventHandlers PrebidMobileTests
  ```
  Empty output ⇒ no `@objc`/`@objcMembers`/`NSObject` base unless needed for another reason (protocol conformance, KVO, `NSCopying`).

## Phase 3 gaps (S3.3)

- **S3.3-A — `PBMURLComponents` keeps its ObjC prefix: Foundation-collision exception to S1.1.** `Foundation` already exports `URLComponents` (a struct), independently exercised by `URLComponentsTests.swift`; renaming the twin would shadow the stdlib type module-wide. **Rule:** when the de-prefixed name collides with an existing Foundation/UIKit/SDK type, keep the `PBM`-prefixed name on both sides of the bridge and skip the rename. Grep first: `rg -n '\bFoo\b' PrebidMobile EventHandlers PrebidMobileTests` — a bare non-PBM hit is the collision signal. One-off exception, not a reversal of S1.1. (`TrackingRecord`, ported alongside it, has no collision, follows S1.1 normally, needs no `@objc`/`NSObject`/`public` per S3.2-A, and is a `struct` — two `let`s, no identity semantics.)

## Phase 4 gaps (S4.1)

- **S4.1-A — a non-failable Swift initializer can retire an ObjC nil-check as unreachable, not just harmless.** `PBMBidResponseTransformer`'s ObjC nil-checked `[[BidResponse alloc] initWithJsonDictionary:]` and returned an error on nil; the Swift twin's `BidResponse.init(jsonDictionary:)` is a non-failable `convenience init` — always succeeds — so the check can never trigger. **Rule:** verify the twin's initializer signature first (`grep -n 'init(jsonDictionary' BidResponse.swift`); if non-failable, drop the dead branch entirely rather than keeping a defensive check "just in case" (it has no test coverage and misrepresents the real error surface). Mirror image of S3.1-H: there a dropped assert could turn a live path into a trap; here the ObjC check was already provably dead.
- **S4.1-B — plan-inventoried steps don't cover 100% of a phase's files; re-measure the directory before splitting into PRs.** `find .../PBMCore -name '*.m'` turned up 13 files against 10 named in the plan. Consumer analysis resolved the three: `PBMBidRequesterFactory` folds into S4.3 (only consumer `PBMPrebidParameterBuilder.m`, same PR); `PBMWinNotifier` becomes new S4.3b (its Swift protocol `WinNotifier.swift` already existed unimplemented — same PR for locality); `PBMSafariVCOpener` defers to Phase 7 (its only consumer, `PBMAbstractCreative.m`, isn't migrated yet). **Rule:** re-run the file-count measurement per-phase before committing to a step/PR split; treat the plan's step list as a first draft.
- **S4.1-C — `@testable import` does not unlock `@_spi`-restricted symbols; the importer needs its own `@_spi(GroupName)` annotation.** Renaming an `@_spi(PBMInternal) public class` broke every file with a bare `@testable import PrebidMobile` (or plain `import`) — cascading as "type has no member 'X'" in unrelated consumer files before the real "type not found" surfaced in the actual importer. **Rule:** whenever an SPI-restricted type gains new consumers (or is renamed), grep every importer: `rg -n 'import PrebidMobile' <files>` and confirm each reads `@_spi(GroupName) import` or `@_spi(GroupName) @testable import` — `@testable` and `@_spi` are independent, both required. When debugging a "cannot find type/member" error that doesn't match the file you're looking at, check for a cascading same-symbol producer file (e.g. a `+TestExtension.swift`) before chasing build-system theories.

## Phase 4 gaps (S4.3/S4.3b)

- **S4.3-A — `@objc(Name)` on a class exposes the class to Objective-C but not, by itself, a custom (non-protocol-witness) initializer or method; only `@objc`-protocol witnesses get automatic inference.** `PrebidParameterBuilder`'s `build(_:)` needed no explicit `@objc` (satisfies `ParameterBuilder`'s `@objc(buildBidRequest:)` requirement — Gap 7 inference). But its 4-parameter designated initializer isn't a protocol requirement and was silently dropped from `PrebidMobile-Swift.h` (only the `SWIFT_UNAVAILABLE` default `init` appeared) — the surviving ObjC caller failed to link ("no visible @interface ... declares the selector"). **Rule:** any custom `init` on an `@objc(Name)`-bridged `NSObject` subclass that a surviving ObjC caller must construct needs its own explicit `@objc`, or the class needs `@objcMembers` (only viable if every member is ObjC-representable — S3.1-D). Diagnose by reading the generated `<Target>-Swift.h>` under DerivedData directly. Don't assume one bridging method implies every member bridges — check protocol-witness status per-member. Contrast: `WinNotifierImpl` (S4.3b) needed no member-level `@objc` — its ObjC identity resolves once via `NSClassFromString`, and every call site is Swift-only.
- **S4.3-B — order steps so the last surviving ObjC consumer is ported last; it's a free compile-time test of every dependency's `@objc` surface.** Executed order `S4.1 → S4.3+S4.3b → S4.4 → S4.2 → S4.5`, not numeric. S4.2 (`PBMBidRequester.m`) is the only remaining ObjC caller of S4.1's and S4.3's output — leaving it in ObjC means the compiler checks each port's bridged surface for free (how S4.3-A surfaced); porting the consumer first turns those into Swift→Swift calls where a missing `@objc` only fails later at runtime via `NSClassFromString`/selector lookup, uncaught by the compiler. Deferring S4.2 costs nothing: its own port is low-risk (already an `_Objc` shim behind a Swift protocol, no ObjC callers — the `WinNotifierImpl` shape), and it owns the repo's one known-flaky test. **Rule:** before fixing a step order, build the consumer graph (`rg -n 'ClassName' PrebidMobile EventHandlers`) and sort so ObjC→Swift call edges survive as long as possible; prefer porting leaves before roots. Record the *reason* in the PR doc, not just "per the approved step order".
- **S4.3-C — a header with a matching `.m` can still be dead: a `_Objc` shim rename leaves the old `@interface` behind.** `PrivateHeaders/PBMBidRequester.h` declares `@interface PBMBidRequester : NSObject <...>`, but `PBMBidRequester.m` implements `PBMBidRequester_Objc` and never imports that header — invisible to the orphan-header sweep (which only finds `.h` with no same-named `.m`). **Rule:** when a class is renamed to `Foo_Objc` to free the bare name for a Swift protocol, check whether the old `Foo.h` still declares the pre-rename `@interface` — if so it's dead and should be deleted with that class's port. Verify: `rg -n '"Foo\.h"' PrebidMobile EventHandlers PrebidMobileTests` (expect `.pbxproj`-only hits) plus `grep -E '@implementation Foo( |$)' Foo.m` miss.

## Orphan headers — `.h` files with no `.m` (inventoried S3.2)

**35 headers under `PrebidMobile/Objc/` have no matching `.m`** (was 39; S4.3/S4.3b deleted 4 once their last importers were ported): block typedefs, `@protocol`s, macro headers, class-continuation headers, `NS_ENUM`s, umbrella headers, categories on system classes. None is "ported" individually — each is **retired when its last importer is ported**. 2 dead + 24 tied to a named `.m` + 5 tied to the test bridging header + 4 shared-infrastructure = 35.

Re-measure:
```bash
comm -23 \
  <(find PrebidMobile/Objc -name '*.h' | sed 's|.*/||; s|\.h$||' | sort -u) \
  <(find PrebidMobile/Objc -name '*.m' | sed 's|.*/||; s|\.m$||' | sort -u)
```

**A — already dead** (zero `#import`s anywhere; deletable any time):

| Header | Kind | Note |
|--------|------|------|
| `PBMAdLoadFlowController.h` | `@interface` | Swift twin `AdLoadFlowController.swift` already ships |
| `PBMORTB_NotImplemented.h` | macros | referenced only by a stale `.pbxproj` entry |

**B — retired with a named `.m`** (a header imported only by another header resolves to the root `.m` — re-run `grep -rl '"Foo.h"' PrebidMobile PrebidMobileTests` before acting on a row):

| Header | Kind | Retired with |
|--------|------|--------------|
| `PBMAbstractCreative+Protected.h` | class continuation | `PBMAbstractCreative.m`, `PBMHTMLCreative.m`, `PBMVideoCreative.m` |
| `PBMAdLoadManagerDelegate.h` | `@protocol` | `PBMAdLoadManagerBase.m`, `PBMAdViewManager.m` |
| `PBMAdLoadManagerProtocol.h` | `@protocol` | `PBMAdLoadManagerBase.m`, `PBMAdViewManager.m` |
| `PBMCreativeModelMakerResult.h` | block typedef | `PBMCreativeModelCollectionMakerVAST.m` |
| `PBMDeepLinkPlusHelper+PBMExternalLinkHandler.h` | class continuation | `PBMDeepLinkPlusHelper.m` |
| `PBMExposureChangeDelegate.h` | `@protocol` | `PBMWebView.m`, `PBMMRAIDController.m` |
| `PBMExternalURLOpenerBlock.h` | block typedef | `PBMExternalURLOpeners.m`, `PBMExternalLinkHandler.m`, `PBMDeepLinkPlusHelper.m` |
| `PBMORTB.h` | umbrella | `PBMWebView.m` |
| `PBMORTBAbstract.h` | `@interface` | via `+Protected.h` → `PBMBidResponseTransformer.m` |
| `PBMORTBAbstract+Protected.h` | class continuation | `PBMBidResponseTransformer.m` |
| `PBMScheduledTimerFactory.h` | block typedef | `PBMCreativeViewabilityTracker.m` |
| `PBMTimerInterface.h` | forward decl | via `PBMScheduledTimerFactory.h` → `PBMCreativeViewabilityTracker.m` |
| `PBMTrackingURLVisitorBlock.h` | block typedef | `PBMTrackingURLVisitors.m`, `PBMExternalLinkHandler.m` |
| `PBMTransactionFactoryCallback.h` | block typedef | `PBMDisplayTransactionFactory.m`, `PBMVastTransactionFactory.m` |
| `PBMUIApplicationProtocol.h` | forward decl | `PBMExternalURLOpeners.m`, `PBMDeepLinkPlusHelper+Testing.m`, `PBMHTMLCreative+pbmTestExtension.h` (S2.5-E seam) |
| `PBMURLOpenAttempterBlock.h` | block typedef | `PBMDeepLinkPlusHelper.m`, `PBMExternalLinkHandler.m` |
| `PBMURLOpenResultHandlerBlock.h` | block typedef | `PBMExternalURLOpenCallbacks.m`, `PBMExternalURLOpeners.m` |
| `PBMVastResourceContainerProtocol.h` | `@protocol` | `PBMVastParser.m`, `PBMVastIcon.m`, `PBMVastCreativeNonLinearAdsNonLinear.m`, `PBMVastCreativeCompanionAdsCompanion.m` |
| `PBMVideoViewDelegate.h` | `@protocol` | `PBMVideoView.m`, `PBMVideoCreative.m` |
| `PBMVideoViewPlaybackState.h` | `NS_ENUM` | `PBMVideoView.m` |
| `PBMViewControllerProvider.h` | block typedef | `PBMSafariVCOpener.m` |
| `PBMVoidBlock.h` | block typedef | `PBMOpenMeasurementWrapper.m`, `PBMSafariVCOpener.m`, `PBMDeferredModalState.m`, `PBMExternalURLOpenCallbacks.m`, `PBMAbstractCreative.m` |
| `PBMWebView+Internal.h` | class continuation | `PBMWebView.m` |
| `PBMWebViewDelegate.h` | `@protocol` | `PBMWebView.m`, `PBMMRAIDController.m` |

Reducing rather than deleting is sometimes right mid-phase — see S2.1-G (`@protocol` → forward declaration) and S2.3-C (a reduced header breaks its importers).

**C — retired with the test bridging header** (imported only by `PrebidMobileTest-Bridging-Header.h`; go when the corresponding Swift test files stop needing the ObjC symbol):

| Header | Kind |
|--------|------|
| `PBMVastParser+Private.h` | class continuation |
| `WKNavigationAction+PBMWKNavigationActionCompatible.h` | category on a system class |
| `WKWebView+PBMWKWebViewCompatible.h` | category on a system class |
| `PBMWKNavigationActionCompatible.h` | `@protocol` (imported only by the category above) |
| `PBMWKWebViewCompatible.h` | `@protocol` (imported only by the category above) |

The two `WK*Compatible` protocols look like SDK types but aren't — no SDK `.m` names them; they exist so Swift tests can substitute a fake navigation action/web view.

**D — shared infrastructure, last to go** (imported by most of the remaining ObjC tree; deletable only once that tree is empty, in S9.x — do **not** port incrementally):

| Header | Kind | Direct importers (S3.2) |
|--------|------|-------------------------|
| `SwiftImport.h` | umbrella (`PrebidMobile-Swift.h` shim) | 66 |
| `PBMMacros.h` | macros (`PBMAssert`, `weakify`) | 27 |
| `Log+Extensions.h` | macros (`PBMLogError` family) | 24 |
| `PBMConstants.h` | typedefs + constants (`PBMJsonDictionary`) | 15 |

`PBMConstants.h` has a real Swift answer today: every `PBMJsonDictionary` use becomes `[String: Any]` as its importer is ported (step 7), shrinking the header to its constants before it disappears.

## General ObjC → Swift reference

Not phase-specific. Adapted from `agents/migration-patterns/`; that guide conflicts with this playbook on four points — read `agents/migration-patterns/SKILL.md` before consulting it directly.

**`NSNull` from `JSONSerialization` is not `nil`.** Typed reads are inherently safe (`NSNull as? String/NSNumber/[String: Any]` all yield `nil`), so every typed `JSONObject` subscript and `case let value as ...` pattern already rejects it. The hazard is confined to **untyped existence checks** — one instance exists (`ORTBImpExtPrebid.swift:37`, matches the ObjC original so not a regression, but don't add more). **Rule:** never test presence with `dict[key] != nil`/bare `if let`; read through a type (`as? NSNumber`), or guard explicitly like `NSMutableDictionary+PBMExtensions.swift:40`: `value == nil || value is NSNull`.

**ObjC ↔ Swift concept mapping** (⚠ = generic guidance is wrong for this repo):

| Objective-C | Swift | Notes |
|-------------|-------|-------|
| `@interface`/`@implementation` | `class` | ⚠ Not `struct` for Phase 1–3 twins — ObjC builders consume them (Gap 4) |
| `@property (nonatomic, strong)` | `var` | `let` for readonly equivalents |
| `@property (nonatomic, copy)` | `var` | ⚠ If `<NSCopying>`, twin must implement it explicitly or `.copy()` crashes (S1.4) |
| `@property (nonatomic, readonly)` | `let` / `private(set) var` | `JSONObject.dict` is `private(set)` — Gap 10 |
| `NSString` | `String` | ⚠ Use `String?` where the ObjC param was nullable (S2.2-B) |
| `NSArray`/`NSDictionary` | `[Element]`/`[Key: Value]` | ⚠ `NSMutableDictionary` props decode via `NSMutableDictionary(dictionary:)`, not `as?` (S1.4) |
| `NSNumber` | `NSNumber` for ORTB fields | Keep `NSNumber` for optional numerics + JSON-key parity |
| `NSError **` | `throws` | ⚠ `@objc` name needs the label: `@objc(name:error:)` (S2.1-E) |
| Block (`^`) | Closure | ⚠ A block *typedef* can't export as a named Swift type (S2.3-B) |
| `id` | `Any` | Prefer specific types |
| `NS_ENUM` | `enum: Int` | ⚠ `NS_TYPED_ENUM` string constants can't bridge — keep a residual `.m` (S2.1-A) |
| `NS_OPTIONS` | `OptionSet` | Struct-based |
| `dispatch_queue_t` + GCD | `DispatchQueue` | ⚠ Not `async`/`await` — iOS 13 floor. `dispatch_time()` needs explicit mach-tick handling (S2.1-C) |
| Category | Extension | ⚠ `@objc` extensions on Foundation types bridge via `-Swift.h` (S2.2-A) |
| `@protocol` | `protocol` | ⚠ Reduce the ObjC header to a forward declaration (S2.1-G) |
| `#pragma mark -` | `// MARK: -` | |
| `@selector` | `#selector` | Compile-time checked |
| `@try`/`@catch` | `do`/`try`/`catch` | Swift can't catch ObjC exceptions |
| `instancetype` | `Self` | |
| `nullable`/`nonnull` | `Optional`/non-optional | |
| `@dynamic` (CALayer) | `@NSManaged` | S2.1-F |

**`NS_SWIFT_NAME`/`NS_REFINED_FOR_SWIFT` on surviving ObjC APIs** — the reverse of `@objc(PBMFoo)`: improves how remaining ObjC declarations appear to Swift while ObjC parameter builders survive into Phase 3/4.
```objc
- (void)fetchRecordsOfType:(PBMRecordType)type NS_SWIFT_NAME(fetchRecords(ofType:));   // rename for Swift only
- (NSInteger)countForType:(NSString *)type NS_REFINED_FOR_SWIFT;                        // hide the ObjC form, wrap in a Swift extension
```
Use sparingly — a rename not obvious from the ObjC selector makes the two layers harder to reconcile at a glance.
