---
name: resolve-dependencies
description: Resolve the PrebidMobile workspace's pinned Swift Package Manager dependencies
---

Run from the repo root:

```bash
./scripts/resolveDependencies.sh
```

The Xcode projects pin vendor SDK versions exactly. This command resolves them into
`.swiftpm-cache/` and writes the ignored workspace `Package.resolved`. The native
workspace contains no published Prebid packages. CocoaPods remains a customer
distribution channel; there is no development Podfile.
Open `PrebidMobile.xcworkspace` for native development.

The published consumer is `Example/PrebidDemo/PrebidDemoSPM.xcodeproj`. Open it
separately, or run `./scripts/buildPrebidSPM.sh`; that script uses its own
`.swiftpm-spm-demo-cache/` and `.build/spm-demo/`. Do not add the consumer project
to the native workspace, where its published adapter ranges would constrain native
vendor upgrades. `./scripts/verifyDependencyIsolation.sh` checks this separation.
CI runs `./scripts/verifySPM.sh` against candidate packages before publication;
its temporary workspace owns its pins, package cache, and DerivedData.

For an intentional vendor update, follow `docs/development-dependencies.md`; commit
the project requirements and the regenerated root `Package.resolved`.
