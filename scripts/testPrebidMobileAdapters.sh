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

export PATH="/Users/distiller/.gem/ruby/2.7.0/bin:$PATH"
gem install cocoapods
pod install --repo-update

echo -e "\n\n${GREEN}RUN PREBID MOBILE ADAPTER TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro

echo -e "\n${GREEN}Clean build\n"
xcodebuild clean build

function testAdapters () {
  local SCHEME="$1"

    xcodebuild \
        -workspace PrebidMobile.xcworkspace \
        -scheme "${SCHEME}" \
        -sdk iphonesimulator \
        -configuration Debug \
        -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
        -destination-timeout 60 \
        build-for-testing

    xcodebuild \
        -workspace PrebidMobile.xcworkspace \
        -scheme "${SCHEME}" \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
        -destination-timeout 60 \
        test-without-building
}

echo -e "\n${GREEN}Running PrebidMobileGAMEventHandlers unit tests${NC} \n"

testAdapters "PrebidMobileGAMEventHandlersTests"

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobileGAMEventHandlers Unit Tests Passed"
else
    echo "🔴 PrebidMobileGAMEventHandlers Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Running PrebidMobileAdMobAdapters unit tests${NC} \n"

testAdapters "PrebidMobileAdMobAdaptersTests"

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobileAdMobAdapters Unit Tests Passed"
else
    echo "🔴 PrebidMobileAdMobAdapters Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Running PrebidMobileMAXAdapters unit tests${NC} \n"

testAdapters "PrebidMobileMAXAdaptersTests"

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobileMAXAdapters Unit Tests Passed"
else
    echo "🔴 PrebidMobileMAXAdapters Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Removing simulator${NC} \n"
xcrun simctl delete iPhone-16-Pro-PrebidMobile