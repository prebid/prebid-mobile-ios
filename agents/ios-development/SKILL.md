---
name: ios-development
description: Generic iOS/Swift reference material — Swift idioms, architecture notes, accessibility and HIG checklists, and size-class handling. Background reading only; not specific to this SDK. For ObjC → Swift migration, use the migration-patterns skill instead.
allowed-tools: [Read, Glob, Grep, WebFetch]
---

# iOS Development Reference

Generic iOS guidance retained as background reading. **This is not repo-specific.** For anything
concerning this SDK, the authoritative sources are `AGENTS.md`, `docs/migration/playbook.md`, and
the runbooks in `agents/` — see the routing table in `AGENTS.md`. Migration material lives in its
own skill, `agents/migration-patterns/`.

Much of the original third-party bundle was removed as inapplicable: this is a header-bidding ad
SDK (a UIKit library, iOS 13+), not an app. It has no SwiftUI, no Core Data, no navigation
hierarchy, no App Store presence. What remains below is the subset with some bearing on the code.

## Available modules

### `coding-best-practices/`
- `swift-patterns.md` — Swift idioms: optionals, type safety, collections, error handling. Its
  naming section reflects this repo's no-single-letter-names rule.
- `architecture-patterns.md` — largely MVVM/app-oriented, so mostly inapplicable to a library.
  The memory-management notes and "don't log sensitive data" are the relevant parts; the latter
  matters here given consent strings, IDFA, and EIDs.

### `ui-review/`
Written in SwiftUI idiom, so the mechanisms rarely transfer — but the thresholds are format-neutral
and do apply to the ad chrome this SDK draws over advertiser content.
- `hig-checklist.md` — notably the 44×44pt minimum tap target, and the orientation matrix.
- `accessibility-quick-ref.md` — contrast ratios (4.5:1 text, 3:1 UI components) and the
  VoiceOver / Dynamic Type / Reduce Transparency test matrix.
- `font-guidelines.md` — the fixed-point-size anti-pattern applies to the two places the SDK draws
  text; every remedy in the file is SwiftUI, so translate to `UIFontMetrics` yourself.

### `ipad-patterns/`
- `multitasking.md` — size-class and trait-change handling, plus the `UIScreen.main.bounds`
  anti-pattern. Relevant because the SDK renders inside a host app's window, which may be a
  fraction of the screen under Split View or Stage Manager.

## How to use

Read a specific file when its topic comes up. Prefer repo-specific docs wherever both cover the
same ground — these files cannot know this codebase's constraints.
