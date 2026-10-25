#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/resolveDependencies.sh

# Compile the app, unit-test, and UI-test targets without running network-based
# integration tests. The Objective-C and SPM demos also need explicit coverage.
for scheme in PrebidDemoTests PrebidDemoSwiftUITests InternalTestApp; do
    xcodebuild build-for-testing \
        -workspace PrebidMobile.xcworkspace \
        -derivedDataPath "$PWD/.build/development-apps" \
        -scheme "$scheme" \
        -sdk iphonesimulator \
        -destination 'generic/platform=iOS Simulator' \
        -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
        -disableAutomaticPackageResolution \
        CODE_SIGNING_ALLOWED=NO
done
for scheme in PrebidDemoObjectiveC InternalTestApp-Skadn; do
    xcodebuild build \
        -workspace PrebidMobile.xcworkspace \
        -derivedDataPath "$PWD/.build/development-apps" \
        -scheme "$scheme" \
        -sdk iphonesimulator \
        -destination 'generic/platform=iOS Simulator' \
        -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
        -disableAutomaticPackageResolution \
        CODE_SIGNING_ALLOWED=NO
done

# Exercise the same derived-data directory for native and published-package
# builds, as Xcode does interactively. Project settings must keep their products
# separate; a script-only derived-data override would hide a GUI build failure.
xcodebuild build \
    -workspace PrebidMobile.xcworkspace \
    -scheme PrebidDemoSPM \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$PWD/.build/development-apps" \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
    -disableAutomaticPackageResolution \
    CODE_SIGNING_ALLOWED=NO

# Rebuild the native app after the SPM demo to catch overwritten modules/binaries.
xcodebuild build \
    -workspace PrebidMobile.xcworkspace \
    -scheme InternalTestApp \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$PWD/.build/development-apps" \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
    -disableAutomaticPackageResolution \
    CODE_SIGNING_ALLOWED=NO
