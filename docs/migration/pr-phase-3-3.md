# [swift-migration] Phase 3.3 — `PBMTrackingRecord` and `PBMURLComponents`

Branch `swift-migration-phase-3-3`, on top of `master` (`a09e3173`, the merged Phase 3 PR #1328).
Resolves the scope question [pr-phase-3.md](pr-phase-3.md) left open: the two ObjC files still
living under `PrebidMobile/Objc/PrebidMobileRendering/Networking/` after Phase 3 landed are ported
here, retiring that directory entirely.

## Scope

| File | Size | Non-test consumers (measured on `master`, not the pr-phase-3.md table) |
|------|------|--------------------------------------------------------------------|
| `Tracking/PBMTrackingRecord.{h,m}` | 37 + 29 lines | **none** |
| `URLBuilding/PBMURLComponents.{h,m}` | 99 + 28 lines | `PBMVastRequester.m` |

pr-phase-3.md's consumer table claimed `PBMTrackingRecord` was consumed by `PBMVastAdsBuilder.m`
and `PBMAdRequesterVAST.m`. That is stale/inaccurate against current `master`: neither file
references `TrackingRecord` anywhere (`rg -n TrackingRecord` returns only the header, the `.m`
itself, the bridging header, and the existing Swift test). Both files *do* `#import
"PBMURLComponents.h"`, but neither ever references the `PBMURLComponents` symbol — dead imports,
removed in this PR. The one real construction site is `PBMVastRequester.m`
(`[[PBMURLComponents alloc] initWithUrl:url paramsDict:@{}]`, then `.argumentsString` /
`.urlString`).

## Summary

### `PBMTrackingRecord` → `TrackingRecord.swift`

`PrebidMobile/Swift/PrebidMobileRendering/Networking/Tracking/TrackingRecord.swift`.

Zero non-test consumers, and the ObjC header lived under `PrivateHeaders/` — never part of the
public podspec surface either. Per Gap S3.2-A, plain `final class`, no `@objc`, no `NSObject`, no
`public`. `@testable import` already gives `PBMTrackingRecordTest.swift` access; it is unchanged
and compiles against the new type without modification (it already called
`TrackingRecord(trackingType:trackingURL:)`, matching the header's pre-existing
`NS_SWIFT_NAME(TrackingRecord)`).

Dropped the ObjC `PBMAssert(trackingType && trackingURL)` guard and the `?: @""` fallbacks — both
unreachable once the parameters are non-optional Swift `String`, same reasoning as Gap S3.1-H.

### `PBMURLComponents` → `PBMURLComponents.swift`

`PrebidMobile/Swift/PrebidMobileRendering/Networking/URLBuilding/PBMURLComponents.swift`.

Kept the `PBM` prefix on both the Swift type name and the `@objc` bridge — see new **Gap S3.3-A**.
`Foundation` already exports `URLComponents` (a struct), and a separate existing test
(`URLComponentsTests.swift`) exercises that stdlib type directly; renaming the twin to
`URLComponents` would shadow it project-wide. Because `PBMVastRequester.m` is a real, surviving
ObjC consumer, the twin keeps the full bridge: `@objc(PBMURLComponents) public class
PBMURLComponents: NSObject`, `@objc(initWithUrl:paramsDict:)` on the initializer, `@objc public
var` on `fullURL` / `urlString` / `argumentsString`.

The dedupe algorithm (existing query items + sorted `paramsDict` entries, reverse, drop items whose
name was already seen, reverse again — so a `paramsDict` key beats an existing query-string key on
collision) is a line-for-line port of `PBMURLComponents.m`, reusing the existing `NSString`
extension `PBMsubstringToString(_:)` for `urlString`'s `?`-stripping (already called directly on a
plain Swift `String` elsewhere in the test suite). Traced the existing
`PBMURLComponentsTest.testPositive` fixture through both the ObjC and the Swift versions by hand
before committing to the port. Dropped the ObjC `|| !paramsDict` nil-check — unreachable once the
parameter is a non-optional `[String: String]`, same reasoning as Gap S3.1-H.

`PBMURLComponentsTest.swift` is unchanged; it already constructed
`PBMURLComponents(url:paramsDict:)` and read `.fullURL`, confirming the prefixed name was already
the deliberate, established shape of this type's Swift-visible surface.

### Consumer re-pointing

- **`PBMVastRequester.m`** — dropped `#import "PBMURLComponents.h"`; the Swift type arrives via
  the existing `#import "SwiftImport.h"`.
- **`PBMVastAdsBuilder.m`**, **`PBMAdRequesterVAST.m`** — dropped the dead
  `#import "PBMURLComponents.h"` (imported, never referenced).
- **`PrebidMobileTest-Bridging-Header.h`** — 2 imports removed
  (`PBMTrackingRecord.h`, `PBMURLComponents.h`).
- **`PrebidMobile.xcodeproj/project.pbxproj`** — 4 ObjC file references removed, 2 Swift file
  references added (`TrackingRecord.swift` into a new `Tracking` subgroup under the Swift
  `Networking` group; `PBMURLComponents.swift` into the existing Swift `URLBuilding` subgroup), via
  the `xcodeproj` gem (same procedure as Phases 1–3). The 3 now-empty ObjC groups this left behind
  (`Tracking`, `URLBuilding`, `Networking` under `/PrebidMobile/Objc/PrebidMobileRendering/Networking`
  — their directories had already been pruned from disk by `git rm`'s default empty-parent
  cleanup) were removed from the project in a follow-up pass. Net: `1 file changed, 17
  insertions(+), 48 deletions(-)`.

### Deleted (4 files)

`PBMTrackingRecord.{h,m}`, `PBMURLComponents.{h,m}`. `PrebidMobile/Objc/PrebidMobileRendering/Networking/`
no longer exists on disk — the ObjC side of `Networking/` is now fully retired; the Swift side
(`PrebidMobile/Swift/PrebidMobileRendering/Networking/`) is the only one going forward.

### Deliberate behavioural divergences

1. **`PBMAssert`/defensive nil-checks dropped in both types.** `TrackingRecord`'s
   `PBMAssert(trackingType && trackingURL)` and `PBMURLComponents`'s `|| !paramsDict` check are
   both unreachable once the corresponding parameters are non-optional Swift types. Same class of
   change as Gap S3.1-H: safe here because the only ObjC-side construction of `PBMURLComponents`
   (`PBMVastRequester.m`) already passes a literal `@{}`, never `nil`, and `TrackingRecord` has no
   ObjC caller at all.

Everything else is a line-for-line port, verified by hand-tracing the existing
`PBMURLComponentsTest.testPositive` fixture through both versions.

### Playbook updates

- New **Gap S3.3-A**: `PBMURLComponents` keeps its `PBM` prefix on both sides of the bridge —
  documented exception to the S1.1 "no PBM prefix" rule for names that collide with a stdlib/UIKit
  type, plus the note that `TrackingRecord`'s zero-consumer visibility decision is a straightforward
  application of the existing Gap S3.2-A, not a new gap.

## Test plan

- [x] `./scripts/testPrebidMobile.sh --latest --quick` — **812 tests, 0 failures, no retries**
      (unchanged count from the last Phase 3 round: `PBMTrackingRecordTest` and
      `PBMURLComponentsTest` are pre-existing test classes, not new ones)
- [x] `-only-testing` re-run of `PBMTrackingRecordTest` and `PBMURLComponentsTest` on the full test
      plan — **2 tests, 0 failures** (`testDefaultValues`, `testPositive`)
- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build clean, zero compile errors in
      `generated/log/prebid_mobile_build.log`
- [x] `swiftlint lint --config .swiftlint.yml` on `TrackingRecord.swift` and
      `PBMURLComponents.swift` — **0 violations**
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite, run before merge
- [ ] Reviewer: confirm the Gap S3.3-A naming exception (keeping the `PBM` prefix on
      `PBMURLComponents`) is the right call versus, e.g., naming the Swift type something else
      entirely to allow dropping the prefix
