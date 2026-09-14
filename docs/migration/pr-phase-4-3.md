# [swift-migration] Phase 4, steps S4.3 + S4.3b — `PBMPrebidParameterBuilder` + `PBMWinNotifier`

Branch on top of `master` (`2befc557`, lands S4.1). Second PR of Phase 4, step order:
S4.1 (landed) → **S4.3 + S4.3b (this)** → S4.4 → S4.2 → S4.5.

## Scope

| File | Non-test consumers |
|------|---------------------|
| `Prebid/PBMCore/PBMPrebidParameterBuilder.{h,m}` (38+324) | `PBMBidRequester.m` (`initWithAdConfiguration:sdkConfiguration:targeting:userAgentService:` + `buildBidRequest:`) |
| `PBMBidRequesterFactory.{h,m}` + `PrivateHeaders/PBMBidRequesterFactoryBlock.h` | **none** — dead code, folded in per Gap S4.1-B |
| `PBMWinNotifier.m` + `PBMWinNotifierBlock.h`, `PBMWinNotifierFactoryBlock.h`, `PBMAdMarkupStringHandler.h` | `Factory.swift` (`NSClassFromString("PBMWinNotifier_Objc")` only; Swift protocol already existed, unimplemented) |

`PBMBidRequesterFactory`: verified zero remaining callers repo-wide — deleted rather than ported.

## Summary

### `PrebidParameterBuilder.swift`

`@objc(PBMPrebidParameterBuilder) @_spi(PBMInternal) public class PrebidParameterBuilder: NSObject,
ParameterBuilder` — same visibility tier as S4.1. `ParameterBuilder` is `@objc(PBMParameterBuilder)`,
so `build(_:)` satisfies its `@objc(buildBidRequest:)` requirement via automatic witness inference
(Gap 7). The 4-param designated init satisfies no protocol requirement, so needed an **explicit**
`@objc` (Gap S4.3-A — a real build failure, not theoretical).

Line-for-line port of `build(_:)` (324-line ObjC, already complexity-heavy): `requestID`/
`storedRequestID`, GDPR consent, OMID source ext, ad-format banner/video/native fields per imp,
dedup'd `ORTBFormat` list (`Set`, Gap 3), interstitial min-size-percent, `appExtPrebid.source/.version`
defaults. Kept `// swiftlint:disable:next cyclomatic_complexity function_body_length` (see SwiftLint).

### `WinNotifierImpl.swift` (S4.3b)

`@objc(PBMWinNotifier_Objc) @_spi(PBMInternal) public class WinNotifierImpl: NSObject, WinNotifier`
— ObjC-visible name matches the string `Factory.swift` already resolves via `NSClassFromString`;
that's the only touchpoint, so **no** member-level `@objc` needed (contrast with
`PrebidParameterBuilder`, see Gap S4.3-A). `WinNotifier` protocol pre-existed, unimplemented.

Line-for-line port of `notifyThroughConnection(_:winningBid:callback:)`: chained win/uuid/cache-URL
`download` closures, falling back to `ORTBMacrosHelper` macro substitution with no inline markup,
plus `cacheUrl(fromTargeting:idKey:)` (`hb_cache_host`/`hb_cache_path`/`hb_uuid`/`hb_cache_id`) and
`adMarkupString(fromResponse:)` JSON `"adm"` extraction helpers.

### Deliberate divergences

Three sites tighten unchecked ObjC `id`→`NSString*` assignments to `as? String`/optional-binding;
behavior changes only on inputs that would've been a latent type-punning crash. No existing test
covers these paths.

| Site | Behaviour on malformed input |
|------|------|
| `PrebidParameterBuilder.swift:91` (`app.ver` ← `CFBundleShortVersionString`) | Non-string value → `app.ver == nil` instead of type-punned object |
| `WinNotifierImpl.swift:47-49` (`rawData` → UTF-8 string before `adMarkupStringFromResponse:`) | Non-UTF8/nil body → `adMarkupFromResponse == nil` instead of calling helper with `nil` |
| `WinNotifierImpl.swift:98` (`jsonResponse["adm"]`) | Non-string `adm` → `nil` instead of type-punned object |

### Consumer re-pointing

`PBMBidRequester.m`/bridging header drop the `#import`; both call sites unchanged (class name +
selectors preserved). `project.pbxproj`: −9 ObjC refs, +2 Swift refs.
`PrebidParameterBuilderTest.swift`: rename + `@testable import` → `@testable @_spi(PBMInternal)
import PrebidMobile` (Gap S4.1-C). Added `testPbAdSlotIsOmittedWhenNil()` — a `nil` `getPbAdSlot()`
must *remove* the `pbadslot` key via `NSMutableDictionary`'s `Any?` subscript, previously untested
(only the non-nil case was covered).

### Deleted (9 files)

`PBMPrebidParameterBuilder.{h,m}`, `PBMBidRequesterFactory.{h,m}`, `PBMBidRequesterFactoryBlock.h`,
`PBMWinNotifier.m`, `PBMWinNotifierBlock.h`, `PBMWinNotifierFactoryBlock.h`,
`PBMAdMarkupStringHandler.h`. Zero remaining references repo-wide (verified via `rg`).

### SwiftLint

`PrebidParameterBuilder.build(_:)` trips `cyclomatic_complexity` (52 vs. 10) as error, plus
`function_body_length`/`type_body_length` warnings — inherent to a faithful port, not a
refactor-worthy regression (refactoring risks behavioral drift). Suppressed only the error-level
rule via `swiftlint:disable:next` above the method. `type_body_length` warning left in place (a
class-level disable comment was flagged "Superfluous Disable Command", removed). Confirmed
non-blocking: no SwiftLint build phase or CI step.

### Playbook updates

- **Gap S4.3-A**: `@objc(Name)` on a class exposes the class but not a custom (non-protocol-witness)
  initializer — only `@objc`-protocol witnesses get automatic inference. `PrebidParameterBuilder`'s
  designated init was silently dropped from generated headers (`SWIFT_UNAVAILABLE` default `init`
  only), breaking `PBMBidRequester.m` ("no visible @interface... declares selector"). Fixed via
  explicit `@objc` on the init. Diagnosed by contrast with `BidResponseTransformer` (ruled out
  `@_spi`), `AdUnitConfig`'s `@objcMembers` (working counter-example), and `WinNotifierImpl` (needs
  no member-level `@objc` — class-level `NSClassFromString` lookup only).
- **Gap S4.3-B**: rationale for Phase 4's step order (`S4.1 → S4.3+S4.3b → S4.4 → S4.2 → S4.5`).
  S4.2 (`PBMBidRequester.m`) is the last ObjC caller of both S4.1's and S4.3's output — keeping it in
  ObjC is a free compile-time check of each port's `@objc` surface (how S4.3-A was caught). Its own
  port is low-risk, so deferring costs nothing.
- **Gap S4.3-C**: `PrivateHeaders/PBMBidRequester.h` is dead but invisible to the orphan-header
  sweep — it has a matching `.m`, which implements `PBMBidRequester_Objc` and never imports it.
  Delete with S4.2.
- Orphan-header inventory: 39 → 35 (removed 4 now-deleted headers, dropped stale
  `PBMPrebidParameterBuilder.m` importer reference from `PBMORTB.h`'s row).

## Test plan

- [x] `--latest --quick` — 858 tests, 0 failures (after `@objc`-init fix; first attempt failed to link)
- [x] `--latest` full suite — 1255 tests, 0 failures
- [x] `buildPrebidMobile.sh` — all 4 XCFrameworks succeeded
- [x] `buildPrebidSPM.sh` — SPM demo app build succeeded
- [x] `swiftlint` on both new files — 1 non-blocking `type_body_length` warning, 0 errors
- [x] Repo-wide `rg` for 7 deleted names — zero remaining references

### Post-review follow-ups (need a re-run)

- `testPbAdSlotIsOmittedWhenNil()` added — **not yet executed**.
- Five `if let x = params.x, !x.isEmpty` guards (dead bindings — body reads parallel `rawX`)
  collapsed to `if params.x?.isEmpty == false`. Semantics unchanged.
- `ORTBFormat.swift`'s Gap S2.5-D comment re-pointed to new Swift names.

Re-verified: swiftlint on 3 changed files (1 non-blocking warning, 0 errors), `Lib-PrebidMobile`
build succeeded. `PrebidMobileTests` target can't build on local Xcode 26.x — ~790 `@_spi` scope
errors **on master too** — needs CI (Xcode 16.4.0) to run the new test.
