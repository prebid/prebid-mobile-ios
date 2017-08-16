if [ -d "scripts" ]; then
cd scripts/
fi

cd ../sdk/

echo "Running unit tests"
gem install xcpretty
xcodebuild test -project PrebidMobile.xcodeproj -scheme "PrebidMobileTests" -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0' | xcpretty

echo "Building ipa"
cd ../examples/PrebidMobileDemo/

# Make the keychain the default so identities are found
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Set keychain locking timeout to 3600 seconds
security set-keychain-settings -t 3600 -u ios-build.keychain

make ipa

echo "Running integration tests"

gem install xamarin-test-cloud
if [ "$TRAVIS_EVENT_TYPE" == "pull_request" ]; then
test-cloud submit Products/ipa/PrebidMobileDemo.ipa 435c130f3f6ff5256d19a790c21dd653 --devices "$XAMARIN_DEVICES_ID_PR" --series "master" --locale "en_US" --app-name "AppNexus.PrebidMobileDemo" --user nhedley@appnexus.com
fi
if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
test-cloud submit Products/ipa/PrebidMobileDemo.ipa 435c130f3f6ff5256d19a790c21dd653 --devices "$XAMARIN_DEVICES_ID_CRON" --series "master" --locale "en_US" --app-name "AppNexus.PrebidMobileDemo" --user nhedley@appnexus.com
fi
