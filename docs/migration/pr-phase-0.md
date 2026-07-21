## Summary

Phase 0 of the ObjC → Swift migration for `PrebidMobile/Objc/`. Must merge before any Phase 1 Swift twins are opened.

**S0.1 — Functional-gap audit & playbook** (`docs/migration/playbook.md`): 5 gaps identified and codified:
- NSCopying: drop entirely — no ORTB callsite ever calls `.copy()` on a model
- Empty child dict suppression: `JSONObject` subscript setter now skips empty dicts (`JSONParsing.swift` fix)
- `PBMORTBFormat` needs `isEqual`/`hash` overrides (used in `NSSet` deduplication)
- Phase 1–3 twins must be `@objc class … : NSObject` until ObjC parameter builders migrate in Phase 3
- `init?` vs broken-instance fallback: Swift `nil` return is correct, audit tests in S1.1

**S0.2 — Parity harness** (`ORTBParityHelper.swift`): `assertORTBParity<ObjCType, SwiftType>` + baseline fixtures for all Phase 1 leaf types.

**Build fix:** `TestCasesManager.swift` — `UserUniqueID.id → uniqueId` missed in #1257.

**S0.3 — Tooling hardening & CI cleanup:**

- **Removed dead CircleCI provisioning** from all four build/test scripts (`buildPrebidMobile.sh`, `testPrebidMobile.sh`, `testPrebidMobileAdapters.sh`, `testPrebidDemo.sh`). The repo now runs exclusively on GitHub Actions (`macos-15`), which ships with CocoaPods 1.16.2 pre-installed; the hardcoded `/Users/distiller/...` PATH prepend and unconditional `gem install cocoapods` were never effective on GHA.
- **Hardened `testPrebidMobile.sh`**: pre-deletes `iPhone-16-Pro-PrebidMobile` simulator before `simctl create` (prevents failure on rerun after a crash); scoped the previously argument-less `xcodebuild clean build` to `-workspace PrebidMobile.xcworkspace -scheme PrebidMobileTests` with an explicit simulator destination.
- **Fixed flaky `PrebidEventDelegateTests.test_eventDelegate_isCalled`**: `PBMBidRequester` also fires `callEventDelegateAsync_prebidBidRequestDidFinishWith` when bid responses land, so in-flight requests from other tests can invoke the mock delegate a second time and crash the process with `assertForOverFulfill`. Set `exp.assertForOverFulfill = false` — the test verifies the delegate is called at least once, not exactly once.
- **Updated CLAUDE.md**: verified build/test details (XCFramework output naming, `Lib-` scheme prefix, two-step `build-for-testing`/`test-without-building` flow, test counts, `--latest`/`--quick` flag semantics); added rule that new test classes must be registered in `PrebidMobilePRTests.xctestplan`; removed `CLAUDE.md` from `.gitignore` so it is tracked.
- **Updated `/xcodebuild` skill** and added new **`/build-sdk` skill** covering the full XCFramework build pipeline.

## Test plan
- [x] `./scripts/testPrebidMobile.sh --latest --quick` — 694 tests, 0 failures
- [x] `./scripts/testPrebidMobile.sh --latest` — 1111 tests, 0 failures (full plan, including previously-crashing `PrebidEventDelegateTests`)
- [x] Reviewer: confirm gap decisions in `docs/migration/playbook.md` before S1 PRs open — all 5 confirmed; Gap 5 note: S1.1 should spot-check `PBMBidResponseTransformerTest` and `PBMORTBTest` for any indirect reliance on the broken-instance fallback path
