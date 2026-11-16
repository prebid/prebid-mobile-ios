#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

source ./scripts/simulator.sh

./scripts/resolveDependencies.sh

# Its own device, so it can run next to the framework test scripts on one machine.
create_test_simulator "$PREBID_SIMULATOR_NAME-Support"

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
