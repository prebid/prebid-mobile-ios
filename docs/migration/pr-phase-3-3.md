# [swift-migration] Phase 3.3 — `PBMTrackingRecord` and `PBMURLComponents`

Branch `swift-migration-phase-3-3`, on `master` (`a09e3173`, merged Phase 3 PR #1328). Resolves the
scope question [pr-phase-3.md](pr-phase-3.md) left open by porting the two ObjC files still under
`Networking/` after Phase 3, retiring that directory entirely.

## Scope

| File | Non-test consumers (re-measured, differs from pr-phase-3.md's table) |
|------|--------------------------------------------------------------------|
| `Tracking/PBMTrackingRecord.{h,m}` | **none** — pr-phase-3.md's claim (`PBMVastAdsBuilder.m`, `PBMAdRequesterVAST.m`) was stale; those files `#import` the *other* header (`PBMURLComponents.h`) but never reference `TrackingRecord`, and never reference `PBMURLComponents` either — both are dead imports, removed here |
| `URLBuilding/PBMURLComponents.{h,m}` | `PBMVastRequester.m` (`initWithUrl:paramsDict:`, `.argumentsString`/`.urlString`) |

## Summary

### `PBMTrackingRecord` → `TrackingRecord.swift`

Zero non-test consumers, and the header was `PrivateHeaders/`-only (never public podspec surface).
Per Gap S3.2-A: plain `final class` (later `struct` — see review fixes), no `@objc`/`NSObject`/
`public`. `@testable import` already gives the existing test file access; unchanged, compiles as-is.
Dropped the ObjC `PBMAssert`/`?: @""` fallbacks — unreachable once parameters are non-optional
`String` (Gap S3.1-H reasoning).

### `PBMURLComponents` → `PBMURLComponents.swift`

Kept the `PBM` prefix on both the type name and `@objc` bridge — new **Gap S3.3-A**: `Foundation`
already exports `URLComponents` (a struct, exercised by an existing `URLComponentsTests.swift`);
renaming would shadow it module-wide. Because `PBMVastRequester.m` is a real surviving ObjC
consumer, kept the full bridge (`@objc(PBMURLComponents) public class PBMURLComponents: NSObject`,
`@objc(initWithUrl:paramsDict:)`, `@objc public var` on `fullURL`/`urlString`/`argumentsString`).
Dedupe algorithm (existing query items + sorted `paramsDict` entries, `paramsDict` wins on
collision) is a line-for-line port, hand-traced against the existing `PBMURLComponentsTest.testPositive`
fixture. Dropped the ObjC `|| !paramsDict` nil-check — unreachable once the parameter is
non-optional (same reasoning as Gap S3.1-H).

### Consumer re-pointing / deletion

`PBMVastRequester.m` dropped its `#import "PBMURLComponents.h"` (arrives via `SwiftImport.h`);
`PBMVastAdsBuilder.m`/`PBMAdRequesterVAST.m` dropped their dead `#import`;
`PrebidMobileTest-Bridging-Header.h` lost both imports; `project.pbxproj` −4 ObjC refs / +2 Swift
refs. Deleted `PBMTrackingRecord.{h,m}`, `PBMURLComponents.{h,m}` — the ObjC `Networking/` tree no
longer exists on disk.

### Deliberate divergence

`PBMAssert`/defensive nil-checks dropped in both types — unreachable once the corresponding
parameters are non-optional Swift types (Gap S3.1-H class); safe because `PBMURLComponents`'s only
ObjC construction site already passes a literal `@{}`, never `nil`, and `TrackingRecord` has no
ObjC caller at all.

### Playbook updates

- New **Gap S3.3-A** (documented above).
- **Correction to Gap S3.1-H**: "keep the parameter non-optional but re-introduce a graceful guard"
  doesn't work once a real ObjC caller survives — bridging traps on `nil` before the guard runs.
  Corrected rule: the bridged parameter must be `Optional` in that case, regardless of
  `NS_ASSUME_NONNULL` (compile-time only).

### Review fixes (PR #1336)

- **`PBMURLComponents.init` nil-safety** — reverted `url`/`paramsDict` to `String?`/
  `[String: String]?` with an explicit guard + `Log.error`, per the Gap S3.1-H correction (a future
  ObjC `nil` caller must not trap during bridging).
- **Dedup comparison** — the ported nested `contains(where:)` compared names with Swift `==`
  (Unicode canonical equivalence) instead of ObjC's `isEqualToString:` (literal UTF-16), a real
  divergence for differently-normalized duplicate names. Replaced with a single-pass
  `[NSString: Int]` last-index map + filter — same "last occurrence wins" result, `NSString`-keyed
  (matches ObjC), O(n) instead of O(n²).
- `urlString`'s double `nsUrlComponents.string` call bound to a local once.
- `NSURLComponents` → Swift's native `URLComponents` struct (never crossed the `@objc` boundary
  itself) — same API, compiler-enforced immutability on the `let`.
- `TrackingRecord` → `struct` (two `let`s, no identity semantics) instead of `final class`.

## Test plan

- [x] `./scripts/testPrebidMobile.sh --latest --quick` — **812 tests, 0 failures, no retries**
      (unchanged count — both test classes pre-existing)
- [x] `-only-testing` re-run of `PBMTrackingRecordTest`/`PBMURLComponentsTest` — 2/2 pass
- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [x] `swiftlint lint --config .swiftlint.yml` on both new files — 0 violations
- [x] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build succeeded (flagged in review since
      this PR deletes ObjC headers/imports from surviving consumers)
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite, run before merge
