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
app's missing scene lifecycle. Both are addressed in the
[iOS 27 follow-up](migration/pr-phase-7-ios-27.md), along with the video status
callback race found during verification. The published podspecs and published
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
