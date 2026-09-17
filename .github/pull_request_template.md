<!--
The PR title becomes a release-note line. Make it clear and user-facing,
e.g. "Fix: outstream video keeps playing when scrolled off-screen".
-->

## Description

<!-- What does this change do, and why? Link the related issue. -->

## Checklist

- [ ] Tests added or updated for behavior changes
- [ ] New code is in Swift (`PrebidMobile/Swift/`), not Objective-C
- [ ] No new public API — or the API baseline (`scripts/guards/baselines/`) is updated in this PR
- [ ] File additions/moves are reflected in all build systems they affect (xcodeproj, `Package.swift`, podspecs)
- [ ] OpenRTB request/response changes cite the relevant spec section
- [ ] `./scripts/guards/run-guards.sh` passes locally (or rely on the CI guards job)
