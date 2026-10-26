#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Only native projects participate in this graph; published Prebid packages live
# in the standalone SPM consumer project. Native vendor requirements are exact.
# Keep checkouts/artifacts outside generated/, which archive builds delete.
xcodebuild -resolvePackageDependencies \
    -workspace PrebidMobile.xcworkspace \
    -scheme Lib-PrebidMobile \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache"
