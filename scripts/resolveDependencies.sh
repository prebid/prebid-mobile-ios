#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Only native projects participate in this graph; published Prebid packages live
# in the standalone SPM consumer project. Native vendor requirements are exact, and
# the committed workspace lockfile pins every package, indirect ones included. A
# lockfile that no longer matches the projects fails here instead of being rewritten.
# Keep checkouts/artifacts outside generated/, which archive builds delete.
xcodebuild -resolvePackageDependencies \
    -workspace PrebidMobile.xcworkspace \
    -scheme Lib-PrebidMobile \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
    -onlyUsePackageVersionsFromResolvedFile
