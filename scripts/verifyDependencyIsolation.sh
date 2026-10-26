#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Keep published consumer requirements out of the native development graph.
python3 - <<'PY'
import json
import subprocess
from pathlib import Path
import xml.etree.ElementTree as ET


def project(path):
    return json.loads(subprocess.check_output([
        "plutil", "-convert", "json", "-o", "-", str(path / "project.pbxproj")
    ]))


def require(condition, message):
    if not condition:
        raise SystemExit(message)


workspace = ET.parse("PrebidMobile.xcworkspace/contents.xcworkspacedata")
consumer = Path("Example/PrebidDemo/PrebidDemoSPM.xcodeproj")
native_ids = set()
for ref in workspace.iter("FileRef"):
    location = ref.attrib["location"]
    require(location.startswith("group:"), "Expected a repository-relative native project")
    path = Path(location.removeprefix("group:"))
    require(path != consumer, "The SPM consumer must stay outside the native workspace")
    data = project(path)
    native_ids.update(data["objects"])
    for obj in data["objects"].values():
        if obj["isa"] == "PBXNativeTarget":
            require(obj["name"] != "PrebidDemoSPM", "Move the SPM target to its standalone project")
        if obj["isa"] == "XCRemoteSwiftPackageReference":
            url = obj["repositoryURL"]
            require("prebid-mobile-ios-sdk" not in url and "prebid-mobile-ios-adapters" not in url,
                    f"Published Prebid package in native graph: {path}: {url}")

data = project(consumer)
require(not native_ids.intersection(data["objects"]), "The standalone project must have independent IDs")
objects = data["objects"].values()
require([o["name"] for o in objects if o["isa"] == "PBXNativeTarget"] == ["PrebidDemoSPM"],
        "The consumer project must contain only the SPM demo")
urls = [o["repositoryURL"] for o in objects if o["isa"] == "XCRemoteSwiftPackageReference"]
require(any("prebid-mobile-ios-adapters" in url for url in urls), "Missing published adapters dependency")
require(not any("google-mobile-ads" in url or "AppLovin" in url for url in urls),
        "The consumer must inherit Google and AppLovin requirements from the adapters package")
print("Native and published consumer package graphs are separate")
PY
