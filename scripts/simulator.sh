# shellcheck shell=bash
# Simulator settings shared by the test scripts. Source this file, then call
# create_test_simulator. Override any value through the environment:
#   PREBID_SIMULATOR_NAME             simulator name (suffixed by scripts that need their own)
#   PREBID_SIMULATOR_DEVICE_TYPE      CoreSimulator device type identifier
#   PREBID_TEST_RUNTIME               runtime identifier; defaults to the latest installed runtime
#   PREBID_SIMULATOR_BOOT_TIMEOUT     seconds boot_test_simulator waits for the first boot
#   PREBID_SIMULATOR_DIAGNOSTICS_DIR  where boot_test_simulator writes diagnostics if that wait fails

PREBID_SIMULATOR_NAME="${PREBID_SIMULATOR_NAME:-iPhone-17-Pro-PrebidMobile}"
PREBID_SIMULATOR_DEVICE_TYPE="${PREBID_SIMULATOR_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro}"
# First-boot data migration has taken up to 7 minutes on CI runners.
PREBID_SIMULATOR_BOOT_TIMEOUT="${PREBID_SIMULATOR_BOOT_TIMEOUT:-900}"
PREBID_SIMULATOR_DIAGNOSTICS_DIR="${PREBID_SIMULATOR_DIAGNOSTICS_DIR:-$PWD/generated/log/simulator-diagnostics}"

# Creates a simulator named $1 (default PREBID_SIMULATOR_NAME), replacing a leftover one from
# an interrupted run, and sets SIMULATOR_ID. The device is deleted by its ID when the script
# exits, including on failure.
create_test_simulator() {
    local name="${1:-$PREBID_SIMULATOR_NAME}"
    xcrun simctl delete "$name" 2>/dev/null || true
    SIMULATOR_ID="$(xcrun simctl create "$name" "$PREBID_SIMULATOR_DEVICE_TYPE" ${PREBID_TEST_RUNTIME:+"$PREBID_TEST_RUNTIME"})"
    trap 'xcrun simctl delete "$SIMULATOR_ID" >/dev/null 2>&1 || true' EXIT
}

# Runs a command in the background and stops it after $1 seconds. Returns the command's status,
# or 124 if it was stopped. macOS runners have no coreutils timeout.
run_with_timeout() {
    local seconds="$1"
    shift
    "$@" &
    local pid=$! waited=0
    while kill -0 "$pid" 2>/dev/null; do
        if (( waited >= seconds )); then
            kill "$pid" 2>/dev/null
            sleep 5
            kill -9 "$pid" 2>/dev/null
            wait "$pid" 2>/dev/null
            return 124
        fi
        sleep 1
        waited=$((waited + 1))
    done
    wait "$pid"
}

# Boots the simulator from create_test_simulator and waits until its first-boot data migration
# finishes. The wait is bounded: if the boot stalls, this records diagnostics and fails, instead
# of holding the runner until the job timeout.
boot_test_simulator() {
    local status=0
    run_with_timeout "$PREBID_SIMULATOR_BOOT_TIMEOUT" xcrun simctl bootstatus "$SIMULATOR_ID" -b || status=$?
    if (( status == 0 )); then
        return 0
    fi
    if (( status == 124 )); then
        echo "Simulator $SIMULATOR_ID did not finish booting within ${PREBID_SIMULATOR_BOOT_TIMEOUT} s." >&2
    else
        echo "Simulator $SIMULATOR_ID failed to boot (status $status)." >&2
    fi
    collect_simulator_diagnostics
    return "$status"
}

# Writes the simulator's state and logs to PREBID_SIMULATOR_DIAGNOSTICS_DIR. Each simctl call is
# bounded too, since it can stall on the same CoreSimulator state that stalled the boot.
collect_simulator_diagnostics() {
    local dir="$PREBID_SIMULATOR_DIAGNOSTICS_DIR"
    local logs="$HOME/Library/Logs/CoreSimulator"
    mkdir -p "$dir"
    echo "Writing simulator diagnostics to $dir" >&2
    run_with_timeout 60 xcrun simctl list -j devices > "$dir/devices.json" 2>&1 || true
    grep -A6 "\"udid\" : \"$SIMULATOR_ID\"" "$dir/devices.json" >&2 || true
    cp "$logs/CoreSimulator.log" "$dir/" 2>/dev/null || true
    cp -R "$logs/$SIMULATOR_ID" "$dir/device-logs" 2>/dev/null || true
    run_with_timeout 600 simctl_diagnose -b --no-archive --timeout=300 \
        --output="$dir/simctl-diagnose" --udid="$SIMULATOR_ID" > "$dir/simctl-diagnose.out" 2>&1 \
        || echo "simctl diagnose did not complete; see simctl-diagnose.out." >&2
    if [[ -f "$dir/CoreSimulator.log" ]]; then
        echo "Last CoreSimulator.log lines:" >&2
        tail -n 40 "$dir/CoreSimulator.log" >&2
    fi
}

# simctl diagnose waits for ENTER after its privacy notice and exits without collecting
# anything when stdin is closed.
simctl_diagnose() {
    printf '\n' | xcrun simctl diagnose "$@"
}
