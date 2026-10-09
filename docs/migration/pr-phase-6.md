# [swift-migration] Phase 6: VAST cluster, AdLoadManager, transaction factories, VideoView

Suggested PR title: `[swift-migration] Phase 6: VAST cluster, AdLoadManager, transaction factories, VideoView`

Branch `swift-migration-phase-6` on top of `master` (`0f07bfa3`). Steps: **S6.1 – S6.9** (below). One PR, built by parallel agents in
separate worktrees and merged in dependency order.

## Scope boundary

Phase 6 ports the connected ObjC cluster that Phases 4 and 5 deferred (playbook S4.5-B, S5.x-scope), **except `PBMVideoCreative`**.

| Left in ObjC | Why | Where it goes |
|--------------|-----|---------------|
| `PBMVideoCreative.{h,m}` | subclasses `PBMAbstractCreative_Objc`, which lives in the ObjC SPM target `__PrebidMobileInternal` and is invisible to the Swift `PrebidMobile` target; it also needs `PBMOpenMeasurementWrapper`/`Session` (Phase 8) and `PBMAbstractCreative+Protected.h`. A composition wrapper would be a throwaway seam (S4.5-B) | Phase 7, with `PBMAbstractCreative`/`PBMHTMLCreative` |
| `PBMVastGlobals.{h,m}` | the remaining `NS_TYPED_ENUM` `PBMVastRequiredMode` string constants stay ObjC (S2.1-A) | cleanup list |

Do not ask to complete these here; see playbook "Phase 6 gaps" and "Hand-off: what Phase 7 inherits".

### The spike that reshaped the plan (S6.1-A)

The plan assumed an ObjC `PBMAdLoadManagerVAST` could subclass a Swift `AdLoadManagerBase`. **It cannot**: `PrebidMobile-Swift.h` marks every Swift class
`objc_subclassing_restricted`, so ObjC fails to compile `@interface PBMVastCreativeLinear : PBMVastCreativeAbstract` once the base is Swift. Every Swift base class
therefore moved in the same step as all of its ObjC subclasses. This is why the cluster moved in connected groups rather than per file.

## Steps

| Step | Contents | Why this order |
|------|----------|----------------|
| **S6.1** (wave 1A) | `VastGlobals` (`VastResourceType`, `VASTError`), `VastResourceContainer` protocol, `VastMediaFile`, `VastIcon`, `VastCreativeCompanionAdsCompanion`, `VastCreativeNonLinearAdsNonLinear` | leaves with no ObjC subclasses |
| **S6.2** (wave 1B) | `VideoView`, `VideoViewDelegate`, `VideoViewPlaybackState`; `PBMVideoView+pbmTestExtension.h` deleted (S3.1-C) | `PBMVideoView` has no ObjC subclass; its ObjC callers (`PBMVideoCreative.m`, `PBMMRAIDController.m`) go through the `@objc` surface |
| **S6.3** (wave 1C) | `AdLoadManagerProtocol` / `AdLoadManagerDelegate` as Swift `@objc` protocols; dead `PBMAdLoadManager+pbmTestExtension.h` deleted | prerequisite for the load-manager pair |
| **S6.4** (wave 2D) | `VastAbstractAd`, `VastInlineAd`, `VastWrapperAd`, `AdRequestResponseVAST` | subclass group moves whole (S6.1-A) |
| **S6.5** (wave 2E) | `VastRequester` (+ new `VastRequesterTest`) | leaf with Swift-only dependencies |
| **S6.6** (wave 3F) | `VastCreativeAbstract`, `VastCreativeLinear`, `VastCreativeCompanionAds`, `VastCreativeNonLinearAds`, `VastResponse`; the `AnyObject?` back-references from S6.4 retyped | subclass group + the aggregate that holds them |
| **S6.7** (wave 4G) | `VastParser` (`NSXMLParserDelegate`); `PBMVastParser+Private.h` replaced by `@testable` access | needs every model above it to be Swift |
| **S6.8** (wave 5H/5I) | `VastAdsBuilder`, `CreativeModelCollectionMakerVAST`; `PBMCreativeModelMakerResult.h` retired | consumers of the parser |
| **S6.9** (wave 6J) | `AdRequesterVAST` + `AdLoadManagerBase` + `AdLoadManagerVAST` (together: a cycle and a subclass), then `VastTransactionFactory` + `TransactionFactoryImpl`; `Factory.swift`'s `NSClassFromString` lookup removed; `MockPBMAdLoadManagerVAST` rewritten as a Swift subclass | last ObjC consumers (S4.3-B); fulfils S4.5-B |

## Parity evidence

- **`VastParser`** (the riskiest port): a throwaway dump of the full parsed model (printing `nil` and `""` differently) was captured from the **ObjC** parser on 23 inputs
  (12 fixtures + 9 synthetic documents for branches no fixture reaches + empty/non-XML data) and committed as literal expectations
  (`VastParserParityExpectations.swift`, checked by `VastParserParityTests`). The Swift port's dump of the same inputs was byte-identical (`diff -r`) before the ObjC was deleted. Playbook S6.x-G-A.
- Other ports are covered by the existing suites (`PBMVastLoader*`, `PBMVideoViewTest`, `CreativeModelCollectionMakerVASTTests`, `PBMAdRequesterVASTTest`, `PBMVASTFailToLoadTest`, `AdViewManagerTest`, …).
- Gap: cases where the **ObjC crashed or raised** cannot be in a parity dump; they are the deviations marked "forced" below.

## Behavior deviations (reviewer: please read)

Swift types forbid the ObjC behavior, or the ObjC behavior was a crash / nil-messaging accident. Full per-site tables were in the per-wave notes; the ones that can change observable behavior:

| # | Site | ObjC | Swift | Status |
|---|------|------|-------|--------|
| 1 | `VastParser`, a `Companion`/`NonLinear`/`Icon`/`MediaFile` element inside a creative of another class | unchecked C-cast; continued and later raised "unrecognized selector" | `as?`; logs the same error and returns | **forced**; malformed documents only |
| 2 | `VastParser`, `<Error>` as the document root | `subarrayWithRange` raised `NSRangeException` | ignored | **forced**; malformed documents only |
| 3 | `CreativeModelCollectionMakerVAST`, a wrapper ad as the first ad | unchecked `(PBMVastInlineAd *)` cast; crashed | returns the "No creative" error | **forced** |
| 4 | `VastResponse.flattenResponse`, nested flatten failure | went on with `nil` and `addObjectsFromArray:nil` (raised) | returns the error immediately | **forced**; the ObjC path was a crash |
| 5 | `VideoView.showMediaFileURL`, nil URL/data in Debug | `NSAssert` crash in Debug, log in Release | logs and returns in both | Debug-only difference |
| 6 | `VideoView.addFriendlyObstructions`, nil `btnLearnMore`/`progressBar` | forwarded `nil` to the OM session (it logged an error) | skips the absent view | **forced** (`OMSession` takes a non-optional view); one fewer error log |
| 7 | `VideoView.handleSkipDelay` | raw `dispatch_time_t` from `Functions` | `asyncAfter` with the delay clamped to `[0, 3e9]` s, NaN → 0 | equivalent; avoids the S2.1-C double-scaling trap |
| 8 | `VideoView` resource loader, `start + requestedLength` overflow | wrapped, then failed the `end > dataLength` check | `addingReportingOverflow`, same failure | found in review: plain `+` would have trapped |
| 9 | `AdLoadManager` `failedToLoad`, transaction parameter | `nil` from request/maker failure, real transaction from `transactionFailedToLoad` | `AdLoadManagerDelegate.loadManager(_:failedToLoad: Transaction?, error:)` keeps the Optional | same; note the mismatch with the non-optional `TransactionDelegate.transactionFailedToLoad` |
| 10 | `AdRequesterVAST.loadVASTURL` | declared only in the `.m`, no callers | ported as an internal func, still no callers | dead; kept so `VastRequester` keeps a user; cleanup list |
| 11 | `VastAbstractAd.identifier`/`adSystem`/`adSystemVersion`, `VastIcon.program`, `VastCreativeAbstract.requiredMode` | `nil` until assigned | `""` | equivalent on reachable paths (the parser always assigns) |
| 12 | `VastCreativeAbstract.adId` | Swift name `AdId` (`NS_SWIFT_NAME`) | `adId` | two tests updated; ObjC selector unchanged |
| 13 | Logging in all ported files | `PBMLogError`/`PBMAssert` macros | `Log.error` | message text identical; file/function prefix differs |

`@weakify`/`@strongify` → `[weak self]` only where the ObjC used them. A dead `@strongify` nil-check inside a synchronous block was dropped (S6.x-H-B).

### Pre-existing behavior reproduced, not fixed

- `VastAdsBuilder`: `requestsPending == 0` is read **outside** the serial queue, as in the ObjC. With concurrent wrapper responses the root completion could fire twice or not at all. Left as is (line-for-line port).
- `VastAbstractAd` and the other Vast models keep untyped `NSMutableArray` properties (S6.1-B); see Open items.

## `@_spi` / visibility

New types are `@objc(PBMFoo) @_spi(PBMInternal) public`; `TransactionFactoryImpl` and `VastTransactionFactory` are internal `final` classes with no `@objc` name (nothing looks them up by name; measured). `@objc(PBM…)` names on the other now-Swift-only classes are kept for runtime-name stability (S6.x-J-D); demotion belongs to S9.2.

## Files

- **Deleted:** 55 ObjC `.m`/`.h` files (`git diff --diff-filter=D master..HEAD`, before this docs commit).
- **Added:** 29 Swift files under `PrebidMobile/Swift/PrebidMobileRendering/` (+ new tests `VastRequesterTest`, `VastParserParityTests`, `VastParserParityExpectations`).
- **Remaining ObjC `.m` under `PrebidMobile/Objc`:** 48 on `master` → 25.
- **`Factory.swift`:** `TransactionFactoryType` and its `NSClassFromString("PBMTransactionFactory_Objc")` force-cast removed; `createTransactionFactory` builds `TransactionFactoryImpl` directly. No other lookup touched.
- **`project.pbxproj`:** edited only through the `xcodeproj` gem recipe; merge conflicts (all additive, one per merged wave) resolved by keeping both sides and re-stripping the deleted ObjC entries; no dangling build files, no references to missing files (checked with the gem after every merge); `plutil -lint` OK.
- **Bridging header:** no VAST / AdLoadManager / AdRequester / TransactionFactory lines remain except `PBMVastGlobals.h`; `PBMVideoCreative.h`, `PBMVideoCreative+PBMTestExtension.h` stay with `PBMVideoCreative`.

### Orphan headers: 36 → 28

Retired: `PBMAdLoadManagerDelegate.h`, `PBMAdLoadManagerProtocol.h`, `PBMCreativeModelMakerResult.h`, `PBMTransactionFactoryCallback.h`, `PBMVastResourceContainerProtocol.h`,
`PBMVideoViewDelegate.h`, `PBMVideoViewPlaybackState.h`, `PBMVastParser+Private.h`. Playbook table updated (re-measured with the `comm` snippet).
`PBMModalState.h` lost an importer (`PBMVideoView.m`); its remaining importers are all Phase 7 files.

## Open items for the reviewer

- **`PBMVideoCreative.h` re-declares the six `videoView…` delegate selectors** (it lost `<PBMVideoViewDelegate>` with the deleted header, and Swift tests call them on the concrete class). They go away when `PBMVideoCreative` is ported (Phase 7).
- **`NSMutableArray` retyping is not done** (about 246 sites in the Vast models, `VastParser`, `VastAdsBuilder`, `VastResponse` and 14 test files, and it would change the parity expectations). No ObjC code mutates them any more, so it is now possible: separate follow-up.
- SwiftLint: `type_body_length` warnings on `VastParser`, `VastAdsBuilder`, `CreativeModelCollectionMakerVAST` and `VideoView` (same as `BidRequesterImpl`/`AdViewManagerImpl` in earlier phases); `todo` warnings for TODO comments carried verbatim from the ObjC; `block_based_kvo` on `VideoView` (string key paths kept to preserve add/remove timing).
- `AdRequesterVAST.loadVASTURL` is dead (deviation 10).
- Playbook S5.x-scope's "ObjC subclassing a Swift base is not compiled" caveat is resolved (disproved, S6.1-A).

## Test plan

- [x] `buildPrebidMobile.sh` (clean `generated/`) — all 4 XCFrameworks built; "All 24 Swift interfaces typecheck" (Gap 6 check)
- [x] `buildPrebidMobilePackage.sh` — SwiftPM package build succeeded (also run after every merged wave; this is the check that catches Swift-cannot-see-ObjC-target breakage)
- [ ] `verifySPM.sh` — **not run**: documented as CI-only. Needs CI
- [ ] `buildPrebidSPM.sh` — **not run**: it builds the *published* packages, so it would not exercise this branch
- [x] `plutil -lint` on `project.pbxproj` — OK after every merge; `xcodeproj` gem check: no dangling build files, no references to missing files
- [x] `testPrebidMobile.sh --latest --quick` — 967 tests (baseline on `master`), 972 after wave 2, 973 after wave 5, 0 failures each time
- [x] `testPrebidMobile.sh --latest` (full, final tree) — **1385 tests, 0 failures** (the script runs with `-retry-tests-on-failure`; no failed-test lines in the log)
- [x] `testPrebidMobileAdapters.sh` — exit 0. GAM (10 tests) and AdMob (4 tests) suites passed; the MAX scheme ran **0 tests** (`PrebidMobileMAXAdaptersTests` has no test sources on `master` either, so this is not caused by this PR)
- [x] `VastParserParityTests` — Swift parser output matches the ObjC parser's captured output on 23 inputs
- [x] `swiftlint` on every new file — 0 serious violations; warnings listed under Open items
- [ ] Manual playback check of a VAST video ad in the demo app — **not done**; `VideoView` (AVPlayer/KVO/resource loader) is covered by `PBMVideoViewTest`/`PBMVideoViewPlaybackStateTest` and the reviewer's line-by-line comparison, but not by a device run. Recommended before merge
