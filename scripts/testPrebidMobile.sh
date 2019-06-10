if [ -d "scripts" ]; then
cd scripts/
fi

cd ../src/PrebidMobile/
echo $PWD
echo "Running unit tests"

gem install xcpretty
gem install xcpretty-travis-formatter
xcodebuild test -project PrebidMobile.xcodeproj -scheme "PrebidMobileTests" -destination 'platform=iOS Simulator,name=iPhone 8 Plus,OS=12.2' | xcpretty -f `xcpretty-travis-formatter` --color --test
if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ Unit Tests Passed"
else
    echo "🔴 Unit Tests Failed"
    exit 1
fi

cd ../src/PrebidMobile/
echo $PWD
echo "Running swiftlint tests"
swiftlint --config .swiftlint.yml
