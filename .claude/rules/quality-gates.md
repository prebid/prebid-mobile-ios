# Quality gates

The ladder, cheapest first. A change is "done" when every rung that applies has actually
run and passed — with evidence (command output), not intention.

| Rung | Command | When |
|---|---|---|
| 1. Guards | `./scripts/guards/run-guards.sh` | every change, before every commit |
| 2. Build | `./scripts/buildPrebidMobile.sh` | code changes |
| 3. Unit (quick) | `./scripts/testPrebidMobile.sh --latest --quick` | every code change |
| 4. Unit (full) | `./scripts/testPrebidMobile.sh --latest` | shared test infra, rendering, timing-adjacent changes |
| 5. Adapters | `./scripts/testPrebidMobileAdapters.sh` | any `EventHandlers/` change |
| 6. Integration/UI | `./scripts/testPrebidDemo.sh -l` / `-ui -l` | protocol/rendering behavior changes; release branches |

Rungs 2–6 need macOS + Xcode. When the environment can't run a rung, the report says
SKIPPED (environment) — a skipped gate is honest, a claimed pass is a lie that CI will
expose anyway.

## Additional gates by change type

- **Public API change** → API baseline regenerated and committed; ObjC-compat test
  considered; PR title reflects the change (release notes are built from PR titles).
- **ORTB / request building** → spec permalink cited in code + PR; wire-format test updated.
- **New architecture rule worth keeping** → becomes a guard (see `docs/guards/README.md`,
  "Adding a guard"), not a review comment.
