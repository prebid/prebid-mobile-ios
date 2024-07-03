if [ -d "scripts" ]; then
cd scripts/
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}TEST PREBID DEMO${NC}\n\n"

cd ..
echo $PWD

export PATH="/Users/distiller/.gem/ruby/2.7.0/bin:$PATH"
gem install cocoapods

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
xcodebuild test -workspace PrebidMobile.xcworkspace -scheme $SCHEME -test-iterations 2 -retry-tests-on-failure  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' | xcpretty -f `xcpretty-travis-formatter` --color --test

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ ${TEST} Tests Passed"
else
    echo "🔴 ${TEST} Tests Failed"
    exit 1
fi
