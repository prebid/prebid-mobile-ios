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
   bad component. `InternalUserConsentDataManagerTests.assertIABGPPSID` was retyped accordingly.
2. **`SKAdNetworksParameterBuilder.skAdNetworkIds()` uses `compactMap`** over the
   `SKAdNetworkItems` plist array, likewise skipping malformed entries instead of inserting `nil`.
3. **`ORTBParameterBuilder.buildOpenRTB(for:)` returns a non-optional `[String: String]`.**
   The ObjC signature was nullable but every path returned a dictionary; the error path returns
   `["openrtb": ""]` as before, after logging "Not valid JSON object".
4. **`PBMAssert` nil-guards dropped** in the six builders whose initializer parameters are
   non-optional in Swift. `BasicParameterBuilder` is the exception: its four properties stay
   optional `var`s (the test extension header used to set them to `nil`) and its
   `Log.error("Invalid properties")` guard is retained, because three tests assert on that log
   line. A `TODO` marks the cleanup.
5. **`NSMutableDictionary` nil-assignment semantics** — ObjC `dict[key] = nil` removes the key;
   the naive Swift subscript stores a boxed `Optional.none`. All such sites go through a new
   `NSMutableDictionary.pbmSetValue(_:forKey:)` helper (Gap S3.1-A).

Everything else was diffed line-by-line against `git show HEAD:…` for
`PBMParameterBuilderService.m`, `PBMBasicParameterBuilder.m` and `PBMDeviceInfoParameterBuilder.m`
and is a faithful port, including the inverted `lmt`, the blank-IFA → `nil` and zeroed-IFA → `ifv`
fallbacks, and the iOS 14 `atts` override of `lmt`.

### Playbook updates

- Seven new Phase 3 gaps (**S3.1-A** … **S3.1-G**) and **S3.2-A**.
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
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — **811 tests, 0 failures, no retries**.
      This PR adds and removes no test methods; the count differs from the 765 recorded in
      `pr-phase-012.md` because of the three upstream PRs merged since `b21cbc2b` (#1301, #1305,
      #1325). Verified no test *class* was renamed by the `PBM`-prefix symbol sweep, so the
      `PrebidMobilePRTests.xctestplan` `skippedTests` prefix matches are unaffected.
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite, run before merge
- [ ] Reviewer: confirm the phase boundary in "Scope" above — is Phase 3 complete, or is
      `PBMTrackingRecord` / `PBMURLComponents` an S3.3?
- [ ] Reviewer: confirm the five deliberate divergences above
- [ ] Reviewer: confirm the playbook's orphan-header inventory against the phase plan

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
