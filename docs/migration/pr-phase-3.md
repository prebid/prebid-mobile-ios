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
| `PBMBasicParameterBuilder` | `BasicParameterBuilder.swift` | non-optional `let` properties — see Gap S3.1-C |
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
   *Round 2:* the parse is now `String.strictNumberValue` (`Int64(self).map(NSNumber.init)`)
   rather than `NumberFormatter`. GPP section IDs are a spec-defined run of digits, and
   `NumberFormatter` resolves against `Locale.current` — under a grouping-separator locale it will
   read `"1,2"` as `12`, and it accepts decimals and signs the spec does not define. This is a
   *narrowing* relative to both the ObjC original and the first Swift draft; no test changed,
   because every existing input is a plain integer string.
2. **`SKAdNetworksParameterBuilder.skAdNetworkIds()` uses `compactMap`** over the
   `SKAdNetworkItems` plist array, likewise skipping malformed entries instead of inserting `nil`.
   `SkadnParameterBuilderTest.testSKAdNetworkIds_SkipsMalformedEntries` exercises the real parse
   (not the mock override) through `MockBundle.mockSKAdNetworkItems`.
3. **`ORTBParameterBuilder.buildOpenRTB(for:)` returns a non-optional `[String: String]`.**
   The ObjC signature was nullable but every path returned a dictionary. As in the original, the
   error path returns an **empty** dictionary — the `openrtb` key is inserted only when
   serialization succeeds — after logging "Not valid JSON object";
   `testAppendBuilderParametersWitError` now asserts that.
4. **`PBMAssert` nil-guards dropped** in **all** the builders, whose initializer parameters are
   non-optional in Swift. As of round 2 `BasicParameterBuilder` is no longer an exception: its four
   properties are non-optional `let`s, the `Log.error("Invalid properties")` guard is gone, and
   `testInvalidProperties` — which reached the guard only by nilling the properties through the
   deleted ObjC test-extension header — is deleted with it.
   The behaviour-class change this implies is recorded as **Gap S3.1-H**: `PBMAssert` is compiled
   out in Release, so an ObjC caller passing `nil` logged and continued, whereas a Swift
   non-optional parameter traps unconditionally. Safe here because all eight builders are
   constructed only by `ParameterBuilderService`, in Swift, with non-optional arguments — the gap
   records the grep to re-run and the rule to re-introduce an explicit `Log.error` + early return
   if that ever stops holding.
5. ~~**`NSMutableDictionary` nil-assignment semantics.**~~ **Withdrawn in review.** The claim that
   the Swift subscript stores a boxed `Optional.none` where ObjC `dict[key] = nil` removes the key
   is wrong: single-level optionals — including the flattened result of optional chaining such as
   `targeting?.getSubjectToGDPR()` — remove the key, exactly as in ObjC. The
   `NSMutableDictionary.pbmSetValue(_:forKey:)` helper this introduced has been removed and its
   four call sites are plain subscript assignments again. Gap S3.1-A is marked withdrawn in the
   playbook, with the verified semantics recorded so no future port repeats the mistake.
6. **`AppInfoParameterBuilder` type-checks the two `CFBundle*Name` reads.** *Raised in review
   round 2 — it was in the original diff but not on this list.* The ObjC line was an unchecked
   static cast (`NSString *bundleDisplayName = bundleDict[…];`), so a plist whose
   `CFBundleDisplayName` is not a string handed that object straight through to
   `bidRequest.app.name` (typed `NSString *`), surfacing later as an unrecognized selector or a
   mistyped JSON value. Swift's `bundleDict[…] as? String` yields `nil` for the same input, so a
   mistyped `CFBundleDisplayName` now **falls back to `CFBundleName`**, and a mistyped pair leaves
   `app.name` unset. Swift offers no way to reproduce the ObjC behaviour without an unsafe cast
   that would trap at first use, so this is not optional — but it is a real change and belongs on
   this list.

Everything else was diffed line-by-line against `git show HEAD:…` for
`PBMParameterBuilderService.m`, `PBMBasicParameterBuilder.m` and `PBMDeviceInfoParameterBuilder.m`
and is a faithful port, including the inverted `lmt`, the blank-IFA → `nil` and zeroed-IFA → `ifv`
fallbacks, and the iOS 14 `atts` override of `lmt`.

### Playbook updates

- Eight new Phase 3 gaps (**S3.1-A** … **S3.1-H**) and **S3.2-A**. **S3.1-A is recorded as
  withdrawn** — see divergence 5 above. **S3.1-H** is new in review round 2 (dropping `PBMAssert`
  converts a Release-mode log into a Release-mode trap); **S3.1-C** was rewritten in the same round
  (deleting the ObjC test-extension header means deleting the looseness it existed to serve, not
  preserving it behind a `TODO`); **S3.2-A** gained the "grep before you reach for `@objc`" rule
  and its `InternalUserConsentDataManager` example.
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
- [x] `./scripts/testPrebidMobile.sh --latest --quick` re-run after the `SetupTests` user-agent
      seeding (see "CI flake fixed in passing" below) — **813 tests, 0 failures, no retries** on a
      simulator the script creates from scratch, i.e. the same cold-WebKit state as CI
- [x] Review round 2: `-only-testing` re-run of the nine parameter-builder / consent / `Utils`
      classes on the full test plan (`PBMBasicParameterBuilderTest`,
      `InternalUserConsentDataManagerTests`, `PBMUserConsentParameterBuilderTest`,
      `ParameterBuilderServiceTest`, `SkadnParameterBuilderTest`, `PBMORTBParameterBuilderTest`,
      `PBMAppInfoParameterBuilderTest`, `PrebidParameterBuilderTest`, `UtilsTests`) — **133 tests,
      0 failures**
- [x] Review round 2: `./scripts/testPrebidMobile.sh --latest --quick` — **812 tests, 0 failures,
      no retries**. 813 − 1: `testInvalidProperties` is deleted, and nothing else moved.
- [x] Review round 2: `./scripts/buildPrebidMobile.sh` — all 4 XCFrameworks build clean (same
      pre-existing GAM "Skipping duplicate build file" and iOS 13 deprecation warnings as before)
- [x] Review round 2: `swiftlint --config .swiftlint.yml` — no new violations from this round. The
      repo baseline is 25 616 violations / 152 error-severity, and SwiftLint is not wired into CI
      (no reference to it anywhere under `.github/`), so it is advisory here. Of the files this PR
      touches, exactly one carries an error-severity violation:
      `ParameterBuilderService.buildParamsDict(with:bundle:…)` trips `function_parameter_count`
      (10 > 5). That is the ObjC signature ported 1:1 and it is the seam
      `ParameterBuilderServiceTest` injects its seven mocks through — collapsing it into a
      parameter object is a real refactor, not a lint fix, and is out of scope here. Everything
      else in the touched files is pre-existing `trailing_whitespace` / `colon` noise inherited
      from the ObjC-era test formatting.
- [ ] `./scripts/testPrebidMobile.sh --latest` — full suite, run before merge
- [ ] Reviewer: confirm the phase boundary in "Scope" above — is Phase 3 complete, or is
      `PBMTrackingRecord` / `PBMURLComponents` an S3.3?
- [ ] Reviewer: confirm the five remaining deliberate divergences above (1–4 and 6; the fifth is
      withdrawn)
- [ ] Reviewer: call the `BasicParameterBuilder.sdkConfiguration` question at the end of
      "Review round 2" — remove the now-dead property and its initializer parameter, or leave it?
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

## Review round 2 — #1328 comments addressed

All nine comments accepted. Seven are code changes, two are documentation.

| Comment | Resolution |
|---------|------------|
| `@objcMembers` on `InternalUserConsentDataManager` is unnecessary | Confirmed by grep: no `.h`/`.m`/`.mm` in the repo names the type; its only consumers are `BasicParameterBuilder`, `UserConsentParameterBuilder` and a `@testable` test. Dropped `@objcMembers` **and** the `NSObject` base — an internal `NSObject` subclass is still emitted as an `@interface` into the generated header, so removing only the attribute would not have achieved the stated goal. Now `final class`. |
| `zeroedIFA` duplicates `String.kIFASentinelValue` | Correct — `Constants.swift:24` already holds the same literal. Deleted the local copy; the guard now reads `ifa == String.kIFASentinelValue`. |
| `NumberFormatter` for `gppSID` is locale-sensitive | Correct. Switched to `String.strictNumberValue`, whose doc comment exists for exactly this reason. See divergence 1. |
| `regs.ext["gdpr"]` write in `BasicParameterBuilder` is dead | Confirmed against `ParameterBuilderService`'s builder order (Basic … **UserConsent** …), which unconditionally overwrites the key. Removed, leaving a comment naming the owner. **One qualification worth recording:** the claim holds for the production pipeline but not for `PrebidParameterBuilderTest.buildBidRequest(with:)`, a test-only pipeline that runs Basic + DeviceInfo + `PBMPrebidParameterBuilder` and was silently depending on the duplicate write — `testSubjectToGDPR` failed on removal. Fixed by adding `UserConsentParameterBuilder()` to that helper in its production-relative position, which is what the helper should have done all along. |
| `BasicParameterBuilder`'s mutable optionals exist only for `testInvalidProperties` | Correct. Four `var`s → `private let`, initializer parameters non-optional, `Log.error("Invalid properties")` guard removed, `testInvalidProperties` and the test class's now-unused `logToFile` lock deleted. Playbook Gap S3.1-C rewritten to prescribe this instead of the `TODO`. |
| Dropping `PBMAssert` is a latent behaviour-class change; note it | Agreed — `PBMAssert` is compiled out in Release, so ObjC logged and continued where Swift now traps. Recorded as **Gap S3.1-H** with the measure-the-callers grep and the fallback rule, and divergence 4 rewritten to point at it. |
| `as? String` in `AppInfoParameterBuilder` is an undisclosed divergence | Agreed — it was in the diff but not on the list. Added as **divergence 6**, including the ObjC behaviour it replaces (unchecked static cast → mistyped object propagated into `app.name`) and the new fallback path. |
| 12 unused static key constants | Verified unused repo-wide and deleted: 8 from `BasicParameterBuilder` (`platformKey`, `platformValue`, `allowRedirectsKey`, `allowRedirectsVal`, `sdkVersionKey`, `urlKey`, `rewardedVideoKey`, `rewardedVideoValue`) and 4 from `DeviceInfoParameterBuilder` (`ifaKey`, `lmtKey`, `ifvKey`, `attsKey`). `AppInfoParameterBuilder.bundleNameKey` / `bundleDisplayNameKey` are **kept** — `MockBundle.swift:42,47` reads both. |
| Coordinate rounding duplicated between `GeoLocationParameterBuilder` and `ParameterBuilderService` | Extracted `ORTBGeo.setRoundedCoordinates(_:precision:)`, used by both (`device.geo` and `user.geo`). Placed in `GeoLocationParameterBuilder.swift` rather than `ORTBGeo.swift` to keep the ORTB twins pure data, and rather than a new file to avoid a `.pbxproj` edit for six lines. |

**One finding surfaced by the above, left for the reviewer to call.**
`BasicParameterBuilder.sdkConfiguration` is now an unused stored property. It was already unused in
substance in ObjC — `git show master:…/PBMBasicParameterBuilder.m` shows `_sdkConfiguration` read
only by the `PBMAssert` and the `Invalid properties` guard, both of which this round deletes. It is
not removed here because the initializer has 13 call sites across four test files, and dropping it
would also strand the `sdkConfiguration:` parameter of
`ParameterBuilderService.buildParamsDict(with:bundle:…)` — the seam `ParameterBuilderServiceTest`
injects through. That is a wider change than the comment asked for, so it is flagged rather than
taken; say the word and it is a separate commit.

## CI flake fixed in passing — `SetupTests` user-agent seeding

The first CI run of this branch failed `PBMBidRequesterTest` (9 cases × 3 retry iterations) plus
`PBMVastLoaderCheckForAds.testNegativeThreeResponsesNoAdsOnLast`, all with
`Asynchronous wait failed: Exceeded timeout of 5 seconds`. **Not caused by this PR** — nothing here
touches `PBMBidRequester`'s request path or `PBMBidRequesterTest` (`git diff master...HEAD` on that
test file is empty). The mechanism, from the job log
([run 33369608203](https://github.com/prebid/prebid-mobile-ios/actions/runs/33369608203/job/99422686045)):

- `PBMBidRequester -requestBidsWithCompletion:` awaits `PBMUserAgentService.shared`
  `fetchUserAgentWithCompletion:` before **every** request — including the ones that only return a
  validation error, which is why `testBanner_invalidConfigID_noRequest` timed out too.
- `UserAgentService.fetchUserAgent` resolves the UA by creating a `WKWebView` and calling
  `evaluateJavaScript("navigator.userAgent")`, with no timeout and no de-duplication.
- On that runner WebKit's helper processes stalled: `GPU process took 173.98 seconds to launch`,
  `Networking process took 177.86 seconds`, and 30 `WebContent process took N seconds` lines. The
  suite started at 08:09:16 and the UA only resolved at 08:11:26; the first case to run *after*
  that passed in 0.029 s.
- The same stall is present in the **passing** phase-012 run (`GPU process took 56.79 seconds`) —
  there it merely finished before `PBMBidRequesterTest` was reached. So the pass/fail outcome is a
  race between WebKit warm-up and how fast the runner reaches the suite.

Fix, in `PrebidMobileTests/RenderingTests/SetupTests.swift` (the test bundle's `NSPrincipalClass`,
instantiated before any test runs):

1. **Seed the persisted user agent** via `UserAgentDefaults` when it is empty, so
   `UserAgentService.shared` starts with a non-empty `userAgent` and `fetchUserAgent` returns
   synchronously without ever touching WebKit. No test asserts on
   `UserAgentService.shared.userAgent` (the parameter-builder tests use `MockUserAgentService`), and
   `UserAgentServiceTest` still exercises the real `WKWebView` path through its own instances.
2. **Keep the WebKit warm-up** with a throwaway fire-and-forget `WKWebView`. Seeding otherwise
   removes the side effect — `UserAgentService.shared`'s initializer creating a `WKWebView` at
   bundle load — that the WebKit-dependent suites were implicitly relying on; without it
   `UserAgentServiceTest.testMultipleCalls` (10 s budget) started failing on a cold simulator.

Verified by erasing the simulator between runs to reproduce a cold WebKit: before the change the
9 CI-failing cases time out locally too, after it they pass in 1–75 ms each.

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
