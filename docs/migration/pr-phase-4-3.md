# [swift-migration] Phase 4, steps S4.3 + S4.3b — `PBMPrebidParameterBuilder` + `PBMWinNotifier`

Branch on top of `master` (`2befc557`, which itself lands S4.1). Second PR of Phase 4 (`PBMCore`),
per the user-approved step order: S4.1 (landed) → **S4.3 + S4.3b (this PR)** → S4.4 → S4.2 → S4.5.

## Scope

| File | Size | Non-test consumers (measured on `master`) |
|------|------|--------------------------------------------|
| `Prebid/PBMCore/PBMPrebidParameterBuilder.{h,m}` | 38 + 324 lines | `PBMBidRequester.m` (only call site: `initWithAdConfiguration:sdkConfiguration:targeting:userAgentService:` + `buildBidRequest:`) |
| `Prebid/PBMCore/PBMBidRequesterFactory.{h,m}` + `PrivateHeaders/PBMBidRequesterFactoryBlock.h` | 36 + 40 + 21 lines | **none** — dead code, folded into this PR per Gap S4.1-B |
| `Prebid/PBMCore/PBMWinNotifier.m` + `PrivateHeaders/PBMWinNotifierBlock.h`, `PBMWinNotifierFactoryBlock.h`, `PBMAdMarkupStringHandler.h` | 106 + 22 + 22 + 18 lines | `Factory.swift` (`NSClassFromString("PBMWinNotifier_Objc")` only — its Swift protocol `WinNotifier.swift` already existed, unimplemented) |

`PBMBidRequesterFactory` was measured (per S4.1-B) to have zero remaining callers anywhere in
`PrebidMobile`/`EventHandlers` — pure dead code, deleted rather than ported.

## Summary

### `PBMPrebidParameterBuilder` → `PrebidParameterBuilder.swift`

`PrebidMobile/Swift/PrebidMobileRendering/Prebid/PBMCore/PrebidParameterBuilder.swift`.

De-prefixed per S1.1. `@objc(PBMPrebidParameterBuilder) @_spi(PBMInternal) public class
PrebidParameterBuilder: NSObject, ParameterBuilder` — `@_spi(PBMInternal)` because it's an internal
request-building utility with a single ObjC caller (`PBMBidRequester.m`), same tier as
`BidResponseTransformer` (S4.1). `ParameterBuilder` is `@objc(PBMParameterBuilder)`, so
`build(_:)` satisfies its `@objc(buildBidRequest:)` requirement and needed no explicit `@objc` of
its own — the protocol witness gets automatic inference (Gap 7). The 4-parameter designated
initializer does **not** satisfy any protocol requirement, so it needed an explicit `@objc` (see
new Gap S4.3-A below — this was a real, test-suite-catching build failure, not just theoretical).

Line-for-line port of `build(_:)` (the ObjC method was already `swiftlint:disable
cyclomatic_complexity`-worthy at 324 lines in ObjC; the Swift twin keeps a
`// swiftlint:disable:next cyclomatic_complexity function_body_length` comment on the method for
the same reason — see "SwiftLint" below): populates `requestID`/`storedRequestID`, GDPR consent,
OMID source ext, ad-format-specific banner/video/native fields on every imp, dedup'd `ORTBFormat`
list (`Set` dedup, per existing Gap 3), interstitial min-size-percent, `appExtPrebid.source`/
`.version` defaults.

### `PBMWinNotifier` → `WinNotifierImpl.swift`

`PrebidMobile/Swift/PrebidMobileRendering/Prebid/PBMCore/WinNotifierImpl.swift` — this PR's S4.3b.
`@objc(PBMWinNotifier_Objc) @_spi(PBMInternal) public class WinNotifierImpl: NSObject,
WinNotifier` — the ObjC-visible name matches the string literal `Factory.swift` already resolves
via `NSClassFromString("PBMWinNotifier_Objc")`; that's the *only* ObjC-side touchpoint, so unlike
`PrebidParameterBuilder` this class needed **no** member-level `@objc` at all (class-level bridge
only — see the contrast note in Gap S4.3-A). `WinNotifier.swift` (the protocol) already existed,
unimplemented, from an earlier phase.

Line-for-line port of `notifyThroughConnection(_:winningBid:callback:)`: builds a chained sequence
of win/uuid/cache-URL notification `download` calls via nested closures, falling back to
`ORTBMacrosHelper`-driven macro substitution when no inline ad markup is present, plus the
`hb_cache_host`/`hb_cache_path`/`hb_uuid`/`hb_cache_id`-keyed `cacheUrl(fromTargeting:idKey:)`
helper and `adMarkupString(fromResponse:)` JSON-`"adm"` extraction helper.

### Consumer re-pointing

- **`PBMBidRequester.m`** — dropped `#import "PBMPrebidParameterBuilder.h"`; the one call site
  (`[[PBMPrebidParameterBuilder alloc] initWithAdConfiguration:sdkConfiguration:targeting:
  userAgentService:]` / `buildBidRequest:`) is unchanged since both the class name and the two
  selectors are preserved.
- **`PrebidMobileTest-Bridging-Header.h`** — dropped `#import "PBMPrebidParameterBuilder.h"`.
- **`PrebidMobile.xcodeproj/project.pbxproj`** — 9 ObjC file references removed (`.h` from Headers,
  `.m` from Sources, plus their `PBXFileReference`/group entries), 2 Swift file references added
  (`PrebidParameterBuilder.swift`, `WinNotifierImpl.swift`, into the existing Swift `PBMCore` group
  and Sources build phase), via the `xcodeproj` gem (same procedure as S4.1).
- **`PrebidParameterBuilderTest.swift`** — `PBMPrebidParameterBuilder(...)` → `PrebidParameterBuilder(...)`;
  `@testable import PrebidMobile` → `@testable @_spi(PBMInternal) import PrebidMobile` (Gap S4.1-C —
  the type is `@_spi(PBMInternal)`, a bare `@testable import` doesn't unlock it).

### Deleted (9 files)

`PBMPrebidParameterBuilder.{h,m}`, `PBMBidRequesterFactory.{h,m}`, `PBMBidRequesterFactoryBlock.h`,
`PBMWinNotifier.m`, `PBMWinNotifierBlock.h`, `PBMWinNotifierFactoryBlock.h`,
`PBMAdMarkupStringHandler.h`. Zero remaining references to any of these 7 class/header names
anywhere in the repo outside `docs/**`/`generated/**` (verified by repo-wide `rg`).

### SwiftLint

`PrebidParameterBuilder.build(_:)` trips `cyclomatic_complexity` (52 vs. threshold 10) as an
**error**, plus `function_body_length`/`type_body_length` warnings — inherent to a faithful
line-for-line port of a large ObjC method with many independent ad-format branches, not a
regression to fix by refactoring during a migration PR (refactoring risks behavioral drift where
fidelity to the original is the point). Suppressed the error-level violation only:
`// swiftlint:disable:next cyclomatic_complexity function_body_length` directly above the method.
Left the `type_body_length` warning in place (a `swiftlint:disable:next type_body_length` comment
on the class declaration was tried first but flagged "Superfluous Disable Command" — doesn't
actually suppress that rule's measurement — so it was removed). Confirmed non-blocking: no
SwiftLint build phase in `project.pbxproj`, no SwiftLint step in `.github/workflows/*.yml`.

### Playbook updates

- New **Gap S4.3-A**: `@objc(Name)` on a class exposes the class itself to Objective-C, but does
  not by itself expose a custom (non-protocol-witness) initializer — only `@objc`-protocol witness
  methods get automatic inference. `PrebidParameterBuilder`'s designated initializer was silently
  dropped from the generated `PrebidMobile-Swift.h` (only a `SWIFT_UNAVAILABLE` default `init`
  appeared), causing `PBMBidRequester.m` to fail with "no visible @interface ... declares the
  selector `initWithAdConfiguration:...`". Fixed by adding an explicit `@objc` to the initializer.
  See the gap entry for the full diagnostic narrative (compared against `BidResponseTransformer`
  to rule out `@_spi` as the cause, `AdUnitConfig`'s `@objcMembers` as the working counter-example,
  and the contrast with `WinNotifierImpl`, which needed no member-level `@objc` since its only
  ObjC touchpoint is a class-level `NSClassFromString` lookup).
- Orphan-header inventory (S3.2) updated: 39 → 35 headers with no matching `.m`. Removed 4 rows
  now actually deleted (`PBMAdMarkupStringHandler.h`, `PBMBidRequesterFactoryBlock.h`,
  `PBMWinNotifierBlock.h`, `PBMWinNotifierFactoryBlock.h`) and dropped the now-stale
  `PBMPrebidParameterBuilder.m` importer reference from `PBMORTB.h`'s row.

## Test plan

- [x] `./scripts/testPrebidMobile.sh --latest --quick` — **858 tests, 0 failures** (after the
      `@objc`-init fix; first attempt failed to link before the fix was applied)
- [x] `./scripts/testPrebidMobile.sh --latest` — full suite — **1255 tests, 0 failures**
- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks — **succeeded**
- [x] `./scripts/buildPrebidSPM.sh` — SPM demo app build (iOS Simulator) — **succeeded**
- [x] `swiftlint lint --config .swiftlint.yml` on both new Swift files — 1 non-blocking
      `type_body_length` warning, 0 errors
- [x] Repo-wide `rg` for the 7 deleted class/header names — zero remaining references
