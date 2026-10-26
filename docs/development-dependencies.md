# Development dependencies

The repository's Xcode workspace uses Swift Package Manager. CocoaPods remains a
customer distribution option through the core and adapter podspecs. Building this
repository does not require CocoaPods, a Podfile, or a generated Pods project.

## Versions and resolution

| Package product | Exact version |
| --- | --- |
| GoogleMobileAds | 13.11.0 |
| GoogleInteractiveMediaAds | 3.33.0 |
| AppLovinSDK | 13.6.4 |
| GoogleUserMessagingPlatform (Google dependency) | 3.1.0 |

These match the previous development Podfile.lock. The three Xcode projects have
exact requirements for the vendor SDKs. They share a generated, ignored lockfile at
`PrebidMobile.xcworkspace/xcshareddata/swiftpm/Package.resolved`. This workspace
contains only native projects and vendor packages, so published Prebid requirements
cannot block a native vendor-major upgrade.

The published consumer lives in the standalone
`Example/PrebidDemo/PrebidDemoSPM.xcodeproj`. Open it separately from the native
workspace. It retains the adapters' `main` branch requirement and gets the core,
GoogleMobileAds, and AppLovinSDK products transitively through that graph. It does
not impose separate Google/AppLovin version requirements; candidate adapter
manifests can therefore change their supported major versions before publication.
Its project lockfile is generated and ignored. Existing local checkouts can use
Xcode's Update to Latest Package Versions command.

The root `Package.swift` retains its consumer version ranges. Its committed
`Package.resolved` selects the same tested vendor versions for the local package
build, which uses `--force-resolved-versions`. Published package manifests and
podspecs retain their customer-facing requirements.

```bash
./scripts/resolveDependencies.sh
```

Scripts keep checkouts and binary artifacts in `.swiftpm-cache/`, outside
`generated/`, so archive builds can delete their output without deleting the cache.
CI keys that cache by Xcode version, the root lockfile, and Xcode project package
requirements. Xcode opened interactively can use its default package cache.
Standalone consumer builds use `.swiftpm-spm-demo-cache/` and `.build/spm-demo/`.
Separate package directories keep one graph's checkout or binary artifact from
replacing another graph's vendor version. Xcode's default DerivedData also separates
the native workspace from the standalone consumer project.

To update a vendor dependency deliberately, change its exact requirement in the
three projects, resolve the workspace, and refresh the root lockfile to the same
versions (using `swift package update` for the changed package if needed):

```bash
./scripts/resolveDependencies.sh
swift package resolve
```

Commit the project requirements and the updated root lockfile. Do not commit the
workspace or standalone-project lockfiles. The release verifier creates a temporary
workspace referencing the consumer project, with its own lockfile, package cache,
and DerivedData. Normal native and consumer lockfiles are never modified. PR checks
build this consumer against locally staged candidate packages before publication;
release checks also build against the published packages afterward.

## Targets and linking

GAM/AdMob frameworks and their unit tests depend on GoogleMobileAds. MAX frameworks
and tests depend on AppLovinSDK. Both native demo apps, the SPM demo, and both
InternalTestApp variants depend on all three vendor SDKs. Unit tests that import
GoogleMobileAds link that product explicitly. UI tests obtain their dependencies
through the tested app. OpenXMockServer and its tests use only system frameworks.

Native and published Prebid products share module/framework names. Keeping the
consumer in a separate project gives both command-line and Xcode builds separate
package graphs and default product directories. Native projects use standard Xcode
product paths; the previous `LocalPrebid` overrides have been removed. When switching
from the earlier shared-container layout, use Product > Clean Build Folder once in
the native workspace to discard any previously mixed native/published modules.

`verifyDevelopmentApps.sh` builds five native app/test configurations. Its optional
`--with-spm-demo` flag also calls `buildPrebidSPM.sh` for the standalone published
consumer, using separate caches/products. PR CI omits that flag because demo changes
may use SDK APIs that have not been published. A separate PR job runs `verifySPM.sh`
against candidate package sources, so those API changes can still be verified before
release. `verifyDependencyIsolation.sh` checks that the
consumer target and published Prebid references stay outside the native workspace.

Google's SPM binary is a static archive. App and test targets disable Xcode's
package diamond diagnostic/automatic dynamic replacement to retain the previous
CocoaPods static-link behavior. Xcode otherwise synthesizes a dynamic wrapper with
no `-ObjC` flag, strips Google's Objective-C symbols, and fails to link the adapter
frameworks. Each Google/AppLovin consumer explicitly retains `-ObjC`. This does not
change the linking requirements of the published adapters. These settings apply to
the native workspace targets only: the standalone SPM consumer links each package
product once, into the app, so it keeps Xcode's defaults, as a customer app would.

The XCFramework interface verifier searches `Frameworks/`, the built XCFrameworks,
and `.swiftpm-cache/artifacts/`. A different SourcePackages location can be passed
as its second argument:

```bash
./scripts/verifyXCFrameworkInterfaces.sh generated/output /path/to/SourcePackages
```

## Internal app cleanup

The internal app's forms are implemented by `FormTableViewController`, a UIKit table
with text, switch, checkmark, value-label, and action rows. Configuration controller
types, the `loadSection` override point, accessibility identifiers, consent defaults,
the multiformat selection rule, and the optional HUD setting remain available. The
unused native editor row helper was deleted. Text, toggle, and display cells are
dequeued, with controls/constraints built once. Reconfiguration updates the bound
row, callbacks, accessibility identifiers, and presentation state. The HUD uses
`UIActivityIndicatorView`.

OpenXMockServer uses URLSession and Combine. Its public `PBMMockServer` API is
unchanged. GET parameters use the query string and POST parameters use a form body;
non-success HTTP status codes fail, undecodable bodies complete without a value,
and offline URLSession errors map to `NetworkError.noConnection`. The local mock
host keeps its self-signed-certificate exception; other hosts use default trust.

## Validation

```bash
./scripts/buildPrebidMobile.sh       # four XCFrameworks and textual interfaces
./scripts/buildPrebidMobilePackage.sh
./scripts/verifyDevelopmentApps.sh  # native demos, internal/Skadn, test targets
./scripts/buildPrebidSPM.sh          # standalone published-package consumer
./scripts/verifyDependencyIsolation.sh
./scripts/testDevelopmentSupport.sh # deterministic form and mock-client tests
./scripts/testPrebidMobile.sh --latest --quick
./scripts/testPrebidMobileAdapters.sh
```

`OpenXMockServerTests` covers response decoding, HTTP/offline errors, and reserved
characters in GET and POST parameters without contacting the mock server.
The test scripts default to the latest installed simulator runtime. Set
`PREBID_TEST_RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-26-5` to use the CI runtime
on a machine that also has iOS 27 installed. Destinations use the created simulator's
UUID, so a runtime override cannot accidentally select another device.

`DevelopmentFormsTests` covers configuration edits, refresh reset, multiformat
selection gating, clearing consent values, and cell reuse without stale callbacks
or presentation state. `testDevelopmentSupport.sh` also runs
the existing configuration-sheet UI smoke test, which checks that the refresh field
and load button remain accessible. It uses its own simulator and removes it afterward.

## Local verification on 2026-10-25

Validated with Xcode 27.0 (27A266a). Runtime tests used iOS 26.5 (23F77), the
runtime matching the CI configuration:

- All four device/simulator XCFrameworks were produced; all 24 public/private Swift
  interfaces passed the standalone interface check with an empty module cache.
- The root SPM package built for the iOS simulator.
- All six verification builds passed: Swift demo with integration tests, Swift
  demo with UI tests, InternalTestApp with tests/UI tests, Objective-C demo,
  InternalTestApp-Skadn, and SPM demo.
- Core PR plan: 1,020 passed, zero failed. One WebKit setup timeout passed on the
  wrapper script's built-in retry (1,021 total test runs).
- GAM: 17 passed; AdMob: five passed; zero failed. The MAX test target builds and
  runs, but its existing Sources phase is empty, so it executes zero tests.
- Development support: three form tests, six mock-client tests, and the existing
  configuration-sheet UI smoke test passed (10 total, zero failed).
- Shell syntax, workflow YAML, exact package requirements, matching vendor
  lockfiles, and removal of CocoaPods project integration were checked.

The initial iOS 27 run exposed a Foundation parity difference and the internal
app's missing scene lifecycle. Both are addressed under
[iOS 27, CI and review follow-ups](#ios-27-ci-and-review-follow-ups), along with
the video status callback race found during verification. The published podspecs and published
package manifests were not modified.

### Historical follow-up: native builds from Xcode (superseded by project split)

Reproduced the adapter undefined-symbol failure in a regular InternalTestApp build
using Xcode's default DerivedData location. Giving only the command-line SPM demo a
separate derived-data directory did not protect builds started from Xcode itself.
The first fix used native project product-path overrides for all build entry
points. The standalone project split below supersedes those overrides.

Verified after the project-setting change:

- The default-location InternalTestApp build succeeds, including both simulator
  architectures. Building PrebidDemoSPM and then InternalTestApp in the same default
  DerivedData directory also succeeds.
- All seven steps in `verifyDevelopmentApps.sh` succeed, including the final native
  rebuild after the SPM demo in the same derived-data directory.
- The core test bundle builds with TestUtils in the native product directory; all
  41 TargetingTests pass on iOS 26.5.
- All 10 development-support tests pass on iOS 26.5.
- All four device/simulator XCFrameworks archive and package successfully, and all
  24 Swift interfaces pass the standalone check. Archive actions use the standard
  product paths to prevent duplicate vendor signature copies in the archive's
  `Signatures` directory.

### Standalone consumer verification on 2026-10-26

The standalone project split supersedes the earlier product-directory workaround.
All five native app/test builds, the standalone published consumer, the root SPM
package, all four XCFrameworks, and all 24 Swift interfaces pass with Xcode 27.0.
On iOS 26.5, all 1,030 core PR tests and 13 development-support tests pass without
failures; the core run needed no retries. The current core test bundle contains no
`large.mp4`.

A temporary native workspace resolves GMA 12.14.0 while the separate published
consumer resolves and builds with GMA 13.11.0, reproducing the incompatible-major
case without changing the committed requirements. A temporary consumer-workspace
build creates its own pins and leaves normal native/consumer lockfiles unchanged.
Source/resource membership, the isolation guard, shell syntax, and workflow YAML
also pass. PR CI separately verifies the consumer against candidate package sources.

## iOS 27, CI and review follow-ups

### iOS 27 changes

- **PM-A:** Preserve the original WebView parity capture, with one iOS 27-specific
  expected line for Foundation's malformed-percent normalization. Recompiled the
  original `PBMMRAIDCommand.m` from the parent of migration commit `31cf748d` in a
  Foundation-only simulator probe. On iOS 27, both original and port reject
  `mraid:expand/%E0%A4%25A` with the same error. On iOS 26.5 the original URL
  becomes `mraid:expand/%25E0%25A4%25A`, and the original command accepts
  `%E0%A4%A`, matching the unchanged legacy capture. No MRAID parser behavior changed.
  The property tests explicitly load a document, await its ready state, reuse
  that page, and replace the JavaScript stub for every input. The existing
  10-second waits remain unchanged.
- **PM-B:** Snapshot the observed video item's status/error before dispatching
  callbacks to the main queue, and ignore replaced items. The three new tests
  failed against the old code: two readiness callbacks, two failure callbacks,
  and one callback from a replaced item. No expectation or timeout was relaxed.
- Adopt UIKit's scene lifecycle in InternalTestApp and InternalTestApp-Skadn,
  using the existing Main storyboard. UIKit on iOS 27 requires this when built
  with the iOS 27 SDK ([UIKit migration guidance](https://developer.apple.com/documentation/uikit/transitioning-to-the-uikit-scene-based-life-cycle)).
  The `-keyUITests` option now sets the scene window's `layer.speed = 200` once
  the window connects. On master the same call ran in `didFinishLaunching`, before
  the storyboard window becomes key, so it most likely had no effect; UI tests now
  run with sped-up layer animations.
  The custom interstitial renderer finds its presentation window through an
  active window scene.

### iOS 27 verification

- [x] iOS 27 development support: 3 form, 6 mock-client and 1 UI smoke test pass.
- [x] iOS 27 core PR suite: 1,023 passed, zero failures, no retries, including
  all three new regression tests.
- [x] iOS 26.5: 33 selected video/parity tests and all 10 development-support
  tests pass, with zero failures.
- [x] Original Objective-C malformed-URL probes on iOS 26.5 and iOS 27.
- [x] Skadn app builds and launches on iOS 27; main screen renders.
- [x] Four device/simulator XCFrameworks built; all 24 Swift interfaces typecheck.
- [x] Root SPM package build.

### CI follow-up for PR #1421

The first CI run passed framework/interface builds, the root SPM package, adapter
checks, and development-app checks. The quick suite failed during cold WebKit
startup, the 58 MB download-size fixture, and delayed wrapper-failure callbacks.

- Wait for simulator boot/migration before building, and delete the owned device
  on both success and failure.
- Replace fire-and-forget WebKit warm-up with a bundle observation that waits for
  JavaScript to execute before tests begin. Keep the page alive until bundle
  completion. The startup budget is 180 seconds (cold CI helper launches have
  previously exceeded 170 seconds). Individual assertion deadlines remain
  unchanged. (A timeout no longer stops the run; see the second review follow-up.)
- Only create the JavaScript property fixture for tests that use it, and attach
  it to a window while probing. Pure parity comparisons keep their original oracle
  and no longer load an unused document.
- Retain both standalone VAST requester/load-manager fixtures through their
  asynchronous completion waits.
- Replace the download-size test's three MP4 transfers with eight small byte/header
  cases using the real URLSession/MockServerURLProtocol path. Assert exact bytes,
  below/equal/above-limit behavior, missing/malformed/negative Content-Length, and
  the absence of a GET when HEAD rejects the download. Deadlines remain two seconds.

Validation:

- [x] Local iOS 26.5 PR suite: 1,030 tests passed with zero failures and no retries.
- [x] Local iOS 27 affected tests: 75 executions across five repetitions, zero failures.

GitHub Actions validation is recorded in [PR #1421 checks](https://github.com/prebid/prebid-mobile-ios/pull/1421/checks).

### Review follow-up for PR #1421

- Restore the root package's existing vendor version ranges so consuming apps can
  choose compatible versions. Native Xcode project requirements remain exact, and
  the committed root lockfile keeps local package builds on the tested versions.
- Restore the ignored workspace lockfile policy. Normal resolution on a fresh
  checkout is no longer frozen to SDK 3.4.1 or a committed adapters-main revision.
  CI caches use the root lockfile and project requirements. Release verification
  preserves an optional local workspace lockfile and also supports its absence.
- Use registered text, toggle, and display cells. Controls and constraints are built
  once; reuse rebinds the current row and clears accessory, color, detail, and
  accessibility state. Three tests cover callback rebinding and presentation reset.
- The JavaScript-only page setup in the CI follow-up also addresses the review
  finding that synchronous parity comparisons loaded an unused document.

Validation:

- [x] Fresh workspace resolution without a workspace lockfile retains all four vendor versions.
- [x] Root SPM package builds with the restored ranges and committed root pins.
- [x] All 13 development-support tests pass on iOS 26.5, including three reuse tests and the UI smoke test.
- [x] Release-verifier cleanup preserves an existing lockfile and removes temporary pins when none existed.
- [x] Shell syntax and workflow YAML parse successfully.
- [x] All seven development-app verification builds pass after review changes.

### Second review follow-up for PR #1421

- PR CI no longer builds `PrebidDemoSPM`. It compiles the same Swift demo sources
  as `PrebidDemoSwift` against the published packages, so a PR that uses new SDK
  API in the demo would fail until that API is released (for example the
  `adFormats` demo change in #1341 against published 3.3.4).
  `verifyDevelopmentApps.sh --with-spm-demo` keeps the same-DerivedData check for
  local use; `SPM.yml` still builds the SPM demo against local package copies.
- The WebKit startup wait in `SetupTests.testBundleWillStart` logs a timeout or
  error and continues instead of calling `precondition`. Locally, 2 of 4 runs
  crashed before the first test ("no restart will be attempted"); a crash there
  cannot be retried by `-retry-tests-on-failure`.

Validation:

- [x] Forced 1 ms startup budget: the warning is logged, the run continues, and
  only a WebKit-dependent test fails on its own deadline (14 tests executed).
- [x] With the 180 second budget: VideoViewStatusTests, WebViewParityTests,
  DownloadSizeHelperTest, PBMVastLoaderMultiWrapperTest and UserAgentServiceTest
  pass on iOS 26.5 (22 tests, zero failures).
- [x] `verifyDevelopmentApps.sh` syntax, shellcheck, `--help` and unknown-flag exit codes.
- [x] `verifyDevelopmentApps.sh` without the flag: all five builds pass, and `PrebidDemoSPM` is not built.

### Package-graph review follow-up for PR #1421

- Move `PrebidDemoSPM` into `Example/PrebidDemo/PrebidDemoSPM.xcodeproj`, outside
  the native workspace. Keep the same 64 Swift sources and nine resource entries,
  with independent project/target IDs. The native workspace now resolves only the
  four vendor packages; published Prebid adapter ranges cannot constrain it.
- Let the standalone consumer obtain GoogleMobileAds, AppLovinSDK, and PrebidMobile
  transitively from its adapters graph. This avoids a second consumer requirement
  blocking candidate adapter vendor-major upgrades.
- Remove `LocalPrebid` output-path overrides from all five native projects. Separate
  containers provide default build-product isolation, and command-line consumer
  builds use their own package cache and DerivedData. Existing shared-layout build
  folders need one clean to discard stale modules.
- Use a temporary consumer workspace, pins, package cache, and DerivedData for
  candidate release verification. No normal lockfiles are backed up or modified.
  Add a PR job building the consumer against candidate packages, preserving coverage
  before a new vendor major or adapter version has been published. Native app
  verification now builds five native configurations, with an isolation guard.
  Preserve `--with-spm-demo` as an opt-in call to the standalone published consumer;
  it no longer shares native products or rebuilds a native app afterward.
- Delete the unused 58 MB `large.mp4` fixture and its project/resource references.
  The eight small URLSession download-size cases remain unchanged.

Validation with Xcode 27.0 (before integrating the remote nonfatal-warm-up change;
that change's focused validation is recorded above, and final-head CI covers both):

- [x] A temporary native workspace with GMA 12.14.0 resolves successfully while the
  independent published consumer uses GMA 13.11.0. This reproduces the reported
  incompatible-major scenario without changing committed vendor requirements.
- [x] Native resolution contains only the four expected vendor packages.
- [x] Standalone consumer builds for both simulator architectures.
- [x] Temporary consumer-workspace build creates its own pins and leaves existing
  native and standalone lockfiles byte-for-byte unchanged.
- [x] All five native app/test verification builds.
- [x] Four device/simulator XCFrameworks and all 24 Swift interfaces.
- [x] Core quick suite: 1,030 passed, zero failures, no retries; all 13
  development-support tests pass on iOS 26.5.
- [x] Root SPM package builds with its committed pins.
- [x] Built test bundle contains no `large.mp4`.
- [x] Isolation guard, unchanged source/resource membership, shell syntax, and workflow YAML.

### Third review follow-up for PR #1421

- The standalone SPM consumer drops `-ObjC` and `DISABLE_DIAMOND_PROBLEM_DIAGNOSTIC`.
  They were copied from the native targets; master's `PrebidDemoSPM` had neither,
  and the consumer builds and links against the published packages without them.
- `WebViewParityTests` asserts that the captured line `expectedForCurrentOS` replaces
  on iOS 27 is still present, so the replacement cannot silently stop applying.
- This PR record moved here from `docs/migration/pr-phase-7-ios-27.md`; its playbook
  entries are now PM-A to PM-C under "Post-migration findings" instead of Phase 7 IDs.
- `AGENTS.md` test counts are measured with `-enumerate-tests`: 1,030 tests in the PR
  plan and 1,430 in the full plan (the class-only entries without test methods are excluded).
- The `PrebidMultiformatConfigurationController.swift` copyright line is back to 2018-2023,
  and the `verifyDevelopmentApps.sh` flag comment is reworded.

Validation:

- [x] `WebViewParityTests` pass on iOS 26.5 and iOS 27 (3 tests each).
- [x] The standalone consumer builds against the published packages without the two settings.
- [x] `verifyDependencyIsolation.sh`, and `verifyDevelopmentApps.sh` syntax, shellcheck and `--help`.
