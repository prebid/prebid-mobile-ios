# AGENTS.md

Canonical instructions for AI coding agents working in this repository. Codex, Cursor, and Copilot
read this file directly; Claude Code reaches it via the `@AGENTS.md` import in `CLAUDE.md`.

## Overview

Prebid Mobile iOS SDK — an open-source header bidding SDK that integrates with Prebid Server to increase ad yield. Version 3.3.0, supports iOS 13+, Swift 5.0+. Distributed via CocoaPods, SPM, and Carthage.

## Agent runbooks (`agents/`)

Detailed procedures live in `agents/` as plain markdown, readable by any agent. Read the relevant
file before acting rather than improvising the commands.

| Task | Read |
|------|------|
| Build the 4 XCFrameworks | `agents/build-sdk/SKILL.md` |
| Run tests, a single test class, or fix post-migration build errors | `agents/xcodebuild/SKILL.md` |
| Review a PR on this repo | `agents/review/SKILL.md` |
| Run SwiftLint | `agents/lint/SKILL.md` |
| CocoaPods install | `agents/pod-install/SKILL.md` |
| Generic iOS/Swift background (not repo-specific; playbook wins on conflicts) | `agents/ios/SKILL.md` |

## Commands

### Build

```bash
# Build all XCFrameworks (PrebidMobile, GAM, AdMob, MAX) into generated/output/
./scripts/buildPrebidMobile.sh

# Build and publish the SPM release
./scripts/buildPrebidSPM.sh
./scripts/publishSPM.sh
```

Requires CocoaPods installed (`pod` on PATH — GHA `macos-15` ships with it pre-installed). Build output goes to `generated/output/` as `XC<name>.xcframework` (e.g. `XCPrebidMobile.xcframework`). Logs go to `generated/log/prebid_mobile_build.log`. Build uses `Lib-`-prefixed scheme names (`Lib-PrebidMobile`, etc.) to avoid colliding with auto-generated SPM schemes.

### Tests

```bash
# Run PR subset (694 tests) — used on PRs in CI
./scripts/testPrebidMobile.sh --latest --quick

# Run full suite (1111 tests) — used on bump-to branches / run-full-tests label
./scripts/testPrebidMobile.sh --latest

# Run adapter tests (GAM, AdMob, MAX)
./scripts/testPrebidMobileAdapters.sh
```

Flags: `--latest` skips the legacy iOS 13 sanity test (always use locally); `--quick` switches the test plan from `PrebidMobileTests` (full) to `PrebidMobilePRTests` (PR subset). The script creates the `iPhone-16-Pro-PrebidMobile` simulator, runs `build-for-testing` then `test-without-building` with `-retry-tests-on-failure`, then deletes the simulator. Any pre-existing simulator with that name is deleted first.

Test plans: `PrebidMobileTests/PrebidMobileTests.xctestplan` (full, 1111 tests), `PrebidMobileTests/PrebidMobilePRTests.xctestplan` (PR subset, 694 tests).

**When adding new tests:** register every new test class in `PrebidMobileTests/PrebidMobilePRTests.xctestplan` so it runs on every PR. The full plan picks up all tests automatically; only the PR plan requires explicit registration.

To run a single test class:
```bash
# Step 1 — build once
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
  build-for-testing

# Step 2 — run (repeat as needed without rebuilding)
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
  -only-testing PrebidMobileTests/TargetingTests \
  test-without-building
```

See `agents/xcodebuild/SKILL.md` for a guided single-class run, and for the post-migration
build-error checklist.

### Setup

```bash
pod install --repo-update
```

Open `PrebidMobile.xcworkspace` (not `.xcodeproj`) for development.

## Architecture

### Workspace Structure

The workspace (`PrebidMobile.xcworkspace`) contains three projects:
- `PrebidMobile.xcodeproj` — core SDK + unit tests
- `EventHandlers/EventHandlers.xcodeproj` — ad network adapters
- `Example/PrebidDemo/PrebidDemo.xcodeproj` — demo apps

### Core SDK (`PrebidMobile/`)

Split between Swift and Objective-C layers:

**`PrebidMobile/Swift/`** — Public-facing Swift API:
- `Objc/Prebid.swift`, `Objc/Targeting.swift` — SDK configuration singleton and user targeting
- `Swift/AdUnits/` — `BannerAdUnit`, `InterstitialAdUnit`, `RewardedVideoAdUnit`, `InstreamVideoAdUnit`, `MultiformatAdUnit`
- `Swift/AdUnits/Native/` — Native ad unit types
- `Swift/ConfigurationAndTargeting/` — `AdUnitConfig`, targeting parameters
- `Swift/CacheManagement/` — bid caching layer
- `Swift/Host.swift` — Prebid Server endpoint configuration
- `Swift/Global.swift` — shared error types

**`PrebidMobile/Objc/`** — Internal Objective-C rendering engine:
- `PrebidMobileRendering/ORTB/` — OpenRTB bid request object model (`PBMORTBBidRequest`, `PBMORTBImp`, etc.)
- `PrebidMobileRendering/Networking/` — HTTP layer, URL building, impression tracking
- `PrebidMobileRendering/AdTypes/` — HTML creative rendering, MRAID, VAST/video
- `PrebidMobileRendering/3dPartyWrappers/OpenMeasurement/` — OMSDK integration
- `PrebidMobileRendering/Prebid/` — `PrebidAdUnit`, `PrebidRequest`, `BidInfo`

The `PrebidMobile_SPM` compile flag is set when building via SPM (not CocoaPods).

### Event Handlers / Adapters (`EventHandlers/`)

Thin wrappers that bridge Prebid bids into third-party ad SDKs:
- `PrebidMobileGAMEventHandlers/` — Google Ad Manager (GAM/DFP) banner, interstitial, rewarded
- `PrebidMobileAdMobAdapters/` — Google AdMob mediation adapters
- `PrebidMobileMAXAdapters/` — AppLovin MAX adapters

Each adapter has its own test target (`*Tests/`).

### SPM vs CocoaPods layout

**SPM** (Package.swift at root): `PrebidMobile` product = `PrebidMobile` target (Swift sources) + `__PrebidMobileInternal` target (ObjC sources). The `__PrebidMobileInternal` target depends on the bundled `Frameworks/OMSDK_Prebidorg.xcframework`.

**CocoaPods** (PrebidMobile.podspec): Single `core` subspec pulls all `PrebidMobile/**/*.{h,m,swift}` except Package.swift.

### Build schemes

Framework build uses `Lib-PrebidMobile`, `Lib-PrebidMobileGAMEventHandlers`, `Lib-PrebidMobileAdMobAdapters`, `Lib-PrebidMobileMAXAdapters` schemes (prefixed `Lib-` to avoid collision with auto-generated SPM schemes).

### CI

GitHub Actions (Xcode 16.4.0, macOS 15):
- PRs run quick tests (`--latest --quick`) unless labeled `run-full-tests`
- Branch names starting with `bump-to` trigger full test suite + UI/integration tests

## ObjC → Swift migration

Migration docs live in `docs/migration/`. Keep them current throughout every working session:

- **`docs/migration/playbook.md`** — per-class porting guide and gap decisions. Update when a new gap is discovered or a rule changes.
- **`docs/migration/pr-phase-0.md`** (and future `pr-phase-N.md` files) — PR-level summary of what was done, with a test-plan checklist. Update the relevant PR doc at the end of each session: add an `S<phase>.<step>` entry for completed work, tick test-plan checkboxes, and note any open items for the reviewer.

When starting work on a migration phase, read the relevant PR doc first to pick up prior context.
