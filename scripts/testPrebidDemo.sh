if [ -d "scripts" ]; then
cd scripts/
fi

# Set bash script to exit immediately if any commands fail.
set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}RUN PREBID DEMO TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro

cd ..
echo $PWD

if ! command -v pod >/dev/null 2>&1; then
    echo "CocoaPods is required but 'pod' was not found on PATH." >&2
    echo "GitHub Actions 'macos-15' ships it preinstalled; install it locally with 'brew install cocoapods'." >&2
    exit 1
fi

pod deintegrate
pod install --repo-update
pod update

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
    -scheme $SCHEME \
    -sdk iphonesimulator \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
    -destination-timeout 60 \
    build-for-testing

echo -e "\n\n${GREEN}Testing ${SCHEME}${NC}\n\n"

# `set -e` would abort the script on a failing xcodebuild before the report below runs,
# so take the exit status explicitly and keep the diagnostic reachable.
TEST_STATUS=0
xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -scheme $SCHEME \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
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
xcrun simctl delete iPhone-16-Pro-PrebidMobile
