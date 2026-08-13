"""Unit tests for the adapter-isolation and swift-migration-direction
check logic (the parsing/classification parts; the git/filesystem walking
is exercised by the guard suite itself)."""

import os
import sys
import unittest

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_HERE, "..", "checks"))
sys.path.insert(0, os.path.join(_HERE, "..", "lib"))

import adapter_isolation  # noqa: E402
import deprecation_hygiene  # noqa: E402
import api_naming  # noqa: E402
import api_test_presence  # noqa: E402
import ortb_test_presence  # noqa: E402
import swift_migration_direction  # noqa: E402


class MigrationClassifyTests(unittest.TestCase):
    def test_three_way_classification(self):
        ungranted, used, stale = swift_migration_direction.classify(
            added=["Objc/New.m", "Objc/Granted.m"],
            granted=["Objc/Granted.m", "Objc/Merged.m"],
        )
        self.assertEqual(ungranted, ["Objc/New.m"])
        self.assertEqual(used, ["Objc/Granted.m"])
        self.assertEqual(stale, ["Objc/Merged.m"])


class OrtbDiscoveryTests(unittest.TestCase):
    def _tree(self, tmp, model_dir_rel, extra_files=()):
        model_dir = os.path.join(tmp, "PrebidMobile", model_dir_rel)
        os.makedirs(model_dir)
        with open(os.path.join(model_dir, "ORTBProbe.swift"), "w") as fh:
            fh.write("class ORTBProbe {}\n")
        for name in extra_files:
            with open(os.path.join(model_dir, name), "w") as fh:
                fh.write("// not a model\n")
        tests_dir = os.path.join(tmp, "PrebidMobileTests")
        os.makedirs(tests_dir)
        return tests_dir

    def test_models_discovered_by_name_wherever_they_live(self):
        import tempfile
        with tempfile.TemporaryDirectory() as tmp:
            # a directory layout the guard has never heard of — the ORTB* file
            # name, not the path, is what puts a model in scope
            tests_dir = self._tree(tmp, os.path.join("Swift", "NewLayout", "Models"),
                                    extra_files=("RequestBuilder.swift",))
            with open(os.path.join(tests_dir, "ProbeTests.swift"), "w") as fh:
                fh.write("final class ProbeTests { let x = ORTBProbe() }\n")
            models = ortb_test_presence.model_files(tmp)
            self.assertEqual([os.path.basename(m) for m in models], ["ORTBProbe.swift"])
            self.assertEqual(ortb_test_presence.violations(models, tmp), [])

    def test_unreferenced_model_is_a_violation(self):
        import tempfile
        with tempfile.TemporaryDirectory() as tmp:
            self._tree(tmp, os.path.join("Swift", "Anywhere"))
            models = ortb_test_presence.model_files(tmp)
            self.assertEqual(
                ortb_test_presence.violations(models, tmp),
                [os.path.join("PrebidMobile", "Swift", "Anywhere", "ORTBProbe.swift")],
            )

    def test_empty_scope_fails_instead_of_passing(self):
        import tempfile
        with tempfile.TemporaryDirectory() as tmp:
            os.makedirs(os.path.join(tmp, "PrebidMobile", "Swift"))
            self.assertEqual(ortb_test_presence.main([], root=tmp), 1)


class AdapterIsolationTests(unittest.TestCase):
    def test_seam_regex(self):
        for bad in ("import __PrebidMobileInternal",
                    "@_spi(PBMInternal) import PrebidMobile",
                    '#include "PrivateHeaders/PBMThing.h"'):
            self.assertTrue(adapter_isolation._SEAM_RE.search(bad), bad)
        self.assertFalse(adapter_isolation._SEAM_RE.search("import PrebidMobile"))

    def test_pbm_token_and_rename_extraction(self):
        line = '@objc(PBMBannerView) public class BannerView { let x = PBMConstants.key }'
        self.assertEqual(adapter_isolation._OBJC_RENAME_RE.findall(line), ["PBMBannerView"])
        self.assertEqual(
            adapter_isolation._PBM_RE.findall(line), ["PBMBannerView", "PBMConstants"]
        )

    def test_comment_lines_do_not_count_as_usage(self):
        self.assertTrue(adapter_isolation._COMMENT_RE.match("  // PBMInternalThing docs"))
        self.assertTrue(adapter_isolation._COMMENT_RE.match(" * PBMInternalThing docs"))
        self.assertFalse(adapter_isolation._COMMENT_RE.match("let x = PBMInternalThing()"))


if __name__ == "__main__":
    unittest.main()


class DeprecationHygieneTests(unittest.TestCase):
    def viol(self, src):
        import deprecation_hygiene
        return deprecation_hygiene.file_violations(src.splitlines(keepends=True))

    def test_deprecated_without_message_flagged(self):
        self.assertEqual(len(self.viol('@available(*, deprecated)\npublic func old() {}\n')), 1)

    def test_bare_unavailable_not_flagged(self):
        # the idiomatic private-init blocker has no replacement to name
        self.assertEqual(self.viol('@available(*, unavailable)\nprivate override init() {}\n'), [])

    def test_message_satisfies(self):
        self.assertEqual(self.viol('@available(*, deprecated, message: "Use new() instead")\n'), [])

    def test_renamed_satisfies(self):
        self.assertEqual(self.viol('@available(*, deprecated, renamed: "fetchDemand(request:)")\n'), [])

    def test_empty_message_flagged(self):
        self.assertEqual(len(self.viol('@available(*, deprecated, message: "")\n')), 1)

    def test_plain_availability_ignored(self):
        self.assertEqual(self.viol('@available(iOS 13.0, *)\npublic func fine() {}\n'), [])

    def test_wrapped_attribute_joined(self):
        src = '@available(\n    *, deprecated,\n    message: "Use the new initializer"\n)\nfunc old() {}\n'
        self.assertEqual(self.viol(src), [])
        src_bad = '@available(\n    *, deprecated\n)\nfunc old() {}\n'
        hits = self.viol(src_bad)
        self.assertEqual([ln for ln, _ in hits], [1])

    def test_comment_lines_ignored(self):
        self.assertEqual(self.viol('// @available(*, deprecated)\n'), [])


class ApiNamingTests(unittest.TestCase):
    def test_violation_extraction(self):
        import api_naming
        sections = {"swift": {
            "(top-level)": {"class": {"PBMLeftover": 1, "BannerView": 1},
                            "let": {"PBMMediationConfigIdKey": 1}},
            "PBMExtended": {"func": {"helper": 1}},
            "PBMLeftover": {"var": {"x": 1}},
        }}
        self.assertEqual(api_naming.violations(sections), [
            "class PBMLeftover",       # declared PBM name flagged once, not also as parent
            "parent PBMExtended",      # extension-of-ObjC-type scope
        ])

    def test_mediation_prefix_exempt_and_spi_ignored(self):
        import api_naming
        sections = {"swift": {"(top-level)": {"let": {"PBMMediationAdUnitBidKey": 1}}},
                    "swift-spi": {"(top-level)": {"class": {"PBMInternalThing": 1}}}}
        self.assertEqual(api_naming.violations(sections), [])


class ApiTestPresenceTests(unittest.TestCase):
    def test_public_types_from_all_scopes(self):
        import api_test_presence
        sections = {"swift": {
            "(top-level)": {"class": {"AdUnit": 1}, "func": {"helper": 1}},
            "Outer": {"struct": {"Inner": 1}, "var": {"x": 1}},
        }}
        self.assertEqual(api_test_presence.public_types(sections), ["AdUnit", "Inner"])

    def test_untested_and_empty_scope(self):
        import api_test_presence, tempfile
        with tempfile.TemporaryDirectory() as tmp:
            tests_dir = os.path.join(tmp, "PrebidMobileTests")
            os.makedirs(os.path.join(tmp, "scripts", "guards", "baselines"))
            os.makedirs(os.path.join(tmp, "scripts", "guards", "allowlists"))
            os.makedirs(tests_dir)
            with open(os.path.join(tests_dir, "T.swift"), "w") as fh:
                fh.write("final class T { let a = AdUnit() }\n")
            self.assertEqual(api_test_presence.untested(["AdUnit", "Orphan"], tmp), ["Orphan"])
            # empty type scope must FAIL, not pass
            import json
            with open(os.path.join(tmp, "scripts", "guards", "baselines", "public-api.json"), "w") as fh:
                json.dump({"swift": {}}, fh)
            self.assertEqual(api_test_presence.main([], root=tmp), 1)


class StringDupTests(unittest.TestCase):
    def lits(self, src):
        import string_dup_ratchet
        return string_dup_ratchet.string_literals(src.splitlines(keepends=True))

    def test_code_literal_extracted(self):
        self.assertEqual(self.lits('let k = "hb_cache_id"\n'), ["hb_cache_id"])

    def test_comment_literals_ignored(self):
        self.assertEqual(self.lits('// "not code"\n/* "also not" */ let x = "yes"\n'), ["yes"])

    def test_block_comment_spanning_lines_ignored(self):
        self.assertEqual(self.lits('/* license\n "Apache License"\n*/\nlet a = "real"\n'), ["real"])

    def test_multiline_string_body_ignored(self):
        self.assertEqual(self.lits('let t = """\n"inner fake"\n"""\nlet b = "outer"\n'), ["outer"])

    def test_escapes_kept(self):
        self.assertEqual(self.lits('let s = "a\\"b"\n'), ['a\\"b'])


class SkiplistEnumerationTests(unittest.TestCase):
    def test_identifiers_target_prefixed_and_sorted(self):
        import skiplist_ratchet, tempfile, json
        plan = {"testTargets": [{"target": {"name": "T"},
                                 "skippedTests": ["B/b()", "A/a()"]}]}
        with tempfile.NamedTemporaryFile("w", suffix=".xctestplan", delete=False) as fh:
            json.dump(plan, fh); path = fh.name
        try:
            self.assertEqual(skiplist_ratchet.skipped_identifiers(path),
                             ["T/A/a()", "T/B/b()"])
        finally:
            os.unlink(path)


class SeamCommentFilterTests(unittest.TestCase):
    def test_doc_comment_mentioning_spi_not_a_seam(self):
        self.assertIsNotNone(adapter_isolation._SEAM_RE.search("// never use @_spi(X)"))
        self.assertTrue(adapter_isolation._COMMENT_RE.match("// never use @_spi(X)"))
        # the filter combination seam_hits applies:
        line = "/// Adapters must not import __PrebidMobileInternal."
        self.assertTrue(adapter_isolation._COMMENT_RE.match(line))
