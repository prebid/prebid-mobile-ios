# AGENTS.md

Canonical instructions for AI coding agents working in this repository. Codex, Cursor, and Copilot
read this file directly; Claude Code reaches it via the `@AGENTS.md` import in `CLAUDE.md`.

## Overview

Prebid Mobile iOS SDK — an open-source header bidding SDK that integrates with Prebid Server to increase ad yield. Version 3.3.0, supports iOS 15+, Swift 5.0+. Distributed via CocoaPods, SPM, and Carthage.

## Agent runbooks (`agents/`)

Detailed procedures live in `agents/` as plain markdown, readable by any agent. Read the relevant
file before acting rather than improvising the commands.

Claude Code additionally loads these as Agent Skills through the committed `.claude/skills`
symlink, which points at `agents/`. `agents/` remains the single source of truth — do not duplicate
files under `.claude/`.

| Task | Read |
|------|------|
| Build the 4 XCFrameworks | `agents/build-sdk/SKILL.md` |
| Run tests, a single test class, or fix post-migration build errors | `agents/xcodebuild/SKILL.md` |
| Review a PR on this repo | `agents/review/SKILL.md` |
| Run SwiftLint | `agents/lint/SKILL.md` |
| Resolve development dependencies | `agents/resolve-dependencies/SKILL.md` |
| Generic iOS/Swift background (not repo-specific; playbook wins on conflicts) | `agents/ios-development/SKILL.md` |
| Generic ObjC → Swift / XCTest migration background (playbook wins on conflicts) | `agents/migration-patterns/SKILL.md` |

## Commands

### Build

```bash
# Build all XCFrameworks (PrebidMobile, GAM, AdMob, MAX) into generated/output/
./scripts/buildPrebidMobile.sh

# SPM release (run by .github/workflows/SPM.yml on version tags, in this order)
./scripts/verifySPM.sh      # build the SPM demo against local copies of both packages; pushes nothing
./scripts/syncSPM.sh        # copy the package sources into a checkout of an SPM repo
./scripts/publishSPM.sh     # commit, push and tag that checkout
./scripts/buildPrebidSPM.sh # build the SPM demo against the published packages
```

Development dependencies use Swift Package Manager; CocoaPods is not required to build this workspace. Build output goes to `generated/output/` as `XC<name>.xcframework` (e.g. `XCPrebidMobile.xcframework`). Logs go to `generated/log/prebid_mobile_build.log`. The script ends by running `./scripts/verifyXCFrameworkInterfaces.sh`, which typechecks each XCFramework's `.swiftinterface` files the way a consumer's compiler does; `xcodebuild` skips that check, so a broken interface otherwise archives cleanly. Build uses `Lib-`-prefixed scheme names (`Lib-PrebidMobile`, etc.) to avoid colliding with auto-generated SPM schemes.

### Tests

```bash
# Run PR subset (1067 tests) — used on PRs in CI
./scripts/testPrebidMobile.sh --latest --quick

# Run full suite (1478 tests) — used on bump-to branches / run-full-tests label
./scripts/testPrebidMobile.sh --latest

# Run adapter tests (GAM, AdMob, MAX)
./scripts/testPrebidMobileAdapters.sh
```

Flags: `--latest` is a no-op kept for backward compatibility (the old iOS 13 sanity run is gone); `--quick` switches the test plan from `PrebidMobileTests` (full) to `PrebidMobilePRTests` (PR subset). The script creates the `iPhone-17-Pro-PrebidMobile` simulator, runs `build-for-testing` then `test-without-building` with `-retry-tests-on-failure`, then deletes the simulator, on failure too. Any pre-existing simulator with that name is deleted first; if that fails, the script stops instead of creating a second one.

The test scripts share `scripts/simulator.sh`, which sets the simulator name and device type; override them with `PREBID_SIMULATOR_NAME` and `PREBID_SIMULATOR_DEVICE_TYPE`. Use `PREBID_TEST_RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-26-5` to select the CI runtime locally when a newer runtime is also installed. The default remains the latest installed runtime. `testPrebidMobile.sh` gives the first boot `PREBID_SIMULATOR_BOOT_TIMEOUT` seconds (a whole number from 1 to 86400, default 900). If the boot has not finished by then, it stops waiting, which takes up to about 12 more seconds (whole-second timing, then SIGTERM, SIGKILL after 5 s, and up to 5 s more). It then writes simulator diagnostics to a new folder under `generated/log/simulator-diagnostics/`, which CI uploads as an artifact, and exits with status 124. The other `simctl` calls have limits too (list 60 s, create and delete 120 s, diagnose 600 s), so a stalled CoreSimulator adds at most about 14 minutes after the boot limit. A SIGINT, SIGTERM or SIGHUP that arrives during a `simctl` call stops the call and deletes the simulator (exit status 130, 143 or 129). During the callers' own foreground commands, such as `xcodebuild`, Bash's default handling applies, unchanged: SIGTERM, SIGHUP and Ctrl-C still delete the simulator, but a SIGINT sent only to the script's PID is ignored until the command finishes. SIGKILL, a signal that reaches only an outer shell, or a signal during the final deletion can leave the simulator behind. See `docs/development-dependencies.md` for the details.

Test plans: `PrebidMobileTests/PrebidMobileTests.xctestplan` (full, 1478 tests), `PrebidMobileTests/PrebidMobilePRTests.xctestplan` (PR subset, 1067 tests).

**When adding new tests:** both plans select by *exclusion*, so a new test class runs on every PR without any registration step. `PrebidMobilePRTests.xctestplan` trims the suite via a `skippedTests` list — check that a new class isn't (prefix-)matched there, and add an entry only if you deliberately want it excluded from the PR subset.

To run a single test class:
```bash
# Step 1 — build once
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone-17-Pro-PrebidMobile,OS=latest' \
  build-for-testing

# Step 2 — run (repeat as needed without rebuilding)
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone-17-Pro-PrebidMobile,OS=latest' \
  -only-testing PrebidMobileTests/TargetingTests \
  test-without-building
```

See `agents/xcodebuild/SKILL.md` for a guided single-class run, and for the post-migration
build-error checklist.

### Setup

```bash
./scripts/resolveDependencies.sh
```

Open `PrebidMobile.xcworkspace` for native development. Its projects pin vendor
SDK versions exactly and share the committed workspace `Package.resolved`, which
`resolveDependencies.sh` uses as is (`-onlyUsePackageVersionsFromResolvedFile`). Scripts use `.swiftpm-cache/` for package checkouts and binary artifacts. The root
package retains consumer version ranges; its committed `Package.resolved` selects
the tested vendor versions for local SPM builds. To update a vendor dependency,
change the exact project requirements, then commit the refreshed workspace and root lockfiles. See
`docs/development-dependencies.md`.

Open `Example/PrebidDemo/PrebidDemoSPM.xcodeproj` separately to build the published
SPM consumer. Keep it outside the native workspace: Xcode resolves one package
graph per container, and published adapter ranges must not constrain native vendor
upgrades. It shares demo sources and resources, but has independent project IDs,
DerivedData, and package resolution. Command-line consumer builds use
`.build/spm-demo/` and `.swiftpm-spm-demo-cache/`. Native projects use Xcode's standard
product paths; no `LocalPrebid` build-folder override is needed.

```bash
./scripts/verifyDevelopmentApps.sh # compile demo, internal, Skadn, and test/UI-test targets
./scripts/verifyDevelopmentApps.sh --with-spm-demo # also build the standalone published consumer
./scripts/verifyDependencyIsolation.sh # check that the native and published package graphs stay separate
./scripts/testDevelopmentSupport.sh # run the internal app's form, mock-server and settings smoke tests
```

PR CI runs `verifyDevelopmentApps.sh` without `--with-spm-demo`: the SPM demo compiles the
Swift demo sources against the published packages, so it fails any PR that uses new SDK API in
the demo until that API is released. A separate PR job runs `verifySPM.sh` against
candidate package sources in a temporary consumer workspace, validating new APIs and
vendor-major upgrades before publication.

## Architecture

### Workspace Structure

The workspace (`PrebidMobile.xcworkspace`) contains five projects:
- `PrebidMobile.xcodeproj` — core SDK + unit tests
- `EventHandlers/EventHandlers.xcodeproj` — ad network adapters
- `Example/PrebidDemo/PrebidDemo.xcodeproj` — demo apps
- `InternalTestApp/InternalTestApp.xcodeproj` — internal apps and mock server
- `tools/TestUtils/TestUtils.xcodeproj` — shared testing helpers

The published-package consumer is a separate project,
`Example/PrebidDemo/PrebidDemoSPM.xcodeproj`, and must not be added to this workspace.

### Core SDK (`PrebidMobile/`)

The SDK is Swift. `PrebidMobile/Objc/` holds no `.m` files; one header remains, and it exists for the test target:

**`PrebidMobile/Swift/`** — the SDK:
- `Swift/AdUnits/` — `BannerAdUnit`, `InterstitialAdUnit`, `RewardedVideoAdUnit`, `InstreamVideoAdUnit`, `MultiformatAdUnit`; `AdUnits/Native/` — native ad unit types
- `Swift/ConfigurationAndTargeting/` — `Prebid`, `Targeting`, `AdUnitConfig`, targeting parameters
- `Swift/CacheManagement/` — bid caching layer
- `Swift/Host.swift` — Prebid Server endpoint configuration
- `Swift/Global.swift` — shared error types
- `Swift/Factory.swift` — constructs the internal implementation classes
- `Swift/PrebidMobileRendering/` — the former Objective-C rendering engine: `Prebid/PBMCore/ORTB/` (OpenRTB model), `Networking/`, `AdTypes/` (HTML/MRAID/VAST), `3dPartyWrappers/OpenMeasurement/` (OMSDK), `Prebid/` (`PrebidAdUnit`, `PrebidRequest`, `BidInfo`)

**`PrebidMobile/Objc/PrivateHeaders/`** — `SwiftImport.h` (the `PrebidMobile-Swift.h` umbrella) is imported by the ObjC test files that prove the public API is callable from Objective-C apps. Those tests stay Objective-C on purpose: see `docs/migration/playbook.md`, S9.x.

### Event Handlers / Adapters (`EventHandlers/`)

Thin wrappers that bridge Prebid bids into third-party ad SDKs:
- `PrebidMobileGAMEventHandlers/` — Google Ad Manager (GAM/DFP) banner, interstitial, rewarded
- `PrebidMobileAdMobAdapters/` — Google AdMob mediation adapters
- `PrebidMobileMAXAdapters/` — AppLovin MAX adapters

Each adapter has its own test target (`*Tests/`).

### SPM vs CocoaPods layout

**SPM**: root `Package.swift` builds local core and adapter products with consumer version ranges; its lockfile selects the development versions. `PrebidMobile/Package.swift` and `EventHandlers/Package.swift` are the published package manifests; their consumer version ranges are independent. The core depends on the bundled `Frameworks/OMSDK_Prebidorg.xcframework`.

**CocoaPods** (PrebidMobile.podspec): Single `core` subspec pulls all `PrebidMobile/**/*.{h,m,swift}` except Package.swift.

### Build schemes

Framework build uses `Lib-PrebidMobile`, `Lib-PrebidMobileGAMEventHandlers`, `Lib-PrebidMobileAdMobAdapters`, `Lib-PrebidMobileMAXAdapters` schemes (prefixed `Lib-` to avoid collision with auto-generated SPM schemes).

### CI

GitHub Actions (macOS 26, with the Xcode version in `.xcode-version`, selected by `.github/actions/select-xcode`):
- PRs run quick tests (`--latest --quick`) unless labeled `run-full-tests`
- Branch names starting with `bump-to` trigger full test suite + UI/integration tests
- Version tags run the SPM sync (`SPM.yml`): the SPM demo must build against local copies of both packages before anything is pushed to `prebid-mobile-ios-sdk` and `prebid-mobile-ios-adapters`, and GitHub releases are created only after the demo also builds against the published packages

## Test seams

`DEBUG` does not mean "our tests". `#if DEBUG` is conditional compilation: the code exists only in builds where the `DEBUG` compilation condition is set. CocoaPods and SwiftPM compile the SDK from source with the app's own build configuration. Their standard Debug configuration defines `DEBUG` for the SDK target, so a publisher's Debug build compiles the SDK's `#if DEBUG` code in and their Release build leaves it out, and publishers would be debugging code that does not ship. With custom configurations it depends on the SDK target's effective compiler flags. Rules for code that exists so tests can reach into `PrebidMobile/` or `EventHandlers/`:

- No `#if DEBUG` that changes runtime behavior or the public API. `#if DEBUG` is for logging and test-only factory functions.
- No global mutable state or `UserDefaults` flags as test seams.
- Dependencies come in through an initializer or a property that defaults to the production implementation. Tests reach internal members through `@testable import`.
- If a test needs a seam only to avoid a heavy subsystem (WebKit, AVFoundation, the network), first look for a fixture or a test level that does not use it.
- A value that only tests read (such as the latest GMA version the adapters were tested with) lives in the test target.

Check: `grep -rn "#if DEBUG" PrebidMobile EventHandlers` lists only logging and test-only factory functions. Global state that tests still change, such as the `Functions.application` override and `PrebidServerConnection.shared.protocolClasses`, is listed in the playbook; do not add more. A test that changes `PrebidServerConnection.shared.protocolClasses` restores it in a teardown block; prefer a connection of the test's own. Seams that are fine as they are, the remaining ones, and how tests replaced the ones that were removed: `docs/migration/playbook.md`, "Test seams in SDK sources".

For tests that need viewability: a creative's impression uses the legacy visibility check, under which a view with no area can count (when its position falls within its ancestors' bounds and nothing visible sits above it at window level), so give the ad a size and assert it. Put the ad on screen with `UtilitiesForTesting.showOnScreen(_:)`. In the unhosted `PrebidMobileTests` configuration a modal presentation has been observed not to complete (animated or not, also with a key window), so anything that needs a presented modal on screen needs a hosted test. To test what code does when it presents a modal, present from a `MockPresentedViewController`, which records the presented controller, not from a view controller in a window.

## ObjC → Swift migration

Migration docs live in `docs/migration/`. Keep them current throughout every working session:

- **`docs/migration/playbook.md`** — per-class porting guide and gap decisions. Update when a new gap is discovered or a rule changes.
- **`docs/migration/pr-phase-<phases>.md`** — one file per *pull request*, not per phase (phases 0–2 shipped together as `pr-phase-012.md`). PR-level summary of what was done, with a test-plan checklist. Update it at the end of each session: add an `S<phase>.<step>` entry for completed work, tick test-plan checkboxes, and note any open items for the reviewer. Do not leave superseded drafts behind — the merged PR doc is the record.

When starting work on a migration phase, read the playbook and the most recent PR doc first to pick up prior context.
