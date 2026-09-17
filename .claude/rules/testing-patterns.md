# Testing patterns

## Where tests live

| Target | What | Runs |
|---|---|---|
| `PrebidMobileTests` | Core unit tests (Swift + some ObjC) | every PR (quick plan) / full plan |
| `PrebidMobile*AdaptersTests` (GAM/AdMob/MAX) | Adapter unit tests | PR when `EventHandlers/` changes |
| `PrebidDemoTests` | Integration tests via demo app | `run-full-tests` label / release branches |
| `PrebidDemoSwiftUITests` | UI tests | same gating |

Two xctestplans control the unit-test split: `PrebidMobileTests.xctestplan` (full) and
`PrebidMobilePRTests.xctestplan` (quick; a skip-list of slow/timing-sensitive tests).
**The skip-list may only shrink** — never add entries to get a green run.

## Shared infrastructure (changes here require the FULL unit suite)

- `RenderingTests/Mocks/MockServer/` — `NSURLProtocol`-based HTTP interception (ObjC):
  `MockServer`, `MockServerRule`, `MockServerRuleRedirect`, `MockServerRuleSlow`.
- `RenderingTests/Utilities/` — `UtilitiesForTesting`, `PBMAssert`, `LogToFileLock`.
- Swizzling helpers — `AdUnitSwizzleHelper.swift`, `Swizzling.swift`. Always restore the
  original implementation in `tearDown`; a leaked swizzle poisons unrelated tests.

## Conventions

- Test naming: `test<What><Condition>` (`testFetchDemandAutoRefresh...`).
- Prefer MockServer rules over hand-rolled URLSession stubs; prefer existing `Mock*` doubles
  over new ones — check `RenderingTests/Mocks/` before writing a mock.
- Timing-sensitive tests (auto-refresh, timeouts) belong in the full plan, not the quick
  plan — but they still must pass; flakiness is a bug, not a candidate for the skip-list.
- ORTB/request-format tests assert on the built wire request (see `RequestBuilderTests`);
  each assertion of protocol behavior cites the OpenRTB spec section in the docstring
  (see the spec-grounding gate in CLAUDE.md).
- ORTB *response* models get hostile-input tests, not just happy-path ones: for every new
  `Decodable`/parsed model, feed wrong-typed fields, nulls, missing keys, and out-of-range
  values, and assert graceful degradation (nil/default/skip), never a crash. A year of
  upstream issues concentrated here — #1300/#1255 (fields decoded with spec-violating
  types), #1259 (decimal conversion), #1273 (crash on unexpected nil). The
  `ortb-test-presence` guard checks a test exists; this convention defines what it must
  cover. Field-type assertions cite the spec, same as request-side tests.
- ObjC API-compatibility tests (`PrebidObjcTests.m`, `TargetingObjCTests.m`) exist to prove
  the ObjC surface still compiles and behaves — public API changes usually need a
  counterpart assertion there.

## Running

```bash
./scripts/testPrebidMobile.sh --latest --quick   # quick plan (PR default)
./scripts/testPrebidMobile.sh --latest           # full plan
./scripts/testPrebidMobileAdapters.sh            # 3 adapter schemes
./scripts/testPrebidDemo.sh -l                   # integration; add -ui for UI tests
```

macOS + Xcode required; the script installs pods and manages its own named simulator. On a
non-mac environment, report unit tests as SKIPPED with the reason — never as passed.
