# Phase 6 wave 2D notes: VAST ad classes

Branch `worktree-agent-a607bbe846e267227`. Input for the integrator, not a PR doc.

## Files

Ported (new, `PrebidMobile/Swift/PrebidMobileRendering/AdTypes/`):

| Swift file | ObjC name | Replaces |
|------------|-----------|----------|
| `Video/Vast/VastAbstractAd.swift` | `PBMVastAbstractAd` | `.h` + `.m` |
| `Video/Vast/VastInlineAd.swift` | `PBMVastInlineAd` | `.h` + `.m` |
| `Video/Vast/VastWrapperAd.swift` | `PBMVastWrapperAd` | `.h` + `.m` |
| `AdView/AdRequestResponseVAST.swift` | `PBMAdRequestResponseVAST` | `.h` + `.m` |

All four are `@objc(PBMFoo) @_spi(PBMInternal) public class`, non-final (Inline/Wrapper subclass AbstractAd), with an
explicit `@objc public override init()` (S4.3-A) and `@objc public` properties.

Deleted (4 `.m`, 4 `.h`): `PBMVastAbstractAd`, `PBMVastInlineAd`, `PBMVastWrapperAd`, `PBMAdRequestResponseVAST`.

Measured first: only these four classes subclass each other (AbstractAd -> Inline/Wrapper); no other ObjC class
subclasses any of them. Consumers (`PBMVastParser.m`, `PBMVastResponse.m`, `PBMVastAdsBuilder.m`,
`PBMCreativeModelCollectionMakerVAST.m`, `PBMAdRequesterVAST.m`, `PBMAdLoadManagerVAST.m`) already imported
`SwiftImport.h`; I only dropped the deleted-header imports. No ObjC logic changed. Headers `PBMVastParser.h`,
`PBMVastResponse.h`, `PBMVastAdsBuilder.h`, `PBMCreativeModelCollectionMakerVAST.h`, `PBMAdLoadManagerVAST.h`,
`PBMVastCreativeAbstract.h` keep their `@class PBMVastAbstractAd;` style forward declarations; these resolve
against the generated header.

## Behavior deviations

| # | Site | ObjC | Swift | Status |
|---|------|------|-------|--------|
| 1 | `VastAbstractAd.ownerResponse` | `weak PBMVastResponse *` | `weak var ownerResponse: AnyObject?` | **forced**: `PBMVastResponse` is ObjC and invisible to Swift. Only stored/read back by ObjC (`PBMVastParser.m`, `PBMVastAdsBuilder.m`). ObjC sees `id`; code using `PBMVastResponse *` compiles unchanged. Retype when `PBMVastResponse` is ported |
| 2 | `VastWrapperAd.vastResponse` | `strong PBMVastResponse *` | `var vastResponse: AnyObject?` | forced, same reason. Swift tests assign `PBMVastResponse` values, which upcast implicitly |
| 3 | `impressionURIs`, `errorURIs` | `NSMutableArray<NSString *>` | untyped `NSMutableArray` | forced (S6.1-B): ObjC parser/response append in place |
| 4 | `creatives` | `NSMutableArray<PBMVastCreativeAbstract *>` | untyped `NSMutableArray` | forced: element type is ObjC; mutated in place by ObjC |
| 5 | `identifier`, `adSystem`, `adSystemVersion` | `nonnull NSString`, `nil` until assigned | `String`, default `""` | equivalent for reachable paths (the parser assigns via `parseString:`, which yields `@""`); a never-assigned ad now reports `""` |
| 6 | `sequence`, `depth` | `NSInteger` | `Int` | equivalent |
| 7 | `VastInlineAd.verificationParameters` | nonnull, set in `init` | non-optional `VideoVerificationParameters`, property initializer | equivalent |
| 8 | `AdRequestResponseVAST.ads` | `atomic NSArray<PBMVastAbstractAd *> *` | `[VastAbstractAd]?` | atomicity dropped: written once by `PBMAdRequesterVAST.m` before the handoff, read afterwards; no concurrent access found. ObjC still sees `NSArray<PBMVastAbstractAd *> *` |

## Gap candidates

- **S6.x-D-A (`AnyObject?` back-reference for a not-yet-ported ObjC type).** A Swift class whose only ties to an ObjC
  type are stored/handed-through properties can type them `AnyObject?` (weak where ObjC was weak). ObjC callers see `id`
  and compile unchanged. Re-type when the referenced class is ported.
- **S6.x-D-B (rename pitfall).** A blanket regex rename `PBMFoo` -> `Foo` over all `*.swift` files also hits the
  `@objc(PBMFoo)` bridge name in newly written Swift files, turning it into `@objc(Foo)`; ObjC then fails with
  "unknown receiver 'PBMFoo'". Exclude the new files or re-check `@objc(` after renaming.
- **S6.x-D-C (import-removal regex).** `^#import "X.h"\s*\n` style patterns with `\s*` swallow the following blank
  line; anchor with `[ \t]*`.

## pbxproj deltas

xcodeproj gem recipe (script `/tmp/update_project_D.rb`, not committed): -8 build files (4 `.m` in Sources, 4 `.h` in
Headers), -8 file refs; +4 Swift refs and +4 Sources build files in the `PrebidMobile` target (3 in the
`Video/Vast` group next to `VastTrackingEvents.swift`, 1 in the `AdView` group). `plutil -lint`: OK.

## Tests changed

Renamed `PBMVastAbstractAd/InlineAd/WrapperAd` -> `VastAbstractAd/InlineAd/WrapperAd` and `PBMAdRequestResponseVAST`
-> `AdRequestResponseVAST` in 14 Swift test files; their `import PrebidMobile` became
`@_spi(PBMInternal) @testable import PrebidMobile`. Test class names are kept.
`PrebidMobileTest-Bridging-Header.h`: dropped 4 imports (AdRequestResponseVAST, AbstractAd, InlineAd, WrapperAd).
Tests were not run.

## Orphan headers

None created or removed; the orphan-header count is unchanged.

## Builds

- `xcodebuild -workspace PrebidMobile.xcworkspace -scheme PrebidMobileTests -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/phase6-dd-D build-for-testing`: TEST BUILD SUCCEEDED.
- `scripts/buildPrebidMobilePackage.sh` (SPM): succeeded.
- `swiftlint --config .swiftlint.yml` on the four new files: 0 violations.

## Integrator notes

- Merge hot spots: `project.pbxproj` (re-run the recipe if it conflicts), `PrebidMobileTest-Bridging-Header.h`, and the
  `#import` removals in `PBMVastParser.m`, `PBMVastResponse.m`, `PBMVastAdsBuilder.m`,
  `PBMCreativeModelCollectionMakerVAST.m`, `PBMAdRequesterVAST.m`.
- When `PBMVastResponse` is ported, retype `ownerResponse` and `vastResponse`.
- An untracked `Pods` symlink exists in the worktree; not committed.
