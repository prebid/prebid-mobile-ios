#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Keep checkouts and binary artifacts outside generated/, which archive builds
# delete. The workspace lockfile is shared by all projects and tracked in git.
xcodebuild -resolvePackageDependencies \
    -workspace PrebidMobile.xcworkspace \
    -scheme Lib-PrebidMobile \
    -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
    -onlyUsePackageVersionsFromResolvedFile
