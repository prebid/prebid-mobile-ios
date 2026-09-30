/*   Copyright 2018-2021 Prebid.org, Inc.
 
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

import Foundation
import XCTest
@_spi(PBMInternal) @testable import PrebidMobile

class CreativeModelCollectionMakerVASTTests: XCTestCase {

    private let connection = UtilitiesForTesting.createConnectionForMockedTest()

    private let adConfiguration: AdConfiguration = {
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        return adConfiguration
    }()

    func testMakeCompanionAd() throws {
        let data = try XCTUnwrap(UtilitiesForTesting.loadFileAsDataFromBundle("VAST_with_companion.xml"))

        let response = try loadResponse(fromVAST: data).get()
        let models = try makeModels(from: response).get()

        XCTAssertEqual(models.count, 2)
        XCTAssertTrue(models[0].hasCompanionAd)
        XCTAssertFalse(models[0].isCompanionAd)
        XCTAssertFalse(models[1].hasCompanionAd)
        XCTAssertTrue(models[1].isCompanionAd)
    }

    // Regression: a CompanionAds creative listed before the Linear one used to crash with
    // -[PBMVastCreativeCompanionAds bestMediaFile]: unrecognized selector.
    func testMakeCompanionAd_companionBeforeLinear() throws {
        // Reuse VAST_with_companion.xml, swapping its two <Creative> blocks so CompanionAds comes first.
        guard let data = UtilitiesForTesting.loadFileAsDataFromBundle("VAST_with_companion.xml"),
              let xml = String(data: data, encoding: .utf8),
              let linearStart = xml.range(of: "<Creative id=\"540069340\">"),
              let companionStart = xml.range(of: "<Creative id=\"540069343\">"),
              let creativesEnd = xml.range(of: "</Creatives>") else {
            XCTFail("VAST_with_companion.xml is missing or its Creative ids changed")
            return
        }
        let head = String(xml[..<linearStart.lowerBound])
        let linearBlock = String(xml[linearStart.lowerBound..<companionStart.lowerBound])
        let companionBlock = String(xml[companionStart.lowerBound..<creativesEnd.lowerBound])
        let tail = String(xml[creativesEnd.lowerBound...])
        let reordered = head + companionBlock + "\n" + linearBlock + tail

        let response = try loadResponse(fromVAST: Data(reordered.utf8)).get()

        // The swap depends on the creative order in the shared fixture. Make sure CompanionAds really comes first.
        XCTAssertTrue((response.ads?.first as? PBMVastInlineAd)?.creatives.firstObject is PBMVastCreativeCompanionAds)

        let models = try makeModels(from: response).get()

        XCTAssertEqual(models.count, 2)
        XCTAssertTrue(models[0].hasCompanionAd)
        XCTAssertFalse(models[0].isCompanionAd)
        XCTAssertFalse(models[1].hasCompanionAd)
        XCTAssertTrue(models[1].isCompanionAd)
    }

    func testMakeCompanionAd_empty() throws {
        let data = try XCTUnwrap(UtilitiesForTesting.loadFileAsDataFromBundle("VAST_with_empty_companion.xml"))

        let response = try loadResponse(fromVAST: data).get()
        let models = try makeModels(from: response).get()

        XCTAssertEqual(models.count, 1)
        XCTAssertFalse(models.first!.hasCompanionAd)
        XCTAssertFalse(models.first!.isCompanionAd)
    }

    // MARK: - Linear creative selection

    // Validation (-[PBMVastAdsBuilder hasValidMedia:]) accepts a response if any Linear creative is playable,
    // so the maker has to render that creative rather than fail on the first Linear it sees.
    func testMakeModels_unsupportedLinearBeforeSupportedLinear() throws {
        let xml = Self.vast(ads: [
            Self.inlineAd(id: "1", creatives: [
                Self.linear(mimeType: "application/javascript", mediaURL: "https://example.com/vpaid.js", duration: "00:00:10"),
                Self.linear(mimeType: "video/mp4", mediaURL: "https://example.com/video.mp4", duration: "00:00:15"),
            ])
        ])

        let models = try makeModels(fromVAST: xml).get()

        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first?.videoFileURL, "https://example.com/video.mp4")
        XCTAssertEqual(models.first?.displayDurationInSeconds, 15)
    }

    func testMakeModels_supportedLinearBeforeUnsupportedLinear() throws {
        let xml = Self.vast(ads: [
            Self.inlineAd(id: "1", creatives: [
                Self.linear(mimeType: "video/mp4", mediaURL: "https://example.com/video.mp4", duration: "00:00:15"),
                Self.linear(mimeType: "application/javascript", mediaURL: "https://example.com/vpaid.js", duration: "00:00:10"),
            ])
        ])

        let models = try makeModels(fromVAST: xml).get()

        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first?.videoFileURL, "https://example.com/video.mp4")
        XCTAssertEqual(models.first?.displayDurationInSeconds, 15)
    }

    // The same disagreement across ads: the first ad has no playable Linear, the second one does.
    // Everything in the models has to come from the ad that gets rendered.
    func testMakeModels_unplayableAdBeforePlayableAd() throws {
        let xml = Self.vast(ads: [
            Self.inlineAd(id: "1", creatives: [
                Self.linear(mimeType: "application/javascript", mediaURL: "https://example.com/vpaid.js", duration: "00:00:10"),
                Self.companion(imageURL: "https://example.com/companion-1.png"),
            ]),
            Self.inlineAd(id: "2", creatives: [
                Self.linear(mimeType: "video/mp4", mediaURL: "https://example.com/video.mp4", duration: "00:00:15"),
                Self.companion(imageURL: "https://example.com/companion-2.png"),
            ]),
        ])

        let models = try makeModels(fromVAST: xml).get()

        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models.first?.videoFileURL, "https://example.com/video.mp4")
        XCTAssertEqual(models.first?.displayDurationInSeconds, 15)

        let impressionKey = TrackingEventDescription.getDescription(.impression)
        XCTAssertEqual(models.first?.trackingURLs[impressionKey], ["https://example.com/imp/2"])

        let companionHTML = try XCTUnwrap(models.last?.html)
        XCTAssertEqual(models.last?.isCompanionAd, true)
        XCTAssertTrue(companionHTML.contains("https://example.com/companion-2.png"))
        XCTAssertFalse(companionHTML.contains("https://example.com/companion-1.png"))
    }

    func testMakeModels_noSupportedMediaIsRejectedByValidation() {
        let xml = Self.vast(ads: [
            Self.inlineAd(id: "1", creatives: [
                Self.linear(mimeType: "application/javascript", mediaURL: "https://example.com/vpaid.js"),
            ]),
            Self.inlineAd(id: "2", creatives: [
                Self.linear(mimeType: "video/x-flv", mediaURL: "https://example.com/video.flv"),
            ]),
        ])

        guard case .failure(let error) = makeModels(fromVAST: xml) else {
            XCTFail("Expected the response to be rejected")
            return
        }

        XCTAssertEqual(error.code, PBMErrorCode.fileNotFound.rawValue)
        XCTAssertEqual(error.localizedDescription, "No Valid Media")
    }

    // The maker can also be called without the validation step, so it reports these cases on its own.
    func testMakeModels_noLinearCreative() {
        let ad = PBMVastInlineAd()
        ad.creatives.add(PBMVastCreativeCompanionAds())
        let response = PBMAdRequestResponseVAST()
        response.ads = [ad]

        guard case .failure(let error) = makeModels(from: response) else {
            XCTFail("Expected a failure for an ad without a Linear creative")
            return
        }

        XCTAssertEqual(error.code, PBMErrorCode.generalLinear.rawValue)
        XCTAssertEqual(error.localizedDescription, "No creative")
    }

    // "No creative" means that no ad has a Linear creative, "No suitable media file" that there is
    // a Linear one but none of them is playable.
    func testMakeModels_makerErrors() {
        let unsupportedMediaFile = PBMVastMediaFile()
        unsupportedMediaFile.type = "application/javascript"
        unsupportedMediaFile.mediaURI = "https://example.com/vpaid.js"

        let unplayableLinear = PBMVastCreativeLinear()
        unplayableLinear.duration = 15
        unplayableLinear.mediaFiles.add(unsupportedMediaFile)

        let unplayableAd = PBMVastInlineAd()
        unplayableAd.creatives.add(unplayableLinear)

        let companionOnlyAd = PBMVastInlineAd()
        companionOnlyAd.creatives.add(PBMVastCreativeCompanionAds())

        let cases: [(ads: [PBMVastAbstractAd], code: PBMErrorCode, message: String)] = [
            ([], .generalLinear, "No creative"),
            ([PBMVastInlineAd()], .generalLinear, "No creative"),
            ([companionOnlyAd, PBMVastInlineAd()], .generalLinear, "No creative"),
            ([unplayableAd], .fileNotFound, "No suitable media file"),
            ([companionOnlyAd, unplayableAd], .fileNotFound, "No suitable media file"),
        ]

        for (index, testCase) in cases.enumerated() {
            let response = PBMAdRequestResponseVAST()
            response.ads = testCase.ads

            guard case .failure(let error) = makeModels(from: response) else {
                XCTFail("Case \(index): expected makeModels to fail")
                continue
            }

            XCTAssertEqual(error.code, testCase.code.rawValue, "case \(index)")
            XCTAssertEqual(error.localizedDescription, testCase.message, "case \(index)")
        }
    }

    // MARK: - Helpers

    /// Parses and validates VAST with `PBMAdRequesterVAST`, the first step of `PBMAdLoadManagerVAST`.
    private func loadResponse(fromVAST data: Data) -> Result<PBMAdRequestResponseVAST, NSError> {
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection: connection, adConfiguration: adConfiguration)

        var result: Result<PBMAdRequestResponseVAST, NSError>?
        let requestCompletedExpectation = expectation(description: "Expected VAST Load to complete")

        adLoadManager.mock_requestCompletedSuccess = { response in
            result = .success(response)
            requestCompletedExpectation.fulfill()
        }

        adLoadManager.mock_requestCompletedFailure = { error in
            result = .failure(error as NSError)
            requestCompletedExpectation.fulfill()
        }

        let requester = PBMAdRequesterVAST(serverConnection: connection, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        requester.buildAdsArray(data)

        waitForExpectations(timeout: 2)

        return result ?? .failure(Self.noCallbackError)
    }

    /// Builds the creative models with `PBMCreativeModelCollectionMakerVAST`, the second step of `PBMAdLoadManagerVAST`.
    private func makeModels(from response: PBMAdRequestResponseVAST) -> Result<[CreativeModel], NSError> {
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection: connection, adConfiguration: adConfiguration)

        var result: Result<[CreativeModel], NSError>?
        let makeModelsExpectation = expectation(description: "makeModels callback called")

        modelMaker.makeModels(response,
                              successCallback: { models in
            result = .success(models)
            makeModelsExpectation.fulfill()
        },
                              failureCallback: { error in
            result = .failure(error as NSError)
            makeModelsExpectation.fulfill()
        })

        waitForExpectations(timeout: 3)

        return result ?? .failure(Self.noCallbackError)
    }

    /// Runs inline VAST through both steps.
    private func makeModels(fromVAST xml: String) -> Result<[CreativeModel], NSError> {
        loadResponse(fromVAST: Data(xml.utf8)).flatMap(makeModels(from:))
    }

    private static let noCallbackError = NSError(domain: "CreativeModelCollectionMakerVASTTests", code: 0)

    private static func vast(ads: [String]) -> String {
        "<VAST version=\"3.0\">\(ads.joined())</VAST>"
    }

    private static func inlineAd(id: String, creatives: [String]) -> String {
        """
        <Ad id="\(id)">
          <InLine>
            <AdSystem>test</AdSystem>
            <AdTitle>t</AdTitle>
            <Impression><![CDATA[https://example.com/imp/\(id)]]></Impression>
            <Creatives>\(creatives.joined())</Creatives>
          </InLine>
        </Ad>
        """
    }

    private static func linear(mimeType: String, mediaURL: String, duration: String = "00:00:15") -> String {
        """
        <Creative>
          <Linear>
            <Duration>\(duration)</Duration>
            <MediaFiles>
              <MediaFile delivery="progressive" type="\(mimeType)" width="640" height="480"><![CDATA[\(mediaURL)]]></MediaFile>
            </MediaFiles>
          </Linear>
        </Creative>
        """
    }

    private static func companion(imageURL: String) -> String {
        """
        <Creative>
          <CompanionAds>
            <Companion width="300" height="250">
              <StaticResource creativeType="image/png"><![CDATA[\(imageURL)]]></StaticResource>
              <CompanionClickThrough><![CDATA[https://example.com/click]]></CompanionClickThrough>
            </Companion>
          </CompanionAds>
        </Creative>
        """
    }
}
