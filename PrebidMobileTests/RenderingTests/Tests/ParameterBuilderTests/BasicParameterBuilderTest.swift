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

import UIKit
import XCTest
@testable import PrebidMobile

class PBMBasicParameterBuilderTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    private var targeting: PrebidRenderingTargeting!
    
    override func setUp() {
        super.setUp()
        
        targeting = .shared
        targeting.parameterDictionary["foo"] = "bar"
        targeting.userAge = 10
    }
    
    override func tearDown() {
        logToFile = nil
        
        super.tearDown()
    }
    
    func testParameterBuilderBannerAUID() {
        
        //Create Builder
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.isInterstitialAd = false
        
        let sdkConfiguration = PrebidConfiguration.mock
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        
        //Run Builder
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check Impression
        PBMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No imp object")
            return
        }
        
        PBMAssertEq(imp.instl, 0)
        PBMAssertEq(imp.displaymanager, "prebid-mobile")
        PBMAssertEq(imp.displaymanagerver, "MOCK_SDK_VERSION")
        PBMAssertEq(imp.secure, 1)
        PBMAssertEq(imp.clickbrowser, 0)
        
        //Check banner
        guard let banner = imp.banner else {
            XCTFail("No banner object!")
            return
        }
        
        PBMAssertEq(banner.api, [])
        
        //Check Regs
        XCTAssertNil(bidRequest.regs.coppa)
    }
    
    func testParameterBuilderExternalBrowser() {
        let adConfiguration = PBMAdConfiguration()
        
        let sdkConfiguration = PrebidConfiguration.mock
        sdkConfiguration.useExternalClickthroughBrowser = true
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No imp object")
            return
        }
        
        PBMAssertEq(imp.clickbrowser, 1)
    }
    
    func testParameterBuilderInterstitialVAST() {
        let adUnit = InterstitialRenderingAdUnit.init(configID: "configId")
        adUnit.adFormat = .video
        let adConfiguration = adUnit.adUnitConfig.adConfiguration
        
        //Run the Builder
        let sdkConfiguration = PrebidConfiguration.mock
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check that this is counted as an interstitial
        PBMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }
        
        PBMAssertEq(imp.instl, 1)
        
        guard let video = imp.video else {
            XCTFail("No video object!")
            return
        }
        
        PBMAssertEq(video.mimes, PBMConstants.supportedVideoMimeTypes)
        PBMAssertEq(video.protocols, [2,5])
        PBMAssertEq(video.placement, 5)
        PBMAssertEq(video.delivery!, [3])
        PBMAssertEq(video.pos, 7)
    }
    
    func testParameterBuilderOutstream() {
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.adFormat = .videoInternal
        adConfiguration.size = CGSize(width: 300, height: 250)
        
        //Run the Builder
        let sdkConfiguration = PrebidConfiguration.mock
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        PBMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }
        PBMAssertEq(imp.instl, 0)
        
        guard let video = imp.video else {
            XCTFail("No video object!")
            return
        }
        
        PBMAssertEq(video.mimes, PBMConstants.supportedVideoMimeTypes)
        PBMAssertEq(video.protocols, [2,5])
        XCTAssertNil(video.placement)
        
        PBMAssertEq(video.delivery!, [3])
        PBMAssertEq(video.pos, 7)
    }
    
    func testParameterBuilderCOPPANotSet() {
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.isInterstitialAd = false
        
        let sdkConfiguration = PrebidConfiguration.mock
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        
        //Run Builder
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        XCTAssertNil(bidRequest.regs.coppa)
    }
    
    func testParameterBuilderCOPPA() {
        self.testParameterBuilderCOPPA(value: nil, expectedRegValue: nil)
        self.testParameterBuilderCOPPA(value: 0, expectedRegValue: 0)
        self.testParameterBuilderCOPPA(value: 1, expectedRegValue: 1)
        self.testParameterBuilderCOPPA(value: 1.3, expectedRegValue: nil)
    }
    
    func testParameterBuilderCOPPA(value: NSNumber?, expectedRegValue: NSNumber?) {
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.isInterstitialAd = false
        
        if let coppa = value {
            targeting.coppa = coppa
        }
        
        let sdkConfiguration = PrebidConfiguration.mock
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        
        //Run Builder
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        PBMAssertEq(bidRequest.regs.coppa, expectedRegValue)
    }
    
    func testInvalidProperties() {
        let adConfiguration = PBMAdConfiguration()
        
        let sdkConfiguration = PrebidConfiguration.mock
        let bidRequest = PBMORTBBidRequest()
        
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        
        builder.build(bidRequest)
        
        logToFile = .init()
        
        builder.adConfiguration = nil
        builder.build(bidRequest)
        var log = PBMLog.shared.getLogFileAsString()
        XCTAssertTrue(log.contains("Invalid properties"))
        
        logToFile = nil
        logToFile = .init()
        
        builder.adConfiguration = adConfiguration
        builder.sdkConfiguration = nil
        builder.build(bidRequest)
        log = PBMLog.shared.getLogFileAsString()
        XCTAssertTrue(log.contains("Invalid properties"))
        
        logToFile = nil
        logToFile = .init()
        
        builder.sdkConfiguration = sdkConfiguration
        builder.sdkVersion = nil
        builder.build(bidRequest)
        log = PBMLog.shared.getLogFileAsString()
        XCTAssertTrue(log.contains("Invalid properties"))
    }
    
    func testParameterBuilderVideoPlacement() {
        self.testParameterBuilderVideo(placement: .undefined,
                                       isInterstitial: false,
                                       expectedPlacement: 0)
        
        self.testParameterBuilderVideo(placement: .inFeed,
                                       isInterstitial: false,
                                       expectedPlacement: 4)
        
        self.testParameterBuilderVideo(placement: .undefined,
                                       isInterstitial: true,
                                       expectedPlacement: 5)
    }
    
    func testParameterBuilderVideo(placement: VideoPlacementType,
                                   isInterstitial: Bool,
                                   expectedPlacement:Int) {
        
        var adConfiguration: PBMAdConfiguration
        if (isInterstitial) {
            let adUnit = InterstitialRenderingAdUnit.init(configID: "configId")
            adUnit.adFormat = .video
            adConfiguration = adUnit.adUnitConfig.adConfiguration
        } else {
            let adUnit = BannerView.init(frame: CGRect.zero, configID: "configId", adSize: CGSize.zero)
            adUnit.adFormat = .video
            if (placement != .undefined) {
                adUnit.videoPlacementType = placement
            }
            adConfiguration = adUnit.adUnitConfig.adConfiguration
        }
        
        let sdkConfiguration = PrebidConfiguration.mock
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        guard let video = bidRequest.imp.first?.video else {
            XCTFail("No video object!")
            return
        }
        
        if (expectedPlacement == 0) {
            XCTAssertNil(video.placement)
        } else {
            PBMAssertEq(video.placement?.intValue, expectedPlacement)
        }
        
    }
    
    func testParameterBuilderDeprecatedProperties() {
        
        //Create Builder
        let adConfiguration = PBMAdConfiguration()
        
        targeting.addParam("rab", withName: "foo")
        adConfiguration.isInterstitialAd = false
        
        let sdkConfiguration = PrebidConfiguration.mock
        let builder = PBMBasicParameterBuilder(adConfiguration:adConfiguration,
                                               sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        //Run Builder
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check Regs
        XCTAssertNil(bidRequest.regs.coppa)
    }
}
