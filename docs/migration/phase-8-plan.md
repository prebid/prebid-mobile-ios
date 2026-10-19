# Phase 8 (OMSDK) — execution plan

> Planning document, written before Phase 8 starts, on `master` = `31cf748d` (Phase 7 / #1402).
> The executing agent writes `docs/migration/pr-phase-8.md` as it works — this file is the brief, not the record.
> Read `docs/migration/playbook.md` and `docs/migration/pr-phase-7.md` first.

## Context

Phases 0–7 are merged. **9 `.m` files remain** under `PrebidMobile/Objc`: the five-file OMSDK cluster
plus four unrelated leftovers. Phase 8 ports the OMSDK cluster and deletes the one throwaway seam
Phase 7 added (`Factory.openMeasurementWrapper`), which the Phase 7 doc explicitly marked for deletion here.

On parallelism: the OMSDK cluster is a **strictly linear dependency chain**, so splitting it across
agents would create merge churn without saving time. Three genuinely independent units sit beside it
and can run concurrently. Hence: **a serial chain owned by one agent, two independent side tracks, and
a read-only review gate** — the structure Phases 6 and 7 used successfully.

### What makes Phase 8 unlike Phase 6/7

| | Phase 6/7 | Phase 8 |
|---|---|---|
| Size | 55 / 42 files deleted | ~690 lines, 5 `.m` + 4 `.h` |
| Hazards (S6.x-K-A, S7.1-B, S7.2-A/D) | many | **zero** — grepped all five files: no `@try/@catch`, no `NSException`, no `hasPrefix`/`containsString`, no `-intValue`/`-boolValue` on untyped values, no unchecked integer arithmetic |
| Blocker | ObjC-subclasses-Swift (S6.1-A) | **SPM manifest wiring** (below) |
| Real risk | behavioural parity | build-system wiring + two nullability lies |

## Verified by probe (not assumed)

1. `import OMSDK_Prebidorg` **typechecks from Swift** (iOS 15 simulator target); `OMIDPrebidorgSDK.versionString()` resolves. The xcframework ships a real Clang modulemap.
2. A **Swift SPM target can depend on the OMSDK binary target** with an ObjC target layered on top — built a throwaway package in exactly that shape: `** BUILD SUCCEEDED **`.
3. Plain `import` adds `import OMSDK_Prebidorg` to the emitted `.swiftinterface`; `internal import` keeps it out but needs an experimental flag on a podspec pinned at `swift_version 5.0`. **Decision: plain import, OMID types kept `internal`/`private`.**

## The actual blocker: one manifest edit in two files

`Package.swift:34-56` and `PrebidMobile/Package.swift:19-39` — binary target `PrebidMobileOMSDK` is a
dependency of `__PrebidMobileInternal` (ObjC) **only**; the Swift `PrebidMobile` target has no
dependencies at all. Fix: add `dependencies: ["PrebidMobileOMSDK"]` to the `PrebidMobile` target in
**both** manifests (`scripts/syncSPM.sh:25` ships the inner one to consumers).

**`scripts/buildPrebidMobilePackage.sh:39-45` passes the OMSDK slice to clang only** (`-Xcc -F`).
Add the matching `-Xswiftc -F -Xswiftc "${PWD}/${OMSDK_SLICE}"`. Per S7.1-D only the SPM build catches
this — Xcode and CocoaPods stay green, so **missing it is a guaranteed CI failure**.

Xcode and CocoaPods need **no change**: one combined `PrebidMobile` target already links the
xcframework (`project.pbxproj:1532-1543`; podspec `vendored_frameworks` + `-framework OMSDK_Prebidorg`).

## Dependency shape — why the chain is serial

```
Factory.openMeasurementWrapper  (Factory.swift:70-78)  <- the Phase 7 seam, deleted in wave 3
   └─> Wrapper ──constructs──> Session ──constructs──> EventTracker
                                  └────calls────> FriendlyObstructionTypeBridge (leaf)
OMSDKVersionProvider_Objc  — fully independent leaf (30 lines, 1 line of real code)
```
No cycles. Bottom-up order: Bridge → EventTracker → Session → Wrapper.
ObjC only ever *constructs* these, never subclasses — so S6.1-A is not a blocker and the chain can be
ported incrementally with the remaining ObjC reaching the Swift types through `SwiftImport.h`.

## Two correctness bugs the port must handle (not stylistic)

1. **`describeFriendlyObstructionPurpose:` is `nonnull` but returns `nil`.**
   `PBMOpenMeasurementFriendlyObstructionTypeBridge.m:52-53` — the `default:` case returns nil inside
   `NS_ASSUME_NONNULL`. The existing test already defends against nil. **The Swift port must return
   `String?`** or it traps (S3.1-H / S7.3-A). Preserve `"Learn More  button"` — double space, byte-for-byte.
2. **`initWithContext:configuration:` declares `nonnull` and has no return type**, yet sets `self = nil`
   on failure (`PBMOpenMeasurementSession.m:46`); all three wrapper call sites nil-check it.
   **Swift must be `init?(context:configuration:)`.**

Also: `NSError *sessionError;` is declared uninitialised and never assigned, then logged
(`PBMOpenMeasurementWrapper.m:140-143, 187-190, 244-247`) — port as a plain failure log, record as a deviation.

## Wave plan

Each agent works in its own git worktree off `swift-migration-phase-8` and merges in order.
Per-agent brief: read the playbook first; follow the per-class steps and the validation checklist;
record new gaps as `S8.x-<letter>`.

### Wave 0 — pilot (blocks everything; one agent)
`OMSDKVersionProvider` is the ideal pilot: 30 lines, one line of real code, zero dependents.
- Both `Package.swift` files + the `buildPrebidMobilePackage.sh` flag.
- Port `OMSDKVersionProvider.m` → Swift; delete `Factory.OMSDKVersionProviderType` (`Factory.swift:155-159`) and the `OMSDKVersionProvider` protocol; `Prebid.swift:90-92` calls `OMIDPrebidorgSDK.versionString()` directly.
- **Gate — do not start wave 1 until all four pass:** `buildPrebidMobilePackage.sh`, `buildPrebidMobile.sh` (incl. the `.swiftinterface` typecheck), `pod install` + Xcode build, and a check that no OMID type leaked into any `.swiftinterface`.

### Wave 1 — three tracks in parallel

**Track A (serial, one owner) — the OMSDK chain.** Port in order: `FriendlyObstructionTypeBridge` →
`EventTracker` → `Session` → `Wrapper`. Keep every OMID type `internal`/`private`. Classes must stay
non-`final` and subclassable from tests until wave 3 rewrites the mocks.

**Track B (independent) — `CreativeViewabilityTracker` + `Prebid+TestExtension`.** One unit: the
tracker is the category's only importer. **No OMSDK involvement.** All seven dependencies are already
Swift. Retires orphan headers `PBMScheduledTimerFactory.h` and `PBMTimerInterface.h`, and replaces
`ViewExposureChecker.swift:43`'s KVC string with a typed read.

**Track C (independent) — dead code + `PBMMRAIDConstants`.** Delete `PBMDeferredModalState.m`,
`DeferredModalState.swift` and the `ModalManager` hooks (`ModalManager.swift:30, 61-68, 91-96`) —
verified dead: `pushDeferredModal` has no callers and no `NSClassFromString` lookup exists. Move the
three `NS_TYPED_ENUM` groups into `MRAIDConstants.swift` and update the 7 test files. Also delete the
dead `WebView.addFriendlyObstructions(to:)` (`WebView.swift:927-931`, empty) and collapse `WebView_Protocol`.

> **Only shared file: `Factory.swift`** — tracks A and B touch disjoint regions (`:73`/`:158` vs `:120-121`).
> `project.pbxproj` conflicts are additive; resolve as in Phase 6/7 (keep both sides, re-strip by name,
> edit only via the `xcodeproj` gem, `plutil -lint` after each merge).

### Wave 2 — independent review gate
A **read-only** agent given only the diff (the Phase 7 pattern that caught two real bugs). Focus:
the two nullability lies above, OMID leakage into `.swiftinterface`, mock-signature drift, and
`agents/review/SKILL.md`'s migration checklist. Fix findings before wave 3.

### Wave 3 — seam deletion and test realignment (track A owner)
- Delete `Factory.openMeasurementWrapper` (`Factory.swift:70-78`); `TransactionImpl.swift:40` reads the Swift singleton — keep the eager evaluation point in `init`.
- Restore typed checks at the three S7.3-C sites: `HTMLCreative.swift:263`, `VideoCreative.swift:165`, `AbstractCreativeImpl.swift:506`.
- Delete bridging-header lines 38-46 and the three `+pbmTestExtension.h` files; keep `OMIDContext+pbmTestExtension.m` (the `NSBundle` swizzle is test infra).
- Rewrite the three mocks as `OMSession`/`OMSessionWrapper` conformers. **Hardest item:** `PBMOpenMeasurementWrapperTest.swift:22-26` adds an `@objc var partnerName` to the ObjC class via a Swift extension purely so `PBMOpenMeasurementWrapperErrorMock` can override it. **No Swift equivalent — redesign as injection** (e.g. an internal `partnerName` property set on the instance).
- Port `PBMOpenMeasurementSessionObjcTest.m` and `PBMOpenMeasurementWrapperObjcTest.m` to Swift.
- Reconcile three spellings of `injectJSLib` (`throws` in the mock vs `NSErrorPointer` in the protocol vs `error:` in ObjC) and `initializeWebViewSession(UIView)` vs `(WKWebView)`.

## Parity evidence

Targeted, not blanket — this cluster has none of the hazards that justified the Phase 6/7 dumps.
Capture one throwaway ObjC dump of `FriendlyObstructionTypeBridge`'s two pure functions over all 7
purpose cases **plus out-of-range values** (that is where the nil bug lives), commit as literal
expectations, re-run against the Swift port (S6.x-G-A). The stateful classes need a live OMID session
and are covered by the existing suites.

## Verification

Run after **every** merged wave, not once per phase:
```bash
./scripts/buildPrebidMobilePackage.sh     # the ONLY check that catches the SPM wiring (S7.1-D)
./scripts/buildPrebidMobile.sh            # 4 XCFrameworks + "All N Swift interfaces typecheck"
./scripts/testPrebidMobile.sh --latest    # FULL plan — see the warning below
```

> **The PR test plan gives zero signal here.** `PrebidMobilePRTests.xctestplan` skips *every* OMSDK and
> viewability class (lines 179, 241-242, 388-407). `--quick` would pass with the cluster completely
> broken. **Phase 8 must validate with the full plan.**

Also: `./scripts/testPrebidMobileAdapters.sh`; `swiftlint`; `plutil -lint` on `project.pbxproj` plus the
`xcodeproj` gem check after each merge; confirm no `.swiftinterface` gained an OMID type.

**Manual demo-app check — the gap Phase 7 left open.** OMSDK is viewability measurement: unit tests
cannot prove a real session starts and reports. Run an HTML banner, an interstitial and a VAST video
in the demo app and confirm sessions are created. Recommended before merge.

## Deliverables

- `docs/migration/pr-phase-8.md` — scope boundary, deviations table, test-plan checklist (Phase 6/7 format).
- `docs/migration/playbook.md` — new `## Phase 8 gaps (S8.x)` section, the hand-off section rewritten for Phase 9, and the orphan-header table re-measured with the `comm` snippet.
- Delete this planning file once `pr-phase-8.md` supersedes it (the playbook's "do not leave superseded drafts behind" rule).

## Expected end state

`PrebidMobile/Objc` **empty of `.m` files** (9 → 0) if all three tracks land; orphan headers down to the
four shared-infrastructure ones (`SwiftImport.h`, `PBMMacros.h`, `Log+Extensions.h`, `PBMConstants.h`),
which S9.x retires once the ObjC tree is gone. Phase 9 then does visibility demotion (Gap 4/6, S9.2),
the remaining `Factory` lookups, `NSMutableArray` retyping (S6.1-B), and `@objc(PBM…)` name removal.
