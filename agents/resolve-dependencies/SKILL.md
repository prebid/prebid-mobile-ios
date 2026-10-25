---
name: resolve-dependencies
description: Resolve the PrebidMobile workspace's pinned Swift Package Manager dependencies
---

Run from the repo root:

```bash
./scripts/resolveDependencies.sh
```

This resolves the committed workspace `Package.resolved` into `.swiftpm-cache/`, shared
by archive, unit-test, demo, and internal-app builds. It does not update versions.
CocoaPods is only a customer distribution channel; there is no development Podfile.
Open `PrebidMobile.xcworkspace` for development.

For an intentional dependency update, follow `docs/development-dependencies.md` and
commit both the exact version requirements and regenerated lockfiles.
