---
name: resolve-dependencies
description: Resolve the PrebidMobile workspace's pinned Swift Package Manager dependencies
---

Run from the repo root:

```bash
./scripts/resolveDependencies.sh
```

The Xcode projects pin vendor SDK versions exactly. This command resolves them into
`.swiftpm-cache/` and writes the ignored workspace `Package.resolved`. The published
Prebid demo packages follow their existing version/branch requirements, so their
resolution is not frozen by a committed workspace lockfile. CocoaPods remains a
customer distribution channel; there is no development Podfile.
Open `PrebidMobile.xcworkspace` for development.

For an intentional vendor update, follow `docs/development-dependencies.md`; commit
the project requirements and the regenerated root `Package.resolved`.
