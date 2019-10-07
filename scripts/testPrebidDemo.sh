if [ -d "scripts" ]; then
cd scripts/
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}TEST PREBID DEMO${NC}\n\n"

cd ..
echo $PWD

gem install cocoapods --user-install
pod install --repo-update

echo -e "\n${GREEN}Running integration tests${NC} \n"
xcodebuild test -workspace PrebidMobile.xcworkspace -scheme "PrebidDemoTests" -destination 'platform=iOS Simulator,name=iPhone 8 Plus,OS=12.2' | xcpretty -f `xcpretty-travis-formatter` --color --test

# Make the keychain the default so identities are found
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Set keychain locking timeout to 3600 seconds
security set-keychain-settings -t 3600 -u ios-build.keychain

