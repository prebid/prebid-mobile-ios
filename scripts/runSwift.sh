#!/bin/sh
# Build and run PrebidDemoSwift application on emulator $1
# Example: ./script/runSwift.sh "iPhone 14 Pro Max"

if [ -d "scripts" ]; then
cd scripts/
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}RUN PREBID SWIFT DEMO${NC}\n\n"

cd ..
echo $PWD


if [ -z "$1" ]
  then
    echo "Please supply an emulator (xcrun simctl list)"
    exit
fi

emulator_name=$1
xcodebuild -workspace PrebidMobile.xcworkspace -scheme "PrebidDemoSwift" -destination "platform=iOS Simulator,name=${emulator_name},OS=latest" -derivedDataPath build

open -a "simulator"

uuid=$(xcrun simctl list | grep -E -i "${emulator_name}" | grep -Eo -i '[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}')
xcrun simctl install ${uuid} ./build/Build/Products/Debug-iphonesimulator/PrebidDemoSwift.app
xcrun simctl launch ${uuid} org.prebid.PrebidDemoSwift
