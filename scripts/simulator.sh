# shellcheck shell=bash
# Simulator settings shared by the test scripts. Source this file, then call
# create_test_simulator. Override any value through the environment:
#   PREBID_SIMULATOR_NAME         simulator name (suffixed by scripts that need their own)
#   PREBID_SIMULATOR_DEVICE_TYPE  CoreSimulator device type identifier
#   PREBID_TEST_RUNTIME           runtime identifier; defaults to the latest installed runtime

PREBID_SIMULATOR_NAME="${PREBID_SIMULATOR_NAME:-iPhone-17-Pro-PrebidMobile}"
PREBID_SIMULATOR_DEVICE_TYPE="${PREBID_SIMULATOR_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro}"

# Creates a simulator named $1 (default PREBID_SIMULATOR_NAME), replacing a leftover one from
# an interrupted run, and sets SIMULATOR_ID. The device is deleted by its ID when the script
# exits, including on failure.
create_test_simulator() {
    local name="${1:-$PREBID_SIMULATOR_NAME}"
    xcrun simctl delete "$name" 2>/dev/null || true
    SIMULATOR_ID="$(xcrun simctl create "$name" "$PREBID_SIMULATOR_DEVICE_TYPE" ${PREBID_TEST_RUNTIME:+"$PREBID_TEST_RUNTIME"})"
    trap 'xcrun simctl delete "$SIMULATOR_ID" >/dev/null 2>&1 || true' EXIT
}
