#!/usr/bin/env bash
set -euo pipefail

# Typechecks every .swiftinterface in the XCFrameworks built by buildPrebidMobile.sh,
# the way a consumer's compiler rebuilds a module from its textual interface.
#
# xcodebuild passes -no-verify-emitted-module-interface to the compiler, so an
# interface that doesn't compile still archives cleanly, and consumers only see the
# failure once their module cache is empty (#1374).
#
# Usage: ./scripts/verifyXCFrameworkInterfaces.sh [output dir]
# The output dir defaults to generated/output. Dependencies are looked up in
# Frameworks/ and Pods/, so run it after the pod install done by buildPrebidMobile.sh.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

cd "$(dirname "$0")/.."

OUTPUT_DIR="${1:-generated/output}"

MODULE_CACHE="$(mktemp -d)"
trap 'rm -rf "$MODULE_CACHE"' EXIT

# Maps an XCFramework slice directory name to the SDK it was built for.
sdk_for_slice() {
    case "$1" in
        ios-*-simulator) echo "iphonesimulator" ;;
        ios-*-maccatalyst) echo "" ;;
        ios-*) echo "iphoneos" ;;
        *) echo "" ;;
    esac
}

xcframeworks=()
while IFS= read -r xcframework; do
    xcframeworks+=("$xcframework")
done < <(find "$OUTPUT_DIR" Frameworks Pods -name '*.xcframework' -type d -prune 2>/dev/null || true)

checked=0
failed=0

for xcframework in "$OUTPUT_DIR"/*.xcframework; do
    for slice in "$xcframework"/ios-*; do
        sdk="$(sdk_for_slice "$(basename "$slice")")"
        [ -n "$sdk" ] || continue

        search_paths=()
        for dependency in ${xcframeworks[@]+"${xcframeworks[@]}"}; do
            for dependency_slice in "$dependency"/ios-*; do
                if [ "$(sdk_for_slice "$(basename "$dependency_slice")")" = "$sdk" ]; then
                    search_paths+=(-F "$dependency_slice")
                fi
            done
        done

        for interface in "$slice"/*.framework/Modules/*.swiftmodule/*.swiftinterface; do
            [ -f "$interface" ] || continue
            module="$(basename "$(dirname "$interface")" .swiftmodule)"
            echo "Checking ${interface#"$OUTPUT_DIR"/}"
            checked=$((checked + 1))

            if ! log="$(xcrun swift-frontend -typecheck-module-from-interface "$interface" \
                -module-name "$module" \
                -sdk "$(xcrun --sdk "$sdk" --show-sdk-path)" \
                ${search_paths[@]+"${search_paths[@]}"} \
                -module-cache-path "$MODULE_CACHE" 2>&1)"; then
                echo -e "${RED}${log}${NC}"
                failed=$((failed + 1))
            fi
        done
    done
done

if [ "$checked" -eq 0 ]; then
    echo -e "${RED}No .swiftinterface files found under ${OUTPUT_DIR}.${NC}"
    exit 1
fi

if [ "$failed" -gt 0 ]; then
    echo -e "${RED}${failed} of ${checked} Swift interfaces failed to typecheck.${NC}"
    exit 1
fi

echo -e "${GREEN}All ${checked} Swift interfaces typecheck.${NC}"
