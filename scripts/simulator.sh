# shellcheck shell=bash
# Simulator settings shared by the test scripts. Source this file, then call
# create_test_simulator. Override any value through the environment:
#   PREBID_SIMULATOR_NAME             simulator name (suffixed by scripts that need their own)
#   PREBID_SIMULATOR_DEVICE_TYPE      CoreSimulator device type identifier
#   PREBID_TEST_RUNTIME               runtime identifier; defaults to the latest installed runtime
#   PREBID_SIMULATOR_BOOT_TIMEOUT     seconds boot_test_simulator waits for the first boot (1 to 86400)
#   PREBID_SIMULATOR_DIAGNOSTICS_DIR  where boot_test_simulator writes diagnostics if that wait fails
#
# create_test_simulator installs an EXIT trap that deletes the simulator, and every simctl call
# handles SIGINT, SIGTERM and SIGHUP while it runs. A sourcing script must not set its own traps
# for EXIT or for those signals.

PREBID_SIMULATOR_NAME="${PREBID_SIMULATOR_NAME:-iPhone-17-Pro-PrebidMobile}"
PREBID_SIMULATOR_DEVICE_TYPE="${PREBID_SIMULATOR_DEVICE_TYPE:-com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro}"
# First-boot data migration has taken up to 7 minutes on CI runners.
PREBID_SIMULATOR_BOOT_TIMEOUT="${PREBID_SIMULATOR_BOOT_TIMEOUT:-900}"
PREBID_SIMULATOR_DIAGNOSTICS_DIR="${PREBID_SIMULATOR_DIAGNOSTICS_DIR:-$PWD/generated/log/simulator-diagnostics}"

# Limits, in seconds, for the other simctl calls. Each normally takes a few seconds, but a
# CoreSimulator that stalls the boot can stall them too.
SIMULATOR_LIST_TIMEOUT=60
SIMULATOR_CREATE_TIMEOUT=120
SIMULATOR_DELETE_TIMEOUT=120
SIMULATOR_DIAGNOSE_TIMEOUT=600
# A command that outlives its limit gets SIGTERM, then SIGKILL after this many seconds, and then
# as long again to exit.
SIMULATOR_STOP_GRACE=5

SIMULATOR_ID=""            # UUID of the simulator this script created
SIMULATOR_CREATING=""      # name given to a simctl create whose UUID is not known yet
SIMULATOR_TIMED_GROUP=""   # process group run_with_timeout is waiting for
SIMULATOR_TIMED_REAPED=0   # 1 once that group's leader has been waited for
SIMULATOR_LAUNCHING=0      # 1 while run_with_timeout starts that group
SIMULATOR_LAUNCH_MARK=""   # value of $! just before that start
SIMULATOR_LAST_JOB=""
SIMULATOR_PAUSE_PID=""
SIMULATOR_CLEANING=0       # 1 while the exit trap runs
SIMULATOR_IN_SIGNAL=0
SIMULATOR_FOUND_IDS=""
SIMULATOR_TEMP_DIR=""

# Creates a simulator named $1 (default PREBID_SIMULATOR_NAME) and sets SIMULATOR_ID. Devices
# with exactly that name, left by an interrupted run, are deleted first; if that fails or times
# out, this fails rather than create a second device with the same name. The exit trap deletes
# the device by its UUID when the script exits, on failure too. Which signals reach that trap
# depends on what the script is doing; see simulator_untrap_signals.
create_test_simulator() {
    local name="${1:-$PREBID_SIMULATOR_NAME}" output status=0
    trap simulator_exit_trap EXIT
    delete_simulators_named "$name" || return
    simulator_make_temp_dir || return
    output="$SIMULATOR_TEMP_DIR/create.out"
    # Until the UUID is read, the exit trap finds an interrupted creation by its name.
    SIMULATOR_CREATING="$name"
    run_with_timeout "$SIMULATOR_CREATE_TIMEOUT" xcrun simctl create "$name" "$PREBID_SIMULATOR_DEVICE_TYPE" \
        ${PREBID_TEST_RUNTIME:+"$PREBID_TEST_RUNTIME"} > "$output" || status=$?
    if (( status != 0 )); then
        echo "Could not create simulator $name (status $status)." >&2
        return "$status"
    fi
    SIMULATOR_ID="$(tr -d '[:space:]' < "$output")"
    if ! simulator_is_uuid "$SIMULATOR_ID"; then
        echo "simctl create printed '$SIMULATOR_ID' instead of a simulator UUID." >&2
        SIMULATOR_ID=""
        return 1
    fi
    SIMULATOR_CREATING=""
}

# Exit trap set by create_test_simulator. It stops a simctl call that is still running and
# deletes the simulator, each within its limit, then returns, so the script keeps its exit status.
# A signal during this cleanup, including the cleanup after an ordinary exit, stops the call in
# progress and ends the script at once, which leaves the simulator behind if its deletion had not
# finished.
simulator_exit_trap() {
    # A failing command or unset variable here would replace the script's exit status.
    set +eu
    SIMULATOR_CLEANING=1
    SIMULATOR_IN_SIGNAL=0
    simulator_trap_signals
    simulator_stop_running
    if [[ -n "$SIMULATOR_ID" ]]; then
        local id="$SIMULATOR_ID"
        SIMULATOR_ID=""
        run_with_timeout "$SIMULATOR_DELETE_TIMEOUT" xcrun simctl delete "$id" >/dev/null 2>&1 \
            || echo "Could not delete simulator $id (status $?)." >&2
    elif [[ -n "$SIMULATOR_CREATING" ]]; then
        local name="$SIMULATOR_CREATING"
        SIMULATOR_CREATING=""
        delete_simulators_named "$name" \
            || echo "Could not delete simulator $name, whose creation did not finish." >&2
    fi
    simulator_remove_temp_dir
    trap - INT TERM HUP
}

# Deletes every simulator named $1. Fails if listing or deleting fails or times out, or if a
# device with that name is still listed afterwards.
delete_simulators_named() {
    local name="$1" id status=0
    simulator_list_ids "$name" || return
    [[ -n "$SIMULATOR_FOUND_IDS" ]] || return 0
    for id in $SIMULATOR_FOUND_IDS; do
        echo "Deleting simulator $name ($id)." >&2
        run_with_timeout "$SIMULATOR_DELETE_TIMEOUT" xcrun simctl delete "$id" || status=$?
        if (( status != 0 )); then
            echo "Could not delete simulator $id (status $status)." >&2
            return "$status"
        fi
    done
    simulator_list_ids "$name" || return
    if [[ -n "$SIMULATOR_FOUND_IDS" ]]; then
        echo "Simulator $name is still listed after its deletion: ${SIMULATOR_FOUND_IDS//$'\n'/ }" >&2
        return 1
    fi
}

# Sets SIMULATOR_FOUND_IDS to the UUIDs of the simulators named exactly $1, one per line. A listing
# that fails, times out or cannot be read fails this function; it never counts as "no devices".
simulator_list_ids() {
    local name="$1" list ids status=0
    SIMULATOR_FOUND_IDS=""
    simulator_make_temp_dir || return
    list="$SIMULATOR_TEMP_DIR/devices.json"
    run_with_timeout "$SIMULATOR_LIST_TIMEOUT" xcrun simctl list -j devices > "$list" || status=$?
    if (( status != 0 )); then
        echo "Could not list simulators (status $status)." >&2
        return "$status"
    fi
    ids="$(simulator_ids_named "$name" "$list")" || status=$?
    if (( status != 0 )); then
        echo "Could not read the simulator list (status $status)." >&2
        return "$status"
    fi
    SIMULATOR_FOUND_IDS="$ids"
}

# Prints the UUID of each device named exactly $1 in file $2, the output of
# `simctl list -j devices`. Names are compared after JSON decoding, so backslashes, tabs, leading
# spaces, parentheses and non-ASCII characters match only themselves. Fails if the listing is not
# the expected JSON or a device entry lacks a string name or a valid UUID.
simulator_ids_named() {
    python3 -I -c '
import json, re, sys

name, path = sys.argv[1], sys.argv[2]
uuid = re.compile(r"[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}")
with open(path, encoding="utf-8") as listing:
    runtimes = json.load(listing)["devices"]
if not isinstance(runtimes, dict):
    sys.exit("simctl listed no device table")
for devices in runtimes.values():
    if not isinstance(devices, list):
        sys.exit("simctl listed a runtime without a device array")
    for device in devices:
        if not isinstance(device, dict) or not isinstance(device.get("name"), str):
            sys.exit("simctl listed a device without a name: %r" % (device,))
        udid = device.get("udid")
        if not isinstance(udid, str) or not uuid.fullmatch(udid):
            sys.exit("simctl listed a device without a valid UUID: %r" % (device,))
        if device["name"] == name:
            print(udid)
' "$1" "$2"
}

simulator_is_uuid() {
    [[ ${#1} -eq 36 && "$1" != *[!0-9A-Fa-f-]* ]]
}

simulator_make_temp_dir() {
    [[ -n "$SIMULATOR_TEMP_DIR" ]] && return 0
    SIMULATOR_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/prebid-simulator.XXXXXX")"
}

simulator_remove_temp_dir() {
    case "$SIMULATOR_TEMP_DIR" in
        */prebid-simulator.*) rm -rf -- "$SIMULATOR_TEMP_DIR" ;;
    esac
    SIMULATOR_TEMP_DIR=""
}

# Runs a command in a process group of its own, with stdin from /dev/null, and returns its status.
# The command and anything it leaves running in its group get $1 seconds (a whole number); after
# that the group is stopped and this returns 124, never earlier than $1 seconds. SIGINT, SIGTERM
# and SIGHUP stop the group as well, then end the script. macOS runners have no coreutils timeout.
run_with_timeout() {
    local seconds="$1" start="$SECONDS" pid status=0
    shift
    simulator_trap_signals
    simulator_last_job
    SIMULATOR_LAUNCH_MARK="$SIMULATOR_LAST_JOB"
    SIMULATOR_LAUNCHING=1
    # Job control gives the command its own process group, so stopping the group also stops its
    # children, such as the simctl process behind xcrun or a pipeline inside a shell function.
    # A terminal stops a background group that reads from it, or that writes to it under
    # `stty tostop`; with SIGTTIN and SIGTTOU ignored, such reads fail and writes go through.
    case $- in
        *m*) ( trap '' TTIN TTOU; "$@" ) < /dev/null & ;;
        *) set -m; ( trap '' TTIN TTOU; "$@" ) < /dev/null & set +m ;;
    esac
    pid=$!
    SIMULATOR_TIMED_GROUP="$pid"
    SIMULATOR_TIMED_REAPED=0
    SIMULATOR_LAUNCHING=0
    # Waiting for the whole group keeps a report writer from outliving the command that started it.
    while kill -0 -- "-$pid" 2>/dev/null; do
        if (( ! SIMULATOR_TIMED_REAPED )) && ! kill -0 "$pid" 2>/dev/null; then
            wait "$pid" || status=$?
            SIMULATOR_TIMED_REAPED=1
        fi
        # SECONDS counts whole seconds, so one more than the limit has to pass.
        if (( SECONDS - start > seconds )); then
            if (( SIMULATOR_TIMED_REAPED )); then
                echo "'$1' exited, but left processes running for over $seconds s." >&2
            fi
            stop_process_group "$pid" "$SIMULATOR_TIMED_REAPED"
            SIMULATOR_TIMED_GROUP=""
            simulator_untrap_signals
            return 124
        fi
        simulator_pause 0.2
    done
    if (( ! SIMULATOR_TIMED_REAPED )); then
        wait "$pid" || status=$?
    fi
    SIMULATOR_TIMED_GROUP=""
    simulator_untrap_signals
    return "$status"
}

# Stops process group $1: SIGTERM, then SIGKILL after SIMULATOR_STOP_GRACE seconds, then waits as
# long again. Unless $2 says the leader was already waited for, the leader is signalled directly
# too, in case it left the group. A process that survives that is left running; nothing here
# waits for it.
stop_process_group() {
    local group="$1" reaped="${2:-0}"
    simulator_signal_group TERM "$group" "$reaped"
    if ! simulator_wait_gone "$group" "$reaped"; then
        simulator_signal_group KILL "$group" "$reaped"
        if ! simulator_wait_gone "$group" "$reaped"; then
            echo "Process group $group was still running ${SIMULATOR_STOP_GRACE} s after SIGKILL." >&2
        fi
    fi
    if (( ! reaped )) && ! kill -0 "$group" 2>/dev/null; then
        wait "$group" 2>/dev/null || true
    fi
}

simulator_signal_group() {
    kill "-$1" -- "-$2" 2>/dev/null || true
    if (( ! $3 )); then
        kill "-$1" "$2" 2>/dev/null || true
    fi
}

# Returns once neither process group $1 nor, unless $2 is 1, its leader exists, or fails after
# SIMULATOR_STOP_GRACE seconds. Counting polls keeps the grace close to its nominal length.
simulator_wait_gone() {
    local group="$1" reaped="$2" polls=$(( SIMULATOR_STOP_GRACE * 5 ))
    while kill -0 -- "-$group" 2>/dev/null || { (( ! reaped )) && kill -0 "$group" 2>/dev/null; }; do
        if (( polls <= 0 )); then
            return 1
        fi
        simulator_pause 0.2
        polls=$((polls - 1))
    done
}

# Sleeps in the background and waits for it, because the wait builtin returns as soon as a
# trapped signal arrives, while a foreground command would delay the trap until it finished.
simulator_pause() {
    sleep "$1" &
    SIMULATOR_PAUSE_PID=$!
    wait "$SIMULATOR_PAUSE_PID" 2>/dev/null || true
    SIMULATOR_PAUSE_PID=""
}

# Reads $! without failing under set -u before the first background command.
simulator_last_job() {
    case $- in
        *u*) set +u; SIMULATOR_LAST_JOB="$!"; set -u ;;
        *) SIMULATOR_LAST_JOB="$!" ;;
    esac
}

simulator_trap_signals() {
    trap 'simulator_on_signal 130' INT
    trap 'simulator_on_signal 143' TERM
    trap 'simulator_on_signal 129' HUP
}

# Outside simctl calls, for example while a caller runs xcodebuild in the foreground, signals keep
# Bash's default handling, as before these traps existed; a trap would only run once that command
# finished. With the default handling, on Bash 3.2:
# - SIGTERM or SIGHUP ends the script at once and the exit trap runs. A foreground command that
#   did not get the signal itself keeps running.
# - SIGINT to the process group (Ctrl-C) ends the command and the script, and the exit trap runs
#   when the script is a file, as the callers are. Under `bash -c`, Bash skips the exit trap.
# - SIGINT sent only to the script's PID is ignored: the command finishes and the script goes on.
simulator_untrap_signals() {
    if (( ! SIMULATOR_CLEANING )); then
        trap - INT TERM HUP
    fi
}

# Signal trap: stops the simctl call in progress and ends the script with status $1 (128 plus the
# signal number). Outside the exit trap, that runs the exit trap; inside it, cleanup stops there.
simulator_on_signal() {
    if (( SIMULATOR_IN_SIGNAL )); then
        return 0
    fi
    SIMULATOR_IN_SIGNAL=1
    simulator_stop_running
    exit "$1"
}

# Stops the command run_with_timeout is waiting for, including one whose start was interrupted
# before its process group was recorded.
simulator_stop_running() {
    local group
    if [[ -n "$SIMULATOR_PAUSE_PID" ]]; then
        kill "$SIMULATOR_PAUSE_PID" 2>/dev/null || true
    fi
    if (( SIMULATOR_LAUNCHING )); then
        simulator_last_job
        if [[ -n "$SIMULATOR_LAST_JOB" && "$SIMULATOR_LAST_JOB" != "$SIMULATOR_LAUNCH_MARK" ]]; then
            SIMULATOR_TIMED_GROUP="$SIMULATOR_LAST_JOB"
            SIMULATOR_TIMED_REAPED=0
        fi
        SIMULATOR_LAUNCHING=0
    fi
    if [[ -n "$SIMULATOR_TIMED_GROUP" ]]; then
        group="$SIMULATOR_TIMED_GROUP"
        SIMULATOR_TIMED_GROUP=""
        stop_process_group "$group" "$SIMULATOR_TIMED_REAPED"
    fi
}

# Prints $2 as a number of seconds, or fails if it is not a whole number from 1 to 86400. Leading
# zeros are decimal, so "08" is 8 rather than an invalid octal number. The range is checked before
# any arithmetic, so a huge value cannot wrap around.
whole_seconds() {
    local name="$1" value="$2" digits=""
    case "$value" in
        "" | *[!0-9]*) ;;
        *) digits="${value#"${value%%[!0]*}"}" ;;
    esac
    if [[ -z "$digits" || ${#digits} -gt 5 ]] || (( 10#$digits > 86400 )); then
        echo "$name must be a whole number of seconds from 1 to 86400, not '$value'." >&2
        return 2
    fi
    echo "$((10#$digits))"
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
    collect_simulator_diagnostics || echo "Could not collect simulator diagnostics." >&2
    return "$status"
}

# Writes the simulator's state and logs to a new folder under PREBID_SIMULATOR_DIAGNOSTICS_DIR,
# named after the time and the simulator, so that a report never includes another run's files.
# Each simctl call is bounded too, since it can stall on the same CoreSimulator state.
collect_simulator_diagnostics() {
    local logs="$HOME/Library/Logs/CoreSimulator" dir stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    if ! mkdir -p "$PREBID_SIMULATOR_DIAGNOSTICS_DIR" 2>/dev/null \
        || ! dir="$(mktemp -d "$PREBID_SIMULATOR_DIAGNOSTICS_DIR/$stamp-$SIMULATOR_ID.XXXXXX" 2>/dev/null)"; then
        echo "Cannot create a diagnostics folder in $PREBID_SIMULATOR_DIAGNOSTICS_DIR." >&2
        return 1
    fi
    echo "Writing simulator diagnostics to $dir" >&2
    run_with_timeout "$SIMULATOR_LIST_TIMEOUT" xcrun simctl list -j devices > "$dir/devices.json" 2>&1 || true
    grep -A6 "\"udid\" : \"$SIMULATOR_ID\"" "$dir/devices.json" >&2 || true
    cp "$logs/CoreSimulator.log" "$dir/" 2>/dev/null || true
    cp -R "$logs/$SIMULATOR_ID" "$dir/device-logs" 2>/dev/null || true
    run_with_timeout "$SIMULATOR_DIAGNOSE_TIMEOUT" simctl_diagnose -b --no-archive --timeout=300 \
        --output="$dir/simctl-diagnose" --udid="$SIMULATOR_ID" > "$dir/simctl-diagnose.out" 2>&1 \
        || echo "simctl diagnose did not complete (status $?); see simctl-diagnose.out." >&2
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
