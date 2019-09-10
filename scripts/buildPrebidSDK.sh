# Merge Script
if [ -d "scripts" ]; then
cd scripts/
fi

# 1
# Set bash script to exit immediately if any commands fail.
set -e

cd ../

# Setup some constants for use later on.
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

PRODUCT_NAME="PrebidMobile"

GENERATED_DIR_NAME="generated"

LOG_DIR="$GENERATED_DIR_NAME/log"
LOG_FILE_FRAMEWORK="$LOG_DIR/prebid_mobile_build.log"
LOG_FILE_FRAMEWORK_ABSOLUTE="$PWD/$LOG_FILE_FRAMEWORK"

XCODE_BUILD_DIR="$GENERATED_DIR_NAME/xcodebuild"
XCODE_BUILD_IPHONE_FILE_ABSOLUTE="$PWD/$XCODE_BUILD_DIR/Build/Products/Release-iphoneos/$PRODUCT_NAME.framework"
XCODE_BUILD_SIMULATOR_FILE_ABSOLUTE="$PWD/$XCODE_BUILD_DIR/Build/Products/Release-iphonesimulator/$PRODUCT_NAME.framework"

OUTPUT_DIR="$GENERATED_DIR_NAME/output"
OUTPUT_DIR_ABSOLUTE="$PWD/$OUTPUT_DIR"

# If remnants from a previous build exist, delete them.
if [ -d "$GENERATED_DIR_NAME" ]; then
rm -rf "$GENERATED_DIR_NAME"
fi

mkdir -p "$LOG_DIR"
touch "$LOG_FILE_FRAMEWORK"

echo $PWD
gem install cocoapods --user-install
pod install --repo-update

schemes=("PrebidMobile" "PrebidMobileCore")
outputPaths=("" "core/")
frameworkNames=("PrebidMobile" "PrebidMobile-core")

for(( n=0; n<=1; n++ ))
do

	# Delete the most recent xcodebuild.
	if [ -d "$XCODE_BUILD_DIR" ]; then
	rm -rf "$XCODE_BUILD_DIR"
	fi

	mkdir -p "$OUTPUT_DIR_ABSOLUTE/${outputPaths[$n]}"
	OUTPUT_FILE_FRAMEWORK_ABSOLUTE="$OUTPUT_DIR_ABSOLUTE/${outputPaths[$n]}${PRODUCT_NAME}.framework"
	
	# Build the framework for device and for simulator (using
	# all needed architectures).
	echo -e "\n${GREEN} - Building ${frameworkNames[$n]} for device${NC}"
	xcodebuild -workspace PrebidMobile.xcworkspace -scheme "${schemes[$n]}" -configuration Release -arch arm64 only_active_arch=no defines_module=yes -sdk "iphoneos" -derivedDataPath $XCODE_BUILD_DIR > "$LOG_FILE_FRAMEWORK" 2>&1 || { echo -e "${RED}Error in build check log "$LOG_FILE_FRAMEWORK_ABSOLUTE"${NC}"; exit 1;}

	echo -e "${GREEN} - Building ${frameworkNames[$n]} for simulator${NC}"
	xcodebuild -workspace PrebidMobile.xcworkspace -scheme "${schemes[$n]}" -configuration Release -arch x86_64 only_active_arch=no defines_module=yes -sdk "iphonesimulator" -derivedDataPath $XCODE_BUILD_DIR > "$LOG_FILE_FRAMEWORK" 2>&1 || { echo -e "${RED}Error in build check log "$LOG_FILE_FRAMEWORK_ABSOLUTE"${NC}"; exit 1;}

	# Copy the device version of framework.
	cp -r "$XCODE_BUILD_IPHONE_FILE_ABSOLUTE" "$OUTPUT_FILE_FRAMEWORK_ABSOLUTE"

	# Copy Swift modules (from iphonesimulator build)
	cp -R "$XCODE_BUILD_SIMULATOR_FILE_ABSOLUTE/Modules/${PRODUCT_NAME}.swiftmodule/." "$OUTPUT_FILE_FRAMEWORK_ABSOLUTE/Modules/${PRODUCT_NAME}.swiftmodule"

	# Merging the device and simulator
	# frameworks' executables with lipo.
	# echo -e "${GREEN} - Creating Universal $FRAMEWORK_NAME framework ${NC}"
	echo -e "${GREEN} - Creating Universal ${frameworkNames[$n]} framework ${NC}"
	lipo "$XCODE_BUILD_IPHONE_FILE_ABSOLUTE/${PRODUCT_NAME}" "$XCODE_BUILD_SIMULATOR_FILE_ABSOLUTE/${PRODUCT_NAME}" -create -output "$OUTPUT_FILE_FRAMEWORK_ABSOLUTE/${PRODUCT_NAME}" 

done

echo -e "\n${GREEN}Done!${NC} \n"
echo -e "Universal frameworks are located: "$OUTPUT_DIR_ABSOLUTE" \n"
echo -e "Build logs path is: "$LOG_FILE_FRAMEWORK_ABSOLUTE" \n"
