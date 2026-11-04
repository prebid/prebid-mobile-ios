#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Keep published consumer requirements out of the native development graph, so the
# published adapters' version ranges cannot constrain native vendor upgrades.
fail() { echo "🔴 $1" >&2; exit 1; }

CONSUMER=Example/PrebidDemo/PrebidDemoSPM.xcodeproj/project.pbxproj

# The committed lockfile is resolved with -onlyUsePackageVersionsFromResolvedFile, so a
# published Prebid package can only enter the native graph by appearing here.
if grep -q 'prebid-mobile-ios-\(sdk\|adapters\)' PrebidMobile.xcworkspace/xcshareddata/swiftpm/Package.resolved; then
    fail "The native workspace lockfile pins a published Prebid package"
fi
grep -q 'repositoryURL = "https://github.com/prebid/prebid-mobile-ios-adapters.git"' "$CONSUMER" ||
    fail "PrebidDemoSPM must depend on the published adapters package"
if grep -q 'repositoryURL = ".*\(google-mobile-ads\|AppLovin\)' "$CONSUMER"; then
    fail "PrebidDemoSPM must take Google Mobile Ads and AppLovin from the adapters package"
fi

echo "✅ Native and published consumer package graphs are separate"
