GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}RUN PREBID DEMO SPM${NC}\n\n"

echo $PWD

echo -e "\n${GREEN}Creating simulator${NC} \n"
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro

xcodebuild \
    -workspace PrebidMobile.xcworkspace \
    -scheme PrebidDemoSPM \
    -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest'

if [[ ${PIPESTATUS[0]} == 0 ]]; then
    echo "✅ Build Success"
else
    echo "🔴 Build Failed"
    exit 1
fi

echo -e "\n${GREEN}Removing simulator${NC} \n"
xcrun simctl delete iPhone-16-Pro-PrebidMobile
