#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Vendor versions are exact requirements in the Xcode projects. The generated
# workspace lockfile is ignored so the published Prebid demo can resolve updates.
# Keep checkouts/artifacts outside generated/, which archive builds delete.
xcodebuild -resolvePackageDependencies \
    -workspace PrebidMobile.xcworkspace \
    -scheme Lib-PrebidMobile \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache"
