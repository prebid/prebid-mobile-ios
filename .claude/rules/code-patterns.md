# Code patterns

## Swift/ObjC interop

- The core is mid-migration: `PrebidMobile/Swift/` is the destination, `PrebidMobile/Objc/`
  the legacy source. Migrations move logic to Swift and leave no new ObjC behind.
- Swift types exposed to ObjC use `@objc(PBMName)` renames (e.g. `@objc(PBMInterstitialAd)
  public class InterstitialAd`). Keep the `PBM` prefix on the ObjC side only.
- `@_spi(PBMInternal)` marks internal-but-cross-module API (see `SwiftMigrationHelper.swift`).
  SPI is never for adapters or publishers — the `adapter-isolation` guard enforces this.
- Internal ObjC headers belong in `PrebidMobile/Objc/PrivateHeaders/` and must be listed
  nowhere public (podspec keeps them private via `private_header_files`).

## API design

- Default to `internal`. `public`/`open` is a commitment tracked by the API baseline guard;
  `open` additionally invites subclassing — use it deliberately.
- Publisher-facing types follow existing naming: ad units are `<Format>AdUnit`, delegates
  are protocols named `*Delegate`, mediation constants are `PBMMediation*` strings.
- New extension points follow the plugin-renderer pattern
  (`PrebidMobileRendering/PluginRenderer/`): a public protocol + a registry, not exposed
  internals.

## Threading

- Publisher-facing delegate callbacks are delivered on the main queue:

  ```swift
  DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.delegate?.adDidLoad(self)
  }
  ```

- UI entry points guard with `assert(Thread.isMainThread, ...)` (see existing usages).
- Shared mutable registries use a concurrent queue with `.barrier` writes — the canonical
  example is `PrebidMobilePluginRegister`.
- Background work (bid requests) stays off main; only the callback hop is main-queue.

## Comments and style

- Match surrounding style; the repo has no enforced formatter (SwiftLint config exists but
  is dormant — do not start enforcing it as a side effect of another change).
- Public declarations carry doc comments (Jazzy publishes them); internal code only needs
  comments for non-obvious constraints.
