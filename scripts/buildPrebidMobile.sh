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

POSTFIX_SIMULATOR="_simulator"

echo -e "\n\n${GREEN}PREPARE BUILD ENVIRONMENT${NC}\n\n"

GENERATED_DIR_NAME="generated"

	LOG_DIR="$GENERATED_DIR_NAME/log"
	LOG_FILE_FRAMEWORK="$LOG_DIR/prebid_mobile_build.log"
	LOG_FILE_FRAMEWORK_ABSOLUTE="$PWD/$LOG_FILE_FRAMEWORK"

	XCODE_BUILD_DIR="$GENERATED_DIR_NAME/xcodebuild"

	XCODE_ARCHIVE_DIR="$GENERATED_DIR_NAME/archive"
	XCODE_ARCHIVE_DIR_ABSOLUTE="$PWD/$GENERATED_DIR_NAME/archive"

	OUTPUT_DIR="$GENERATED_DIR_NAME/output"
	OUTPUT_DIR_ABSOLUTE="$PWD/$OUTPUT_DIR"


# If remnants from a previous build exist, delete them.
if [ -d "$GENERATED_DIR_NAME" ]; then
	rm -rf "$GENERATED_DIR_NAME"
fi

mkdir -p "$LOG_DIR"
touch "$LOG_FILE_FRAMEWORK"

echo -e "\n\n${GREEN}INSTALL PODS${NC}\n\n"

export PATH="/Users/distiller/.gem/ruby/2.7.0/bin:$PATH"
gem install cocoapods
pod install --repo-update

echo -e "\n\n${GREEN}BUILD PREBID MOBILE${NC}\n\n"

schemes=("PrebidMobile" "PrebidMobileGAMEventHandlers" "PrebidMobileAdMobAdapters" "PrebidMobileMAXAdapters")

for(( n=0; n<${#schemes[@]}; n++ ))
do
	
	# Build the framework for device and for simulator 
	echo -e "\n${GREEN} - Archiving ${schemes[$n]} for device${NC}"

	xcodebuild archive \
	only_active_arch=NO \
	defines_module=YES \
	SKIP_INSTALL=NO \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	-workspace PrebidMobile.xcworkspace \
	-scheme "${schemes[$n]}" \
	-configuration Release \
	-arch arm64 \
	-sdk "iphoneos" \
	-derivedDataPath $XCODE_BUILD_DIR \
	-archivePath "$XCODE_ARCHIVE_DIR/${schemes[$n]}.xcarchive" \
	> "$LOG_FILE_FRAMEWORK" 2>&1 || { echo -e "${RED}Error in build check log "$LOG_FILE_FRAMEWORK_ABSOLUTE"${NC}"; exit 1;}

	echo -e "${GREEN} - Archiving ${schemes[$n]} for simulator${NC}"

	xcodebuild archive \
	only_active_arch=NO \
	defines_module=YES \
	SKIP_INSTALL=NO \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	-workspace PrebidMobile.xcworkspace \
	-scheme "${schemes[$n]}" \
	-configuration Release \
	-sdk "iphonesimulator" \
	-derivedDataPath $XCODE_BUILD_DIR \
	-archivePath "$XCODE_ARCHIVE_DIR/${schemes[$n]}$POSTFIX_SIMULATOR.xcarchive" \
	> "$LOG_FILE_FRAMEWORK" 2>&1 || { echo -e "${RED}Error in build check log "$LOG_FILE_FRAMEWORK_ABSOLUTE"${NC}"; exit 1;}

	echo -e "${GREEN} - Creating ${schemes[$n]} XCFramework${NC}"
	# Create XCFramework
    
	# eval
	eval " 
	xcodebuild -create-xcframework \
	    -framework "$XCODE_ARCHIVE_DIR/${schemes[$n]}.xcarchive/Products/Library/Frameworks/${schemes[$n]}.framework" \
	    -debug-symbols "$XCODE_ARCHIVE_DIR_ABSOLUTE/${schemes[$n]}.xcarchive/dSYMs/${schemes[$n]}.framework.dSYM" \
	    -framework "$XCODE_ARCHIVE_DIR/${schemes[$n]}$POSTFIX_SIMULATOR.xcarchive/Products/Library/Frameworks/${schemes[$n]}.framework" \
	    -debug-symbols "$XCODE_ARCHIVE_DIR_ABSOLUTE/${schemes[$n]}$POSTFIX_SIMULATOR.xcarchive/dSYMs/${schemes[$n]}.framework.dSYM" \
	    -output "$OUTPUT_DIR/XC${schemes[$n]}.xcframework"
	"

done

echo -e "\n${GREEN}Done!${NC} \n"
echo -e "XCFrameworks are located: "$OUTPUT_DIR_ABSOLUTE" \n"
echo -e "Build logs path is: "$LOG_FILE_FRAMEWORK_ABSOLUTE" \n"
