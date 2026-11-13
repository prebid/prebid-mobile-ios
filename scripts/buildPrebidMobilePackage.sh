#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "\n\n${GREEN}BUILD LOCAL SPM PACKAGE${NC}\n\n"

# Why this exists, separately from buildPrebidSPM.sh:
#
# buildPrebidSPM.sh builds the PrebidDemoSPM app, which consumes the *published*
# package via XCRemoteSwiftPackageReference — it never compiles this working tree.
# buildPrebidMobile.sh builds the Xcode framework targets, where the generated
# PrebidMobile-Swift.h transitively re-exports umbrella headers that SPM does not.
#
# Neither catches a source file that compiles in an Xcode framework target but fails under SPM
# (e.g. an ObjC file relying on a removed header for its UIKit visibility). This
# script compiles Package.swift directly to close that gap.
#
# swift build uses the host toolchain, so the iOS simulator triple and SDK must be
# passed explicitly to both swiftc and clang. Pass them to the build engine too:
# newer SwiftPM defaults to Swift Build, which selects XCFramework slices before
# invoking the compiler. Compiler-only -target flags leave it targeting macOS.

SDK_PATH="$(xcrun --sdk iphonesimulator --show-sdk-path)"
TRIPLE="arm64-apple-ios15.0-simulator"

# SwiftPM resolves binaryTarget xcframework slices against the *host* platform, so
# cross-compiling this way it never adds a framework search path for OMSDK. Point
# clang and swiftc (the Swift target imports OMSDK too) at the iOS simulator slice
# explicitly (the identifier comes from the xcframework's Info.plist AvailableLibraries).
OMSDK_SLICE="Frameworks/OMSDK_Prebidorg.xcframework/ios-arm64_x86_64-simulator"

if [ ! -d "${OMSDK_SLICE}" ]; then
    echo "🔴 OMSDK iOS simulator slice not found at ${OMSDK_SLICE}"
    exit 1
fi

SWIFT_BUILD_FLAGS=(
    -Xswiftc -sdk -Xswiftc "${SDK_PATH}"
    -Xswiftc -target -Xswiftc "${TRIPLE}"
    -Xcc -isysroot -Xcc "${SDK_PATH}"
    -Xcc -target -Xcc "${TRIPLE}"
    -Xcc -F -Xcc "${PWD}/${OMSDK_SLICE}"
    -Xswiftc -F -Xswiftc "${PWD}/${OMSDK_SLICE}"
)

swift build --force-resolved-versions --triple "${TRIPLE}" --sdk "${SDK_PATH}" --target PrebidMobile "${SWIFT_BUILD_FLAGS[@]}"

echo "✅ SPM package build succeeded"
