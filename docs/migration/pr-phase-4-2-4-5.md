# [swift-migration] Phase 4, steps S4.2 + S4.5 — PBMBidRequester, PBMDisplayTransactionFactory

Branch on top of `master` (`a289c42b`). Final PR of Phase 4, step order:
S4.1, S4.3 + S4.3b, S4.4 (all landed) → **S4.2 + S4.5 (this)**.

Phase 4 is **intentionally closed with two files still in ObjC** (`PBMVastTransactionFactory`,
`PBMTransactionFactory.m`) — deferred to Phase 6 behind `AdLoadManager`. Do not ask to complete them
here; rationale and Phase 6 pick-up list in playbook Gap **S4.5-B**.

## S4.2 — `PBMBidRequester`

### Scope

| File | Non-test consumers |
|------|---------------------|
| `Prebid/PBMCore/PBMBidRequester.m` (class `PBMBidRequester_Objc`) | `Factory.swift` only, via `NSClassFromString("PBMBidRequester_Objc")` |
| `PrivateHeaders/PBMBidRequester.h` | none — dead (Gap S4.3-C) |

S4.2 was deliberately ported after S4.1/S4.3 (Gap S4.3-B): the ObjC `.m` was the last caller of
`BidResponseTransformer` and `PrebidParameterBuilder`, so their `@objc` surface was already
compiler-checked.

### Summary

#### `BidRequesterImpl.swift` (new)

`@objc(PBMBidRequester_Objc) @_spi(PBMInternal) public class BidRequesterImpl: NSObject, BidRequester`
— the `WinNotifierImpl` shape. The ObjC runtime name is preserved so
`Factory.bidRequesterType` keeps resolving with no change to `Factory.swift`. No member-level
`@objc` is needed: every call site is Swift-only and the protocol requirements are inherited from
`BidRequester` / `BidRequesterProtocol`.

Behavior ported 1:1, including:
- ms → s timeout conversion for `timeoutMillisDynamic` (read and write sides);
- `filterOutUncachedBids` gated on `isOriginalAPI`, `noCachedBids` vs `noWinningBid` selection;
- `tmax` → dynamic-timeout update, only when no dynamic timeout is set and the host URL is unchanged;
- `prebidmobilesdk` passthrough → `creativeFactoryTimeout` / `…PreRenderContent`;
- event-delegate callback after every completion path that reached the server response.

Structural changes (no behavior change):
- `@synchronized(self)` completion handling (Issue #1195) → an `NSLock` around three small
  helpers (`isRequestInProgress`, `setCompletion`, `takeCompletion`).
- `findErrorInSettings` size checks use `CGSize` directly instead of boxing in `NSValue`.
- `isInvalidID` takes a non-optional `String` (the Swift properties are non-optional); trimming
  uses `.whitespaces`, same as the ObjC `whitespaceCharacterSet`.
- ObjC quirk **not** carried over: `self.completion = completion ?: ^{}` never ran with nil
  (the Swift parameter is non-optional).
- `@weakify/@strongify` → `[weak self]` + `guard let self`.

#### Deleted (2 files)

`PBMBidRequester.m`, `PrivateHeaders/PBMBidRequester.h` (dead `@interface` — Gap S4.3-C).
`project.pbxproj`: −4 ObjC refs, +2 Swift refs (`BidRequesterImpl.swift` in the `PBMCore` group).

## S4.5 — `PBMDisplayTransactionFactory` (partial)

### Scope

S4.5 was planned as the three `TransactionFactory/` files. Only one is ported here (Gap S4.5-A):

| File | Status |
|------|--------|
| `PBMDisplayTransactionFactory.{h,m}` | **ported** → `DisplayTransactionFactory.swift` |
| `PBMVastTransactionFactory.{h,m}` | deferred — constructs and drives `PBMAdLoadManagerVAST` (ObjC, no Swift twin) |
| `PBMTransactionFactory.m` (`PBMTransactionFactory_Objc`) | deferred — constructs `PBMVastTransactionFactory` directly |

### Summary

`DisplayTransactionFactory.swift`: `@objc(PBMDisplayTransactionFactory) @_spi(PBMInternal) public class`,
conforming to `TransactionDelegate`. The surviving ObjC dispatcher `PBMTransactionFactory.m` still
`alloc/init`s it, so the class name and `@objc(initWithBid:adConfiguration:connection:callback:)` /
`@objc(loadWithAdMarkup:)` are explicit (Gap S4.3-A). Line-for-line port; `@weakify` becomes
`[weak self]`. `width`/`height` convert `CGFloat` → `Int` with `Int(...)` truncation, matching the
implicit ObjC conversion.

`PBMTransactionFactory.m`: dropped the `#import "PBMDisplayTransactionFactory.h"` (header deleted).

#### Deleted (3 files)

`PBMDisplayTransactionFactory.m`, `PrivateHeaders/PBMDisplayTransactionFactory.h`. `project.pbxproj`:
−4 ObjC refs, +2 Swift refs (`TransactionFactory` group).

## Open items for the reviewer

- `BidRequesterImpl.swift`: SwiftLint `type_body_length` warning (182 > 100 lines). Left as a warning;
  split or disable at reviewer's preference.
- Local-run gotcha: after deleting `.m` files, a stale DerivedData folder produced 635 spurious
  "Undefined symbols" link errors in `PrebidMobileTests`; a clean DerivedData fixed it. (Earlier
  PR docs blame a local `@_spi` toolchain failure — not reproduced on Xcode 26.2; clean `master`
  and this branch both build the test bundle.)

## Test plan

- [x] `buildPrebidMobile.sh` — all 4 XCFrameworks succeeded
- [x] `buildPrebidSPM.sh` — succeeded
- [x] `plutil -lint` on `project.pbxproj` — OK
- [x] `swiftlint` on both new files — 0 errors; 1 warning (`type_body_length`, above)
- [x] `testPrebidMobile.sh --latest --quick` — 953 tests, 0 failures (clean DerivedData)
- [ ] `--latest` full suite — **did not complete locally** (hit a 30 min limit at ~730 cases).
  3 timing-sensitive failures seen under load (`AdUnitTests.testFetchDemandResumeAutoRefresh`,
  `AutoRefreshManagerTest.testAllowRefreshOnSecondAtempt`, `…testBlocksCallSequenceWithPrefetch2`);
  all 32 tests of those two classes pass when rerun alone. Needs CI.
- [ ] `testPrebidMobileAdapters.sh` — **not run**: two leftover `iPhone-17-Pro-PrebidMobile`
  simulators made the destination ambiguous. Needs CI or a rerun after removing them.
