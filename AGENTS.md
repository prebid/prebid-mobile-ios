# AGENTS.md

Canonical instructions for AI coding agents working in this repository. Codex, Cursor, and Copilot
read this file directly; Claude Code reaches it via the `@AGENTS.md` import in `CLAUDE.md`.
Human contributors: see [CONTRIBUTING.md](CONTRIBUTING.md); nothing in the contribution process
requires an AI tool.

The philosophy here: rules are machine-enforced wherever possible. Most "musts" below point
at a structural guard (`./scripts/guards/run-guards.sh`, enforced in CI) — follow the rule
because the build fails otherwise, and when you find a recurring violation class that isn't
guarded yet, propose a new guard rather than relying on review vigilance.

## Overview

Prebid Mobile iOS SDK — an open-source header bidding SDK that integrates with Prebid Server to increase ad yield. Version 3.3.0, supports iOS 13+, Swift 5.0+. Distributed via CocoaPods, SPM, and Carthage.

## Agent runbooks (`agents/`)

Detailed procedures live in `agents/` as plain markdown, readable by any agent. Read the relevant
file before acting rather than improvising the commands.

Claude Code additionally loads these as Agent Skills through the committed `.claude/skills`
symlink, which points at `agents/`. `agents/` remains the single source of truth — do not duplicate
files under `.claude/`.

| Task | Read |
|------|------|
| Build the 4 XCFrameworks | `agents/build-sdk/SKILL.md` |
| Run tests, a single test class, or fix post-migration build errors | `agents/xcodebuild/SKILL.md` |
| Review a PR on this repo | `agents/review/SKILL.md` |
| Run SwiftLint | `agents/lint/SKILL.md` |
| CocoaPods install | `agents/pod-install/SKILL.md` |
| Author a new structural guard | `agents/guard/SKILL.md` |
| Review a branch/PR with this repo's checklist, or audit the full tree | `agents/sdk-review/SKILL.md` |
| Audit ORTB models/tests against the OpenRTB spec (read-only) | `agents/verify-spec/SKILL.md` |
| Generic iOS/Swift background (not repo-specific; playbook wins on conflicts) | `agents/ios-development/SKILL.md` |
| Generic ObjC → Swift / XCTest migration background (playbook wins on conflicts) | `agents/migration-patterns/SKILL.md` |

Claude Code additionally loads `.claude/`: the rules linked under Deeper guidance, four
skills (`/guard` authors a new structural guard, `/sdk-review` runs this repo's review
checklist, `/verify-spec` audits ORTB models against the OpenRTB spec, `/benchmark`
measures SDK size and hot-path timing), and the `qc-validator` subagent that checks
finished work against the quality gates. All of it is plain markdown under
`.claude/skills/` and `.claude/agents/` — other agents can read and follow the same
procedures directly.

## Repo map

| Path | Role |
|---|---|
| `PrebidMobile/Swift/` | Core SDK, Swift. **All new core code goes here.** |
| `PrebidMobile/Objc/` | Core SDK, legacy ObjC — being migrated to Swift. New files only via explicit allowlist grant (guarded). |
| `PrebidMobile/Objc/PrivateHeaders/` | Internal ObjC headers (~150). Not public API. |
| `PrebidMobile/Swift/PrebidMobileRendering/ORTB/` | OpenRTB request/response models — **spec-grounding gate applies** |
| `PrebidMobile/Swift/PrebidMobileRendering/PluginRenderer/` | Plugin renderer extension point |
| `EventHandlers/` | GAM event handlers + AdMob/MAX mediation adapters. Public-API-only consumers of the core (guarded). |
| `Example/PrebidDemo/` | Demo apps + `PrebidDemoTests` (integration) + `PrebidDemoSwiftUITests` (UI) |
| `InternalTestApp/` | Internal test app |
| `scripts/` | Build/test/guard scripts (CI entry points) |
| `.github/workflows/SPM.yml` | Release-tag sync into split repos `prebid-mobile-ios-sdk` / `prebid-mobile-ios-adapters` |

## Three build systems, one truth

Every file addition, move, deletion, or visibility change must be consistent across:
1. **Xcode**: `PrebidMobile.xcodeproj` (+ `EventHandlers/EventHandlers.xcodeproj`)
2. **SPM**: root `Package.swift` (also `PrebidMobile/Package.swift` and
   `EventHandlers/Package.swift`, which become the split repos' root manifests at release)
3. **CocoaPods**: `PrebidMobile.podspec` + three adapter podspecs

The public API is likewise declared in three places that must not drift: Swift
`public`/`open` modifiers, the podspec's `private_header_files`, and `.jazzy.yaml` excludes.
The `public-api-baseline` guard snapshots this surface.

## Hard rules (each is guarded — the build fails, don't argue with it)

1. **New core code is Swift.** No new `.h/.m/.mm` under `PrebidMobile/Objc/`
   (guard: `swift-migration-direction`). Rare, genuinely unavoidable exceptions
   (e.g. a bridge shim Swift cannot express) are granted explicitly in
   `scripts/guards/allowlists/swift-migration-direction.json` with its `reason`,
   in the same PR — never silently.
2. **Adapters use only public API.** Nothing in `EventHandlers/` may `import
   __PrebidMobileInternal`, use `@_spi`, include `PrivateHeaders`, or reference non-public
   `PBM*` symbols (guard: `adapter-isolation`).
3. **API-surface changes are explicit.** Any new/removed/renamed `public`/`open` or
   `@_spi` declaration, `PrivateHeaders` interface, or `Package.swift` product export
   requires regenerating `scripts/guards/baselines/public-api.json` in the same change
   (`./scripts/guards/run-guards.sh --update-api-baseline`) and calling it out — the
   baseline is namespaced (`swift` / `swift-spi` / `objc-internal` / `spm-product`) so
   the diff shows which surface moved (guard: `public-api-baseline`).
4. **Shipped code lives under synced paths.** Core code outside `PrebidMobile/`,
   adapter code outside `EventHandlers/PrebidMobile{AdMob,MAX,GAM}*` never reaches the
   split release repos — check `.github/workflows/SPM.yml`'s rsync list manually when
   adding top-level paths (no guard for this currently).
5. **Delegate callbacks to publishers are delivered on the main queue** — wrap in
   `DispatchQueue.main.async` (guard: `ast-rule-ratchet` — the finding count is
   baselined and may not grow; same for `force-unwrap` and `weak-delegate` sites).

## Test-integrity policy (zero tolerance)

- Never delete, weaken, or skip a failing test to make a run pass. Fix the code, or report
  the failure as a blocker with the output.
- `PrebidMobileTests/PrebidMobilePRTests.xctestplan` is a *skip-list* for the quick PR run.
  Its skipped-tests list may only shrink. Never add entries to make CI pass
  (guard: `skiplist-ratchet`).
- MockServer (`PrebidMobileTests/RenderingTests/Mocks/MockServer/`), swizzling helpers, and
  `UtilitiesForTesting` are shared infrastructure — after touching them, run the full
  `PrebidMobileTests` suite, not just the quick plan.
- Never report success you didn't verify. If the environment can't run a check (no macOS,
  no simulator), say SKIPPED and why — a skipped check is honest; a fabricated pass is not.

## Spec-grounding gate (OpenRTB)

Changes to `PrebidMobileRendering/ORTB/` models or bid-request building must cite the
authoritative source **before** the code changes:
- [IAB OpenRTB 2.x spec](https://github.com/InteractiveAdvertisingBureau/openrtb2.x) — cite
  the section, link a commit-pinned permalink in the PR description and in a code comment.
- Prebid Server's request semantics where OpenRTB is silent (prebid extensions:
  `imp.ext.prebid`, etc.).

Other SDKs (prebid-mobile-android, prebid.js) are cross-checks, **not** the authority.
Uncited protocol changes should be rejected in review.

## Environment: what can run where

- **Any OS (including Linux CI)**: guards (`python3` + [ast-grep](https://ast-grep.github.io)
  on PATH — a missing tool makes that guard exit 2 = SKIPPED, which is *not* a pass) and
  SwiftLint (`brew install swiftlint`; the script warns when your version differs from CI's pin).
- **macOS only**: build and every test rung — Xcode + CocoaPods.

When the environment can't run a check, report it as SKIPPED with the reason — never as
passed (see the test-integrity policy below).

## Commands

### Guards

```bash
# Structural guards (seconds — run before every commit)
./scripts/guards/run-guards.sh

# …or have git run them automatically (opt-in, once per clone):
git config core.hooksPath .githooks

# Style lint — fails on violations in the lines this branch adds (docs/lint/README.md)
./scripts/lint/run-swiftlint.sh
```

When a guard fails legitimately, its failure message names the fix: ratchet wins and
intentional surface changes re-record a baseline (`./scripts/guards/run-guards.sh
--update-<name>-baseline`; the script header lists them all), and grandfathered exceptions
live in `scripts/guards/allowlists/*.json` — shrink-only, one entry per exception with its
`reason`. Commit baseline/allowlist diffs in the same PR and call them out. The full
catalog of guards is in `docs/guards/README.md`.

### Build

```bash
# Build all XCFrameworks (PrebidMobile, GAM, AdMob, MAX) into generated/output/
./scripts/buildPrebidMobile.sh

# Build and publish the SPM release
./scripts/buildPrebidSPM.sh
./scripts/publishSPM.sh
```

Requires CocoaPods installed (`pod` on PATH — GHA `macos-15` ships with it pre-installed). Build output goes to `generated/output/` as `XC<name>.xcframework` (e.g. `XCPrebidMobile.xcframework`). Logs go to `generated/log/prebid_mobile_build.log`. Build uses `Lib-`-prefixed scheme names (`Lib-PrebidMobile`, etc.) to avoid colliding with auto-generated SPM schemes.

### Tests

```bash
# Run PR subset (694 tests) — used on PRs in CI
./scripts/testPrebidMobile.sh --latest --quick

# Run full suite (1111 tests) — used on bump-to branches / run-full-tests label
./scripts/testPrebidMobile.sh --latest

# Run adapter tests (GAM, AdMob, MAX)
./scripts/testPrebidMobileAdapters.sh

# Demo integration tests; add -ui for UI tests
./scripts/testPrebidDemo.sh -l
./scripts/testPrebidDemo.sh -ui -l
```

Flags: `--latest` skips the legacy iOS 13 sanity test (always use locally); `--quick` switches the test plan from `PrebidMobileTests` (full) to `PrebidMobilePRTests` (PR subset). The script creates the `iPhone-16-Pro-PrebidMobile` simulator, runs `build-for-testing` then `test-without-building` with `-retry-tests-on-failure`, then deletes the simulator. Any pre-existing simulator with that name is deleted first.

Test plans: `PrebidMobileTests/PrebidMobileTests.xctestplan` (full, 1111 tests), `PrebidMobileTests/PrebidMobilePRTests.xctestplan` (PR subset, 694 tests).

**When adding new tests:** both plans select by *exclusion*, so a new test class runs on every PR without any registration step. `PrebidMobilePRTests.xctestplan` trims the suite via a `skippedTests` list — check that a new class isn't (prefix-)matched there. The `skiplist-ratchet` guard fails on any new skip entry (the list may only shrink — see the test-integrity policy above); slow/timing-sensitive tests still belong in the full plan and still must pass.

To run a single test class:
```bash
# Step 1 — build once
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
  build-for-testing

# Step 2 — run (repeat as needed without rebuilding)
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
  -only-testing PrebidMobileTests/TargetingTests \
  test-without-building
```

See `agents/xcodebuild/SKILL.md` for a guided single-class run, and for the post-migration
build-error checklist.

### Setup

```bash
pod install --repo-update
```

Open `PrebidMobile.xcworkspace` (not `.xcodeproj`) for development.

## Architecture

### Workspace Structure

The workspace (`PrebidMobile.xcworkspace`) contains three projects:
- `PrebidMobile.xcodeproj` — core SDK + unit tests
- `EventHandlers/EventHandlers.xcodeproj` — ad network adapters
- `Example/PrebidDemo/PrebidDemo.xcodeproj` — demo apps

### Core SDK (`PrebidMobile/`)

Split between Swift and Objective-C layers (mid-migration — see the hard rules above):

**`PrebidMobile/Swift/`** — Public-facing Swift API + migrated rendering code:
- `Objc/Prebid.swift`, `Objc/Targeting.swift` — SDK configuration singleton and user targeting
- `Swift/AdUnits/` — `BannerAdUnit`, `InterstitialAdUnit`, `RewardedVideoAdUnit`, `InstreamVideoAdUnit`, `MultiformatAdUnit`
- `Swift/AdUnits/Native/` — Native ad unit types
- `Swift/ConfigurationAndTargeting/` — `AdUnitConfig`, targeting parameters
- `Swift/CacheManagement/` — bid caching layer
- `Swift/Host.swift` — Prebid Server endpoint configuration
- `Swift/Global.swift` — shared error types
- `Swift/PrebidMobileRendering/ORTB/` — OpenRTB request/response models (spec-grounding gate applies)
- `Swift/PrebidMobileRendering/PluginRenderer/` — plugin renderer extension point

**`PrebidMobile/Objc/`** — Internal Objective-C rendering engine (legacy, shrinking):
- `PrebidMobileRendering/Networking/` — HTTP layer, URL building, impression tracking
- `PrebidMobileRendering/AdTypes/` — HTML creative rendering, MRAID, VAST/video
- `PrebidMobileRendering/3dPartyWrappers/OpenMeasurement/` — OMSDK integration
- `PrebidMobileRendering/Prebid/` — `PrebidAdUnit`, `PrebidRequest`, `BidInfo`

The `PrebidMobile_SPM` compile flag is set when building via SPM (not CocoaPods).

### Event Handlers / Adapters (`EventHandlers/`)

Thin wrappers that bridge Prebid bids into third-party ad SDKs:
- `PrebidMobileGAMEventHandlers/` — Google Ad Manager (GAM/DFP) banner, interstitial, rewarded
- `PrebidMobileAdMobAdapters/` — Google AdMob mediation adapters
- `PrebidMobileMAXAdapters/` — AppLovin MAX adapters

Each adapter has its own test target (`*Tests/`).

### SPM vs CocoaPods layout

**SPM** (Package.swift at root): `PrebidMobile` product = `PrebidMobile` target (Swift sources) + `__PrebidMobileInternal` target (ObjC sources). The `__PrebidMobileInternal` target depends on the bundled `Frameworks/OMSDK_Prebidorg.xcframework`.

**CocoaPods** (PrebidMobile.podspec): Single `core` subspec pulls all `PrebidMobile/**/*.{h,m,swift}` except Package.swift.

### Build schemes

Framework build uses `Lib-PrebidMobile`, `Lib-PrebidMobileGAMEventHandlers`, `Lib-PrebidMobileAdMobAdapters`, `Lib-PrebidMobileMAXAdapters` schemes (prefixed `Lib-` to avoid collision with auto-generated SPM schemes).

### CI

GitHub Actions (Xcode 16.4.0, macOS 15):
- Guards run on every PR (`guards.yml`, ubuntu), as does SwiftLint over the lines the PR adds (`swiftlint.yml`, ubuntu — blocking)
- Build + quick unit tests (`--latest --quick`) run on every non-draft PR (`PR_checks.yml`, macos)
- Full tests + demo/UI suites run when the PR has the `run-full-tests` label or the branch name contains `bump-to`

## Decision trees

**Adding a public API** → is it necessary, or can it stay `internal`? If public: implement in
`PrebidMobile/Swift/`, add tests, regenerate the API baseline, mention the API change in the
PR title/description (PR titles become release notes).

**Touching ORTB / request building** → find the spec section first (permalink), write/adjust
the test asserting the wire format, then change the model. Cite the permalink in a comment.

**Adding a file** → decide the layer (core Swift / adapter / tests), add to the xcodeproj
AND check `Package.swift` sources and podspec globs cover it (core: `PrebidMobile/**` globs
usually cover automatically — verify for new top-level directories, and check they are
covered by the release sync in `.github/workflows/SPM.yml`).

**Fixing a bug** → write the failing test first (`PrebidMobileTests`), fix, run guards +
quick plan; if the fix touches shared test infra or rendering, run the full plan.

**Adapter feature** → public API only. If the core lacks the hook you need, add the public
hook to the core (baseline update) — never reach into internals.

## Commits and PRs

Commit subjects use release-note-quality language and reference issues (`Fix #1296: …`).
The PR title becomes a release-note line; the PR template's checklist mirrors the guards.

## Known traps

- `scripts/testPrebidMobile.sh` installs pods and creates/deletes a named simulator; it
  needs macOS + Xcode.
- SwiftLint is **blocking but diff-scoped** — it fails on violations in the lines a branch
  adds, and never reports the lines it didn't touch. A whole-tree run shows ~13k
  pre-existing violations; do not "fix" them as a drive-by, and don't run `swiftlint --fix`
  over a legacy file to clear one finding — it rewrites the whole file. It replaces no
  guard (`docs/lint/README.md` says which rules it deliberately leaves to guards).
- `PR_checks.yml`'s `unit-test-adapters` job computes `IS_RELEASE_PR` with inverted-looking
  logic — confirm intent with maintainers before touching it.
- `.jazzy.yaml` excludes drift (deleted files stay listed) — the baseline guard reports this
  as an advisory.
- Some `PBM*` names are *deliberately public* (e.g. `PBMMediation*` constants); prefix alone
  doesn't mean internal.
- `@objcMembers` classes are visible to the ObjC runtime via reflection
  (`NSClassFromString` etc.) regardless of Swift access level. No guard can track this —
  don't treat `internal` on such a class as proof the type is unreachable.

## Deeper guidance

- `.claude/rules/code-patterns.md` — Swift/ObjC interop, threading idioms, API design
- `.claude/rules/testing-patterns.md` — test layout, MockServer, xctestplan policy
- `.claude/rules/quality-gates.md` — the gate ladder and completion standards
- `.claude/rules/session-completion.md` — end-of-session checklist
- `docs/guards/README.md` — every guard, its rationale, and how to add one
- `docs/lint/README.md` — SwiftLint: why it is diff-scoped, and why it is not a guard

## ObjC → Swift migration

Migration docs live in `docs/migration/`. Keep them current throughout every working session:

- **`docs/migration/playbook.md`** — per-class porting guide and gap decisions. Update when a new gap is discovered or a rule changes.
- **`docs/migration/pr-phase-<phases>.md`** — one file per *pull request*, not per phase (phases 0–2 shipped together as `pr-phase-012.md`). PR-level summary of what was done, with a test-plan checklist. Update it at the end of each session: add an `S<phase>.<step>` entry for completed work, tick test-plan checkboxes, and note any open items for the reviewer. Do not leave superseded drafts behind — the merged PR doc is the record.

When starting work on a migration phase, read the playbook and the most recent PR doc first to pick up prior context.
