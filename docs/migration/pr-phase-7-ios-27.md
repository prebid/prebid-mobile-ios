# iOS 27 follow-up

Follow-up on `codex/issue-1410-spm-dependencies`. The dependency migration and
native/SPM build-product separation are documented in
[development-dependencies.md](../development-dependencies.md).

## Completed work

- **S7.3-E:** Preserve the original WebView parity capture, with one iOS 27-specific
  expected line for Foundation's malformed-percent normalization. Recompiled the
  original `PBMMRAIDCommand.m` from the parent of migration commit `31cf748d` in a
  Foundation-only simulator probe. On iOS 27, both original and port reject
  `mraid:expand/%E0%A4%25A` with the same error. On iOS 26.5 the original URL
  becomes `mraid:expand/%25E0%25A4%25A`, and the original command accepts
  `%E0%A4%A`, matching the unchanged legacy capture. No MRAID parser behavior changed.
  The property tests explicitly load a document, await its ready state, reuse
  that page, and replace the JavaScript stub for every input. The existing
  10-second waits remain unchanged.
- **S7.x-F:** Snapshot the observed video item's status/error before dispatching
  callbacks to the main queue, and ignore replaced items. The three new tests
  failed against the old code: two readiness callbacks, two failure callbacks,
  and one callback from a replaced item. No expectation or timeout was relaxed.
- Adopt UIKit's scene lifecycle in InternalTestApp and InternalTestApp-Skadn,
  using the existing Main storyboard. UIKit on iOS 27 requires this when built
  with the iOS 27 SDK ([UIKit migration guidance](https://developer.apple.com/documentation/uikit/transitioning-to-the-uikit-scene-based-life-cycle)).
  UI-test animation speed is applied after scene connection.
  The custom interstitial renderer finds its presentation window through an
  active window scene.

## Verification

- [x] iOS 27 development support: 3 form, 6 mock-client and 1 UI smoke test pass.
- [x] iOS 27 core PR suite: 1,023 passed, zero failures, no retries, including
  all three new regression tests.
- [x] iOS 26.5: 33 selected video/parity tests and all 10 development-support
  tests pass, with zero failures.
- [x] Original Objective-C malformed-URL probes on iOS 26.5 and iOS 27.
- [x] Skadn app builds and launches on iOS 27; main screen renders.
- [x] Four device/simulator XCFrameworks built; all 24 Swift interfaces typecheck.
- [x] Root SPM package build.

## CI follow-up for PR #1421

The first CI run passed framework/interface builds, the root SPM package, adapter
checks, and development-app checks. The quick suite failed during cold WebKit
startup, the 58 MB download-size fixture, and delayed wrapper-failure callbacks.

- Wait for simulator boot/migration before building, and delete the owned device
  on both success and failure.
- Replace fire-and-forget WebKit warm-up with a bundle observation that waits for
  JavaScript to execute before tests begin. Keep the page alive until bundle
  completion. The startup budget is 180 seconds (cold CI helper launches have
  previously exceeded 170 seconds); failure stops the run. Individual assertion
  deadlines remain unchanged.
- Only create the JavaScript property fixture for tests that use it, and attach
  it to a window while probing. Pure parity comparisons keep their original oracle
  and no longer load an unused document.
- Retain both standalone VAST requester/load-manager fixtures through their
  asynchronous completion waits.
- Replace the download-size test's three MP4 transfers with eight small byte/header
  cases using the real URLSession/MockServerURLProtocol path. Assert exact bytes,
  below/equal/above-limit behavior, missing/malformed/negative Content-Length, and
  the absence of a GET when HEAD rejects the download. Deadlines remain two seconds.

Validation:

- [x] Local iOS 26.5 PR suite: 1,030 tests passed with zero failures and no retries.
- [x] Local iOS 27 affected tests: 75 executions across five repetitions, zero failures.

GitHub Actions validation is recorded in [PR #1421 checks](https://github.com/prebid/prebid-mobile-ios/pull/1421/checks).
