# Phase 6 wave 1A notes: VAST leaf models

## Spike result (decisive): an ObjC class cannot subclass a Swift `@objc` class

`PBMVastCreativeLinear`, `PBMVastCreativeCompanionAds` and `PBMVastCreativeNonLinearAds` (still ObjC) subclass
`PBMVastCreativeAbstract`. With `PBMVastCreativeAbstract` ported to Swift as `@objc(PBMVastCreativeAbstract) open class`
the Xcode build fails:

    PBMVastCreativeLinear.h:22:12: error: cannot subclass a class that was declared with the
    'objc_subclassing_restricted' attribute   (same for CompanionAds.h:21, NonLinearAds.h:18)

Cause: the generated `PrebidMobile-Swift.h` emits `SWIFT_CLASS_NAMED(...)`, which expands to
`__attribute__((objc_subclassing_restricted))` for every Swift class, `open` or not. There is no Swift-side opt-out.
So the playbook's S5.x-scope inference ("ObjC `PBMAdLoadManagerVAST` can subclass a Swift `AdLoadManagerBase`") is
**false** too (same mechanism). Only the Xcode build was tried; SPM uses the same clang attribute.

Consequence: `PBMVastCreativeAbstract` and `PBMVastAbstractAd` were left ObjC, as instructed. `PBMVastInlineAd` and
`PBMVastWrapperAd` (subclass AbstractAd) and `PBMAdRequestResponseVAST` (its `ads` property is
`NSArray<PBMVastAbstractAd *>`) were left ObjC as well, because they depend on `PBMVastAbstractAd`. The whole subclass
chain (`CreativeAbstract` + `Linear`/`CompanionAds`/`NonLinearAds`, `AbstractAd` + `Inline`/`Wrapper`, and the ObjC
`PBMVastParser`/`PBMVastResponse`/`PBMVastAdsBuilder` that construct them) must be ported in one step.

## Files ported (Swift under PrebidMobile/Swift/PrebidMobileRendering/)

| Swift file | ObjC name | Replaces |
|------------|-----------|----------|
| `VastGlobals.swift` (`VastResourceType`, `VASTError` enums) | `PBMVastResourceType`, `PBMVASTError` | enums in `PBMVastGlobals.h` |
| `AdTypes/Video/Vast/VastResourceContainer.swift` (`@objc` protocol) | `PBMVastResourceContainerProtocol` | `PBMVastResourceContainerProtocol.h` |
| `AdTypes/Video/Vast/VastMediaFile.swift` | `PBMVastMediaFile` | `.h` + `.m` |
| `AdTypes/Video/Vast/VastIcon.swift` | `PBMVastIcon` | `.h` + `.m` |
| `AdTypes/Video/Vast/VastCreativeCompanionAdsCompanion.swift` | `PBMVastCreativeCompanionAdsCompanion` | `.h` + `.m` |
| `AdTypes/Video/Vast/VastCreativeNonLinearAdsNonLinear.swift` | `PBMVastCreativeNonLinearAdsNonLinear` | `.h` + `.m` |

Deleted (4 `.m`, 5 `.h`): `PBMVastMediaFile.{m,h}`, `PBMVastIcon.{m,h}`, `PBMVastCreativeCompanionAdsCompanion.{m,h}`,
`PBMVastCreativeNonLinearAdsNonLinear.{m,h}`, `PBMVastResourceContainerProtocol.h`.

**Kept:** `PBMVastGlobals.{h,m}`, reduced to the `NS_TYPED_ENUM` `PBMVastRequiredMode` string constants (playbook
S2.1-A; consumers `PBMVastCreativeCompanionAds.m` and a test using `PBMVastRequiredMode.all.rawValue`). Only the two
enums moved. `@objc(PBMVastResourceType)` keeps the ObjC constant names (`PBMVastResourceTypeStaticResource` etc.) that
`PBMVastParser.m`/`PBMCreativeModelCollectionMakerVAST.m` use unchanged. Classes and protocol are
`@_spi(PBMInternal) public`; the two enums are plain `public`.

ObjC consumers: `PBMVastParser.m` and `PBMCreativeModelCollectionMakerVAST.m` already imported `SwiftImport.h`; the
headers `PBMVastCreativeLinear.h`, `PBMVastCreativeCompanionAds.h`, `PBMVastCreativeNonLinearAds.h` (which used the
deleted headers) now `#import "SwiftImport.h"`.

## Behavior deviations

| # | Site | ObjC | Swift | Status |
|---|------|------|-------|--------|
| 1 | `clickTrackingURIs` | `NSMutableArray<NSString *>` | untyped `NSMutableArray` | **forced**: ObjC parser/response code appends in place, so a Swift `[String]` value would not bridge as mutable. Generic lost; ObjC callers unaffected. Revisit when the parser is ported |
| 2 | `copy` string properties | `copy` | Swift `String` value semantics | equivalent |
| 3 | `setDeliver:` | method | `@objc(setDeliver:)` | selector identical (S4.3-A). Property `deivery` (sic) kept |
| 4 | `identifier` with `NS_SWIFT_NAME(id)` (NonLinear) | ObjC `identifier`, Swift `id` | Swift `id` with `@objc(identifier)` | identical on both sides |
| 5 | init | designated `init` | explicit `@objc public override init()` | S4.3-A |
| 6 | default array / `VastTrackingEvents` members | created in `init` | property initializers | equivalent |

## New playbook gap candidates

- **S6.1-A (spike, decisive).** ObjC cannot subclass a Swift class, `open` or not: `PrebidMobile-Swift.h` stamps
  `objc_subclassing_restricted` on every class. A Swift base class can only move together with (or after) all its ObjC
  subclasses. Invalidates the S5.x-scope assumption about `PBMAdLoadManagerBase`/`PBMAdLoadManagerVAST`: Base and VAST
  must be ported in one step, and `PBMVastCreativeAbstract` moves with Linear/CompanionAds/NonLinearAds.
- **S6.1-B.** ObjC `NSMutableArray` properties mutated in place by surviving ObjC code stay `NSMutableArray` in Swift.
- **S6.1-C.** `@objc(PBMFoo) enum` keeps ObjC constant names `PBMFooCase`; Swift cases are lowerCamel (`.staticResource`,
  `.iFrameResource`). Existing Swift tests needed only the type rename.

## pbxproj delta

xcodeproj script output: removed 9 build files (4 `.m` Sources + 5 `.h` Headers), 9 file refs, added 6 Swift file refs
(+6 build files in `PrebidMobile` Sources). `plutil -lint`: OK. Script lived in /tmp, not committed.

## Orphan headers

None created. `PBMVastGlobals.h` still has `PBMVastGlobals.m`. Orphan count unchanged.

## Tests changed

Renamed `PBMVastMediaFile/PBMVastIcon/PBMVastCreativeCompanionAdsCompanion/PBMVastCreativeNonLinearAdsNonLinear/PBMVastResourceType`
to Swift names and switched to `@_spi(PBMInternal) @testable import PrebidMobile` in `PBMVastIconTest`,
`PBMVastParserTests`, `PBMVastCreativeNonLinearAdsTest`, `PBMVastLoaderTestSingleInline`, `PBMVastLoaderTestWrapperPlusInline`.
`PrebidMobileTest-Bridging-Header.h`: dropped 5 imports (CompanionAdsCompanion, NonLinearAdsNonLinear, Icon, MediaFile,
ResourceContainerProtocol). Still present: AbstractAd, CreativeAbstract, InlineAd, WrapperAd, AdRequestResponseVAST.

## Integrator notes

- `PrebidMobileTests` `build-for-testing` (generic simulator, Pods symlinked) succeeded; `buildPrebidMobilePackage.sh`
  (SPM) succeeded; swiftlint on the 6 new files: 0 violations. Tests not run.
- Any other wave-1 agent that ports a Swift base class with surviving ObjC subclasses will hit the same wall.
- An untracked `Pods` symlink exists in the worktree (not committed).
