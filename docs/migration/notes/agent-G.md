# Phase 6 wave 4G notes: VastParser

Branch `worktree-agent-a1558e2244548d4e9` (fast-forwarded onto `swift-migration-phase-6` first). Input for the integrator, not a PR doc.

## Files

Ported: `PBMVastParser.m` (639 lines) + `PrivateHeaders/PBMVastParser.h` + `PrivateHeaders/PBMVastParser+Private.h`
-> `PrebidMobile/Swift/PrebidMobileRendering/AdTypes/Video/Vast/VastParser.swift`
(`@objc(PBMVastParser) @_spi(PBMInternal) public class VastParser: NSObject, XMLParserDelegate`).

Deleted: the `.m` and both headers. Consumers `PBMVastAdsBuilder.m` and `PBMCreativeModelCollectionMakerVAST.m` lost their
`#import "PBMVastParser.h"` (both already import `SwiftImport.h`); `PBMVastAdsBuilder.m` still calls `[PBMVastParser new]` and
`-parseAdsResponse:` (selector kept with `@objc(parseAdsResponse:)`, init with explicit `@objc public override init()`).
`PBMVastAdsBuilder.h` keeps `@class PBMVastParser;` (resolves against the generated header). Test bridging header lost
`PBMVastParser+Private.h`. Nothing subclasses the class (measured with `rg`).

Test-only members of the old `+Private` category (`parseResource(for:)`, `parseTimeInterval(_:)`, `extractCreativeContainer()`) and the
parser state properties (`parsedResponse`, `ad`, `inlineAd`, `wrapperAd`, `adAttributes`, `creative`, `currentElementAttributes`, ...)
are plain `internal` (reachable through `@testable`); only `parseAdsResponse` is `@objc public`. The delegate methods are `public`
(protocol conformance of a public class).

## Parity tests (new)

All in `PrebidMobileTests/RenderingTests/Tests/VASTTests/`:

| File | Role |
|------|------|
| `VastModelDump.swift` | renders a parsed `VastResponse` as deterministic text: every property the parser writes, `nil` vs `""` distinguished, tracking events sorted, progress offsets, verification resources |
| `VastParserParityCases.swift` | the inputs: 12 fixture files + 9 synthetic documents + empty data + non-XML |
| `VastParserParityExpectations.swift` | literal expected dumps, **captured from the ObjC `PBMVastParser`** (throwaway `VastParserCapture` test run against the ObjC parser, then rebuilt against Swift and `diff -r` of the two dump directories: byte-identical on all 23 cases) |
| `VastParserParityTests.swift` | asserts Swift parser output == expectations, and that case set == expectation set |

Fixtures covered (all samples used by `PBMVastParserTests` and `PBMVastLoader*`/`CreativeModelCollectionMakerVASTTests`/`PBMAdRequesterVASTTest`/`PBMVASTFailToLoadTest`):
`vast.3.0.xml`, `VAST_with_companion.xml`, `VAST_with_empty_companion.xml`, `VAST_Empty_Inline.xml`, `VAST_Empty_Response.xml`,
`VAST_Empty_Response2.xml`, `document_with_one_inline_ad.xml`, `document_with_one_wrapper_ad.xml`, `inline_with_padding_on_urls.xml`,
`prebid_vast_response.xml`, `vast_om_verification_from_extension.xml`, `vast_om_verification_one_inline_ad.xml`.
Synthetic (branches no fixture reaches): `linear_icons_media` (all icon attrs/children, three resource kinds, skipoffset, progress offsets,
bad ints/floats, bare MediaFile), `companion_nonlinear` (required mode, companion/nonlinear attrs+resources+clicks+tracking, orphan resource/click
before any NonLinear, empty CompanionAds), `wrapper_sequences` (wrapper attrs incl. non-`true`, bad/zero/partial sequences), `text_handling`
(entity-split chunks, CDATA+text mix, parent text split by child), `misplaced_and_unknown` (unknown elements, Error at several depths, Tracking
without event leaving the element path unpopped, elements outside their creative), `verifications` (resources, tracking, outside/in-wrapper),
`no_ads_no_version`, `malformed_mismatched_tag`, `malformed_truncated`, `empty_data`, `not_xml`.
Not covered by an *independent* full-model assertion before this wave: nothing relevant; the existing loader tests still assert their own fields.

The mismatched-tag/truncated/empty/non-XML cases all return `nil` (the parse aborts, `parserDidEndDocument` never fires).

## Deviations (S5.2-C: ObjC message-to-nil fixed point)

| # | Site | ObjC | Swift | Status |
|---|------|------|-------|--------|
| 1 | `parserDidStartDocument` / `parsedResponse` | `parsedResponse` nonnull-in-practice after start | `VastResponse?`; every use is `?.`/`if let` | same observable behavior (a delegate callback before `parserDidStartDocument` cannot happen) |
| 2 | `[ads addObject:]` in `Ad` end | `NSMutableArray arrayWithArray:` copy, append, assign | same (`NSMutableArray(array:)`, append, assign), wrapped in `if let parsedResponse` | the ObjC messaged a nil response silently; unreachable |
| 3 | `parseBool/Int/Float` | `NSString.integerValue/floatValue` | `(string as NSString).integerValue/floatValue` | kept on purpose (Swift `Int("12abc")` would be nil); verified by the `"x"`, `"3.9"`, `"12abc"` synthetic cases |
| 4 | sequence `intValue` | `if (str.intValue) sequence = str.intValue` | `(str as NSString).intValue`, assign when `!= 0` | `Int32` truncation preserved |
| 5 | `Wrapper` `id followAdditionalWrappersKey = attributeDict[..]; if (key)` | | `if let` | same |
| 6 | `Companion`/`NonLinear`/`Icon`/`MediaFile` start, `creative` of another class | unchecked C-cast `(PBMVastCreativeLinear *)self.creative`; `if (!x)` only catches nil, so a non-nil wrong-class creative continued and raised unrecognized selector | `as?` cast; logs the same error and returns | forced by Swift (a failed `as?` is nil); only reachable for malformed documents; not covered by a parity case because the ObjC original crashes there |
| 7 | `Duration` end | `currentElementContent ? parse : 0` | `parseTimeInterval(currentElementContent)` | content is non-optional, ternary was always true |
| 8 | `Tracking` end, companion/nonLinear branches | `lastObject` with `isKindOfClass` implied by typed array | `lastObject as? Companion` / `as? NonLinear` | untyped `NSMutableArray` (S6.1-B); a foreign element yields nil tracking object and the "No suitable tracking events" log, as the ObjC did for an empty list |
| 9 | `Verification` end | `arrayByAddingObject:self.verificationResource` (nil would raise) then assign | `if let verificationResource { append }` | the ObjC raised on a `Verification` end with no resource, which cannot occur in well-formed XML (start always sets it); malformed XML aborts earlier |
| 10 | `AdVerifications` end | `self.inlineAd.verificationParameters = self.verificationParameter` (assign nil into nonnull) | assigns only when non-nil | S5.2-C: Swift type is non-optional. Differs only when `AdVerifications` ends with no parameter object (cannot happen) or has no `inlineAd` (Wrapper: dropped in both; covered by `synthetic_verifications`) |
| 11 | `currentElementAttributes` | `NSDictionary *`, nil after end element | `[String: String]?`, nil after end element | same; `attributes` param defaults to `[:]` in the Swift signature as the protocol requires non-optional |
| 12 | `Error` end path check | `[path subarrayWithRange:NSMakeRange(0, 2)]` raises `NSRangeException` when `elementPath.count < 2` | `Array(path.prefix(2)) == [...]` | forced: no raise. Only differs when `Error` is the document root element (path length 1); ObjC crashed, Swift ignores it. Not covered (ObjC crashes) |
| 13 | logging | `PBMLogError(@"...%ld", (long)type)` (file/line/function of the macro) | `Log.error("...\(type.rawValue)")` | message text identical; log prefix file/function differ |
| 14 | `-parseAdsResponse:` `nonnull NSData` | | `Data` | ObjC passes the same bytes |
| 15 | `currentElementContext`, `currentElementName` | public properties | kept, `internal` | written but never read, as before |

Early `return`s that leave `elementPath` unpopped (`Tracking` without an event, `Companion`/`NonLinear`/`Icon`/`MediaFile`/click handlers on a wrong creative) were
preserved line for line (they are ObjC bugs; covered by `synthetic_misplaced_and_unknown`, whose dump shows the leaked path effect on later `Error` handling).

## Gap candidates

- **S6.x-G-A (a throwaway ObjC-era dump as parity oracle).** For a delegate/state-machine port, write a deterministic text dump of the model, run a
  throwaway capture test against the ObjC class, commit the dump as `#"""..."""#` literals, then re-run the same dump against the Swift port and `diff -r`
  the two output directories before deleting the ObjC. Raw-string literals add no trailing newline: append `\n` when generating. The dump must print
  `nil` and `""` differently or S5.2-C regressions hide.
- **S6.x-G-B (`NSString` numeric parsing stays `NSString`).** `NSString.integerValue/floatValue/doubleValue/intValue` are prefix-lenient and never fail;
  `Int(_:)`/`Double(_:)` are strict. Use `(string as NSString).integerValue` to port ObjC attribute parsing.
- **S6.x-G-C (typed ObjC delegate attribute dictionary).** The `XMLParserDelegate` signature needs `attributes attributeDict: [String: String] = [:]`.
- **S6.x-G-D (`@objc(parseAdsResponse:)` on a function with a single unlabeled parameter).** Needed because a bare `@objc` would import as `parseAdsResponse:` only by
  coincidence; the explicit selector is cheap insurance (S4.3-A).

## pbxproj deltas

Gem recipe (scripts `/tmp/g/proj1.rb`, `proj2.rb`, `proj3.rb`, not committed), `plutil -lint` OK each time:
- `PrebidMobile` target: -`PBMVastParser.m` (Sources), -`PBMVastParser.h`, -`PBMVastParser+Private.h` (Headers) and file refs; +`VastParser.swift` (Sources, group `Video/Vast`).
- `PrebidMobileTests` target: +`VastModelDump.swift`, `VastParserParityCases.swift`, `VastParserParityExpectations.swift`, `VastParserParityTests.swift` (group `VASTTests`).

## Orphan headers

None created. `PBMVastParser.h` and `PBMVastParser+Private.h` removed (both had a `.m`/were its category; the playbook's orphan list line
`PBMVastParser+Private.h | class continuation` can be struck by the integrator, count unchanged because it is not in the 36 re-measured set).
Re-measured `comm` of `.h` without `.m` should be unchanged.

## Tests changed

`PBMVastParserTests.swift`: `PBMVastParser` -> `VastParser` (perl `\bPBMVastParser\b`, applied only to that test file; test class and method names kept,
including `testVastParserDidEndElementAd`'s local `pbmVastParser` variables). It already used `@_spi(PBMInternal) @testable import`.
The existing `parseResource(for:)`/`parseTimeInterval`/`extractCreativeContainer` tests needed no other edit.

## Builds and tests

- `xcodebuild -workspace PrebidMobile.xcworkspace -scheme PrebidMobileTests -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/phase6-dd-G build-for-testing`: TEST BUILD SUCCEEDED.
- `scripts/buildPrebidMobilePackage.sh` (SPM): succeeded.
- Tests **were run**, on the existing simulator `iPhone 16 Pro Max` (iOS 18.4, id `C320D4C9-...`, already present; no simulator created/deleted, no `pod install`, the shared
  `iPhone-17-Pro-PrebidMobile` name untouched): `VastParserParityTests`, `PBMVastParserTests`, `CreativeModelCollectionMakerVASTTests`, `PBMVastLoaderTestSingleInline`,
  `PBMVastLoaderTestWrapperPlusInline`, `PBMVastLoaderTestOMVerificationOneInline`, `PBMVastLoaderTestOMVerificationInExtension`, `PBMVastLoaderMultiWrapperTest`,
  `PBMVastLoaderCheckForAds`, `PBMAdRequesterVASTTest`, `PBMVASTFailToLoadTest`: 30 tests, 0 failures. Full suite not run.
- `swiftlint --config .swiftlint.yml` on `VastParser.swift` and the three new test helpers: 0 serious; `type_body_length` warnings (parser 457, dump 222, cases 292 lines) because the
  parser is one delegate class and the helpers are data.

## Integrator notes

- Merge hot spots: `project.pbxproj` (re-run the three-part recipe), `PrebidMobileTest-Bridging-Header.h`, the two `#import "PBMVastParser.h"` removals.
- With the parser gone, the remaining ObjC consumers of the Vast model are `PBMVastAdsBuilder.m` and `PBMCreativeModelCollectionMakerVAST.m`; once they are Swift, the untyped
  `NSMutableArray` properties (S6.1-B deviations in waves 2D/3F) can be typed and the `.add(...)` calls in `VastParser.swift` become `append`.
- `VastParser` keeps the NSMutableArray-based model API unchanged, so it does not need to move with them.
- A `Pods` symlink exists in the worktree, untracked; not committed.
