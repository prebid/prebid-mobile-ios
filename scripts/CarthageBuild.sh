GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Merge Script
if [ -d "scripts" ]; then
cd scripts/
fi

# Set bash script to exit immediately if any commands fail.
set -e
cd ..

CARTHAGE_SCHEMA_DIR="$PWD/Carthage/Checkouts/prebid-mobile-ios/PrebidMobile.xcodeproj/xcshareddata/xcschemes"

echo -e "\n${GREEN}Enter a schema name${NC}"
read schema


carthage update --no-build 

mv "$CARTHAGE_SCHEMA_DIR/$schema.xcscheme" "./"
rm $CARTHAGE_SCHEMA_DIR/*
mv "$schema.xcscheme" "$CARTHAGE_SCHEMA_DIR/"

carthage build