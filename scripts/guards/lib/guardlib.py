"""Shared engine for the structural guards.

Python 3 stdlib only — no pip, no requirements file. The guards' contract
("seconds on any machine, ubuntu CI is authoritative") dies the moment they
need dependency installation.

Three ratchet primitives, used by the checks in scripts/guards/checks/:

  lockfile   — a committed snapshot must match regenerated reality exactly
               (public-api baseline).
  allowlist  — grandfathered violations enumerated one per line; new
               violations fail, stale entries fail (shrink-only).
  count      — grandfathered violations recorded as a number; growth fails,
               shrinkage fails until the committed number is updated.

This file is deliberately platform-agnostic: nothing in it knows about
Swift, Xcode, or iOS. Porting the guards to another repo (e.g.
prebid-mobile-android) means copying this file and the runner, then writing
platform-specific probes that feed these primitives.
"""

import os
import re


# ── file helpers ─────────────────────────────────────────────────────────────

def read_list(path):
    """Non-comment, non-blank lines of an allowlist/baseline file, as a list.

    Missing file reads as empty (guards create their allowlists on demand).
    """
    if not os.path.exists(path):
        return []
    entries = []
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if line and not line.startswith("#"):
                entries.append(line)
    return entries


def write_lines(path, lines):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        for line in lines:
            fh.write(line + "\n")


def c_sorted(lines):
    """Byte-order sort + dedupe, matching `LC_ALL=C sort -u` for the ASCII
    content the guards emit."""
    return sorted(set(lines))


# ── primitive 1: lockfile ────────────────────────────────────────────────────

def lockfile_diff(baseline_lines, current_lines, limit=40):
    """Changed lines between two snapshots, in unified-diff notation with
    the +++/--- headers dropped (same shape the shell version printed via
    `diff -u | grep -E '^[+-][^+-]' | head -40`). Empty list == no drift."""
    import difflib
    out = []
    for line in difflib.unified_diff(baseline_lines, current_lines, lineterm=""):
        if len(line) >= 1 and line[0] in "+-" and not line[1:2] in ("+", "-"):
            out.append(line)
            if len(out) >= limit:
                break
    return out


# ── primitive 2: allowlist ratchet ───────────────────────────────────────────

def ratchet(current_violations, allowlist_entries):
    """(new, stale): violations not grandfathered, and grandfathered entries
    whose violation is gone. Both must be empty for a pass."""
    current = set(current_violations)
    allowed = set(allowlist_entries)
    new = sorted(current - allowed)
    stale = sorted(allowed - current)
    return new, stale


# ── primitive 3: count ratchet ───────────────────────────────────────────────

def check_count(current, baseline_path, label, update_cmd, grow_hint):
    """Standard count-ratchet verdict.

    Returns (exit_code, [message lines]). Messages match the wording the
    bash guards established: growth and shrinkage both fail, with different
    instructions.
    """
    if not os.path.exists(baseline_path):
        return 1, [
            "FAIL: baseline missing. Record it with:",
            "      " + update_cmd,
        ]
    recorded_raw = open(baseline_path, encoding="utf-8").read().strip()
    try:
        recorded = int(recorded_raw)
    except ValueError:
        return 1, [
            f"FAIL: cannot parse {os.path.basename(baseline_path)} "
            f"(contents: {recorded_raw!r}). Re-record it with:",
            "      " + update_cmd,
        ]
    if current > recorded:
        return 1, [
            f"FAIL: {label} count grew ({recorded} → {current}).",
        ] + grow_hint
    if current < recorded:
        return 1, [
            f"FAIL: {label} count shrank ({recorded} → {current}) — a ratchet win, but the",
            "baseline must be updated in the same PR:",
            "      " + update_cmd,
        ]
    return 0, [f"OK: {label} count unchanged ({current})."]


# ── primitive 3b: keyed count ratchet ────────────────────────────────────────

def read_keyed_counts(path):
    """'<key> <count>' baseline lines as {key: int}. Missing file → {}.
    Raises ValueError on an unparsable line (caller reports it)."""
    counts = {}
    for line in read_list(path):
        key, _, num = line.rpartition(" ")
        if not key:
            raise ValueError(f"malformed keyed-count line: {line!r}")
        counts[key] = int(num)
    return counts


def format_keyed_counts(counts):
    """Sorted '<key> <count>' lines, zero-count keys dropped."""
    return [f"{key} {n}" for key, n in sorted(counts.items()) if n > 0]


def check_keyed_counts(current, baseline_path, label, update_cmd, grow_hint):
    """Per-key count-ratchet verdict: any key growing (or appearing) fails
    with the grow hint; any key shrinking (or disappearing) fails until the
    baseline is updated — a visible per-key ratchet win.

    Returns (exit_code, [message lines]); keys reported sorted.
    """
    if not os.path.exists(baseline_path):
        return 1, [
            "FAIL: baseline missing. Record it with:",
            "      " + update_cmd,
        ]
    try:
        recorded = read_keyed_counts(baseline_path)
    except ValueError as exc:
        return 1, [
            f"FAIL: cannot parse {os.path.basename(baseline_path)} ({exc}). Re-record with:",
            "      " + update_cmd,
        ]
    current = {k: n for k, n in current.items() if n > 0}
    grown = sorted(k for k in current if current[k] > recorded.get(k, 0))
    shrunk = sorted(k for k in recorded if recorded[k] > current.get(k, 0))
    if grown:
        lines = [f"FAIL: {label} count grew:"]
        lines += [f"  {k}: {recorded.get(k, 0)} → {current[k]}" for k in grown]
        return 1, lines + grow_hint
    if shrunk:
        lines = [f"FAIL: {label} count shrank — a ratchet win, but the baseline must be",
                 "updated in the same PR:",
                 "      " + update_cmd]
        lines += [f"  {k}: {recorded[k]} → {current.get(k, 0)}" for k in shrunk]
        return 1, lines
    total = sum(current.values())
    return 0, [f"OK: {label} count unchanged ({total} across {len(current)} entries)."]


# ── shared text utilities used by the platform probes ───────────────────────

_COMMENT_LINE = re.compile(r"^\s*(//|\*|/\*)")


def strip_comment_matches(grep_lines):
    """Filter 'NN:line' grep-style matches whose line is a comment."""
    return [ln for ln in grep_lines if not _COMMENT_LINE.match(ln.split(":", 1)[-1])]


def walk_files(root, suffixes, exclude_dir_parts=()):
    """All files under root with one of the suffixes, path-sorted, skipping
    any path containing one of exclude_dir_parts."""
    hits = []
    for dirpath, _dirnames, filenames in os.walk(root):
        if any(part in dirpath for part in exclude_dir_parts):
            continue
        for name in filenames:
            if name.endswith(tuple(suffixes)):
                hits.append(os.path.join(dirpath, name))
    return sorted(hits)
