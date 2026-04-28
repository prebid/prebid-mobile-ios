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
    let d = newValue?.jsonDictionary
    dict[key.rawValue] = (d?.isEmpty == true) ? nil : d
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

## Canonical Swift twin template

```swift
// PrebidMobile/Swift/PrebidMobileRendering/ORTB/Request/PBMORTBFoo.swift

import Foundation

@objc class PBMORTBFoo: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc var someField: NSNumber?
    @objc var anotherField: String?

    // MARK: - Init

    override init() {}

    required convenience init?(jsonDictionary: [String: Any]) {
        self.init()
        let json = JSONObject<Key>(jsonDictionary)
        someField   = json[.someField]
        anotherField = json[.anotherField]
    }

    // MARK: - PBMJsonEncodable

    var jsonDictionary: [String: Any] {
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
- `Key` enum uses `RawRepresentable` with `String` raw values matching JSON keys.
- `@objc` on properties ensures ObjC consumers can access them via `*-Swift.h`.
- No `toJsonStringWithError:` / `fromJsonString:` implementations — inherited.
- No `NSCopying`.
- For child ORTB objects, use `json[.childKey] = self.childObj` — empty-dict suppression is automatic.

## Validation checklist per PR

- [ ] `xcodebuild -workspace PrebidMobile.xcworkspace -scheme Lib-PrebidMobile -sdk iphonesimulator build`
- [ ] `./scripts/testPrebidMobile.sh --latest --quick`
- [ ] (Phase 1 & 3) JSON round-trip parity test passes (see S0.2 harness)
- [ ] No `"app": {}` / `"device": {}` empty-object regressions in captured bid requests
