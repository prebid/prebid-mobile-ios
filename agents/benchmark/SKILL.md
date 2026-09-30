---
name: benchmark
description: Measure prebid-mobile-ios performance — the download size the SDK adds to a publisher's app, and one-off wall-clock timing of hot paths like bid-request building, response parsing, and creative scanning. Use when asked how big the SDK is, whether a change costs size or time, or to investigate a suspected performance regression.
---

# /benchmark [size | time]

Two measurements with very different trust levels. Conflating them is the main way
performance work here goes wrong.

| | Download size | Wall clock |
|---|---|---|
| Reproducible | yes — identical on a fixed Xcode | no — device, thermals and load all move it |
| Quotable | yes | only from a physical device, with the deviation stated |
| Committed | nothing is; measure on demand | nothing is |

Nothing is wired to measure either automatically. That is deliberate: a timing gate on
shared CI runners produces noise, and noise gets ignored.

---

## Download size

Prebid Mobile is a dependency — whatever it weighs lands in someone else's app download.
This is the number publishers actually feel, and the only one reproducible enough to quote
without caveats.

### Build, then measure

```bash
./scripts/buildPrebidMobile.sh
```

Produces four `.xcframework` bundles in `generated/output/` (gitignored). Then:

```bash
for f in generated/output/*.xcframework; do
  n=$(basename "$f" .xcframework); n=${n#XC}
  b="$f/ios-arm64/$n.framework/$n"
  [ -f "$b" ] && printf "%-32s %10s bytes\n" "$n" "$(stat -f%z "$b")"
done
```

**Measure the `ios-arm64` device slice.** The `ios-arm64_x86_64-simulator` slice carries an
extra architecture and never ships, so measuring it counts bytes nobody downloads.

Report the size of the binary. Do not break it into segments or sections — the whole-file
number is the one that means something to a publisher, and a breakdown only invites
arguments about which part "really" counts.

### Sanity check

Rough magnitudes to catch a measurement that went wrong — a partial build, the simulator
slice by mistake, the wrong path:

  core ≈ 3 MB · GAM and AdMob adapters ≈ 4 MB each · MAX adapter well under 1 MB · total ≈ 11 MB

These are deliberately coarse. Exact figures move with the Xcode release, so pinning them
here would go stale and invite the cross-version comparison the next section warns against.
If you need a real before/after, take both measurements yourself in one sitting on one
Xcode, and record the version with them:

```bash
xcodebuild -version
```

### Traps

- **Never compare across Xcode versions.** Two Xcodes produce different sizes from identical
  source. A jump that appears right after an Xcode upgrade is the compiler, not the SDK.
  Always state the Xcode build id next to the number.
- **Adapters are mostly not Prebid's code.** Google's SDK ships as a *static* library, so
  the linker copies it into `PrebidMobileGAMEventHandlers` and `PrebidMobileAdMobAdapters`
  — that is why each is around 4 MB. AppLovin ships *dynamically* and is not copied in,
  which is why `PrebidMobileMAXAdapters` is about 0.15 MB. Never quote an adapter's size as
  Prebid's cost: an app using GAM already ships Google's SDK. Check which kind a vendor SDK
  is with `file <vendor-binary>` — `ar archive` means static and embedded,
  `dynamically linked shared library` means not.
- **Adapters need current pods.** They fail at `Check Pods Manifest.lock` when
  `Pods/Manifest.lock` is stale against `Podfile.lock`; `pod install --repo-update` fixes
  it. If only some frameworks built, say so — never present a partial build as the SDK's
  size.
- **Growth is usually attributable.** New `public` API pins symbols the linker would
  otherwise strip, so cross-check a jump against the `public-api-baseline` diff in the same
  change. A new dependency is the only thing that costs megabytes.

---

## Wall clock

Worth measuring only for genuinely hot, CPU-bound paths: bid-request assembly
(`PBMParameterBuilderService`), ORTB serialize/parse (`PBMORTBAbstract`), response parsing
(`BidResponse(jsonDictionary:)`), and the `AdViewUtils` creative regex scan — which runs on
the **main thread** after render in the original API.

### How

Write a throwaway `XCTestCase` in the `PrebidMobileTests` target (`@testable import
PrebidMobile`; the bridging header already exposes `PBM*`), build every fixture in `setUp`,
and `measure(metrics:options:)` the workload. Reuse existing `Mock*` doubles and test
fixtures — a hand-made payload drifts from what the SDK actually handles and then measures
something production never sees.

```bash
xcodebuild test -workspace PrebidMobile.xcworkspace -scheme PrebidMobileTests \
  -destination 'platform=iOS,id=<device-udid>' \
  -only-testing:PrebidMobileTests/<YourPerfTests>
```

Delete the test afterwards unless it is worth maintaining. **If you keep one, it must not go
into `PrebidMobilePRTests.xctestplan`'s skipped-tests list** — that list is a shrink-only
ratchet (`skiplist-ratchet`, CLAUDE.md test-integrity). Gate it on an environment variable
with `XCTSkipUnless` instead, so it compiles everywhere and runs only when asked.

### Reading the numbers

- **Deviation before average.** Relative standard deviation ≲ 2% is trustworthy; ≳ 10% means
  the *benchmark* is broken, not the code. Never report a regression from a >10% run.
- **Batch anything under ~1 ms.** Below that the timer's resolution dominates: measured
  bare, a workload reports ~30% deviation for code that did not change. Loop it 20–100×
  inside the measured block. The figure is then per batch, so the batch size is part of the
  benchmark's identity — changing it invalidates comparison with earlier runs.
- **`CPU Instructions Retired` is the most stable metric**, largely immune to clock and
  thermal drift. Prefer it when comparing two runs on one device.
- **`Memory Physical` is quantized to 16 KB pages** — it reads 0 or 16384 and nothing
  between, so its deviation is an artefact. Read `Memory Peak Physical` for allocation
  regressions.
- **Simulator numbers measure your Mac** — its cores, its clocks, no thermal ceiling. Good
  for catching a large algorithmic regression and nothing else.
- **Compare like with like**: same device, same session, same batch size. A device that
  thermally throttled between two runs invalidates the pair.

---

## Reporting

Write for someone who does not know this codebase. Lead with the numbers in megabytes and
milliseconds. Put method and caveats underneath, short.

```
SDK download size — Xcode <version from `xcodebuild -version`>, arm64 device build

  PrebidMobile (core)             2.83 MB
  PrebidMobileGAMEventHandlers    4.00 MB
  PrebidMobileAdMobAdapters       4.01 MB
  PrebidMobileMAXAdapters         0.15 MB
  -------------------------------------
  Total                          10.99 MB

The GAM and AdMob adapters embed Google's SDK, which those publishers already ship —
their size is not additional download for those apps.
```

Three rules, each of which has been got wrong before:

- **Say what you did not measure.** A build that produced only some frameworks is a partial
  measurement.
- **Never call a simulator timing "performance."** Say "simulator" every time you quote one.
- **Never report a regression from a run with >10% deviation.** Fix the benchmark and re-run
  before saying anything about the code.
