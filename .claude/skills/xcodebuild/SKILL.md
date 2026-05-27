---
name: xcodebuild
description: Run xcodebuild tests for a scheme or specific test class in PrebidMobile.xcworkspace
---

Run xcodebuild tests for this iOS project. The workspace is `PrebidMobile.xcworkspace`.

## Available schemes

- `PrebidMobileTests` — core SDK unit tests (694 tests in PR plan, 1111 in full plan)
- `PrebidMobileGAMEventHandlersTests` — GAM adapter tests
- `PrebidMobileAdMobAdaptersTests` — AdMob adapter tests
- `PrebidMobileMAXAdaptersTests` — MAX adapter tests

Default simulator destination: `platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest`

## Running the full suite via the wrapper script (preferred)

For a full or PR suite run, prefer the script over raw xcodebuild:

```bash
# PR subset — 694 tests, used on PRs in CI
./scripts/testPrebidMobile.sh --latest --quick

# Full suite — 1111 tests, used on bump-to branches / run-full-tests label
./scripts/testPrebidMobile.sh --latest
```

The script handles simulator create/delete, the two-step build-for-testing /
test-without-building flow, -retry-tests-on-failure, and the correct test plan
(-testPlan PrebidMobilePRTests or PrebidMobileTests).

## Pass/fail policy

**`--quick` run is the gate for migration PRs.** Any failure in `./scripts/testPrebidMobile.sh --latest --quick` is a regression that must be fixed before committing. Do not recheck the same failure on another branch or re-run to dismiss it — if it fails, investigate and fix.

The only exception is `PBMBidRequesterTest.testBanner_300x250` (documented in playbook.md as a pre-existing flaky test). If that is the sole failure and it passes when run in isolation, proceed. Every other failure is a hard stop.

## Running a single test class (raw xcodebuild)

Use the two-step approach so you can iterate without rebuilding:

### Step 1 — ensure the simulator exists

```bash
xcrun simctl delete iPhone-16-Pro-PrebidMobile 2>/dev/null || true
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro
```

### Step 2 — build for testing (once)

```bash
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
  -destination-timeout 60 \
  build-for-testing
```

### Step 3 — run tests (repeat without rebuilding)

```bash
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
  -destination-timeout 60 \
  -only-testing PrebidMobileTests/<TestClass> \
  test-without-building
```

Omit `-only-testing` to run the full scheme. Add `/<testMethod>` to narrow to a single test.

If no scheme is specified by the user, default to `PrebidMobileTests`.
Report pass/fail and the executed/failed counts clearly after the run.
