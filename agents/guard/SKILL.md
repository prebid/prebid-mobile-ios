---
name: guard
description: Author a new structural guard from a prose architecture rule — pick the right mechanism (ast-grep / grep / git-diff / consistency script), grandfather existing violations, prove true-positive and true-negative, register and document it.
---

# /guard <rule description>

Turns an architecture rule into a permanent, deterministic check in `scripts/guards/`.
Read `docs/guards/README.md` first — it defines the ratchet contract every guard obeys.

## 1. Pick the mechanism

| Rule shape | Mechanism | Existing example |
|---|---|---|
| Structural Swift pattern ("X must (not) appear inside Y") | ast-grep YAML in `scripts/guards/rules/` | `main-thread-callbacks.yml` |
| Content/parse rule (imports, symbols, counts, consistency) | Python check in `scripts/guards/checks/` on `lib/guardlib.py` (stdlib only, no pip) | `logging_hygiene.py`, `fixme_ratchet.py` |
| "New files must (not) go to path P" | git-diff check via `subprocess` (ratchets by construction) | `swift_migration_direction.py` |
| Committed-surface change control | lockfile check on `guardlib` | `api_baseline.py` |

Python checks reuse `guardlib`'s three primitives (lockfile, allowlist ratchet, count
ratchet) and get unit tests in `scripts/guards/tests/` (run in CI). All committed data is
JSON read through `guardlib` (schema-validated, so a malformed file FAILs instead of
reading as "no findings"); wrap `main` in `guardlib.cli()` so that failure is actionable,
and exit `guardlib.EXIT_SKIPPED` when a required external tool is absent. `guardlib` is
platform-agnostic by design — it is the part that later ports to the Android repo.

Prefer the simplest mechanism that has no false positives. False negatives are acceptable
(a guard that catches 80% mechanically beats a review comment); false positives are not —
they teach people to ignore guards.

## 2. Build it

1. Write the rule or check. Checks: Python 3 stdlib only, self-locate `ROOT` like the
   existing checks, deterministic output (sorted), actionable FAIL message that says how
   to fix — plus unit tests for any nontrivial parsing in `scripts/guards/tests/`. Keep
   parsing separate from I/O (see `ast_rule_ratchet.parse_stream`) so it is testable
   without the tool installed.
2. Run against the current tree. Existing violations → grandfather into
   `scripts/guards/allowlists/<guard>.json` and implement the ratchet: new violations
   fail, stale entries fail. Use `guardlib.read_allowlist()` + `guardlib.ratchet()` (see
   `adapter_isolation.py`); report stale entries with `guardlib.describe_entries()` so
   the failure states what each grant was for.
3. Each grandfathered entry is a record — `entry` (the exact token your probe emits) and
   `reason`. The schema is validated on read, so a missing or empty reason fails the run:
   state the justification there, never as an in-code `FIXME` comment (the
   `fixme-ratchet` guard blocks marker growth). Where the debt needs tracking, file an
   issue per cluster and name it in the file's top-level `description`.

## 3. Prove it (mandatory, before committing)

- **True positive**: introduce a violation on a scratch change → guard fails with the
  actionable message. Revert.
- **True negative**: clean tree → guard passes. Full suite `./scripts/guards/run-guards.sh`
  still exits 0.

## 4. Register and document

- Add a `run_guard` line in `scripts/guards/run-guards.sh` (blocking). An ast-grep
  pattern rule whose existing findings are too numerous to enumerate joins the count
  ratchet instead: add its rule id to `AST_RULES` in `run-guards.sh` and record the
  count with `--update-ast-rule-baseline` (the ast-rule-ratchet block).
- Add a section to `docs/guards/README.md`: what it enforces, why, how to fix a failure.
- One commit for the whole guard: rule/script + allowlist/baseline + docs + runner entry.
