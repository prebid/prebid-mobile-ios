if [ -d "scripts" ]; then
cd scripts/
fi

# Flags:
# -l:   run tests only for the latest iOS.
#       It is needed for CircleCI builds.
#       Do not use this flag locally to keep everything updated.

run_only_with_latest_ios="NO"

while getopts 'l' flag; do
  case "${flag}" in
    l) run_only_with_latest_ios="YES" ;;
  esac
done

set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}INSTALL PODS${NC}\n\n"

cd ..

brew install xcbeautify

export PATH="/Users/distiller/.gem/ruby/2.7.0/bin:$PATH"
gem install cocoapods
pod install --repo-update

echo -e "\n\n${GREEN}TEST PREBID MOBILE${NC}\n\n"

echo -e "\n${GREEN}Clean build\n"

xcodebuild clean build 

if [ "$run_only_with_latest_ios" != "YES" ]
then
 echo -e "\n${GREEN}Running some unit tests for iOS 13${NC} \n"
 xcodebuild test \
    -workspace PrebidMobile.xcworkspace \
    -scheme "PrebidMobileTests" \
    -destination 'platform=iOS Simulator,name=iPhone 11 Pro Max,OS=13.7' \
    -only-testing PrebidMobileTests/RequestBuilderTests/testPostData | xcbeautify

 if [[ ${PIPESTATUS[0]} == 0 ]]; then
     echo "✅ unit tests for iOS 13 Passed"
 else
     echo "🔴 unit tests for iOS 13 Failed"
     exit 1
 fi
 
fi

echo -e "\n${GREEN}Running PrebidMobile unit tests${NC} \n"
xcodebuild test \
    -workspace PrebidMobile.xcworkspace \
    -retry-tests-on-failure \
    -scheme "PrebidMobileTests" \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' | xcbeautify



if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobile Unit Tests Passed"
else
    echo "🔴 PrebidMobile Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Running PrebidMobileGAMEventHandlers unit tests${NC} \n"
xcodebuild test \
    -workspace PrebidMobile.xcworkspace  \
    -scheme "PrebidMobileGAMEventHandlersTests" \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' | xcbeautify

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobileGAMEventHandlers Unit Tests Passed"
else
    echo "🔴 PrebidMobileGAMEventHandlers Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Running PrebidMobileAdMobAdapters unit tests${NC} \n"
xcodebuild test -workspace PrebidMobile.xcworkspace  -scheme "PrebidMobileAdMobAdaptersTests" -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' | xcbeautify

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobileAdMobAdapters Unit Tests Passed"
else
    echo "🔴 PrebidMobileAdMobAdapters Unit Tests Failed"
    exit 1
fi

echo -e "\n${GREEN}Running PrebidMobileMAXAdapters unit tests${NC} \n"
xcodebuild test -workspace PrebidMobile.xcworkspace  -scheme "PrebidMobileMAXAdaptersTests" -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' | xcbeautify

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ PrebidMobileMAXAdapters Unit Tests Passed"
else
    echo "🔴 PrebidMobileMAXAdapters Unit Tests Failed"
    exit 1
fi
# echo -e "\n${GREEN}Running swiftlint tests${NC} \n"
# swiftlint --config .swiftlint.yml
