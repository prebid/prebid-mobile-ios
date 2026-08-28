# [swift-migration] Phase 3 — Networking parameter builders

Branch `swift-migration-phase-3`, on top of `master` (`ef8a4a35`). Continues the ObjC → Swift
migration of `PrebidMobile/Objc/` started in [Phases 0–2](pr-phase-012.md).

This PR lands migration steps **S3.1** and **S3.2** together: the eight parameter builders and
the service that drives them are a single dependency cluster — `PBMParameterBuilderService.m` is
the only non-test consumer of seven of the eight, so splitting them across two PRs would mean
either an intermediate state where an ObjC service instantiates Swift builders through the
bridging header, or two rounds of test-file churn over the same files. They are also a single
commit for the same reason: a commit that ports only the builders would not compile, which is
worse for `git bisect` than a slightly larger one.

## Scope — what this PR does *not* cover

`PrebidMobile/Objc/PrebidMobileRendering/Networking/Parameters/` is now empty of `.m` files, but
**two ObjC files remain elsewhere under `Networking/`**:

| File | Size | Non-test consumers |
|------|------|--------------------|
| `Tracking/PBMTrackingRecord.{h,m}` | 37 + 29 lines | `PBMVastAdsBuilder.m`, `PBMAdRequesterVAST.m` |
| `URLBuilding/PBMURLComponents.{h,m}` | 99 + 28 lines | `PBMVastRequester.m` |

Whether they belong to Phase 3 (as an S3.3) or to a later phase is **not decided here** — the
authoritative step list lives in the migration TaskNotes, not in this repo. Flagging them so the
boundary is explicit: if Phase 3 is scoped as "Networking" rather than "parameter builders", this
PR is not the whole phase.

Everything else that Phase 3 was expected to touch per the playbook — the `PBMParameterBuilder`
protocol, the eight builders, the service, and their two support types — is done.

## Summary

### S3.1 — Parameter builders (8 classes + 3 support types)

`PrebidMobile/Objc/PrebidMobileRendering/Networking/Parameters/` → `PrebidMobile/Swift/…/Parameters/`.

| ObjC | Swift | Notes |
|------|-------|-------|
| `PBMParameterBuilderProtocol.h` | `ParameterBuilder.swift` | `@objc(PBMParameterBuilder) public protocol`, `@objc(buildBidRequest:) func build(_:)` |
| `PBMBasicParameterBuilder` | `BasicParameterBuilder.swift` | keeps optional stored properties — see Gap S3.1-C |
| `PBMGeoLocationParameterBuilder` | `GeoLocationParameterBuilder.swift` | |
| `PBMAppInfoParameterBuilder` | `AppInfoParameterBuilder.swift` | |
| `PBMDeviceInfoParameterBuilder` | `DeviceInfoParameterBuilder.swift` | |
| `PBMNetworkParameterBuilder` | `NetworkParameterBuilder.swift` | `CTCarrier` read stays `#available`-gated off on iOS 16+ |
| `PBMUserConsentParameterBuilder` | `UserConsentParameterBuilder.swift` | |
| `PBMSKAdNetworksParameterBuilder` | `SKAdNetworksParameterBuilder.swift` | left non-`final`; `skAdNetworkIds()` stays overridable for the test mock |
| `PBMORTBParameterBuilder` | `ORTBParameterBuilder.swift` | not a `ParameterBuilder`; the terminal JSON-serialization step |

Support types pulled along because the builders are their only consumers:

- `PBMBundleProtocol.h` → `BundleProtocol.swift` — deliberately **not** `@objc`, so the plain-Swift
  `MockBundle` can conform (Gap S3.1-B). `extension Bundle: BundleProtocol {}` supplies the real
  implementation.
- `InternalUserConsentDataManager.{h,m}` → `InternalUserConsentDataManager.swift` — read by
  `BasicParameterBuilder` and `UserConsentParameterBuilder`.

### S3.2 — `PBMParameterBuilderService` → `ParameterBuilderService.swift`

The static entry point that assembles the seven builders, runs them over a fresh `ORTBBidRequest`,
merges arbitrary ORTB config, and hands off to `ORTBParameterBuilder.buildOpenRTB(for:)`.
Both public overloads keep their ObjC selectors (`buildParamsDictWithAdConfiguration:` and
`…:extraParameterBuilders:`) because `PBMBidRequester.m` still calls them.

`createORTBBidRequest(with:)` is ported 1:1 including the `Targeting` reads (user ext, external
user IDs, shared ID, user/app keywords, store URL, domain, iTunes ID, publisher name, rounded
coordinates).

### Consumer re-pointing

- **`PBMBidRequester.m`** — dropped `#import "PBMParameterBuilderService.h"`; the Swift class
  arrives via the existing `SwiftImport.h`.
- **`PBMPrebidParameterBuilder.h`** — gained an explicit
  `- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest NS_SWIFT_NAME(build(_:));`.
  This ObjC class conforms to the now-Swift `PBMParameterBuilder` protocol but does not inherit
  the protocol's Swift-side name (Gap S3.1-F).
- **`PrebidMobileTest-Bridging-Header.h`** — 12 imports removed.
- **`PrebidMobile.xcodeproj/project.pbxproj`** — 23 file references removed, 12 added, via the
  `xcodeproj` gem (same procedure as Phases 1–2).

### Deleted (23 files)

10 `.m` (9 builders + `InternalUserConsentDataManager.m`), 12 private headers, and
`PrebidMobileTests/RenderingTests/TestExtensions/PBMBasicParameterBuilder+pbmTestExtension.h`
(an ObjC class extension cannot re-open a Swift class — Gap S3.1-C).

### Deliberate behavioural divergences

These are intentional and reviewer-visible:

1. **`InternalUserConsentDataManager.gppSID` is non-optional `[NSNumber]` and uses `compactMap`.**
   The ObjC version built an `NSMutableArray` and called `addObject:` with the result of
   `numberFromString:`, which returns `nil` for an unparseable component — an
   `NSInvalidArgumentException` crash on malformed `IABGPP_GppSID`. The Swift version skips the
   bad component. `InternalUserConsentDataManagerTests.assertIABGPPSID` was retyped accordingly,
   and `testIABGPPSID_Malformed` covers the new skip behaviour.
2. **`SKAdNetworksParameterBuilder.skAdNetworkIds()` uses `compactMap`** over the
   `SKAdNetworkItems` plist array, likewise skipping malformed entries instead of inserting `nil`.
   `SkadnParameterBuilderTest.testSKAdNetworkIds_SkipsMalformedEntries` exercises the real parse
   (not the mock override) through `MockBundle.mockSKAdNetworkItems`.
3. **`ORTBParameterBuilder.buildOpenRTB(for:)` returns a non-optional `[String: String]`.**
   The ObjC signature was nullable but every path returned a dictionary. As in the original, the
   error path returns an **empty** dictionary — the `openrtb` key is inserted only when
   serialization succeeds — after logging "Not valid JSON object";
   `testAppendBuilderParametersWitError` now asserts that.
4. **`PBMAssert` nil-guards dropped** in the six builders whose initializer parameters are
   non-optional in Swift. `BasicParameterBuilder` is the exception: its four properties stay
   optional `var`s (the test extension header used to set them to `nil`) and its
   `Log.error("Invalid properties")` guard is retained, because three tests assert on that log
   line. A `TODO` marks the cleanup.
5. ~~**`NSMutableDictionary` nil-assignment semantics.**~~ **Withdrawn in review.** The claim that
   the Swift subscript stores a boxed `Optional.none` where ObjC `dict[key] = nil` removes the key
   is wrong: single-level optionals — including the flattened result of optional chaining such as
   `targeting?.getSubjectToGDPR()` — remove the key, exactly as in ObjC. The
   `NSMutableDictionary.pbmSetValue(_:forKey:)` helper this introduced has been removed and its
   four call sites are plain subscript assignments again. Gap S3.1-A is marked withdrawn in the
   playbook, with the verified semantics recorded so no future port repeats the mistake.

Everything else was diffed line-by-line against `git show HEAD:…` for
`PBMParameterBuilderService.m`, `PBMBasicParameterBuilder.m` and `PBMDeviceInfoParameterBuilder.m`
and is a faithful port, including the inverted `lmt`, the blank-IFA → `nil` and zeroed-IFA → `ifv`
fallbacks, and the iOS 14 `atts` override of `lmt`.

### Playbook updates

- Seven new Phase 3 gaps (**S3.1-A** … **S3.1-G**) and **S3.2-A**. **S3.1-A is recorded as
  withdrawn** — see divergence 5 above.
- **Gap 4 and Gap 6 corrected.** Both claimed "after Phase 3 all ObjC consumers are gone", so the
  `@objc public` ORTB twins could be demoted to `internal`. That is false:
  `PBMPrebidParameterBuilder.m`, `PBMBidRequester.m`, `PBMBidResponseTransformer.m` and
  `PBMWebView.m` all still consume ORTB Swift twins. The demotion stays deferred to S9.2, and the
  playbook now says so with the actual file list.
- **Orphan-header inventory** added: the 39 headers under `PrebidMobile/Objc/` with no matching
  `.m`. The per-class porting recipe at the top of the playbook never applies to them, so without
  an explicit inventory they are invisible to the phase plan and would linger past S9. Each row
  names the `.m` whose port retires the header, measured from the current importer graph, so the
  inventory stays valid regardless of how the remaining phases are numbered. Two headers are
  already dead.

## Test plan

- [x] `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build clean (only the 4 pre-existing
      "Skipping duplicate build file" warnings for the GAM AdLoading sources)
- [x] `./scripts/buildPrebidMobilePackage.sh` — SwiftPM build of the working tree clean
      (`__PrebidMobileInternal` complete)
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — **811 tests, 0 failures, no retries**
      (before the review round; the count differs from the 765 recorded in `pr-phase-012.md`
      because of the three upstream PRs merged since `b21cbc2b` — #1301, #1305, #1325). Verified
      no test *class* was renamed by the `PBM`-prefix symbol sweep, so the
      `PrebidMobilePRTests.xctestplan` `skippedTests` prefix matches are unaffected.
- [x] Review round 1: `-only-testing` re-run of the six parameter-builder classes on the full test
      plan (`InternalUserConsentDataManagerTests`, `SkadnParameterBuilderTest`,
      `PBMORTBParameterBuilderTest`, `BasicParameterBuilderTest`,
      `PBMUserConsentParameterBuilderTest`, `ParameterBuilderServiceTest`) — **0 failures**,
      including the four new cases
- [x] Review round 1: `PrebidMobilePRTests` plan re-run after the fixes — **813 tests, 0
      failures**. 811 + the two new `SkadnParameterBuilderTest` cases; the two new
      `InternalUserConsentDataManagerTests` cases are skipped by that plan (see note below)
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite, run before merge
- [ ] Reviewer: confirm the phase boundary in "Scope" above — is Phase 3 complete, or is
      `PBMTrackingRecord` / `PBMURLComponents` an S3.3?
- [ ] Reviewer: confirm the four remaining deliberate divergences above (the fifth is withdrawn)
- [ ] Reviewer: confirm the playbook's orphan-header inventory against the phase plan

### Note on the two new tests and the PR test plan

`InternalUserConsentDataManagerTests` is skipped wholesale by `PrebidMobilePRTests.xctestplan`
(class-level `skippedTests` entry, pre-existing), so `testIABGPPSID_Malformed` and
`testIABGPPSID_EmptyString` run in the full plan only. No plan edit was made: adding them to the
quick subset would mean un-skipping a class that was deliberately excluded.
`SkadnParameterBuilderTest` is not skipped, so its two new tests run on every PR.

## Review round 1 — #1328 comments addressed

| Comment | Resolution |
|---------|------------|
| Gap S3.1-A describes a nonexistent Swift bug | Verified under `swiftc -swift-version 5`: assigning a nil single-level optional through the `NSMutableDictionary` / `[String: Any]` subscript removes the key, and optional chaining flattens, so `targeting?.getSubjectToGDPR()` is `NSNumber?` and behaves identically. Gap marked **withdrawn** in the playbook with the measured semantics; `pbmSetValue(_:forKey:)` deleted and its four call sites reverted to plain subscript assignment. |
| `buildOpenRTB(for:)` error path returns `[:]`, not `["openrtb": ""]` | Divergence 3 corrected; `testAppendBuilderParametersWitError` now captures the result and asserts `isEmpty`. |
| `gppSID` crash-to-skip needs a regression test; `testIABGPPSID_Unset` asserted the wrong property | Added `testIABGPPSID_Malformed` (`"2_bad_5"` → `[2, 5]`) and `testIABGPPSID_EmptyString` (covers the `isEmpty` early return). `testIABGPPSID_Unset` called `assertIABGPPString(nil)` — a copy-paste of the `gppHDRString` test that never touched `gppSID`; it now asserts `assertIABGPPSID([])`. |
| `skAdNetworkIds()` divergence is only covered through the mock override | Added `testSKAdNetworkIds_SkipsMalformedEntries`, which drives the real parse via a new `MockBundle.mockSKAdNetworkItems` seam over a plist array holding a valid entry, an empty entry, a wrong-type (`Int`) identifier and a wrong-key entry, and asserts both `skAdNetworkIds()` and the resulting `imp.ext.skadn.skadnetids`. Also `testSKAdNetworkIds_NilInfoDictionary` for the `infoDictionary == nil` branch. `SKAdNetworkItemsKey` / `SKAdNetworkIdentifierKey` lost their `private` so the mock can key off them, matching `AppInfoParameterBuilder.bundleNameKey`. |

## Notes for the reviewer

- **`MockSKAdNetworksParameterBuilder` is now `fileprivate`.** Not cosmetic: an `internal`
  NSObject-derived Swift class in the *test* module is emitted into `PrebidMobileTests-Swift.h`,
  and that header fails to compile when the superclass is a non-`@objc` internal class from
  another module. `fileprivate` suppresses the emission (Gap S3.1-E).
- **`ParameterBuilderService` is not `@objcMembers`.** One member takes a `BundleProtocol`, which
  is not ObjC-representable, so `@objcMembers` fails to compile; the two bridged entry points
  carry explicit `@objc(selector:)` instead (Gap S3.1-D).
- **`PBMAdLoadFlowController.h` and `PBMORTB_NotImplemented.h` are dead** — zero `#import`s
  anywhere in the repo (the former's Swift twin already exists as
  `AdLoadFlowController.swift`; the latter is referenced only by a stale `.pbxproj` entry).
  Left in place in this PR to keep the diff scoped to Phase 3; recorded in the playbook
  inventory as deletable at any time.
