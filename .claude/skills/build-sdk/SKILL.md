---
name: build-sdk
description: Build all four Prebid Mobile XCFrameworks via buildPrebidMobile.sh
---

Build all Prebid Mobile XCFrameworks for distribution. Run from the repo root:

```bash
./scripts/buildPrebidMobile.sh
```

## What it does

1. Deletes any previous `generated/` directory.
2. Runs `pod install --repo-update` (CocoaPods is pre-installed on GHA macos-15).
3. For each of four frameworks — `PrebidMobile`, `PrebidMobileGAMEventHandlers`,
   `PrebidMobileAdMobAdapters`, `PrebidMobileMAXAdapters` — it:
   - Archives for device (`iphoneos`, arm64) using scheme `Lib-<name>`
   - Archives for simulator (`iphonesimulator`, arm64 + x86_64) using scheme `Lib-<name>`
   - Bundles both archives + dSYMs into `generated/output/XC<name>.xcframework`
4. Prints the output path when done.

The `Lib-` prefix on scheme names avoids collision with auto-generated SPM schemes.

## Output

```
generated/output/
  XCPrebidMobile.xcframework            (~60 MB)
  XCPrebidMobileGAMEventHandlers.xcframework  (~21 MB)
  XCPrebidMobileAdMobAdapters.xcframework     (~22 MB)
  XCPrebidMobileMAXAdapters.xcframework       (~9 MB)
```

Each XCFramework contains an `ios-arm64` (device) and `ios-arm64_x86_64-simulator` slice.

## Logs

Build output is streamed to `generated/log/prebid_mobile_build.log`. On failure the
script prints the log path and exits non-zero.

## SPM

To build or publish the SPM release instead:

```bash
./scripts/buildPrebidSPM.sh
./scripts/publishSPM.sh
```
