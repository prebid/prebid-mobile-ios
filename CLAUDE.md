# CLAUDE.md — Prebid Mobile iOS

Guidance for AI assistants working on this codebase. Human contributors: see
[CONTRIBUTING.md](CONTRIBUTING.md); nothing in the contribution process requires an AI tool.

The philosophy here: rules are machine-enforced wherever possible. Most "musts" below point
at a structural guard (`./scripts/guards/run-guards.sh`, enforced in CI) — follow the rule
because the build fails otherwise, and when you find a recurring violation class that isn't
guarded yet, propose a new guard rather than relying on review vigilance.

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

## Commands

```bash
# Guards (seconds — run before every commit)
./scripts/guards/run-guards.sh
# …or have git run them automatically (opt-in, once per clone):
git config core.hooksPath .githooks

# Style lint on the lines this branch adds (advisory; see docs/lint/README.md)
./scripts/lint/run-swiftlint.sh

# Build
./scripts/buildPrebidMobile.sh

# Unit tests, quick PR plan / full plan (macOS + Xcode required)
./scripts/testPrebidMobile.sh --latest --quick
./scripts/testPrebidMobile.sh --latest

# Adapters / demo integration / demo UI
./scripts/testPrebidMobileAdapters.sh
./scripts/testPrebidDemo.sh -l
./scripts/testPrebidDemo.sh -ui -l
```

CI: guards run on every PR (`guards.yml`, ubuntu), as does the advisory SwiftLint pass
(`swiftlint.yml`, ubuntu). Build + quick unit tests run on every
non-draft PR (`PR_checks.yml`, macos). Full tests + demo suites run when the PR has the
`run-full-tests` label or the branch name contains `bump-to`.

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

## Known traps

- `scripts/testPrebidMobile.sh` installs pods and creates/deletes a named simulator; it
  needs macOS + Xcode.
- SwiftLint is **advisory and diff-scoped** — it lints the lines a branch adds, nothing
  else. A whole-tree run reports ~13k pre-existing violations; do not "fix" them as a
  drive-by. It replaces no guard (`docs/lint/README.md` says which rules it deliberately
  leaves to guards).
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
- `docs/lint/README.md` — SwiftLint: why it is advisory, diff-scoped, and not a guard
