#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/resolveDependencies.sh

SIMULATOR_NAME=iPhone-17-Pro-PrebidSupport
xcrun simctl delete "$SIMULATOR_NAME" 2>/dev/null || true
SIMULATOR_ID="$(xcrun simctl create "$SIMULATOR_NAME" com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro ${PREBID_TEST_RUNTIME:+"$PREBID_TEST_RUNTIME"})"
trap 'xcrun simctl delete "$SIMULATOR_ID"' EXIT

for action in build-for-testing test-without-building; do
    xcodebuild "$action" \
        -workspace PrebidMobile.xcworkspace \
        -derivedDataPath "$PWD/.build/development-apps" \
        -scheme InternalTestApp \
        -parallel-testing-enabled NO \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
        -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
        -disableAutomaticPackageResolution \
        -only-testing:InternalTestAppTests/DevelopmentFormsTests \
        -only-testing:OpenXMockServerTests/OpenXMockServerTests \
        -only-testing:InternalTestAppUITests/ConsolidatedBannerUITest/testOpenSettings
done
