# [swift-migration] Phase 4, step S4.4 — Native click tracking

Branch on top of `master` (`403f13a6`). Third PR of Phase 4, step order:
S4.1 (landed) → S4.3 + S4.3b (landed) → **S4.4 (this)** → S4.2 → S4.5.

## Scope

| File | Non-test consumers |
|------|---------------------|
| `NativeEventsTracking/ClickTracking/PBMExternalLinkHandler.{h,m}` | `PBMDeepLinkPlusHelper.m` (`deepLinkPlusHandlerWithExternalLinkHandler:` + `openExternalUrl:trackingUrls:completion:onClickthroughExitBlock:` + `asDeepLinkHandler` + `handlerByAddingUrlOpenAttempter:`) |
| `PBMExternalURLOpenCallbacks.{h,m}` | `PBMExternalLinkHandler.m` (also ported here), `PBMDeepLinkPlusHelper.m` (`urlOpenedCallback` / `onClickthroughExitBlock` reads at `:73-75`) |
| `PBMExternalURLOpeners.{h,m}` | `PBMDeepLinkPlusHelper.m` (`applicationAsExternalUrlOpener:`) |
| `PBMTrackingURLVisitors.{h,m}` | `PBMDeepLinkPlusHelper.m` (`connectionAsTrackingURLVisitor:`) |

`PBMDeepLinkPlusHelper.m` itself stays ObjC (deferred — not part of this phase's step list); it's
the sole remaining consumer of all 4 ported classes, so this step follows S4.3-B's ordering rule
(leaf classes first, consumer last) for free `@objc`-surface checking.

The 4 block-typedef headers `PBMURLOpenAttempterBlock.h`, `PBMURLOpenResultHandlerBlock.h`,
`PBMExternalURLOpenerBlock.h`, `PBMTrackingURLVisitorBlock.h` are **kept** (orphan-header rule,
S2.3-B/S3.2) — `PBMDeepLinkPlusHelper.m` still directly imports/uses two of them
(`PBMURLOpenAttempterBlock`, `PBMTrackingURLVisitorBlock`) as local variable/block types.

## Summary

### `ExternalURLOpenCallbacks.swift`, `ExternalURLOpeners.swift`, `TrackingURLVisitors.swift`, `ExternalLinkHandler.swift`

All 4 twins: `@objc(PBMFoo) @_spi(PBMInternal) public class Foo: NSObject` (Gap 4/6 — live ObjC
consumer via `PBMDeepLinkPlusHelper.m`), `@available(*, unavailable) override init()` for the two
static-utility classes (`ExternalURLOpeners`, `TrackingURLVisitors`), explicit `@objc(selector:)` on
every custom initializer/factory method (Gap S4.3-A — none of these satisfy a protocol witness).
Line-for-line ports; no behavioral changes.

`ExternalURLOpeners.applicationAsExternalUrlOpener(_:)` takes `PBMUIApplicationProtocol` (Swift
protocol, pre-existing) and calls `.open(_:options:completionHandler:)`.
`TrackingURLVisitors.connectionAsTrackingURLVisitor(_:)` takes `PrebidServerConnectionProtocol`
(Swift protocol, pre-existing) and calls `.get(_:timeout:callback:)`, kept the two original
`// TODO:` comments verbatim (`fireAndForget` / non-zero timeout).

`ExternalLinkHandler` is the most complex twin: `openExternalUrl(_:trackingUrls:completion:
onClickthroughExitBlock:)`, `asDeepLinkHandler` (computed `@objc public var`), and
`handlerByAddingUrlOpenAttempter(_:)` (returns a new instance wrapping the primary opener with an
attempter chain) — all ported 1:1 from the ObjC block-based implementation.

### `ClickTrackingBlocks.swift` (new — not a 1:1 file mirror)

Consolidates the Swift-facing closure `typealias`es for what were 4 separate ObjC block-typedef
headers into one file, since none of them export as a named ObjC-visible Swift type (Gap S2.3-B —
block typedefs bridge structurally, not nominally): `URLOpenResultHandlerBlock`,
`TrackingURLVisitorBlock`, `ExternalURLOpenerBlock`, `CanOpenURLResultHandlerBlock`,
`URLOpenAttempterBlock`. The ObjC block-typedef headers themselves are untouched and still used
directly by the surviving `PBMDeepLinkPlusHelper.m`.

### Consumer re-pointing

- `PBMDeepLinkPlusHelper.m`: dropped `#import`s for the 3 now-Swift class headers
  (`PBMExternalLinkHandler.h`, `PBMExternalURLOpeners.h`, `PBMTrackingURLVisitors.h`); added a
  direct `#import "PBMTrackingURLVisitorBlock.h"` (previously pulled in transitively through
  `PBMTrackingURLVisitors.h` — build broke without it, see below). Call sites unchanged (class
  names + selectors preserved via `@objc(PBMFoo)`/`@objc(selector:)`).
- `PBMURLOpenAttempterBlock.h`: replaced `#import "PBMExternalURLOpenCallbacks.h"` with a forward
  declaration (`@class PBMExternalURLOpenCallbacks;` + "has been moved to Swift" comment), mirroring
  the existing `PBMUIApplicationProtocol.h` precedent.
- `PBMDeepLinkPlusHelper+PBMExternalLinkHandler.h`: same treatment for `PBMExternalLinkHandler.h`.
- `project.pbxproj`: −8 ObjC refs (4 `.h` + 4 `.m`), +5 Swift refs (new
  `NativeEventsTracking/ClickTracking` group under the Swift `PBMCore` group).

### Deleted (8 files)

`PBMExternalLinkHandler.{h,m}`, `PBMExternalURLOpenCallbacks.{h,m}`, `PBMExternalURLOpeners.{h,m}`,
`PBMTrackingURLVisitors.{h,m}`. Zero remaining references repo-wide (verified via `rg`).

### Build error encountered and fixed

First `buildPrebidMobile.sh` attempt failed:
```
PBMDeepLinkPlusHelper.m:42:5: error: unknown type name 'PBMTrackingURLVisitorBlock'
```
`PBMDeepLinkPlusHelper.m` uses the `PBMTrackingURLVisitorBlock` block-typedef type directly as a
local variable type, previously supplied transitively via `#import "PBMTrackingURLVisitors.h"`
(now deleted). Fixed by importing `PBMTrackingURLVisitorBlock.h` directly. Re-ran — succeeded.

### SwiftLint

0 errors on all 5 new files. 2 non-blocking `todo` warnings, carried over verbatim from the
original ObjC `// TODO:` comments in `TrackingURLVisitors.swift` — not a regression.

### Playbook updates

No new Gap — this step is a straightforward application of the existing S2.3-B (block typedefs
stay ObjC, ship structurally-matching Swift closure `typealias`es) and S4.3-A/S4.3-B (explicit
`@objc` on custom inits; leaf-before-consumer ordering) rules, plus the orphan-header retirement
rule (S2.3/S3.2) confirmed still correctly blocking the 4 block-typedef headers on
`PBMDeepLinkPlusHelper.m`.

- Orphan-header inventory: unchanged at 35 (the 4 block-typedef headers move closer to retirement
  once `PBMDeepLinkPlusHelper.m` itself is ported in a later step, but remain live for now).

## Test plan

- [x] `buildPrebidMobile.sh` — all 4 XCFrameworks succeeded (after the `PBMTrackingURLVisitorBlock.h`
  import fix)
- [x] `buildPrebidSPM.sh` — SPM build succeeded
- [x] `swiftlint` on all 5 new files — 0 errors, 2 non-blocking `todo` warnings (pre-existing text)
- [x] Repo-wide `rg`/grep sweep for the 4 deleted class names — zero remaining references
- [x] `plutil -lint` on `project.pbxproj` — OK
- [ ] `--latest --quick` — **could not get a clean signal locally**: `PrebidMobileTests` fails to
  build-for-testing with 758 `error:` lines, matching the documented pre-existing local-toolchain
  issue (`PrebidMobileTests` target can't build on local Xcode 26.x — ~790 `@_spi` scope errors,
  see `pr-phase-4-3.md`). **Confirmed identical on a clean `master` baseline** (`git stash` →
  re-ran the same command → same 758-error count, including the exact same two
  `PBMDeepLinkPlusHelperTest.swift:67,101` "cannot assign `MockUIApplication` to `(any
  PBMUIApplicationProtocol)?`" errors) — pre-existing, not introduced by this change. Needs CI
  (Xcode 16.4.0) to get a real pass/fail signal.
- [ ] `--latest` full suite — not run locally, same blocker as above; defer to CI.
