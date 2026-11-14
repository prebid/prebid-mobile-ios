# Development dependencies

The repository's Xcode workspace uses Swift Package Manager. CocoaPods remains a
customer distribution option through the core and adapter podspecs. Building this
repository does not require CocoaPods, a Podfile, or a generated Pods project.

## Versions and resolution

| Package product | Exact version |
| --- | --- |
| GoogleMobileAds | 13.12.0 |
| GoogleInteractiveMediaAds | 3.33.0 |
| AppLovinSDK | 13.6.4 |
| GoogleUserMessagingPlatform (Google dependency) | 3.1.0 |

These match the previous development Podfile.lock. The three Xcode projects have
exact requirements for the vendor SDKs. They share the committed workspace lockfile,
`PrebidMobile.xcworkspace/xcshareddata/swiftpm/Package.resolved`, which also pins
indirect dependencies. `resolveDependencies.sh` resolves with
`-onlyUsePackageVersionsFromResolvedFile`, so a lockfile that no longer matches the
projects fails instead of being rewritten. This workspace contains only native
projects and vendor packages, so published Prebid requirements cannot block a
native vendor-major upgrade.

The published consumer lives in the standalone
`Example/PrebidDemo/PrebidDemoSPM.xcodeproj`. Open it separately from the native
workspace. It retains the adapters' `main` branch requirement and gets the core,
GoogleMobileAds, and AppLovinSDK products transitively through that graph. It does
not impose separate Google/AppLovin version requirements; candidate adapter
manifests can therefore change their supported major versions before publication.
Its project lockfile stays ignored, like every lockfile Xcode writes when a single
`.xcodeproj` is opened on its own. Existing local checkouts can use Xcode's Update to
Latest Package Versions command.

The root `Package.swift` retains its consumer version ranges. Its committed
`Package.resolved` selects the same tested vendor versions for the local package
build, which uses `--force-resolved-versions`. Published package manifests and
podspecs retain their customer-facing requirements.

```bash
./scripts/resolveDependencies.sh
```

Scripts keep checkouts and binary artifacts in `.swiftpm-cache/`, outside
`generated/`, so archive builds can delete their output without deleting the cache.
CI keys that cache by Xcode version and the workspace lockfile, through the
`.github/actions/cache-swift-packages` composite action. Xcode opened interactively
can use its default package cache. Standalone consumer builds use
`.swiftpm-spm-demo-cache/` and `.build/spm-demo/`. Separate package directories keep
one graph's checkout or binary artifact from replacing another graph's vendor
version. Xcode's default DerivedData also separates the native workspace from the
standalone consumer project.

To update a vendor dependency deliberately, change its exact requirement in the
three projects, resolve the workspace without the frozen-lockfile flag, and refresh
the root lockfile to the same versions:

```bash
xcodebuild -resolvePackageDependencies -workspace PrebidMobile.xcworkspace \
    -scheme Lib-PrebidMobile -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache"
swift package update <package identity>
```

Commit the project requirements together with both lockfiles, so the bump is visible
in review. The release verifier creates a temporary workspace referencing the
consumer project, with its own lockfile, package cache, and DerivedData; it never
modifies the committed lockfiles. PR checks build this consumer against locally
staged candidate packages before publication; release checks also build against the
published packages afterward.

## Targets and linking

GAM/AdMob frameworks and their unit tests depend on GoogleMobileAds. MAX frameworks
and tests depend on AppLovinSDK. Both native demo apps, the SPM demo, and both
InternalTestApp variants depend on all three vendor SDKs. The adapter unit tests run
without a host app and link GoogleMobileAds explicitly. `InternalTestAppTests` and
`PrebidDemoTests` import it but do not link it: they run inside their host app and use
its copy, so a test run has one SDK state. UI tests obtain their dependencies through
the tested app. OpenXMockServer and its tests use only system frameworks.

Native and published Prebid products share module/framework names. Keeping the
consumer in a separate project gives both command-line and Xcode builds separate
package graphs and default product directories. Native projects use standard Xcode
product paths. When switching from an earlier shared-container layout, use
Product > Clean Build Folder once in the native workspace to discard any previously
mixed native/published modules.

`verifyDevelopmentApps.sh` builds five native app/test configurations. Its optional
`--with-spm-demo` flag also calls `buildPrebidSPM.sh` for the standalone published
consumer, using separate caches/products. PR CI omits that flag because demo changes
may use SDK APIs that have not been published. A separate PR job runs `verifySPM.sh`
against candidate package sources, so those API changes can still be verified before
release. `verifyDependencyIsolation.sh` checks that the committed workspace lockfile
pins no published Prebid package, and that the consumer takes Google Mobile Ads and
AppLovin from the adapters package.

Google Mobile Ads and the User Messaging Platform ship as static binaries. The GAM
and AdMob adapter targets are built as static frameworks in Debug and Release
(`MACH_O_TYPE = $(PREBID_ADAPTER_MACH_O_TYPE)`, which defaults to `staticlib`), so
those SDKs are linked once, into the app or the adapter test bundle. Linked into
dynamic adapter frameworks, as CocoaPods also did, every adapter framework and the
app each carried a copy with its own state: the runtime reported about 800
`Class … is implemented in both` warnings at launch, and SDK singletons such as
`MobileAds.shared` were separate objects per image. Xcode embeds an empty
placeholder for a static framework listed under Embed Frameworks; nothing loads it.

`buildPrebidMobile.sh` passes `PREBID_ADAPTER_MACH_O_TYPE=mh_dylib`, so the
distributed XCFrameworks stay dynamic. Only the two adapter targets read that
setting; overriding `MACH_O_TYPE` itself on the command line would also change the
package targets in that build.

AppLovinSDK ships as a dynamic framework, so only one copy is loaded however the
MAX adapter is linked, and the MAX adapter stays a dynamic framework. App and
test targets keep Xcode's package diamond diagnostic disabled: with it enabled, Xcode
moves AppLovinSDK, which both the MAX adapter and the apps use, into a synthesized
dynamic wrapper, and `PrebidDemoObjectiveC`, which uses AppLovin classes directly,
fails to link. Each Google/AppLovin consumer explicitly retains `-ObjC`. None of this
changes the linking requirements of the published adapters. The standalone SPM
consumer links each package product once, into the app, so it keeps Xcode's
defaults, as a customer app would.

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
and the multiformat selection rule remain available; a configuration controller
whose owner is missing or of the wrong type still asserts in Debug. The unused
native editor row helper and the optional HUD setting were deleted. Text, toggle,
and display cells are dequeued, with controls/constraints built once.
Reconfiguration updates the bound row, callbacks, accessibility identifiers, and
presentation state.

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

The test scripts create their simulator through `scripts/simulator.sh`. It first
deletes every device with exactly the same name that an interrupted run left behind.
It finds them in the JSON from `simctl list -j devices`, read with `python3` (which
`verifySPM.sh` also uses), so a name matches only itself: a backslash, a tab, a leading
space or a non-ASCII character is never treated as another character. If listing,
reading or deleting those devices fails or times out, the script stops rather than
create a second device with that name. It then creates the simulator and deletes it by
its UUID when the script exits, on failure too. Its defaults can be overridden
through the environment: `PREBID_SIMULATOR_NAME`, `PREBID_SIMULATOR_DEVICE_TYPE`,
and `PREBID_TEST_RUNTIME`. The runtime defaults to the latest installed one; set
`PREBID_TEST_RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-26-5` to use the CI runtime
on a machine that also has iOS 27 installed. Destinations use the created simulator's
UUID, so a runtime override cannot accidentally select another device.

Every `simctl` call has a time limit, since a stalled CoreSimulator can stall any of
them:

| Call | Limit |
| --- | --- |
| `list` | 60 s |
| `create`, `delete` | 120 s each |
| `bootstatus`, the first boot in `testPrebidMobile.sh` | `PREBID_SIMULATOR_BOOT_TIMEOUT`: a whole number of seconds from 1 to 86400, default 900 |
| `diagnose`, after a failed boot | 600 s |

A call is never stopped before its limit. Because the shell counts whole seconds, it can
run up to about 2 s longer. The call's whole process group then gets SIGTERM, SIGKILL
after 5 s, and up to 5 s more to exit. A process that survives that is reported and left
running; the script does not wait for it. A call that exits but leaves processes running
in its group is treated as still running until they finish or are stopped. A stopped
call returns 124.

After a boot timeout, `testPrebidMobile.sh` exits with status 124, even if collecting
diagnostics or deleting the simulator fails. Collecting the diagnostics (a `list`, then
`diagnose`) and deleting the simulator add at most about 14 minutes after the boot
limit: 12 s to stop the boot wait, then 72, 612 and 132 s for the three calls, each
including its overrun and shutdown time. Each failed boot writes a new folder, named
after the time and the simulator's UUID, under `PREBID_SIMULATOR_DIAGNOSTICS_DIR`
(default `generated/log/simulator-diagnostics/`, which CI uploads). Earlier reports stay
in their own folders and never mix with the current one.

What a signal does depends on what the script is running when it arrives.

During a `simctl` call, SIGINT, SIGTERM or SIGHUP, sent to the script or to its process
group (Ctrl-C in a terminal), stops that call, deletes the simulator, and ends the script
with status 130, 143 or 129. If creation was interrupted before `simctl` printed the
UUID, the device is found by its exact name.

While a caller runs its own foreground command, such as `xcodebuild`, Bash's default
handling applies, as it did before these changes. On Bash 3.2:

- SIGTERM or SIGHUP ends the script at once, and the exit trap deletes the simulator.
  If only the script received the signal, the foreground command keeps running.
- SIGINT to the process group, such as Ctrl-C, ends the command and the script, and the
  exit trap deletes the simulator (status 130). This holds when the script is a file, as
  all four callers are. When the same code runs through `bash -c`, Bash skips the exit
  trap and the simulator is left behind.
- SIGINT sent only to the script's process ID is ignored: the command finishes and the
  script carries on.

The simulator can also be left behind in these cases:

- The script is killed with SIGKILL.
- Only an outer shell receives the signal, as when a CI runner signals the step's shell
  and later kills the remaining processes.
- A signal interrupts the final deletion, including the one that runs after an ordinary
  exit: the signal stops `simctl delete` and ends the script.

The next run that uses the same name deletes a device left behind.

`DevelopmentFormsTests` covers configuration edits, refresh reset, multiformat
selection gating, clearing consent values, and cell reuse without stale callbacks
or presentation state. `testDevelopmentSupport.sh` also runs
the existing configuration-sheet UI smoke test, which checks that the refresh field
and load button remain accessible. It uses its own simulator.
