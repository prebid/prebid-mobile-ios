/*   Copyright 2018-2023 Prebid.org, Inc.

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
import TestUtils
@testable import PrebidMobile

class PrebidAdUnitTests: XCTestCase {
    
    func testFetchDemandWithNoParameters() {
        let expectation = expectation(description: "fetchDemand completion")
        expectation.expectedFulfillmentCount = 2
        
        let request = PrebidRequest()
        let adUnit = PrebidAdUnit(configId: "test-config-id")
        
        adUnit.fetchDemand(adObject: () as AnyObject, request: request) { bidInfo in
            expectation.fulfill()
            XCTAssertEqual(bidInfo.resultCode, .prebidInvalidRequest)
        }
        
        adUnit.fetchDemand(request: request) { bidInfo in
            expectation.fulfill()
            XCTAssertEqual(bidInfo.resultCode, .prebidInvalidRequest)
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAdUnitConfiguration_banner() {
        let testObject: AnyObject = () as AnyObject
        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2

        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let bannerParameters = BannerParameters()
        bannerParameters.api = [.MRAID_3]
        bannerParameters.adSizes = [CGSize(width: 300, height: 250), CGSize(width: 320, height: 50)]

        let request = PrebidRequest(bannerParameters: bannerParameters)

        var config = adUnit.getConfiguration()
        
        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            XCTAssertNotNil(config.adConfiguration.bannerParameters)
            XCTAssertEqual(config.adFormats, [.banner])
            XCTAssertEqual(config.adSize, CGSize(width: 300, height: 250))
            XCTAssertEqual(config.additionalSizes, [CGSize(width: 320, height: 50)])
            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()

        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            XCTAssertNotNil(config.adConfiguration.bannerParameters)
            XCTAssertEqual(config.adFormats, [.banner])
            XCTAssertEqual(config.adSize, CGSize(width: 300, height: 250))
            XCTAssertEqual(config.additionalSizes, [CGSize(width: 320, height: 50)])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_video() {
        let testObject: AnyObject = () as AnyObject
        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2

        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let videoParameters = VideoParameters(mimes: ["video/mp4"])
        videoParameters.adSize = CGSize(width: 300, height: 250)

        let request = PrebidRequest(videoParameters: videoParameters)
        
        var config = adUnit.getConfiguration()

        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            XCTAssertNotNil(config.adConfiguration.videoParameters)
            XCTAssertEqual(config.adSize, CGSize(width: 300, height: 250))
            XCTAssertEqual(config.adFormats, [.video])
            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()
        
        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            XCTAssertNotNil(config.adConfiguration.videoParameters)
            XCTAssertEqual(config.adSize, CGSize(width: 300, height: 250))
            XCTAssertEqual(config.adFormats, [.video])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_native() {
        let testObject: AnyObject = () as AnyObject
        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2

        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let nativeParameters = NativeParameters()

        let title = NativeAssetTitle(length: 90, required: true)
        let body = NativeAssetData(type: DataAsset.description, required: true)
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)

        nativeParameters.assets = [title, body, cta]

        let request = PrebidRequest(nativeParameters: nativeParameters)
        
        var config = adUnit.getConfiguration()

        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            XCTAssertNotNil(config.nativeAdConfiguration)
            XCTAssertEqual(config.nativeAdConfiguration?.markupRequestObject.assets, [title, body, cta])
            XCTAssertEqual(config.adFormats, [.native])
            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()

        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            XCTAssertNotNil(config.nativeAdConfiguration)
            XCTAssertEqual(config.nativeAdConfiguration?.markupRequestObject.assets, [title, body, cta])
            XCTAssertEqual(config.adFormats, [.native])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_interstitial() {
        let testObject: AnyObject = () as AnyObject
        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2

        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let bannerParameters = BannerParameters()
        bannerParameters.interstitialMinWidthPerc = 4
        bannerParameters.interstitialMinHeightPerc = 4

        let request = PrebidRequest(bannerParameters: bannerParameters, isInterstitial: true)
        
        var config = adUnit.getConfiguration()

        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            XCTAssertTrue(config.adConfiguration.isInterstitialAd)
            XCTAssertEqual(config.adPosition, .fullScreen)
            XCTAssertEqual(config.adConfiguration.videoParameters.placement, .Interstitial)
            XCTAssertEqual(config.adConfiguration.videoParameters.plcmnt, .Interstitial)
            XCTAssertEqual(config.minSizePerc, NSValue(cgSize: CGSize(width: 4, height: 4)))
            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()

        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            XCTAssertTrue(config.adConfiguration.isInterstitialAd)
            XCTAssertEqual(config.adPosition, .fullScreen)
            XCTAssertEqual(config.adConfiguration.videoParameters.placement, .Interstitial)
            XCTAssertEqual(config.adConfiguration.videoParameters.plcmnt, .Interstitial)
            XCTAssertEqual(config.minSizePerc, NSValue(cgSize: CGSize(width: 4, height: 4)))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_interstitial_rewarded() {
        let testObject: AnyObject = () as AnyObject
        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2

        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let videoParameters = VideoParameters(mimes: ["video/mp4"])

        let request = PrebidRequest(videoParameters: videoParameters, isInterstitial: true, isRewarded: true)
        
        var config = adUnit.getConfiguration()

        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            XCTAssertTrue(config.adConfiguration.isInterstitialAd)
            XCTAssertTrue(config.adConfiguration.isRewarded)
            XCTAssertEqual(config.adPosition, .fullScreen)
            XCTAssertEqual(config.adConfiguration.videoParameters.placement, .Interstitial)
            XCTAssertEqual(config.adConfiguration.videoParameters.plcmnt, .Interstitial)

            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()

        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            XCTAssertTrue(config.adConfiguration.isInterstitialAd)
            XCTAssertTrue(config.adConfiguration.isRewarded)
            XCTAssertEqual(config.adPosition, .fullScreen)
            XCTAssertEqual(config.adConfiguration.videoParameters.placement, .Interstitial)
            XCTAssertEqual(config.adConfiguration.videoParameters.plcmnt, .Interstitial)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_extData() {
        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let request = PrebidRequest(bannerParameters: BannerParameters())
        request.addExtData(key: "key1", value: "value1")

        let testObject: AnyObject = () as AnyObject

        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2

        var config = adUnit.getConfiguration()
        
        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            XCTAssertEqual(config.getExtData(), ["key1": ["value1"]])
            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()

        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            XCTAssertEqual(config.getExtData(), ["key1": ["value1"]])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_appContent() {
        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let request = PrebidRequest(bannerParameters: BannerParameters())

        let appContent = PBMORTBAppContent()
        let contentData = PBMORTBContentData()
        contentData.name = "test"
        appContent.data = [contentData]

        request.setAppContent(appContent)

        let testObject: AnyObject = () as AnyObject

        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2
        
        var config = adUnit.getConfiguration()

        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            let realAppContent = config.getAppContent()
            XCTAssertEqual(realAppContent?.data?.count, 1)
            XCTAssertEqual(realAppContent?.data?.first?.name, "test")
            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()

        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            let realAppContent = config.getAppContent()
            XCTAssertEqual(realAppContent?.data?.count, 1)
            XCTAssertEqual(realAppContent?.data?.first?.name, "test")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_userData() {
        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let request = PrebidRequest(bannerParameters: BannerParameters())

        let contentData = PBMORTBContentData()
        contentData.name = "test"

        request.addUserData([contentData])

        let testObject: AnyObject = () as AnyObject

        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2
        
        var config = adUnit.getConfiguration()

        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            let realUserData = config.getUserData()
            XCTAssertEqual(realUserData?.count, 1)
            XCTAssertEqual(realUserData?.first?.name, "test")
            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()

        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            let realUserData = config.getUserData()
            XCTAssertEqual(realUserData?.count, 1)
            XCTAssertEqual(realUserData?.first?.name, "test")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_extKeywords() {
        var adUnit = PrebidAdUnit(configId: "test-config-id")

        let request = PrebidRequest(bannerParameters: BannerParameters())
        request.addExtKeyword("test1")

        let testObject: AnyObject = () as AnyObject

        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2
        
        var config = adUnit.getConfiguration()

        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            XCTAssertEqual(config.getExtKeywords(), ["test1"])
            expectation.fulfill()
        }

        adUnit = PrebidAdUnit(configId: "test-config-id")
        config = adUnit.getConfiguration()

        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            XCTAssertEqual(config.getExtKeywords(), ["test1"])
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAdUnitConfiguration_gpid() {
        let expectation = expectation(description: "\(#function)")
        expectation.expectedFulfillmentCount = 2
        
        let gpid = "/12345/home_screen#identifier"
        var adUnit = PrebidAdUnit(configId: "test-config-id")
        
        let request = PrebidRequest(bannerParameters: BannerParameters())
        request.setGPID(gpid)
        
        // fetchDemand(request:completion)
        adUnit.fetchDemand(request: request) { _ in
            expectation.fulfill()
            XCTAssertEqual(adUnit.getConfiguration().gpid, gpid)
        }
        
        let testObject: AnyObject = () as AnyObject
        adUnit = PrebidAdUnit(configId: "test-config-id")
        
        // fetchDemand(adObject:request:completion)
        adUnit.fetchDemand(adObject: testObject, request: request) { _ in
            expectation.fulfill()
            XCTAssertEqual(adUnit.getConfiguration().gpid, gpid)
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSetAdPosition() {
        let request = PrebidRequest(bannerParameters: BannerParameters())
        request.adPosition = .header
        
        let adUnit = PrebidAdUnit(configId: "test-config-id")
        adUnit.fetchDemand(request: request, completion: { _ in })
        
        XCTAssertEqual(adUnit.getConfiguration().adPosition, .header)
        
        request.adPosition = .footer
        adUnit.fetchDemand(request: request, completion: { _ in })
        
        XCTAssertEqual(adUnit.getConfiguration().adPosition, .footer)
    }
}
