# Session completion checklist

Before declaring a task done or ending a working session:

1. **Guards green** — `./scripts/guards/run-guards.sh` exit 0. If an allowlist or the API
   baseline changed, the diff is intentional, minimal, and called out.
2. **Tests ran** — the applicable rungs of the quality-gate ladder actually executed;
   failures are reported as failures, environment limits as SKIPPED with reason.
3. **No stray changes** — `git status` shows only files the task required. No leftover
   debug prints, no commented-out code, no unrelated formatting churn.
4. **Three build systems consistent** — file adds/moves/deletes reflected in xcodeproj,
   `Package.swift`, and podspecs where applicable.
5. **Ratchet respected** — no allowlist grew; no xctestplan skip-list grew; stale allowlist
   entries removed alongside their fixes.
6. **Commits** — each logical step its own commit; messages describe the change in
   release-note-quality language (PR titles become release notes).
7. **Handoff honesty** — the summary states what was verified, what was not, and any
   follow-ups filed as issues rather than left implicit.
