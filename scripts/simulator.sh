# shellcheck shell=bash
# Simulator settings shared by the test scripts. Source this file, then call
# create_test_simulator. Override any value through the environment:
#   PREBID_SIMULATOR_NAME             simulator name (suffixed by scripts that need their own)
#   PREBID_SIMULATOR_DEVICE_TYPE      CoreSimulator device type identifier
#   PREBID_TEST_RUNTIME               runtime identifier; defaults to the latest installed runtime
#   PREBID_SIMULATOR_BOOT_TIMEOUT     whole seconds boot_test_simulator waits for the first boot
#   PREBID_SIMULATOR_DIAGNOSTICS_DIR  where boot_test_simulator writes diagnostics if that wait fails

PREBID_SIMULATOR_NAME="${PREBID_SIMULATOR_NAME:-iPhone-17-Pro-PrebidMobile}"
PREBID_SIMULATOR_DEVICE_TYPE="${PREBID_SIMULATOR_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro}"
# First-boot data migration has taken up to 7 minutes on CI runners.
PREBID_SIMULATOR_BOOT_TIMEOUT="${PREBID_SIMULATOR_BOOT_TIMEOUT:-900}"
PREBID_SIMULATOR_DIAGNOSTICS_DIR="${PREBID_SIMULATOR_DIAGNOSTICS_DIR:-$PWD/generated/log/simulator-diagnostics}"

# Deleting a booted simulator normally takes a few seconds. A CoreSimulator that stalled the boot
# can stall the deletion too, and the job could then never upload its diagnostics.
SIMULATOR_DELETE_TIMEOUT=120
SIMULATOR_DIAGNOSE_TIMEOUT=600
# Process group of the command run_with_timeout is waiting for, so that the exit trap can stop it.
SIMULATOR_TIMED_GROUP=""

# Creates a simulator named $1 (default PREBID_SIMULATOR_NAME), replacing a leftover one from
# an interrupted run, and sets SIMULATOR_ID. The device is deleted by its ID when the script
# exits, including on failure.
create_test_simulator() {
    local name="${1:-$PREBID_SIMULATOR_NAME}"
    run_with_timeout "$SIMULATOR_DELETE_TIMEOUT" xcrun simctl delete "$name" 2>/dev/null || true
    SIMULATOR_ID="$(xcrun simctl create "$name" "$PREBID_SIMULATOR_DEVICE_TYPE" ${PREBID_TEST_RUNTIME:+"$PREBID_TEST_RUNTIME"})"
    trap delete_test_simulator EXIT
}

# Exit trap set by create_test_simulator. The deletion is bounded, and the script keeps the exit
# status it had before the trap ran.
delete_test_simulator() {
    local status=$?
    if [[ -n "$SIMULATOR_TIMED_GROUP" ]]; then
        stop_process_group "$SIMULATOR_TIMED_GROUP"
        SIMULATOR_TIMED_GROUP=""
    fi
    if ! run_with_timeout "$SIMULATOR_DELETE_TIMEOUT" xcrun simctl delete "$SIMULATOR_ID" >/dev/null 2>&1; then
        echo "Could not delete simulator $SIMULATOR_ID within ${SIMULATOR_DELETE_TIMEOUT} s." >&2
    fi
    exit "$status"
}

# Runs a command in its own process group and returns its status. If the command is still running
# after $1 seconds, stops the whole group, including children such as the simctl process behind
# xcrun or a pipeline inside a shell function, and returns 124. macOS runners have no coreutils
# timeout.
run_with_timeout() {
    local seconds="$1" pid status=0 deadline
    shift
    deadline=$((SECONDS + seconds))
    # Job control puts the background command in a process group of its own.
    case $- in
        *m*) "$@" & pid=$! ;;
        *) set -m; "$@" & pid=$!; set +m ;;
    esac
    SIMULATOR_TIMED_GROUP=$pid
    while kill -0 "$pid" 2>/dev/null; do
        if (( SECONDS >= deadline )); then
            stop_process_group "$pid"
            SIMULATOR_TIMED_GROUP=""
            return 124
        fi
        sleep 1
    done
    wait "$pid" || status=$?
    SIMULATOR_TIMED_GROUP=""
    return "$status"
}

# Sends TERM to process group $1, then KILL to whatever is left after 5 s, and returns once no
# process in the group is left, or after 10 more seconds.
stop_process_group() {
    local group="$1" waited=0
    kill -TERM -- "-$group" 2>/dev/null || true
    while kill -0 -- "-$group" 2>/dev/null && (( waited < 5 )); do
        sleep 1
        waited=$((waited + 1))
    done
    kill -KILL -- "-$group" 2>/dev/null || true
    waited=0
    while kill -0 -- "-$group" 2>/dev/null; do
        if (( waited >= 10 )); then
            echo "Process group $group was still running 10 s after SIGKILL." >&2
            break
        fi
        sleep 1
        waited=$((waited + 1))
    done
    wait "$group" 2>/dev/null || true
}

# Prints $2 as a number of seconds, or fails if it is not a positive whole number. Leading zeros
# are decimal, so "08" is 8 rather than an invalid octal number.
whole_seconds() {
    local name="$1" value="$2"
    case "$value" in
        "" | *[!0-9]*)
            echo "$name must be a positive whole number of seconds, not '$value'." >&2
            return 2
            ;;
    esac
    value=$((10#$value))
    if (( value <= 0 )); then
        echo "$name must be a positive whole number of seconds, not '$2'." >&2
        return 2
    fi
    echo "$value"
}

# Boots the simulator from create_test_simulator and waits until its first-boot data migration
# finishes. The wait is bounded: if the boot stalls, this records diagnostics and returns 124,
# instead of holding the runner until the job timeout.
boot_test_simulator() {
    local status=0 timeout
    timeout="$(whole_seconds PREBID_SIMULATOR_BOOT_TIMEOUT "$PREBID_SIMULATOR_BOOT_TIMEOUT")" || return 2
    run_with_timeout "$timeout" xcrun simctl bootstatus "$SIMULATOR_ID" -b || status=$?
    if (( status == 0 )); then
        return 0
    fi
    if (( status == 124 )); then
        echo "Simulator $SIMULATOR_ID did not finish booting within $timeout s." >&2
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
    run_with_timeout "$SIMULATOR_DIAGNOSE_TIMEOUT" simctl_diagnose -b --no-archive --timeout=300 \
        --output="$dir/simctl-diagnose" --udid="$SIMULATOR_ID" > "$dir/simctl-diagnose.out" 2>&1 \
        || echo "simctl diagnose did not complete; see simctl-diagnose.out." >&2
    if [[ -f "$dir/CoreSimulator.log" ]]; then
        echo "Last CoreSimulator.log lines:" >&2
        tail -n 40 "$dir/CoreSimulator.log" >&2
    fi
}

# simctl diagnose waits for ENTER after its privacy notice and exits without collecting
# anything when stdin is closed. run_with_timeout stops the pipeline's whole process group,
# so a timeout also stops simctl, not only the shell that runs this function.
simctl_diagnose() {
    printf '\n' | xcrun simctl diagnose "$@"
}
