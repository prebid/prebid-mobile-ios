# Swift Migration Playbook

Per-class file-level porting guide for migrating `PrebidMobile/Objc/` to Swift.
See the full phasing plan in the TaskNotes task "[PI][PREBID] Develop a plan to migrate the iOS SDK to Swift".

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

**Gap 1 — no `NSCopying`.** `PBMORTBAbstract`'s `<NSCopying>` (JSON-round-trip `copyWithZone:`) has zero callers on ORTB model objects. Swift twins do not implement `NSCopying` (exception: root containers actually `.copy()`d in tests — see S1.4 below).

**Gap 2 — empty child dict suppression.** ObjC calls `[[child toJsonDictionary] nullIfEmpty]` so an empty child never serializes as `"app": {}`. Swift `JSONObject`'s `PBMJsonCodable` subscript setter replicates this by nil-ing out an empty dict before storing:
```swift
set {
    let childDict = newValue?.jsonDictionary
    dict[key.rawValue] = (childDict?.isEmpty == true) ? nil : childDict
}
```

**Gap 3 — `ORTBFormat` needs `isEqual`/`hash`.** Deduplicated via `NSSet` in `PBMPrebidParameterBuilder.m:197`, keyed on `w`/`h`. The Swift twin (an `NSObject` subclass, Gap 4) overrides both:
```swift
override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? PBMORTBFormat else { return false }
    return w == other.w && h == other.h
}
override var hash: Int { (w?.hashValue ?? 0) ^ (h?.hashValue ?? 0) }
```

**Gap 4 — Phase 1–3 twins are `@objc NSObject` subclasses.** Response-side ORTB types are plain Swift classes (Swift-only consumers). Request-side (Phase 1) models are still read by ObjC parameter builders, which need `NSObject` to bridge. *Correction (S3.2):* "gone after Phase 3" was wrong — `PBMPrebidParameterBuilder.m`, `PBMBidRequester.m`, `PBMBidResponseTransformer.m`, `PBMWebView.m` still consume ORTB twins post-Phase-3. Keep `NSObject` until all four are ported; revisit in S9.x.

**Gap 5 — `init?(jsonDictionary:)` returns `nil` on failure**, unlike ObjC's broken-instance fallback (`[PBMORTBAbstract new]`) — semantically correct, no code change needed. Audit tests that relied on the broken instance.

**Gap 6 — framework build visibility.** `internal` Swift types appear only as `@class` stubs in `PrebidMobile-Swift.h` under a framework archive build ⇒ ObjC consumers get "forward declaration" errors. All Phase 1–3 twins must be `@objc public class` with `@objc public var` properties. Demote to `internal` only in S9.2 (see Gap 4 correction for what's still blocking that).

**Gap 7 — explicit ObjC selector bridges required.** Non-`@objc`-protocol requirements (`PBMJsonDecodable.init?`, `PBMJsonEncodable.jsonDictionary`) do not get automatic `@objc` inference, even on `public NSObject` subclasses:
```swift
@objc(initWithJsonDictionary:) public required init(jsonDictionary: [String: Any]) { super.init(); ... }
@objc(toJsonDictionary) public var jsonDictionary: [String: Any] { ... }
```

**Gap 8 — ObjC private headers invisible to Swift in framework builds.** Never call ObjC private-header functions (e.g. `PBMFunctions.h`) from Swift twins — inline the logic instead (e.g. `PBMORTBImpExtSkadn` inlines `supportedSKAdNetworkVersions` with `#available` guards).

**Gap 9 — empty arrays are preserved.** `pbmCopyWithoutEmptyVals`/`pbmRemoveEmptyVals` strip only `nil`/`NSNull`, never `[]`. Do not add `.isEmpty ? nil : array` guards on `[String]` properties.

**Naming convention — no `PBM` prefix (applied S1.1).** Swift class = `ORTBFoo` (file `ORTBFoo.swift`), ObjC bridge name preserved via `@objc(PBMORTBFoo)` on the declaration. Mirrors the existing response-side pattern. Applies Phase 1 onward — **exception:** Gap S3.3-A.

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

Key points: no `PBM` prefix on the Swift name/file; `@objc(PBMORTBFoo)` bridge; `@objc public class` + `@objc public var` (Gap 6); explicit `@objc(initWithJsonDictionary:)` / `@objc(toJsonDictionary)` (Gap 7); `super.init()` first in the JSON init; no `NSCopying`; no `toJsonStringWithError:`/`fromJsonString:` (inherited); child `PBMJsonCodable` objects get automatic empty-dict suppression (Gap 2); empty `[String]` arrays pass through as-is (Gap 9). For a key not in the typed `Key` enum (dynamic `ext` sub-dict), mutate the dict returned by `json.dict` — it's `private(set)` and can't be written into directly from outside the struct (see Gap 10 below).

**Gap 10 (S1.2) — untyped sub-dict encoding.** When the wire format needs a raw `[String: Any]` that doesn't fit the typed `Key` enum (e.g. `ORTBImp.ext` built from several heterogeneous sub-fields):
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

`'PBMORTBFoo' has been renamed to 'ORTBFoo'` compiler errors ⇒ bulk-rename with `perl -pi` (BSD `sed -i ''` does not reliably handle `\b` word boundaries):
```bash
perl -pi -e 's/PBMORTBFoo\b/ORTBFoo/g' PrebidMobileTests/path/to/TestFile.swift
```
Scan at minimum: `PBMORTBAbstractTest.swift`, `PBMORTBBidRequestTest.swift`, `PrebidParameterBuilderTest.swift`, and any other Swift test importing/instantiating the migrated types. Catch stragglers with:
```bash
xcodebuild ... build-for-testing 2>&1 | grep "error:" | grep "has been renamed"
```

## Known flaky test — `PBMBidRequesterTest.testBanner_300x250` only

Allowlist of exactly this one test — not a general "re-run and move on" policy; during a migration a genuine regression is more likely to look like an intermittent async failure than at any other time. Pre-existing timing flakiness (`Asynchronous wait failed`), reproducible on `master` with no Swift twins present. Confirmed S1.3: fails in 2 consecutive full-suite runs, passes in isolation — root cause is simulator resource pressure under full-suite load, not a regression.

**Rule:** before dismissing a failure as this flake, confirm all three: (1) it's the only failure, (2) it passes run alone (`-only-testing .../testBanner_300x250`), (3) your step touched nothing in the bid-request/networking path. Any other flaky-looking failure must be investigated. Never silence it by relaxing the test (`assertForOverFulfill = false`, longer timeouts, weaker assertions).

## S1.3/S1.4 porting notes

**Non-`PBMJsonCodable` types.** Some `PrebidMobile/Objc/PrebidMobileRendering/ORTB/` classes are plain `NSObject` subclasses (custom designated init, no `toJsonDictionary`/`initWithJsonDictionary:`) — check the superclass before porting. Port these as plain `@objc public class ORTBFoo: NSObject` with the custom init; no `PBMJsonCodable`, no JSON-bridge selectors. Example: `ORTBRendererConfig`.

**Typed generic dicts.** A parameterized ObjC `NSDictionary<KeyType, ValueType>*` needs the matching concrete Swift type, not `[String: Any]` — e.g. `PBMORTBAppExt.data` (`NSDictionary<NSString*, NSArray<NSString*>*>*`) → `[String: [String]]?`. `[String: Any]?` compiles but breaks test code calling `.sorted()` on values.

**Non-optional ObjC properties in test code.** A non-`nullable` ObjC property ported to `NSNumber?` needs `?.` chains in test code changed to `.`. Catch with: `grep "cannot use optional chaining on non-optional"` in the build-for-testing output.

**`NSCopying` on root containers.** `NSObject` subclasses do NOT inherit `NSCopying` — `.copy()` crashes at runtime if not added explicitly. Any Swift twin whose ObjC original was `<NSCopying>` **and is actually `.copy()`'d** needs it added back via JSON round-trip:
```swift
public func copy(with zone: NSZone? = nil) -> Any { Self(jsonDictionary: jsonDictionary) }
```
Phase 1: only `ORTBBidRequest` needed this (its `.copy()` is called by test code) — check other phases as they land.

**`NSMutableDictionary` from JSON decode.** `JSONSerialization` always returns immutable `NSDictionary`, so `jsonDictionary["ext"] as? NSMutableDictionary` silently yields `nil` for a property declared `NSMutableDictionary *` in ObjC (`PBMORTBUser.ext`, `PBMORTBRegs.ext`). Decode via:
```swift
if let extDict = jsonDictionary["ext"] as? [String: Any] {
    ext = NSMutableDictionary(dictionary: extDict)
}
```
Forgetting this silently drops round-tripped `ext` contents (e.g. EIDs disappear after serialize/deserialize).

**Deleting `PBMORTBAbstract` — cascade.** Removes the `from(jsonString:)` class method, `copyWithZone:`, and the abstract fallback impls. Checklist: (1) replace `PBMORTBAbstract.from(jsonString:)`/`SomeType.from(jsonString:)` test calls with the `PBMJsonDecodable.from(jsonString:)` shim in `ORTBParityHelper.swift`; (2) remove `extension PBMORTBAbstract: SomeProtocol` test blocks; (3) remove `codeAndDecode<T: PBMORTBAbstract>` overloads (the `PBMJsonCodable` overload covers all Swift types); (4) delete `testAbstractMethods()` tests calling `PBMORTBAbstract.from(jsonString:)` directly; (5) **keep** `PBMORTBAbstract.h`/`+Protected.h` — Phase 3/4 ObjC parameter builders still import them.

## Validation checklist per PR

- [ ] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [ ] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build clean (catches header-visibility breakage the CocoaPods build masks — Gap S2.5-A)
- [ ] `./scripts/testPrebidMobile.sh --latest --quick` — clean pass (re-run once if only `PBMBidRequesterTest.testBanner_300x250` fails)
- [ ] Swift test files updated: no `'PBMORTBFoo' has been renamed` errors
- [ ] (Phase 1 & 3) JSON round-trip parity test passes (S0.2 harness)
- [ ] (Phase 1 & 3) Each migrated model has a **partial**-payload decode test asserting the re-encoded key set — a full fixture can't catch a resurrected default (Gap S2.5-C)
- [ ] No `"app": {}` / `"device": {}` empty-object regressions in captured bid requests
- [ ] PR doc states its **scope boundary** — which `S<phase>.<step>`s it lands and which ObjC files it deliberately leaves behind. The authoritative step list lives in the migration TaskNotes, not this repo — a PR titled "Phase N" is not self-evidently all of Phase N (added S3.2)

## Phase 2 gaps (S2.1)

**S2.1-A — `NS_TYPED_ENUM` constants can't bridge as free-standing ObjC constants from Swift.** Keep a residual ObjC `.m` with only the constant assignments; port the class implementations to Swift separately. Delete the residual `.m` once its last ObjC consumer is ported.

**S2.1-B — `@_spi(PBMInternal)` needs `@_spi` import in test files.** Any test accessing `Functions.*` (`@_spi(PBMInternal) public class`) directly needs `@_spi(PBMInternal) @testable import PrebidMobile`.

**S2.1-C — `dispatch_time()` unavailable in Swift; do not use `DispatchTime(uptimeNanoseconds:)` on a raw `dispatch_time_t`.** That initializer *converts* ns→mach-ticks, so round-tripping an already-tick value scales it again (invisible on simulator, ~41x off on arm64 devices where the timebase is 125/3). Branch on sentinels and convert explicitly (see `Functions.swift`):
```swift
switch startTime {
case dispatchTimeNow:     return (DispatchTime.now() + representableSeconds(timeInterval)).rawValue
case dispatchTimeForever: return dispatchTimeForever
default:
    let ticks = machTicks(fromSeconds: timeInterval)   // nanoseconds * denom / numer
    if ticks >= 0 {
        let (deadline, overflow) = startTime.addingReportingOverflow(UInt64(ticks))
        return overflow ? dispatchTimeForever : deadline
    }
    let elapsed = UInt64(ticks.magnitude)
    return elapsed > startTime ? dispatchTimeNow : startTime - elapsed
}
```
Signed arithmetic matters: `startTime &+ UInt64(bitPattern: negativeTicks)` wraps to "almost forever" instead of "already past" — branch on sign and subtract, saturating at `DISPATCH_TIME_NOW`. Clamp the interval before converting (`Int64(seconds * NSEC_PER_SEC)` traps on `.nan`/`.infinity`; `nanoseconds * denom` can overflow beyond ~97 years at a 125/3 timebase). Simulator timebase is 1:1, so only device testing validates the tick-conversion branches — reason about units at review time, don't rely on CI (`TestFunctions.testDispatchTimeAfterTimeInterval*`).

**S2.1-D** — `UIInterfaceOrientationIsPortrait()` → `orientation.isPortrait`.

**S2.1-E** — `@objc(name:)` on a `throws` method must include the error label: `@objc(dictionaryFromJSONString:error:)`, not `...:)`.

**S2.1-F** — ObjC `@dynamic value;` (CALayer) → Swift `@NSManaged var value: CGFloat`.

**S2.1-G — porting an `@objc protocol`:** reduce the ObjC private header to a forward declaration (`@protocol PBMFoo;`); the full definition comes from `PrebidMobile-Swift.h` via `SwiftImport.h`. Any `.m` calling methods on `id<PBMFoo>` needs `#import "SwiftImport.h"`.

## Phase 2 gaps (S2.2)

**S2.2-A** — `@objc extension NSDictionary/NSString/...` with `@objc public func` members appear as ObjC categories in `PrebidMobile-Swift.h`; consumers importing `SwiftImport.h` get them for free once the original `.h` is deleted.

**S2.2-B — string nil-guard preservation.** ObjC `nil` → `nonnull NSString *` bridges to Swift `""`, not `nil`. If the ObjC code had a nil guard, declare the Swift parameter `String?` (even if the header said `nonnull`) so `nil` actually passes through.

**S2.2-C** — a class conforming to an `@_spi(PBMInternal)` protocol must itself be `@_spi(PBMInternal)` (and so must any property/method returning that type), or the compiler errors "it is SPI".

**S2.2-D** — always call `@_spi` classes by their Swift name (`Factory`), never the ObjC bridge name (`PBMFactory`), from Swift code.

**S2.2-E — capitalized ObjC method names.** `LogViewHierarchy` imports to Swift as `logViewHierarchy()`. If both ObjC and Swift callers exist, name the Swift method lowercase and add `@objc(LogViewHierarchy)` to preserve the ObjC selector.

**S2.2-F — DEBUG-only category properties** (e.g. `Prebid.forcedIsViewable` in `Prebid+TestExtension.h`) aren't visible to Swift (Gap 8) — access via KVC inside `#if DEBUG`: `Prebid.shared.value(forKey: "forcedIsViewable") as? Bool ?? false`.

## Phase 2 gaps (S2.3)

**S2.3-A** — `NSInvocationOperation` has no Swift equivalent; replace with `target.perform(selector, with: argument)` guarded by `target.responds(to: selector)`.

**S2.3-B — ObjC block typedefs can't export as a named ObjC-visible Swift type.** For a header-only typedef `.h` (no `.m`), keep the header in place; the Swift implementation just uses a structurally-matching closure type (e.g. `(TimeInterval, AnyObject, Selector, Any?, Bool) -> ProtocolType`) — no cast needed, block types are structural.

**S2.3-C — reducing a header to a forward declaration can break its importers transitively.** E.g. reducing `PBMTimerInterface.h` (dropped `@import Foundation;`) broke `PBMScheduledTimerFactory.h`'s use of Foundation types. After any such reduction, check every importing header for Foundation-type usage and add `#import <Foundation/Foundation.h>` where needed.

## Phase 2 gaps (S2.4 — rebase hazards)

**S2.4-A — rebasing onto a commit that independently deleted the ported class.** A clean auto-merge only means no *overlapping lines* — it does not mean the port is still wanted. (`PBMTouchDownRecognizer`: master replaced it with `UITapGestureRecognizer` on different lines than the migration touched, so the port sailed through as dead code.) **Rule:** after every rebase, diff the upstream commits against this phase's ported classes; for any ObjC class deleted upstream (not just modified), delete the Swift port + test after confirming no post-rebase code still references it.

**S2.4-B — post-migration commits can reintroduce stale ObjC-name references in tests** (copy-paste from an older test). Not caught by the migration's own history. **Rule:** after rebasing, build once (`'PBMFoo' has been renamed` errors name the file), then proactively grep every `@objc(PBMFoo)` name this phase ported against all `*.swift` files outside its declaration line.

## Phase 2 gaps (review, S2.5)

**S2.5-A — deleting an ObjC header can break the SPM build only.** A `.m` that got UIKit transitively through a deleted header still compiles under CocoaPods (the generated `-Swift.h` re-exports the umbrella headers) but fails under SwiftPM (`@import PrebidMobile;` doesn't re-export UIKit): `error: declaration of 'UIScreen' must be imported from module 'UIKit.UIScreen'...`. Neither `buildPrebidMobile.sh` nor `buildPrebidSPM.sh` (builds the *published* package, not the working tree) catches this. **Rule:** any `.m` referencing UIKit types must `#import <UIKit/UIKit.h>` explicitly. Verify with `./scripts/buildPrebidMobilePackage.sh` (compiles `Package.swift` directly; wired into `PR_checks.yml` as `build-spm-package`).

**S2.5-B — don't reflexively add `[weak self]` when porting ObjC blocks.** An ObjC block with no `__weak`/`@weakify` captures `self` strongly — sometimes the *only* thing keeping it alive. (`PBMDownloadDataHelper`: callers create it as a bare local; a weak capture lets it deallocate between the HEAD and GET, silently dropping the completion.) **Rule:** port capture semantics literally; only add `[weak self]` where ObjC used `__weak`/`@weakify`, or where a retain cycle is demonstrable. Comment strong captures kept deliberately.

**S2.5-C — `?? default` in `init(jsonDictionary:)` resurrects defaults the wire format never sent.** ObjC's `initWithJsonDictionary:` calls `[self init]` first (seeding class defaults) then writes ivars **unconditionally** — an absent key overwrites the default with `nil`, and `pbmCopyWithoutEmptyVals` omits it on re-encode. `bidfloor = json[.bidfloor] ?? 0.0` is wrong; it invents a wire key ObjC never sent. **Rule:** assign unconditionally (`x = json[.k]`, never `?? default`) in the JSON init; keep the default only in the property declaration/plain `init()`. This forces the property optional even under `NS_ASSUME_NONNULL_BEGIN` — the header was lying; the JSON initializer is the proof. Same for collections (`ORTBBidRequest.imp` seeds one `ORTBImp()` in `init()` but must clear to `[]` if `"imp"` is absent/empty). **Exceptions where `?? default` is faithful:** the ObjC init explicitly substituted a value for a missing key (`ORTBPmp.deals`, `ORTBBanner.format`), or the property is never written by `toJsonDictionary`/is guarded by a non-empty check (no wire difference observable) — child-object fallbacks (`json[.pmp] ?? ORTBPmp()`) are fine since empty child dicts are suppressed on encode (Gap 2). A full round-trip fixture can't detect this bug — cover with a *partial* payload asserting the re-encoded key set (`assertORTBNoResurrectedDefaults` in `ORTBParityHelper.swift`).

**S2.5-D — `[nil isEqual:nil]` is `NO`; Swift `nil == nil` is `true`.** An `isEqual:` built from `[self.w isEqual:other.w] && ...` returns `NO` for all-nil vs. Swift's direct `w == other.w` translation returning `true` — changes `NSSet` dedup behavior for all-nil instances. `ORTBFormat`: accepted as-is (not fixed) because the only dedup callsite always populates `w`/`h` via `+ortbFormatWithSize:`, so all-nil never reaches the `NSSet`; reproducing ObjC exactly would require `w != nil && h != nil && ...`, breaking `isEqual:` reflexivity. **Rule:** when porting an `isEqual:` built from optional-property `isEqual:` calls, explicitly decide whether all-nil instances must stay distinct; if ObjC semantics can't be reproduced without breaking reflexivity, keep Swift semantics and comment the callsite justifying it.

**S2.5-E — `UIApplication.shared` is non-optional in Swift but nil host-less** (e.g. unit-test bundle). ObjC guarded with `if (!uiApplication)`; the non-optional Swift import can't be tested for nil and crashes at first use (typically boxed into `PBMUIApplicationProtocol`). **Rule:** never read `UIApplication.shared` directly in ported code — resolve via the ObjC runtime so nil stays observable:
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
Three follow-ons: (1) always consult the `Functions.application` test seam **first**, in one place (`resolvedApplication`) — a second `??` spelling invites drift; (2) route every application-derived read (e.g. `safeAreaInsets`, which needs the key window) through the protocol, not around it, and resolve once per call if multiple values are needed; (3) do not memoize — resolution is `nil` until `UIApplicationMain` runs, so a cached `nil` can outlive its cause; the lookup is cheap (one selector + `objc_msgSend`).

Scope: applied in `Functions.swift` only. **10 other files / 17 call sites still read `UIApplication.shared` directly** (`LocationManager.swift` ×4, `UIApplication+Extensions.swift` ×2, `AdViewButtonDecorator.swift` ×2, one each in `UIWindow+PBMExtensions.swift`, `UIWindow+Extensions.swift`, `ViewExposureChecker.swift`, `ModalViewController.swift`, `AutoRefreshManager.swift`, `Host.swift`, `NativeAd.swift`) — apply this rule when touching them. Re-measure: `grep -rn --include='*.swift' -F 'UIApplication.shared' PrebidMobile` (not CI-gated; SwiftLint isn't wired into any workflow today).

## Phase 3 gaps (S3.1/S3.2)

**S3.1-A — withdrawn.** Originally claimed `dict[key] = maybeNil` (Swift optional) stores a boxed `Optional.none` instead of removing the key, unlike ObjC. **False**, re-verified under `swiftc -swift-version 5`: `NSMutableDictionary`/`[String: Any]` remove the key for a single-level-optional `nil`, and optional chaining flattens (`targeting?.getSubjectToGDPR()` is `NSNumber?`, not `NSNumber??`). Only an explicitly *nested* optional (`String??` holding `.some(nil)`) boxes — and that assignment triggers a `coerced ... to 'Any?'` warning, so it can't land silently. **Rule:** translate literally, `dict[key] = maybeNil`; no helper needed. If the coercion warning appears, flatten (`?? nil` / `guard let`) rather than silence with `as Any?`.

**S3.1-B — a protocol Swift test mocks must conform to can't be `@objc`.** `@objc protocol BundleProtocol` would force `@objc` onto every conformer, including a plain-Swift `MockBundle`. **Rule:** injection-seam protocols consumed only by Swift stay plain `protocol Foo: AnyObject`, with the real type conformed retroactively (`extension Bundle: BundleProtocol {}`). Knock-on: S3.1-D.

**S3.1-C — an ObjC `Foo+pbmTestExtension.h` class extension can't re-open a Swift class.** (It re-declared `readonly` builder properties `readwrite` so a test could nil them.) Swift extensions can't add stored properties or loosen access. **Rule:** delete the test-extension header **and the looseness it existed to serve** — don't widen production properties to optional just to keep an error-path test alive; check call sites first (if all-Swift and already non-optional, the guard is unreachable and the test should be deleted, not preserved via a `TODO`). See S3.1-H for the behavior class this trades away.

**S3.1-D — `@objcMembers` fails if any member's signature has a non-ObjC type** (e.g. a `BundleProtocol` parameter, S3.1-B). **Rule:** don't reach for `@objcMembers` on a mixed-surface class; annotate only the ObjC-called members with the explicit selector: `@objc(buildParamsDictWithAdConfiguration:extraParameterBuilders:)`.

**S3.1-E — a Swift *test* subclass of a now-internal SDK Swift class breaks `<Module>Tests-Swift.h`.** Swift emits every internal-or-wider `NSObject`-derived test class into the generated test header, including its `@interface : Superclass` line — which doesn't compile if the superclass is internal/non-`@objc` in the main module. Surfaces at the *end* of the build, looks like a stale-header artifact (isn't). **Rule:** mark test-only SDK subclasses `fileprivate`/`private` (excluded from the generated header) rather than widening the SDK class to `@objc public`.

**S3.1-F — an ObjC class conforming to a Swift `@objc protocol` doesn't inherit the Swift method spelling.** `@objc(buildBidRequest:) func build(_:)` on the protocol; an ObjC conformer implementing `buildBidRequest:` satisfies ObjC but Swift callers only see `buildBidRequest(_:)`, not `build(_:)`. **Rule:** re-declare the method in the ObjC conformer's header with `NS_SWIFT_NAME`: `- (void)buildBidRequest:(...)bidRequest NS_SWIFT_NAME(build(_:));`.

**S3.1-G** — `ATTrackingManager.AuthorizationStatus.rawValue` is `UInt`; compare via `atts.uintValue == ATTrackingManager.AuthorizationStatus.authorized.rawValue`, not `.intValue`.

**S3.1-H — dropping `PBMAssert` turns a Release-mode log into a Release-mode trap.** ObjC's `PBMAssert(a && b && c)` compiles out in Release — a `nil` logged and continued. A Swift non-optional `let` makes the same `nil` a compile error (Swift caller) or an unconditional trap (ObjC caller), in every configuration. Fine when every constructor call is provably Swift (measure, don't assume — a set of "sibling" builders being non-optional isn't evidence for the one you haven't checked; `SKAdNetworksParameterBuilder`'s `adConfiguration` shipped as an undocumented `AdConfiguration?` for exactly this reason, later fixed to match its non-nullable ObjC header). **Rule:** measure first —
```bash
grep -rn --include='*.m' --include='*.h' 'initWith\|alloc] init' PrebidMobile EventHandlers
```
Swift-only ⇒ drop the assert, non-optional parameter, no guard. **If an ObjC caller survives, the bridged parameter must be `Optional`** (`String?`, not `String`) regardless of the header's `NS_ASSUME_NONNULL` annotation (compile-time only, doesn't stop a runtime `nil`) — ObjC→Swift bridging traps on `nil` for a non-optional parameter *before* the initializer body runs, so "keep it non-optional but add a graceful guard inside" is not achievable; the guard must live behind an `Optional` parameter. Guard-unwrap at the top and `Log.error` + `return nil` (or equivalent) on the nil case. (`PBMURLComponents` hit this for real via the surviving `PBMVastRequester.m` caller — see S3.3-A.)

**S3.2-A — Gap 4/Gap 6 don't apply per-phase, apply per-type, by measured importer check.** The Phase 3 builders have no surviving ObjC consumers (`PBMParameterBuilderService.m` was the only one, ported in the same PR) — only `ParameterBuilder` (still-ObjC conformer) and `ParameterBuilderService` (`PBMBidRequester.m` caller) need `@objc public`; the eight builders are plain `internal`. Same check applies to dragged-along support types — don't inherit whatever visibility the ObjC original had "on reflex" (`InternalUserConsentDataManager` was ported `@objcMembers` this way; measured, its only consumers are two Swift builders + a `@testable` test, so it's now a plain `final class`, no `NSObject` base). **Rule:**
```bash
grep -rn --include='*.h' --include='*.m' --include='*.mm' 'Foo' PrebidMobile EventHandlers PrebidMobileTests
```
Empty output ⇒ no `@objc`/`@objcMembers`/`NSObject` base unless needed for another reason (protocol conformance, KVO, `NSCopying`).

## Phase 3 gaps (S3.3)

**S3.3-A — `PBMURLComponents` keeps its ObjC prefix: Foundation-collision exception to the S1.1 naming rule.** `Foundation` already exports `URLComponents` (a struct), independently exercised by `URLComponentsTests.swift`; renaming the twin would shadow the stdlib type module-wide. **Rule:** when the de-prefixed name collides with an existing Foundation/UIKit (or SDK) type, keep the `PBM`-prefixed name on *both* sides of the bridge (`@objc(PBMURLComponents) public class PBMURLComponents: NSObject`) and skip the rename. Grep first: `rg -n '\bFoo\b' PrebidMobile EventHandlers PrebidMobileTests` — a bare non-PBM hit is the collision signal. One-off exception, not a reversal of S1.1. (`TrackingRecord`, ported alongside it, has no collision and follows S1.1 normally; per S3.2-A it also needs no `@objc`/`NSObject`/`public` — zero non-test consumers — and is a `struct`, not a class: two `let`s, pass-through init, no identity semantics.)

## Phase 4 gaps (S4.1)

**S4.1-A — a non-failable Swift initializer can retire an ObjC nil-check as unreachable, not just make it unreachable-but-harmless.** `PBMBidResponseTransformer`'s ObjC implementation nil-checked the result of `[[BidResponse alloc] initWithJsonDictionary:]` and returned `PBMError.responseDeserializationFailed()` on nil. The Swift twin (`BidResponse.init(jsonDictionary:)`) is a non-failable `convenience init` — it always succeeds — so the check can never trigger. **Rule:** verify the twin's initializer signature first (`grep -n 'init(jsonDictionary' BidResponse.swift`); if non-failable, drop the dead branch entirely rather than porting a defensive check that can't fire (don't keep it "just in case" — an unreachable branch has no test coverage and misrepresents the real error surface to a reader). This is the mirror image of S3.1-H: there, a dropped assert could turn a live path into a trap; here, the ObjC check was already provably dead once the callee stopped being able to fail.

**S4.1-B — plan-inventoried steps (S4.1-S4.5) don't cover 100% of a phase's files; re-measure the directory before splitting into PRs.** `find PrebidMobile/Objc/.../Prebid/PBMCore -name '*.m'` turned up 13 files against 10 named in the plan's step breakdown — `PBMBidRequesterFactory.m`, `PBMSafariVCOpener.m`, `PBMWinNotifier.m` were unaccounted for. Consumer analysis (`grep -rn 'PBMSafariVCOpener\|PBMWinNotifier\|PBMBidRequesterFactory' PrebidMobile EventHandlers`) resolved the three: `PBMBidRequesterFactory` folds into S4.3 (only consumer is `PBMPrebidParameterBuilder.m`, same PR); `PBMWinNotifier` becomes a new S4.3b (its Swift protocol `WinNotifier.swift` already exists, unimplemented — same PR as S4.3 for locality); `PBMSafariVCOpener` defers to Phase 7 (its only consumer, `PBMAbstractCreative.m`, isn't migrated yet — porting it now would leave an orphaned Swift type with no real caller to verify against). **Rule:** re-run the file-count measurement per-phase before committing to a step/PR split; treat the plan document's step list as a first draft, not a checksum.

**S4.1-C — `@testable import` does not unlock `@_spi`-restricted symbols; the importer needs its own `@_spi(GroupName)` annotation.** After renaming `PBMBidResponseTransformer` → `BidResponseTransformer` (declared `@_spi(PBMInternal) public class`, per S1.1's cross-module-visibility rule), the full test target failed with "cannot find type 'BidResponseTransformer' in scope" — but only in files importing with a bare `@testable import PrebidMobile` or a bare `import PrebidMobile`; files already spelling `@_spi(PBMInternal) @testable import PrebidMobile` compiled fine. The failure was file-local and cascaded: `PBMBidResponseTransformer+TestExtension.swift` (a bare `import PrebidMobile`) failed first, and every test file consuming its static factory methods (`.someValidResponse`, `.makeValidResponse`, etc.) then reported "type 'BidResponseTransformer' has no member 'X'" instead of the real "type not found" error one file over — a classic single-root-cause-many-symptoms trap. **Rule:** whenever an SPI-restricted type gains new consumers (or an existing consumer is renamed to match it), grep every importer for the pattern first: `rg -n 'import PrebidMobile' <files>` and confirm each one reads `@_spi(GroupName) import PrebidMobile` or `@_spi(GroupName) @testable import PrebidMobile` — a plain `@testable import` is not sufficient, `@testable` and `@_spi` are independent, both-required visibility unlocks. When debugging a "cannot find type/member in scope" error that doesn't match the file you're looking at, check for cascading failures from a same-symbol producer file (e.g. a `+TestExtension.swift`) before chasing build-system/caching theories.

## Phase 4 gaps (S4.3/S4.3b)

**S4.3-A — `@objc(Name)` on a class exposes the class to Objective-C, but does not by itself expose a custom (non-protocol-witness) initializer or method; only `@objc`-protocol witnesses get automatic inference.** `PrebidParameterBuilder`'s `build(_:)` needed no explicit `@objc` because it satisfies `ParameterBuilder`'s `@objc(buildBidRequest:)` requirement (protocol is `@objc(PBMParameterBuilder) public protocol ParameterBuilder`) — that inference is real (Gap 7 already covers protocol-witness methods). But the class's own 4-parameter designated initializer is not a protocol requirement, and was silently dropped from the generated `PrebidMobile-Swift.h` (only the `SWIFT_UNAVAILABLE`-marked default `init` appeared). The surviving ObjC caller (`PBMBidRequester.m`'s `[[PBMPrebidParameterBuilder alloc] initWithAdConfiguration:sdkConfiguration:targeting:userAgentService:]`) failed to link: `no visible @interface for 'PBMPrebidParameterBuilder' declares the selector 'initWithAdConfiguration:...'`. **Rule:** any custom `init` on an `@objc(Name)`-bridged `NSObject` subclass that a surviving ObjC caller must construct needs its own explicit `@objc` (`@objc public init(...)`), or the whole class needs `@objcMembers` (only viable if every member's signature is ObjC-representable — S3.1-D). Diagnose by reading the generated `<Target>-Swift.h` under DerivedData directly — it is the ground truth for what ObjC actually sees, faster than guessing from the Swift source. Don't assume "one method on this class already bridges automatically" implies "every method/init on this class bridges automatically" — check protocol-witness status per-member. Contrast case: `WinNotifierImpl` (S4.3b) needed no member-level `@objc` at all — its ObjC-side identity is resolved once via `NSClassFromString("PBMWinNotifier_Objc")` (class-level bridge only, per `Factory.WinNotifierType`), and every actual call site (`notifyThroughConnection`, `winNotifierBlock`, `factoryBlock`) is Swift-only; no ObjC code ever calls a member by selector.

**S4.3-B — order steps so the last surviving ObjC consumer is ported *last*; it is a free compile-time test of every dependency's `@objc` surface.** Phase 4's executed order is `S4.1 → S4.3 + S4.3b → S4.4 → S4.2 → S4.5`, not the plan's numeric order. S4.2 (`PBMBidRequester.m`, 233 lines — the largest file left in `PBMCore`) is the only remaining ObjC caller of S4.1's `PBMBidResponseTransformer` (`PBMBidRequester.m:127`) and S4.3's `PBMPrebidParameterBuilder` (`:188-196`). Leaving it in ObjC while its dependencies migrate means the compiler checks each port's bridged surface for free — which is exactly how Gap S4.3-A surfaced. Port the consumer first and those call sites become Swift→Swift: a missing member-level `@objc` then compiles cleanly and only fails later at runtime, through `NSClassFromString`/selector lookup, with no compiler to catch it. Deferring costs nothing here because S4.2's *own* port is low-risk: `PBMBidRequester.m:22` already declares `PBMBidRequester_Objc` conforming to the Swift protocol `BidRequester` (`@objc(PBMBidRequester)`), constructed solely via `Factory.swift:26`'s `NSClassFromString("PBMBidRequester_Objc")`, with no ObjC callers and only `SwiftImport.h`/`Log+Extensions.h`/`PBMMacros.h`/UIKit imports — the `WinNotifierImpl` shape, a drop-in class swap. Secondary tiebreaker: S4.2's test class owns the repo's one known-flaky test (`PBMBidRequesterTest.testBanner_300x250`, see `agents/review/SKILL.md`), so landing it early would hand every later step in the phase an ambiguous baseline. **Rule:** before fixing a step order, build the consumer graph (`rg -n 'ClassName' PrebidMobile EventHandlers`) and sort so that ObjC→Swift call edges survive as long as possible; prefer porting leaves before roots. Record the *reason* in the PR doc — "per the user-approved step order" is not a rationale, and a later reader cannot reconstruct it without redoing the analysis. (Unexplained residue: nothing in the code requires S4.2 to sit *between* S4.4 and S4.5 rather than simply last — S4.4/S4.5 are the ClickTracking and TransactionFactory groups, neither of which touches `PBMBidRequester` in either direction.)

**S4.3-C — a header with a matching `.m` can still be dead: the `_Objc` shim rename leaves the old `@interface` behind.** `PrivateHeaders/PBMBidRequester.h` declares `@interface PBMBidRequester : NSObject <PBMBidRequesterProtocol>`, but `PBMBidRequester.m` implements `PBMBidRequester_Objc` and never imports that header; no file in the repo imports it either (only four `project.pbxproj` entries reference it). It is therefore invisible to the orphan-header sweep below, which only finds `.h` files with *no* same-named `.m`. **Rule:** when a class is renamed to `Foo_Objc` to free the bare `Foo` name for a Swift protocol, check whether the old `Foo.h` still declares the pre-rename `@interface` — if so it is dead and should be deleted with that class's port (here, S4.2). Verify with `rg -n '"Foo\.h"' PrebidMobile EventHandlers PrebidMobileTests` (expect `.pbxproj`-only hits) plus a `grep -E '@implementation Foo( |$)' Foo.m` miss.

## Orphan headers — `.h` files with no `.m` (inventoried S3.2)

**35 headers under `PrebidMobile/Objc/` have no matching `.m`** (was 39 as of S3.2; S4.3/S4.3b deleted 4 — `PBMAdMarkupStringHandler.h`, `PBMBidRequesterFactoryBlock.h`, `PBMWinNotifierBlock.h`, `PBMWinNotifierFactoryBlock.h` — once their last importers, `PBMWinNotifier.m`/`PBMPrebidParameterBuilder.m`/`PBMBidRequesterFactory.m`, were ported/removed): block typedefs, `@protocol`s, macro headers, `+Protected`/`+Internal`/`+Private` class-continuation headers, `NS_ENUM`s, umbrella headers, categories on system classes. None is itself "ported" — each is **retired when its last importer is ported**. 2 dead + 24 tied to a named `.m` + 5 tied to the test bridging header + 4 shared-infrastructure = 35.

Re-measure:
```bash
comm -23 \
  <(find PrebidMobile/Objc -name '*.h' | sed 's|.*/||; s|\.h$||' | sort -u) \
  <(find PrebidMobile/Objc -name '*.m' | sed 's|.*/||; s|\.m$||' | sort -u)
```

**A — already dead** (zero `#import`s anywhere; deletable any time, left in place only to keep prior diffs scoped):

| Header | Kind | Note |
|--------|------|------|
| `PBMAdLoadFlowController.h` | `@interface` | Swift twin `AdLoadFlowController.swift` already ships |
| `PBMORTB_NotImplemented.h` | macros | referenced only by a stale `.pbxproj` entry |

**B — retired with a named `.m`** (measured S3.2; a header imported only by another header is resolved to the root `.m` — re-run `grep -rl '"Foo.h"' PrebidMobile PrebidMobileTests` before acting on a row):

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
| `PBMORTBAbstract.h` | `@interface` | via `PBMORTBAbstract+Protected.h` → `PBMBidResponseTransformer.m` |
| `PBMORTBAbstract+Protected.h` | class continuation | `PBMBidResponseTransformer.m` |
| `PBMScheduledTimerFactory.h` | block typedef | `PBMCreativeViewabilityTracker.m` |
| `PBMTimerInterface.h` | forward decl | via `PBMScheduledTimerFactory.h` → `PBMCreativeViewabilityTracker.m` |
| `PBMTrackingURLVisitorBlock.h` | block typedef | `PBMTrackingURLVisitors.m`, `PBMExternalLinkHandler.m` |
| `PBMTransactionFactoryCallback.h` | block typedef | `PBMDisplayTransactionFactory.m`, `PBMVastTransactionFactory.m` |
| `PBMUIApplicationProtocol.h` | forward decl | `PBMExternalURLOpeners.m`, `PBMDeepLinkPlusHelper+Testing.m`, `PBMHTMLCreative+pbmTestExtension.h` (S2.5-E's seam type) |
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

**`NSNull` from `JSONSerialization` is not `nil`.** Typed reads are inherently safe (`NSNull as? String/NSNumber/[String: Any]` all yield `nil`), so every typed `JSONObject` subscript and `case let value as ...` pattern in `JSONParsing.swift` already rejects it. The hazard is confined to **untyped existence checks** — one instance exists (`ORTBImpExtPrebid.swift:37`, `jsonDictionary["is_rewarded_inventory"] != nil`, `true` for a JSON `null`); it matches the ObjC original's `!= nil` test so it's not a regression, but don't add more. **Rule:** never test presence with `dict[key] != nil` / bare `if let`; read through a type (`as? NSNumber`), or guard explicitly like `NSMutableDictionary+PBMExtensions.swift:40`: `value == nil || value is NSNull`.

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
