if [ -d "scripts" ]; then
cd scripts/
fi

usage() {
  cat <<'USAGE'
Usage: testPrebidMobileAdapters.sh
USAGE
}

set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}INSTALL PODS${NC}\n\n"

cd ..

if ! command -v pod >/dev/null 2>&1; then
    echo "CocoaPods is required but 'pod' was not found on PATH." >&2
    echo "GitHub Actions 'macos-15' ships it preinstalled; install it locally with 'brew install cocoapods'." >&2
    exit 1
fi

pod install --repo-update

echo -e "\n\n${GREEN}RUN PREBID MOBILE ADAPTER TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro

echo -e "\n${GREEN}Clean build\n"
xcodebuild clean build

function testAdapters () {
  local SCHEME="$1"

    # Callers invoke this as `testAdapters … || TEST_STATUS=$?`, which suspends `set -e`
    # for the whole body — so a build failure has to short-circuit explicitly, or the
    # test run below would go ahead against stale products.
    xcodebuild \
        -workspace PrebidMobile.xcworkspace \
        -scheme "${SCHEME}" \
        -sdk iphonesimulator \
        -configuration Debug \
        -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
        -destination-timeout 60 \
        build-for-testing || return $?

    xcodebuild \
        -workspace PrebidMobile.xcworkspace \
        -scheme "${SCHEME}" \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
        -destination-timeout 60 \
        test-without-building
}

echo -e "\n${GREEN}Running PrebidMobileGAMEventHandlers unit tests${NC} \n"

# `set -e` would abort the script on a failing xcodebuild before the report below runs,
# so take the exit status explicitly and keep the diagnostic reachable.
TEST_STATUS=0
testAdapters "PrebidMobileGAMEventHandlersTests" || TEST_STATUS=$?

if [[ ${TEST_STATUS} == 0 ]]; then
    echo "✅ PrebidMobileGAMEventHandlers Unit Tests Passed"
else
    echo "🔴 PrebidMobileGAMEventHandlers Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Running PrebidMobileAdMobAdapters unit tests${NC} \n"

TEST_STATUS=0
testAdapters "PrebidMobileAdMobAdaptersTests" || TEST_STATUS=$?

if [[ ${TEST_STATUS} == 0 ]]; then
    echo "✅ PrebidMobileAdMobAdapters Unit Tests Passed"
else
    echo "🔴 PrebidMobileAdMobAdapters Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Running PrebidMobileMAXAdapters unit tests${NC} \n"

TEST_STATUS=0
testAdapters "PrebidMobileMAXAdaptersTests" || TEST_STATUS=$?

if [[ ${TEST_STATUS} == 0 ]]; then
    echo "✅ PrebidMobileMAXAdapters Unit Tests Passed"
else
    echo "🔴 PrebidMobileMAXAdapters Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Removing simulator${NC} \n"
xcrun simctl delete iPhone-16-Pro-PrebidMobile