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

# Published Prebid packages have the same product names as the local framework
# targets. Keep their build products separate to avoid replacing local binaries.
xcodebuild build \
    -workspace PrebidMobile.xcworkspace \
    -scheme PrebidDemoSPM \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$PWD/.build/spm-demo" \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
    -disableAutomaticPackageResolution \
    CODE_SIGNING_ALLOWED=NO
