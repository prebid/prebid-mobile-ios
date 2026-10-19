# [swift-migration] Phase 8: OMSDK wrappers, viewability tracker, remaining ObjC leftovers

Suggested PR title: `[swift-migration] Phase 8: OMSDK wrappers, viewability tracker, remaining ObjC leftovers`

Branch `swift-migration-phase-8` on top of `master` (`31cf748d`, after Phase 7 / #1402). Steps: **S8.0 – S8.3** (below). One PR, built by parallel agents in
separate worktrees and merged in dependency order (wave 0, wave 1 tracks A/B/C, wave 3), with an independent review between waves 1 and 3.

**Result: `PrebidMobile/Objc` has no `.m` files left (9 → 0).** Orphan headers: **17 → 14**.

## Scope boundary

Phase 8 ports everything the Phase 7 hand-off assigned to it, plus the four unrelated leftovers. **Nothing is deliberately left behind in `.m` form.**
What remains in `PrebidMobile/Objc` is 14 headers (list in the playbook), retired in Phase 9. The ObjC SPM target `__PrebidMobileInternal` still exists in
both `Package.swift` files with no sources; removing it is Phase 9 (see "Build system").

## Steps

| Step | Contents | Why this order |
|------|----------|----------------|
| **S8.0** (wave 0) | SPM wiring (`PrebidMobileOMSDK` added to the Swift `PrebidMobile` target in both `Package.swift` files, `-Xswiftc -F` in `buildPrebidMobilePackage.sh`) and `OMSDKVersionProvider` (protocol, ObjC class and `Factory` lookup deleted; `Prebid.omsdkVersion` calls `OMIDPrebidorgSDK.versionString()`) | the real blocker was the manifest, not the code; a 30-line port proves the wiring before the chain depends on it |
| **S8.1** (track A) | `OpenMeasurementFriendlyObstructionTypeBridge` → `OpenMeasurementEventTracker` → `OpenMeasurementSession` → `OpenMeasurementWrapper` | strictly linear: the wrapper constructs the session, which constructs the tracker and calls the bridge. One owner, one commit per class |
| **S8.2** (track B) | `CreativeViewabilityTrackerImpl` + `Prebid.forcedIsViewable` (`Prebid+TestExtension.{h,m}` deleted); `PBMScheduledTimerFactory.h`, `PBMTimerInterface.h` retired | independent of OMSDK (no OMID import); the tracker was the category's only importer |
| **S8.2** (track C) | `PBMDeferredModalState` (dead code), `PBMMRAIDConstants` (`NS_TYPED_ENUM` residue → `MRAIDAction`/`MRAIDPlacementType`/`MRAIDFeature`), empty `WebView.addFriendlyObstructions(to:)`, `WebView_Protocol` | independent; deletions plus 7 test files |
| **S8.3** (wave 3, after review) | `Factory.openMeasurementWrapper` seam deleted; the four OMSDK classes demoted to `internal`; transitional `@objc` seams removed; mocks rewritten as protocol conformers; `PBMVoidBlock.h` deleted; PR test plan skip list aligned | needs every ObjC user gone first, so it ran last |

## Why the parallelism was limited

The OMSDK chain is serial, so only tracks B and C ran beside it. The agents also share one machine and one simulator name: `testPrebidMobile.sh` deletes and
recreates `iPhone-17-Pro-PrebidMobile`, and the first wave-1 test runs collided on it (`No matching device`, mass failures that were not regressions). A lock
around the test step fixed that; builds need none. Judge any wave-1 per-track test result with that in mind; the authoritative runs are the ones on the merged tree.

## Parity evidence

Targeted, not blanket: the cluster has none of the hazards that justified the Phase 6/7 dumps (no `@try/@catch`, `NSException`, `hasPrefix`/`containsString`,
`-intValue` on untyped values, or unchecked integer arithmetic; checked by grep on all five files).

| Test | Inputs | Result |
|------|--------|--------|
| `OpenMeasurementBridgeParityTests` (`obstructionType(of:)`, `describe`) | raw values 0–8, 99, `UInt.max`; ObjC output frozen with a throwaway clang harness before the class was deleted | identical. `6, 7, 8, 99, UInt.max` → type `.other`, description `nil`; raw 4 is `"Learn More  button"` (double space) |

The stateful classes need a live OMID session and are covered by `PBMOpenMeasurementWrapperTest`, `OpenMeasurementSessionTests`, `PBMOpenMeasurementEventTrackerTest`
and the creative suites. Out-of-range raw values cannot exist in a Swift enum, so the parity test maps them to `.other`/`nil` in its harness.

## Defects found in review and fixed in this PR

An independent read-only reviewer, given only the diff, found no BLOCKER or HIGH defect. Two things it flagged were fixed in wave 3:

- **Duplicate friendly obstructions logged an error the ObjC never logged (M3).** `OMIDAdSession.addFriendlyObstruction` documents `NO` *without* an error object
  for "session finished" and "already added". The ObjC logged only when `error != nil`; Swift's `try` turns the bare `NO` into `Foundation._GenericObjCError`
  (code 0, empty userInfo), so every repeat add (MRAID resize/expand re-adds the same views) logged. The Session now returns silently on that domain and logs
  everything else; a genuine OMID error (`com.omid.library`, code 1512 for a 51-character reason) is still logged. Two tests use a real OMID session.
- **The OMSDK classes were `public` for a reason that no longer held (M1/M2).** They were left `public` with `@objc` seams only while ObjC users existed; the review
  verified none remain. They are `internal` now and the seams (`init(omidContext:omidConfiguration:)`, `init(omidSession:)` with a force-cast, `obstructionTypeRawValue`) are gone.

## Behavior deviations (reviewer: please read)

| # | Site | ObjC | Swift | Status |
|---|------|------|-------|--------|
| 1 | `FriendlyObstructionTypeBridge.describe` | annotated `nonnull`, returned `nil` in `default:` | returns `String?`, `nil` only for `.purposesCount` | verified (parity test) |
| 2 | `OpenMeasurementSession.init` | `initWithContext:configuration:` declared `nonnull`, set `self = nil` on failure | failable `init?`; the three wrapper call sites `guard let` | **forced** |
| 3 | `OpenMeasurementWrapper` session/OMSDK failure logs | logged an `NSError` that was declared but never assigned (`(null)`) | plain failure log (the real cause is logged where it is known) | reasoned, not run |
| 4 | `injectJSLib(nil)` | returned an error for nil HTML | non-optional parameter; unreachable from Swift, `testInjectNilHTML` dropped with the ObjC test | **forced** |
| 5 | `OpenMeasurementWrapper.partnerName` | read-only property plus a test-only category | injected `let` via `init(partnerName:)` | **forced**; a Swift extension cannot add an overridable member to a test subclass seam |
| 6 | `OpenMeasurementWrapper` partner | non-optional, always set | `OMIDPrebidorgPartner?`; a failed partner init gives a nil session | reasoned |
| 7 | `EventTracker.trackVolumeChanged(_:deviceVolume:)` | ignored `deviceVolume` | ignores it (kept, commented) | kept as-is, untested |
| 8 | `Session.deinit` | `dispatch_after` 1 s capturing the local view, then `stop` | `withExtendedLifetime` inside `asyncAfter` on the main queue | reasoned, **not run** (timing untested) |
| 9 | `addFriendlyObstruction` duplicate add | silent | silent (fixed, see above) | verified with a real session |
| 10 | `CreativeViewabilityTracker`, creative without a view | non-nil checker over a nil view → zero exposure | `checker` is `nil` → zero exposure | reasoned, same observable result |
| 11 | `CreativeViewabilityTracker` poll interval | `adConfiguration.pollFrequency` (nil messaging → 0) | `adConfiguration?.pollFrequency ?? 0` | reasoned |
| 12 | `CreativeViewabilityTracker` exposure callback | cast to the ObjC class **before** `isKindOfClass:` | `as?` once; `[weak creative]` as the ObjC `@weakify` | covered by tests |
| 13 | `forcedIsViewable` | ObjC category on `Prebid` plus a KVC string read in `ViewExposureChecker` plus a third copy in the test extension | one `#if DEBUG` `Prebid.forcedIsViewable` (same `UserDefaults` key) | reasoned; DEBUG-only, not compiled in Release |
| 14 | Typed OMSDK gates (S7.3-C) | `isKindOfClass:[PBMOpenMeasurementSession class]` | **kept the non-nil `OMSession` check** | judgement call, see below |
| 15 | MRAID constants | `NS_TYPED_ENUM` `PBMMRAIDAction` etc. | `MRAIDAction`/`MRAIDPlacementType`/`MRAIDFeature` structs, same string values; production literals replaced by them | verified by diff (no literal changed) |
| 16 | Logging | `PBMLog*` macros | `Log.*` | message text identical, file/function prefix differs |

### Judgement call: the S7.3-C gates stay non-nil checks

The Phase 7 hand-off said the creatives' non-nil session check "can regain a typed check" once the wrapper is Swift. It was tried and **not done**: the mocks are now
`OMSession` conformers that are not `OpenMeasurementSession`, so a typed `as? OpenMeasurementSession` gate would make `testMeassurementSession` (HTML and video) and the
`onAdDisplayed` tracker registration stop exercising their paths. The only production producer is still `OpenMeasurementWrapper`, so behavior is equivalent in
production; the check is weaker than the ObjC's only for a hypothetical third `OMSession` conformer.

### Surface changes (all `@_spi(PBMInternal)` or private ObjC headers; none is documented public API)

`PBMDeferredModalState`, `ModalManager.pushDeferredModal`/`deferredModalState`, `WebView_Protocol` (`@objc(PBMWebView_Protocol)`), `WebView.addFriendlyObstructions(to:)`
(`@objc(addFriendlyObstructionsToMeasurementSession:)`), the `PBMMRAIDAction`/`PlacementType`/`Feature` constants, and the ObjC `PBMOpenMeasurement*` names. The public
`Prebid.omsdkVersion` is unchanged.

## Build system

- **`Package.swift` and `PrebidMobile/Package.swift`:** `PrebidMobileOMSDK` is now a dependency of the Swift `PrebidMobile` target (the inner manifest is the one `syncSPM.sh` ships).
- **`scripts/buildPrebidMobilePackage.sh`:** passes the OMSDK slice to `swiftc` (`-Xswiftc -F`) as well as clang, **and now builds the `PrebidMobile` target explicitly.** With no `.m`
  files left, `__PrebidMobileInternal` has no sources, SwiftPM skips its `PrebidMobile` dependency, and the old single `swift build --target __PrebidMobileInternal` passed in ~0.2 s
  while compiling nothing. This was found during the merge, not by CI; it is the one check that exists to catch SPM wiring.
- **Interfaces:** the plain `import OMSDK_Prebidorg` appears in `PrebidMobile.swiftinterface` (decision: plain import, OMID types internal). No OMID **type** appears in any public
  signature (checked: the only `OMID`-containing lines besides the import are unrelated SDK names, `Signals.Api.OMID_1` and `ORTBSourceExtOMID`).
- **`project.pbxproj`:** edited only through the `xcodeproj` gem. Merging tracks B and C conflicted (additive); resolved by keeping the merged result and re-applying each track's removals/additions by name through the gem. After every merge: `plutil -lint` OK, no missing files, no build files without a reference.
- **`__PrebidMobileInternal`** still exists in both manifests with no sources. It builds (exit 0) but is dead; remove it in Phase 9.
- **CocoaPods/Xcode:** no change needed (one combined target already links the xcframework).

## `PrebidMobilePRTests.xctestplan`

The PR subset used to skip **every** OMSDK and viewability class, so a PR could break the cluster and still go green. Wave 3 removed the stale entries (the renamed bridge test,
the deleted ObjC tests, all of `PBMOpenMeasurementWrapperTest`), so these now run on PRs: `OpenMeasurementFriendlyObstructionTypeBridgeTest`, `OpenMeasurementBridgeParityTests`,
`OpenMeasurementSessionTests`, `PBMOpenMeasurementWrapperTest`. They are fast and use the mocked library manager (no network). Still skipped: `PBMOpenMeasurementEventTrackerTest`,
`PBMCreativeViewabilityTrackerTest`, the creative `testMeassurementSession` variants and `PBMAbstractCreativeTest.testOpenMeasurement`. The PR-subset count in `AGENTS.md` (694) is now
stale; the agent estimated about 708 but did not measure it.

## Files

- **Deleted vs Phase 7:** 24 files under `PrebidMobile` and `PrebidMobileTests` (9 `.m`, the OMSDK/viewability/MRAID/`Prebid+TestExtension` headers, three `+pbmTestExtension.h`, two ObjC tests, `DeferredModalState.swift`, `OMSDKVersionProvider.swift`).
- **Added:** 8 files (4 OMSDK Swift classes, `CreativeViewabilityTrackerImpl.swift`, `Prebid+ForcedViewability.swift`, 3 tests with the frozen expectations).
- **Bridging header:** all OMSDK imports and `PBMMRAIDConstants.h` removed.
- **Orphan headers: 17 → 14.** Retired: `PBMScheduledTimerFactory.h`, `PBMTimerInterface.h`, `PBMVoidBlock.h`. See the playbook for the 14.

## Open items for the reviewer

- **Manual check in the demo app: not done.** OMSDK is viewability measurement; unit tests cannot prove a real session starts and reports against a live creative. No HTML banner, interstitial or VAST video was run. **Recommended before merge** (Phase 7 left the same gap).
- **Deviations 3, 8, 10, 11, 13** are reasoned from the ObjC, not run against it. The 1 s `deinit` retention (8) has no test.
- **`testFetchDemandResumeAutoRefresh`** failed its first attempt and passed on retry in most runs (every track and the merged A+B+C run), but passed first time on the final-tree run. It depends on the network and an 800 ms timer and touches no code changed here, but a full baseline on `31cf748d` was not run to prove it predates this PR.
- **A test-host crash was seen once** in a track-B run under heavy shared-simulator load (`PBMHTMLCreativeTest.creativeDidDisplay` firing after its expectation was released, via a timer). It was not reproducible (`BaseInterstitialAdUnitTest` ran 6/6 clean alone); the tracker's start/stop/deinit lifecycle is identical to the ObjC. Not ruled out, not confirmed.
- The `PBMOpenMeasurementEventTrackerTest` and `PBMCreativeViewabilityTrackerTest` classes stay out of the PR subset.
- `OMIDContext+pbmTestExtension.m` (an `NSBundle` swizzle that avoids an OMSDK crash in tests) is the last ObjC file in the test target's OMSDK area and must stay.

## Test plan

- [x] `buildPrebidMobile.sh` — 4 XCFrameworks built; "All 24 Swift interfaces typecheck" (run on wave 0, on the merged A+B+C tree, and again on the final tree)
- [x] `buildPrebidMobilePackage.sh` — clean build of the merged tree compiles **394 files**, exit 0 (after the script fix above)
- [x] `testPrebidMobile.sh --latest` (full) on the **final** merged tree: **1410 tests, 0 failures, no retries**, `TEST EXECUTE SUCCEEDED`. This is the authoritative run: nothing else was using the machine or the simulator
- [x] `testPrebidMobile.sh --latest` (full) on wave 0: 1408 tests, 0 failures; on the merged A+B+C tree: 1411, `TEST EXECUTE SUCCEEDED` (one first-attempt failure, `testFetchDemandResumeAutoRefresh`, passed on retry)
- [x] Wave 3 (worktree): 1410 tests, 0 failures. Net −1: the seam-comparison test is gone, two `OpenMeasurementSessionTests` replace one ObjC-replacement test
- [x] Parity test (`OpenMeasurementBridgeParityTests`) — Swift output matches the ObjC's frozen output
- [x] Review gate — independent read-only review of the diff; no BLOCKER/HIGH
- [ ] `testPrebidMobile.sh --latest --quick` (PR subset) — **not run**; its skip list changed in this PR
- [ ] `verifySPM.sh`, `buildPrebidSPM.sh` — **not run**: CI-only, and the latter builds the published packages
- [ ] `testPrebidMobileAdapters.sh`, `swiftlint` — **not run**
- [ ] **Manual demo-app OMSDK check** — **not done** (see Open items)
