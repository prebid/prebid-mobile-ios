# Swift Migration Playbook

Per-class file-level porting guide for migrating `PrebidMobile/Objc/` to Swift.
See the full phasing plan in the TaskNotes task "[PI][PREBID] Develop a plan to migrate the iOS SDK to Swift".

## Per-class steps

For each `Foo.m` + `Foo.h`:

1. Create `Foo.swift` at the mirrored path under `PrebidMobile/Swift/...`.
2. Declare `@objc class PBMORTBFoo: NSObject, PBMJsonCodable` — see §Gap 4 below for why.
3. Port property declarations 1:1, preserving exact JSON key strings.
4. Implement `init?(jsonDictionary:)` using `JSONObject<KeySet>` subscripts (see pattern in `ORTBBid.swift`).
5. Implement `var jsonDictionary: [String: Any]` using `JSONObject<KeySet>` — the subscript setter for `PBMJsonCodable` values already suppresses empty child dicts (see §Gap 2); no `nullIfEmpty` needed.
6. `fromJsonString:`/`toJsonStringWithError:` — do **not** reimplement; they are inherited from `PBMJsonDecodable`/`PBMJsonEncodable` default extensions.
7. Replace `PBMJsonDictionary` typedef with `[String: Any]` at every site touched.
8. Do **not** add `NSCopying` — see §Gap 1.
9. Update ObjC consumers to import `PrebidMobile-Swift.h` (they bridge automatically once the `.h`/`.m` are deleted).
10. Delete `Foo.m`, `Foo.h`, and any matching entry in `PrebidMobile/Objc/PrivateHeaders/`.
11. Verify: `./scripts/testPrebidMobile.sh --latest --quick`.

## Gap audit findings (S0.1)

### Gap 1 — `NSCopying`: Drop it entirely

`PBMORTBAbstract` declares `<NSCopying>` and implements `copyWithZone:` via a JSON round-trip.
Grep confirms **no callsite in the codebase calls `.copy()` on any ORTB model object**.
All `.copy()` calls found are on blocks, plain strings, NSArrays, or NSError — standard Swift value semantics handle those without any protocol conformance.

**Rule:** Swift ORTB twins do not implement `NSCopying` or any equivalent.

### Gap 2 — Empty child dict suppression (`nullIfEmpty` pattern): one-line fix in `JSONObject`

ObjC composite ORTB types call `[[child toJsonDictionary] nullIfEmpty]` when writing child objects into the parent dict. `nullIfEmpty` converts an empty `{}` to `NSNull`, and `pbmCopyWithoutEmptyVals` then strips it, so no `"app": {}` appears in JSON output.

Swift `JSONObject`'s subscript setter for `PBMJsonCodable` values naively assigns `newValue?.jsonDictionary`, which stores an empty `[:]` as-is — this would produce `"app": {}` in serialized output.

**Fix applied** (see `JSONParsing.swift`): the `PBMJsonCodable` subscript setter now skips empty dicts:

```swift
set {
    let childDict = newValue?.jsonDictionary
    dict[key.rawValue] = (childDict?.isEmpty == true) ? nil : childDict
}
```

### Gap 3 — `PBMORTBFormat` must be `Equatable`/`Hashable` (NSObject overrides)

`PBMORTBFormat` is deduplicated via `NSSet setWithArray:` in `PBMPrebidParameterBuilder.m:197`.
Its ObjC `isEqual:` / `hash` are based on the `w` and `h` fields.

**Rule:** The `PBMORTBFormat` Swift twin (an `NSObject` subclass — see §Gap 4) overrides `isEqual(_:)` and `hash` based on `w` and `h`. This is the only Phase 1 type requiring this treatment.

```swift
override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? PBMORTBFormat else { return false }
    return w == other.w && h == other.h
}

override var hash: Int { (w?.hashValue ?? 0) ^ (h?.hashValue ?? 0) }
```

### Gap 4 — Phase 1–3 Swift twins must be `@objc NSObject` subclasses

The response-side Swift ORTB types (`ORTBBid`, `ORTBBidResponse`, etc.) are plain Swift `class` because they are consumed exclusively by Swift code.

The **request-side** ORTB models (Phase 1) are consumed by ObjC parameter builders that remain in ObjC until Phase 3. Once we delete a `PBMORTBFoo.m`/`.h`, those ObjC files import `PrebidMobile-Swift.h` and use the Swift type. For ObjC bridging to work, the Swift type must inherit from `NSObject`.

**Rule:** Phase 1–3 Swift twins are declared `@objc class PBMORTBFoo: NSObject, PBMJsonCodable`.

**Corrected in S3.2.** The original wording — "after Phase 3 all ObjC consumers are gone" — is wrong.
Phase 3 removes the ObjC parameter *builders*, but four ObjC files still consume ORTB Swift twins
after it: `PBMPrebidParameterBuilder.m`, `PBMBidRequester.m`, `PBMBidResponseTransformer.m` and
`PBMWebView.m`. Keep `NSObject` until all four are ported; revisit dropping it in S9.x cleanup.

### Gap 5 — `initWithJsonDictionary:` broken-instance fallback vs. `init?`

`PBMORTBAbstract.initWithJsonDictionary:` logs an error and returns `[PBMORTBAbstract new]` (a broken abstract instance). The Swift `init?(jsonDictionary:)` protocol requirement returns `nil` on failure — semantically correct.

**Rule:** No change to `PBMJsonCoding.swift` needed. During S1.1, audit test code for any test that depended on the broken-instance behavior and update to expect `nil`.

### Gap 6 — Framework build visibility: `public` required (discovered S1.1)

In a framework archive build, Swift types with `internal` access only appear as `@class` forward stubs in `PrebidMobile-Swift.h`. ObjC consumers in the same target get "receiver type is a forward declaration" errors when trying to alloc/init or call methods.

**Rule:** All Phase 1–3 Swift twins must be `@objc public class` with `@objc public var` properties. Demote to `internal` in S9.2 — **not** after Phase 3; see the correction under Gap 4 for the four ObjC files that still consume ORTB twins past Phase 3.

### Gap 7 — ObjC selector bridge: explicit annotations required (discovered S1.1)

Protocol requirements from non-`@objc` protocols (`PBMJsonDecodable.init?`, `PBMJsonEncodable.jsonDictionary`) do NOT get automatic `@objc` selector inference even on `public NSObject` subclasses. ObjC consumers get "no visible @interface declares the selector" errors.

**Rule:** Use explicit ObjC bridge annotations on both required members:
- `@objc(initWithJsonDictionary:) public required init(jsonDictionary:)` — non-optional (a non-failable init satisfies the failable protocol requirement); call `super.init()` as first statement.
- `@objc(toJsonDictionary) public var jsonDictionary: [String: Any]`

This matches the existing pattern in `ORTBAppContent.swift`.

### Gap 8 — ObjC private headers not visible to Swift in framework builds (discovered S1.1)

ObjC private headers (e.g. `PBMFunctions.h`) are not bridged into the Swift compilation context during a framework archive build. Any Swift file that calls `PBMFunctions.*` will fail with "cannot find in scope".

**Rule:** Do not call ObjC private-header functions from Swift migration twins. Inline the logic in Swift instead. Example: `PBMORTBImpExtSkadn` inlines `supportedSKAdNetworkVersions` as a `private static var` with `#available` guards, removing the `PBMFunctions` dependency.

### Gap 9 — Empty arrays are preserved by `pbmCopyWithoutEmptyVals` (discovered S1.1)

`pbmCopyWithoutEmptyVals` and `pbmRemoveEmptyVals` only strip `nil` / `NSNull` — **empty arrays `[]` are kept**. Swift twins must not suppress empty `[String]` arrays. Pass them through as-is; do not apply `.isEmpty ? nil : array` guards.

### Naming convention — no PBM prefix on Swift types (applied S1.1)

Swift class names and filenames drop the `PBM` namespace prefix. The ObjC bridge name is preserved via `@objc(PBMORTBFoo)` on the class declaration so all ObjC consumers continue to see the original `PBMORTBFoo` name unchanged.

**Rule:** Swift class = `ORTBFoo`, filename = `ORTBFoo.swift`, ObjC bridge = `@objc(PBMORTBFoo)`. This mirrors the existing response-side pattern (`ORTBAppContent`, `ORTBBid`, etc.). Applies to every Swift twin from Phase 1 onward.

## Canonical Swift twin template

```swift
// PrebidMobile/Swift/PrebidMobileRendering/Prebid/PBMCore/ORTB/Request/ORTBFoo.swift

import Foundation

@objc(PBMORTBFoo)
public class ORTBFoo: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var someField: NSNumber?
    @objc public var anotherField: String?

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        someField    = json[.someField]
        anotherField = json[.anotherField]
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.someField]    = someField
        json[.anotherField] = anotherField
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case someField    = "somefield"
        case anotherField = "anotherfield"
    }
}
```

Key points:
- **Filename / Swift class name**: `ORTBFoo` / `ORTBFoo.swift` — no `PBM` prefix.
- **ObjC bridge name**: `@objc(PBMORTBFoo)` on the class — ObjC consumers unchanged.
- `@objc public class` + `@objc public var` — required for framework build ObjC bridge (Gap 6).
- `@objc(initWithJsonDictionary:)` + non-optional `public required init` — exposes the init selector to ObjC (Gap 7).
- `@objc(toJsonDictionary)` — exposes the encode selector to ObjC (Gap 7).
- `super.init()` as first statement in the JSON init.
- No `toJsonStringWithError:` / `fromJsonString:` implementations — inherited.
- No `NSCopying`.
- For child ORTB objects, use `json[.childKey] = self.childObj` — empty-dict suppression is automatic (Gap 2).
- Empty `[String]` arrays: include as-is, never suppress (Gap 9).
- When you need to inject a key not part of the typed `Key` enum (e.g. a dynamic `ext` sub-dict), use `var result = json.dict; result["ext"] = ext; return result` — `JSONObject.dict` has `private(set)` and cannot be written from outside the struct directly.

### Encoding pattern for untyped sub-dicts (Gap 10 — discovered S1.2)

`JSONObject.dict` is `private(set)`, so you cannot do `json.dict["ext"] = ext` from outside the struct. When the serialized form requires injecting a raw `[String: Any]` dict that does not fit a typed `Key` (e.g. `ORTBImp.ext` which is built from several heterogeneous sub-fields), build via subscripts first then mutate the returned dict:

```swift
@objc(toJsonDictionary)
public var jsonDictionary: [String: Any] {
    var json = JSONObject<Key>()
    // ... typed subscript assignments
    var result = json.dict
    let ext = extDictionary          // private [String: Any] helper
    if !ext.isEmpty { result["ext"] = ext }
    return result
}
```

## Swift test file updates after each migration step

When a Swift test file references a migrated type by its old `PBMORTBFoo` name, the Swift compiler emits `'PBMORTBFoo' has been renamed to 'ORTBFoo'`. Fix with a bulk rename using `perl -pi`:

```bash
perl -pi -e 's/PBMORTBFoo\b/ORTBFoo/g' PrebidMobileTests/path/to/TestFile.swift
```

**Use `perl -pi` not `sed -i ''` for word-boundary replacements** — BSD `sed` on macOS does not reliably handle `\b` word boundaries; `perl` does.

Files to scan after each migration step:
- `PrebidMobileTests/RenderingTests/Tests/PBMORTBAbstractTest.swift`
- `PrebidMobileTests/RenderingTests/Tests/PBMORTBBidRequestTest.swift`
- `PrebidMobileTests/RenderingTests/Tests/ParameterBuilderTests/PrebidParameterBuilderTest.swift`
- Any other Swift test file that imports or instantiates the migrated types

Run after renaming: `xcodebuild ... build-for-testing 2>&1 | grep "error:" | grep "has been renamed"` to catch stragglers.

## Known flaky test — `PBMBidRequesterTest.testBanner_300x250` only

This section is an allowlist of exactly one test. It is **not** a general "re-run and move on"
policy: during a migration, a genuine regression is far more likely to present as an
intermittent async failure than at any other time, so every other flaky-looking failure must be
investigated.

`PBMBidRequesterTest.testBanner_300x250` fails intermittently with:
> Asynchronous wait failed: Exceeded timeout of 5 seconds, with unfulfilled expectations: "exp".

This is a **pre-existing timing flakiness** unrelated to the Swift migration — it reproduces on
`master` with no Swift twins present.

**Rule (this test only):** a re-run passing is *not* sufficient evidence. Confirm all three:

1. It is the only failure.
2. It passes in isolation:
   `-only-testing PrebidMobileTests/PBMBidRequesterTest/testBanner_300x250`.
3. The step you just landed touched nothing in the bid-request or networking path (otherwise
   treat it as a regression until proven otherwise, regardless of 1 and 2).

If any check fails, investigate. Never silence it by relaxing the test (`assertForOverFulfill =
false`, longer timeouts, weakened assertions) — that converts a real signal into a permanent
blind spot.

**Confirmed S1.3:** fails in 2 consecutive full-suite runs, passes immediately when run alone.
Root cause is simulator resource pressure under full-suite load, not a regression.

### Non-`PBMJsonCodable` types (discovered S1.3)

Not every type in `PrebidMobile/Objc/PrebidMobileRendering/ORTB/` inherits from `PBMORTBAbstract`. Some are plain `NSObject` subclasses with custom designated initializers and no `toJsonDictionary`/`initWithJsonDictionary:`. These do NOT conform to `PBMJsonCodable`.

**Rule:** Check each file's superclass before starting. If it inherits from `NSObject` (not `PBMORTBAbstract`), port as a plain `@objc public class ORTBFoo: NSObject` with the custom designated init — no `PBMJsonCodable`, no `@objc(initWithJsonDictionary:)`, no `@objc(toJsonDictionary)`.

Example: `ORTBRendererConfig` — plain `NSObject`, designated init `initWithName:version:data:`.

### Typed ObjC generic dicts (discovered S1.3)

When an ObjC property uses a parameterized `NSDictionary<KeyType, ValueType>`, declare the Swift equivalent with the correct concrete types — not `[String: Any]`. The type matters for test code that calls methods on the values.

Example: `PBMORTBAppExt.data` is `NSDictionary<NSString*, NSArray<NSString*>*>*` → Swift `[String: [String]]?`. Using `[String: Any]?` compiles but breaks tests that call `.sorted()` on the values.

### Non-optional ObjC properties in test code (discovered S1.3)

When an ObjC property is declared without `nullable` (e.g. `@property (nonatomic, strong) NSNumber *pos`) but made `NSNumber?` in Swift, test code that used `?.` chains on the property needs the optional chain removed (`.` instead of `?.`).

Catch with: `xcodebuild ... build-for-testing 2>&1 | grep "cannot use optional chaining on non-optional"`.

### NSCopying on root containers (discovered S1.4)

`PBMORTBAbstract` implemented `<NSCopying>` via a JSON round-trip. Swift twins that inherit from `NSObject` do NOT get `NSCopying` automatically — `obj.copy()` crashes at runtime.

**Rule:** Any Swift twin that replaces an `NSCopying`-conforming ObjC type must explicitly add `NSCopying`. Implement via JSON round-trip to match the ObjC behaviour:

```swift
public func copy(with zone: NSZone? = nil) -> Any {
    Self(jsonDictionary: jsonDictionary)
}
```

For Phase 1 only `ORTBBidRequest` needs this (it's the only type whose `.copy()` is called by test code). Check other phases as they land.

### NSMutableDictionary from JSON decode (discovered S1.4)

When an ObjC property is `NSMutableDictionary *` (e.g. `PBMORTBUser.ext`, `PBMORTBRegs.ext`), `JSONSerialization` always returns an immutable `NSDictionary`. The cast `jsonDictionary["ext"] as? NSMutableDictionary` silently returns `nil`, leaving the property nil even when the JSON contained data.

**Rule:** Decode mutable dict properties by wrapping in `NSMutableDictionary(dictionary:)`:

```swift
if let extDict = jsonDictionary["ext"] as? [String: Any] {
    ext = NSMutableDictionary(dictionary: extDict)
}
```

This applies to any property declared `NSMutableDictionary *` in ObjC that is decoded from JSON. Forgetting this silently breaks any code that reads back a round-tripped `ext` (e.g. EIDs disappear after `ORTBBidRequest` serialization/deserialization).

### Deleting PBMORTBAbstract — cascade effects (discovered S1.4)

Deleting `PBMORTBAbstract.m` removes:
- The `from(jsonString:)` ObjC class method (bridged as `try SomeClass.from(jsonString:)` in Swift tests)
- The `copyWithZone:` NSCopying implementation
- The `toJsonDictionary`/`initWithJsonDictionary:` abstract fallback implementations

**Action items when deleting `PBMORTBAbstract.m`:**
1. Search tests for `PBMORTBAbstract.from(jsonString:)` and `SomeType.from(jsonString:)` — replace with the `PBMJsonDecodable.from(jsonString:)` shim (defined in `ORTBParityHelper.swift`).
2. Remove any `extension PBMORTBAbstract: SomeProtocol` blocks in test files.
3. Remove `codeAndDecode<T: PBMORTBAbstract>` overloads — the `PBMJsonCodable` overload handles all Swift types.
4. Remove any `testAbstractMethods()` test that calls `PBMORTBAbstract.from(jsonString:)` directly.
5. Keep `PBMORTBAbstract.h` and `PBMORTBAbstract+Protected.h` — Phase 3/4 ObjC parameter builders still import them.

## Validation checklist per PR

- [ ] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [ ] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build of the working tree clean (catches header-visibility breakage the CocoaPods build masks — Gap S2.5-A)
- [ ] `./scripts/testPrebidMobile.sh --latest --quick` — must pass on a clean run (re-run once if only `PBMBidRequesterTest.testBanner_300x250` fails)
- [ ] Swift test files updated: no `'PBMORTBFoo' has been renamed` compiler errors
- [ ] (Phase 1 & 3) JSON round-trip parity test passes (see S0.2 harness)
- [ ] (Phase 1 & 3) Each migrated model has a **partial**-payload decode test asserting the
      re-encoded key set — a full fixture cannot catch a resurrected default (Gap S2.5-C)
- [ ] No `"app": {}` / `"device": {}` empty-object regressions in captured bid requests
- [ ] The PR doc states its **scope boundary** — which `S<phase>.<step>`s it lands, and which ObjC
      files in the same area it deliberately leaves behind. The authoritative step list lives in
      the migration TaskNotes, not in this repo, so a PR titled "Phase N" is not self-evidently the
      whole of Phase N; say so explicitly or the reviewer cannot tell (added S3.2)

## Phase 2 gaps (discovered S2.1)

### Gap S2.1-A — NS_TYPED_ENUM constants cannot be bridged as free-standing ObjC constants from Swift

`FOUNDATION_EXPORT NSString * const PBMFooAction = @"foo"` style global constants have no Swift equivalent that bridges to C-level symbols. Keep a residual ObjC `.m` file containing ONLY the constant assignments; port the class implementations to Swift separately. Delete the residual `.m` when the last ObjC consumer of those constants is ported.

### Gap S2.1-B — @_spi(PBMInternal) class requires @_spi import in test files

`Functions` (`PBMFunctions`) is declared `@_spi(PBMInternal) public class`. Any Swift test file that accesses `Functions.*` directly must use `@_spi(PBMInternal) @testable import PrebidMobile` instead of just `@testable import PrebidMobile`.

### Gap S2.1-C — dispatch_time() C function unavailable in Swift

The C function `dispatch_time(startTime, delta)` is not exposed to Swift, and neither are the
`DISPATCH_TIME_NOW` / `DISPATCH_TIME_FOREVER` macros. The obvious translation is wrong:

```swift
// WRONG — do not use
(DispatchTime(uptimeNanoseconds: startTime) + timeInterval).rawValue
```

`DispatchTime.rawValue` is a raw `dispatch_time_t`, expressed in **mach ticks**.
`DispatchTime(uptimeNanoseconds:)` *converts* nanoseconds to ticks via `mach_timebase_info`.
Round-tripping a `dispatch_time_t` through it therefore scales the value a second time and yields a
bogus deadline. The simulator's timebase is 1:1 so the error is invisible there; on arm64 devices it
is 125/3, so the deadline is off by ~41x.

**Rule:** Branch on the sentinel values and do the tick conversion explicitly. Reference
implementation in `Functions.swift`:

```swift
private static let dispatchTimeNow: UInt64 = 0
private static let dispatchTimeForever: UInt64 = .max

switch startTime {
case dispatchTimeNow:
    return (DispatchTime.now() + representableSeconds(timeInterval)).rawValue
case dispatchTimeForever:
    return dispatchTimeForever
default:
    let ticks = machTicks(fromSeconds: timeInterval)
    if ticks >= 0 {
        let (deadline, overflow) = startTime.addingReportingOverflow(UInt64(ticks))
        return overflow ? dispatchTimeForever : deadline
    }
    let elapsed = UInt64(ticks.magnitude)
    return elapsed > startTime ? dispatchTimeNow : startTime - elapsed
}
```

where `machTicks(fromSeconds:)` applies `nanoseconds * denom / numer` from `mach_timebase_info`.

**The signed arithmetic matters.** `dispatch_time_t` is unsigned, mach ticks from a negative
interval are not. `startTime &+ UInt64(bitPattern: negativeTicks)` wraps to just under `UInt64.max`
— i.e. "almost forever" instead of "already past". Branch on the sign and subtract, saturating at
`DISPATCH_TIME_NOW`. Likewise, clamp the interval before converting: `Int64(seconds * NSEC_PER_SEC)`
traps on `.nan`/`.infinity`, and `nanoseconds * denom` can overflow before the division for
intervals beyond ~97 years on a 125/3 timebase.

**Corollary:** a simulator-only test suite cannot validate any API whose correctness depends on the
mach timebase — its timebase is 1:1, so the tick conversion is an identity there. Tests that only
exercise `DISPATCH_TIME_NOW` prove nothing about the other branches. Cover the sign, sentinel and
saturation behaviour explicitly (`TestFunctions.testDispatchTimeAfterTimeInterval*`), and still
reason about the tick/nanosecond units at review time rather than relying on CI.

### Gap S2.1-D — UIInterfaceOrientationIsPortrait() unavailable in Swift

Replace with `orientation.isPortrait` (Swift property on `UIInterfaceOrientation`).

### Gap S2.1-E — @objc(selector:) on throws methods must include :error: label

For `@objc(name:)` on a Swift `throws` method, the explicit name must include the `:error:` label or the compiler emits "provides N argument names, but method has N+1 parameters (including the error parameter)". Use `@objc(dictionaryFromJSONString:error:)` not `@objc(dictionaryFromJSONString:)`.

### Gap S2.1-F — CALayer @dynamic → @NSManaged in Swift

`@dynamic value;` in ObjC CALayer subclasses maps to `@NSManaged var value: CGFloat` in Swift.

### Gap S2.1-G — ObjC protocol migration: reduce header to forward declaration

When porting an `@objc protocol` to Swift, change the ObjC private header to just `@protocol PBMFoo;` (forward declaration). The full definition comes from `PrebidMobile-Swift.h` via `SwiftImport.h`. Any ObjC `.m` file that calls methods on `id<PBMFoo>` needs `#import "SwiftImport.h"`.

## Phase 2 gaps (discovered S2.2)

### Gap S2.2-A — @objc extensions on Foundation types bridge to ObjC via PrebidMobile-Swift.h

`@objc extension NSDictionary`, `@objc extension NSString`, etc. with `@objc public func` methods appear in `PrebidMobile-Swift.h` as ObjC categories. ObjC consumers that import `SwiftImport.h` can call these methods without any additional header imports after the original `.h` is deleted.

**Rule:** When porting ObjC categories on Foundation types (`NSDictionary`, `NSString`, `NSURL`, etc.), create a Swift `extension SomeClass` with `@objc public` methods. Remove the ObjC header import from all consumers; they get the methods automatically via `PrebidMobile-Swift.h`.

### Gap S2.2-B — NSString nil-param bridging: use String? to preserve nil guards

ObjC `nil` passed to a `nonnull NSString *` parameter bridges to Swift `String` as `""` (empty string), not `nil`. If the original ObjC code had a nil guard (`if (!param) { return self; }`), the Swift equivalent must use `String?` parameters so the nil passes through correctly.

**Rule:** For methods that had ObjC nil guards on string parameters, declare those parameters as `String?` in Swift (even if the ObjC header said `nonnull`). This is a backwards-compatible relaxation (`_Nullable` vs `_Nonnull` in the ObjC bridge).

### Gap S2.2-C — SPI protocol conformers must inherit @_spi

A Swift class that conforms to an `@_spi(PBMInternal)` protocol (e.g. `ViewExposure`) must itself be declared `@_spi(PBMInternal)`. Otherwise the compiler emits "cannot use protocol 'Foo' here; it is SPI".

**Rule:** When implementing a `@_spi` protocol, add `@_spi(PBMInternal)` to the conforming class/struct declaration. Similarly, properties/methods that return a `@_spi` type must themselves be marked `@_spi`.

### Gap S2.2-D — Swift name vs ObjC name for Factory and other @_spi classes

`Factory` (Swift name) is `PBMFactory` (ObjC bridge name via `@objc(PBMFactory)`). When writing Swift code that calls methods on the class, always use the Swift name `Factory`, never `PBMFactory`. Applies to all `@_spi` classes that have `@objc(PBMFoo)` bridge names.

### Gap S2.2-E — logViewHierarchy naming: @objc(LogViewHierarchy) with lowercase Swift name

ObjC method `- (void)LogViewHierarchy` (capital L) imports to Swift test code as `logViewHierarchy()` (lowercase). Swift callers use the lowercase name. Fix: name the Swift method `logViewHierarchy()` and add `@objc(LogViewHierarchy)` to preserve the ObjC selector for ObjC consumers.

**Rule:** When an ObjC method name starts with a capital letter, Swift automatically lowercases the first letter when importing. If both ObjC and Swift callers exist, name the Swift method in lowercase and use the explicit `@objc(UppercaseName)` annotation to maintain the ObjC selector.

### Gap S2.2-F — DEBUG-only ObjC category properties: KVC in Swift

`Prebid.forcedIsViewable` is defined in a private `#ifdef DEBUG` ObjC category (`Prebid+TestExtension.h`). Since private headers are not visible to Swift (Gap 8), access it via KVC: `Prebid.shared.value(forKey: "forcedIsViewable") as? Bool ?? false`. Only safe inside `#if DEBUG` blocks.

## Phase 2 gaps (discovered S2.3)

### Gap S2.3-A — NSInvocationOperation not available in Swift

`NSInvocationOperation` is an ObjC-only class. Replace with `NSObject.perform(_:with:)` for synchronous target/selector invocation:

```swift
// ObjC: NSInvocationOperation(target: obj, selector: sel, object: arg).start()
// Swift:
if target.responds(to: selector) {
    target.perform(selector, with: argument)
}
```

### Gap S2.3-B — ObjC block typedef cannot be exported from Swift as a named type

ObjC `typedef id<Foo>(^PBMBar)(NSTimeInterval, id, SEL, id?, BOOL)` cannot be reproduced in Swift as a named ObjC-visible type. Options:
1. Keep the typedef `.h` file (no `.m` to delete — it's header-only). ObjC consumers continue importing it.
2. The Swift closure `(TimeInterval, AnyObject, Selector, Any?, Bool) -> ProtocolType` generates an ObjC block type with the same signature. ObjC assignment is compatible without explicit casts (block types are structurally typed).

**Rule:** For header-only ObjC typedef files (`.h` with no corresponding `.m`), there is nothing to "port" — keep them in place. The Swift implementation uses a matching closure type; structural compatibility with the ObjC typedef is sufficient.

### Gap S2.3-C — Header chain: reducing one header breaks its importers

When `PBMTimerInterface.h` was reduced to a forward declaration `@protocol PBMTimerInterface;` (removing `@import Foundation;`), `PBMScheduledTimerFactory.h` lost Foundation types it was getting transitively. Fix: add `#import <Foundation/Foundation.h>` directly to any header that loses types via a reduced dependency.

**Rule:** After reducing a private header to a forward declaration, check every header that `#import`s it for Foundation-type usage (`NSTimeInterval`, `BOOL`, `NS_ASSUME_NONNULL_BEGIN`, etc.) and add `#import <Foundation/Foundation.h>` or `@import Foundation;` as needed.

### Gap S2.4-A — Rebasing a migration commit onto an upstream commit that deletes the ported class

When rebasing a migration branch onto `master` and the *ported* ObjC class was independently
deleted upstream (its whole feature replaced, not just tweaked), the migration's Swift port
becomes dead code even if the rebase auto-merges cleanly — a clean auto-merge only means git found
no *overlapping lines*, not that the port is still wanted. This happened with
`PBMTouchDownRecognizer`: `master` deleted it in favor of `UITapGestureRecognizer` in the same
commit range being rebased onto, and the deletion touched different lines than the migration's
port, so `PBMWebView.m`/`PBMVideoView.m` auto-merged onto master's replacement while
`TouchDownRecognizer.swift` and its test sailed through unchanged.

**Rule:** After any rebase of a migration branch onto `master`, diff the upstream commits being
rebased onto against the set of classes ported in this phase. For any ObjC class deleted upstream
(not just modified), delete the corresponding Swift port and its test rather than reconciling —
check first whether any production code (post-rebase) still references it.

### Gap S2.4-B — Post-migration upstream commits can reintroduce ObjC-name references in tests

A test file can be modified by an upstream commit *after* a class was already migrated to Swift,
adding a fresh reference to the old ObjC name (the author copy-pasted from an older test or wasn't
aware of the port). This isn't caught by the migration's own history — grep the full test suite
for stale ObjC-prefixed names after every rebase, not just the files touched by rebase conflicts.

**Rule:** After rebasing onto `master`, run the build once; any `'PBMFoo' has been renamed to 'Foo'`
compiler error names the file. Then grep proactively: build the list of `@objc(PBMFoo)` names from
every Swift file this phase ported, and search all `*.swift` files for each name outside its own
declaration line — this catches other stale references the build hasn't reached yet.

## Phase 2 gaps (discovered in review, S2.5)

### Gap S2.5-A — deleting an ObjC header can break the SPM build only

When a migrated ObjC header is deleted, every `.m` that was getting UIKit *transitively* through it
loses those types. Under CocoaPods/Xcode this is masked: the generated `PrebidMobile-Swift.h`
(pulled in via `SwiftImport.h`) re-exports the umbrella headers, so `UIView` / `UIScreen` stay
visible. Under SwiftPM the Swift half is consumed as `@import PrebidMobile;`, which does not
re-export UIKit, and the same file fails with:

> error: declaration of 'UIScreen' must be imported from module 'UIKit.UIScreen' before it is required

Neither `buildPrebidMobile.sh` (CocoaPods) nor `buildPrebidSPM.sh` catches this —
`buildPrebidSPM.sh` builds `PrebidDemoSPM`, which consumes the *published* package via
`XCRemoteSwiftPackageReference` and never compiles the working tree.

**Rule:** Any ObjC `.m` that references UIKit types must `#import <UIKit/UIKit.h>` explicitly; never
rely on transitive visibility. Verify with `./scripts/buildPrebidMobilePackage.sh`, which compiles
`Package.swift` directly for the iOS simulator triple and is wired into `PR_checks.yml` as the
`build-spm-package` job.

### Gap S2.5-B — ObjC blocks capture `self` strongly; do not add `[weak self]` reflexively

An ObjC block with no `@weakify`/`__weak` dance captures `self` strongly, and that capture is
sometimes the *only* thing keeping the object alive. Translating it to `{ [weak self] … }` is not a
neutral safety improvement — it changes object lifetime and can silently turn the callback into a
no-op.

`PBMDownloadDataHelper.downloadDataForURL:maxSize:` is the concrete case: callers such as
`PBMCreativeFactoryJob` create the helper as a bare local and return immediately, so a weak capture
lets it deallocate between the HEAD and the GET, and the completion closure never fires. Unit tests
do not catch it because they hold the helper in a scope that spans `waitForExpectations`.

**Rule:** Port block capture semantics literally. Only introduce `[weak self]` where the ObjC
original used `__weak`/`@weakify`, or where a retain cycle is demonstrable (`self` owns the object
holding the block). When keeping a strong capture, leave a comment saying why, so the next reader
does not "fix" it.

### Gap S2.5-C — `initWithJsonDictionary:` destroys `init` defaults; `?? default` resurrects them

Every ORTB model's JSON initializer is written as:

```objc
- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) { return nil; }   // seeds class defaults
    _bidfloor = jsonDictionary[@"bidfloor"];     // direct ivar write, no setter
    ...
}
```

The ivar writes are **unconditional** and bypass the (sometimes coercing) setters. So when a key is
absent, the default seeded by `init` is *overwritten with nil* — and `pbmCopyWithoutEmptyVals` then
omits the key on re-encode. Decoding `{"id":"deal-1"}` and re-encoding it yields `{"id":"deal-1"}`,
not the four extra defaults.

The natural-looking Swift port is wrong:

```swift
// WRONG — invents wire keys the ObjC SDK never sent
bidfloor = json[.bidfloor] ?? 0.0
```

**Rule:** In `init(jsonDictionary:)`, assign unconditionally — `x = json[.k]`, never
`json[.k] ?? default`. Keep the default in the property declaration so the plain `init()` path still
matches ObjC. This forces the property to be **optional even when the ObjC header declared it
nonnull** under `NS_ASSUME_NONNULL_BEGIN`; the header was lying, and the JSON initializer is the
proof. Same rule for collection properties: `ORTBBidRequest.imp` defaults to one `ORTBImp()` in
`init()` but must be cleared to `[]` when `"imp"` is absent or empty.

Two exceptions where `?? default` **is** faithful and should be kept:

- The ObjC init explicitly substituted a value for a missing key
  (`_deals = jsonDictionary[@"deals"] ? … : @[]`) — `ORTBPmp.deals`, `ORTBBanner.format`.
- The property is never written by `toJsonDictionary` (`ORTBPublisher.cat`, `ORTBApp.cat` /
  `sectioncat` / `pagecat`) or is guarded by a non-empty check (`ORTBImpExtSkadn.skadnetids`), so no
  wire difference is observable. Child-object fallbacks (`json[.pmp] ?? ORTBPmp()`) are likewise
  fine: ObjC allocated the child too, and empty child dicts are suppressed on encode (Gap 2).

**Verification:** a fully-populated round-trip fixture cannot detect this — the resurrected default
is stable across both encodes. Cover it with a *partial* payload and assert on the re-encoded key
set (`assertORTBNoResurrectedDefaults` in `ORTBParityHelper.swift`).

### Gap S2.5-D — `[nil isEqual:nil]` is `NO`; Swift `nil == nil` is `true`

ObjC `isEqual:` implementations written as `[self.w isEqual:other.w] && [self.h isEqual:other.h]`
return `NO` when both sides are nil, because messaging `nil` returns `NO`. The direct Swift
translation `w == other.w && h == other.h` returns `true`. For a type used as an `NSSet` member
this changes deduplication: all-nil instances used to be distinct and now collapse into one.

`ORTBFormat` is the instance. The divergence was **accepted, not fixed**: the only dedup callsite
(`PBMPrebidParameterBuilder`) builds every element via `+ortbFormatWithSize:`, which always sets `w`
and `h`, so all-nil formats never reach the `NSSet`. Reproducing ObjC exactly would need
`w != nil && h != nil && …`, which makes `isEqual:` non-reflexive and violates the contract
`NSSet`/`Hashable` rely on.

**Rule:** When porting an `isEqual:` built from `isEqual:` calls on optional properties, decide
explicitly whether all-nil instances must stay distinct. If the ObjC semantics can't be reproduced
without breaking reflexivity, keep the Swift semantics and leave a comment at the callsite
justifying it — don't leave the difference silent.

### Gap S2.5-E — `UIApplication.shared` is non-optional in Swift but nil host-less

`[UIApplication sharedApplication]` returns `nil` whenever the SDK runs outside an application
process — most importantly the unit-test bundle, which has no app host. ObjC code guarded this with
`if (!uiApplication)` / `conformsToProtocol:`. Swift imports the property as **non-optional**
`UIApplication`, so the `nil` becomes an invalid reference that cannot be tested for and crashes at
first use — typically when boxed into a `PBMUIApplicationProtocol` existential.

**Rule:** Never read `UIApplication.shared` directly in ported code. Resolve it through the ObjC
runtime so the `nil` stays observable:

```swift
static var sharedApplication: UIApplication? {
    let selector = NSSelectorFromString("sharedApplication")
    guard let applicationClass = UIApplication.self as AnyObject as? NSObjectProtocol,
          applicationClass.responds(to: selector),
          let application = applicationClass.perform(selector)?.takeUnretainedValue()
    else { return nil }
    return application as? UIApplication
}

/// The application every call site must read.
static var resolvedApplication: PBMUIApplicationProtocol? {
    Functions.application ?? sharedApplication
}
```

Three follow-on rules:

- **Honour the injection seam, in one place.** `Functions.application`
  (`Functions+Testing.swift`) is how tests substitute a mock, so it must be consulted first —
  reading `sharedApplication` alone silently ignores the mock and resolves the real singleton.
  Express that precedence once, in `resolvedApplication`; a second accessor spelling out the
  same `??` chain is a place for the two to drift apart.
- **Route every application-derived read through the protocol.** A value the SDK reads off the
  application — including `safeAreaInsets`, which needs the key window — belongs on
  `PBMUIApplicationProtocol` so it resolves through the same seam. `safeAreaInsets` reaching
  around it to `UIApplication.shared.…` reintroduces both the host-less trap and the untestable
  path the rule exists to prevent. Where a caller needs more than one such value (`deviceMaxSize`
  needs insets *and* the status-bar height), resolve the application once and pass it down rather
  than repeating the runtime lookup per accessor.
- **Do not memoize.** The resolution is `nil` until `UIApplicationMain` has run, so a cached `nil`
  can outlive the condition that produced it. The runtime lookup is a selector resolution plus one
  `objc_msgSend` — not worth trading for a staleness hazard and mutable global state.

**Scope:** applied in `Functions.swift` (`attemptToOpen`, `statusBarHeight`, `safeAreaInsets`), which
no longer reads `UIApplication.shared` in code. **10 other Swift files still do, across 17 call
sites**: `LocationManager.swift` (4), `UIApplication+Extensions.swift` (2),
`AdViewButtonDecorator.swift` (2), then one each in `UIWindow+PBMExtensions.swift`,
`UIWindow+Extensions.swift`, `ViewExposureChecker.swift`, `ModalViewController.swift`,
`AutoRefreshManager.swift`, `Host.swift`, `NativeAd.swift`. All predate this PR and are tracked as
follow-up — apply this rule when touching them.

To re-measure, grep the SDK sources and discount comment lines — a raw count is high, because
`Functions.swift` names the API twice in prose while reading it nowhere:

```bash
grep -rn --include='*.swift' -F 'UIApplication.shared' PrebidMobile
```

The counts above are a snapshot, not an enforced budget: nothing in CI gates them. SwiftLint
`custom_rules` would be the natural home for a ban, but SwiftLint runs in no CI workflow
(`scripts/swiftLint.sh` still pins 0.31.0 and is invoked by nobody), so such a rule would be
invisible today. Enforcement is worth revisiting once SwiftLint is actually wired into a workflow.

## Phase 3 gaps (discovered S3.1/S3.2)

### Gap S3.1-A — ObjC `dict[key] = nil` removes the key; the Swift subscript boxes `Optional.none`

`PBMBasicParameterBuilder.m` and `PBMUserConsentParameterBuilder.m` write nullable values straight
into an `NSMutableDictionary`:

```objc
bidRequest.regs.ext[@"gdpr"] = self.targeting.getSubjectToGDPR;   // nil ⇒ key removed
```

The literal Swift translation `dict["gdpr"] = value` where `value` is `T?` **stores a boxed
`Optional.none`**, which serializes as a present key. The bug is silent: the type checker is happy
and only a wire-format diff catches it.

**Rule:** Never assign an optional through the `NSMutableDictionary` subscript. Use the helper added
in `NSMutableDictionary+PBMExtensions.swift`:

```swift
func pbmSetValue(_ value: Any?, forKey key: String) {
    if let value = value { self[key] = value } else { removeObject(forKey: key) }
}
```

### Gap S3.1-B — a protocol that Swift test mocks conform to cannot be `@objc`

`PBMBundleProtocol` exists so `PBMParameterBuilderService` can be handed a `MockBundle` in tests.
Porting it as `@objc protocol BundleProtocol` compiles, but `MockBundle` is a plain Swift class, and
an `@objc` protocol drags `@objc` requirements onto every conformer — including the retroactive
`extension Bundle`, where `infoDictionary` and `bundleIdentifier` already exist with non-`@objc`
Swift signatures.

**Rule:** Injection-seam protocols consumed only by Swift are declared plain
`protocol Foo: AnyObject`, with the real type conformed retroactively:

```swift
protocol BundleProtocol: AnyObject {
    var infoDictionary: [String: Any]? { get }
    var bundleIdentifier: String? { get }
}

extension Bundle: BundleProtocol {}
```

The knock-on is Gap S3.1-D: any method whose signature mentions such a protocol is not
ObjC-representable.

### Gap S3.1-C — `Foo+pbmTestExtension.h` class extensions cannot re-open a Swift class

`PBMBasicParameterBuilder+pbmTestExtension.h` re-declared the builder's four `readonly` properties
as `readwrite` so tests could nil them out. An ObjC class extension can only re-open an ObjC
`@implementation`; there is no equivalent for a Swift class, and Swift extensions cannot add stored
properties or change a property's access.

**Rule:** Delete the test-extension header and declare the properties directly on the Swift twin
with the access the tests need — here, four optional `var`s plus the original `Log.error("Invalid
properties")` guard, which three tests assert on. Mark the resulting looseness with a `TODO` rather
than tightening it silently: dropping the optionality also deletes the tests that cover the guard.

### Gap S3.1-D — `@objcMembers` fails if any member signature contains a non-ObjC type

`ParameterBuilderService` has an internal overload taking a `BundleProtocol` (Gap S3.1-B).
`@objcMembers` tries to expose every member and fails to compile on that one.

**Rule:** Do not reach for `@objcMembers` on a class with a mixed surface. Annotate only the members
ObjC actually calls, with the original selector spelled out:

```swift
@objc(buildParamsDictWithAdConfiguration:extraParameterBuilders:)
public static func buildParamsDict(with:extraParameterBuilders:) -> [String: String]
```

### Gap S3.1-E — a Swift test subclass of a now-internal Swift SDK class breaks `<TestModule>-Swift.h`

```
PrebidMobileTests-Swift.h:1605: cannot find interface declaration for
'SKAdNetworksParameterBuilder', superclass of 'MockSKAdNetworksParameterBuilder'
```

Swift emits every `internal`-or-wider `NSObject`-derived class in the **test** module into
`PrebidMobileTests-Swift.h`, including its `@interface … : Superclass` line. When the superclass is
an `internal`, non-`@objc` Swift class in `PrebidMobile`, no ObjC declaration for it exists and the
generated header does not compile. The error surfaces at the *end* of the test build and looks like
a stale-header artefact — it is not, and it will not clear on a clean build.

**Rule:** Mark test-only subclasses of SDK Swift classes `fileprivate` (or `private`). File-scoped
types are excluded from the generated header. Making the SDK class `@objc public` also works but
widens the shipped surface for a test's benefit — prefer `fileprivate`.

### Gap S3.1-F — an ObjC class conforming to a Swift `@objc protocol` does not inherit the Swift method name

`PBMParameterBuilder` became a Swift protocol declaring
`@objc(buildBidRequest:) func build(_ bidRequest: ORTBBidRequest)`. `PBMPrebidParameterBuilder` (an
ObjC class not yet ported) declares `<PBMParameterBuilder>` and implements `buildBidRequest:` — the
ObjC side is satisfied, but Swift callers see only `buildBidRequest(_:)`. The `build(_:)` spelling
comes from the Swift declaration, and conformance does not propagate it back into the imported ObjC
interface. Swift test code calling `builder.build(bidRequest)` fails with "has no member 'build'".

**Rule:** When a Swift protocol replaces an ObjC one, re-declare the method in each surviving ObjC
conformer's header with the matching `NS_SWIFT_NAME`:

```objc
- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest NS_SWIFT_NAME(build(_:));
```

### Gap S3.1-G — `ATTrackingManager.AuthorizationStatus.rawValue` is `UInt`

`PBMDeviceInfoParameterBuilder.m` compared the `atts` `NSNumber` against
`ATTrackingManagerAuthorizationStatusAuthorized` with `==`. In Swift the enum's `RawValue` is
`UInt`, so `atts.intValue == ...rawValue` does not type-check and `Int(...rawValue)` is a needless
conversion.

**Rule:** Compare through `NSNumber.uintValue`:
`atts.uintValue == ATTrackingManager.AuthorizationStatus.authorized.rawValue`.

### Gap S3.2-A — Gap 4 / Gap 6 do not apply to the Phase 3 builders themselves

The parameter builders have **no** surviving ObjC consumers: `PBMParameterBuilderService.m` was
their only non-test caller and is ported in the same PR. Only two Phase 3 types cross the ObjC seam
and therefore need `@objc public` — `ParameterBuilder` (implemented by the still-ObjC
`PBMPrebidParameterBuilder`) and `ParameterBuilderService` (called by `PBMBidRequester.m`). The
eight builders are plain `internal` Swift classes.

**Rule:** Apply Gap 4 / Gap 6 per type, based on a measured importer check — not per phase.

## Orphan headers — the `.h` files with no `.m` (inventoried S3.2)

The per-class recipe at the top of this playbook assumes a `Foo.h` + `Foo.m` pair. **39 headers
under `PrebidMobile/Objc/` have no matching `.m`**: block typedefs, `@protocol` declarations, macro
headers, `+Protected` / `+Internal` / `+Private` class-continuation headers, `NS_ENUM`s, umbrella
headers, and categories on system classes. None of them is *ported*; each is **retired when its
last importer is ported**, and without this inventory they are invisible to the phase plan.
Grouped below as 2 dead + 28 tied to a named `.m` + 5 tied to the test bridging header +
4 shared-infrastructure = 39.

Re-measure at any time:

```bash
comm -23 \
  <(find PrebidMobile/Objc -name '*.h' | sed 's|.*/||; s|\.h$||' | sort -u) \
  <(find PrebidMobile/Objc -name '*.m' | sed 's|.*/||; s|\.m$||' | sort -u)
```

### A — already dead (zero `#import`s anywhere)

| Header | Kind | Note |
|--------|------|------|
| `PBMAdLoadFlowController.h` | `@interface` | Swift twin `AdLoadFlowController.swift` already ships; the header was left behind |
| `PBMORTB_NotImplemented.h` | macros | referenced only by a stale `.pbxproj` entry |

Deletable at any time; not deleted in the Phase 3 PR only to keep that diff scoped.

### B — retired with a named `.m`

Measured at S3.2. A header imported only by another header is resolved down the chain to the `.m`
at its root; for the deeper block-typedef chains the list names the roots reached, so re-run the
grep (`grep -rl '"Foo.h"' PrebidMobile PrebidMobileTests`) before acting on a row.

| Header | Kind | Retired with |
|--------|------|--------------|
| `PBMAbstractCreative+Protected.h` | class continuation | `PBMAbstractCreative.m`, `PBMHTMLCreative.m`, `PBMVideoCreative.m` |
| `PBMAdLoadManagerDelegate.h` | `@protocol` | `PBMAdLoadManagerBase.m`, `PBMAdViewManager.m` |
| `PBMAdLoadManagerProtocol.h` | `@protocol` | `PBMAdLoadManagerBase.m`, `PBMAdViewManager.m` |
| `PBMAdMarkupStringHandler.h` | block typedef | via `PBMWinNotifierBlock.h` → `PBMWinNotifier.m`, `PBMPrebidParameterBuilder.m` |
| `PBMBidRequesterFactoryBlock.h` | block typedef | `PBMBidRequesterFactory.m`, `PBMPrebidParameterBuilder.m` |
| `PBMCreativeModelMakerResult.h` | block typedef | `PBMCreativeModelCollectionMakerVAST.m` |
| `PBMDeepLinkPlusHelper+PBMExternalLinkHandler.h` | class continuation | `PBMDeepLinkPlusHelper.m` |
| `PBMExposureChangeDelegate.h` | `@protocol` | `PBMWebView.m`, `PBMMRAIDController.m` |
| `PBMExternalURLOpenerBlock.h` | block typedef | `PBMExternalURLOpeners.m`, `PBMExternalLinkHandler.m`, `PBMDeepLinkPlusHelper.m` |
| `PBMORTB.h` | umbrella | `PBMPrebidParameterBuilder.m`, `PBMWebView.m` |
| `PBMORTBAbstract.h` | `@interface` | via `PBMORTBAbstract+Protected.h` → `PBMBidResponseTransformer.m` |
| `PBMORTBAbstract+Protected.h` | class continuation | `PBMBidResponseTransformer.m` |
| `PBMScheduledTimerFactory.h` | block typedef | `PBMCreativeViewabilityTracker.m` |
| `PBMTimerInterface.h` | forward decl | via `PBMScheduledTimerFactory.h` → `PBMCreativeViewabilityTracker.m` |
| `PBMTrackingURLVisitorBlock.h` | block typedef | `PBMTrackingURLVisitors.m`, `PBMExternalLinkHandler.m` |
| `PBMTransactionFactoryCallback.h` | block typedef | `PBMDisplayTransactionFactory.m`, `PBMVastTransactionFactory.m` |
| `PBMUIApplicationProtocol.h` | forward decl | `PBMExternalURLOpeners.m`, `PBMDeepLinkPlusHelper+Testing.m`, `PBMHTMLCreative+pbmTestExtension.h` (Gap S2.5-E's seam type) |
| `PBMURLOpenAttempterBlock.h` | block typedef | `PBMDeepLinkPlusHelper.m`, `PBMExternalLinkHandler.m` |
| `PBMURLOpenResultHandlerBlock.h` | block typedef | `PBMExternalURLOpenCallbacks.m`, `PBMExternalURLOpeners.m` |
| `PBMVastResourceContainerProtocol.h` | `@protocol` | `PBMVastParser.m`, `PBMVastIcon.m`, `PBMVastCreativeNonLinearAdsNonLinear.m`, `PBMVastCreativeCompanionAdsCompanion.m` |
| `PBMVideoViewDelegate.h` | `@protocol` | `PBMVideoView.m`, `PBMVideoCreative.m` |
| `PBMVideoViewPlaybackState.h` | `NS_ENUM` | `PBMVideoView.m` |
| `PBMViewControllerProvider.h` | block typedef | `PBMSafariVCOpener.m` |
| `PBMVoidBlock.h` | block typedef | `PBMOpenMeasurementWrapper.m`, `PBMSafariVCOpener.m`, `PBMDeferredModalState.m`, `PBMExternalURLOpenCallbacks.m`, `PBMAbstractCreative.m` |
| `PBMWebView+Internal.h` | class continuation | `PBMWebView.m` |
| `PBMWebViewDelegate.h` | `@protocol` | `PBMWebView.m`, `PBMMRAIDController.m` |
| `PBMWinNotifierBlock.h` | block typedef | `PBMWinNotifier.m`, `PBMPrebidParameterBuilder.m` |
| `PBMWinNotifierFactoryBlock.h` | block typedef | `PBMWinNotifier.m` |

Reducing rather than deleting is sometimes the right move mid-phase — see Gap S2.1-G
(`@protocol` → forward declaration) and Gap S2.3-C (a reduced header breaks its importers).

### C — retired with the test bridging header

Imported by `PrebidMobileTest-Bridging-Header.h` and nothing else in the SDK. They go when the
corresponding Swift test files stop needing the ObjC symbol.

| Header | Kind |
|--------|------|
| `PBMVastParser+Private.h` | class continuation |
| `WKNavigationAction+PBMWKNavigationActionCompatible.h` | category on a system class |
| `WKWebView+PBMWKWebViewCompatible.h` | category on a system class |
| `PBMWKNavigationActionCompatible.h` | `@protocol` (imported only by the category above) |
| `PBMWKWebViewCompatible.h` | `@protocol` (imported only by the category above) |

The two `WK*Compatible` protocols look like SDK types but are not: no SDK `.m` names them. They
exist purely so Swift tests can substitute a fake navigation action / web view.

### D — shared infrastructure, last to go

Imported by most of the remaining ObjC tree; they can only be deleted once the tree is empty, in
S9.x. Do **not** attempt to port them incrementally.

| Header | Kind | Direct importers (S3.2) |
|--------|------|-------------------------|
| `SwiftImport.h` | umbrella (`PrebidMobile-Swift.h` shim) | 66 |
| `PBMMacros.h` | macros (`PBMAssert`, `weakify`) | 27 |
| `Log+Extensions.h` | macros (`PBMLogError` family) | 24 |
| `PBMConstants.h` | typedefs + constants (`PBMJsonDictionary`) | 15 |

`PBMConstants.h` is the one with a real Swift answer available today: every `PBMJsonDictionary` use
becomes `[String: Any]` as its importer is ported (per-class step 7), so the header shrinks to its
constants before it disappears.

## General ObjC → Swift reference

Not phase-specific. Adapted from the generic guides in `agents/migration-patterns/`. Those
guides conflict with this playbook on four significant points — read
`agents/migration-patterns/SKILL.md` before consulting them directly.

### `NSNull` from `JSONSerialization` is not `nil`

`JSONSerialization` decodes a JSON `null` to `NSNull`, not to an absent key. **Typed reads are
inherently safe**: `NSNull as? String`, `as? NSNumber`, and `as? [String: Any]` all yield `nil`, so
every typed `JSONObject` subscript and every `case let value as …` pattern match in
`JSONParsing.swift` already rejects it. `numberOrString` (`JSONParsing.swift:111`) and
`backwardsCompatiblePassthrough` (`:116`) are both safe for this reason.

The hazard is confined to **untyped existence checks**. One instance exists:

```swift
// ORTBImpExtPrebid.swift:37
isRewardedInventory = jsonDictionary["is_rewarded_inventory"] != nil
```

Given `"is_rewarded_inventory": null` this yields `true`. The ObjC original used the same `!= nil`
test, so wire-format parity is preserved and this is **not** a migration regression — but do not
introduce further instances.

**Rule:** Never test presence with `jsonDictionary[key] != nil` or a bare
`if let value = jsonDictionary[key]`. Read through a type (`as? NSNumber`, `as? String`), or guard
explicitly the way `NSMutableDictionary+PBMExtensions.swift:40` does: `value == nil || value is NSNull`.

### ObjC ↔ Swift concept mapping

Quick reference for porting. Rows marked ⚠ are where the generic source is wrong for this repo.

| Objective-C | Swift | Notes |
|-------------|-------|-------|
| `@interface` / `@implementation` | `class` | ⚠ **Not `struct`** for Phase 1–3 twins — ObjC parameter builders consume them (Gap 4) |
| `@property (nonatomic, strong)` | `var` | `let` for readonly equivalents |
| `@property (nonatomic, copy)` | `var` | ⚠ If the ObjC type conformed to `<NSCopying>`, the Swift twin must implement it explicitly or `.copy()` crashes (see S1.4) |
| `@property (nonatomic, readonly)` | `let` or `private(set) var` | Note `JSONObject.dict` is `private(set)` — see Gap 10 |
| `NSString` | `String` | ⚠ Use `String?` where the ObjC param was nullable, to preserve nil guards (Gap S2.2-B) |
| `NSArray` / `NSDictionary` | `[Element]` / `[Key: Value]` | ⚠ `NSMutableDictionary` properties must be decoded as `NSMutableDictionary(dictionary:)`, not `as?` (S1.4) |
| `NSNumber` | `NSNumber` for ORTB fields | Keep `NSNumber` where the ORTB model needs optional numerics and JSON-key parity |
| `NSError **` | `throws` | ⚠ `@objc` name must include the label: `@objc(name:error:)` (Gap S2.1-E) |
| Block (`^`) | Closure | ⚠ A block *typedef* cannot be exported from Swift as a named type (Gap S2.3-B) |
| `id` | `Any` | Prefer specific types |
| `NS_ENUM` | `enum: Int` | ⚠ `NS_TYPED_ENUM` string constants cannot be bridged — keep a residual ObjC `.m` (Gap S2.1-A) |
| `NS_OPTIONS` | `OptionSet` | Struct-based |
| `dispatch_queue_t` + GCD | `DispatchQueue` | ⚠ **Not** `async`/`await` — iOS 13 floor. `dispatch_time()` needs explicit mach-tick handling — **never** `DispatchTime(uptimeNanoseconds:)` on a `dispatch_time_t` (Gap S2.1-C) |
| Category | Extension | ⚠ `@objc` extensions on Foundation types bridge via `PrebidMobile-Swift.h` (Gap S2.2-A) |
| `@protocol` | `protocol` | ⚠ Reduce the ObjC header to a forward declaration (Gap S2.1-G) |
| `#pragma mark -` | `// MARK: -` | |
| `@selector` | `#selector` | Compile-time checked |
| `@try` / `@catch` | `do` / `try` / `catch` | Swift cannot catch ObjC exceptions |
| `instancetype` | `Self` | |
| `nullable` / `nonnull` | `Optional` / non-optional | |
| `@dynamic` (CALayer) | `@NSManaged` | Gap S2.1-F |

### `NS_SWIFT_NAME` / `NS_REFINED_FOR_SWIFT` on surviving ObjC APIs

The reverse of `@objc(PBMFoo)`: these improve how *remaining* ObjC declarations appear to Swift,
which still matters while ObjC parameter builders survive into Phase 3/4.

```objc
// Rename for Swift without touching the ObjC interface
- (void)fetchRecordsOfType:(PBMRecordType)type NS_SWIFT_NAME(fetchRecords(ofType:));

// Hide the ObjC form (exposed as __countForType:) and wrap it in a Swift extension
- (NSInteger)countForType:(NSString *)type NS_REFINED_FOR_SWIFT;
```

Use sparingly — a rename that is not obvious from the ObjC selector makes the two layers harder to
cross-reference during review.
