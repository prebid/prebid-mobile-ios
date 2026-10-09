# Agent E notes (Phase 6 wave 2E): VastRequester

## Files
- Ported: `PBMVastRequester.m` + `PrivateHeaders/PBMVastRequester.h` -> `PrebidMobile/Swift/PrebidMobileRendering/AdTypes/Video/VastRequester.swift` (`@objc(PBMVastRequester) @_spi(PBMInternal) public class VastRequester`).
- Deleted: both ObjC files. `AdRequestCallback` typedef removed (rg confirmed no other user); replaced by nested `VastRequester.Completion`.
- Selector preserved: `+loadVastURL:connection:completion:`.
- Consumers: dropped `#import "PBMVastRequester.h"` from `PBMAdRequesterVAST.m` and `PBMVastAdsBuilder.m` (both already import SwiftImport). Test bridging header had no entry. Nothing subclasses the class.
- New test: `PrebidMobileTests/RenderingTests/Tests/VASTTests/VastRequesterTest.swift` (success, connection error, non-200, no data, nil URL) using `MockServerConnection`. No prior test existed. Not run (per instructions); compiles.

## Deviations (S5.2-C)
| Site | ObjC nil behaviour | Swift |
|---|---|---|
| `url` (nonnull annotation) | nil -> `PBMURLComponents` init failed -> completion(nil, error) | `String?` kept; same error path, no trap |
| `completion` error type | `NSError *` | `Error?` (bridges to NSError; same object) |
| non-200 error | `PBMError errorWithDescription:statusCode:` with arbitrary Int | `PBMError(message:code: Int)` (internal init; same domain/code/message) |
| `serverResponse` callback param | `_Nonnull` annotation | Swift protocol already non-optional |
| undefined / fileNotFound codes | enum | `PBMErrorCode.undefined` / `.fileNotFound` (900 / 401), unchanged |
| `connection` | nonnull | non-optional; ObjC nil would now trap at bridging (callers pass `self.serverConnection`, a nonnull property) |

No logging existed in the ObjC; none added.

## Gap candidates
- Comment in `PBMURLComponents.swift` says it is constructed from `PBMVastRequester.m`; now stale (the call is Swift). Left for integrator.
- The `AdRequestCallback` "single typedef for the whole app" TODO is resolved by removal.

## pbxproj deltas (xcodeproj gem, plutil OK)
- Removed PBMVastRequester.m (Sources) and .h (Headers) refs/build files.
- Added `VastRequester.swift` to PrebidMobile target (group AdTypes/Video); `VastRequesterTest.swift` to PrebidMobileTests (group VASTTests).

## Orphan headers
None.

## Integrator notes
- Xcode `build-for-testing` and `scripts/buildPrebidMobilePackage.sh` both succeed.
- `Pods` symlink in the worktree is untracked; not committed.
