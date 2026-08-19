---
name: lint
description: Run SwiftLint on the PrebidMobile Swift sources
---

Run SwiftLint on the project using the existing config file:

```
swiftlint --config .swiftlint.yml
```

If SwiftLint is not installed, offer to install it via Homebrew:
```
brew install swiftlint
```

After linting, summarize:
- Total warnings and errors
- Files with the most violations
- Any errors that must be fixed (errors block builds; warnings do not)

If the user asks to auto-fix violations, run:
```
swiftlint --fix --config .swiftlint.yml
```
and report what was corrected vs. what still needs manual attention.
