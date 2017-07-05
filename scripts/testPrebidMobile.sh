if [ -d "scripts" ]; then
cd scripts/
fi

cd ../sdk/

echo "Running unit tests"
gem install xcpretty
xcodebuild test -project PrebidMobile.xcodeproj -scheme "PrebidMobileTests" -destination 'platform=iOS Simulator,id=$IOS_SIMULATOR_UDID' | xcpretty

echo "Running integration tests"
cd ../examples/PrebidMobileDemo/
#make ipa
gem install xamarin-test-cloud
test-cloud submit Products/ipa/PrebidMobileDemo.ipa 435c130f3f6ff5256d19a790c21dd653 --devices 9f82ba1c --series "master" --locale "en_US" --app-name "AppNexus.PrebidMobileDemo" --user nhedley@appnexus.com
