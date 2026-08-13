#!/usr/bin/env python3
"""Guard: string-dup-ratchet.

"The constant is duplicated across the SDK — consolidate into a single
source" is a recurring review ask in the upstream PR history (10 inline
comments). This guard mechanizes the strong-signal core: a string literal
(≥ 6 chars, no interpolation) appearing in **3 or more distinct files** of
PrebidMobile/Swift/ is a duplicated constant. Copying a literal into a
third file is the moment it clearly wants a single definition.

Thresholds were tuned against the tree at landing time: ≥ 2 files yields 21
findings dominated by short JSON keys whose repetition is natural (model +
parser), i.e. false-positive territory; ≥ 3 files yields exactly the real
offenders. Exempt: the stock Xcode `init(coder:)` fatalError boilerplate —
an idiom, not a constant.

Extraction is comment- and multiline-string-aware (the same state-machine
approach as api_baseline._strip_noise, inverted to collect string contents
from code): license headers and doc comments never count.

Ratchet (keyed counts — {literal: file-count} in
baselines/string-dup-counts.json): a literal newly reaching 3 files, or an
existing duplicate spreading further, FAILS ("hoist it next to the existing
constant"); consolidation shrinks the count and must update the baseline in
the same PR — a visible ratchet win.

  update → ./scripts/guards/run-guards.sh --update-string-dup-baseline
"""

import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

BASELINE = os.path.join(ROOT, "scripts", "guards", "baselines", "string-dup-counts.json")
UPDATE_CMD = "./scripts/guards/run-guards.sh --update-string-dup-baseline"
MIN_LENGTH = 6
MIN_FILES = 3
EXEMPT = {"init(coder:) has not been implemented"}  # stock Xcode boilerplate


def string_literals(lines):
    """Contents of single-line string literals in CODE — comments (line and
    block) and multiline-string bodies are excluded, escapes kept verbatim."""
    out = []
    state = {"comment": False, "text3": False}
    for line in lines:
        i, n = 0, len(line)
        while i < n:
            if state["comment"]:
                j = line.find("*/", i)
                if j == -1:
                    break
                state["comment"] = False
                i = j + 2
                continue
            if state["text3"]:
                j = line.find('"""', i)
                if j == -1:
                    break
                state["text3"] = False
                i = j + 3
                continue
            if line.startswith("//", i):
                break
            if line.startswith("/*", i):
                state["comment"] = True
                i += 2
                continue
            if line.startswith('"""', i):
                state["text3"] = True
                i += 3
                continue
            if line[i] == '"':
                i += 1
                buf = []
                while i < n:
                    if line[i] == "\\":
                        buf.append(line[i:i + 2])
                        i += 2
                    elif line[i] == '"':
                        i += 1
                        break
                    else:
                        buf.append(line[i])
                        i += 1
                out.append("".join(buf))
                continue
            i += 1
    return out


def duplicate_counts(root=ROOT):
    """{literal: distinct-file count} for literals in ≥ MIN_FILES files."""
    seen = {}
    src_root = os.path.join(root, "PrebidMobile", "Swift")
    for path in guardlib.walk_files(src_root, (".swift",)):
        with open(path, encoding="utf-8", errors="replace") as fh:
            for lit in set(string_literals(fh.readlines())):
                if len(lit) >= MIN_LENGTH and "\\(" not in lit and lit not in EXEMPT:
                    seen.setdefault(lit, set()).add(path)
    return {lit: len(files) for lit, files in seen.items() if len(files) >= MIN_FILES}


def main(argv):
    current = duplicate_counts()

    if len(argv) > 1 and argv[1] == "--update":
        guardlib.write_keyed_counts(BASELINE, current, guard="string-dup-ratchet")
        print(f"Recorded {len(current)} duplicated literal(s) in "
              "scripts/guards/baselines/string-dup-counts.json")
        return 0

    code, messages = guardlib.check_keyed_counts(
        current, BASELINE, "duplicated string literal", UPDATE_CMD,
        grow_hint=[
            f"A literal now appears in {MIN_FILES}+ files — hoist it next to (or reuse)",
            "the existing constant instead of copying it (recurring review ask).",
        ],
    )
    print("\n".join(messages))
    return code


if __name__ == "__main__":
    sys.exit(guardlib.cli(main)(sys.argv))
