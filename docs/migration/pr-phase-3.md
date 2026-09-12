# [swift-migration] Phase 3 — Networking parameter builders

Branch `swift-migration-phase-3`, on `master` (`ef8a4a35`). Continues the migration started in
[Phases 0–2](pr-phase-012.md). Lands **S3.1** and **S3.2** together (single dependency cluster:
`PBMParameterBuilderService.m` is the only non-test consumer of 7 of the 8 builders; splitting
would leave a non-compiling intermediate commit).

## Scope — what this PR does *not* cover

`Networking/Parameters/` is now empty of `.m` files, but two ObjC files remain elsewhere under
`Networking/`: `Tracking/PBMTrackingRecord.{h,m}` (consumers: `PBMVastAdsBuilder.m`,
`PBMAdRequesterVAST.m`) and `URLBuilding/PBMURLComponents.{h,m}` (consumer: `PBMVastRequester.m`).
Whether they're S3.3 or a later phase is not decided here (resolved in
[pr-phase-3-3.md](pr-phase-3-3.md) — the `PBMTrackingRecord` consumer claim above turned out stale).
Everything else the playbook assigned to Phase 3 — the `PBMParameterBuilder` protocol, the 8
builders, the service, and their 3 support types — is done.

## Summary

### S3.1 — Parameter builders (8 classes + 3 support types)

`Networking/Parameters/` → Swift, same relative path.

| ObjC | Swift | Notes |
|------|-------|-------|
| `PBMParameterBuilderProtocol.h` | `ParameterBuilder.swift` | `@objc(PBMParameterBuilder) public protocol`, `@objc(buildBidRequest:) func build(_:)` |
| `PBMBasicParameterBuilder` | `BasicParameterBuilder.swift` | non-optional `let` properties (S3.1-C) |
| `PBMGeoLocationParameterBuilder` | `GeoLocationParameterBuilder.swift` | |
| `PBMAppInfoParameterBuilder` | `AppInfoParameterBuilder.swift` | |
| `PBMDeviceInfoParameterBuilder` | `DeviceInfoParameterBuilder.swift` | |
| `PBMNetworkParameterBuilder` | `NetworkParameterBuilder.swift` | `CTCarrier` read stays `#available`-gated off on iOS 16+ |
| `PBMUserConsentParameterBuilder` | `UserConsentParameterBuilder.swift` | |
| `PBMSKAdNetworksParameterBuilder` | `SKAdNetworksParameterBuilder.swift` | non-`final`; `skAdNetworkIds()` stays overridable for the test mock |
| `PBMORTBParameterBuilder` | `ORTBParameterBuilder.swift` | not a `ParameterBuilder`; terminal JSON-serialization step |

Support types pulled along: `PBMBundleProtocol.h` → `BundleProtocol.swift` (deliberately not
`@objc` so `MockBundle` can conform — Gap S3.1-B; `extension Bundle: BundleProtocol {}` supplies
the real impl); `InternalUserConsentDataManager.{h,m}` → `.swift` (read by `BasicParameterBuilder`,
`UserConsentParameterBuilder`).

### S3.2 — `PBMParameterBuilderService` → `ParameterBuilderService.swift`

Static entry point assembling the 7 builders over a fresh `ORTBBidRequest`, merging arbitrary ORTB
config, handing off to `ORTBParameterBuilder.buildOpenRTB(for:)`. Both public overloads keep their
ObjC selectors (`buildParamsDictWithAdConfiguration:`, `…:extraParameterBuilders:`) — `PBMBidRequester.m`
still calls them. `createORTBBidRequest(with:)` ported 1:1 including all `Targeting` reads.

### Consumer re-pointing

- `PBMBidRequester.m` — dropped the service header import.
- `PBMPrebidParameterBuilder.h` — gained `NS_SWIFT_NAME(build(_:))` on `buildBidRequest:` (conforms
  to the now-Swift protocol but doesn't inherit its Swift name — Gap S3.1-F).
- `PrebidMobileTest-Bridging-Header.h` — 12 imports removed.
- `project.pbxproj` — 23 refs removed, 12 added (`xcodeproj` gem).

### Deleted (23 files)

10 `.m` (9 builders + `InternalUserConsentDataManager.m`), 12 private headers, and
`PBMBasicParameterBuilder+pbmTestExtension.h` (can't re-open a Swift class — Gap S3.1-C).

### Deliberate behavioural divergences (final state, corrected across review)

1. **`InternalUserConsentDataManager.gppSID`** — non-optional `[NSNumber]` via `compactMap` (ObjC
   crashed on an unparseable component). Parse via `String.strictNumberValue` (`Int64(self).map(NSNumber.init)`),
   not `NumberFormatter` (locale-sensitive: accepts grouping separators/decimals the GPP spec
   doesn't define). **Two-directional, not a pure narrowing**: whitespace-padded (`" 5"`) is now
   rejected (narrower), a leading `+` (`"+5"`) is now accepted (wider) — both covered by dedicated
   tests. Same swap underlies every `strictNumberValue` call in `SkadnParametersManager`.
2. **`SKAdNetworksParameterBuilder.skAdNetworkIds()`** uses `compactMap` over the plist array,
   likewise skipping malformed entries instead of inserting `nil`; covered by
   `testSKAdNetworkIds_SkipsMalformedEntries` via `MockBundle.mockSKAdNetworkItems`.
3. **`ORTBParameterBuilder.buildOpenRTB(for:)` returns non-optional `[String: String]`**, `[:]` on
   the error path (ObjC's nullable signature always returned a dict in practice).
4. **`PBMAssert` nil-guards dropped** in all 8 builders (non-optional Swift parameters) — Gap
   S3.1-H: `PBMAssert` compiles out in Release (ObjC logged-and-continued on nil; Swift traps).
   Safe because all 8 builders are constructed only by `ParameterBuilderService`, in Swift, with
   non-optional arguments.
5. ~~**`NSMutableDictionary` nil-assignment semantics.**~~ **Withdrawn.** Verified: `dict[key] = nil`
   removes the key identically in ObjC and Swift for single-level optionals (Gap S3.1-A withdrawn).
6. **`AppInfoParameterBuilder` type-checks the two `CFBundle*Name` reads** (`as? String` vs. ObjC's
   unchecked cast) — a mistyped `CFBundleDisplayName` now falls back to `CFBundleName` instead of
   propagating a type-punned object.

Everything else is a faithful line-for-line port of `PBMParameterBuilderService.m`,
`PBMBasicParameterBuilder.m`, `PBMDeviceInfoParameterBuilder.m` (inverted `lmt`, blank-IFA→`nil`/
zeroed-IFA→`ifv` fallbacks, iOS 14 `atts` override of `lmt`).

### Playbook updates

- 8 new gaps (**S3.1-A**…**S3.1-H**) + **S3.2-A**. Gap 4/Gap 6 corrected: `PBMPrebidParameterBuilder.m`,
  `PBMBidRequester.m`, `PBMBidResponseTransformer.m`, `PBMWebView.m` still consume ORTB Swift twins
  post-Phase-3 — demotion to `internal` stays deferred to S9.2.
- Orphan-header inventory added (39 headers with no matching `.m`, 2 already dead).

## CI flake fixed in passing — `SetupTests` user-agent seeding

First CI run failed `PBMBidRequesterTest` (×9) + one `PBMVastLoaderCheckForAds` case, all
`Asynchronous wait failed`. Not caused by this PR (`git diff` on that test file is empty). Root
cause: `PBMBidRequester` awaits `UserAgentService.shared.fetchUserAgent`, which spins up a
`WKWebView` with no timeout; on a cold runner WebKit's helper processes stalled ~2 minutes, so
every request-path test timed out until the UA resolved. Fix in `SetupTests.swift` (test bundle's
`NSPrincipalClass`): (1) seed the persisted user agent via `UserAgentDefaults` when empty, so
`fetchUserAgent` returns synchronously without touching WebKit; (2) keep a throwaway fire-and-forget
`WKWebView` for warm-up, since `UserAgentServiceTest.testMultipleCalls` relies on that side effect.
Verified against a cold-erased simulator: 9 previously-timing-out cases now pass in 1–75 ms.

## Notes for the reviewer

- `MockSKAdNetworksParameterBuilder` is `fileprivate` — an `internal` NSObject-derived test class
  emits into `<Module>Tests-Swift.h` and fails to compile against a non-`@objc` internal superclass
  from another module (Gap S3.1-E).
- `ParameterBuilderService` is not `@objcMembers` — one member takes a `BundleProtocol` (not
  ObjC-representable); the two bridged entry points carry explicit `@objc(selector:)` instead (Gap
  S3.1-D).
- `PBMAdLoadFlowController.h` and `PBMORTB_NotImplemented.h` are dead (zero importers) but left in
  place to keep the diff scoped; recorded in the playbook's orphan-header inventory.

## Test plan (final)

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks clean
- [x] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build clean
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — **812 tests, 0 failures, no retries** (final,
      post round 2; `testInvalidProperties` deleted along with the properties it tested)
- [x] `swiftlint --config .swiftlint.yml` — no new violations from this PR; one pre-existing
      error-level hit inherited 1:1 from the ObjC signature
      (`ParameterBuilderService.buildParamsDict` `function_parameter_count`), out of scope
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite, run before merge
- [ ] Reviewer: confirm the phase boundary in "Scope" — is `PBMTrackingRecord`/`PBMURLComponents` an S3.3?
- [ ] Reviewer: confirm divergences 1–4 and 6 above (5 is withdrawn)
- [ ] Reviewer: `BasicParameterBuilder.sdkConfiguration` is dead (already dead in ObjC too) but
      removing it touches 13 test call sites + the `buildParamsDict` signature — separate commit if wanted
- [ ] Reviewer: confirm the playbook's orphan-header inventory against the phase plan

### Note on the two new tests and the PR test plan

`InternalUserConsentDataManagerTests` is skipped wholesale by `PrebidMobilePRTests.xctestplan`
(pre-existing class-level exclusion), so its two new cases (`testIABGPPSID_Malformed`,
`testIABGPPSID_EmptyString`) run in the full plan only — no plan edit made.
`SkadnParameterBuilderTest`'s two new cases are not skipped and run on every PR.

## Review history (rounds 1–3, all addressed)

**Round 1** (#1328): withdrew Gap S3.1-A (verified no real bug); fixed `buildOpenRTB(for:)`'s error
path to return `[:]`; added `gppSID` crash-to-skip regression tests and fixed a copy-paste test that
asserted the wrong property; added `skAdNetworkIds()` malformed-entry coverage via a new
`MockBundle` seam.

**Round 2** (#1328, 9 comments, all accepted): dropped unnecessary `@objcMembers`+`NSObject` from
`InternalUserConsentDataManager` (measured zero ObjC consumers); deduped `zeroedIFA`/
`String.kIFASentinelValue`; switched `gppSID` parsing off `NumberFormatter` (divergence 1); removed
a dead `regs.ext["gdpr"]` write in `BasicParameterBuilder` (owned by `UserConsentParameterBuilder`
later in the pipeline — required fixing one test helper that accidentally depended on the
duplicate); collapsed `BasicParameterBuilder`'s four mutable optionals to non-optional `let`s,
deleting `testInvalidProperties` with them; documented the `PBMAssert`-drop behaviour class as Gap
S3.1-H; documented the `AppInfoParameterBuilder` `as? String` divergence (6); deleted 12 unused
static key constants; extracted `ORTBGeo.setRoundedCoordinates(_:precision:)` to de-duplicate
coordinate rounding between `GeoLocationParameterBuilder` and `ParameterBuilderService`. Left
`BasicParameterBuilder.sdkConfiguration` (dead) for the reviewer to call — see open item above.

**Round 3** (#1328, 12 comments from a second reviewer, triaged into 3 migration-fidelity fixes +
9 acknowledged-and-deferred improvements — none were correctness blockers):
- Fixed: divergence 1 corrected from "narrowing" to "two-directional" with tests for both
  directions; `SKAdNetworksParameterBuilder`'s `adConfiguration` parameter un-loosened from
  `AdConfiguration?` back to non-optional (the deleted ObjC header was non-nullable); a literal `…`
  in the playbook's Gap S3.1-H grep fixed to `initWith` so the safety check actually matches.
- Deferred (real substance, follow-up issue): dual `user.ext["consent"]` writers (ObjC side outside
  this diff); test pipelines hand-copying the builder list; removing dead `sdkConfiguration`;
  `AppInfoParameterBuilder`'s unreachable publisher-name guard; ATT-comparison duplication with
  `Host.swift`.
- Deferred (doc-only): ownership comment on the builder array; `getObjectFromUserDefaults` style
  consistency; a hypothetical non-`@objc` regression test; documenting the "extras run last"
  guarantee.

Final re-verification after round 3: `-only-testing` re-run of the three touched test classes (0
failures), full quick suite unchanged at 812/0, `swiftlint` clean on touched files.
