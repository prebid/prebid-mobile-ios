# Phase 6 wave 6J notes: AdLoadManager, AdRequesterVAST, transaction factories

Branch `worktree-agent-aa21697d77ab42640` (fast-forwarded onto `swift-migration-phase-6` first). Input for the integrator, not a PR doc.

## Files

Ported (all `@_spi(PBMInternal) public`, ObjC runtime names kept via `@objc(PBMFoo)`; no ObjC code references them any more):

| ObjC (deleted) | Swift (new) |
|---|---|
| `PBMAdLoadManagerBase.{h,m}` | `Swift/PrebidMobileRendering/AdTypes/AdView/AdLoadManagerBase.swift` (non-final, `required init`) |
| `PBMAdLoadManagerVAST.{h,m}` | `.../AdTypes/AdView/AdLoadManagerVAST.swift` |
| `PBMAdRequesterVAST.{h,m}` | `.../AdTypes/AdView/AdRequesterVAST.swift` |
| `PBMTransactionFactory.m` (`PBMTransactionFactory_Objc`) | `.../Prebid/PBMCore/TransactionFactory/TransactionFactoryImpl.swift` (`final`, internal, no `@objc` name) |
| `PBMVastTransactionFactory.{h,m}` | `.../Prebid/PBMCore/TransactionFactory/VastTransactionFactory.swift` (`final`, internal) |

Also deleted: `PrivateHeaders/PBMTransactionFactoryCallback.h` (the Swift `TransactionFactoryCallback` typealias already existed).
`Factory.swift`: removed `TransactionFactoryType` (the `NSClassFromString("PBMTransactionFactory_Objc") as!` force-cast); `createTransactionFactory` now returns `TransactionFactoryImpl(...)` directly.
No other `Factory.swift` lookup was touched. Nothing else referenced `TransactionFactoryType` (rg over PrebidMobile, tests, EventHandlers).
Stale "still called from ObjC" comments updated in `DisplayTransactionFactory`, `VastAdsBuilder`, `VastRequester`, `CreativeModelCollectionMakerVAST` (comment-only).

Verified nothing ObjC subclassed or referenced these (rg for the PBM names over PrebidMobile/EventHandlers/tests/scripts after the change: only the test mock's own name).
`PBMVideoCreative` (ObjC) does not depend on any of them.

## Deviations (S5.2-C: ObjC message-to-nil fixed point)

| # | Site | ObjC | Swift | Status |
|---|------|------|-------|--------|
| 1 | `Base.init` `PBMAssert(connection)` | assert (compiled out in release) | non-optional `PrebidServerConnectionProtocol` | forced; every caller is Swift (S3.1-H measured) |
| 2 | `dispatchQueue` | `dispatch_queue_create("PBMAdLoadManager", NULL)` (serial) | `DispatchQueue(label: "PBMAdLoadManager")` (serial) | same; created in init; only `AdLoadManagerVAST.load(from:)` uses it (one `async` hop, not on main) |
| 3 | `makeCreativesWithCreativeModels:` | `model.expirationInterval = self.bid.exp` | same, `Bid.exp` is `NSNumber?`, `expirationInterval` is `NSNumber?` | same (nil exp clears the interval, as before) |
| 4 | `transaction.bid = bid`, `.delegate = self` | message-to-nil impossible, `Factory.createTransaction` is non-optional | local `let transaction`, stored into `currentTransaction` first | same order: store, bid, delegate, `startCreativeFactory` |
| 5 | `transactionReadyForDisplay` | notify then `self.currentTransaction = nil` | same order | `currentTransaction = nil` kept |
| 6 | `failedToLoadTransaction` Optional vs `TransactionDelegate.transactionFailedToLoad(_: Transaction, ...)` non-optional | ObjC passed `nil` from `requestCompletedFailure` and from the maker failure callback, the real transaction from `transactionFailedToLoad` | `AdLoadManagerDelegate.loadManager(_:failedToLoad: Transaction?, error:)` (Wave 1C) keeps Optional: `nil` from both request/maker failure paths, the non-optional transaction passes straight through in `transactionFailedToLoad`. `VastTransactionFactory` ignores the transaction in both cases, as before | no mismatch left to bridge |
| 7 | `@weakify/@strongify` | `if (!self) { log; return }` | `[weak self]` + `guard let self else { Log.error(same text); return }` in `load(from:)`, both maker callbacks, `AdRequesterVAST` loaders, `VastTransactionFactory.onFinished`, `TransactionFactoryImpl.callbackForProperFactory` | same (strings unchanged, including `"PBMAdLoadManagerVast is nil!"` casing) |
| 8 | `loadFromString:` data | `[vastString dataUsingEncoding:NSUTF8StringEncoding]` | `Data(vastString.utf8)` | identical bytes (UTF-8 encoding of a Swift string cannot fail) |
| 9 | `requestCompletedSuccess:` | `[self.creativeModelCollectionMaker makeModels:...]` (nil maker = silent no-op) | `creativeModelCollectionMaker?.makeModels(...)` | `creativeModelCollectionMaker` and `adRequester` are Optional properties, set in `prepareForLoading` |
| 10 | `AdRequesterVAST.adLoadManager` weak, type `AdLoadManagerVAST?` | `weak` `PBMAdLoadManagerVAST *` | `weak var` | cycle kept weak; `AdLoadManagerVAST` owns the requester strongly |
| 11 | `adLoadManager requestCompletedFailure:`/`Success:` on a nil weak ref | message to nil | `adLoadManager?.` | same |
| 12 | `serverResponse.rawData` | `nonnull`-annotated NSData param; nil data reached `buildVastAdsArray:` | `serverResponse?.rawData ?? Data()` | empty data fails the parse with the same "VAST Parsing failed" path |
| 13 | `PBMLogWhereAmI()` | macro (file/line/function of the macro) | `Log.whereAmI()` | same message, caller location differs |
| 14 | `loadVASTURL:` and empty `-load` | `loadVASTURL:` was only declared in the `.m` (private), `-load` was an empty `// TODO: REMOVE ME` stub | `loadVASTURL` ported as internal func (no callers); `-load` dropped | `loadVASTURL` is dead, kept so `VastRequester.loadVastURL` keeps a user; deletion candidate for the post-migration cleanup list |
| 15 | `TransactionFactory_Objc.loadWithAdMarkup:` | `[adMarkup containsString:@"<VAST"]` -> VAST branch else HTML | `adMarkup.contains("<VAST")` (exact literal `<VAST`, not `&lt;VAST`; the task text's `&lt;` was an HTML rendering of `<`) | same. `isLoading` is checked first, `currentFactory` is the generic `NSObject?` as in ObjC and cleared in `onFinished` before the callback |
| 16 | callback threading | HTML factory and VAST factory both hop to the main queue in their own `onFinished`; `TransactionFactory_Objc.onFinishedWithTransaction` invoked `self.callback` synchronously on whatever thread it was called from | unchanged: main-queue `async` + `[weak self]` in `VastTransactionFactory.onFinished` and `DisplayTransactionFactory`; `TransactionFactoryImpl.onFinished` stays synchronous | same |
| 17 | `TransactionFactory_Objc` `callback` `copy` | `[callback copy]` | `@escaping` closure stored | same |
| 18 | `Base` property visibility | `@property` strong, public in header | `@objc public var` (needed so the mock/tests subclass and read them from the test target) | `connection`, `adConfiguration`, `bid`, `dispatchQueue` public SPI; `currentTransaction` private (was a class-extension property) |
| 19 | `Base`/`VAST` method names | `makeCreativesWithCreativeModels:`, `requestCompletedFailure:`, `loadFromString:`, `requestCompletedSuccess:` | explicit `@objc(...)` selectors, same spelling; Swift names `makeCreatives(creativeModels:)`, `load(from:)` | selectors preserved (S4.3-A) |

`AdRequesterVAST.buildVastAdsArray:` keeps the selector via `@objc(buildVastAdsArray:)`; the Swift name is `buildAdsArray(_:)` (existing test usage; the ObjC test bridge imported it as `buildAdsArray` through the Swift name mapping, so the 10 test call sites needed no edit).

## Gap candidates

- **S6.x-J-A (non-final Swift base with a protocol `init` requirement).** `AdLoadManagerProtocol.init(bid:connection:adConfiguration:)` forces `required init` on the non-final `AdLoadManagerBase`; subclasses that add no designated initializers (`AdLoadManagerVAST`, the test mock) inherit it automatically, no `required` repetition.
- **S6.x-J-B (Swift subclass in the SDK of another SPI class needs nothing special; ObjC subclassing proved unnecessary).** Porting `Base` + `VAST` as a pair removed the "ObjC subclasses a Swift `@objc` class" question entirely (the S5.x-scope "inferred, not compiled" caveat is moot).
- **S6.x-J-C (factory seam retired).** A `*_Objc` class behind a `Factory.swift` `NSClassFromString` lookup can be ported to an internal `final` Swift class constructed directly by the factory method; the `@objc(...)` name, the `TransactionFactoryType` static and the `as!` cast all disappear. Only valid when no ObjC code looks the name up (measured).
- **S6.x-J-D (`@objc(name)` bridge names on now-Swift-only classes).** `PBMAdLoadManagerBase/VAST`, `PBMAdRequesterVAST` keep their `@objc(PBM...)` names (stable runtime names, like `InterstitialLayoutConfigurator`); `PBMVastTransactionFactory`/`PBMTransactionFactory_Objc` do not. Candidates to drop in S9.x.

## pbxproj deltas (xcodeproj gem recipe, `/tmp/j_proj.rb`, not committed; `plutil -lint` OK)

Removed from `PrebidMobile`: Sources `PBMAdRequesterVAST.m`, `PBMAdLoadManagerBase.m`, `PBMAdLoadManagerVAST.m`, `PBMTransactionFactory.m`, `PBMVastTransactionFactory.m`; Headers `PBMAdLoadManagerBase.h`, `PBMAdLoadManagerVAST.h`, `PBMAdRequesterVAST.h`, `PBMTransactionFactoryCallback.h`, `PBMVastTransactionFactory.h`; file refs; the now-empty `AdLoadManager` and `TransactionFactory` ObjC groups.
Added to `PrebidMobile` Sources: `AdLoadManagerBase.swift`, `AdLoadManagerVAST.swift`, `AdRequesterVAST.swift` (group `Swift/.../AdTypes/AdView`), `TransactionFactoryImpl.swift`, `VastTransactionFactory.swift` (group of `DisplayTransactionFactory.swift`).
Tests target: unchanged (no files added/removed; only edits).

## Orphan headers

`PBMTransactionFactoryCallback.h` (orphan table row B) deleted. `PBMAdLoadManagerDelegate.h` / `PBMAdLoadManagerProtocol.h` rows in the playbook are already stale (the ObjC headers are gone since Wave 1C; the protocols are Swift) and can be struck by the integrator. Orphan count should drop by 1 versus the playbook's 36 (re-measure with the `comm` snippet).

## Tests changed

- `MockPBMAdLoadManagerVAST.swift`: superclass `PBMAdLoadManagerVAST` -> `AdLoadManagerVAST` (it already was a Swift subclass overriding `requestCompletedSuccess(_:)`/`requestCompletedFailure(_:)`, which are now ordinary Swift overrides; `mock_requestCompletedSuccess/Failure` API unchanged). Already imports `@_spi(PBMInternal) @testable`.
- `PBMAdRequesterVAST(` -> `AdRequesterVAST(`, `PBMAdLoadManagerVAST(` -> `AdLoadManagerVAST(` (11 test files), `AdViewManagerTest` `PBMAdLoadManagerBase!` -> `AdLoadManagerBase!`. Class/method names of the tests kept (`PBMAdRequesterVASTTest`, ...).
- `PrebidMobileTest-Bridging-Header.h`: removed `PBMAdLoadManagerBase.h`, `PBMAdLoadManagerVAST.h`, `PBMAdRequesterVAST.h`.

### Leftover bridging-header lines (not mine)
Still present: `PBMVastGlobals.h` (line "// VAST" + import; `PBMVastGlobals.m` is a live ObjC file not in my scope; used by the video creative cluster), and the unrelated `PBMConstants.h`, `PBMCreativeFactory.h`, `PBMCreativeFactoryJob.h`, `PBMDeepLinkPlusHelper*.h`, `PBMHTMLCreative.h`, `PBMHTMLFormatter.h`, `PBMMacros.h`, `PBMModalState.h`, `PBMMRAID*.h`, `PBMORTB.h`, `PBMUIApplicationProtocol.h`, `PBMVideoCreative.h`, `PBMWebView*.h`, the `WK*` category headers, `Log+Extensions.h`, OM wrappers and the `*+PBMTestExtension.h` set. No remaining AdLoadManager/AdRequester/TransactionFactory/Vast(parser, builder, maker) lines.

## NSMutableArray retyping (NOT done)

Left as `NSMutableArray` (no ObjC mutator remains, so retyping is now possible, but it is a ~250-site change across the model, `VastParser`, `VastAdsBuilder`, `VastResponse`, `VastCreative*`, `CreativeModelCollectionMakerVAST`, and 14 test files, plus the `VastModelDump`/parity expectations): `VastAbstractAd.{impressionURIs,errorURIs,creatives}`, `VastCreativeLinear.{icons,mediaFiles,clickTrackingURIs}`, `VastCreativeCompanionAds.companions`, `VastCreativeCompanionAdsCompanion.clickTrackingURIs`, `VastCreativeNonLinearAds.nonLinears`, `VastCreativeNonLinearAdsNonLinear.clickTrackingURIs`, `VastIcon.clickTrackingURIs`, `VastResponse.vastAbstractAds`. Retyped: none. Recommended as its own follow-up (also lets the `// surviving ObjC ... appends in place` comments go).

## Builds and tests

- `xcodebuild -workspace PrebidMobile.xcworkspace -scheme PrebidMobileTests -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/phase6-dd-J build-for-testing`: TEST BUILD SUCCEEDED (first attempt, no errors).
- `scripts/buildPrebidMobilePackage.sh` (SPM): succeeded.
- Tests run on existing simulator `iPhone 16 Pro Max` (id `C320D4C9-...`, iOS 18.4; nothing created/deleted): `PBMVASTFailToLoadTest`, `PBMAdRequesterVASTTest`, `PBMVastLoaderTestSingleInline`, `PBMVastLoaderTestWrapperPlusInline`, `PBMVastLoaderTestOMVerificationOneInline`, `PBMVastLoaderTestOMVerificationInExtension`, `PBMVastLoaderMultiWrapperTest`, `CreativeModelCollectionMakerVASTTests`, `RewardedVideoEventsTest`, `RewardedVideo_CompanionTest`, `VastEventTrackingTest`, `AdViewManagerTest`, plus the TransactionFactory users `BannerViewTest`, `BaseInterstitialAdUnitTest`, `MediationBannerAdUnitTest`, `PluginRendererFactoryTest`, `ModalViewControllerTest`: 114 tests, 0 failures. Full suite not run.
- `swiftlint --config .swiftlint.yml` on the five new files: 0 violations after rewording a comment (a `TODO` in a comment tripped the todo rule).

## Integrator notes

- Merge hot spots: `project.pbxproj` (re-run the recipe), `PrebidMobileTest-Bridging-Header.h`, `Factory.swift` (`TransactionFactoryType` removed).
- Nothing in ObjC references `PBMAdLoadManager*`, `PBMAdRequesterVAST`, `PBMVastTransactionFactory`, `PBMTransactionFactory_Objc` any more; playbook S4.5-B "Phase 6 must pick these up" is fulfilled, and the S5.x-scope "not compiled" caveat is moot.
- Untracked `Pods` symlink in the worktree; not committed.
