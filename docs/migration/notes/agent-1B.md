# Agent 1B notes (Phase 7): MRAIDJavascriptCommands, MRAIDCommand, HTMLFormatter

## Files

Ported to Swift, ObjC deleted:

| Swift | Deleted ObjC |
|-------|--------------|
| `PrebidMobile/Swift/PrebidMobileRendering/AdTypes/AdView/MRAIDJavascriptCommands.swift` | `AdTypes/AdView/PBMMRAIDJavascriptCommands.m`, `Objc/PrivateHeaders/PBMMRAIDJavascriptCommands.h` |
| `.../AdTypes/MRAIDCommand.swift` | `AdTypes/PBMMRAIDCommand.m`, `PrivateHeaders/PBMMRAIDCommand.h` |
| `.../AdTypes/HTMLFormatter.swift` | `AdTypes/PBMHTMLFormatter.m`, `PrivateHeaders/PBMHTMLFormatter.h` |

All three are `@objc(PBMFoo) @_spi(PBMInternal) public` with explicit selectors for every member the surviving ObjC
callers use (`PBMWebView.m`, `PBMMRAIDController.m`, `PBMHTMLCreative.m`). Selectors were not guessed: the ObjC callers
compile unchanged, which checks them. `PBMMRAIDConstants.m` untouched.

New tests: `MRAIDParityTests.swift`, `MRAIDParityExpectations.swift`. Updated: `MRAIDJavascriptCommandsTests`,
`PBMWebViewTest`, `PBMMRAIDCommandTest`, `PBMHTMLFormatterTest`, `PBMMRAIDControllerTest` (renames, `.rawValue`, SPI import),
`LocationManagerTest`, `UtilsTests` (see "lost transitive import" below), test bridging header (3 imports removed).

## Parity evidence (S6.x-G-A)

- Throwaway ObjC dump (`PrebidMobileTests/RenderingTests/Tests/MRAIDParityDump.m`, an XCTestCase writing to a file; NOT committed,
  copy kept in `/tmp/p7-1B/oracle/`) run against the ObjC classes before deletion. It prints `nil` and `""` differently and
  escapes everything past ASCII as `\u{XXXX}`.
- **348 comparable lines** (plus 5 exception lines, below): 11 constants/booleans, 25 numeric values x 6 numeric commands (150, incl. NaN, +-inf,
  -0.0, 1e300, 0.00005/0.00015 rounding ties), 7 exposures + zero + nil, 6 states + nil, 13 volumes + nil,
  7 strings x (placementType, orientation x2, onError x 7 actions incl. nil/empty/quotes/unicode) , **48 MRAID URLs**
  (valid, missing args, malformed percent-encoding, odd casing, `İ`, unicode, empty segments, nil URL, nil error pointer),
  **37 HTML inputs** (with/without html/head/body/script, case variants, K-sign/sigma/dotless-i lowercasing traps, ZWJ after the match, 2000-char input).
- Expectations are committed literally (`MRAIDParityExpectations.swift`), checked by `MRAIDParityTests`. The same
  inputs rendered by the Swift port: 348/348 lines byte-identical (first run showed 348 failures purely because I had
  written `\t` in the expectations and ` => ` in the Swift dump; separator fixed in the expectations file, no value changed).
- The ObjC and Swift classes share a bridged name, so they cannot coexist in one build; the oracle output was frozen to
  `/tmp/p7-1B/objc-dump.orig.txt` first and `diff`ed through the test.
- Left out of the dump because the ObjC raised: 4 URLs with the scheme after index 0 and more text after it, and nil HTML. See deviations 1 and 2.

## Deviation table (each checked by running the ObjC)

| # | Site | ObjC (measured) | Swift | Status |
|---|------|-----------------|-------|--------|
| 1 | `MRAIDCommand.init`, scheme found after index 0 with text after it (`" mraid:open"`, `"xmraid:open"`, `"http://a/mraid:expand"`) | `-[NSString PBMsubstringFromString:]` (the Swift `NSString` extension already ported in S2.2) computes `length - range.length` as the substring length, which runs past the end: raised `NSInvalidArgumentException` (4/4 probed). `PBMMRAIDController.webView:handleMRAIDURL:` wraps the call in `@try` and logs a warning | throws "URL does not contain MRAID scheme: ..." (`PBMError`, code 700, logged). Controller then throws an `NSException` carrying that message, caught by the same `@try`, logged as a warning | **forced** (Swift cannot raise an ObjC exception from `throws`); message text differs, control flow same. Scheme at index 0, or at the end of the string (`"xmraid:"`), behaves exactly as before (in dump). Test: `testSchemeAfterStartOfURLIsRejected`. Also a latent bug in `NSString+PBMExtensions.swift`, not fixed here |
| 2 | `HTMLFormatter.ensureHTMLHasBodyAndHTMLTags(nil)` | `NSRegularExpression` raised `NSInvalidArgumentException` (nil argument) | parameter is non-optional `String` | **unreachable**: the only caller, `PBMHTMLCreative.m` `loadHTMLToWebView`, runs after `setupView` returns early on `!html`. Not a trap risk from ObjC via `PBMHTMLCreative`; any new ObjC caller passing nil would trap on bridging (S3.1-H) |
| 3 | `MRAIDCommand.init(url:)` nil URL | `nil` url returned nil with "URL is nil" (nil guard behind a `nonnull` header) | param declared `String?` (S2.2-B) and throws the same error, same domain/code | same |
| 4 | `MRAIDJavascriptCommands` `onExposureChange`/`onStateChange`/`updatePlacementType`/`updateCurrentAppOrientation`/`onError` with nil | `%@` printed `(null)` (probed: `mraid.onStateChange('(null)');`, `mraid.onExposureChange("(null)");`) | params are Optional and print `(null)` | same (S5.2-C). In the dump |
| 5 | Typed-enum parameters (`PBMMRAIDPlacementType`, `PBMMRAIDAction`) and `MRAIDCommand.command` | `NS_TYPED_ENUM` string typedefs | plain `String` (the Swift target cannot see `PBMMRAIDConstants.h`); ObjC callers still pass the same `NSString` constants. Swift tests use `PBMMRAIDAction.x.rawValue` | S2.1-A residue; fine |
| 6 | `MRAIDJavascriptCommands.onAudioVolumeChange` | `volumePercentage.floatValue` then `CGFloat` formatting | `CGFloat($0.floatValue)`, same float round trip (`0.1f` prints `0.1`, in dump) | same |
| 7 | Support features JSON | `NSDictionary` serialized with `NSJSONSerialization` | same, built as `NSDictionary` so key order is the ObjC one (a Swift `Dictionary` re-hashes per process). Order is process-hash dependent in both, as before; the existing test parses it | same |
| 8 | `MRAIDCommand` | lowercasing/compare via `NSString` | `(x as NSString).lowercased`, `isEqual(to:)`, `components(separatedBy:)`, `range(of:)` so `İ` etc. match (S6.x-K-A) | in dump (`cmd.22`, `cmd.47`) |
| 9 | Logging | `PBMLogError` / `[PBMError createError:...]` (which logs) | `Log.error`; `PBMError` created then logged | text same, file/function prefix differs |

Integer arithmetic: none in these files (only `NSRange` sums, bounded by the string length). `NSNumberFormatter` of NaN/inf
reproduced (`NaN`, `+∞`), and 1e300 prints `0.0` in both; both in the dump.

## Gap candidates (for the playbook; I did not edit it)

- **S2.5-A again (lost transitive import in an ObjC `.m`):** deleting `PBMMRAIDJavascriptCommands.h` removed `@import CoreLocation` from
  `PBMWebView.m`'s import chain (`CLLocationCoordinate2D`). Xcode build was green; only `buildPrebidMobilePackage.sh` failed
  ("definition of 'CLLocationCoordinate2D' must be imported from module ..."). Fixed with an explicit `@import CoreLocation;`.
- **S6.x-B again (Swift tests):** `LocationManagerTest.swift` and `UtilsTests.swift` lost `CoreLocation` the same way (they only
  had it through the bridging header). Added `import CoreLocation`.
- **Typed-enum arguments become `String` on the Swift side** once the consumer of an `NS_TYPED_ENUM` is ported but the constants stay
  in ObjC; Swift tests use `.rawValue`. Worth a line under S2.1-A.
- **`@_spi` and `String?` tests:** `PBMMRAIDControllerTest` and `PBMHTMLFormatterTest` needed `@_spi(PBMInternal) @testable import` once the type became SPI.
- **Existing bug:** `NSString.PBMsubstringFromString(_:)` (Swift, S2.2) uses `length - range.length` as the length, a copy of the ObjC
  arithmetic; it raises when the match is not at index 0. Only `MRAIDCommand` used it and no longer does.

## project.pbxproj deltas (xcodeproj gem only, `plutil -lint` OK)

- Removed: 3 `.m` Sources entries, 3 `.h` Headers entries, 6 file refs.
- Added: `HTMLFormatter.swift`, `MRAIDCommand.swift` (group `Swift/PrebidMobileRendering/AdTypes`), `MRAIDJavascriptCommands.swift` (`.../AdTypes/AdView`) in target `PrebidMobile`;
  `MRAIDParityTests.swift`, `MRAIDParityExpectations.swift` (`PrebidMobileTests/RenderingTests/Tests`) in target `PrebidMobileTests`.
- Validation: 0 dangling PBXBuildFiles, 0 file refs to missing files, each new file exactly 1 ref and 1 Sources entry. The temporary
  `MRAIDParityDump.m` was added and removed again (net zero).
- `Podfile.lock` unchanged.

## Orphan headers

None retired and none created: the three deleted headers each had a matching `.m` (not in the orphan table). Count stays **28**. `PBMModalState.h`
etc. unaffected. `PBMMRAIDConstants.h` still imported by the surviving ObjC files (`PBMWebView.h`, ...).
Remaining `.m` under `PrebidMobile/Objc`: 22 on this branch.

## Verification

- Xcode: `xcodebuild -workspace PrebidMobile.xcworkspace -scheme PrebidMobileTests -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/phase7-dd-1B build-for-testing`: **TEST BUILD SUCCEEDED** (final tree).
- SPM: `scripts/buildPrebidMobilePackage.sh`: **succeeded** (after the `PBMWebView.m` CoreLocation fix; failed before it).
- SwiftLint on the 5 new files: 0 serious, 6 warnings (`type_body_length` x3 incl. `MRAIDJavascriptCommands` at 133, `function_body_length`/`large_tuple` in the parity test, blanket `line_length` disable in the expectations file).
- Tests run on existing simulator `iPhone 17` (iOS 26.0, id 1727A2A3-..., already booted by someone else; no simulators created or deleted), via `-only-testing ... test-without-building`, **89 tests, 0 failures**:
  `MRAIDParityTests` (3), `MRAIDJavascriptCommandsTests` (2), `PBMMRAIDCommandTest` (2), `PBMHTMLFormatterTest` (3), `PBMWebViewTest` (37), `PBMMRAIDControllerTest`,
  `PBMMRAIDControllerObjCTest`, `PBMHTMLCreativeTest`, `PBMHTMLCreativeTest_NoMRAID`, `PBMHTMLCreativeTest_MRAIDExpand`, `PBMHTMLCreativeTest_MRAIDResize`, `LocationManagerTest`.
- Not run: the full or PR test plan, adapter tests, `buildPrebidMobile.sh` (forbidden), `verifySPM.sh`.

## Notes for the integrator

- Merge conflicts to expect in `project.pbxproj` (additive) and the test bridging header (3 lines removed: `PBMHTMLFormatter.h`, `PBMMRAIDCommand.h`, `PBMMRAIDJavascriptCommands.h`).
- When `PBMWebView`/`PBMMRAIDController`/`PBMHTMLCreative` move, call `MRAIDJavascriptCommands.x(...)` / `HTMLFormatter.ensureHTMLHasBodyAndHTMLTags(_:)` /
  `MRAIDCommand(url:)` directly, drop the `@objc(selector)` annotations, and the `String?` parameters can become non-optional where the Swift caller can't pass nil.
- `MRAIDController.command(from:)` (test extension header `PBMMRAIDController+pbmTestExtension.h`) still returns `PBMMRAIDCommand*`; it now resolves to the Swift class through `PrebidMobile-Swift.h`.
- Any later wave that deletes `CoreLocation`-carrying ObjC headers should rerun `buildPrebidMobilePackage.sh`.
