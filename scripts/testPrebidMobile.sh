if [ -d "scripts" ]; then
cd scripts/
fi

# Flags:
# --latest:             accepted for backward compatibility; it used to skip a sanity test on the
#                       oldest supported iOS (13). That run was removed when the minimum became
#                       iOS 15, since Xcode 27 hosts cannot run an iOS 15 simulator runtime.
# --quick:              run only quick set of tests for PR.
#                       It is needed for the GitHub Actions builds on every PR to avoid running all tests.

run_only_with_latest_ios="NO"
run_only_PR_tests="NO"

usage() {
  cat <<'USAGE'
Usage: testPrebidMobile.sh [--latest] [--quick]
USAGE
}

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --latest)         run_only_with_latest_ios="YES"; shift ;;
    --quick)          run_only_PR_tests="YES"; shift ;;
    -h|--help)        usage; exit 0 ;;
    --)               shift; break ;;
    -*)               echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *)                break ;;
  esac
done


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

echo -e "\n\n${GREEN}RUN PREBID MOBILE TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
# Remove any leftover simulator from a previous interrupted run so `create` doesn't fail.
xcrun simctl delete iPhone-16-Pro-PrebidMobile 2>/dev/null || true
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro

if [ "$run_only_PR_tests" != "YES" ]; then
    echo -e "\n${GREEN}Clean build\n"
    xcodebuild clean build \
        -workspace PrebidMobile.xcworkspace \
        -scheme PrebidMobileTests \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest'
fi

TESTPLAN=""

if [ "$run_only_PR_tests" != "YES" ]; then
    TESTPLAN="PrebidMobileTests"
else
    TESTPLAN="PrebidMobilePRTests"
fi

echo -e "\n${GREEN}Running PrebidMobile unit tests${NC} \n"

xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -scheme PrebidMobileTests \
    -sdk iphonesimulator \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
    -destination-timeout 60 \
    build-for-testing

TEST_STATUS=0
xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -scheme PrebidMobileTests \
    -sdk iphonesimulator \
    -testPlan "${TESTPLAN}" \
    -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
    -destination-timeout 60 \
    -retry-tests-on-failure \
    test-without-building || TEST_STATUS=$?

if [[ ${TEST_STATUS} == 0 ]]; then
    echo "✅ PrebidMobile Unit Tests Passed"
else
    echo "🔴 PrebidMobile Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Removing simulator${NC} \n"
xcrun simctl delete iPhone-16-Pro-PrebidMobile

# echo -e "\n${GREEN}Running swiftlint tests${NC} \n"
# swiftlint --config .swiftlint.yml
