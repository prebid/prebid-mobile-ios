# Contributing to Prebid Mobile iOS

Thank you for contributing! This document covers how to build, test, and submit changes.

## Repository layout

| Path | What it is |
|---|---|
| `PrebidMobile/Swift/` | Core SDK — Swift sources. **New code goes here.** |
| `PrebidMobile/Objc/` | Core SDK — legacy Objective-C sources (being migrated to Swift; new files only in rare, explicitly-granted cases — see `docs/guards/README.md`) |
| `PrebidMobile/Objc/PrivateHeaders/` | Internal Objective-C headers, not part of the public API |
| `EventHandlers/` | GAM event handlers, AdMob and MAX mediation adapters (separate products) |
| `Example/PrebidDemo/` | Demo apps (Swift and Objective-C) + integration/UI tests |
| `InternalTestApp/` | Internal test application |
| `scripts/` | Build, test, and quality scripts used locally and in CI |

## Building

The project supports three build systems, which must stay consistent with each other:

- **Xcode workspace**: open `PrebidMobile.xcworkspace` (run `pod install` first)
- **Swift Package Manager**: root `Package.swift`
- **CocoaPods**: `PrebidMobile.podspec` and the three adapter podspecs

If you add, move, or delete a source file — or change what is public — check all three.

Full build check: `./scripts/buildPrebidMobile.sh`

## Testing

- Unit tests (quick PR set): `./scripts/testPrebidMobile.sh --latest --quick`
- Unit tests (full): `./scripts/testPrebidMobile.sh --latest`
- Adapter tests: `./scripts/testPrebidMobileAdapters.sh`
- Demo integration tests: `./scripts/testPrebidDemo.sh -l` (add `-ui` for UI tests)

CI runs the quick unit-test plan on every PR. The full suite and demo tests run when the
PR carries the `run-full-tests` label or the branch name contains `bump-to`.

## Quality guards

Optionally, run the guards automatically before every push (one-time, per clone):

```bash
git config core.hooksPath .githooks
```

The hook runs the same checks CI runs — failing locally just fails faster; bypass a
genuine emergency with `git push --no-verify` (CI still catches it).

`./scripts/guards/run-guards.sh` runs fast, deterministic structural checks (architecture
rules such as adapter isolation and public-API baselining). They run on every PR in CI and
take seconds locally. See [`docs/guards/README.md`](docs/guards/README.md) for what each
guard enforces and what to do when one fails.

## Pull requests

- **PR titles become release notes.** Release notes are generated from PR titles — write a
  clear, user-facing title (e.g. `Fix: outstream video keeps playing when scrolled off-screen`).
- Include tests for behavior changes.
- Changes to the public API must update the API baseline (`scripts/guards/baselines/`) in the
  same PR — this makes API changes an explicit, reviewable decision.
- Changes to OpenRTB request building should cite the relevant spec section in the PR
  description.
- For significant features, open an "intent to implement" issue first.

## AI-assisted development (optional)

The repository ships configuration for AI coding assistants (`CLAUDE.md`, `.claude/`).
Using an AI assistant is entirely optional — nothing in the contribution process requires
one. CI enforces quality through the deterministic guards above, which apply equally to
everyone.
