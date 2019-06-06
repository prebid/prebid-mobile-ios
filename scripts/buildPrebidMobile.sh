# Merge Script
if [ -d "scripts" ]; then
cd scripts/
fi

# 1
# Set bash script to exit immediately if any commands fail.
set -e

# 2
# Setup some constants for use later on.


cd ../src/PrebidMobile/

FRAMEWORK_NAME="PrebidMobile"
LOGDIR=../../build/out/log
mkdir -p "$LOGDIR"

# 3
# If remnants from a previous build exist, delete them.
if [ -d "build" ]; then
rm -rf "build"
fi

LOGFILE="$LOGDIR"/prebid_mobile_build.log
touch "$LOGFILE"


# 4
# Build the framework for device and for simulator (using
# all needed architectures).
echo "Building the framework for device"
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch arm64 only_active_arch=no defines_module=yes -sdk "iphoneos" > "$LOGFILE" 2>&1 || { echo "Error in build check log "$LOGFILE""; exit 1;}

echo "Building the framework for simulator"
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch x86_64 only_active_arch=no defines_module=yes -sdk "iphonesimulator" > "$LOGFILE" 2>&1 || { echo "Error in build check log "$LOGFILE""; exit 1;}
# 5
# Remove .framework file if exists on Desktop from previous run.
if [ -d "${HOME}/Desktop/${FRAMEWORK_NAME}.framework" ]; then
rm -rf "${HOME}/Desktop/${FRAMEWORK_NAME}.framework"
fi

# 6
# Copy the device version of framework to Desktop.
cp -r "build/Release-iphoneos/${FRAMEWORK_NAME}.framework" "${HOME}/Desktop/${FRAMEWORK_NAME}.framework"

# 7
# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.
lipo -create -output "${HOME}/Desktop/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/Release-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

echo "Done! You can find the Prebid Mobile framework on your Desktop"
echo "Build logs are also available in the build/out/log/ folder."

# 8
# Delete the most recent build.
if [ -d "build" ]; then
rm -rf "build"
fi
