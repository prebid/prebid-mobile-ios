if [ -d "scripts" ]; then
cd scripts/
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}RUN PREBID DEMO TESTS${NC}\n\n"

echo -e "\n${GREEN}Creating simulator${NC} \n"
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro

cd ..
echo $PWD

export PATH="/Users/distiller/.gem/ruby/2.7.0/bin:$PATH"
brew install xcbeautify
gem install cocoapods

pod deintegrate
pod install --repo-update
pod update

brew install xcbeautify

if [ "$1" == "-ui" ]; then
    echo -e "\n${GREEN}Running UI tests${NC} \n"
    SCHEME="PrebidDemoSwiftUITests"
    TEST="UI"
else
    echo -e "\n${GREEN}Running integration tests${NC} \n"
    SCHEME="PrebidDemoTests"
    TEST="Integration"
fi

xcodebuild test \
    -workspace PrebidMobile.xcworkspace \
    -scheme $SCHEME \
    -test-iterations 2 \
    -retry-tests-on-failure \
    -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' | xcbeautify

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ ${TEST} Tests Passed"
else
    echo "🔴 ${TEST} Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Removing simulator${NC} \n"
xcrun simctl delete iPhone-16-Pro-PrebidMobile
