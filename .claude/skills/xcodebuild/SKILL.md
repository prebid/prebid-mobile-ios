---
name: xcodebuild
description: Run xcodebuild tests for a scheme or specific test class in PrebidMobile.xcworkspace
---

Run xcodebuild tests for this iOS project. The workspace is `PrebidMobile.xcworkspace`.

## Available schemes

- `PrebidMobileTests` — core SDK unit tests (694 tests in PR plan, 1111 in full plan)
- `PrebidMobileGAMEventHandlersTests` — GAM adapter tests
- `PrebidMobileAdMobAdaptersTests` — AdMob adapter tests
- `PrebidMobileMAXAdaptersTests` — MAX adapter tests

Default simulator destination: `platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest`

## Running the full suite via the wrapper scripts (preferred)

Always use the project scripts, not raw xcodebuild, for build and test:

```bash
# Build all 4 XCFrameworks — run first after every migration step
./scripts/buildPrebidMobile.sh

# PR subset — 694 tests, gate for migration PRs
./scripts/testPrebidMobile.sh --latest --quick

# Full suite — 1111 tests, run on final commit of each phase
./scripts/testPrebidMobile.sh --latest
```

The test script handles simulator create/delete, the two-step build-for-testing /
test-without-building flow, -retry-tests-on-failure, and the correct test plan
(-testPlan PrebidMobilePRTests or PrebidMobileTests).

## Pass/fail policy

**`--quick` run is the gate for migration PRs.** Any failure is a regression that must be fixed
before committing. Do not recheck on another branch or re-run to dismiss — if it fails, fix it.

The only exception is `PBMBidRequesterTest.testBanner_300x250` (pre-existing flaky; see
playbook.md). If that is the sole failure and it passes in isolation, proceed. Every other
failure is a hard stop.

## Post-migration checklist (run BEFORE the first build attempt)

After porting a batch of ObjC `.m`/`.h` files to Swift and deleting the originals, do these
steps in order. They prevent the most common build errors and save multiple build iterations.

### 1 — Update the Xcode project file

The `.xcodeproj` has explicit compile-source and header lists. Use the `xcodeproj` gem:

```ruby
# Remove stale ObjC refs and add new Swift files — adapt file lists as needed
require 'xcodeproj'
proj = Xcodeproj::Project.open('PrebidMobile.xcodeproj')

to_remove = %w[PBMFoo.m PBMFoo.h PBMFoo+Private.h ...]   # deleted files
to_add    = %w[Foo.swift ...]                              # new Swift files

main_target = proj.targets.find { |t| t.name == 'PrebidMobile' }

proj.targets.each do |target|
  target.build_phases.each do |phase|
    next unless phase.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase) ||
                phase.is_a?(Xcodeproj::Project::Object::PBXHeadersBuildPhase)
    phase.files.select { |f| to_remove.include?(f.file_ref&.path) }.each(&:remove_from_project)
  end
end
proj.files.select { |f| to_remove.include?(f.path) }.each(&:remove_from_project)

utilities_group = proj.main_group.recursive_children.find do |c|
  c.is_a?(Xcodeproj::Project::Object::PBXGroup) &&
  c.real_path.to_s.end_with?('Swift/PrebidMobileRendering/Utilities')  # adjust path
end

to_add.each do |fname|
  next if proj.files.any? { |f| f.path == fname }
  main_target.source_build_phase.add_file_reference(utilities_group.new_file(fname))
end

proj.save
```

Run with: `ruby update_project.rb`

### 2 — Remove deleted-header imports from ObjC consumer .m files

```bash
# Replace with the actual deleted header names
perl -pi -e 's/^#import "PBMFoo\.h"\n?//g'          file1.m file2.m ...
perl -pi -e 's/^#import "PBMFoo\+Private\.h"\n?//g' file1.m file2.m ...
```

### 3 — Fix any typedef losses

When a widely-imported header (e.g. `PBMFunctions.h`) that re-exported typedefs (`PBMJsonDictionary`,
`PBMMutableJsonDictionary`) is deleted, add `#import "PBMConstants.h"` to every ObjC `.m` that
used those typedefs. Catch with:

```bash
grep "error:.*undeclared identifier.*PBMJsonDictionary" generated/log/prebid_mobile_build.log
```

### 4 — Replace deleted-header imports in PrivateHeaders

Headers that imported another now-deleted header need updating:
- Replace `#import "PBMFoo.h"` with `@class PBMFoo;` (forward decl) when the type is only used
  as a property/parameter type.
- Replace with `#import "SwiftImport.h"` when the `.m` calls methods on the type and is NOT
  itself being ported this step.

### 5 — Update the test bridging header

`PrebidMobileTests/PrebidMobileTest-Bridging-Header.h` lists ObjC headers explicitly. Remove
every deleted header from it. Already-migrated Swift types are visible to ObjC tests via the
module automatically.

### 6 — Rename migrated types in Swift test files

Swift tests that used ObjC names (via bridging header) now see Swift class names. Bulk-rename:

```bash
perl -pi -e 's/PBMFoo\b/Foo/g' PrebidMobileTests/**/*.swift
```

Use `perl -pi` (not `sed -i ''`) for reliable `\b` word-boundary support on macOS.

Also rename property/method calls that changed from ObjC style to Swift style:
- `[PBMFunctions sdkVersion]` was ObjC method → Swift `Functions.sdkVersion` (property, no parens)
- `[PBMFunctions supportedSKAdNetworkVersions]` → `Functions.supportedSKAdNetworkVersions`
- `[PBMFunctions deviceMaxSize]` → `Functions.deviceMaxSize` (all static var, no `()`)

### 7 — Fix @_spi access in test files

The `Functions` class carries `@_spi(PBMInternal)`. Any Swift test file that calls `Functions.*`
directly must use:

```swift
@_spi(PBMInternal) @testable import PrebidMobile
```

**Critical**: use Python (not Perl) to inject `@_spi` into import lines — Perl's `@` interpolation
in regex patterns silently corrupts the line:

```python
import re, sys
path = sys.argv[1]
content = open(path).read()
content = re.sub(
    r'^@testable import PrebidMobile$',
    '@_spi(PBMInternal) @testable import PrebidMobile',
    content, flags=re.MULTILINE
)
open(path, 'w').write(content)
```

To batch-fix a list of files:
```bash
python3 - file1.swift file2.swift << 'PYEOF'
import sys, re
for path in sys.argv[1:]:
    c = open(path).read()
    c = re.sub(r'^@testable import PrebidMobile$',
               '@_spi(PBMInternal) @testable import PrebidMobile',
               c, flags=re.MULTILINE)
    open(path, 'w').write(c)
PYEOF
```

If you accidentally corrupt imports with Perl (symptom: `(PBMInternal)  import PrebidMobile`
or `@testable (PBMInternal) import`), recover with:

```python
import os, re, pathlib
for p in pathlib.Path('PrebidMobileTests').rglob('*.swift'):
    c = p.read_text()
    fixed = re.sub(r'\(PBMInternal\)\s+import PrebidMobile',
                   '@_spi(PBMInternal) @testable import PrebidMobile', c)
    if fixed != c:
        p.write_text(fixed)
```

### 8 — Add NSObject superclass to mocks that conform to @objc protocols

Any Swift mock class conforming to an `@objc protocol ... : NSObjectProtocol` must inherit
`NSObject`. Update the mock class declaration:

```swift
// before
class MockFoo: PBMSomeProtocol { ... }

// after
class MockFoo: NSObject, PBMSomeProtocol { ... }
```

### 9 — Fix no-arg init for migrated NSObject subclasses

Swift designated inits suppress `NSObject.init()` inheritance. If tests call the no-arg form
(e.g. `MRAIDResizeProperties()`), add an explicit override:

```swift
@objc public var width: Int = 0  // all stored properties need defaults
...
public override init() { super.init() }
```

## Common build-error → fix mapping

| Error | Root cause | Fix |
|-------|------------|-----|
| `'PBMFoo.h' file not found` | Deleted header still imported | Remove import; use forward decl or SwiftImport.h |
| `use of undeclared identifier 'PBMJsonDictionary'` | Lost typedef from deleted PBMFunctions.h | Add `#import "PBMConstants.h"` |
| `'PBMFoo' has been renamed to 'Foo'` | Swift test using ObjC bridging name | `perl -pi -e 's/PBMFoo\b/Foo/g'` in test files |
| `inaccessible due to '@_spi'` | Swift test accessing Functions.* without SPI import | Add `@_spi(PBMInternal) @testable import` |
| `cannot call value of non-function type 'String'` | ObjC method → Swift property; called with `()` | Remove `()` — it's now a property |
| `missing arguments for parameters 'width', 'height'` | Swift init lacks no-arg form | Add `public override init() { super.init() }` with defaulted properties |
| `cannot declare conformance to 'NSObjectProtocol'` | Mock class missing NSObject | Add `: NSObject` superclass |
| `@objc method name provides N argument names, but method has N+1` | `throws` method needs `:error:` in explicit name | Use `@objc(name:error:)` not `@objc(name:)` |
| `'dispatch_time' has been replaced` | C function unavailable in Swift | `(DispatchTime(uptimeNanoseconds: t) + interval).rawValue` |
| `'UIInterfaceOrientationIsPortrait' has been replaced` | C macro unavailable in Swift | `orientation.isPortrait` |
| `initializer for conditional binding must have Optional type` | Callback `PrebidServerResponse` is non-optional | Remove `if let` / `guard let`; use directly |
| `expected a type` in ObjC header | UIKit missing after header removal | Add `#import <UIKit/UIKit.h>` to affected header |
| `(PBMInternal)  import PrebidMobile` in source | Perl `@` interpolation corrupted import | Run Python recovery script (see §7) |

## Running a single test class (raw xcodebuild)

Use the two-step approach so you can iterate without rebuilding:

### Step 1 — ensure the simulator exists

```bash
xcrun simctl delete iPhone-16-Pro-PrebidMobile 2>/dev/null || true
xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro
```

### Step 2 — build for testing (once)

```bash
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
  -destination-timeout 60 \
  build-for-testing
```

### Step 3 — run tests (repeat without rebuilding)

```bash
xcodebuild \
  -workspace PrebidMobile.xcworkspace \
  -scheme PrebidMobileTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
  -destination-timeout 60 \
  -only-testing PrebidMobileTests/<TestClass> \
  test-without-building
```

Omit `-only-testing` to run the full scheme. Add `/<testMethod>` to narrow to a single test.

If no scheme is specified by the user, default to `PrebidMobileTests`.
Report pass/fail and the executed/failed counts clearly after the run.
