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
After Phase 3 all ObjC consumers are gone; revisit in S9.x cleanup whether to drop `NSObject` and convert to plain classes or structs.

### Gap 5 — `initWithJsonDictionary:` broken-instance fallback vs. `init?`

`PBMORTBAbstract.initWithJsonDictionary:` logs an error and returns `[PBMORTBAbstract new]` (a broken abstract instance). The Swift `init?(jsonDictionary:)` protocol requirement returns `nil` on failure — semantically correct.

**Rule:** No change to `PBMJsonCoding.swift` needed. During S1.1, audit test code for any test that depended on the broken-instance behavior and update to expect `nil`.

### Gap 6 — Framework build visibility: `public` required (discovered S1.1)

In a framework archive build, Swift types with `internal` access only appear as `@class` forward stubs in `PrebidMobile-Swift.h`. ObjC consumers in the same target get "receiver type is a forward declaration" errors when trying to alloc/init or call methods.

**Rule:** All Phase 1–3 Swift twins must be `@objc public class` with `@objc public var` properties. After Phase 3 when all ObjC consumers are gone, demote to `internal` in S9.2.

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

## Known flaky test — do not over-investigate

`PBMBidRequesterTest.testBanner_300x250` fails intermittently with:
> Asynchronous wait failed: Exceeded timeout of 5 seconds, with unfulfilled expectations: "exp".

This is a **pre-existing timing flakiness** unrelated to the Swift migration. It was present before Phase 1 and has appeared on both the first and second post-migration runs. On a clean re-run of `./scripts/testPrebidMobile.sh --latest --quick` it passes.

**Rule:** If this is the only failing test after a migration step, re-run once. If it passes on the second run, proceed — do not investigate or modify the test. If it keeps failing across multiple full-suite runs **but passes when run in isolation** (`-only-testing PrebidMobileTests/PBMBidRequesterTest/testBanner_300x250`), that is still flakiness — move on. Only investigate if it fails in isolation too.

**Confirmed S1.3:** fails in 2 consecutive full-suite runs, passes immediately when run alone. Root cause is simulator resource pressure under full-suite load, not a regression.

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
- [ ] `./scripts/testPrebidMobile.sh --latest --quick` — must pass on a clean run (re-run once if only `PBMBidRequesterTest.testBanner_300x250` fails)
- [ ] Swift test files updated: no `'PBMORTBFoo' has been renamed` compiler errors
- [ ] (Phase 1 & 3) JSON round-trip parity test passes (see S0.2 harness)
- [ ] No `"app": {}` / `"device": {}` empty-object regressions in captured bid requests

## Phase 2 gaps (discovered S2.1)

### Gap S2.1-A — NS_TYPED_ENUM constants cannot be bridged as free-standing ObjC constants from Swift

`FOUNDATION_EXPORT NSString * const PBMFooAction = @"foo"` style global constants have no Swift equivalent that bridges to C-level symbols. Keep a residual ObjC `.m` file containing ONLY the constant assignments; port the class implementations to Swift separately. Delete the residual `.m` when the last ObjC consumer of those constants is ported.

### Gap S2.1-B — @_spi(PBMInternal) class requires @_spi import in test files

`Functions` (`PBMFunctions`) is declared `@_spi(PBMInternal) public class`. Any Swift test file that accesses `Functions.*` directly must use `@_spi(PBMInternal) @testable import PrebidMobile` instead of just `@testable import PrebidMobile`.

### Gap S2.1-C — dispatch_time() C function unavailable in Swift

Replace `dispatch_time(startTime, delta)` with `(DispatchTime(uptimeNanoseconds: startTime) + timeInterval).rawValue`. Use `.now()` when `startTime == DISPATCH_TIME_NOW (== 0)`.

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

## General ObjC → Swift reference

Not phase-specific. Adapted from the generic guides in `agents/ios/migration-patterns/`. Those
guides conflict with this playbook on four significant points — read
`agents/ios/migration-patterns/SKILL.md` before consulting them directly.

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
| `dispatch_queue_t` + GCD | `DispatchQueue` | ⚠ **Not** `async`/`await` — iOS 13 floor. `dispatch_time()` becomes `(DispatchTime(uptimeNanoseconds:) + interval).rawValue` (Gap S2.1-C) |
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
