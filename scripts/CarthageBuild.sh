GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Set bash script to exit immediately if any commands fail.
set -e

if ! [ -e "$PWD/Cartfile" ]; then
	# should be called from Cartfile folder
	echo "PrebidCarthageBuild: ERROR: run this script from Cartfile directory"
	exit;
fi

CARTHAGE_SCHEMA_DIR="$PWD/Carthage/Checkouts/prebid-mobile-ios/PrebidMobile.xcodeproj/xcshareddata/xcschemes"

echo -e "\nPrebidCarthageBuild: ${GREEN}Enter a schema name${NC}(PrebidMobile, PrebidMobileCore)"
read schema

carthage update prebid-mobile-ios --no-build 

mv "$CARTHAGE_SCHEMA_DIR/$schema.xcscheme" "./"
rm $CARTHAGE_SCHEMA_DIR/*
mv "$schema.xcscheme" "$CARTHAGE_SCHEMA_DIR/"

carthage build prebid-mobile-ios

echo -e "\nPrebidCarthageBuild: ${GREEN}$schema is ready.${NC} Please check next folder "$PWD/Carthage/Build" "