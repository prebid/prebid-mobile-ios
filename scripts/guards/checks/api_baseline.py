#!/usr/bin/env python3
"""Guard G2: public-api-baseline.

The API surface is a committed, reviewable artifact (the lockfile pattern),
namespaced by exposure path so a baseline diff shows exactly WHICH surface a
change touches. Every declaration is stored as a structured record — no
"kind name" strings to re-parse:

  swift, swift-spi   {parent: {kind: {name: count}}}
                     parent  = declaring type's dotted name path
                               ("(top-level)" for free declarations;
                               extension scopes contribute the EXTENDED
                               type's name, so extension members group
                               with the type they extend)
                     kind    = class/struct/enum/actor/protocol/extension/
                               func/var/let/init/subscript/typealias/
                               associatedtype/case
                     count   = number of declarations sharing the name —
                               two overloads of fetchDemand are count 2, so
                               adding or removing an overload is a visible
                               one-line baseline diff
  objc-header        [path] — public ObjC headers (non-PrivateHeaders .h)
  objc-internal      {kind: {name: count}} — PrivateHeaders
                     @interface/@protocol surface; reachable via the
                     exported __PrebidMobileInternal target; should only
                     SHRINK as the migration deletes ObjC
  spm-product        {manifest: {product: [target]}} — frozen product
                     exports of all three Package.swift manifests

The Swift extractor tracks brace depth (with string literals and comments
stripped) to know the enclosing scope. That also lets it record surface a
flat name scan could not see:

  - members of a `public extension` (implicitly public)
  - requirements of a public protocol (implicitly public)
  - cases of a public enum (implicitly public)

It remains a line-based heuristic, not a parser. Known, accepted misses:
raw strings (#"…"#), nested block comments, several declarations on one
physical line, and string interpolations that themselves contain string
literals. The regenerated baseline is the ground truth to eyeball.

Fails when the snapshot differs from scripts/guards/baselines/public-api.json.
Regenerate intentionally with:  ./scripts/guards/run-guards.sh --update-api-baseline

NOT covered (inherent to Objective-C): @objcMembers runtime reflection —
see the known-trap note in CLAUDE.md.

Unit tests: scripts/guards/tests/test_api_baseline.py
"""

import glob
import os
import re
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(_HERE)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "guards", "lib"))
import guardlib  # noqa: E402

BASELINE = os.path.join(ROOT, "scripts", "guards", "baselines", "public-api.json")
UPDATE_CMD = "./scripts/guards/run-guards.sh --update-api-baseline"
MANIFESTS = ("Package.swift", "PrebidMobile/Package.swift", "EventHandlers/Package.swift")
SECTIONS = ("swift", "swift-spi", "objc-header", "objc-internal", "spm-product")
TOP_LEVEL = "(top-level)"

_KINDS = {
    "class", "protocol", "enum", "struct", "actor", "func", "var", "let",
    "typealias", "extension", "subscript", "associatedtype",
}
# Kinds that open a scope members get attributed to.
_TYPE_KINDS = {"class", "protocol", "enum", "struct", "actor", "extension"}
_ACCESS = {"public", "open", "internal", "fileprivate", "private", "package"}
# Declaration modifiers Swift allows BEFORE the access keyword
# ("dynamic public func fetchDemand", "override public var hash", …).
_MODIFIERS = {
    "final", "override", "dynamic", "static", "class", "required",
    "convenience", "lazy", "weak", "unowned", "mutating", "nonmutating",
    "nonisolated", "indirect", "optional", "prefix", "postfix", "infix",
}
_INIT_RE = re.compile(r"^init[(<]?")
_SUBSCRIPT_RE = re.compile(r"^subscript[(<]")
_NAME_STRIP_RE = re.compile(r"[(<{:].*$")
_CASE_RE = re.compile(r"^(?:indirect[ \t]+)?case[ \t]+(.+)$")


def _strip_noise(line, state):
    """The line with comments and string-literal contents removed, so brace
    counting and declaration matching never see them. `state` carries block
    comments and triple-quoted strings across lines."""
    out = []
    i, n = 0, len(line)
    while i < n:
        if state["comment"]:
            j = line.find("*/", i)
            if j == -1:
                return "".join(out)
            state["comment"] = False
            i = j + 2
            continue
        if state["text3"]:
            j = line.find('"""', i)
            if j == -1:
                return "".join(out)
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
            while i < n:
                if line[i] == "\\":
                    i += 2
                elif line[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
            continue
        out.append(line[i])
        i += 1
    return "".join(out)


def _case_names(rest):
    """Case names from the payload of a `case` line: split on top-level
    commas (associated values keep their inner commas), drop raw values."""
    names, paren, cur = [], 0, ""
    for ch in rest:
        if ch == "(":
            paren += 1
        elif ch == ")":
            paren -= 1
        elif ch == "," and paren == 0:
            names.append(cur)
            cur = ""
            continue
        cur += ch
    names.append(cur)
    out = []
    for n in names:
        n = n.split("=")[0].strip()
        n = _NAME_STRIP_RE.sub("", n).strip()
        if n and not n.startswith("."):  # ".foo" is a switch pattern, not a decl
            out.append(n)
    return out


def swift_decls(lines, include_docs=False):
    """(section, parent, kind, name) records for one Swift file's lines —
    (section, parent, kind, name, documented) when include_docs is True.

    section: "swift" or "swift-spi"
    parent:  dotted path of the enclosing type scopes ("" at top level);
             extension scopes contribute the extended type's name
    kind:    declaration kind ("case" for enum cases)
    documented: a `///` line or a `/** … */` block sits immediately above
             the declaration head (attribute/modifier lines in between OK)
    """
    out = []
    pending = ""
    depth = 0
    stack = []            # enclosing type scopes, innermost last
    pending_scope = None  # type decl seen; its body brace not yet opened
    state = {"comment": False, "text3": False}
    doc_seen = doc_block = False

    for raw in lines:
        in_comment = state["comment"]
        code = _strip_noise(raw, state)
        stripped_raw = raw.strip()
        if stripped_raw.startswith("///"):
            doc_seen = True
        elif stripped_raw.startswith("/**") and not stripped_raw.startswith("/***"):
            doc_block = True
        if doc_block and "*/" in raw:
            doc_seen, doc_block = True, False
        line = code.strip()
        if not line:
            if not stripped_raw:
                pending = ""  # blank line resets carried attributes …
                if not (in_comment or state["comment"] or doc_block):
                    doc_seen = False  # … and breaks doc adjacency
            continue          # … but comment/string-only lines keep them

        joined = (pending + " " + line) if pending else line
        tokens = joined.split()

        kind = name = ""
        access = None
        spi = "@_spi(" in joined
        for i, tok in enumerate(tokens):
            if access is None and tok in _ACCESS:
                access = tok
                continue
            if tok in _KINDS:
                if tok == "class" and i + 1 < len(tokens) and (
                    tokens[i + 1] in _KINDS or _INIT_RE.match(tokens[i + 1])
                ):
                    continue  # `class func` / `class var`: modifier, not a kind
                kind = tok
                if i + 1 < len(tokens):
                    name = tokens[i + 1]
                break
            if _INIT_RE.match(tok):
                kind = name = "init"
                break
            if _SUBSCRIPT_RE.match(tok):
                kind = name = "subscript"
                break

        # a declaration head must start with an attribute, an access keyword,
        # a declaration modifier, or the kind itself
        anchored = bool(tokens) and (
            tokens[0].startswith("@")
            or tokens[0] in _ACCESS
            or tokens[0] in _MODIFIERS
            or tokens[0] in _KINDS
            or _INIT_RE.match(tokens[0])
            or _SUBSCRIPT_RE.match(tokens[0])
        )

        top = stack[-1] if stack else None
        at_body = (top["body_depth"] == depth) if top else (depth == 0)
        parent = ".".join(s["name"] for s in stack)

        recorded = False
        if kind and name and anchored:
            clean = _NAME_STRIP_RE.sub("", name)
            clean = clean[:-1] if clean.endswith(",") else clean
            if clean:
                section = None
                if access in ("public", "open") and at_body:
                    section = "swift-spi" if spi else "swift"
                elif (access is None and top is not None and at_body
                      and top["access"] in ("public", "open")
                      and top["kind"] in ("protocol", "extension")):
                    # public-protocol requirements and `public extension`
                    # members inherit public visibility
                    section = "swift-spi" if (spi or top["spi"]) else "swift"
                if section:
                    record = (section, parent, kind, clean)
                    out.append(record + (doc_seen,) if include_docs else record)
                    recorded = True
                if kind in _TYPE_KINDS:
                    pending_scope = {
                        "name": clean,
                        "kind": kind,
                        "access": access,
                        "spi": spi,
                        "body_depth": None,
                    }
            pending = ""
            doc_seen = False
        elif (not kind and not any(c in line for c in "{}=") and all(
                t.startswith("@") or t in _MODIFIERS or t in _ACCESS
                for t in line.split())):
            # attribute/modifier/access-only line → prepend to the next line
            # (doc adjacency survives the wrap)
            pending = joined
        else:
            pending = ""
            doc_seen = False

        # cases of a public enum are public API
        if (not recorded and top is not None and at_body
                and top["kind"] == "enum" and top["access"] in ("public", "open")):
            m = _CASE_RE.match(line)
            if m:
                section = "swift-spi" if top["spi"] else "swift"
                for c in _case_names(m.group(1)):
                    record = (section, parent, "case", c)
                    out.append(record + (doc_seen,) if include_docs else record)
                doc_seen = False

        for ch in code:
            if ch == "{":
                depth += 1
                if pending_scope is not None:
                    pending_scope["body_depth"] = depth
                    stack.append(pending_scope)
                    pending_scope = None
            elif ch == "}":
                if stack and stack[-1]["body_depth"] == depth:
                    stack.pop()
                depth -= 1
    return out


_OBJC_DECL_RE = re.compile(r"^[ \t]*@(interface|protocol)[ \t]")
_OBJC_FWD_RE = re.compile(r";[ \t]*$")


def objc_internal_decls(lines):
    """(kind, name) records for one PrivateHeaders file."""
    out = []
    for raw in lines:
        if not _OBJC_DECL_RE.match(raw) or _OBJC_FWD_RE.search(raw):
            continue
        entry = re.sub(r"^[ \t]*@", "", raw.rstrip("\r\n"))
        entry = re.sub(r"[ \t]*[:<].*$", "", entry)
        entry = re.sub(r"[ \t]+\(", "(", entry, count=1)
        entry = re.sub(r"[ \t]+$", "", entry)
        kind, _, name = entry.partition(" ")
        if name:
            out.append((kind, name))
    return out


_QUOTED_RE = re.compile(r'"([^"]*)"')


def spm_products(lines, manifest):
    """(manifest, product, target) records for one manifest."""
    out = []
    in_products = False
    product = ""
    for raw in lines:
        if re.search(r"products:[ \t]*\[", raw):
            in_products = True
            continue
        if in_products and raw.startswith("    ],"):
            in_products = False
        if not in_products:
            continue
        if "name:" in raw:
            m = _QUOTED_RE.search(raw)
            if m:
                product = m.group(1)
        if "targets:" in raw:
            tail = re.sub(r".*targets:[ \t]*\[", "", raw)
            for target in _QUOTED_RE.findall(tail):
                out.append((manifest, product, target))
    return out


def _read(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.readlines()


def _counted_tree(pairs):
    """[(kind, name), …] → {kind: {name: count}}, keys sorted."""
    tree = {}
    for kind, name in pairs:
        names = tree.setdefault(kind, {})
        names[name] = names.get(name, 0) + 1
    return {kind: dict(sorted(tree[kind].items())) for kind in sorted(tree)}


def generate(root=ROOT):
    """The five exposure surfaces in the structured-model shape documented
    in the module docstring."""
    scoped = {"swift": {}, "swift-spi": {}}
    for path in guardlib.walk_files(os.path.join(root, "PrebidMobile"), (".swift",)):
        for section, parent, kind, name in swift_decls(_read(path)):
            scoped[section].setdefault(parent or TOP_LEVEL, []).append((kind, name))

    sections = {
        name: {parent: _counted_tree(pairs)
               for parent, pairs in sorted(scoped[name].items())}
        for name in ("swift", "swift-spi")
    }

    objc_root = os.path.join(root, "PrebidMobile", "Objc")
    sections["objc-header"] = guardlib.c_sorted(
        os.path.relpath(path, root)
        for path in guardlib.walk_files(objc_root, (".h",), exclude_dir_parts=("PrivateHeaders",))
    )
    internal = []
    for path in guardlib.walk_files(os.path.join(objc_root, "PrivateHeaders"), (".h",)):
        internal.extend(objc_internal_decls(_read(path)))
    sections["objc-internal"] = _counted_tree(internal)

    products = {}
    for manifest in MANIFESTS:
        path = os.path.join(root, manifest)
        if not os.path.exists(path):
            continue
        for _, product, target in spm_products(_read(path), manifest):
            products.setdefault(manifest, {}).setdefault(product, []).append(target)
    sections["spm-product"] = {
        manifest: {product: guardlib.c_sorted(targets)
                   for product, targets in sorted(entries.items())}
        for manifest, entries in sorted(products.items())
    }
    return sections


def flatten(sections):
    """One '<section> …' line per declaration (counts expanded, so an
    overload added or removed is one +/- line) for human-readable drift
    output."""
    out = []
    for name in ("swift", "swift-spi"):
        for parent, kinds in sections[name].items():
            for kind, names in kinds.items():
                for decl, count in names.items():
                    out.extend([f"{name} [{parent}] {kind} {decl}"] * count)
    for kind, names in sections["objc-internal"].items():
        for decl, count in names.items():
            out.extend([f"objc-internal {kind} {decl}"] * count)
    out.extend(f"objc-header {path}" for path in sections["objc-header"])
    for manifest, entries in sections["spm-product"].items():
        for product, targets in entries.items():
            out.extend(f"spm-product {manifest} {product} -> {t}" for t in targets)
    return sorted(out)


def jazzy_stale(root=ROOT):
    """Paths .jazzy.yaml excludes that no longer exist on disk (advisory)."""
    jazzy = os.path.join(root, ".jazzy.yaml")
    if not os.path.exists(jazzy):
        return []
    stale = []
    for raw in _read(jazzy):
        m = re.match(r"^\s+- (PrebidMobile/.*)$", raw.rstrip("\r\n"))
        if not m:
            continue
        p = m.group(1)
        if "*" in p:
            if not glob.glob(os.path.join(root, p)):
                stale.append(p)
        elif not os.path.exists(os.path.join(root, p)):
            stale.append(p)
    return stale


def _valid_shape(sections):
    return all(
        isinstance(sections.get(name), list if name == "objc-header" else dict)
        for name in SECTIONS
    )


def main(argv):
    current = generate()

    if len(argv) > 1 and argv[1] == "--update":
        guardlib.dump_json(BASELINE, current)
        total = len(flatten(current))
        print(f"Regenerated {total} baseline entries in scripts/guards/baselines/public-api.json")
        print("Commit the diff in the same PR as the API change, and call it out for review.")
        return 0

    baseline_sections = guardlib.load_json(BASELINE, UPDATE_CMD)

    try:
        if not _valid_shape(baseline_sections):
            raise TypeError("section shape mismatch")
        baseline_flat = flatten(baseline_sections)
    except (TypeError, AttributeError):
        print("FAIL: the baseline does not match the structured-model format")
        print("(section -> parent -> kind -> name -> count). Regenerate it with:")
        print("      " + UPDATE_CMD)
        return 1

    drift = guardlib.lockfile_diff(baseline_flat, flatten(current))
    if drift:
        print("FAIL: the API surface changed but the baseline was not updated.")
        print()
        print("\n".join(drift))
        print()
        print("Line shape: <section> [<declaring type>] <kind> <name> — swift = public API,")
        print("swift-spi = @_spi surface, objc-internal = PrivateHeaders (should only shrink),")
        print("spm-product = exported targets. Overloads appear once per overload.")
        print()
        print("If this change is intentional, regenerate the baseline and commit it:")
        print("      " + UPDATE_CMD)
        print("If it is not intentional, adjust the access level (public/open → internal)")
        print("or revert the manifest/header change.")
        return 1

    stale = jazzy_stale()
    if stale:
        print("ADVISORY: .jazzy.yaml excludes paths that no longer exist (docs-config drift):")
        print("\n".join(guardlib.c_sorted(stale)))

    print("OK: API surface matches the committed baseline.")
    return 0


if __name__ == "__main__":
    sys.exit(guardlib.cli(main)(sys.argv))
