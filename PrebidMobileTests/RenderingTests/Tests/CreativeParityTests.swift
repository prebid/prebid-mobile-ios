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

@_spi(PBMInternal) @testable import PrebidMobile

typealias ParityHTMLCreative = HTMLCreative
typealias ParityVideoCreative = VideoCreative

/// Parity evidence for the ObjC to Swift port of `HTMLCreative` / `VideoCreative` (Phase 7, wave 3).
/// The expectations in `CreativeParityExpectations` were captured from the ObjC classes before they were deleted.
final class CreativeParityTests: XCTestCase {

    private static func describe(_ number: NSNumber?) -> String {
        guard let number else { return "nil" }
        return String(format: "%.17g", number.doubleValue)
    }

    private static func describe(_ value: Double?) -> String {
        guard let value else { return "nil" }
        return String(format: "%.17g", value)
    }

    private static let vastInputs: [String] = [
        "", "test", "<VAST version=\"3.0\">", "<vast version=\"3.0\">", "<Vast  version =\"4.0\">",
        "<VAST\tversion=\"3.0\">", "<VAST\nversion=\"3.0\">", "< VAST version=\"3.0\">", "<VASTversion=\"3.0\">",
        "<VAST version \"3.0\">", "<VAST version", "<VAST version=", "<?xml version=\"1.0\"?><VAST version=\"2.0\"></VAST>",
        "<html><body>VAST version=</body></html>", "<html><!-- <VAST version=\"3\"> --></html>",
        "<VAST\u{00A0}version=\"3.0\">", "<VAST\u{2003}version=\"3.0\">", "<VAST\u{200D}version=\"3.0\">",
        "<VAST version\u{00A0}=\"3.0\">", "<\u{FF36}AST version=\"3.0\">", "<VAST\u{0301} version=\"3.0\">",
        "<\u{0130}VAST version=\"3.0\">", "prefix <VAST version=\"3.0\"> suffix", "<VAST version=\"3.0\"",
        "<VAST    \t\n  version  \t=", "<vAsT version=1>", String(repeating: "a", count: 5000) + "<VAST version=",
        "<VAST version=\"1\"><VAST version=\"2\">", "\u{FEFF}<VAST version=\"3.0\">"
    ]

    private func makeModel() -> CreativeModel {
        CreativeModel(adConfiguration: AdConfiguration())
    }

    func dumpLines() -> [String] {
        var lines = [String]()

        // hasVastTag
        let htmlCreative = ParityHTMLCreative(creativeModel: makeModel(), transaction: UtilitiesForTesting.createEmptyTransaction())
        for (index, input) in Self.vastInputs.enumerated() {
            lines.append("vast.\(index) => \(htmlCreative.hasVastTag(input))")
        }

        lines.append("max.size => \(ParityVideoCreative.maxSizeForPreRenderContent)")

        // calculateCloseDelay(forPubCloseDelay:)
        let closeDelayModel = makeModel()
        let closeDelayCreative = ParityVideoCreative(creativeModel: closeDelayModel,
                                                     transaction: UtilitiesForTesting.createEmptyTransaction(),
                                                     videoData: Data())
        let skipDelays: [Double?] = [nil, 5, .nan]
        let skipOffsets: [NSNumber?] = [nil, 4, -1]
        let durations: [NSNumber?] = [nil, 0, 60, Double.nan as NSNumber, Double.infinity as NSNumber]
        let pubDelays: [Double] = [0, 5, .nan]
        for hasCompanion in [false, true] {
            for skipDelay in skipDelays {
                for skipOffset in skipOffsets {
                    for duration in durations {
                        for pubDelay in pubDelays {
                            closeDelayModel.hasCompanionAd = hasCompanion
                            closeDelayModel.adConfiguration?.videoControlsConfig.skipDelay = skipDelay ?? PrebidConstants.SKIP_DELAY_DEFAULT.doubleValue
                            closeDelayModel.skipOffset = skipOffset
                            closeDelayModel.displayDurationInSeconds = duration
                            let result = closeDelayCreative.calculateCloseDelay(forPubCloseDelay: pubDelay)
                            lines.append("close.comp=\(hasCompanion).skip=\(Self.describe(skipDelay)).off=\(Self.describe(skipOffset)).dur=\(Self.describe(duration)).pub=\(Self.describe(pubDelay)) => \(Self.describe(result))")
                        }
                    }
                }
            }
        }

        // rewardTime / postRewardTime computed in the initializer
        let events: [String?] = [nil, "start", "complete", "bogus"]
        let videoTimes: [NSNumber?] = [nil, -1, 5, 2.5]
        let rewardDurations: [NSNumber?] = [nil, -5, 40.5]
        let postRewardTimes: [NSNumber?] = [nil, 0, 2.5]
        for isRewarded in [false, true] {
            for event in events {
                for videoTime in videoTimes {
                    for duration in rewardDurations {
                        for postRewardTime in postRewardTimes {
                            let ortbRewarded = ORTBRewardedConfiguration()
                            ortbRewarded.completion = ORTBRewardedCompletion()
                            ortbRewarded.completion?.video = ORTBRewardedCompletionVideo()
                            ortbRewarded.completion?.video?.playbackevent = event
                            ortbRewarded.completion?.video?.time = videoTime
                            ortbRewarded.close = ORTBRewardedClose()
                            ortbRewarded.close?.postrewardtime = postRewardTime

                            let adConfiguration = AdConfiguration()
                            adConfiguration.isRewarded = isRewarded
                            adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: ortbRewarded)
                            let model = CreativeModel(adConfiguration: adConfiguration)
                            model.displayDurationInSeconds = duration

                            _ = ParityVideoCreative(creativeModel: model,
                                                    transaction: UtilitiesForTesting.createEmptyTransaction(),
                                                    videoData: Data())
                            lines.append("reward.r=\(isRewarded).ev=\(event ?? "nil").vt=\(Self.describe(videoTime)).dur=\(Self.describe(duration)).post=\(Self.describe(postRewardTime)) => reward=\(Self.describe(model.rewardTime)) post=\(Self.describe(model.postRewardTime))")
                        }
                    }
                }
            }
        }

        // no rewarded config at all
        let plainAdConfiguration = AdConfiguration()
        plainAdConfiguration.isRewarded = true
        let plainModel = CreativeModel(adConfiguration: plainAdConfiguration)
        plainModel.displayDurationInSeconds = 12
        _ = ParityVideoCreative(creativeModel: plainModel, transaction: UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        lines.append("reward.noconfig => reward=\(Self.describe(plainModel.rewardTime)) post=\(Self.describe(plainModel.postRewardTime))")

        return lines
    }

    func testParity() throws {
        let lines = dumpLines()

        let expected = CreativeParityExpectations.lines
        XCTAssertFalse(expected.isEmpty, "expectations were not captured")
        XCTAssertEqual(lines.count, expected.count)
        for (index, line) in lines.enumerated() where index < expected.count {
            XCTAssertEqual(line, expected[index], "line \(index)")
        }
    }
}
