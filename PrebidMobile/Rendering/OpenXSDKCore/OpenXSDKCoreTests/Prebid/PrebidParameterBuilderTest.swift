//
//  PrebidParameterBuilderTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class PrebidParameterBuilderTest: XCTestCase {
    
    private let sdkConfiguration = OXASDKConfiguration()
    private var targeting: OXATargeting!
    
    override func setUp() {
        super.setUp()
        
        targeting = OXATargeting.withDisabledLock
    }
    
    func testAdPositionHeader() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormat = .display
        
        let builder = OXMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                               sdkConfiguration: sdkConfiguration,
                                               sdkVersion: "MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        OXAPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Banner object!")
            return
        }
        
        OXMAssertEq(imp.instl, 0)
        
        guard let banner = imp.banner else {
            XCTFail("No Banner object!")
            return
        }
        XCTAssertNil(banner.pos)
        
        adUnitConfig.adPosition = .header
        
        OXAPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        XCTAssertEqual(banner.pos?.intValue, OXAAdPosition.header.rawValue)
    }
    
    func testAdPositionFullScreen() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let interstitialAdUnit =  OXAInterstitialAdUnit(configId: configId)
        
        let builder = OXMBasicParameterBuilder(adConfiguration: interstitialAdUnit.adUnitConfig.adConfiguration,
                                               sdkConfiguration: sdkConfiguration,
                                               sdkVersion: "MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        OXAPrebidParameterBuilder(adConfiguration: interstitialAdUnit.adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Banner object!")
            return
        }
        
        OXMAssertEq(imp.instl, 1)
        
        guard let banner = imp.banner else {
            XCTFail("No Banner object!")
            return
        }
        XCTAssertEqual(banner.pos?.intValue, OXAAdPosition.fullScreen.rawValue)
    }
    
    func testAdditionalSizes() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormat = .display
        
        let bidRequest = OXMORTBBidRequest()
        
        OXMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)
        
        OXAPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let banner = bidRequest.imp.first?.banner else {
            XCTFail("No Banner object!")
            return
        }
        
        XCTAssertEqual(banner.format.count, 1)
        OXMAssertEq(banner.format.first?.w, 320)
        OXMAssertEq(banner.format.first?.h, 50)
        
        adUnitConfig.additionalSizes = [NSValue.init(cgSize:CGSize(width: 728, height: 90))]
        OXAPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        XCTAssertEqual(banner.format.count, 2)
        OXMAssertEq(banner.format[1].w, 728)
        OXMAssertEq(banner.format[1].h, 90)
    }
    
    func testVideo() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormat = .video
        adUnitConfig.adPosition = .header
        
        let bidRequest = OXMORTBBidRequest()
        
        OXMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)
        
        OXAPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let video = bidRequest.imp.first?.video else {
            XCTFail("No Video object!")
            return
        }
        
        OXMAssertEq(video.linearity, 1)
        OXMAssertEq(video.w, 320)
        OXMAssertEq(video.h, 50)
        XCTAssertEqual(video.pos.intValue, OXAAdPosition.header.rawValue)
    }
    
    func testNative() {
        let nativeVer = "1.2"
        let desc = OXANativeAssetData(dataType: .desc)
        let nativeAdConfig = OXANativeAdConfiguration.init(assets:[desc])
        nativeAdConfig.context = .socialCentric
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormat = .display
        adUnitConfig.nativeAdConfig = nativeAdConfig
        
        let bidRequest = OXMORTBBidRequest()
        
        OXMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)
        
        OXAPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Impression object!")
            return
        }
        
        OXMAssertEq(imp.native?.ver, nativeVer)
        OXMAssertEq(imp.native?.request,
                    "{\"assets\":[{\"data\":{\"type\":2}}],\"context\":2,\"ver\":\"\(nativeVer)\"}")
    }
    
    func testFirstPartyData() {
        let nativeAdConfig = OXANativeAdConfiguration.init(assets: [
            OXANativeAssetData(dataType: .desc),
        ])
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.nativeAdConfig = nativeAdConfig
        
        let bidRequest = OXMORTBBidRequest()
        
        targeting.addBidder(toAccessControlList: "openx-apollo")
        targeting.updateUserData(Set(["red", "orange"]), forKey: "fav_colors")
        targeting.addContextData("wolf", forKey: "last_search_keywords")
        targeting.addContextData("pet", forKey: "last_search_keywords")
        adUnitConfig.addContextData("mushrooms", forKey: "buy")
        
        OXMBasicParameterBuilder(adConfiguration: adUnitConfig.adConfiguration,
                                 sdkConfiguration: sdkConfiguration,
                                 sdkVersion: "MOCK_SDK_VERSION",
                                 targeting: targeting)
            .build(bidRequest)
        
        OXAPrebidParameterBuilder(adConfiguration: adUnitConfig,
                                  sdkConfiguration: sdkConfiguration,
                                  targeting: targeting,
                                  userAgentService: MockUserAgentService())
            .build(bidRequest)
        
        
        XCTAssertEqual(bidRequest.extPrebid.dataBidders, ["openx-apollo"])
        XCTAssertEqual(bidRequest.app.extPrebid.data, ["last_search_keywords": ["pet", "wolf"]])
        XCTAssertEqual(bidRequest.user.ext!["data"] as? NSObject, ["fav_colors": ["red", "orange"]] as NSObject)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Impression object!")
            return
        }
        
        OXMAssertEq(imp.native?.request, try! nativeAdConfig.markupRequestObject.toJsonString())
        
        XCTAssertEqual(imp.extContextData, ["buy": ["mushrooms"]])
    }
}
