#!/usr/bin/env bash

cd "$(dirname "$0")/.."

# Set bash script to exit immediately if any commands fail.
set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}RUN PREBID DEMO TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
xcrun simctl delete iPhone-17-Pro-PrebidMobile 2>/dev/null || true
SIMULATOR_ID="$(xcrun simctl create iPhone-17-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro ${PREBID_TEST_RUNTIME:+"$PREBID_TEST_RUNTIME"})"

echo $PWD

./scripts/resolveDependencies.sh

if [ "$1" == "-ui" ]; then
    echo -e "\n${GREEN}Running UI tests${NC} \n"
    SCHEME="PrebidDemoSwiftUITests"
    TEST="UI"
else
    echo -e "\n${GREEN}Running integration tests${NC} \n"
    SCHEME="PrebidDemoTests"
    TEST="Integration"
fi

echo -e "\n\n${GREEN}Building ${SCHEME} for testing${NC}\n\n"

xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -derivedDataPath "$PWD/.build/demo-tests" \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
    -disableAutomaticPackageResolution \
    -scheme $SCHEME \
    -sdk iphonesimulator \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    -destination-timeout 60 \
    build-for-testing

echo -e "\n\n${GREEN}Testing ${SCHEME}${NC}\n\n"

# `set -e` would abort the script on a failing xcodebuild before the report below runs,
# so take the exit status explicitly and keep the diagnostic reachable.
TEST_STATUS=0
xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -derivedDataPath "$PWD/.build/demo-tests" \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
    -disableAutomaticPackageResolution \
    -scheme $SCHEME \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    -destination-timeout 60 \
    -test-iterations 2 \
    -retry-tests-on-failure \
    test-without-building || TEST_STATUS=$?

if [[ ${TEST_STATUS} == 0 ]]; then
    echo "✅ ${TEST} Tests Passed"
else
    echo "🔴 ${TEST} Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Removing simulator${NC} \n"
xcrun simctl delete iPhone-17-Pro-PrebidMobile
