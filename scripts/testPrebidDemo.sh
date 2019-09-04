if [ -d "scripts" ]; then
cd scripts/
fi


cd ..
echo $PWD

gem install cocoapods --user-install
pod install --repo-update

echo "Running integration tests"
xcodebuild test -workspace PrebidMobile.xcworkspace -scheme "PrebidDemoSwiftTests" -destination 'platform=iOS Simulator,name=iPhone 8 Plus,OS=12.2' | xcpretty -f `xcpretty-travis-formatter` --color --test

# Make the keychain the default so identities are found
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Set keychain locking timeout to 3600 seconds
security set-keychain-settings -t 3600 -u ios-build.keychain

