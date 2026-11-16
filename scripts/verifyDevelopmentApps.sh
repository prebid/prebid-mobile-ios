#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Flags:
# --with-spm-demo:      also build the standalone SPM consumer against the *published*
#                       packages. It fails for demo changes that use SDK API not yet released,
#                       so PR CI omits it; the PR job runs verifySPM.sh against candidate packages.
with_spm_demo="NO"

usage() {
  cat <<'USAGE'
Usage: verifyDevelopmentApps.sh [--with-spm-demo]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-spm-demo)  with_spm_demo="YES"; shift ;;
    -h|--help)        usage; exit 0 ;;
    *)                echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

./scripts/verifyDependencyIsolation.sh
./scripts/resolveDependencies.sh

# Compile the app, unit-test, and UI-test targets without running network-based
# integration tests. The standalone SPM consumer is checked separately against
# candidate packages, so native SDK upgrades do not depend on a published release.
for scheme in PrebidDemoTests PrebidDemoSwiftUITests InternalTestApp; do
    xcodebuild build-for-testing \
        -workspace PrebidMobile.xcworkspace \
        -derivedDataPath "$PWD/.build/development-apps" \
        -scheme "$scheme" \
        -sdk iphonesimulator \
        -destination 'generic/platform=iOS Simulator' \
        -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
        -disableAutomaticPackageResolution \
        CODE_SIGNING_ALLOWED=NO
done
for scheme in PrebidDemoObjectiveC InternalTestApp-Skadn; do
    xcodebuild build \
        -workspace PrebidMobile.xcworkspace \
        -derivedDataPath "$PWD/.build/development-apps" \
        -scheme "$scheme" \
        -sdk iphonesimulator \
        -destination 'generic/platform=iOS Simulator' \
        -clonedSourcePackagesDirPath "$PWD/.swiftpm-cache" \
        -disableAutomaticPackageResolution \
        CODE_SIGNING_ALLOWED=NO
done

# PrebidMobile.framework loads OMSDK_Prebidorg.framework through @rpath, so every app has to
# embed it. Xcode and `xcodebuild test` run an app with the build products folder on the dyld
# search path, where the framework always is, so an app that does not embed it still builds
# and runs there and fails only when installed on its own.
products="$PWD/.build/development-apps/Build/Products/Debug-iphonesimulator"
for app in PrebidDemoSwift PrebidDemoObjectiveC InternalTestApp InternalTestApp-Skadn; do
    if [[ ! -f "$products/$app.app/Frameworks/OMSDK_Prebidorg.framework/OMSDK_Prebidorg" ]]; then
        echo "$app.app does not embed OMSDK_Prebidorg.framework; it would fail to launch outside Xcode." >&2
        exit 1
    fi
done

if [[ "$with_spm_demo" == "YES" ]]; then
    ./scripts/buildPrebidSPM.sh CODE_SIGNING_ALLOWED=NO
fi
