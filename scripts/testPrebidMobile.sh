if [ -d "scripts" ]; then
cd scripts/
fi

# Flags:
# --latest:             run tests only for the latest iOS.
#                       It is needed for the GitHub Actions builds.
#                       Do not use this flag locally to keep everything updated.
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

export PATH="/Users/distiller/.gem/ruby/2.7.0/bin:$PATH"
gem install cocoapods
pod install --repo-update

echo -e "\n\n${GREEN}RUN PREBID MOBILE TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro

if [ "$run_only_PR_tests" != "YES" ]; then
    echo -e "\n${GREEN}Clean build\n"
    xcodebuild clean build
fi

if [ "$run_only_with_latest_ios" != "YES" ]
then
 echo -e "\n${GREEN}Running some unit tests for iOS 13${NC} \n"
 xcodebuild test \
    -workspace PrebidMobile.xcworkspace \
    -scheme "PrebidMobileTests" \
    -destination 'platform=iOS Simulator,name=iPhone 11 Pro Max,OS=13.7' \
    -only-testing PrebidMobileTests/RequestBuilderTests/testPostData

 if [[ ${PIPESTATUS[0]} == 0 ]]; then
     echo "✅ unit tests for iOS 13 Passed"
 else
     echo "🔴 unit tests for iOS 13 Failed"
     exit 1
 fi
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

xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -scheme PrebidMobileTests \
    -sdk iphonesimulator \
    -testPlan "${TESTPLAN}" \
    -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
    -destination-timeout 60 \
    -retry-tests-on-failure \
    test-without-building

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobile Unit Tests Passed"
else
    echo "🔴 PrebidMobile Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Removing simulator${NC} \n"
xcrun simctl delete iPhone-16-Pro-PrebidMobile

# echo -e "\n${GREEN}Running swiftlint tests${NC} \n"
# swiftlint --config .swiftlint.yml
