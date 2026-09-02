---
name: migration-patterns
description: Generic reference for Objective-C to Swift and XCTest to Swift Testing migrations. Background material only — for this repo's ObjC to Swift work, docs/migration/playbook.md is authoritative.
allowed-tools: [Read, Glob, Grep]
---

# Migration Patterns

Generic, non-repo-specific migration references retained as background reading.

> **Authority note.** This repo's ObjC → Swift migration is governed by
> **`docs/migration/playbook.md`**, plus `agents/xcodebuild/SKILL.md` (build-error triage) and
> `agents/review/SKILL.md` (review checklist). Those are derived from actual build failures in
> this codebase. Where the generic `objc-to-swift.md` below disagrees with them, **the playbook
> wins.** See "Known conflicts" for the specific points.

## Available guides

| Migration | Reference File | Status in this repo |
|-----------|---------------|---------------------|
| Objective-C to Swift | `objc-to-swift.md` | **Active** — but see playbook first, and the conflicts below |
| XCTest to Swift Testing | `xctest-to-swift-testing.md` | **Not adopted** — 194 files use `XCTestCase`, 0 use Swift Testing |

## Known conflicts between `objc-to-swift.md` and this repo

Four points where following the generic guide would break this SDK:

1. **`@objc` naming.** The guide only ever shows bare `@objc class Foo: NSObject`. The
   parenthesized form `@objc(PBMFoo)` never appears in it. This repo has 153 `@objc(PBM…)`
   declarations, and they exist to preserve the shipped ObjC API name while the Swift type drops
   the prefix. Omitting it silently renames a public class. See playbook "Naming convention".

2. **Value types.** The guide advises converting `NSObject` subclasses to structs
   (`objc-to-swift.md:25`, `:121`). Phase 1–3 ORTB twins **must** stay `@objc` `NSObject`
   subclasses because ObjC parameter builders still consume them — playbook Gap 4.

3. **Bridging headers.** The guide makes them central. The `PrebidMobile` framework target has
   no bridging header and cannot use one; only the test target does. See playbook Gap 8 on
   private-header invisibility in framework builds.

4. **The Swift→ObjC import.** The guide says `#import "ProjectName-Swift.h"`. This repo must use
   `#import "SwiftImport.h"`, a conditional shim — a direct import compiles under CocoaPods and
   fails under SPM.

Also absent from the guide entirely: `NSCopying` (playbook records that `.copy()` crashes at
runtime on twins that omit it) and the `@_spi(PBMInternal)` propagation rules.

## Why this repo stays on XCTest

Recorded so the question does not get reopened. `xctest-to-swift-testing.md:433-441` disqualifies
this repo on two of its own criteria: shared test infrastructure via `XCTestCase` subclassing, and
ObjC test helpers that depend on `XCTestCase`. Beyond that, the `.xctestplan` registry, the ObjC
test bridging header, and the flaky-test isolation procedure in `agents/xcodebuild/SKILL.md` all
assume XCTest's `Class/method` addressing.

Note in particular that the generic advice to "migrate tests first for a safety net" is **wrong
here** — the XCTest suite *is* the safety net for the ObjC → Swift work, and it gates every
migration PR (`./scripts/testPrebidMobile.sh --latest --quick`). Dismantling it first would remove
the gate before the risky work begins.

## References

- [Migrating a test from XCTest](https://developer.apple.com/documentation/testing/migratingfromxctest)
- [Swift and Objective-C in the same project](https://developer.apple.com/documentation/swift/importing-objective-c-into-swift)
