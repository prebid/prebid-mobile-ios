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
exact requirements, and share the committed lockfile at
`PrebidMobile.xcworkspace/xcshareddata/swiftpm/Package.resolved`. The root development
`Package.swift` and `Package.resolved` use the same vendor versions. Published
package manifests and podspecs retain their customer-facing version requirements.
The SPM demo still follows the Prebid adapter repository's `main` branch; the
workspace lockfile records the tested commit.

```bash
./scripts/resolveDependencies.sh
```

This command requires the committed package versions. Scripts keep checkouts and
binary artifacts in `.swiftpm-cache/`, outside `generated/`, so a new archive build
can delete its output without deleting its dependencies. CI caches that directory
using the Xcode version and workspace lockfile as its key. Xcode opened interactively
can use its default package cache; it still reads the same workspace lockfile.

To update a vendor dependency deliberately, change the exact requirement in all
three projects and the root development manifest where applicable. Resolve without
the frozen-lockfile option, then regenerate the root lockfile:

```bash
xcodebuild -resolvePackageDependencies \
  -workspace PrebidMobile.xcworkspace -scheme Lib-PrebidMobile \
  -clonedSourcePackagesDirPath .swiftpm-cache
swift package resolve
```

Commit the updated requirements and both lockfiles together. The release verifier
intentionally resolves temporary local Prebid packages and restores the development
lockfile afterward. Published-package release verification resolves afresh in CI.

## Targets and linking

GAM/AdMob frameworks and their unit tests depend on GoogleMobileAds. MAX frameworks
and tests depend on AppLovinSDK. Both native demo apps, the SPM demo, and both
InternalTestApp variants depend on all three vendor SDKs. Unit tests that import
GoogleMobileAds link that product explicitly. UI tests obtain their dependencies
through the tested app. OpenXMockServer and its tests use only system frameworks.

Normal builds of the local framework and app targets use
`$(BUILD_DIR)/LocalPrebid/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)` for their products.
The SPM demo and its published packages retain Xcode's default product directory.
Both copies of PrebidMobile have the same module/framework names, so sharing the
same product directory can mix published Swift modules with local binaries and
fail adapter linking with undefined `PrebidMobile.*.unsafeMutableAddressor` symbols.
The separation is set in all five native projects, including TestUtils, so it also
applies to builds started directly from Xcode. PrebidDemoSPM overrides the native
project default to keep its package products separate.

`verifyDevelopmentApps.sh` deliberately builds both kinds of targets in one
derived-data directory and rebuilds InternalTestApp after the SPM demo. This checks
that building the published packages cannot overwrite the native products. The
standalone `buildPrebidSPM.sh` continues to use its own derived-data directory.
Archive/install builds already use per-scheme directories. They keep Xcode's standard
product paths (`DEPLOYMENT_LOCATION=YES`), avoiding duplicate vendor XCFramework
signature copies when Xcode collects the archive's `Signatures` directory.

Google's SPM binary is a static archive. App and test targets disable Xcode's
package diamond diagnostic/automatic dynamic replacement to retain the previous
CocoaPods static-link behavior. Xcode otherwise synthesizes a dynamic wrapper with
no `-ObjC` flag, strips Google's Objective-C symbols, and fails to link the adapter
frameworks. Each Google/AppLovin consumer explicitly retains `-ObjC`. This does not
change the linking requirements of the published adapters.

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
unused native editor row helper was deleted. The HUD uses `UIActivityIndicatorView`.

OpenXMockServer uses URLSession and Combine. Its public `PBMMockServer` API is
unchanged. GET parameters use the query string and POST parameters use a form body;
non-success HTTP status codes fail, undecodable bodies complete without a value,
and offline URLSession errors map to `NetworkError.noConnection`. The local mock
host keeps its self-signed-certificate exception; other hosts use default trust.

## Validation

```bash
./scripts/buildPrebidMobile.sh       # four XCFrameworks and textual interfaces
./scripts/buildPrebidMobilePackage.sh
./scripts/verifyDevelopmentApps.sh  # native/SPM demos, internal/Skadn, test targets
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
selection gating, and clearing consent values. `testDevelopmentSupport.sh` also runs
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

The iOS 27 run exposed two compatibility issues outside this dependency change:

- The core PR plan passed 1,019 of 1,020 tests. `WebViewParityTests.testOutputMatchesObjectiveCOriginals`
  expects an invalid URL percent escape to remain `%E0%A4%A`; Foundation on iOS 27
  normalizes it to `%E0%A4%25A`, changing the captured parity output. Playback and
  JavaScript setup timeouts passed on the built-in retries.
- InternalTestApp cannot launch on iOS 27 when built with the iOS 27 SDK because
  UIKit now requires scene lifecycle adoption. The crash report identifies
  `_UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption`. The same app and
  all 10 support tests pass on iOS 26.5, which emits a future-adoption warning.

No SDK behavior, parity expectations, or app lifecycle code was changed to conceal
these differences. The published podspecs and published package manifests were not
modified.

### Follow-up: native builds from Xcode

Reproduced the adapter undefined-symbol failure in a regular InternalTestApp build
using Xcode's default DerivedData location. Giving only the command-line SPM demo a
separate derived-data directory did not protect builds started from Xcode itself.
The native project product paths now provide that separation for all build entry
points, while archive/install actions retain the standard per-scheme paths.

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
