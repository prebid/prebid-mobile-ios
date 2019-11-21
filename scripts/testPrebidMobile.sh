if [ -d "scripts" ]; then
cd scripts/
fi

set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}TEST PREBID MOBILE${NC}\n\n"

cd ..
echo $PWD

gem install xcpretty --user-install
gem install xcpretty-travis-formatter --user-install

gem install cocoapods --user-install
pod install --repo-update

echo -e "\n${GREEN}Running unit tests${NC} \n"
xcodebuild test -workspace PrebidMobile.xcworkspace  -scheme "PrebidMobileTests" -destination 'platform=iOS Simulator,name=iPhone 11 Pro Max,OS=13.0' | xcpretty -f `xcpretty-travis-formatter` --color --test

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ Unit Tests Passed"
else
    echo "🔴 Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Running swiftlint tests${NC} \n"
swiftlint --config .swiftlint.yml
