"""Unit tests for the api_baseline extractor.

Run: python3 -m unittest discover -s scripts/guards/tests
Also run in CI (guards.yml) so a weakened extractor fails there rather than
silently narrowing the tracked surface.
"""

import os
import sys
import unittest

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_HERE, "..", "checks"))
sys.path.insert(0, os.path.join(_HERE, "..", "lib"))

import api_baseline  # noqa: E402
import guardlib  # noqa: E402


def swift(src):
    return api_baseline.swift_decls(src.splitlines(keepends=True))


class SwiftExtractorTests(unittest.TestCase):
    def test_single_line_public_class(self):
        self.assertEqual(swift("public class Foo {}\n"), [("swift", "", "class", "Foo")])

    def test_internal_class_ignored(self):
        self.assertEqual(swift("class Foo {}\n"), [])

    def test_open_and_modifiers(self):
        self.assertEqual(swift("open class Bar: NSObject {}\n"), [("swift", "", "class", "Bar")])
        self.assertEqual(swift("public final class Baz {}\n"), [("swift", "", "class", "Baz")])

    def test_spi_same_line(self):
        self.assertEqual(
            swift("@_spi(PBMInternal) public class Hidden {}\n"),
            [("swift-spi", "", "class", "Hidden")],
        )

    def test_spi_wrapped_attribute_line(self):
        src = "@_spi(PBMInternal)\npublic class Hidden {}\n"
        self.assertEqual(swift(src), [("swift-spi", "", "class", "Hidden")])

    def test_head_wrapped_after_public(self):
        # the Factory.swift shape the single-line extractor missed entirely
        src = "@objc(PBMFactory) @_spi(PBMInternal) public\nclass Factory: NSObject {}\n"
        self.assertEqual(swift(src), [("swift-spi", "", "class", "Factory")])

    def test_objcmembers_wrapped_public_class(self):
        # the DisplayView.swift shape: @objcMembers public / class on next line
        src = "@objc(PBMDisplayView)\n@objcMembers public\nclass DisplayView: UIView {}\n"
        self.assertEqual(swift(src), [("swift", "", "class", "DisplayView")])

    def test_bare_public_wrapped_before_decl(self):
        # the AdViewManagerDelegate.swift shape: "public" alone on its line
        src = "@objc(PBMAdViewManagerDelegate)\npublic\nprotocol AdViewManagerDelegate {}\n"
        self.assertEqual(swift(src), [("swift", "", "protocol", "AdViewManagerDelegate")])

    def test_comment_between_attribute_and_decl(self):
        src = "@_spi(PBMInternal)\n// doc-ish comment\npublic func hidden() {}\n"
        self.assertEqual(swift(src), [("swift-spi", "", "func", "hidden")])

    def test_blank_line_resets_pending_attributes(self):
        src = "@_spi(PBMInternal)\n\npublic class NotSPI {}\n"
        self.assertEqual(swift(src), [("swift", "", "class", "NotSPI")])

    def test_generic_and_inheritance_stripped_from_name(self):
        self.assertEqual(swift("public struct Box<T> {}\n"), [("swift", "", "struct", "Box")])
        self.assertEqual(swift("public class A: B {}\n"), [("swift", "", "class", "A")])

    def test_modifier_before_access_keyword(self):
        self.assertEqual(
            swift("dynamic public func fetchDemand(request: Request) {}\n"),
            [("swift", "", "func", "fetchDemand")],
        )
        self.assertEqual(
            swift("override public var hash: Int { 0 }\n"),
            [("swift", "", "var", "hash")],
        )
        self.assertEqual(swift("final public class Foo {}\n"), [("swift", "", "class", "Foo")])
        self.assertEqual(
            swift("static public let shared = Foo()\n"), [("swift", "", "let", "shared")]
        )

    def test_modifier_head_wrapped_before_decl(self):
        self.assertEqual(swift("final public\nclass Wrapped {}\n"),
                         [("swift", "", "class", "Wrapped")])

    def test_modifier_without_access_is_ignored(self):
        self.assertEqual(swift("override func internalThing() {}\n"), [])
        self.assertEqual(swift("final class Foo {}\n"), [])

    def test_class_func_is_a_func_not_a_class(self):
        self.assertEqual(swift("public class func make() -> Self {}\n"),
                         [("swift", "", "func", "make")])

    def test_public_subscript(self):
        self.assertEqual(swift("public subscript(index: Int) -> Int { 0 }\n"),
                         [("swift", "", "subscript", "subscript")])


class ScopeTrackingTests(unittest.TestCase):
    def test_members_scoped_to_declaring_type(self):
        src = (
            "public class AdUnit {\n"
            "    public func fetchDemand(completion: @escaping () -> Void) {}\n"
            "    var internalThing = 0\n"
            "}\n"
        )
        self.assertEqual(swift(src), [
            ("swift", "", "class", "AdUnit"),
            ("swift", "AdUnit", "func", "fetchDemand"),
        ])

    def test_overloads_preserved_as_duplicates(self):
        src = (
            "public class AdUnit {\n"
            "    public func fetchDemand(a: Int) {}\n"
            "    public func fetchDemand(a: Int, b: Int) {}\n"
            "}\n"
        )
        self.assertEqual(
            [f"{k} {n}" for _, _, k, n in swift(src)],
            ["class AdUnit", "func fetchDemand", "func fetchDemand"],
        )

    def test_nested_type_uses_dotted_path(self):
        src = (
            "public class Outer {\n"
            "    public struct Inner {\n"
            "        public var x: Int\n"
            "    }\n"
            "    public var y: Int = 0\n"
            "}\n"
        )
        self.assertEqual(swift(src), [
            ("swift", "", "class", "Outer"),
            ("swift", "Outer", "struct", "Inner"),
            ("swift", "Outer.Inner", "var", "x"),
            ("swift", "Outer", "var", "y"),
        ])

    def test_decls_inside_function_bodies_not_recorded(self):
        src = (
            "public class Foo {\n"
            "    public func work() {\n"
            "        let helper = { print(0) }\n"
            "        helper()\n"
            "    }\n"
            "    public var after: Int = 0\n"
            "}\n"
        )
        self.assertEqual([f"{k} {n}" for _, _, k, n in swift(src)],
                         ["class Foo", "func work", "var after"])

    def test_braces_in_string_literals_do_not_break_scoping(self):
        src = (
            "public class Foo {\n"
            "    let json = \"{\\\"k\\\": \\\"}}{{v\\\"}\"\n"
            "    public func after() {}\n"
            "}\n"
        )
        self.assertEqual(swift(src), [
            ("swift", "", "class", "Foo"),
            ("swift", "Foo", "func", "after"),
        ])

    def test_block_comment_hides_declarations(self):
        src = "/*\npublic class Hidden {}\n*/\npublic class Visible {}\n"
        self.assertEqual(swift(src), [("swift", "", "class", "Visible")])

    def test_multiline_string_hides_declarations(self):
        src = 'let t = """\npublic class NotReal {\n"""\npublic class Real {}\n'
        self.assertEqual(swift(src), [("swift", "", "class", "Real")])


class ImplicitVisibilityTests(unittest.TestCase):
    def test_public_protocol_requirements_recorded(self):
        src = (
            "public protocol Handler: NSObjectProtocol {\n"
            "    func handle(_ x: Int)\n"
            "    var isReady: Bool { get }\n"
            "    init(config: String)\n"
            "}\n"
        )
        self.assertEqual(swift(src), [
            ("swift", "", "protocol", "Handler"),
            ("swift", "Handler", "func", "handle"),
            ("swift", "Handler", "var", "isReady"),
            ("swift", "Handler", "init", "init"),
        ])

    def test_internal_protocol_requirements_not_recorded(self):
        src = "protocol Quiet {\n    func hidden()\n}\n"
        self.assertEqual(swift(src), [])

    def test_public_extension_members_recorded(self):
        src = (
            "public extension AdUnit {\n"
            "    func helper() {}\n"
            "    private func reallyHidden() {}\n"
            "}\n"
        )
        self.assertEqual(swift(src), [
            ("swift", "", "extension", "AdUnit"),
            ("swift", "AdUnit", "func", "helper"),
        ])

    def test_plain_extension_needs_explicit_access(self):
        src = (
            "extension AdUnit {\n"
            "    public func visible() {}\n"
            "    func hidden() {}\n"
            "}\n"
        )
        self.assertEqual(swift(src), [("swift", "AdUnit", "func", "visible")])

    def test_private_extension_members_not_recorded(self):
        src = "private extension Foo {\n    func x() {}\n}\n"
        self.assertEqual(swift(src), [])

    def test_public_enum_cases_recorded(self):
        src = (
            "public enum AdFormat {\n"
            "    case banner\n"
            "    case video(Int), native\n"
            "    case raw = \"r\"\n"
            "}\n"
        )
        self.assertEqual(swift(src), [
            ("swift", "", "enum", "AdFormat"),
            ("swift", "AdFormat", "case", "banner"),
            ("swift", "AdFormat", "case", "video"),
            ("swift", "AdFormat", "case", "native"),
            ("swift", "AdFormat", "case", "raw"),
        ])

    def test_switch_cases_inside_methods_not_recorded(self):
        src = (
            "public enum E {\n"
            "    case a\n"
            "    public func f() {\n"
            "        switch self {\n"
            "        case .a: break\n"
            "        }\n"
            "    }\n"
            "}\n"
        )
        self.assertEqual([f"{k} {n}" for _, _, k, n in swift(src)], ["enum E", "case a", "func f"])

    def test_internal_enum_cases_not_recorded(self):
        src = "enum E {\n    case a\n}\n"
        self.assertEqual(swift(src), [])

    def test_spi_extension_members_land_in_spi_section(self):
        src = (
            "@_spi(PBMInternal) public extension Foo {\n"
            "    func seam() {}\n"
            "}\n"
        )
        self.assertEqual(swift(src), [
            ("swift-spi", "", "extension", "Foo"),
            ("swift-spi", "Foo", "func", "seam"),
        ])


class ObjcInternalTests(unittest.TestCase):
    def objc(self, src):
        return api_baseline.objc_internal_decls(src.splitlines(keepends=True))

    def test_plain_interface(self):
        self.assertEqual(self.objc("@interface PBMFoo : NSObject\n"),
                         [("interface", "PBMFoo")])

    def test_name_ending_in_t_is_not_truncated(self):
        # regression: BSD sed's [ \t] treated \t as a literal 't' and produced
        # "PBMORTBAbstrac" in the original baseline
        self.assertEqual(self.objc("@interface PBMORTBAbstract : NSObject\n"),
                         [("interface", "PBMORTBAbstract")])

    def test_category_space_collapsed(self):
        self.assertEqual(self.objc("@interface NSString (PBMExtensions)\n"),
                         [("interface", "NSString(PBMExtensions)")])

    def test_forward_declaration_excluded(self):
        self.assertEqual(self.objc("@protocol PBMSomething;\n"), [])

    def test_protocol_with_conformance(self):
        self.assertEqual(self.objc("@protocol PBMTimerInterface <NSObject>\n"),
                         [("protocol", "PBMTimerInterface")])


class SpmProductTests(unittest.TestCase):
    MANIFEST = """\
let package = Package(
    name: "PrebidMobile",
    products: [
        .library(
            name: "PrebidMobile",
            targets: ["PrebidMobile", "__PrebidMobileInternal"]
        ),
    ],
    targets: [
        .target(name: "NotAProduct", dependencies: ["X"]),
    ]
)
"""

    def test_products_extracted_targets_section_ignored(self):
        got = api_baseline.spm_products(self.MANIFEST.splitlines(keepends=True), "Package.swift")
        self.assertEqual(got, [
            ("Package.swift", "PrebidMobile", "PrebidMobile"),
            ("Package.swift", "PrebidMobile", "__PrebidMobileInternal"),
        ])


class SectionShapeTests(unittest.TestCase):
    SECTIONS = {
        "swift": {
            "(top-level)": {"class": {"A": 1}},
            "A": {"func": {"b": 2}},
        },
        "swift-spi": {"(top-level)": {"class": {"Hidden": 1}}},
        "objc-header": [],
        "objc-internal": {"interface": {"PBMX": 1}},
        "spm-product": {"Package.swift": {"P": ["T"]}},
    }

    def test_counted_tree(self):
        self.assertEqual(
            api_baseline._counted_tree([("func", "b"), ("var", "a"), ("func", "b")]),
            {"func": {"b": 2}, "var": {"a": 1}},
        )

    def test_flatten_expands_counts_and_names_parents(self):
        self.assertEqual(api_baseline.flatten(self.SECTIONS), [
            "objc-internal interface PBMX",
            "spm-product Package.swift P -> T",
            "swift [(top-level)] class A",
            "swift [A] func b",
            "swift [A] func b",
            "swift-spi [(top-level)] class Hidden",
        ])

    def test_valid_shape(self):
        self.assertTrue(api_baseline._valid_shape(self.SECTIONS))
        flat_swift = dict(self.SECTIONS, swift=["class A"])  # pre-model layout
        self.assertFalse(api_baseline._valid_shape(flat_swift))


class GuardlibTests(unittest.TestCase):
    def test_ratchet_new_and_stale(self):
        new, stale = guardlib.ratchet(["a", "b"], ["b", "c"])
        self.assertEqual(new, ["a"])
        self.assertEqual(stale, ["c"])

    def test_lockfile_diff_shape(self):
        drift = guardlib.lockfile_diff(["one", "two"], ["one", "three"])
        self.assertEqual(sorted(drift), ["+three", "-two"])
        self.assertEqual(guardlib.lockfile_diff(["same"], ["same"]), [])

    def test_lockfile_diff_sees_duplicate_count_changes(self):
        # two overloads → one: the removal must be visible
        drift = guardlib.lockfile_diff(["func f", "func f"], ["func f"])
        self.assertEqual(drift, ["-func f"])

    def test_check_count_directions(self):
        import tempfile
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as fh:
            fh.write("5\n")
            path = fh.name
        try:
            code, _ = guardlib.check_count(5, path, "probe", "cmd", [])
            self.assertEqual(code, 0)
            code, msgs = guardlib.check_count(6, path, "probe", "cmd", ["hint"])
            self.assertEqual(code, 1)
            self.assertIn("grew", msgs[0])
            code, msgs = guardlib.check_count(4, path, "probe", "cmd", [])
            self.assertEqual(code, 1)
            self.assertIn("shrank", msgs[0])
        finally:
            os.unlink(path)


if __name__ == "__main__":
    unittest.main()


class DocDetectionTests(unittest.TestCase):
    def docs(self, src):
        return api_baseline.swift_decls(src.splitlines(keepends=True), include_docs=True)

    def test_triple_slash_documents(self):
        got = self.docs("/// Fetches demand.\npublic func fetchDemand() {}\n")
        self.assertEqual(got, [("swift", "", "func", "fetchDemand", True)])

    def test_undocumented(self):
        got = self.docs("public func fetchDemand() {}\n")
        self.assertEqual(got, [("swift", "", "func", "fetchDemand", False)])

    def test_doc_block_documents(self):
        got = self.docs("/**\n Fetches demand.\n */\npublic func fetchDemand() {}\n")
        self.assertEqual(got, [("swift", "", "func", "fetchDemand", True)])

    def test_attribute_between_doc_and_decl_keeps_doc(self):
        got = self.docs("/// Docs.\n@objc\npublic func f() {}\n")
        self.assertEqual(got, [("swift", "", "func", "f", True)])

    def test_blank_line_breaks_doc_adjacency(self):
        got = self.docs("/// Docs.\n\npublic func f() {}\n")
        self.assertEqual(got, [("swift", "", "func", "f", False)])

    def test_doc_consumed_by_first_decl_only(self):
        src = "/// Docs.\npublic class A {\n    public var x: Int = 0\n}\n"
        got = self.docs(src)
        self.assertEqual(got, [
            ("swift", "", "class", "A", True),
            ("swift", "A", "var", "x", False),
        ])

    def test_plain_comment_is_not_documentation(self):
        got = self.docs("// not a doc comment\npublic func f() {}\n")
        self.assertEqual(got, [("swift", "", "func", "f", False)])

    def test_default_call_shape_unchanged(self):
        got = api_baseline.swift_decls(["/// d\n", "public func f() {}\n"])
        self.assertEqual(got, [("swift", "", "func", "f")])


class KeyedCountTests(unittest.TestCase):
    def test_roundtrip_and_verdicts(self):
        import tempfile
        with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as fh:
            fh.write("a.swift 2\nb.swift 1\n")
            path = fh.name
        try:
            self.assertEqual(guardlib.read_keyed_counts(path), {"a.swift": 2, "b.swift": 1})
            code, _ = guardlib.check_keyed_counts({"a.swift": 2, "b.swift": 1}, path, "probe", "cmd", [])
            self.assertEqual(code, 0)
            code, msgs = guardlib.check_keyed_counts({"a.swift": 3, "b.swift": 1}, path, "probe", "cmd", ["hint"])
            self.assertEqual(code, 1)
            self.assertIn("a.swift: 2 → 3", "\n".join(msgs))
            code, msgs = guardlib.check_keyed_counts({"a.swift": 2, "b.swift": 1, "c.swift": 1}, path, "probe", "cmd", [])
            self.assertEqual(code, 1)  # new key = growth
            code, msgs = guardlib.check_keyed_counts({"a.swift": 2}, path, "probe", "cmd", [])
            self.assertEqual(code, 1)  # disappeared key = shrink, needs update
            self.assertIn("shrank", msgs[0])
        finally:
            os.unlink(path)

    def test_format_drops_zero_counts(self):
        self.assertEqual(guardlib.format_keyed_counts({"a": 1, "b": 0}), ["a 1"])
