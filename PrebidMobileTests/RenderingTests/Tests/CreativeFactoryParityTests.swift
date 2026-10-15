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

/// Parity evidence for the ObjC to Swift port of `PBMCreativeFactoryJob` / `PBMTransaction_Objc` (Phase 7, wave 4).
/// The expectations in `CreativeFactoryParityExpectations` were captured from the ObjC classes before they were deleted.
final class CreativeFactoryParityTests: XCTestCase {

    private static func describe(_ value: Double) -> String {
        String(format: "%.17g", value)
    }

    // MARK: - Job timeout selection

    private func timeIntervalLines() -> [String] {
        var lines = [String]()
        let defaultTimeout = Prebid.shared.creativeFactoryTimeout
        let defaultPreRenderTimeout = Prebid.shared.creativeFactoryTimeoutPreRenderContent
        defer {
            Prebid.shared.creativeFactoryTimeout = defaultTimeout
            Prebid.shared.creativeFactoryTimeoutPreRenderContent = defaultPreRenderTimeout
        }

        // The ObjC job compared `winningBidAdFormat` by identity: an equal but distinct instance is not "video".
        let lookalikeVideo = AdFormat(rawValue: AdFormat.video.rawValue, stringEquivalent: "video")
        let formats: [(String, AdFormat?)] = [("nil", nil), ("banner", .banner), ("video", .video), ("native", .native),
                                              ("videoLookalike", lookalikeVideo)]
        let timeouts: [(Double, Double)] = [(defaultTimeout, defaultPreRenderTimeout), (11.1, 22.2), (0, -1), (.nan, .infinity)]
        let forced: [Bool?] = [nil, false, true]

        var index = 0
        for (timeout, preRenderTimeout) in timeouts {
            Prebid.shared.creativeFactoryTimeout = timeout
            Prebid.shared.creativeFactoryTimeoutPreRenderContent = preRenderTimeout
            for (name, format) in formats {
                for isInterstitial in [false, true] {
                    for forcedValue in forced {
                        let adConfiguration = AdConfiguration()
                        adConfiguration.winningBidAdFormat = format
                        adConfiguration.isInterstitialAd = isInterstitial
                        adConfiguration.forceInterstitialPresentation = forcedValue.map { NSNumber(value: $0) }
                        let model = CreativeModel(adConfiguration: adConfiguration)
                        let interval = jobTimeInterval(model: model)
                        lines.append("interval.\(index) \(name) interstitial=\(isInterstitial) forced=\(String(describing: forcedValue)) => \(Self.describe(interval))")
                        index += 1
                    }
                }
            }
        }

        // a model without ad configuration
        Prebid.shared.creativeFactoryTimeout = 3.5
        let bareModel = CreativeModel()
        bareModel.adConfiguration = nil
        lines.append("interval.noconfig => \(Self.describe(jobTimeInterval(model: bareModel)))")
        return lines
    }

    // MARK: - Transaction navigation

    private func describe(_ creative: AbstractCreative?, in creatives: [AbstractCreative], foreign: AbstractCreative) -> String {
        guard let creative else { return "nil" }
        if creative === foreign { return "foreign" }
        return creatives.firstIndex { $0 === creative }.map { "c\($0)" } ?? "unknown"
    }

    private func transactionLines() -> [String] {
        var lines = [String]()
        let connection = PrebidServerConnection()
        let foreign = UtilitiesForTesting.createHTMLCreative(withModel: CreativeModel(adConfiguration: AdConfiguration()), withView: false)

        // creatives: empty, one, three, a creative listed twice
        let counts = ["empty": 0, "one": 1, "three": 3, "duplicate": 2]
        for scenario in ["empty", "one", "three", "duplicate"] {
            let transaction = Factory.createTransaction(serverConnection: connection, adConfiguration: AdConfiguration(), models: [])
            var creatives = [AbstractCreative]()
            for position in 0..<(counts[scenario] ?? 0) {
                let model = CreativeModel(adConfiguration: AdConfiguration())
                model.revenue = position == 1 ? nil : "rev\(position)"
                if position == 0 {
                    model.adDetails = AdDetails(rawResponse: "raw", transactionId: "tid")
                }
                creatives.append(UtilitiesForTesting.createHTMLCreative(withModel: model, withView: false))
            }
            if scenario == "duplicate", let first = creatives.first {
                creatives.append(first)
                creatives.append(UtilitiesForTesting.createHTMLCreative(withModel: CreativeModel(adConfiguration: AdConfiguration()), withView: false))
            }
            transaction.creatives = creatives

            let details = transaction.getAdDetails()
            lines.append("\(scenario).first => \(describe(transaction.getFirstCreative(), in: creatives, foreign: foreign))")
            lines.append("\(scenario).details => \(details.map { "\($0.rawResponse)/\($0.transactionId)" } ?? "nil")")
            for (position, creative) in (creatives + [foreign]).enumerated() {
                let after = transaction.getCreative(after: creative)
                lines.append("\(scenario).after.\(position) => \(describe(after, in: creatives, foreign: foreign))")
                lines.append("\(scenario).revenue.\(position) => \(transaction.revenueForCreative(after: creative) ?? "nil")")
            }
        }

        // updateAdConfiguration and resetAdConfiguration
        let sizes: [(Int, Int)] = [(0, 0), (42, 7), (-3, -4), (Int(Int32.max), 1), (1 << 40, 2)]
        for (width, height) in sizes {
            let adConfiguration = AdConfiguration()
            let first = CreativeModel(adConfiguration: adConfiguration)
            first.width = width
            first.height = height
            let second = CreativeModel(adConfiguration: adConfiguration)
            second.width = 1
            second.height = 1
            let transaction = Factory.createTransaction(serverConnection: connection, adConfiguration: adConfiguration, models: [first, second])
            transaction.updateAdConfiguration()
            lines.append("size.\(width)x\(height) => \(Self.describe(transaction.adConfiguration.size.width)) \(Self.describe(transaction.adConfiguration.size.height))")
        }
        let emptyConfiguration = AdConfiguration()
        emptyConfiguration.size = CGSize(width: 9, height: 8)
        let emptyTransaction = Factory.createTransaction(serverConnection: connection, adConfiguration: emptyConfiguration, models: [])
        emptyTransaction.updateAdConfiguration()
        lines.append("size.nomodels => \(emptyTransaction.adConfiguration.size.width) \(emptyTransaction.adConfiguration.size.height)")

        let oldConfiguration = AdConfiguration()
        let newConfiguration = AdConfiguration()
        let models = [CreativeModel(adConfiguration: oldConfiguration), CreativeModel(adConfiguration: oldConfiguration)]
        let resetTransaction = Factory.createTransaction(serverConnection: connection, adConfiguration: oldConfiguration, models: models)
        resetTransaction.resetAdConfiguration(newConfiguration)
        lines.append("reset => transaction=\(resetTransaction.adConfiguration === newConfiguration) models=\(models.map { $0.adConfiguration === newConfiguration })")

        lines.append("session.initial => \(resetTransaction.measurementSession == nil)")
        return lines
    }

    func dumpLines() -> [String] {
        timeIntervalLines() + transactionLines()
    }

    func testParity() throws {
        let lines = dumpLines()
        try? lines.joined(separator: "\n").write(toFile: "/tmp/p7-4/factory-dump.txt", atomically: true, encoding: .utf8)

        let expected = CreativeFactoryParityExpectations.lines
        guard !expected.isEmpty else {
            return // capture run
        }

        XCTAssertEqual(lines.count, expected.count)
        for (index, line) in lines.enumerated() where index < expected.count {
            XCTAssertEqual(line, expected[index], "line \(index)")
        }
    }

    // MARK: - Shim over the job (the ObjC spelling before the port)

    private func jobTimeInterval(model: CreativeModel) -> Double {
        let job = PBMCreativeFactoryJob(from: model,
                                        transaction: UtilitiesForTesting.createEmptyTransaction(),
                                        serverConnection: PrebidServerConnection(),
                                        finishedCallback: { _, _ in })
        return job.getTimeInterval()
    }
}
