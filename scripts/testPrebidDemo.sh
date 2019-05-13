if [ -d "scripts" ]; then
cd scripts/
fi

echo "Running integration tests"
cd ../example/Swift/PrebidDemo/
echo $PWD
gem install cocoapods --pre
pod install --repo-update
xcodebuild -workspace PrebidDemo.xcworkspace test -scheme "PrebidDemoTests" -destination 'platform=iOS Simulator,name=iPhone 8 Plus,OS=12.2' | xcpretty -f `xcpretty-travis-formatter` --color --test

# Make the keychain the default so identities are found
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Set keychain locking timeout to 3600 seconds
security set-keychain-settings -t 3600 -u ios-build.keychain

