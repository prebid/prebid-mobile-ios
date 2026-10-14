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
import CoreLocation

@_spi(PBMInternal) @testable import PrebidMobile

/// Checks `MRAIDJavascriptCommands`, `MRAIDCommand` and `HTMLFormatter` against the output of the Objective-C classes
/// they replaced, over a fixed set of inputs. See `MRAIDParityExpectations`.
class MRAIDParityTests: XCTestCase {

    func testOutputMatchesObjectiveCOriginals() {
        let actualLines = MRAIDParityDump.dump().split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        let expectedLines = MRAIDParityExpectations.expected.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)

        XCTAssertEqual(actualLines.count, expectedLines.count)
        for (actual, expected) in zip(actualLines, expectedLines) {
            XCTAssertEqual(actual, expected)
        }
    }

    /// The Objective-C `-[NSString PBMsubstringFromString:]` raised `NSRangeException` when the MRAID scheme was found
    /// after the start of a string that continues beyond it. The port reports a missing scheme instead.
    func testSchemeAfterStartOfURLIsRejected() {
        for url in [" mraid:open", "xmraid:open", "http://a/mraid:expand", "\u{E9}mraid:close/1"] {
            XCTAssertThrowsError(try MRAIDCommand(url: url), url) { error in
                XCTAssertEqual(error.localizedDescription, "URL does not contain MRAID scheme: \(url)")
            }
        }
    }

    func testNilURLIsRejected() {
        XCTAssertThrowsError(try MRAIDCommand(url: nil)) { error in
            XCTAssertEqual(error.localizedDescription, "URL is nil")
        }
    }
}

/// Renders every observable output of the three classes as text, the way the throwaway Objective-C dump did.
/// `nil` and `""` print differently.
enum MRAIDParityDump {

    static func dump() -> String {
        var lines = [String]()

        func line(_ key: String, _ value: String) {
            lines.append("\(key) => \(value)")
        }

        // constants
        line("js.isEnabled", escape(MRAIDJavascriptCommands.isEnabled()))
        line("js.nativeCallComplete", escape(MRAIDJavascriptCommands.nativeCallComplete()))
        line("js.onReady", escape(MRAIDJavascriptCommands.onReady()))
        line("js.onReadyExpanded", escape(MRAIDJavascriptCommands.onReadyExpanded()))
        line("js.getCurrentPosition", escape(MRAIDJavascriptCommands.getCurrentPosition()))
        line("js.getOrientationProperties", escape(MRAIDJavascriptCommands.getOrientationProperties()))
        line("js.getExpandProperties", escape(MRAIDJavascriptCommands.getExpandProperties()))
        line("js.getResizeProperties", escape(MRAIDJavascriptCommands.getResizeProperties()))
        line("js.updateSupportedFeatures", escape(MRAIDJavascriptCommands.updateSupportedFeatures()))
        line("js.onViewableChange.true", escape(MRAIDJavascriptCommands.onViewableChange(true)))
        line("js.onViewableChange.false", escape(MRAIDJavascriptCommands.onViewableChange(false)))

        // numeric
        let numbers: [Double] = [0.0, -0.0, 1.0, -1.1, 1.1111, 0.00005, 0.00015, 0.00025, 0.00035, 0.12345, 0.99995,
                                 1e300, -1e300, 1234567.891, 375.0, 1024.5, .nan, .infinity, -.infinity, 1e-10,
                                 12345678901234567890.0, 0.5, 2.5, 3.5, -0.00005]
        for index in 0..<numbers.count {
            let first = CGFloat(numbers[index])
            let second = CGFloat(numbers[(index + 1) % numbers.count])
            let third = CGFloat(numbers[(index + 2) % numbers.count])
            let fourth = CGFloat(numbers[(index + 3) % numbers.count])
            let suffix = String(format: "%02d", index)
            line("js.onSizeChange.\(suffix)", escape(MRAIDJavascriptCommands.onSizeChange(CGSize(width: first, height: fourth))))
            line("js.updateMaxSize.\(suffix)", escape(MRAIDJavascriptCommands.updateMaxSize(CGSize(width: first, height: fourth))))
            line("js.updateScreenSize.\(suffix)", escape(MRAIDJavascriptCommands.updateScreenSize(CGSize(width: first, height: fourth))))
            line("js.updateDefaultPosition.\(suffix)",
                 escape(MRAIDJavascriptCommands.updateDefaultPosition(CGRect(x: first, y: second, width: third, height: fourth))))
            line("js.updateCurrentPosition.\(suffix)",
                 escape(MRAIDJavascriptCommands.updateCurrentPosition(CGRect(x: first, y: second, width: third, height: fourth))))
            line("js.updateLocation.\(suffix)",
                 escape(MRAIDJavascriptCommands.updateLocation(CLLocationCoordinate2D(latitude: Double(first), longitude: Double(second)),
                                                               accuracy: Double(third),
                                                               timeStamp: Double(fourth))))
        }

        // exposure
        let exposures: [(Float, CGRect, [CGRect]?)] = [
            (0.0, .zero, nil),
            (1.0, CGRect(x: 0, y: 0, width: 100, height: 100), nil),
            (0.5, CGRect(x: 1.23456, y: 2.5, width: 3.00005, height: 4), []),
            (0.333, CGRect(x: 0, y: 0, width: 100, height: 100),
             [CGRect(x: 70, y: 80, width: 30, height: 20), CGRect(x: 0, y: 0, width: 10, height: 10)]),
            (1.5, CGRect(x: -5, y: -6, width: 7, height: 8), nil),
            (-1.0, CGRect(x: 0, y: 0, width: 1e10, height: 0.00015), [CGRect(x: 1, y: 1, width: 1, height: 1)]),
            (.nan, CGRect(x: CGFloat.nan, y: CGFloat.infinity, width: 0, height: 0), nil)
        ]
        for (index, spec) in exposures.enumerated() {
            let exposure = Factory.createViewExposure(exposureFactor: spec.0,
                                                      visibleRectangle: spec.1,
                                                      occlusionRectangles: spec.2)
            line("js.onExposureChange.\(index)", escape(MRAIDJavascriptCommands.onExposureChange(exposure)))
        }
        line("js.onExposureChange.zero",
             escape(MRAIDJavascriptCommands.onExposureChange(Factory.createViewExposure(exposureFactor: 0, visibleRectangle: .zero))))
        line("js.onExposureChange.nil", escape(MRAIDJavascriptCommands.onExposureChange(nil)))

        // state
        let states: [MRAIDState] = [.notEnabled, .defaultState, .expanded, .hidden, .loading, .resized]
        for (index, state) in states.enumerated() {
            line("js.onStateChange.\(index)", escape(MRAIDJavascriptCommands.onStateChange(state)))
        }
        line("js.onStateChange.nil", escape(MRAIDJavascriptCommands.onStateChange(nil)))

        // volume
        let volumes: [NSNumber] = [NSNumber(value: 0), NSNumber(value: 50.5), NSNumber(value: 100), NSNumber(value: -1),
                                   NSNumber(value: Double.nan), NSNumber(value: 1e10), NSNumber(value: 33.333333),
                                   NSNumber(value: Float(0.1)), NSNumber(value: 7), NSNumber(value: true),
                                   NSNumber(value: 0.00005), NSNumber(value: Double.infinity), NSNumber(value: 1e300)]
        line("js.onAudioVolumeChange.nil", escape(MRAIDJavascriptCommands.onAudioVolumeChange(nil)))
        for (index, volume) in volumes.enumerated() {
            line("js.onAudioVolumeChange.\(String(format: "%02d", index))", escape(MRAIDJavascriptCommands.onAudioVolumeChange(volume)))
        }

        // strings
        let strings: [String?] = ["inline", "interstitial", "", "a'b", "it's \"q\"", "unicode \u{E9} \u{1F600}", nil]
        for (index, value) in strings.enumerated() {
            line("js.updatePlacementType.\(index)", escape(MRAIDJavascriptCommands.updatePlacementType(value)))
            line("js.updateCurrentAppOrientation.locked.\(index)", escape(MRAIDJavascriptCommands.updateCurrentAppOrientation(value, locked: true)))
            line("js.updateCurrentAppOrientation.unlocked.\(index)", escape(MRAIDJavascriptCommands.updateCurrentAppOrientation(value, locked: false)))
            for (actionIndex, action) in strings.enumerated() {
                line("js.onError.\(index).\(actionIndex)", escape(MRAIDJavascriptCommands.onError(value, action: action)))
            }
        }

        // MRAID command parsing
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
                    "mraid:expand/%25", "mraid:expand/%2F", "mraid:op\u{307}en"]
        for (index, url) in urls.enumerated() {
            let result: String
            do {
                let command = try MRAIDCommand(url: url)
                result = "command=\(escape(command.command)) arguments=\(argumentList(command.arguments)) error=nil"
            } catch let error as NSError {
                result = "nil error=\(escape(error.localizedDescription)) domain=\(escape(error.domain)) code=\(error.code)"
            }
            line("cmd.\(String(format: "%02d", index)).\(escape(url))", result)
        }
        do {
            _ = try MRAIDCommand(url: nil)
            line("cmd.nilurl", "command")
        } catch let error as NSError {
            line("cmd.nilurl", "nil error=\(escape(error.localizedDescription)) domain=\(escape(error.domain)) code=\(error.code)")
        }
        line("cmd.nilerrorpointer", (try? MRAIDCommand(url: "mraid:")) == nil ? "nil" : "command")

        // HTML formatter
        let htmls = ["", "x", "<body>x</body>", "<html></html>", "<HTML><BODY>x</BODY></HTML>", "<html>x", "x</html>",
                     "<html style=\"a\">x</html>", "<head><script>1</script></head>x", "<BODY class=a>x", "<bod>y", "<html><html>",
                     "<  html>", "<html >", "a<html>b</html>c<HtMl>d", "<bodyx>", "<body", "\u{130}<body>", "<BODY\u{200D}>",
                     "<!DOCTYPE html><html><head></head><body>hi</body></html>", "line1\nline2\r\n<html>\n</html>\n",
                     "\u{1F600}<html>\u{1F600}</html>\u{1F600}", "<script src=\"mraid.js\"></script> <div>x</div>",
                     "<html style=\"color:red\u{201D}>blah</html>", "<</html>html>", "</html></html></HTML>", "<Body>", "<bo\u{307}dy>",
                     "%@ %d \\ \"", "\u{212A}<BODY>", "\u{3A3}<BODY", "<html\u{200D}>x</html>", "<BODY>\u{130}", "\u{1E9E} <Body>",
                     "<body\n>", "<html>\n</HTML>x",
                     String(String(repeating: "<div>ab</div>", count: 154).prefix(2000))]
        for (index, html) in htmls.enumerated() {
            line("html.\(String(format: "%02d", index))", escape(HTMLFormatter.ensureHTMLHasBodyAndHTMLTags(html)))
        }

        return lines.joined(separator: "\n") + "\n"
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

    private static func argumentList(_ arguments: [String]) -> String {
        "[" + arguments.map { escape($0) }.joined(separator: ", ") + "]"
    }
}
