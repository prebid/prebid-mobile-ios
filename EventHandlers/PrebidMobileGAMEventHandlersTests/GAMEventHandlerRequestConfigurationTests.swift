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
import GoogleMobileAds
import PrebidMobile
@testable import PrebidMobileGAMEventHandlers

final class GAMEventHandlerRequestConfigurationTests: XCTestCase {

    func testBannerRequestConfigurationIsNilByDefault() {
        let handler = GAMBannerEventHandler(
            adUnitID: "/test/adunit",
            validGADAdSizes: [nsValue(for: AdSizeBanner)]
        )

        XCTAssertNil(handler.adManagerRequestConfiguration)
    }

    func testInterstitialRequestConfigurationIsNilByDefault() {
        let handler = GAMInterstitialEventHandler(adUnitID: "/test/adunit")

        XCTAssertNil(handler.adManagerRequestConfiguration)
    }

    func testRewardedRequestConfigurationIsNilByDefault() {
        let handler = GAMRewardedAdEventHandler(adUnitID: "/test/adunit")

        XCTAssertNil(handler.adManagerRequestConfiguration)
    }

    func testBannerRequestConfigurationIsCalledDuringAdRequest() {
        let handler = GAMBannerEventHandler(
            adUnitID: "/test/adunit",
            validGADAdSizes: [nsValue(for: AdSizeBanner)]
        )
        let expectation = expectation(description: "adManagerRequestConfiguration should be called")

        handler.adManagerRequestConfiguration = { request in
            request.publisherProvidedID = "test-ppid"
            expectation.fulfill()
        }

        handler.requestAd(with: nil)

        waitForExpectations(timeout: 1)
    }

    func testInterstitialRequestConfigurationIsCalledDuringAdRequest() {
        let handler = GAMInterstitialEventHandler(adUnitID: "/test/adunit")
        let expectation = expectation(description: "adManagerRequestConfiguration should be called")

        handler.adManagerRequestConfiguration = { request in
            request.publisherProvidedID = "test-ppid"
            expectation.fulfill()
        }

        handler.requestAd(with: nil)

        waitForExpectations(timeout: 1)
    }

    func testRewardedRequestConfigurationIsCalledDuringAdRequest() {
        let handler = GAMRewardedAdEventHandler(adUnitID: "/test/adunit")
        let expectation = expectation(description: "adManagerRequestConfiguration should be called")

        handler.adManagerRequestConfiguration = { request in
            request.publisherProvidedID = "test-ppid"
            expectation.fulfill()
        }

        handler.requestAd(with: nil)

        waitForExpectations(timeout: 1)
    }

    func testConfigureRequestPreservesPublisherProvidedID() {
        let request = makeRequest()

        GAMUtils.configureRequest(
            request,
            bidResponse: nil,
            adManagerRequestConfiguration: { request in
                request.publisherProvidedID = "test-ppid-123"
            }
        )

        XCTAssertEqual(request.request.publisherProvidedID, "test-ppid-123")
    }

    func testConfigureRequestMergesPublisherTargetingWithBidTargeting() {
        let request = makeRequest()
        let bidResponse = BidResponse(
            adUnitId: "test",
            targetingInfo: [
                "hb_pb": "1.50",
                "hb_bidder": "appnexus"
            ]
        )

        GAMUtils.configureRequest(
            request,
            bidResponse: bidResponse,
            adManagerRequestConfiguration: { request in
                request.customTargeting = ["publisher_key": "publisher_value"]
            }
        )

        XCTAssertEqual(request.customTargeting?["publisher_key"] as? String, "publisher_value")
        XCTAssertEqual(request.customTargeting?["hb_pb"] as? String, "1.50")
        XCTAssertEqual(request.customTargeting?["hb_bidder"] as? String, "appnexus")
    }

    func testConfigureRequestLetsBidTargetingOverridePublisherTargeting() {
        let request = makeRequest()
        let bidResponse = BidResponse(
            adUnitId: "test",
            targetingInfo: [
                "hb_pb": "1.50",
                "hb_cache_id": "prebid-cache-id"
            ]
        )

        GAMUtils.configureRequest(
            request,
            bidResponse: bidResponse,
            adManagerRequestConfiguration: { request in
                request.customTargeting = [
                    "hb_pb": "publisher-value",
                    "publisher_key": "publisher_value"
                ]
            }
        )

        XCTAssertEqual(request.customTargeting?["publisher_key"] as? String, "publisher_value")
        XCTAssertEqual(request.customTargeting?["hb_pb"] as? String, "1.50")
        XCTAssertEqual(request.customTargeting?["hb_cache_id"] as? String, "prebid-cache-id")
    }

    func testConfigureRequestPreservesNonStringPublisherTargeting() {
        let request = makeRequest()
        let bidResponse = BidResponse(
            adUnitId: "test",
            targetingInfo: [
                "hb_pb": "1.50"
            ]
        )

        GAMUtils.configureRequest(
            request,
            bidResponse: bidResponse,
            adManagerRequestConfiguration: { request in
                request.customTargeting = [
                    "publisher_key": 42
                ]
            }
        )

        XCTAssertEqual(request.customTargeting?["publisher_key"] as? Int, 42)
        XCTAssertEqual(request.customTargeting?["hb_pb"] as? String, "1.50")
    }

    private func makeRequest(
        file: StaticString = #file,
        line: UInt = #line
    ) -> GAMRequestWrapper {
        guard let request = GAMRequestWrapper() else {
            XCTFail("GAMRequestWrapper should be available", file: file, line: line)
            return GAMRequestWrapper(request: AdManagerRequest())!
        }

        return request
    }
}
