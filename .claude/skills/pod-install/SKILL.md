---
name: pod-install
description: Run pod install --repo-update for the PrebidMobile workspace
---

Run CocoaPods install for this project from the repo root:

```
pod install --repo-update
```

This installs all pods for the workspace (`PrebidMobile.xcworkspace`) covering all targets: core SDK, GAM event handlers, AdMob adapters, MAX adapters, demo apps, and internal test app.

After completion, remind the user to open `PrebidMobile.xcworkspace` (not the `.xcodeproj`) if they haven't already.
