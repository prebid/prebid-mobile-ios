# Swift Migration Playbook

Per-class file-level porting guide for migrating `PrebidMobile/Objc/` to Swift.
Full phasing plan: https://github.com/prebid/prebid-mobile-ios/issues/396 — a first draft whose file lists
predate the work (see S4.1-B, S5.x-scope); where it disagrees with this playbook or the `pr-phase-*.md`
docs, those win. A PR titled "Phase N" is not self-evidently all of Phase N.

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
- **Gap 4 — Phase 1–3 twins are `@objc NSObject` subclasses.** Response-side types are plain Swift (Swift-only consumers). Request-side (Phase 1) models are still read by ObjC parameter builders → need `NSObject` bridging. *Correction (S3.2):* still consumed post-Phase-3 by `PBMPrebidParameterBuilder.m`, `PBMBidRequester.m`, `PBMBidResponseTransformer.m`, `PBMWebView.m` — keep `NSObject` until all four are ported (S9.x). *Correction (Phase 7):* `PBMWebView.m` imported `PBMORTB.h` but used no ORTB type, so it never kept Gap 4 alive; it is now Swift. Re-measure the remaining ObjC consumers before S9.2.
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

- [ ] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean, and their `.swiftinterface` files typecheck (the script's last step)
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

## Phase 4 gaps (S4.5)

- **S4.5-A — a plan step that names N sibling files can be blocked by a transitive ObjC dependency; port the unblocked subset and record the rest.** S4.5 listed the three `TransactionFactory/` files, but `PBMVastTransactionFactory.m` drives `PBMAdLoadManagerVAST` (ObjC subclass of `PBMAdLoadManagerBase`, no Swift protocol or `Factory` seam), and `PBMTransactionFactory_Objc` constructs the Vast factory directly. Porting them would need a new Swift `AdLoadManagerVAST` seam that Phase 6 deletes again. **Rule:** before starting a step, trace each file's ObjC-only dependencies (`rg -n '#import "PBM' <file>`); if one has no Swift twin and isn't in the step, port only the files whose dependencies are all Swift-visible (here `PBMDisplayTransactionFactory`, which only needs `PBMFactory`, `Bid`, `CreativeModel`) and defer the rest to the phase that ports the blocker. Related: S4.1-B.
- **S4.5-B — Phase 4 is intentionally closed with two files left in ObjC; reviewers should not ask to complete it.** Deferred to **Phase 6** (`AdLoadManager` port): `PBMVastTransactionFactory.{h,m}` and `PBMTransactionFactory.m`. Completing them in Phase 4 was evaluated and rejected:
  1. *Throwaway seam* — a Swift `AdLoadManagerVAST` protocol plus a `Factory.swift` `NSClassFromString` lookup, written, reviewed and deleted again in Phase 6.
  2. *Scope creep into Phase 6* — a Swift class can't conform across the SPM module boundary (`PrebidMobile` Swift target ← `__PrebidMobileInternal` ObjC target) to the ObjC `PBMAdLoadManagerDelegate`/`PBMAdLoadManagerProtocol`; they would have to become Swift `@objc` protocols first, touching `PBMAdLoadManagerBase.m`, `PBMAdViewManager.m` (ported in Phase 5 — it no longer imports either protocol header, so only `PBMAdLoadManagerBase.m`, `PBMAdLoadManagerVAST.m` and the test mocks remain) and `PBMAdLoadManagerVAST.m`.
  3. *Unverifiable test churn* — `MockPBMAdLoadManagerVAST` and ~10 VAST tests reach `PBMAdLoadManagerVAST` through the test bridging header; `PrebidMobileTests` cannot be built locally (pre-existing `@_spi` toolchain issue), so breakage would only surface in CI.
  4. *Weakens S4.3-B* — the call into `PBMAdLoadManagerVAST` would resolve at runtime via the seam, so a missing `@objc`/selector would no longer be a compile error.

  A middle option (port only the dispatcher behind a smaller `Factory` lookup) was also rejected: one throwaway seam to retire one file. **Rule:** when a phase's last files depend on a blocker scheduled for a later phase, close the phase without them and list them here under the blocking phase; do not add temporary seams just to reach 100%. **Phase 6 must pick these up:** port `PBMVastTransactionFactory` + `PBMTransactionFactory_Objc` right after `AdLoadManager`, then delete `PBMVastTransactionFactory.h`, `PBMTransactionFactoryCallback.h`, and the `PBMTransactionFactory_Objc` `NSClassFromString` target in `Factory.swift`.

## Phase 5 gaps (S5.0/S5.1/S5.2)

- **S5.x-scope — the plan's Phase 5 file list was stale; only three of 17 `.m` files were portable.** Re-measured (S4.1-B) at the start of Phase 5: of the 17 remaining `.m` files under the Phase 5 directories, only `PBMModalState`, `PBMAdViewManager` and `PBMInterstitialLayoutConfigurator` (added as S5.0, not in the plan) had all-Swift-visible dependencies. The rest were re-assigned rather than ported behind throwaway seams (S4.5-B):

  | Files | Re-assigned to | Why |
  |-------|----------------|-----|
  | VAST cluster, `PBMAdLoadManagerBase`/`PBMAdLoadManagerVAST`, `PBMVideoCreative`, `PBMVideoView` | Phase 6 | one connected ObjC cluster; `PBMAdLoadManagerBase` alone needs `PBMAdLoadManagerProtocol`/`PBMAdLoadManagerDelegate` moved to Swift `@objc` protocols, which rewrites `MockPBMAdLoadManagerVAST` and `PBMAdLoadManager+pbmTestExtension.h` and still doesn't unblock `PBMVastTransactionFactory`/`PBMTransactionFactory_Objc` |
  | `PBMWebView`, `PBMMRAIDController`, `PBMMRAIDJavascriptCommands`, `PBMAbstractCreative` | Phase 7 | blocked: `PBMAbstractCreative` is subclassed by `PBMHTMLCreative`/`PBMVideoCreative` (ObjC), and imports `PBMSafariVCOpener`/OMSDK wrappers |
  | `PBMCreativeFactoryJob` | after `PBMHTMLCreative`/`PBMVideoCreative` exist in Swift, then `PBMCreativeFactory`, then `PBMTransaction` | each one's last ObjC dependency is the next one's port |

  Refines S4.5-B: once the two ad-load-manager protocols are Swift `@objc` protocols, ObjC `PBMAdLoadManagerVAST` should be able to subclass a Swift `@objc public` non-final `AdLoadManagerBase` (inferred, **not compiled** — verify before relying on it). **Rule:** a "Phase N" step list written before Phase N-1 landed is a first draft; re-run the S4.1-B measurement plus the S4.5-A dependency trace (`rg -n '#import "PBM' <file>`) for every file before splitting PRs.
- **S5.0-A — a surviving ObjC caller of a static ObjC method needs an explicit `@objc(selector:)`, and ObjC truthiness has to be translated by hand.** `PBMInterstitialLayoutConfigurator` was ported first (S5.0) because `PBMAdViewManager.m` still called its `+configurePropertiesWithAdConfiguration:displayProperties:`. A Swift `static func configureProperties(with:displayProperties:)` would have imported under a different selector, so each of the four class methods carries `@objc(configurePropertiesWithAdConfiguration:displayProperties:)`, `@objc(calculateLayoutFromSize:)`, `@objc(isPortrait:)`, `@objc(isLandscape:)` (S4.3-A). The ObjC `if (layout && layout != PBMInterstitialLayoutUndefined)` collapses to `layout != .undefined`: `.undefined` is raw value 0, so the truthiness test was redundant. `NSSet<NSValue *>` of `CGSize`s becomes `[CGSize]` with `contains` (same membership semantics for these finite, positive sizes). **Not `Set<CGSize>`:** `CGSize: Hashable` is `@available(iOS 18.0, *)`; with an iOS 15 deployment target Swift 5 mode only warns, the conformance descriptor is weak-linked, and the first use crashes on iOS 15–17 — CI runs iOS 26 only and cannot catch it. **Rule:** a Swift collection that needs a system type to be `Hashable` must be checked against the deployment target (`swiftc -typecheck -target arm64-apple-ios15.0-simulator` and look for `only available in iOS`); `Equatable` types go in an array.
- **S5.1-A — `isKindOfClass:[ConcreteObjCClass]` becomes `as? SomeProtocol`, with the property added to the protocol; `getter=isFoo` needs `@objc(isFoo)`.** `PBMModalState_Objc.isRotationEnabled` checked `[lastView isKindOfClass:[PBMWebView class]]` and read `webView.rotationEnabled`. `PBMWebView` is still ObjC and not visible to the Swift twin, so the check goes through the existing `WebView_Protocol` (`PBMWebView` already conforms), and `rotationEnabled` is added to that protocol. The ObjC property is declared `getter=isRotationEnabled`, so the protocol requirement is `@objc(isRotationEnabled) var rotationEnabled: Bool { get }` — without the explicit name the conformance check against `PBMWebView` fails to find the selector. Behavior is identical as long as `WebView_Protocol` has exactly one conformer; re-check when `PBMWebView` is ported (Phase 7). The block-typedef header `PBMModalState.h` (two typedefs) survives: seven ObjC files import it (see orphan table).
- **S5.2-A — ObjC passing `nil` to a callback whose Swift parameter is non-optional: don't skip the call.** `PBMAdViewManager_Objc` calls `[delegate adLoaded:[transaction getAdDetails]]`, and `getAdDetails` may return `nil`. The Swift delegate method is `adLoaded(_ adDetails: AdDetails)`, non-optional. Writing `if let adDetails = ... { delegate.adLoaded(adDetails) }` silently drops the callback and hangs the publisher's load flow. **Rule:** when the ObjC original made an unconditional call with a possibly-nil argument, supply a neutral value (`AdDetails(rawResponse: "", transactionId: "")`) and call anyway; record it as a deviation in the PR doc. Related to S3.1-H (the other direction: a non-optional parameter turns `nil` into a trap).
- **S5.2-B — a protocol's `#if DEBUG` requirements force `public` members in every configuration.** `AdViewManager` declares `currentCreative`, `externalTransaction` and both `setupCreative` overloads under `#if DEBUG` ("exposed for tests"). The conforming class is `@_spi(PBMInternal) public`, so in a Release/framework archive build, where the requirements vanish, the members are still `public`; making them `internal`/`#if DEBUG`-only in the class would break the Debug conformance. Accepted: they are `@_spi`-scoped, so not visible to SDK clients. Clean-up belongs to S9.2 along with the rest of the visibility demotions (Gap 6).
- **S5.2-C — port the fixed-point of ObjC message-to-nil, not just the branch structure.** ObjC `self.adConfiguration = creative.creativeModel.adConfiguration;` assigns `nil` into a nonnull-annotated property, and `[self setupCreative:[transaction getFirstCreative]]` passes `nil`. Swift's non-optional types make both impossible; see the PR doc for how each was resolved (`setupCreative` keeps the previous `adConfiguration` when the model has none; `onTransactionIsReady` replays `autoDisplayOnLoad = true; show()` when there is no first creative). **Rule:** for every nonnull-by-annotation ObjC site, ask what `nil` did at runtime; if the Swift type forbids it, reproduce the observable effect rather than only the types.

## Phase 6 gaps (S6.x)

- **S6.1-A — an ObjC class cannot subclass a Swift class, `open` or not (spike, decisive).** `PrebidMobile-Swift.h` stamps `objc_subclassing_restricted` on every Swift class, so
  `@interface PBMVastCreativeLinear : PBMVastCreativeAbstract` fails with "cannot subclass a class that was declared with the 'objc_subclassing_restricted' attribute" once the base is Swift.
  This **disproves** the S5.x-scope assumption that an ObjC `PBMAdLoadManagerVAST` could subclass a Swift `AdLoadManagerBase`. **Rule:** a Swift base class moves in the same step as all of its ObjC subclasses
  (here: `AdLoadManagerBase` + `AdLoadManagerVAST`; `VastCreativeAbstract` + `Linear`/`CompanionAds`/`NonLinearAds`; `VastAbstractAd` + `Inline`/`Wrapper`). The reverse (a Swift subclass of an ObjC class) is untested in the SPM layout: the Swift target cannot see `__PrebidMobileInternal`, which is why `PBMVideoCreative` stays ObjC (see the hand-off).
- **S6.1-B — `NSMutableArray` properties that surviving ObjC mutates in place stay `NSMutableArray`.** Swift arrays are value types. Waves 2D–5I kept `impressionURIs`, `errorURIs`, `creatives`, `vastAbstractAds`, `icons`, `mediaFiles`, `companions`, `nonLinears`
  and the click-tracking arrays untyped. All ObjC mutators are gone now; retyping touches about 246 sites and the 23-input parity dumps, so it is a separate follow-up (see the cleanup list).
- **S6.1-C — `@objc(PBMFoo) enum` keeps the ObjC constant names `PBMFooCase`; the Swift cases are lowerCamel.** `NS_TYPED_ENUM` string constants (`PBMVastRequiredMode`) stay in ObjC (S2.1-A); Swift code compares against the `"all"`/`"any"` literals.
- **S6.x-A — `Foo+pbmTestExtension.h` for a ported class becomes plain `internal` + `@testable`.** Delete the header and its bridging import (S3.1-C confirmed on `VideoView`, `VastParser`). `PBMAdLoadManager+pbmTestExtension.h` was dead (nothing read `currentTransaction`).
- **S6.x-B — deleting an ObjC header can remove transitive system imports.** Two Swift tests lost `AVFoundation`/`CoreMedia` when `PBMVideoView.h` left the bridging header and needed an explicit `import AVFoundation` (same hazard as S2.5-A for `.m` files).
- **S6.x-D-A / F-A — `AnyObject?` stands in for a back-reference to a not-yet-ported ObjC type; retire it in the same commit that ports the referent.** Used for `VastAbstractAd.ownerResponse`/`vastResponse` in wave 2D, retyped in wave 3F.
- **S6.x-D-B — a blanket `PBMFoo` → `Foo` rename also rewrites `@objc(PBMFoo)` in newly written Swift files** and ObjC then fails with "unknown receiver". Exclude new files or re-check `@objc(` after renaming.
- **S6.x-D-C — import-removal regexes: use `[ \t]*`, not `\s*`** (`\s*` swallows the following blank line).
- **S6.x-F-B — `NSErrorPointer` out-param → `throws` with an explicit `@objc(nameAndReturnError:)`-style selector.** ObjC callers that pass `&error` need no edit. Used for `VastResponse.flattenResponse`.
- **S6.x-F-C — `NSMutableArray` is not convertible to `[Any]` with `as`;** use `Array(x)`.
- **S6.x-G-A — a throwaway ObjC-era dump is the parity oracle for a delegate/state-machine port.** Write a deterministic text dump of the parsed model (printing `nil` and `""` differently, or S5.2-C regressions hide), run it against the ObjC class on every fixture plus synthetic inputs, commit the output as literal expectations, then re-run the same dump on the Swift port and `diff -r`. `VastParser`: 23 inputs, byte-identical.
- **S6.x-G-B — ObjC attribute parsing keeps `NSString.integerValue`/`floatValue`/`intValue`.** They are prefix-lenient and never fail; `Int(_:)`/`Double(_:)` are strict.
- **S6.x-H-A — a `.m`-private block typedef becomes a `private typealias`; a public one becomes a nested `public typealias Completion`.** Both bridge to the same block type, so ObjC call sites keep their literal blocks.
- **S6.x-H-B — a dead `@strongify` nil-check inside a synchronous block is not ported;** record it as unreachable.
- **S6.x-J-A — a non-final Swift base with a protocol `init` requirement needs `required init`.** Subclasses that add no designated initializers (`AdLoadManagerVAST`, the test mock) inherit it.
- **S6.x-J-C — a `*_Objc` class behind a `Factory.swift` `NSClassFromString` lookup becomes an internal `final` Swift class constructed directly by the factory method.** The `@objc` name, the `TransactionFactoryType` static and the `as!` force-cast disappear. Only valid when no ObjC code looks the name up (measured). Done for `TransactionFactoryImpl` + `VastTransactionFactory`.
- **S6.x-K-A — Swift traps where ObjC wrapped, and `String` is not `NSString`: check both on every value that comes from outside.** Found in review of Phase 6.
  (1) Integer arithmetic on parsed input: `NSInteger` multiplication/addition wraps, Swift `*`/`+` trap. `VastCreativeLinear.bestMediaFile` multiplied `<MediaFile width= height=>` values (unbounded, from third-party ad servers) and crashed the host app on `4e9 * 4e9`; use `&*`/`&+` or `addingReportingOverflow` and keep the ObjC outcome (`VideoView`'s resource-loader offset had the same issue).
  (2) `-[NSString containsString:]`/`rangeOfString:` and Swift `String.contains` disagree when a grapheme-extending character follows the match (`"<VAST\u{200D}>"`); use `(string as NSString).contains(...)` for a 1:1 port (cf. S6.x-G-B for the numeric parsers).
  (3) Before writing "the ObjC crashed here" in a deviation table, run the ObjC: `-[NSMutableArray addObjectsFromArray:nil]` is a no-op, not an exception. An `NSError **` out-param that is *left set* while the loop continues (`VastResponse.flattenResponse`) is a different control flow from an early `throw`: port it as catch, remember, continue, and throw at the end. **Rule:** for each ported input-handling method, grep the file for `*`, `+`, `-`, `Int(`, `.contains(` and force-unwraps, and for each deviation claimed as "forced" write a probe against the ObjC.
- **S6.x-J-D — `@objc(PBM...)` bridge names on now-Swift-only classes** (`AdLoadManagerBase`/`VAST`, `AdRequesterVAST`, the VAST models) are kept for runtime-name stability, as for `InterstitialLayoutConfigurator`. Candidates to drop in S9.x.

**Phase 6 closed with `PBMVideoCreative` (and `PBMVastGlobals.{h,m}`) left in ObjC — do not ask to complete it here.** `PBMVideoCreative` subclasses `PBMAbstractCreative_Objc`, which lives in the ObjC SPM target `__PrebidMobileInternal`; the Swift `PrebidMobile` target cannot see it, so a Swift subclass would break `buildPrebidMobilePackage.sh`.
It also depends on `PBMOpenMeasurementWrapper`/`PBMOpenMeasurementSession` (Phase 8) and the `PBMAbstractCreative+Protected.h` continuation. A composition wrapper would be a throwaway seam of the kind S4.5-B rejects. `PBMVastGlobals.m` keeps only the `NS_TYPED_ENUM` `PBMVastRequiredMode` constants (S6.1-C).

## Phase 7 gaps (S7.x)

- **S7.1-A — reach an ObjC type through its Swift `@objc` protocol; the surviving ObjC caller's block type changes with it.** The Swift target cannot name `PBMOpenMeasurementSession`, but the type already conforms to the Swift `OMSession` (`PBMOMSession`). `WindowLocker` and `SafariVCOpener` take `OMSession?`; the ObjC block in `PBMAbstractCreative.m` was retyped to `id<PBMOMSession>` so the bridged signature matched. No seam added (S4.5-B).
- **S7.1-B — ObjC `@try/@catch (NSException)` has no Swift equivalent.** `SafariVCOpener.openClickthrough` and `HTMLCreative.webView(_:receivedMRAIDLink:)` caught UIKit/WebKit exceptions and logged them; the Swift ports do not. Record it as a deviation and keep the explicit pre-checks. `MRAIDController` replaced its 14 `NSException` throw sites with a Swift `throws` (message text unchanged). Review of the creative wave flagged the dropped catch as the one behavioural loss (UIKit "present modally an active controller" would now crash instead of logging); not fixed, no ObjC shim added (follow-up: #1403).
- **S7.1-C — a `+PBMTestExtension.h` class extension becomes `internal` + `@testable`** (S3.1-C again): `SafariVCOpener`, `DeepLinkPlusHelper`, `WebView`, `MRAIDController`, the three creatives, `CreativeFactoryJob`. A header that got `PBMVoidBlock.h` only through a deleted header needs the direct import.
- **S7.1-D — deleting an ObjC header again removes transitive system imports, and only the SPM build notices** (S2.5-A, S6.x-B). Wave 1B: `PBMMRAIDJavascriptCommands.h` carried `@import CoreLocation` into `PBMWebView.m`, `LocationManagerTest` and `UtilsTests`. Xcode was green; `buildPrebidMobilePackage.sh` failed. **Rule:** run the SPM build after every header deletion, not once per phase.
- **S7.1-E — typed-enum arguments become `String` on the Swift side** once the consumer of an `NS_TYPED_ENUM` is ported but the constants stay in ObjC (S2.1-A residue). `PBMMRAIDAction`/`PBMMRAIDPlacementType` are `String`; Swift tests use `.rawValue`.
- **S7.2-A — `(x as NSString).hasPrefix(...)` still calls Swift's grapheme-aware `String.hasPrefix`.** For a literal anchored search use `range(of:options:[.anchored, .literal])` (found by a combining-mark input, `"mraid:\u{301}x"`, in the parity dump). Same for `hasSuffix`. Extends S6.x-K-A (2).
- **S7.2-B — a Swift property that a test reads through key-value coding needs `@objc`.** `PBMWebViewTest.testExpand` waits on `NSPredicate("state == ...")` / `"mraidState.rawValue == ..."`; without `@objc` the test times out rather than failing to compile.
- **S7.2-C — S3.1-F for an ObjC class conforming to a Swift `@objc` protocol:** Swift tests see the ObjC selectors only if a test-extension header re-declares them. Delete the re-declarations with the class (they went with `PBMHTMLCreative`).
- **S7.2-D — ObjC reads of untyped JSON crash on the wrong type; do not reproduce the crash.** `-integerValue`/`-boolValue` on `NSNull`/`NSArray`/`NSDictionary` is an unrecognized-selector crash (7 of 7 probes). `MRAIDController` rejects such values like a missing key. Run the ObjC before writing "ObjC crashed here" (S6.x-K-A (3)).
- **S7.2-E — a blanket rename also hits test helpers and string literals.** `var MRAIDController: PBMMRAIDController!` shadowed the new type; `ACCESSIBILITY_WEB_VIEW_LABEL = "PBMWebView"` and log strings must stay unchanged.
- **S7.2-F — Swift cannot hold a lone surrogate or build NUL via `%c`.** Build such parity inputs with `NSString(characters:length:)` and write the expectation key by hand.
- **S7.2-G — screen-dependent parity must pin the screen.** `CGRectForResizeProperties` depends on `UIScreen.main.bounds`; the parity test is recorded at 402x874 pt and `XCTSkip`s elsewhere.
- **S7.3-A — a Swift protocol requirement that an ObjC conformer left `nullable` must be Optional.** Review of waves 1-2 found `AbstractCreative.dismissInterstitialModalState: VoidBlock` (non-optional) against `PBMAbstractCreative.m`'s `copy, nullable` block: `mraid.close()`/`unload()` on an interstitial before the modal was pushed would call a null block (ObjC checked for nil). Fixed to `VoidBlock?`. Same review: `SafariVCOpener.modalManager` was non-optional while `PBMAbstractCreative.m` passes a property that is nil until `onTransactionIsReady`. **Rule:** when porting a class that an ObjC class conforms to (or calls), grep the ObjC side's `nullable` annotations against every protocol requirement and bridged parameter, not just the ported file's own header (extends S3.1-H).
- **S7.3-B — a base class whose bare name belongs to a Swift protocol becomes `*Impl` and keeps the ObjC name.** `AbstractCreativeImpl` is `@objc(PBMAbstractCreative_Objc)`; likewise `TransactionImpl` (internal `final`, no `@objc`, S6.x-J-C). A non-final base with a protocol `init` requirement needs `required init` (S6.x-J-A).
- **S7.3-C — the `isKindOfClass:[ObjCClass]` OMSDK gate becomes a non-nil check on the protocol-typed session.** Equivalent in production (the only `OMSession` producer is `PBMOpenMeasurementWrapper`); any other conformer now passes. `Transaction.measurementSession` became `OMSession?` (`PBMTransaction.m` left it nil until the first creative created it).
- **S7.3-D — `NSURL(string:)` not `URL(string:)` when empty strings must survive.** `URL(string: "")` is nil, `NSURL(string: "")` is a valid empty URL (probed). Likewise `-intValue` on a reward time wraps at 32 bits: use `int32Value`, not `intValue`.
- **S7.4-A — a `*_Objc` class whose only lookup is `Factory.swift` but whose construction also reads an ObjC singleton: the singleton read is the seam, not the class.** `TransactionImpl` is constructed directly; `Factory.openMeasurementWrapper` is one `NSClassFromString("PBMOpenMeasurementWrapper")` plus `perform(NSSelectorFromString("shared"))` cast to `OMSessionWrapper`. It is the only seam Phase 7 added and Phase 8 deletes it.
- **S7.4-B — removing a protocol's `init(...)` requirement when the `NSClassFromString` factory goes** (it only existed for `Type.init(...)`): `Transaction` lost `init(serverConnection:adConfiguration:models:)`.
- **S7.4-C — `AdFormat` is an `OptionSet` class: `===` is not `==`.** The ObjC compared pointers (`adType == AdFormat.banner`); a distinct instance equal to `.video` takes the default timeout. Keep identity (a lookalike instance in the parity dump shows it).
- **S7.4-D — `DispatchQueue.asyncAfter(deadline: .now() + NaN)` means "never", `dispatch_time(NOW, NaN)` means "now".** Map NaN to 0 explicitly (`HTMLCreative` display timer, `CreativeFactoryJob` timeout). The NaN branch was reasoned from the C cast, not run against the ObjC; inf, huge and negative were probed in Swift.
- **S7.x-E — when a parity dump forces the Swift/ObjC name clash, freeze the ObjC output first.** ObjC and Swift classes share a bridged name and cannot coexist in one build, so every Phase 7 dump was captured from the ObjC, committed as literal expectations, then compared from the Swift. Keep the expectation files small: the creative-wave dump was 9,928 lines (a full cross product of about 30 inputs per dimension) and was cut to about 590 lines of boundary values (nil, 0, a normal value, negative, NaN, infinity) once it had matched; filter the captured ObjC output rather than re-capturing, since the ObjC is gone.

**Phase 7 closed with the OMSDK ObjC wrappers (and the rest of the list under "What Phase 8 inherits") left in ObjC.** The user chose to reach OMSDK through the existing Swift `OMSession`/`OMSessionWrapper` protocols (option (a)) rather than pull Phase 8 forward or split the group.

## Phase 8 gaps (S8.x)

- **S8.0-A — the SPM Swift target needs the OMSDK binary target as a dependency, and `swiftc` needs the slice path too.** `Package.swift` and `PrebidMobile/Package.swift` gave `PrebidMobileOMSDK` only to the ObjC target. Adding `dependencies: ["PrebidMobileOMSDK"]` to the Swift target is the whole fix (probed with a throwaway package first; the xcframework ships a real modulemap). `buildPrebidMobilePackage.sh` also needs `-Xswiftc -F` next to `-Xcc -F`, because SwiftPM resolves binary slices against the host platform when cross-compiling. Xcode and CocoaPods already link OMSDK into one combined target and needed nothing (S7.1-D: only the SPM build notices).
- **S8.0-B — a plain `import OMSDK_Prebidorg` puts that line in the `.swiftinterface`; `internal import` keeps it out but needs `-enable-experimental-feature AccessLevelOnImport` and `public import UIKit` in the same file, on a podspec pinned at `swift_version 5.0`.** Decision: plain import, and keep every OMID *type* `internal`/`private` so none appears in a public signature. Check: the only `OMID`-containing lines in `PrebidMobile.swiftinterface` should be the import and unrelated SDK names (`Signals.Api.OMID_1`, `ORTBSourceExtOMID`).
- **S8.0-C — an ObjC SPM target with no sources compiles nothing and SwiftPM skips its dependencies, so a build of it alone passes without compiling the SDK.** When the last `.m` went, `swift build --target __PrebidMobileInternal` took 0.2 s and exited 0. `buildPrebidMobilePackage.sh` now builds `PrebidMobile` and `__PrebidMobileInternal` as two commands (`--product PrebidMobile` fails on an unrelated `DO_NOT_MOVE_THESE_FILES.txt` in an adapter target). **Rule:** a green build that finished in under a second after a large deletion proves nothing; check the log for `Compiling` lines (about 394 for a clean build of this SDK) and force a clean build before trusting it. The empty `__PrebidMobileInternal` target itself is a Phase 9 removal.
- **S8.1-A — "public for the transition" comments rot; re-grep before believing them.** The OMSDK classes were left `public` with `@objc` seams (`init(omidContext:omidConfiguration:)`, `init(omidSession:)` with a force-cast) while ObjC users and ObjC-importing tests existed. The review found the stated reason was already false (no ObjC user remained) and the public surface had widened. They are `internal` now. **Rule:** a transitional visibility needs a measured exit condition in the comment *and* a step that removes it; keep OMID types out of the seams with `NSObject`/raw values meanwhile.
- **S8.1-B — delete headers last, and run the test target.** Deleting `PBMOpenMeasurementWrapper.h` and the `+pbmTestExtension.h` files removed the only carriers of `Log+Extensions.h` and `PBMMacros.h` for `LogObjCTest.m` and `PBMMacrosTest.m` (S2.5-A, S7.1-D). Neither the framework build nor the SPM build compiles the test target; only `testPrebidMobile.sh` does.
- **S8.1-C — a pure-function parity dump can be built outside the repo** (clang on a stubbed `SwiftImport.h` plus one `.m`) to freeze the ObjC output before deleting the class; no Xcode scheme is needed.
- **S8.1-D — ObjC `NSError **` APIs import as `throws`, and OMID names change on import:** `OMIDPrebidorgSDK.shared` (not `sharedInstance`), `adUserInteraction(withType:)` keeps its label, enum cases lose the `OMID` prefix (`OMIDCreativeType.htmlDisplay`).
- **S8.1-E — a `nonnull` ObjC initializer that sets `self = nil` needs `init?`** (`OpenMeasurementSession.init?(context:configuration:)`; the wrapper's three call sites nil-check). Likewise a `nonnull` method with a `default: return nil` needs an Optional return (`describe(_:)` returns `String?`, S3.1-H). Both annotations lied; the existing test already defended against `nil`.
- **S8.1-F — an ObjC property that is read-only in the header but overridden by a test subclass through a category is an injection point, not a property.** `partnerName` became an `init(partnerName:)` `let`; no overridable member and no test subclass seam is needed, so the class can be `internal`.
- **S8.2-A — a `NS_TYPED_ENUM` residue with no ObjC consumers left ports to a `@_spi(PBMInternal) public struct X: RawRepresentable, Hashable` with `static let`s.** The spelling `Type.case.rawValue` is unchanged, so tests only drop the `PBM` prefix. A blanket `sed` with `\b` missed call sites (S7.2-E again); grep the old names after the rename.
- **S8.2-B — a DEBUG-only ObjC category property read from Swift by KVC (S2.2-F) becomes a `#if DEBUG` Swift `static var`.** Three accessors for one `UserDefaults` key (the category, a KVC string, a test-extension copy) collapsed to one. A duplicate declaration in a `@testable` test target is ambiguous, so remove the test copy.
- **S8.2-C — a timer selector target must be `@objc` and must not be `#if DEBUG`, even when the protocol requirement is.** `CreativeViewabilityTrackerImpl.checkViewability` is the timer's selector and has to exist in Release.
- **S8.2-D — a class an ObjC class used through nil-messaging can stop compiling once ported.** `creative.creativeModel.adConfiguration.pollFrequency` hid that `adConfiguration` is Optional; the port is `adConfiguration?.pollFrequency ?? 0`. Record it as a deviation.
- **S8.3-A — Swift `try` on an ObjC `BOOL ... error:` API turns a bare `NO` (no error object) into `Foundation._GenericObjCError`, code 0, empty userInfo.** If the header documents `NO` without an error as a *non-error* case, the port must filter it or it logs spuriously. `OMIDAdSession.addFriendlyObstruction` returns `NO` with no error for "already added" and "session finished"; the ObjC logged only when `error != nil`. Found in review, probed with a real OMID session (a genuine violation throws domain `com.omid.library`, code 1512). **Rule:** read the header's `@return` before writing `catch { log }`.
- **S8.3-B — restoring a typed `isKindOfClass` gate is incompatible with protocol-conformer mocks.** The three S7.3-C sites stay non-nil `OMSession` checks, because a typed gate would make the mock-based creative tests skip their paths. Decide per site; document the weaker check.
- **S8.x-D — a PR test plan that skips a whole subsystem gives that subsystem no PR signal.** `PrebidMobilePRTests.xctestplan` skipped every OMSDK and viewability class, so a PR could break the cluster and stay green; after a class rename the skip entries also go stale silently. After renaming or deleting a test class, `grep` the plan for the old name.
- **S8.x-E — parallel agents share one simulator name.** `testPrebidMobile.sh` deletes and recreates `iPhone-17-Pro-PrebidMobile`; concurrent runs delete each other's device (`No matching device`, mass failures that are not regressions). Serialize the *test* step with a lock (`mkdir /tmp/prebid-sim.lock`); builds need none. CPU contention also made timing tests flaky, so judge a parallel-track test result as provisional and re-run on the merged tree.

**Phase 8 closed with no `.m` file left under `PrebidMobile/Objc`.**

## Phase 9 gaps (S9.x)

- **S9.1-A — ObjC tests that prove the public API is callable from Objective-C stay ObjC; they are not migration debt.** `PrebidObjcTests`, `TargetingObjCTests`, `AdUnitObjCTests`, `AdUnitSuccessorObjCTests`, `AdViewUtilsObjCTests` and `UtilsObjCTests` exist to fail when an `@objc` name, selector label, nullability or enum import changes for ObjC apps (e.g. `Targeting.shared.coppa` is an `NSNumber *` there; Swift cannot check that). A Swift port would still compile after such a break. **Rule:** before porting an ObjC test, ask what it would catch that the Swift version cannot; if the answer is "a break for ObjC callers", leave it. `NSString+pbmExtensionsObjCTest` (passes `nil` to `nonnull` parameters), `NSMutableDictionaryTests` (`@objc` category-style API), `PBMFunctionsPrivateTest` (raw `dispatch_time_t` into C `dispatch_after`, which Swift does not expose) stay for the same reason.
- **S9.1-B — an ObjC test is deleted, not ported, when it only exercises ObjC-only machinery.** `LogObjCTest` and `PBMMacrosTest` tested the `PBMLog*`/`@weakify` macros, which no SDK code uses; Swift `LogTest` covers `Log`. `PBMFunctionsObjCTest` was entirely commented out. The headers (`Log+Extensions.h`, `PBMMacros.h`) went with them.
- **S9.1-C — `SwiftImport.h` cannot be retired.** The ObjC API tests above import it (it is the `PrebidMobile-Swift.h` shim). The Phase 8 plan to delete it "once the ObjC tests are Swift" was wrong. It stays, and the `PrebidMobile_SPM` branch is gone from it (no ObjC target is built by SPM any more).
- **S9.1-D — deleting the last header in a bridging header's import chain removes transitive imports Swift tests relied on.** `PBMORTB.h` imported `SwiftImport.h`, which gave the `Mediation*AdUnit+TestExtension.h` category headers their `@interface` declarations; `WKNavigationAction+...h` pulled in WebKit and `PBMUIApplicationProtocol.h` effectively UIKit. Dozens of Swift tests then failed with `cannot find 'WKWebView' in scope`. The bridging header now imports `<UIKit/UIKit.h>`, `<WebKit/WebKit.h>` and `SwiftImport.h` explicitly. Only a full test build shows this (S8.1-B).
- **S9.1-E — `@compatibility_alias` typedefs leak into Swift.** `ServerConnectionTest` used `JsonDictionary`, an ObjC alias from `PBMConstants.h`; it became `[String: Any]`.
- **S9.1-F — an SPM manifest cleanup is verified by a clean build with a file count, not by exit status** (S8.0-C). `rm -rf .build` then `buildPrebidMobilePackage.sh`: 394 `Compiling` lines, as before the target was removed.
- **S9.3-A — a Swift class whose `@objc(Name)` existed only so `NSClassFromString` could find it loses the annotation with the lookup.** The five `Factory` lookups (`PBMBidRequester_Objc`, `PBMWinNotifier_Objc`, `PBMAdViewManager_Objc`, `PBMViewExposure_Objc`, `PBMModalState_Objc`) construct the `*Impl` classes directly; the runtime names are gone. `Factory.WinNotifierType` and `ViewExposureType` stay as metatype constants because tests call static members through them.
- **S9.x-G — a ported helper that nothing calls can still be wrong.** `NSString.PBMsubstringFromString(_:)` used `length - range.length` as the substring length and so raised `NSRangeException` for a match past index 0 (the ObjC original did too; `MRAIDCommand` already routes around it). Fixed to `substring(from:)`; the end-of-string and index-0 results are unchanged. A mid-string case is now tested.

## Hand-off: what is left after Phase 9

Phase 9 as merged retired every header that could be retired without breaking ObjC-API coverage. **`PrebidMobile/Objc` holds one header, `SwiftImport.h`, and that is the intended end state** (S9.1-C). Not done in Phase 9, and not blocking:

- **S9.2 visibility demotion** (Gap 4/6): the Phase 1 ORTB models and the `@_spi(PBMInternal) public` implementation classes. Re-measure the ObjC consumers first: `grep -rn --include='*.m' --include='*.h' 'PBMORTB' PrebidMobile PrebidMobileTests` finds none now, but the ObjC API tests were not audited against each `public` member.
- **`@objc(PBM...)` bridge names and `@objc(selector:)` annotations** on the remaining Swift-only classes (`WebView`, `MRAIDController`, the three creatives, the helpers): drop where nothing looks them up (S6.x-J-D). The five `_Objc` names are done.
- **`NSMutableArray` retyping in the VAST models** (S6.1-B, about 246 sites).
- **`MockServer/*.m`** (6 files) and `OMIDContext+pbmTestExtension.m` are test infrastructure; `OMIDContext+pbmTestExtension.m` must stay (an `NSBundle` swizzle that avoids an OMSDK crash in tests).
- **Dropped `@try/@catch`** around UIKit presentation (S7.1-B, #1403).
- **Demo-app check for OMSDK was never done in Phases 7, 8 or 9.** Run an HTML banner, an interstitial and a VAST video and confirm sessions start and report.
- **S5.2-B follow-up:** the `AdViewManager` DEBUG-only protocol requirements and the `public` members they force on `AdViewManagerImpl`.
- **`OpenMeasurementSession.deinit`'s 1 s view retention and `trackVolumeChanged` ignoring `deviceVolume`** are ported literally and untested.

## Orphan headers — `.h` files with no `.m` (inventoried S3.2)

**1 header under `PrebidMobile/Objc/` has no `.m`, and there are no `.m` files at all** (was 14 before Phase 9, 17 before Phase 8, 28 before Phase 7, 36 before Phase 6, 39 before Phase 4). Phase 9 deleted the other 13: `PBMAdLoadFlowController.h`, `PBMORTB_NotImplemented.h`, `PBMORTBAbstract+Protected.h`, `PBMORTBAbstract.h`, `PBMORTB.h`, `PBMUIApplicationProtocol.h`, both `WK*Compatible` protocols and their two categories, `PBMConstants.h`, `PBMMacros.h` and `Log+Extensions.h`. The survivor is `SwiftImport.h`, imported by the ObjC API tests (S9.1-A, S9.1-C).

Re-measure:
```bash
comm -23 \
  <(find PrebidMobile/Objc -name '*.h' | sed 's|.*/||; s|\.h$||' | sort -u) \
  <(find PrebidMobile/Objc -name '*.m' | sed 's|.*/||; s|\.m$||' | sort -u)
```

## Post-migration cleanup list

Items that are not worth porting and should be deleted once the migration is over (do not port them, do not extend them):

- **`PBMDeferredModalState`** — done in Phase 8 (S8.2, track C): `PBMDeferredModalState.m`, `DeferredModalState.swift` and the `ModalManager` hooks were deleted after a re-grep confirmed no caller. An `@_spi(PBMInternal)` surface removal.
- **`PBMModalState.h`** — done in Phase 7 (deleted with `PBMHTMLCreative.m`, `PBMVideoCreative.m`, `PBMAbstractCreative.m`).
- **`WebView_Protocol`** — done in Phase 8 (S8.2, track C): the two `as? WebView_Protocol` casts became `as? WebView` and the protocol was deleted, together with the empty `WebView.addFriendlyObstructions(to:)`.
- **S5.2-B follow-up:** the `AdViewManager` DEBUG-only protocol requirements and the `public` members they force on `AdViewManagerImpl` (visibility demotion, S9.2).
- No `PBMInterstitialLayoutConfigurator` leftovers remain: header and `.m` were deleted in S5.0, and the `@objc(PBMInterstitialLayoutConfigurator)` bridge name has no ObjC caller anymore (kept so the runtime name is stable; may be dropped in S9.x).

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
| `dispatch_queue_t` + GCD | `DispatchQueue` | ⚠ Ports so far use GCD, not `async`/`await`, only because of the old iOS 13 floor. With iOS 15 as the minimum that constraint is gone, so `async`/`await` is an option for new ports. `dispatch_time()` needs explicit mach-tick handling (S2.1-C) |
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
