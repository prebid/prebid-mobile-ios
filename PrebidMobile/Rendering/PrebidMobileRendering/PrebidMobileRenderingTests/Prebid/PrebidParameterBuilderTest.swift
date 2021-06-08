//
//  PrebidParameterBuilderTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PrebidParameterBuilderTest: XCTestCase {
    
    private let sdkConfiguration = PrebidRenderingConfig.mock
    private var targeting: PrebidRenderingTargeting!
    
    override func setUp() {
        super.setUp()
        targeting = PrebidRenderingTargeting.shared
        UtilitiesForTesting.resetTargeting(targeting)
    }
    
    override func tearDown() {
        UtilitiesForTesting.resetTargeting(targeting)
    }
    
    func testAdPositionHeader() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormat = .display
        
        let builder = PBMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                               sdkConfiguration: sdkConfiguration,
                                               sdkVersion: "MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        PBMPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Banner object!")
            return
        }
        
        PBMAssertEq(imp.instl, 0)
        
        guard let banner = imp.banner else {
            XCTFail("No Banner object!")
            return
        }
        XCTAssertNil(banner.pos)
        
        adUnitConfig.adPosition = .header
        
        PBMPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        XCTAssertEqual(banner.pos?.intValue, AdPosition.header.rawValue)
    }
    
    func testAdPositionFullScreen() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let interstitialAdUnit =  InterstitialAdUnit(configID: configId)
        
        let builder = PBMBasicParameterBuilder(adConfiguration: interstitialAdUnit.adUnitConfig.adConfiguration,
                                               sdkConfiguration: sdkConfiguration,
                                               sdkVersion: "MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        PBMPrebidParameterBuilder(adConfiguration: interstitialAdUnit.adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Banner object!")
            return
        }
        
        PBMAssertEq(imp.instl, 1)
        
        guard let banner = imp.banner else {
            XCTFail("No Banner object!")
            return
        }
        XCTAssertEqual(banner.pos?.intValue, AdPosition.fullScreen.rawValue)
    }
    
    func testAdditionalSizes() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormat = .display
        
        let bidRequest = PBMORTBBidRequest()
        
        PBMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)
        
        PBMPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let banner = bidRequest.imp.first?.banner else {
            XCTFail("No Banner object!")
            return
        }
        
        XCTAssertEqual(banner.format.count, 1)
        PBMAssertEq(banner.format.first?.w, 320)
        PBMAssertEq(banner.format.first?.h, 50)
        
        adUnitConfig.additionalSizes = [CGSize(width: 728, height: 90)]
        PBMPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        XCTAssertEqual(banner.format.count, 2)
        PBMAssertEq(banner.format[1].w, 728)
        PBMAssertEq(banner.format[1].h, 90)
    }
    
    func testVideo() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormat = .video
        adUnitConfig.adPosition = .header
        
        let bidRequest = PBMORTBBidRequest()
        
        PBMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)
        
        PBMPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let video = bidRequest.imp.first?.video else {
            XCTFail("No Video object!")
            return
        }
        
        PBMAssertEq(video.linearity, 1)
        PBMAssertEq(video.w, 320)
        PBMAssertEq(video.h, 50)
        XCTAssertEqual(video.pos.intValue, AdPosition.header.rawValue)
    }
    
    func testNative() {
        let nativeVer = "1.2"
        let desc = NativeAssetData(dataType: .desc)
        let nativeAdConfig = NativeAdConfiguration.init(assets:[desc])
        nativeAdConfig.context = NativeContextType.socialCentric.rawValue
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormat = .display
        adUnitConfig.nativeAdConfiguration = nativeAdConfig
        
        let bidRequest = PBMORTBBidRequest()
        
        PBMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)
        
        PBMPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Impression object!")
            return
        }
        
        PBMAssertEq(imp.native?.ver, nativeVer)
        PBMAssertEq(imp.native?.request,
                    "{\"assets\":[{\"data\":{\"type\":2}}],\"context\":2,\"ver\":\"\(nativeVer)\"}")
    }
    
    func testFirstPartyData() {
        let nativeAdConfig = NativeAdConfiguration.init(assets: [
            NativeAssetData(dataType: .desc),
        ])
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.nativeAdConfiguration = nativeAdConfig
        
        let bidRequest = PBMORTBBidRequest()
        
        targeting.addBidder(toAccessControlList: "prebid-mobile")
        targeting.updateUserData(Set(["red", "orange"]), forKey: "fav_colors")
        targeting.addContextData("wolf", forKey: "last_search_keywords")
        targeting.addContextData("pet", forKey: "last_search_keywords")
        adUnitConfig.addContextData("mushrooms", forKey: "buy")
        
        PBMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)
        
        PBMPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        
        XCTAssertEqual(bidRequest.extPrebid.dataBidders, ["prebid-mobile"])
        
        let extData = bidRequest.app.extPrebid.data!
        XCTAssertTrue(extData.keys.count == 1)
        let extValues = extData["last_search_keywords"]!.sorted()
        XCTAssertEqual(extValues, ["pet", "wolf"])
        
        let userData = bidRequest.user.ext!["data"] as! [String :AnyHashable]
        XCTAssertTrue(userData.keys.count == 1)
        let userValues = userData["fav_colors"] as! Set<String>
        XCTAssertEqual(userValues, ["red", "orange"])
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Impression object!")
            return
        }
        
        PBMAssertEq(imp.native?.request, try! nativeAdConfig.markupRequestObject.toJsonString())
        
        XCTAssertEqual(imp.extContextData, ["buy": ["mushrooms"]])
    }
}
