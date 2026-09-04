# Structural guards

Fast, deterministic architecture checks for prebid-mobile-ios. They run on every PR
(`.github/workflows/guards.yml`, ubuntu, seconds of runtime) and locally:

```bash
./scripts/guards/run-guards.sh
```

To run them automatically before every push (opt-in, one-time per clone):
`git config core.hooksPath .githooks` — the hook (`.githooks/pre-push`) runs this same
suite and blocks the push on failure (`--no-verify` bypasses; CI still catches it).

Requirements: bash + git. The `ast-rule-ratchet` guard additionally needs
[ast-grep](https://ast-grep.github.io/) (`brew install ast-grep`); when it's missing locally,
that guard is skipped with a note — CI is authoritative.

## The ratchet

Guards enforce rules going **forward** without demanding the past be fixed first:

- Pre-existing violations are *grandfathered* in `scripts/guards/allowlists/<guard>.json`.
- Allowlists **only shrink**. A stale entry (the violation is gone) fails the run and must be
  deleted in the same PR — so the debt is monotonically decreasing.
- New violations fail immediately.
- Where sites are too numerous to enumerate, the same contract applies to a **count
  baseline** (`scripts/guards/baselines/`): growth fails, shrinkage must update the
  committed number in the same PR (`fixme-ratchet`, `ast-rule-ratchet`).

## Data format

Every committed allowlist and baseline is JSON with a `guard` field naming its owner and a
`description` stating its contract. The schema is validated on **every** read, so a
malformed or under-specified file fails the run instead of quietly reading as "no
findings" — which would look like a ratchet win.

An allowlist entry carries its justification with it, rather than in a comment no parser
can see:

```json
{
  "guard": "logging-hygiene",
  "description": "Files with raw print()/NSLog() calls predating the Log facade rule…",
  "entries": [
    {
      "entry": "PrebidMobile/Swift/AdUnits/Utils.swift",
      "reason": "Raw console output predating the Log-facade rule."
    }
  ]
}
```

`entry` is the exact violation token the guard's probe emits (a path, a `path:symbol` pair,
a symbol name — each guard's section below says which). `reason` states why the violation
is grandfathered. Both are required and must be non-empty, and any other field is rejected
— so a typo (`resaon`) fails loudly instead of silently dropping the justification. A
stale-entry failure prints each entry's `reason`, so the report says what the grant was
for.

Baselines come in three shapes, all with the same `guard`/`description` header:

| Shape | Payload | Used by |
|---|---|---|
| count | `"count": 42` | `fixme-ratchet` |
| keyed count | `"counts": {"<key>": 3}` | `api-doc-coverage`, `string-dup-ratchet`, `ast-rule-ratchet` |
| entry list | `"entries": ["…"]` | `skiplist-ratchet` |

`public-api.json` is its own richer structured model (see `public-api-baseline` below).
Regenerating any baseline preserves the prose already in its `description`, and writes
sorted keys with zero counts dropped, so a regeneration diff shows only real movement.

## Guards

### adapter-isolation (blocking)

`EventHandlers/**` (GAM/AdMob/MAX adapters) must only use the public PrebidMobile API.
Never allowed, no allowlist: `import __PrebidMobileInternal`, `@_spi(...)` imports,
`PrivateHeaders/` includes (comment lines are exempt — a doc comment *mentioning*
`@_spi` is not a seam). Additionally, `PBM*` symbol references must resolve to the
public vocabulary (public/open declarations and `@objc(PBM...)` renames in the core, or
types the adapter defines itself) — anything else is an internal symbol.

**When it fails:** replace the internal symbol with public API; if no public API exists for
the need, that's a missing-API discussion for the PR, not a reason to reach inside.

### public-api-baseline (blocking)

The API surface is snapshotted in `scripts/guards/baselines/public-api.json` — a JSON
object keyed by exposure section, machine-readable for downstream tooling (release
gates, API-diff comments) and formatted so a baseline change reviews as one `+`/`-`
line per moved declaration:

| Prefix | Surface | Notes |
|---|---|---|
| `swift` | true `public`/`open` Swift declarations | the publisher contract |
| `swift-spi` | `@_spi(PBMInternal)`-gated declarations | hidden from normal imports, but reachable by source-based SPM consumers via `@_spi(PBMInternal) import PrebidMobile` |
| `objc-header` | public ObjC headers (non-`PrivateHeaders` `.h`) | mirrors the podspec's `private_header_files`; currently empty |
| `objc-internal` | `PrivateHeaders` `@interface`/`@protocol` declarations | de-facto reachable by SPM consumers because the root `Package.swift` exports `__PrebidMobileInternal`; **should only shrink** as the Swift migration deletes ObjC — a visible ratchet |
| `spm-product` | product→target export lists of all three `Package.swift` manifests | freezes the exported targets so a new `__*Internal`-style leak can't appear silently |

Declarations are stored as a **structured model**, one field per fact — nothing is
encoded in strings that tooling would have to re-parse:

```json
"swift": { "AdUnit": { "func": { "fetchDemand": 2, "getGPID": 1 } } }
```

The `swift` and `swift-spi` sections are keyed by the declaring type's dotted name path
(`"AdUnit"`, `"Signals.Api"`; `"(top-level)"` for free declarations — extension scopes
contribute the *extended* type's name, so extension members group with the type they
extend), then by declaration kind, then by name, whose value is the **declaration
count** — two overloads of `fetchDemand` are `"fetchDemand": 2`, so adding or removing
an overload is a visible one-line baseline diff even when the name already exists.
`objc-internal` uses the same `{kind: {name: count}}` shape; `spm-product` is
`{manifest: {product: [target]}}`; `objc-header` stays a path list.

The Swift extractor tracks brace depth (with string literals and comments stripped) to
know the enclosing scope, which also lets it record implicitly-public surface a flat
name scan cannot see: members of a `public extension`, requirements of a public
protocol, and cases of a public enum. It is multi-line aware (attribute/modifier-only
heads join the following declaration line) and recognizes declaration modifiers before
the access keyword (`dynamic public func`, `override public var`) — Swift permits
either ordering. It remains a line-based heuristic, not a parser; its known misses are
listed in the module docstring of `scripts/guards/checks/api_baseline.py`, and the
regenerated baseline diff is always the ground truth to review.

Any change to any section fails until the baseline is regenerated — making surface changes
an explicit, reviewable artifact:

```bash
./scripts/guards/run-guards.sh --update-api-baseline
```

Commit the baseline diff in the same PR and call it out in the description. If you didn't
mean to change the API, tighten the access level instead (`public` → `internal`).

Not covered (inherent to Objective-C, no compile-time surface to snapshot): `@objcMembers`
classes expose every member to the ObjC runtime via reflection regardless of Swift access
level — see the corresponding known-trap note in `CLAUDE.md`.

Also emits an advisory when `.jazzy.yaml` excludes paths that no longer exist on disk
(docs-config drift).

### swift-migration-direction (blocking)

The core is migrating Objective-C → Swift. Adding new `.h/.m/.mm` files under
`PrebidMobile/Objc/` fails; new code goes in `PrebidMobile/Swift/`. Diff-based against the
merge-base with `master`, so it ratchets by construction.

Rare, genuinely unavoidable exceptions (e.g. a bridge shim Swift cannot express) are
granted explicitly: add an entry for the path to
`scripts/guards/allowlists/swift-migration-direction.json` with its `reason`,
**in the same PR** — the grant is then part of the reviewed diff, and the guard echoes it
with its reason as a NOTE for reviewers. After the PR merges the
entry is stale; the guard reports it as an advisory to remove (it does not fail, so
unrelated PRs are never blocked by someone else's merged exception).

### fixme-ratchet (blocking)

FIXME/TODO markers in core sources (`PrebidMobile/`) are deferred behavior decisions —
upstream issue #1299 is a `FIXME` that shipped as user-visible behavior. The count is
recorded in `scripts/guards/baselines/fixme-count.json` and may only shrink. Growth fails
(fix the marked issue, or file a GitHub issue and delete the marker); shrinkage fails
until the baseline is updated in the same PR — a visible ratchet win:

```bash
./scripts/guards/run-guards.sh --update-fixme-baseline
```

### ortb-test-presence (blocking)

Every ORTB model — discovered by **file name** (`ORTB*.swift` anywhere under
`PrebidMobile/`), not by hardcoded paths, so the migration reshuffling directories can
never silently drop models from checking — must be referenced by at least one test in
`PrebidMobileTests`. If discovery finds no model at all, the guard fails rather than
passing on an empty scope. Motivated by a year of upstream issues concentrated on
untested decode paths (#1300/#1255/#1259). The check is deliberately loose (name
referenced anywhere in test sources); coverage *quality* is the spec-grounding gate's
job. Pre-existing gaps are grandfathered in
`scripts/guards/allowlists/ortb-test-presence.json` (shrink-only; stale entries fail).

**When it fails:** add a wire-format/decoding test exercising the type, citing the
OpenRTB spec section in the docstring.

### logging-hygiene (blocking)

Publishers see the SDK's console output inside their apps — raw `print()`/`debugPrint()`/
`NSLog()` bypasses the `Log` facade's levels and custom-logger routing, so it can't be
silenced or redirected (upstream #1295/#1279 are the failure class). All output goes through
`Log.error/warn/info/debug/verbose`. `PrebidMobile/Swift/Logging/` is structurally exempt
(the console logger is the sanctioned `print()` call site); two pre-existing violating
files are grandfathered in `scripts/guards/allowlists/logging-hygiene.json` (shrink-only).

### skiplist-ratchet (blocking)

`PrebidMobileTests/PrebidMobilePRTests.xctestplan` (the quick PR plan) skips slow and
timing-sensitive tests. The test-integrity policy says its skip-list may **only shrink**
— this guard makes that mechanical, and the baseline **enumerates every skipped test
identifier** (`scripts/guards/baselines/skiplist.json`, `<target>/<Class>/<test>()` per
entry), so a *swap* — un-skipping one test while skipping another — fails by name, which
the earlier bare count could never see. A new skip fails naming the test ("never add
entries to make CI pass"); a removed skip fails until the baseline is updated in the
same PR — a visible ratchet win naming the exact test:

```bash
./scripts/guards/run-guards.sh --update-skiplist-baseline
```

### deprecation-hygiene (blocking)

Deprecating API without telling the publisher what to use instead is a recurring
review ask (11 inline review comments in the upstream PR history). Every `@available`
attribute marking a declaration `deprecated` in `PrebidMobile/Swift/` or non-test
`EventHandlers/` sources must carry a non-empty `message:` (or a `renamed:`) naming
the replacement. Wrapped multi-line attributes are joined before checking. Bare
`unavailable` is deliberately not flagged — its dominant use is the idiomatic
private-init blocker, which has no replacement to name (removing public API is the
api-baseline guard's territory). The tree was fully compliant when the guard landed, so
`allowlists/deprecation-hygiene.json` starts empty — a future exception needs its
`reason`, in the same PR (shrink-only).

**When it fails:** add `message: "Use <replacement> instead"` (or `renamed:`) to the
deprecation attribute.

### api-doc-coverage (blocking)

"Please describe the method in details" is the third most common actionable ask in the
upstream repo's inline review history (14 comments), and the rule already exists in
prose (`.claude/rules/code-patterns.md`: public declarations carry doc comments — Jazzy
publishes them). This guard makes it a per-file ratchet: the count of **undocumented**
public declarations per file (`scripts/guards/baselines/api-doc-counts.json`) may only
shrink — new public API arrives documented, and a cross-file swap fails in the file
that grew. Roughly half the surface was undocumented at landing time (817 declarations
across 128 files); that debt is grandfathered, not demanded up front.

"Documented" = a `///` line or `/** … */` block immediately above the declaration head
(attributes/modifiers in between are fine), detected by the same extractor that builds
the API baseline, so the two guards can never disagree about what is public. Enum
`case`s and `extension` declarations are not counted.

```bash
./scripts/guards/run-guards.sh --update-api-doc-baseline
```

**When it fails on growth:** add the doc comment. On shrink (you documented something):
update the baseline in the same PR — a visible ratchet win.

### api-naming (blocking)

Naming asks are the most frequent review theme in the upstream PR history (26 inline
comments); most are judgment calls, so this guard enforces only the crisp codified rule
(`.claude/rules/code-patterns.md`): the `PBM` prefix belongs on the ObjC side only —
Swift symbols get `@objc(PBMName)` renames, and a PBM-prefixed name in the public Swift
surface is a migration leftover. Reads the committed API baseline (the structured
model), never re-parses source, so it cannot disagree with `public-api-baseline` about
what the surface is. `PBMMediation*` constants are a permanent documented exception
(publisher wire contract — see the known-trap note in CLAUDE.md), encoded in the check.
Ten leftovers are grandfathered in `allowlists/api-naming.json` (shrink-only).

**When it fails:** name the Swift symbol without the prefix (add the `@objc(PBM…)`
rename if ObjC callers need the old spelling); renames of already-shipped API deprecate
the old name (deprecation-hygiene guard applies).

### api-test-presence (blocking)

"Add a test for this" is the most common substantive review ask in the upstream PR
history (24 inline comments). `ortb-test-presence` covers the ORTB models; this guard
extends the same contract to the rest of the surface: every public type
(class/struct/enum/protocol/actor) in the API baseline's `swift` section must be
referenced by at least one test in `PrebidMobileTests`. The type list comes from the
committed structured baseline, so it can never disagree with `public-api-baseline`.
Same deliberately-loose "referenced at all" contract and the same empty-scope-fails
safety. 34 pre-existing gaps are grandfathered in `allowlists/api-test-presence.json`
(shrink-only) — that list is the untested-public-API backlog.

**When it fails:** add a test that exercises the type (or question whether it should
be public at all — an untestable public type is a design smell).

### string-dup-ratchet (blocking)

"The constant is duplicated across the SDK — consolidate" is a recurring review ask
(10 inline comments in the upstream PR history). A string literal (≥ 6 chars, no
interpolation) appearing in **3 or more distinct files** of `PrebidMobile/Swift/` is a
duplicated constant; the per-literal file counts are baselined in
`scripts/guards/baselines/string-dup-counts.json` and may only shrink. Thresholds were
tuned against the tree: at ≥ 2 files the findings are dominated by short JSON keys
whose repetition is natural (false-positive territory); at ≥ 3 files only the real
offenders remain (2 grandfathered at landing). Extraction is comment- and
multiline-string-aware, so license headers never count; the stock Xcode `init(coder:)`
boilerplate is exempt.

```bash
./scripts/guards/run-guards.sh --update-string-dup-baseline
```

**When it fails on growth:** reuse or hoist the existing constant instead of copying
the literal. On shrink (you consolidated): update the baseline — a ratchet win.

### ast-rule-ratchet (blocking — per-rule finding count may not grow)

Three ast-grep pattern rules whose grandfathered findings are recorded as **counts** in
`scripts/guards/baselines/ast-rule-counts.json` (the count-ratchet pattern: too many sites
to enumerate in an allowlist, so only the number is committed). A count that grows fails
the run — fix the new site, or update the baseline with justification in the same PR. A
count that shrinks also fails until the baseline is updated — a visible ratchet win:

```bash
./scripts/guards/run-guards.sh --update-ast-rule-baseline
```

The rules:

- **main-thread-delegate-callbacks** (`rules/main-thread-callbacks.yml`) — publisher-facing
  delegate callbacks are delivered on the main queue; flags optional-chained calls on any
  `*[dD]elegate`-named receiver (`delegate`, `flowDelegate`, `videoPlaybackDelegate`, …)
  not visibly wrapped in `DispatchQueue.main.async`. The rule is still being calibrated
  against the codebase's idioms, so a growth failure can be a false positive — the
  justified-baseline-update escape hatch exists for exactly that case.
- **force-unwrap** (`rules/force-unwrap.yml`) — `x!` / `try!` / `as!` in production code
  turns unexpected nil into publisher-visible crashes (upstream #1273). IUO type
  declarations, prefix negation, and `!=` are deliberately not matched.
- **weak-delegate** (`rules/weak-delegate.yml`) — stored `[dD]elegate$`-named class
  members without `weak`/`unowned` are the classic retain-cycle source. Computed
  properties, protocol requirements, and local bindings are excluded (known miss:
  stored properties with `didSet` observers).

Inspect findings with:

```bash
ast-grep scan -c scripts/guards/sgconfig.yml PrebidMobile/Swift
```

Requires ast-grep; when missing locally the guard reports SKIPPED and CI (pinned
install) is authoritative. Long-term path per rule: triage its findings toward zero, or
graduate the remainder into a site-enumerating allowlist.

## Adding a guard

1. Structural Swift rule → ast-grep YAML in `scripts/guards/rules/`.
2. Content/parse rule (imports, symbols, counts, consistency) → Python check in
   `scripts/guards/checks/` built on `scripts/guards/lib/guardlib.py` (stdlib only —
   no pip), with unit tests in `scripts/guards/tests/` (run in CI).
3. Path or direction rule → git-diff-based check via `subprocess` (see
   `swift_migration_direction.py`).

`guardlib.py` provides the three ratchet primitives (lockfile, allowlist, count), the
validated JSON readers/writers every guard shares, and `cli()`, which turns a malformed
data file into an actionable FAIL. It is deliberately platform-agnostic — the layer that
later ports to prebid-mobile-android. A check that needs an external tool exits
`guardlib.EXIT_SKIPPED` when the tool is missing, and the runner reports it as an
advisory SKIP rather than a pass.

Every new guard must: run green on `master` (grandfather via allowlist if needed), fail on
a deliberately crafted violation (prove one true positive and one true negative), be
registered in `run-guards.sh`, and get a section in this file.
