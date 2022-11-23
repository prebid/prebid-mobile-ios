if [ -d "scripts" ]; then
cd scripts/
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}TEST PREBID DEMO${NC}\n\n"

cd ..
echo $PWD

gem install cocoapods --user-install

pod deintegrate
pod install --repo-update
pod update

echo -e "\n${GREEN}Running integration tests${NC} \n"
xcodebuild test -workspace PrebidMobile.xcworkspace -scheme "PrebidDemoTests" -destination 'platform=iOS Simulator,name=iPhone 11 Pro Max,OS=latest' | xcpretty -f `xcpretty-travis-formatter` --color --test

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ Integration Tests Passed"
else
    echo "🔴 Integration Tests Failed"
    exit 1
fi
