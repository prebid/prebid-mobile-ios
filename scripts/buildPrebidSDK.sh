# Merge Script
if [ -d "scripts" ]; then
cd scripts/
fi

# 1
# Set bash script to exit immediately if any commands fail.
set -e

cd ../

# 2
# Setup some constants for use later on.
FRAMEWORK_NAME="PrebidMobile"
GENERATED_FOLDER_NAME="generated"

LOG_DIR="$GENERATED_FOLDER_NAME/log"
LOG_FILE="$LOG_DIR/prebid_mobile_build.log"
LOG_FILE_ABSOLUTE="$PWD/$LOG_FILE"

XCODE_BUILD_DIR="$GENERATED_FOLDER_NAME/xcodebuild"
XCODE_BUILD_IPHONE_FILE_ABSOLUTE="$PWD/$XCODE_BUILD_DIR/Build/Products/Release-iphoneos/$FRAMEWORK_NAME.framework"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 3
# If remnants from a previous build exist, delete them.
if [ -d "$GENERATED_FOLDER_NAME" ]; then
rm -rf "$GENERATED_FOLDER_NAME"
fi

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

echo $PWD
gem install cocoapods --user-install
pod install --repo-update

# 4
# Build the framework for device and for simulator (using
# all needed architectures).
echo -e "${GREEN}-Building the framework for device${NC}"
xcodebuild -workspace PrebidMobile.xcworkspace -scheme "PrebidMobile" -configuration Release -arch arm64 only_active_arch=no defines_module=yes -sdk "iphoneos" -derivedDataPath $XCODE_BUILD_DIR > "$LOG_FILE" 2>&1 || { echo -e "${RED}Error in build check log "$LOG_FILE_ABSOLUTE"${NC}"; exit 1;}

echo -e "${GREEN}-Building the framework for simulator${NC}"
xcodebuild -workspace PrebidMobile.xcworkspace -scheme "PrebidMobile" -configuration Release -arch x86_64 only_active_arch=no defines_module=yes -sdk "iphonesimulator" -derivedDataPath $XCODE_BUILD_DIR > "$LOG_FILE" 2>&1 || { echo -e "${RED}Error in build check log "$LOG_FILE_ABSOLUTE"${NC}"; exit 1;}

echo -e "${GREEN}Done!${NC} \nPrebid Mobile framework for iPhone path is "$XCODE_BUILD_IPHONE_FILE_ABSOLUTE""
echo "Build logs path is "$LOG_FILE_ABSOLUTE""
