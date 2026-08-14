#!/usr/bin/env bash

set -o pipefail

DEMO_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_REPOSITORY_ROOT="$(cd "${DEMO_SCRIPT_DIRECTORY}/.." && pwd)"
DEMO_SIMULATOR_NAME="iPhone-17-Pro-PrebidMobile"
DEMO_TEST_RESULTS_DIRECTORY="${DEMO_REPOSITORY_ROOT}/TestResults"

cd "${DEMO_REPOSITORY_ROOT}"

# Set bash script to exit immediately if any commands fail.
set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}RUN PREBID DEMO TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
DEMO_SIMULATOR_UDID="$(xcrun simctl create "${DEMO_SIMULATOR_NAME}" com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro)"

cleanup_demo_simulator() {
    xcrun simctl delete "${DEMO_SIMULATOR_UDID}" > /dev/null 2>&1 || true
}

collect_demo_simulator_logs() {
    mkdir -p "${DEMO_TEST_RESULTS_DIRECTORY}"
    xcrun simctl spawn "${DEMO_SIMULATOR_UDID}" log show \
        --style compact \
        --last 30m \
        > "${DEMO_TEST_RESULTS_DIRECTORY}/${TEST}-simulator.log" 2>&1 || true
}

trap cleanup_demo_simulator EXIT

xcrun simctl boot "${DEMO_SIMULATOR_UDID}"
xcrun simctl bootstatus "${DEMO_SIMULATOR_UDID}" -b

echo $PWD

if ! command -v pod >/dev/null 2>&1; then
    echo "CocoaPods is required but 'pod' was not found on PATH." >&2
    echo "GitHub Actions 'macos-26' ships it preinstalled; install it locally with 'brew install cocoapods'." >&2
    exit 1
fi

if ! pod install --repo-update --deployment; then
    echo "🔴 CocoaPods dependency installation failed" >&2
    exit 1
fi

if [ "$1" == "-ui" ]; then
    echo -e "\n${GREEN}Running UI tests${NC} \n"
    SCHEME="PrebidDemoSwiftUITests"
    TEST="UI"
else
    echo -e "\n${GREEN}Running integration tests${NC} \n"
    SCHEME="PrebidDemoTests"
    TEST="Integration"
fi

mkdir -p "${DEMO_TEST_RESULTS_DIRECTORY}"
DEMO_RESULT_BUNDLE="${DEMO_TEST_RESULTS_DIRECTORY}/PrebidDemo-${TEST}-${GITHUB_RUN_ID:-local}-${GITHUB_RUN_ATTEMPT:-0}-$$.xcresult"

echo -e "\n\n${GREEN}Building ${SCHEME} for testing${NC}\n\n"

# `set -e` would abort the script on a failing xcodebuild before the diagnostics below run,
# so take the exit status explicitly and keep them reachable.
DEMO_BUILD_EXIT_CODE=0
xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -scheme $SCHEME \
    -sdk iphonesimulator \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=${DEMO_SIMULATOR_UDID}" \
    -destination-timeout 60 \
    build-for-testing || DEMO_BUILD_EXIT_CODE=$?

if [[ ${DEMO_BUILD_EXIT_CODE} != 0 ]]; then
    collect_demo_simulator_logs
    echo "🔴 ${TEST} Test Build Failed"
    exit "${DEMO_BUILD_EXIT_CODE}"
fi

echo -e "\n\n${GREEN}Testing ${SCHEME}${NC}\n\n"

DEMO_TEST_EXIT_CODE=0
xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -scheme $SCHEME \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,id=${DEMO_SIMULATOR_UDID}" \
    -destination-timeout 60 \
    -test-iterations 2 \
    -retry-tests-on-failure \
    -resultBundlePath "${DEMO_RESULT_BUNDLE}" \
    test-without-building || DEMO_TEST_EXIT_CODE=$?

if [[ ${DEMO_TEST_EXIT_CODE} == 0 ]]; then
    echo "✅ ${TEST} Tests Passed"
else
    collect_demo_simulator_logs
    echo "🔴 ${TEST} Tests Failed"
    exit "${DEMO_TEST_EXIT_CODE}"
fi
