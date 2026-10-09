# Phase 6 wave 1C notes: AdLoadManager protocols

## Ported
- `PBMAdLoadManagerProtocol.h` -> `Swift/PrebidMobileRendering/AdTypes/AdView/AdLoadManagerProtocol.swift`
  (`@objc(PBMAdLoadManagerProtocol) @_spi(PBMInternal) public protocol`, inherits `NSObjectProtocol, TransactionDelegate`;
  `adLoadManagerDelegate` weak; `init` carries `@objc(initWithBid:connection:adConfiguration:)`).
- `PBMAdLoadManagerDelegate.h` -> `AdLoadManagerDelegate.swift` (selectors `loadManager:didLoadTransaction:` and
  `loadManager:failedToLoadTransaction:error:` pinned with explicit `@objc(...)`).

## Deleted
- `PrivateHeaders/PBMAdLoadManagerProtocol.h`, `PrivateHeaders/PBMAdLoadManagerDelegate.h`
- `PrebidMobileTests/RenderingTests/TestExtensions/PBMAdLoadManager+pbmTestExtension.h` (dead: `rg currentTransaction` showed
  no reader outside Base.m's own private extension; its bridging-header import was already a duplicate pair).
- Bridging header (`PrebidMobileTests/PrebidMobileTest-Bridging-Header.h`): removed the Protocol/Delegate imports and both
  `PBMAdLoadManager+PBMTestExtension.h` imports (note the case differs from the real filename; macOS is case-insensitive).

## Consumer edits
- `PBMAdLoadManagerBase.h`: dropped the two header imports; it already imports `SwiftImport.h`, which supplies the protocols.
- `PBMAdLoadManagerBase.m`: dropped unused `PBMAdRequesterVAST.h` / `PBMCreativeModelCollectionMakerVAST.h` (verified: no symbol of either used).
- `PBMAdLoadManagerVAST.*`, `PBMVastTransactionFactory.m`, `PBMAdRequesterVAST.h`: no change needed (they reach the Swift header through
  `SwiftImport.h` transitively; compiled clean).
- `PBMVASTFailToLoadTest.swift`: conforms to `AdLoadManagerDelegate`, now needs `@_spi(PBMInternal) @testable import PrebidMobile`.
  Mock/tests elsewhere unchanged (they use `PBMAdLoadManagerVAST`, which still compiles; `AdViewManagerTest` uses `PBMAdLoadManagerBase` only).

## Deviations / findings
- Mismatch to record: `PBMTransactionDelegate.transactionFailedToLoad:error:` takes a NON-nullable transaction, while
  `loadManager:failedToLoadTransaction:error:` takes a `nullable` one (Base calls it with `nil` from `requestCompletedFailure:`). Kept
  faithfully: Swift signature is `Transaction?`. `PBMVastTransactionFactory.m` implements it with a non-nullable param (ObjC, only a nullability warning class, none emitted).
- `@_spi(PBMInternal) public protocol` with an `init` requirement compiled fine for the ObjC subclass chain (Base still implements it in ObjC).
- Because the Swift protocols have an `init` requirement, a future Swift `AdLoadManagerBase` must be `required init` for non-final classes.

## Playbook gap candidates
- Swift test files conforming to a `@_spi` protocol need the `@_spi(PBMInternal) @testable import PrebidMobile` line (like other tests).
- A symlinked `Pods` in the worktree shows up as untracked (`.gitignore` has `Pods/`, which doesn't match a symlink); do not commit it.

## pbxproj deltas (via xcodeproj gem, `plutil -lint` OK)
- -2 PBXFileReference + -2 header build files (Protocol.h, Delegate.h), -1 test-extension header file ref (+ group entry).
- +2 Swift file refs/build files in the PrebidMobile target `AdView` group (next to `TransactionDelegate.swift`).

## Orphan headers
- None created. `PBMAdLoadManagerBase.h`/`VAST.h` remain (ported in a later wave).

## Builds
- `xcodebuild ... -scheme PrebidMobileTests ... build-for-testing` (derivedData /tmp/phase6-dd-C): TEST BUILD SUCCEEDED.
- `scripts/buildPrebidMobilePackage.sh` (SPM `__PrebidMobileInternal`): succeeded.
- swiftlint on the new files: 0 violations. Tests not run.

## Integrator must know
- `Pods` symlink exists untracked in this worktree; it was not committed.
- Base.h has a leftover double blank line where imports were removed (cosmetic).
