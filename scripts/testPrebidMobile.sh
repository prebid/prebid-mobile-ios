if [ -d "scripts" ]; then
cd scripts/
fi

set -e

cd ..
echo $PWD

gem install xcpretty --user-install
gem install xcpretty-travis-formatter --user-install

gem install cocoapods --user-install
pod install --repo-update

echo "Running unit tests"
xcodebuild test -workspace PrebidMobile.xcworkspace  -scheme "PrebidMobileTests" -destination 'platform=iOS Simulator,name=iPhone 8 Plus,OS=12.2' | xcpretty -f `xcpretty-travis-formatter` --color --test

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ Unit Tests Passed"
else
    echo "🔴 Unit Tests Failed"
    exit 1
fi

echo "Running swiftlint tests"
swiftlint --config .swiftlint.yml
