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

import XCTest
@testable import PrebidMobile

class PrebidParameterBuilderTest: XCTestCase {
    
    private let sdkConfiguration = Prebid.mock
    private var targeting: Targeting!
    
    override func setUp() {
        super.setUp()
        targeting = Targeting.shared
        UtilitiesForTesting.resetTargeting(targeting)
    }
    
    override func tearDown() {
        UtilitiesForTesting.resetTargeting(targeting)
    }
    
    func testAdPositionHeader() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
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
        XCTAssertEqual(banner.pos?.intValue, 4)
    }
    
    func testAdPositionFullScreen() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let interstitialAdUnit =  InterstitialRenderingAdUnit(configID: configId)
        
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
        XCTAssertEqual(banner.pos?.intValue, 7)
    }
    
    func testAdditionalSizes() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
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
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
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
        XCTAssertEqual(video.pos.intValue, 4)
    }
    
    func testFirstPartyData() {
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        
        let bidRequest = PBMORTBBidRequest()
        
        targeting.addBidderToAccessControlList("prebid-mobile")
        targeting.updateUserData(key: "fav_colors", value: Set(["red", "orange"]))
        targeting.addContextData(key: "last_search_keywords", value: "wolf")
        targeting.addContextData(key: "last_search_keywords", value: "pet")
        
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"
        
        adUnitConfig.addUserData([userDataObject1, userDataObject2])
        let objects = adUnitConfig.getUserData()!
        
        adUnitConfig.addContextData(key: "buy", value: "mushrooms")
        
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
        
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, userDataObject1)
        
        let extData = bidRequest.app.extPrebid.data!
        XCTAssertTrue(extData.keys.count == 1)
        let extValues = extData["last_search_keywords"]!.sorted()
        XCTAssertEqual(extValues, ["pet", "wolf"])

        let userData = bidRequest.user.ext!["data"] as! [String :AnyHashable]
        XCTAssertTrue(userData.keys.count == 1)
        let userValues = userData["fav_colors"] as! Array<String>
        XCTAssertEqual(Set(userValues), ["red", "orange"])
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Impression object!")
            return
        }
        
        XCTAssertEqual(imp.extContextData, ["buy": ["mushrooms"]])
    }
    
    func testPbAdSlotWithContextDataDictionary() {
        let testAdSlot = "test ad slot"
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        
        adUnitConfig.setPbAdSlot(testAdSlot)
        
        adUnitConfig.addContextData(key: "key", value: "value1")
        adUnitConfig.addContextData(key: "key", value: "value2")
        
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
        
        bidRequest.imp.forEach { imp in
            guard let extContextData = imp.extContextData as? [String: Any], let result = extContextData["key"] as? [String] else {
                XCTFail()
                return
            }
           
            XCTAssertEqual(Set(result), Set(["value1", "value2"]))
            XCTAssertEqual(extContextData["adslot"] as? String, testAdSlot)
        }
    }
    
    func testSourceOMID() {
        let bidRequest = PBMORTBBidRequest()
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        
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
        
        XCTAssertEqual(bidRequest.source.extOMID.omidpn, "Prebid")
        XCTAssertEqual(bidRequest.source.extOMID.omidpv, PBMFunctions.omidVersion())
        
        targeting.omidPartnerVersion = "test omid version"
        targeting.omidPartnerName = "test omid name"
        
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
        
        XCTAssertEqual(bidRequest.source.extOMID.omidpn, "test omid name")
        XCTAssertEqual(bidRequest.source.extOMID.omidpv, "test omid version")
        
        targeting.omidPartnerVersion = nil
        targeting.omidPartnerName = nil
    }
    
    func testSubjectToCOPPA() {
        let bidRequest = PBMORTBBidRequest()
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        
        targeting.subjectToCOPPA = true
        
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
        
        XCTAssertEqual(bidRequest.regs.coppa, 1)
        
        targeting.subjectToCOPPA = false
        
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
        
        XCTAssertEqual(bidRequest.regs.coppa, 0)
    }
    
    func testSubjectToGDPR() {
        let bidRequest = PBMORTBBidRequest()
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        
        targeting.subjectToGDPR = true
        
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
        
        guard let extRegs = bidRequest.regs.ext as? [String: Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(extRegs["gdpr"] as? NSNumber, 1)
    }
    
    func testGDPRConsentString() {
        let testGDPRConsentString = "test gdpr consent string"
        let bidRequest = PBMORTBBidRequest()
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        
        targeting.gdprConsentString = testGDPRConsentString
        
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
        
        guard let userExt = bidRequest.user.ext as? [String: Any] else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(userExt["consent"] as? String, testGDPRConsentString)
    }
}
