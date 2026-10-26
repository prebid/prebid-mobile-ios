#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# The consumer project has its own graph, build products, and package checkouts.
# Release verification can supply a temporary workspace containing this project.
if [[ -n "${PREBID_SPM_WORKSPACE:-}" ]]; then
    CONTAINER=(-workspace "$PREBID_SPM_WORKSPACE")
else
    CONTAINER=(-project "$PWD/Example/PrebidDemo/PrebidDemoSPM.xcodeproj")
fi

xcodebuild build \
    "${CONTAINER[@]}" \
    -scheme PrebidDemoSPM \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "${PREBID_SPM_DERIVED_DATA:-$PWD/.build/spm-demo}" \
    -clonedSourcePackagesDirPath "${PREBID_SPM_PACKAGES:-$PWD/.swiftpm-spm-demo-cache}" \
    "$@"

echo "✅ Standalone SPM demo build succeeded"
