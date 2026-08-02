## Summary

Phase 2 — Utilities & extensions. All three steps complete (S2.1, S2.2, S2.3).

All Swift twins live under `PrebidMobile/Swift/PrebidMobileRendering/`.
Naming: Swift class = `FooBar`, file = `FooBar.swift`, ObjC bridge = `@objc(PBMFooBar)`.

---

### S2.1 — Standalone utilities (`Utilities/`)

Ported 8 of 12 files. 4 deferred due to private-header ObjC dependencies (Gap 8):
- `PBMDeepLinkPlusHelper` → Phase 4 (deps: `PBMExternalLinkHandler`, `PBMExternalURLOpeners`, `PBMTrackingURLVisitors`)
- `PBMWindowLocker` → Phase 8 (dep: `PBMOpenMeasurementSession`)

`PBMMRAIDConstants` partially ported: ObjC classes → `MRAIDConstants.swift`; `NS_TYPED_ENUM` string constants kept in residual `.m` (Gap S2.1-A).

Key findings:
- `PBMFunctions` was the Gap 8 header that forced inlining in Phase 1. Now in Swift, future phases call `Functions.*` directly.
- `PBMUIApplicationProtocol.h` reduced to forward declaration; protocol definition moved to `PBMUIApplicationProtocol.swift`.
- `dispatch_time()` → `DispatchTime` (Gap S2.1-C). `UIInterfaceOrientationIsPortrait()` → `.isPortrait` (Gap S2.1-D).
- `@objc(selector:)` on `throws` methods must include `:error:` label (Gap S2.1-E).
- `CALayer @dynamic` → `@NSManaged` (Gap S2.1-F).

---

### S2.2 — Foundation/UIKit category extensions (`ExtensionsAndWrappers/`)

Ported all 11 files including the `Exposure/` subgroup.

Key findings:
- `@objc extension` on Foundation types (`NSDictionary`, `NSString`, etc.) bridges automatically; no ObjC consumer changes beyond removing the deleted `#import` (Gap S2.2-A).
- ObjC `nil NSString*` → Swift `String` becomes `""`. Methods with ObjC nil-guards need `String?` parameters (Gap S2.2-B).
- `ViewExposure`/`ViewExposureChecker` are `@_spi(PBMInternal)` — conforming Swift classes must carry the same annotation (Gap S2.2-C).
- `Factory` (Swift name), not `PBMFactory` (ObjC bridge name) (Gap S2.2-D).
- `NSClassFromString("PBMViewExposure_Objc")` in `Factory.swift` requires `@objc(PBMViewExposure_Objc)` on `ViewExposureImpl`.
- `LogViewHierarchy` ObjC selector → `@objc(LogViewHierarchy) func logViewHierarchy()` (Gap S2.2-E).
- `Prebid.forcedIsViewable` (DEBUG ObjC category, Gap 8) → KVC `value(forKey:)` (Gap S2.2-F).

---

### S2.3 — NSTimer wrapper (`ExtensionsAndWrappers/NSTimer/`)

Ported `NSTimer+PBMScheduledTimerFactory`, `PBMWeakTimerTargetBox`, and added `TimerInterface` Swift protocol.

Key findings:
- `NSInvocationOperation` unavailable in Swift → `NSObject.perform(_:with:)` (Gap S2.3-A).
- `PBMScheduledTimerFactory` ObjC block typedef kept in `PBMScheduledTimerFactory.h` (header-only, no `.m`); Swift closure is structurally compatible — ObjC callers assign without explicit casts (Gap S2.3-B).
- `PBMTimerInterface.h` reduced to forward decl caused `PBMScheduledTimerFactory.h` to lose transitive Foundation types — fixed by adding `#import <Foundation/Foundation.h>` directly (Gap S2.3-C).

---

## Commits (branch `swift-migration-phase-2`)

- `632bd5dd` S2.1 — Port standalone utilities to Swift
- `16f89cb1` docs: update playbook with S2.1 gaps
- `990b6778` S2.2 — Port Foundation/UI category extensions to Swift
- `c81e0568` S2.3 — Port NSTimer wrapper to Swift; Phase 2 complete
- `ced2c972` docs: codify S2.2 + S2.3 gaps in playbook; finalize pr-phase-2

---

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 694 tests, 0 failures (S2.3 final)
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite (pending before merge)
- [ ] Reviewer: confirm gap S2.1-A (NS_TYPED_ENUM deferred) and gap S2.1-B (@_spi imports in tests)

---

### S2.4 — Rebase onto `master` (post `#1294`)

Rebased phases 0–2 onto `master` at `273cd07f` ("fix: register click on touch up", #1294), which
landed after these commits were originally authored.

Conflicts resolved:
- `project.pbxproj`, `PBMWebView.m`, `PBMVideoView.h`, test bridging header — mechanical; kept the
  migration's file deletions (ObjC → Swift moves) alongside master's unrelated changes.
- `PBMTouchDownRecognizer` — **dropped, not reconciled**. `#1294` deleted the class entirely
  (replaced `PBMWebView`/`PBMVideoView`'s tap-down recognizer with a plain `UITapGestureRecognizer`
  + `shouldReceiveTouch:`), which auto-merged cleanly since the migration's diff didn't touch that
  code. The migration's `TouchDownRecognizer.swift` port and its test were now dead code ported
  from a class master no longer has — removed both, plus their `project.pbxproj` entries, rather
  than reconciling (Gap S2.4-A, see `pr-phase-2-description.md`).
- `PBMVideoViewPlaybackStateTest.swift:462` — master's `#1286`/`#1292` fixes added a new test after
  S2.1 was authored, referencing `PBMDownloadDataHelper` (the ObjC name). Since `DownloadDataHelper`
  is Swift-only now, renamed the reference (Gap S2.4-B — same class as S2.1, but rediscovered
  because it was introduced by a post-migration upstream commit, not part of the original port).

Test plan for the rebase:
- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 751 tests, 0 failures (test count grew
      from 694 due to master's intervening commits)
