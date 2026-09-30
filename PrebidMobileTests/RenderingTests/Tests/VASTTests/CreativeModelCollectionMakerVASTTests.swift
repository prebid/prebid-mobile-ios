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
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    
    var successfulExpectation: XCTestExpectation?
    
    override func tearDown() {
        successfulExpectation = nil
    }
    
    func testMakeCompanionAd() {
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        successfulExpectation = expectation(description: "Expected VAST Load to be successful")
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("VAST_with_companion.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)
        
        XCTAssertNotNil(vastServerResponse)
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        let successCallbackExpectation = expectation(description: "makeModels successCallback called")
        
        modelMaker.makeModels(vastServerResponse!,
                              successCallback: { models in
            successCallbackExpectation.fulfill()
            
            XCTAssertEqual(models.count, 2)
            XCTAssertTrue(models[0].hasCompanionAd)
            XCTAssertFalse(models[0].isCompanionAd)
            XCTAssertFalse(models[1].hasCompanionAd)
            XCTAssertTrue(models[1].isCompanionAd)
        },
                              failureCallback: { error in
            XCTFail(error.localizedDescription)
        })
        
        waitForExpectations(timeout: 3)
    }
    
    // Regression: a CompanionAds creative listed before the Linear one used to crash with
    // -[PBMVastCreativeCompanionAds bestMediaFile]: unrecognized selector.
    func testMakeCompanionAd_companionBeforeLinear() {
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]

        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)

        successfulExpectation = expectation(description: "Expected VAST Load to be successful")

        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }

        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager

        // Reuse VAST_with_companion.xml, swapping its two <Creative> blocks so CompanionAds comes first.
        guard let data = UtilitiesForTesting.loadFileAsDataFromBundle("VAST_with_companion.xml"),
              let xml = String(data: data, encoding: .utf8),
              let linearStart = xml.range(of: "<Creative id=\"540069340\">"),
              let companionStart = xml.range(of: "<Creative id=\"540069343\">"),
              let creativesEnd = xml.range(of: "</Creatives>") else {
            XCTFail("Could not load VAST_with_companion.xml")
            return
        }
        let head = String(xml[..<linearStart.lowerBound])
        let linearBlock = String(xml[linearStart.lowerBound..<companionStart.lowerBound])
        let companionBlock = String(xml[companionStart.lowerBound..<creativesEnd.lowerBound])
        let tail = String(xml[creativesEnd.lowerBound...])
        let reordered = head + companionBlock + "\n" + linearBlock + tail

        requester.buildAdsArray(Data(reordered.utf8))

        waitForExpectations(timeout: 2)

        XCTAssertNotNil(vastServerResponse)

        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)

        let successCallbackExpectation = expectation(description: "makeModels successCallback called")

        modelMaker.makeModels(vastServerResponse!,
                              successCallback: { models in
            successCallbackExpectation.fulfill()

            XCTAssertEqual(models.count, 2)
            XCTAssertTrue(models[0].hasCompanionAd)
            XCTAssertFalse(models[0].isCompanionAd)
            XCTAssertFalse(models[1].hasCompanionAd)
            XCTAssertTrue(models[1].isCompanionAd)
        },
                              failureCallback: { error in
            XCTFail(error.localizedDescription)
        })

        waitForExpectations(timeout: 3)
    }

    func testMakeCompanionAd_empty() {
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        successfulExpectation = expectation(description: "Expected VAST Load to be successful")
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("VAST_with_empty_companion.xml") {
            requester.buildAdsArray(data)
        }
        
        waitForExpectations(timeout: 2)
        
        XCTAssertNotNil(vastServerResponse)
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        let successCallbackExpectation = expectation(description: "makeModels successCallback called")
        
        modelMaker.makeModels(vastServerResponse!,
                              successCallback: { models in
            XCTAssertEqual(models.count, 1)
            XCTAssertFalse(models.first!.hasCompanionAd)
            XCTAssertFalse(models.first!.isCompanionAd)
            successCallbackExpectation.fulfill()
        },
                              failureCallback: { error in
            XCTFail(error.localizedDescription)
        })
        
        waitForExpectations(timeout: 3)
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

    // The maker can also be called without the validation step. "No creative" means that no ad has a
    // Linear creative, "No suitable media file" that there is a Linear one but none of them is playable.
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
            ([companionOnlyAd], .generalLinear, "No creative"),
            ([unplayableAd], .fileNotFound, "No suitable media file"),
            ([companionOnlyAd, unplayableAd], .fileNotFound, "No suitable media file"),
        ]

        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection: UtilitiesForTesting.createConnectionForMockedTest(),
                                                             adConfiguration: adConfiguration)

        for (index, testCase) in cases.enumerated() {
            let response = PBMAdRequestResponseVAST()
            response.ads = testCase.ads

            let failureCallbackExpectation = expectation(description: "makeModels failureCallback called, case \(index)")

            modelMaker.makeModels(response,
                                  successCallback: { _ in
                XCTFail("Case \(index): expected makeModels to fail")
            },
                                  failureCallback: { error in
                XCTAssertEqual((error as NSError).code, testCase.code.rawValue, "case \(index)")
                XCTAssertEqual(error.localizedDescription, testCase.message, "case \(index)")
                failureCallbackExpectation.fulfill()
            })

            waitForExpectations(timeout: 3)
        }
    }

    // MARK: - Helpers

    /// Runs inline VAST through the two steps `PBMAdLoadManagerVAST` chains:
    /// `PBMAdRequesterVAST` (parsing and validation), then `PBMCreativeModelCollectionMakerVAST`.
    private func makeModels(fromVAST xml: String) -> Result<[CreativeModel], NSError> {
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]

        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)

        var validationError: NSError?
        vastServerResponse = nil

        let requestCompletedExpectation = expectation(description: "Expected VAST Load to complete")

        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            requestCompletedExpectation.fulfill()
        }

        adLoadManager.mock_requestCompletedFailure = { error in
            validationError = error as NSError
            requestCompletedExpectation.fulfill()
        }

        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        requester.buildAdsArray(Data(xml.utf8))

        waitForExpectations(timeout: 2)

        guard let vastServerResponse else {
            return .failure(validationError ?? NSError(domain: "CreativeModelCollectionMakerVASTTests", code: 0))
        }

        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)

        var result: Result<[CreativeModel], NSError>?
        let makeModelsExpectation = expectation(description: "makeModels callback called")

        modelMaker.makeModels(vastServerResponse,
                              successCallback: { models in
            result = .success(models)
            makeModelsExpectation.fulfill()
        },
                              failureCallback: { error in
            result = .failure(error as NSError)
            makeModelsExpectation.fulfill()
        })

        waitForExpectations(timeout: 3)

        return result ?? .failure(NSError(domain: "CreativeModelCollectionMakerVASTTests", code: 0))
    }

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
