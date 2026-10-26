/*   Copyright 2018-2025 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest
import WebKit

@_spi(PBMInternal) @testable import PrebidMobile

/// Checks the pure helpers of `WebView` and `MRAIDController` against the output of the Objective-C classes they replaced
/// (`PBMWebView`, `PBMMRAIDController`), over a fixed set of inputs. See `WebViewParityExpectations`.
class WebViewParityTests: XCTestCase {

    // Each probe replaces window.mraid completely. Keep one page per test case
    // so the 50 inputs do not repeatedly start and tear down WebKit processes.
    private var propertyProbeWebView: WebView!
    private var propertyProbeWindow: UIWindow?

    private func preparePropertyProbes() throws {
        propertyProbeWebView = WebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        // Keep the probe attached while executing JavaScript, rather than let
        // WebKit suspend an offscreen page between navigation and evaluation.
        let controller = UIViewController()
        controller.view.addSubview(propertyProbeWebView)
        let window = UIWindow(frame: propertyProbeWebView.frame)
        window.rootViewController = controller
        propertyProbeWindow = window
        window.isHidden = false
        // Give the probes a loaded document instead of racing JavaScript against
        // WebKit's initial, implicit about:blank navigation.
        let loaded = XCTNSPredicateExpectation(
            predicate: NSPredicate { [weak self] _, _ in self?.propertyProbeWebView?.state == .loaded },
            object: nil
        )
        propertyProbeWebView.loadHTML("<!doctype html><html><body></body></html>", baseURL: nil, injectMraidJs: false)
        guard XCTWaiter.wait(for: [loaded], timeout: 10) == .completed else {
            throw NSError(domain: "WebViewParityTests", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "The JavaScript probe document did not finish loading"])
        }
    }

    override func tearDown() {
        propertyProbeWebView?.internalWebView.stopLoading()
        propertyProbeWindow?.isHidden = true
        propertyProbeWindow?.rootViewController = nil
        propertyProbeWindow = nil
        propertyProbeWebView = nil
        super.tearDown()
    }

    func testOutputMatchesObjectiveCOriginals() throws {
        let actualLines = WebViewParityDump.dump().split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        let expectedLines = WebViewParityExpectations.expectedForCurrentOS.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)

        // The resize results depend on the screen size; the expectations were captured on a 402x874 pt screen (iPhone 17 / 17 Pro).
        try XCTSkipUnless(actualLines.first == expectedLines.first, "Parity expectations were captured on a different screen size")

        XCTAssertEqual(actualLines.count, expectedLines.count)
        for (actual, expected) in zip(actualLines, expectedLines) {
            XCTAssertEqual(actual, expected)
        }
    }

    /// Runs the JavaScript expressions captured from the Objective-C original through the Swift port.
    func testJavaScriptPropertiesMatchObjectiveCOriginal() throws {
        try preparePropertyProbes()
        let lines = WebViewParityExpectations.javaScriptProperties.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        XCTAssertEqual(lines.count, 50)

        for expectedLine in lines {
            let separatorRange = expectedLine.range(of: " :: ")!
            let head = String(expectedLine[..<separatorRange.lowerBound])
            let arrowRange = head.range(of: " => ")!
            let key = String(head[..<arrowRange.lowerBound])
            let literal = String(head[arrowRange.upperBound...])

            let actualResult: String
            if key.hasPrefix("probe.expand") {
                actualResult = expandProperties(forLiteral: literal).map { "width=\($0.width) height=\($0.height)" } ?? "nil"
            } else {
                actualResult = resizeProperties(forLiteral: literal).map {
                    "width=\($0.width) height=\($0.height) offsetX=\($0.offsetX) offsetY=\($0.offsetY) allowOffscreen=\($0.allowOffscreen ? 1 : 0)"
                } ?? "nil"
            }
            XCTAssertEqual("\(key) => \(literal) :: \(actualResult)", expectedLine)
        }
    }

    /// The JSON properties come from the creative. `JSON.stringify` turns `NaN` and `Infinity` into `null`, and the Objective-C
    /// original then sent `-integerValue`/`-boolValue` to an `NSNull`, an array or a dictionary and crashed the host app with
    /// "unrecognized selector" (probed one at a time, 7 of 7 crashed). The port treats such a value as unusable: the
    /// completion handler gets `nil`.
    func testUnsupportedValueTypesInJSPropertiesAreRejected() throws {
        try preparePropertyProbes()
        let expandLiterals = ["{width:null,height:250}", "{width:{},height:1}", "{width:[1],height:2}", "{width:NaN,height:Infinity}"]
        for literal in expandLiterals {
            XCTAssertNil(expandProperties(forLiteral: literal), literal)
        }

        let resizeLiterals = ["{width:300,height:250,offsetX:1,offsetY:2,allowOffscreen:null}",
                              "{width:300,height:250,offsetX:null,offsetY:2,allowOffscreen:true}",
                              "{width:{a:1},height:250,offsetX:1,offsetY:2,allowOffscreen:true}"]
        for literal in resizeLiterals {
            XCTAssertNil(resizeProperties(forLiteral: literal), literal)
        }
    }

    // MARK: - Helpers

    private func expandProperties(forLiteral literal: String) -> MRAIDExpandProperties? {
        let webView = propertyProbeWebView!
        let setup = expectation(description: "setup")
        webView.internalWebView.evaluateJavaScript("window.mraid = { getExpandProperties: function() { return \(literal); } }; 1;") { _, _ in
            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        var result: MRAIDExpandProperties?
        let done = expectation(description: "done")
        webView.MRAID_getExpandProperties { properties in
            result = properties
            done.fulfill()
        }
        wait(for: [done], timeout: 10)
        return result
    }

    private func resizeProperties(forLiteral literal: String) -> MRAIDResizeProperties? {
        let webView = propertyProbeWebView!
        let setup = expectation(description: "setup")
        webView.internalWebView.evaluateJavaScript("window.mraid = { getResizeProperties: function() { return \(literal); } }; 1;") { _, _ in
            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        var result: MRAIDResizeProperties?
        let done = expectation(description: "done")
        webView.MRAID_getResizeProperties { properties in
            result = properties
            done.fulfill()
        }
        wait(for: [done], timeout: 10)
        return result
    }
}

/// `UIInterfaceOrientationMask` stub for `isOrientationLocked`.
private class ParityMaskViewController: UIViewController {
    var mask: UIInterfaceOrientationMask = .all

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { mask }
}

/// Renders every observable output of the pure helpers as text, the way the throwaway Objective-C dump did.
/// `nil` and `""` print differently.
enum WebViewParityDump {

    static func dump() -> String {
        var lines = [String]()

        func line(_ key: String, _ value: String) {
            lines.append("\(key) => \(value)")
        }

        line("screen", String(format: "%.1fx%.1f", UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height))

        // MARK: isMRAIDLink

        var lonePaddedLink = "mraid:"
        lonePaddedLink += String(repeating: "a", count: 2000 - lonePaddedLink.count)
        // A Swift `String` cannot hold a lone surrogate (it is repaired to U+FFFD on bridging); the key keeps the original units.
        let loneSurrogateLink = String(NSString(characters: Array("mraid:".utf16) + [0xD83D], length: 7))
        let links: [String] = ["mraid:", "mraid:open", "MRAID:open", "mRaid:open", "mraid", "", " mraid:open", "mraid :open",
                               "mraid:\u{301}x", "mraid:\u{200D}", "mraid\u{FF1A}open", "\u{FEFF}mraid:open", "xmraid:open", "mraid:mraid:",
                               "mraid:\u{1F600}", "\u{130}", "mraid:\u{130}", "MRAI\u{130}D:", "mraid;", "mraid:open/%20", "mraid:\n",
                               "mraid:%00", "http://mraid:", "mraid:expand/http://a.com", "mraid\u{301}:open", "m\u{301}raid:open",
                               loneSurrogateLink, "mraid\u{200D}:", "MRAID:", "mraid://", "mraid:?", "about:blank", "https://example.com",
                               "tel:123", "mraid:openx", "mraid:", "mraid:\u{E9}", "mraid:", "mraid: ", "mraid:\t",
                               lonePaddedLink]
        for (index, link) in links.enumerated() {
            let key = link == loneSurrogateLink ? "\"mraid:\\u{D83D}\"" : escape(link)
            line("ctl.isMRAIDLink.\(String(format: "%02d", index)).\(key)", MRAIDController.isMRAIDLink(link) ? "YES" : "NO")
        }

        // MARK: commandFromURL

        let controller = MRAIDController(creative: nil,
                                         viewControllerForPresenting: nil,
                                         webView: nil,
                                         creativeViewDelegate: nil,
                                         downloadBlock: nil)
        let urls = ["mraid:open", "mraid:OPEN", "MRAID:open", "mraid:", "mraid", "", "mraid:bad", "mraid:expand/foo.com",
                    "mraid:expand/foo.com%20bar", "mraid:expand/%", "mraid:expand/%zz", "mraid:expand/%E0%A4%A", "mraid:expand/%C3%A9",
                    "mraid:expand/\u{E9}", "mraid:expand//", "mraid:expand/a/b/c", "mraid:/open", "mraid: open", "mraid:open/",
                    "mraid:playVideo/http%3A%2F%2Fa.com%2Fb.mp4",
                    "mraid:onOrientationPropertiesChanged/%7B%22allowOrientationChange%22%3Atrue%7D",
                    "mraid:ONORIENTATIONPROPERTIESCHANGED", "mraid:\u{130}", "mraid:open\u{2BC}", "mraid:storePicture",
                    "mraid:createCalendarEvent", "mraid:unload", "mraid:log/%0A", "mraid:expand/%00", "mraid:expand/\u{200D}",
                    "mraid:expand/a b", "mraid:expand?x=1", "mraid:open/mraid:close", "mraid:mraid:open", "mraid:open\n",
                    "xmraid:", "http://a/mraid:", "mraid:%6Fpen", "mraid:expand/%C3", "mraid:PLAYVIDEO/x", "mraid:Resize/1/2",
                    "mraid:close/\u{1F600}", "mraid:expand/%F0%9F%98%80", "mraid:LOG", "mraid:OnOrientationPropertiesChanged",
                    "mraid:expand/%25", "mraid:expand/%2F", "mraid:op\u{307}en", "mraid:resize", "mraid:close", "mraid:expand",
                    "mraid:playVideo", "mraid:open/https%3A%2F%2Fa.com%3Fq%3D1%26r%3D2", "mraid:open/a%2Fb", "mraid:Unload",
                    "mraid:expand/%20", "mraid:expand/ ", "mraid:log/a/b/c/d/e", "mraid:CLOSE/", "mraid:storepicture",
                    "mraid:createcalendarevent", "mraid:%", "mraid:o%70en", "mraid:\u{DF}", "mraid:open\u{200D}"]
        for (index, urlString) in urls.enumerated() {
            let url = NSURL(string: urlString) as URL?
            let result: String
            do {
                let command = try controller.command(from: url)
                let arguments = command.arguments.map { escape($0) }.joined(separator: ", ")
                result = "command=\(escape(command.command)) arguments=[\(arguments)]"
            } catch {
                result = "throws reason=\(escape(error.localizedDescription))"
            }
            line("ctl.command.\(String(format: "%02d", index)).\(escape(urlString))", "url=\(url == nil ? "nil" : "set") \(result)")
        }
        do {
            _ = try controller.command(from: nil)
            line("ctl.command.nilurl", "no throw")
        } catch {
            line("ctl.command.nilurl", "throws reason=\(escape(error.localizedDescription))")
        }

        // MARK: CGRectForResizeProperties

        let sizes: [Int] = [Int.min, -1, 0, 49, 50, 51, 320, 375, 700, 1500, Int.max]
        let offsets: [Int] = [Int.min, -1000, -1, 0, 1, 25, 100, 1000, Int.max]
        let frames: [CGRect] = [CGRect(x: 25, y: 25, width: 320, height: 50), .zero, CGRect(x: -100, y: -100, width: 320, height: 50),
                                CGRect(x: 300, y: 700, width: 100, height: 100), CGRect(x: 1e15, y: -1e15, width: 10, height: 10),
                                CGRect(x: 10.7, y: 20.9, width: 30, height: 40), CGRect(x: -10.7, y: -20.9, width: 30, height: 40)]
        let parentFrames: [CGRect] = [CGRect(x: 0, y: 0, width: 400, height: 800), CGRect(x: 15.5, y: 30.25, width: 400, height: 800),
                                      CGRect(x: -50, y: -60, width: 400, height: 800)]
        for (frameIndex, frame) in frames.enumerated() {
            let orphan = UIView(frame: frame)
            let properties = MRAIDResizeProperties(width: 320, height: 250, offsetX: 0, offsetY: 0, allowOffscreen: false)
            line("ctl.resize.orphan.\(frameIndex)", rectText(MRAIDController.cgRect(for: properties, from: orphan)))
        }
        line("ctl.resize.nilproperties", rectText(MRAIDController.cgRect(for: nil, from: UIView())))
        var resizeIndex = 0
        for (sizeIndex, width) in sizes.enumerated() {
            for (offsetIndex, offsetX) in offsets.enumerated() {
                let height = sizes[(sizeIndex + offsetIndex) % sizes.count]
                let offsetY = offsets[(offsetIndex + sizeIndex) % offsets.count]
                for offscreen in 0..<2 {
                    let frame = frames[resizeIndex % frames.count]
                    let parentFrame = parentFrames[(resizeIndex / frames.count) % parentFrames.count]
                    let parent = UIView(frame: parentFrame)
                    let child = UIView(frame: frame)
                    parent.addSubview(child)
                    let properties = MRAIDResizeProperties(width: width, height: height, offsetX: offsetX, offsetY: offsetY, allowOffscreen: offscreen == 1)
                    let key = String(format: "ctl.resize.%03d.w%ld.h%ld.x%ld.y%ld.off%d.f%d", resizeIndex, width, height, offsetX, offsetY, offscreen, resizeIndex % frames.count)
                    line(key, rectText(MRAIDController.cgRect(for: properties, from: child)))
                    resizeIndex += 1
                }
            }
        }
        // huge origins (UIKit rejects NaN frames with a CALayer assertion, so those cannot reach the code)
        let bigs: [CGFloat] = [1e300, -1e300, 1e19, -1e19, 9.3e18]
        for index in 0..<bigs.count {
            let parent = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
            let child = UIView(frame: CGRect(x: bigs[index], y: bigs[(index + 1) % bigs.count], width: 100, height: 100))
            parent.addSubview(child)
            var properties = MRAIDResizeProperties(width: 100, height: 100, offsetX: 5, offsetY: 5, allowOffscreen: true)
            line("ctl.resize.big.\(index).offscreen", rectText(MRAIDController.cgRect(for: properties, from: child)))
            properties = MRAIDResizeProperties(width: 100, height: 100, offsetX: 5, offsetY: 5, allowOffscreen: false)
            line("ctl.resize.big.\(index).onscreen", rectText(MRAIDController.cgRect(for: properties, from: child)))
        }

        // MARK: anyToJSONDict

        var deep = ""
        for _ in 0..<100 { deep += "{\"a\":" }
        deep += "1"
        for _ in 0..<100 { deep += "}" }
        let loneSurrogate = NSString(characters: [0xD800], length: 1)
        // Interpolating it into a Swift `String` would repair it to U+FFFD, so the NSString is built from UTF-16 units.
        let loneSurrogateInString = NSString(characters: Array("{\"a\":\"".utf16) + [0xD800] + Array("\"}".utf16), length: 11)
        let anyInputs: [Any?] = [NSNull(), 1, true, "", "{}", "{ }", "{\"a\":1}", "{\"a\":1.0}",
                                 "{\"a\":true,\"b\":null,\"c\":[1,2,{\"d\":\"e\"}],\"f\":{\"g\":{}}}", "{\"width\":300,\"height\":250}",
                                 "{\"width\":\"300\"}", "{\"a\":1,\"a\":2}", "[]", "[1]", "test", "{", "{\"a\":}", "{'a':1}",
                                 "{\"\u{E9}\":\"\u{FC}\"}", "{\"a\":\"\\u00e9\"}", "{\"a\":\"\u{1F600}\"}",
                                 loneSurrogate, loneSurrogateInString,
                                 "\u{FEFF}{}", " {}", "{}\n", "{} x", "{}{}", "{\"a\":NaN}", "{\"a\":1e999}", "{\"a\":12345678901234567890}",
                                 "{\"a\":-0}", "{\"a\":0.1}", "{\"a\":1E2}", deep, UIView(), ["a": 1], ["{}"],
                                 Data("{}".utf8), "\u{26F5}", "\u{168}", "test{}", NSMutableString(string: "{\"a\":\"b\"}"),
                                 "{\"a\":\"b\"}", "{\"a\":\"\\u0000\"}", "1", "null", "true", "\"str\"", "{\"a\":{\"b\":[]}}",
                                 "{\"offsetX\":-5,\"offsetY\":6,\"allowOffscreen\":false,\"width\":1,\"height\":2}",
                                 "{\"width\":1.9,\"height\":2.1}", "{\"width\":1e2,\"height\":2e0}", "{\"width\":-1,\"height\":0}"]
        line("web.anyToJSONDict.nil", describe(WebView.anyToJSONDict(nil)))
        for (index, value) in anyInputs.enumerated() {
            line("web.anyToJSONDict.\(String(format: "%02d", index))", describe(WebView.anyToJSONDict(value)))
        }

        // MARK: webViewStateDescription

        for rawState in 0..<3 {
            line("web.webViewStateDescription.\(rawState)", escape(WebView.webViewStateDescription(WebViewState(rawValue: rawState)!)))
        }

        // MARK: isVisibleView

        line("web.isVisibleView.nil", yesNo(WebView.isVisibleView(nil)))
        line("web.isVisibleView.plain", yesNo(WebView.isVisibleView(UIView())))
        let window = UIWindow()
        window.isHidden = false
        let parent = UIView()
        let view = UIView()
        line("web.isVisibleView.window", yesNo(WebView.isVisibleView(window)))
        parent.addSubview(view)
        line("web.isVisibleView.parentNoWindow", yesNo(WebView.isVisibleView(view)))
        view.removeFromSuperview()
        window.addSubview(view)
        line("web.isVisibleView.windowChildZeroFrame", yesNo(WebView.isVisibleView(view)))
        let unit = CGRect(x: 0, y: 0, width: 1, height: 1)
        window.frame = unit
        view.frame = unit
        line("web.isVisibleView.unitFrame", yesNo(WebView.isVisibleView(view)))
        window.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.frame = CGRect(x: 101, y: 101, width: 100, height: 100)
        line("web.isVisibleView.outOfRange", yesNo(WebView.isVisibleView(view)))
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.removeFromSuperview()
        parent.addSubview(view)
        window.addSubview(parent)
        line("web.isVisibleView.complexHierarchy", yesNo(WebView.isVisibleView(view)))
        view.isHidden = true
        line("web.isVisibleView.hidden", yesNo(WebView.isVisibleView(view)))
        view.isHidden = false
        view.alpha = 0
        line("web.isVisibleView.alphaZero", yesNo(WebView.isVisibleView(view)))

        // MARK: isOrientationLocked

        let webView = WebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        line("web.orientationLocked.nilvc", yesNo(webView.isOrientationLocked(viewController: nil)))
        for rawMask in 0..<32 {
            let viewController = ParityMaskViewController()
            viewController.mask = UIInterfaceOrientationMask(rawValue: UInt(rawMask))
            line("web.orientationLocked.mask\(String(format: "%02d", rawMask))", yesNo(webView.isOrientationLocked(viewController: viewController)))
        }

        // MARK: buildMraidEnvObject

        let savedCoppa = Targeting.shared.coppa
        let coppaValues: [NSNumber?] = [nil, 0, 1, 2, 1.0, -1]
        for (index, value) in coppaValues.enumerated() {
            Targeting.shared.coppa = value
            // sdk version, bundle id and ifa differ per machine and run; they are masked, the rest is compared literally
            var env = webView.buildMraidEnvObject()
            env = mask(env, pattern: "sdkVersion: '[^']*'", with: "sdkVersion: '<sdk>'")
            env = mask(env, pattern: "appId: '[^']*'", with: "appId: '<app>'")
            env = mask(env, pattern: "ifa: '[^']*'", with: "ifa: '<ifa>'")
            line("web.mraidEnv.coppa.\(index)", escape(env))
        }
        Targeting.shared.coppa = savedCoppa

        return lines.joined(separator: "\n") + "\n"
    }

    // MARK: - Formatting

    private static func yesNo(_ value: Bool) -> String {
        value ? "YES" : "NO"
    }

    private static func rectText(_ rect: CGRect) -> String {
        if rect.isInfinite {
            return "infinite"
        }
        return String(format: "rect(%.6f,%.6f,%.6f,%.6f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
    }

    private static func mask(_ text: String, pattern: String, with replacement: String) -> String {
        text.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
    }

    private static func describe(_ value: Any?) -> String {
        guard let value else {
            return "nil"
        }
        if value is NSNull {
            return "null"
        }
        if let string = value as? String {
            return "str:" + escape(string)
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return "bool:\(number.boolValue ? "true" : "false")"
            }
            return "num:\(String(cString: number.objCType)):\(number.stringValue)"
        }
        if let array = value as? [Any] {
            return "[" + array.map { describe($0) }.joined(separator: ", ") + "]"
        }
        if let dictionary = value as? [String: Any] {
            let parts = dictionary.keys.sorted().map { "\(escape($0))=\(describe(dictionary[$0]))" }
            return "{" + parts.joined(separator: ", ") + "}"
        }
        return "other"
    }

    private static func escape(_ text: String) -> String {
        var output = "\""
        for unit in text.utf16 {
            switch unit {
            case 0x5C: output += "\\\\"
            case 0x22: output += "\\\""
            case 0x0A: output += "\\n"
            case 0x0D: output += "\\r"
            case 0x09: output += "\\t"
            case 0..<0x20, 0x7F...: output += String(format: "\\u{%04X}", unit)
            default: output += String(UnicodeScalar(UInt8(unit)))
            }
        }
        return output + "\""
    }
}
