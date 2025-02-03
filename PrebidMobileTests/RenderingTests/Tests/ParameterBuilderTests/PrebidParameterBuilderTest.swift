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
        Prebid.reset()
    }
    
    func testAdPositionHeader() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormats = [.banner]
        
        var bidRequest = buildBidRequest(with: adUnitConfig)
        
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
        
        bidRequest = buildBidRequest(with: adUnitConfig)
        
        XCTAssertEqual(bidRequest.imp.first?.banner?.pos?.intValue, AdPosition.header.rawValue)
        XCTAssertEqual(bidRequest.imp.first?.banner?.pos?.intValue, 4)
    }
    
    func testAdPositionFullScreen() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let interstitialAdUnit = BaseInterstitialAdUnit(
            configID: configId,
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        
        let bidRequest = buildBidRequest(with: interstitialAdUnit.adUnitConfig)
        
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
        adUnitConfig.adFormats = [.banner]
        
        var bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let banner = bidRequest.imp.first?.banner else {
            XCTFail("No Banner object!")
            return
        }
        
        XCTAssertEqual(banner.format.count, 1)
        PBMAssertEq(banner.format.first?.w, 320)
        PBMAssertEq(banner.format.first?.h, 50)
        
        adUnitConfig.additionalSizes = [CGSize(width: 728, height: 90)]
        
        bidRequest = buildBidRequest(with: adUnitConfig)
        
        XCTAssertEqual(bidRequest.imp.first?.banner?.format.count, 2)
        PBMAssertEq(bidRequest.imp.first?.banner?.format[1].w, 728)
        PBMAssertEq(bidRequest.imp.first?.banner?.format[1].h, 90)
    }
    
    func testInterstitialDeviceSizeNotSet() {
        let adUnitConfig = AdUnitConfig(configId: "test-config-id", size: CGSize.zero)
        adUnitConfig.adFormats = [.banner, .video]
        adUnitConfig.adConfiguration.isInterstitialAd = true
        
        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        // If no ad size is specified, the SDK should not assign a device size for interstitials
        XCTAssertEqual(bidRequest.imp.first?.banner?.format.count, 0)
        
        XCTAssertNil(bidRequest.imp.first?.video?.w)
        XCTAssertNil(bidRequest.imp.first?.video?.h)
    }
    
    func testVideo() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adFormats = [.video]
        adUnitConfig.adPosition = .header
        
        let parameters = VideoParameters(mimes: [])
        parameters.linearity = 1
        parameters.placement = .Interstitial
        parameters.plcmnt = .Interstitial
        parameters.api = [Signals.Api.MRAID_1]
        parameters.minDuration = 1
        parameters.maxDuration = 10
        parameters.minBitrate = 1
        parameters.maxBitrate = 10
        parameters.startDelay = Signals.StartDelay.GenericMidRoll
        
        adUnitConfig.adConfiguration.videoParameters = parameters
        
        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let video = bidRequest.imp.first?.video else {
            XCTFail("No Video object!")
            return
        }
        
        PBMAssertEq(video.linearity, 1)
        PBMAssertEq(video.placement, 5)
        PBMAssertEq(video.plcmt, 3)
        PBMAssertEq(video.w, 320)
        PBMAssertEq(video.h, 50)
        PBMAssertEq(video.api, [3])
        PBMAssertEq(video.minduration, 1)
        PBMAssertEq(video.maxduration, 10)
        PBMAssertEq(video.minbitrate, 1)
        PBMAssertEq(video.maxbitrate, 10)
        PBMAssertEq(video.protocols, [2, 5])
        PBMAssertEq(video.startdelay, -1)
        PBMAssertEq(video.mimes, PBMConstants.supportedVideoMimeTypes)
        PBMAssertEq(video.playbackend, 2)
        PBMAssertEq(video.delivery, [3])
        XCTAssertEqual(video.pos.intValue, AdPosition.header.rawValue)
        XCTAssertEqual(video.pos.intValue, 4)
    }
    
    func testFirstPartyData() {
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        
        targeting.addBidderToAccessControlList("prebid-mobile")
        targeting.updateUserData(key: "fav_colors", value: Set(["red", "orange"]))
        targeting.addAppExtData(key: "last_search_keywords", value: "wolf")
        targeting.addAppExtData(key: "last_search_keywords", value: "pet")
        
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"
        
        adUnitConfig.addUserData([userDataObject1, userDataObject2])
        let objects = adUnitConfig.getUserData()!
        
        adUnitConfig.addExtData(key: "buy", value: "mushrooms")
        
        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        XCTAssertEqual(bidRequest.extPrebid.dataBidders, ["prebid-mobile"])
        
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, userDataObject1)
        
        let extData = bidRequest.app.ext.data!
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
        
        XCTAssertEqual(imp.extData, ["buy": ["mushrooms"]])
    }
    
    func testAdUnitSpecificKeywords() {
        let adUnit = AdUnit(configId: "config_id", size: nil, adFormats: [.banner])
        
        let expectedKeywords = Set<String>(["keyword1", "keyword2", "keyword3"])
        
        adUnit.addExtKeywords(expectedKeywords)
        
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        
        bidRequest.imp.forEach { imp in
            let resultKeywords = Set<String>((imp.extKeywords?.components(separatedBy: ",")) ?? [])
            XCTAssertEqual(resultKeywords, expectedKeywords)
        }
    }

    func testPbAdSlotWithContextDataDictionary() {
        let testAdSlot = "test ad slot"
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        adUnitConfig.setPbAdSlot(testAdSlot)

        adUnitConfig.addExtData(key: "key", value: "value1")
        adUnitConfig.addExtData(key: "key", value: "value2")

        let bidRequest = buildBidRequest(with: adUnitConfig)

        bidRequest.imp.forEach { imp in
            guard let extData = imp.extData as? [String: Any], let result = extData["key"] as? [String] else {
                XCTFail()
                return
            }

            XCTAssertEqual(Set(result), Set(["value1", "value2"]))
            XCTAssertEqual(extData["adslot"] as? String, testAdSlot)
            XCTAssertEqual(extData["pbadslot"] as? String, testAdSlot)
        }
    }

    func testSourceOMID() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        Targeting.shared.omidPartnerName = "Prebid"
        Targeting.shared.omidPartnerVersion = PBMFunctions.sdkVersion()
        var bidRequest = buildBidRequest(with: adUnitConfig)

        XCTAssertEqual(bidRequest.source.extOMID.omidpn, "Prebid")
        XCTAssertEqual(bidRequest.source.extOMID.omidpv, PBMFunctions.sdkVersion())

        targeting.omidPartnerVersion = "test omid version"
        targeting.omidPartnerName = "test omid name"

        bidRequest = buildBidRequest(with: adUnitConfig)

        XCTAssertEqual(bidRequest.source.extOMID.omidpn, "test omid name")
        XCTAssertEqual(bidRequest.source.extOMID.omidpv, "test omid version")

        targeting.omidPartnerVersion = nil
        targeting.omidPartnerName = nil
    }

    func testSubjectToCOPPA() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        targeting.subjectToCOPPA = true

        var bidRequest = buildBidRequest(with: adUnitConfig)
        
        XCTAssertEqual(bidRequest.regs.coppa, 1)

        targeting.subjectToCOPPA = false

        bidRequest = buildBidRequest(with: adUnitConfig)

        XCTAssertEqual(bidRequest.regs.coppa, 0)
    }

    func testSubjectToGDPR() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        targeting.subjectToGDPR = true

        let bidRequest = buildBidRequest(with: adUnitConfig)

        guard let extRegs = bidRequest.regs.ext as? [String: Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(extRegs["gdpr"] as? NSNumber, 1)
    }

    func testGDPRConsentString() {
        let testGDPRConsentString = "test gdpr consent string"

        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        targeting.gdprConsentString = testGDPRConsentString
        
        let bidRequest = buildBidRequest(with: adUnitConfig)

        guard let userExt = bidRequest.user.ext as? [String: Any] else {
            XCTFail()
            return
        }

        XCTAssertEqual(userExt["consent"] as? String, testGDPRConsentString)
    }

    func testStoredBidResponses() {
        Prebid.shared.addStoredBidResponse(bidder: "testBidder", responseId: "testResponseId")

        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        let bidRequest = buildBidRequest(with: adUnitConfig)

        let resultStoredBidResponses = [
            [
                "bidder": "testBidder",
                "id" : "testResponseId"
            ]
        ]

        XCTAssertEqual(bidRequest.extPrebid.storedBidResponses, resultStoredBidResponses)
    }
    
    func testDefaultCaching() {
        XCTAssertFalse(sdkConfiguration.useCacheForReportingWithRenderingAPI)

        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard bidRequest.extPrebid.cache == nil else {
            XCTFail("Cache should be nil by default.")
            return
        }
    }
    
    func testEnableCaching() {
        sdkConfiguration.useCacheForReportingWithRenderingAPI = true

        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))

        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let cache = bidRequest.extPrebid.cache else {
            XCTFail("Cache shouldn't be nil if useCacheForReportingWithRenderingAPI is turned on.")
            return
        }
        
        XCTAssertNotNil(cache["bids"])
        XCTAssertNotNil(cache["vastxml"])
    }
    
    func testCachingForOriginalAPI() {
        // This should not impact on caching the bid in original api
        sdkConfiguration.useCacheForReportingWithRenderingAPI = false
        
        let adUnit = AdUnit(configId: "test", size: CGSize(width: 320, height: 50), adFormats: [.banner])
        let adUnitConfig = adUnit.adUnitConfig
        
        let bidRequest = buildBidRequest(with: adUnitConfig)
        
        guard let cache = bidRequest.extPrebid.cache else {
            XCTFail("Cache shouldn't be nil for original api.")
            return
        }
        
        XCTAssertNotNil(cache["bids"])
        XCTAssertNotNil(cache["vastxml"])
    }
    
    func testDefaultAPISignalsInAllAdUnits() {
        // Original API
        let adUnit = AdUnit(configId: "test", size: CGSize(width: 320, height: 50), adFormats: [.banner])
        
        var bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        
        bidRequest.imp.forEach {
            // API signals should be nil for original API
            XCTAssertEqual($0.banner?.api, nil)
        }
        
        let apiSignalsAsNumbers = PrebidConstants.supportedRenderingBannerAPISignals.map { NSNumber(value: $0.value) }
        
        // Rendering API
        let renderingBannerAdUnit = BannerView(frame: .init(origin: .zero, size: CGSize(width: 320, height: 50)), configID: "test", adSize: CGSize(width: 320, height: 50))
        bidRequest = buildBidRequest(with: renderingBannerAdUnit.adUnitConfig)
        
        bidRequest.imp.forEach { imp in
            // Supported banner api signals for rendering API is MRAID_1, MRAID_2, MRAID_3, OMID_1
            XCTAssertEqual(imp.banner?.api, apiSignalsAsNumbers)
        }
        
        let redenderingInterstitialAdUnit = BaseInterstitialAdUnit(
            configID: "configID",
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        
        bidRequest = buildBidRequest(with: redenderingInterstitialAdUnit.adUnitConfig)
        
        bidRequest.imp.forEach {
            // Supported banner api signals for rendering API is MRAID_1, MRAID_2, MRAID_3, OMID_1
            XCTAssertEqual($0.banner?.api, apiSignalsAsNumbers)
        }
        
        // Mediation API
        let mediationBannerAdUnit = MediationBannerAdUnit(configID: "configId", size: CGSize(width: 320, height: 50), mediationDelegate: MockMediationUtils(adObject: MockAdObject()))
        bidRequest = buildBidRequest(with: mediationBannerAdUnit.adUnitConfig)
        
        bidRequest.imp.forEach {
            // Supported banner api signals for rendering API is MRAID_1, MRAID_2, MRAID_3, OMID_1
            XCTAssertEqual($0.banner?.api, apiSignalsAsNumbers)
        }
        
        let mediationInterstitialAdUnit = MediationBaseInterstitialAdUnit(configId: "configId", mediationDelegate: MockMediationUtils(adObject: MockAdObject()))
        bidRequest = buildBidRequest(with: mediationInterstitialAdUnit.adUnitConfig)
        
        bidRequest.imp.forEach {
            // Supported banner api signals for rendering API is MRAID_1, MRAID_2, MRAID_3, OMID_1
            XCTAssertEqual($0.banner?.api, apiSignalsAsNumbers)
        }
    }
    
    func testDefaultBannerParameters_DisplayBanner_OriginalAPI() {
        let adUnit = BannerAdUnit(configId: "test", size: CGSize(width: 300, height: 250))
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        PBMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }

        guard let banner = imp.banner else {
            XCTFail("No banner object!")
            return
        }

        XCTAssertEqual(banner.pos, nil)
        XCTAssertEqual(banner.api, nil)
    }
    
    func testDefaultVideoParameters_VideoBanner_OriginalAPI() {
        let adUnit = BannerAdUnit(configId: "configId", size: CGSize(width: 300, height: 250))
        adUnit.adFormats = [.video]
        
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        PBMAssertEq(bidRequest.imp.count, 1)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }

        guard let video = imp.video else {
            XCTFail("No video object!")
            return
        }

        XCTAssertEqual(video.mimes, nil)
        XCTAssertEqual(video.minduration, nil)
        XCTAssertEqual(video.maxduration, nil)
        XCTAssertEqual(video.startdelay, nil)
        XCTAssertEqual(video.linearity, nil)
        XCTAssertEqual(video.minbitrate, nil)
        XCTAssertEqual(video.maxbitrate, nil)
        XCTAssertEqual(video.playbackmethod, nil)
        XCTAssertEqual(video.playbackend, nil)
        XCTAssertEqual(video.protocols, nil)
        XCTAssertEqual(video.playbackend, nil)
        XCTAssertEqual(video.delivery, [3])
        XCTAssertEqual(video.pos, nil)
        XCTAssertEqual(video.api, nil)
        XCTAssertEqual(video.placement, nil)
        XCTAssertEqual(video.plcmt, nil)
        XCTAssertEqual(video.w, 300)
        XCTAssertEqual(video.h, 250)
    }
    
    func testDefaultBannerParameters_DisplayInterstitial_OriginalAPI() {
        let adUnit = InterstitialAdUnit(configId: "test")
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        PBMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }

        guard let banner = imp.banner else {
            XCTFail("No banner object!")
            return
        }

        XCTAssertEqual(banner.pos, 7)
    }
    
    func testDefaultVideoParameters_VideoInterstitial_OriginalAPI() {
        let adUnit = VideoInterstitialAdUnit(configId: "test")
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }

        guard let video = imp.video else {
            XCTFail("No video object!")
            return
        }

        XCTAssertEqual(video.mimes, nil)
        XCTAssertEqual(video.minduration, nil)
        XCTAssertEqual(video.maxduration, nil)
        XCTAssertEqual(video.maxduration, nil)
        XCTAssertEqual(video.minbitrate, nil)
        XCTAssertEqual(video.maxbitrate, nil)
        XCTAssertEqual(video.playbackmethod, nil)
        XCTAssertEqual(video.playbackend, nil)
        XCTAssertEqual(video.linearity, nil)
        XCTAssertEqual(video.protocols, nil)
        XCTAssertEqual(video.playbackend, nil)
        XCTAssertEqual(video.delivery, [3])
        XCTAssertEqual(video.pos, 7)
        XCTAssertEqual(video.placement, 5)
        XCTAssertEqual(video.plcmt, 3)
        XCTAssertEqual(video.api, nil)
    }
    
    func testDefaultVideoParameters_VideoRewarded_OriginalAPI() {
        let adUnit = RewardedVideoAdUnit(configId: "test")
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }

        guard let video = imp.video else {
            XCTFail("No video object!")
            return
        }

        XCTAssertEqual(video.mimes, nil)
        XCTAssertEqual(video.minduration, nil)
        XCTAssertEqual(video.maxduration, nil)
        XCTAssertEqual(video.maxduration, nil)
        XCTAssertEqual(video.minbitrate, nil)
        XCTAssertEqual(video.maxbitrate, nil)
        XCTAssertEqual(video.playbackmethod, nil)
        XCTAssertEqual(video.playbackend, nil)
        XCTAssertEqual(video.linearity, nil)
        XCTAssertEqual(video.protocols, nil)
        XCTAssertEqual(video.playbackend, nil)
        XCTAssertEqual(video.delivery, [3])
        XCTAssertEqual(video.pos, 7)
        XCTAssertEqual(video.placement, 5)
        XCTAssertEqual(video.plcmt, 3)
        XCTAssertEqual(video.api, nil)
    }

    func testDefaultVideoParameters_RenderingAPI() {
        let adUnit = BannerView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 250)), configID: "configId", adSize: CGSize(width: 300, height: 250))
        adUnit.adFormat = .video
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        //Check that this is counted as an interstitial
        PBMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }

        guard let video = imp.video else {
            XCTFail("No video object!")
            return
        }

        PBMAssertEq(video.mimes, PBMConstants.supportedVideoMimeTypes)
        PBMAssertEq(video.protocols, [2,5])
        PBMAssertEq(video.delivery!, [3])
        PBMAssertEq(video.pos, 7)
        PBMAssertEq(video.playbackend, 2)
    }

    func testParameterBuilderInterstitialVAST() {
        let adUnit = BaseInterstitialAdUnit(
            configID: "configID",
            minSizePerc: nil,
            eventHandler: InterstitialEventHandlerStandalone()
        )
        
        adUnit.adUnitConfig.adFormats = [.video]
        
        let adConfiguration = adUnit.adUnitConfig.adConfiguration
        let parameters = VideoParameters(mimes: [])
        parameters.placement = .Interstitial
        parameters.plcmnt = .Interstitial
        parameters.linearity = 1
        adConfiguration.videoParameters = parameters

        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

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
        PBMAssertEq(video.delivery!, [3])
        PBMAssertEq(video.pos, 7)
    }

    func testParameterBuilderOutstream() {
        let adUnit = BannerView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 250)), configID: "configID", adSize: CGSize(width: 300, height: 250))

        let adConfiguration = adUnit.adUnitConfig.adConfiguration
        adConfiguration.adFormats = [.video]
        adConfiguration.size = CGSize(width: 300, height: 250)


        // Run the Builder
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

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
        XCTAssertNil(video.plcmt)

        PBMAssertEq(video.delivery!, [3])
        PBMAssertEq(video.pos, 7)
    }

    func testBannerParameters() {
        // Original API
        let adUnit = AdUnit(configId: "test", size: CGSize(width: 320, height: 50), adFormats: [.banner])
        adUnit.adUnitConfig.adFormats = [.banner]

        let bannerParameters = BannerParameters()
        bannerParameters.api = [.MRAID_1, .MRAID_2, .MRAID_3, .OMID_1, .ORMMA, .VPAID_1, .VPAID_2, .ORMMA]

        adUnit.adUnitConfig.adConfiguration.bannerParameters = bannerParameters

        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        bidRequest.imp.forEach {
            XCTAssertEqual($0.banner?.api, [3, 5, 6, 7, 4, 1, 2, 4])
        }
    }
    
    func testBannerParameters_deprecatedDisplayFormat() {
        // Original API
        let adUnit = AdUnit(configId: "test", size: CGSize(width: 320, height: 50), adFormats: [.display])

        let bannerParameters = BannerParameters()
        bannerParameters.api = [.MRAID_1, .MRAID_2, .MRAID_3, .OMID_1, .ORMMA, .VPAID_1, .VPAID_2, .ORMMA]

        adUnit.adUnitConfig.adConfiguration.bannerParameters = bannerParameters

        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        bidRequest.imp.forEach {
            XCTAssertEqual($0.banner?.api, [3, 5, 6, 7, 4, 1, 2, 4])
        }
    }

    func testVideoParameters() {
        // Original API
        let adUnit = AdUnit(configId: "test", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        adUnit.adUnitConfig.adFormats = [.video]

        let videoParamters = VideoParameters(mimes: [])
        videoParamters.api = [.MRAID_1, .MRAID_2, .MRAID_3, .OMID_1, .ORMMA, .VPAID_1, .VPAID_2, .ORMMA]
        videoParamters.maxBitrate = 1500
        videoParamters.minBitrate = 30
        videoParamters.maxDuration = 60
        videoParamters.minDuration = 30
        videoParamters.mimes = ["video/mp4"]
        videoParamters.playbackMethod = [.AutoPlaySoundOn]
        videoParamters.protocols = [.VAST_1_0, .VAST_2_0, .VAST_3_0]
        videoParamters.startDelay = .GenericMidRoll
        videoParamters.placement = .InBanner
        videoParamters.plcmnt = .AccompanyingContent
        videoParamters.linearity = 1

        adUnit.adUnitConfig.adConfiguration.videoParameters = videoParamters

        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        bidRequest.imp.forEach {
            XCTAssertEqual($0.video?.api, [3, 5, 6, 7, 4, 1, 2, 4])
            XCTAssertEqual($0.video?.maxbitrate, 1500)
            XCTAssertEqual($0.video?.minbitrate, 30)
            XCTAssertEqual($0.video?.maxduration, 60)
            XCTAssertEqual($0.video?.minduration, 30)
            XCTAssertEqual($0.video?.mimes, ["video/mp4"])
            XCTAssertEqual($0.video?.playbackmethod, [1])
            XCTAssertEqual($0.video?.protocols, [1, 2, 3])
            XCTAssertEqual($0.video?.startdelay, -1)
            XCTAssertEqual($0.video?.placement, 2)
            XCTAssertEqual($0.video?.plcmt, 2)
            XCTAssertEqual($0.video?.linearity, 1)
        }
    }
    
    func testIncludeFormatOnMultiformatAdUnit() {
        let adUnit = BannerAdUnit(configId: "test", size: CGSize(width: 300, height: 250))
        adUnit.adUnitConfig.adFormats = [.banner]
        var bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        XCTAssertNil(bidRequest.extPrebid.targeting["includeformat"])
        
        adUnit.adUnitConfig.adFormats = [.banner, .video]
        bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        XCTAssert(bidRequest.extPrebid.targeting["includeformat"] as! Bool == true)
    }

    func testIncludewinnersAndIncludeBidderKeysAreNil() {
        //Default value
        Prebid.shared.includeWinners = false
        Prebid.shared.includeBidderKeys = false

        let adUnit = BannerAdUnit(configId: "test", size: CGSize(width: 300, height: 250))
        adUnit.adUnitConfig.adFormats = [.banner]
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        XCTAssertNil(bidRequest.extPrebid.targeting["includewinners"])
        XCTAssertNil(bidRequest.extPrebid.targeting["includebidderkeys"])
    }

    
    func testIncludewinnersAndIncludeBidderKeysAreNotNil() {
        //Default value
        Prebid.shared.includeWinners = true
        Prebid.shared.includeBidderKeys = true

        let adUnit = BannerAdUnit(configId: "test", size: CGSize(width: 300, height: 250))
        adUnit.adUnitConfig.adFormats = [.banner]
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        XCTAssertNotNil(bidRequest.extPrebid.targeting["includewinners"])
        XCTAssertNotNil(bidRequest.extPrebid.targeting["includebidderkeys"])
    }
    
    
    func testIncludeWinnersFlagIsTrue() {
        Prebid.shared.includeWinners = true

        let adUnit = BannerAdUnit(configId: "test", size: CGSize(width: 300, height: 250))
        adUnit.adUnitConfig.adFormats = [.banner]
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        XCTAssertNotNil(bidRequest.extPrebid.targeting["includewinners"])
        XCTAssert(bidRequest.extPrebid.targeting["includewinners"] as! Bool == true)
    }

    
    func testIncludeBidderKeys() {
        Prebid.shared.includeBidderKeys = true
        
        let adUnit = BannerAdUnit(configId: "test", size: CGSize(width: 300, height: 250))
        adUnit.adUnitConfig.adFormats = [.banner]
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)

        XCTAssertNotNil(bidRequest.extPrebid.targeting["includebidderkeys"])
        XCTAssert(bidRequest.extPrebid.targeting["includebidderkeys"] as! Bool == true)
    }
    
    func testGPID() {
        let gpid = "/12345/home_screen#identifier"
        let adUnit = AdUnit(configId: "test", size: CGSize.zero, adFormats: [.banner])
        adUnit.setGPID(gpid)
        
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        for imp in bidRequest.imp {
            XCTAssertEqual(imp.extGPID, gpid)
        }
    }
    
    // MARK: Arbitrary ORTB (Deprecated API)
    
    func testArbitraryORTBParams() {
        let gpid = "/12345/home_screen#identifier"
        let ortb = "{\"arbitraryparamkey1\":\"arbitraryparamvalue1\",\"imp\":[{}]}"
        let adUnit = AdUnit(configId: "test", size: CGSize.zero, adFormats: [.banner])
        adUnit.setGPID(gpid)
        adUnit.setOrtbConfig(ortb)

        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        
        XCTAssertEqual(bidRequest.ortbObject?["arbitraryparamkey1"] as? String, "arbitraryparamvalue1")
    }
    
    func testArbitraryORTBParamsIncorrectJSON() {
        let gpid = "/12345/home_screen#identifier"
        let ortb = "{{\"arbitraryparamkey1\":\"arbitraryparamvalue1\",\"imp\":[{}]}"
        let adUnit = AdUnit(configId: "test", size: CGSize.zero, adFormats: [.banner])
        adUnit.setGPID(gpid)
        adUnit.setOrtbConfig(ortb)

        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        
        XCTAssert(bidRequest.ortbObject?.isEmpty == true)
    }
    
    func testExtPrebidSDKRenderers() {
        let mockRenderer1 = MockPrebidMobilePluginRenderer(name: "MockRenderer1", version: "0.0.1")
        let mockRenderer2 = MockPrebidMobilePluginRenderer(name: "MockRenderer2", version: "0.0.2")
        let mockRenderer3 = MockPrebidMobilePluginRenderer(name: "MockRenderer3", version: "0.0.3")
        
        PrebidMobilePluginRegister.shared.registerPlugin(mockRenderer1)
        PrebidMobilePluginRegister.shared.registerPlugin(mockRenderer2)
        PrebidMobilePluginRegister.shared.registerPlugin(mockRenderer3)
        
        let adUnitConfig = AdUnitConfig(configId: "test")
        let bidRequest = buildBidRequest(with: adUnitConfig)
        let realResult = bidRequest.extPrebid.sdkRenderers
        
        XCTAssert(realResult?.count == 3)
    }
    
    func testExtPrebidSDKRenderers_OriginalAPI() {
        let mockRenderer1 = MockPrebidMobilePluginRenderer(name: "MockRenderer1", version: "0.0.1")
        let mockRenderer2 = MockPrebidMobilePluginRenderer(name: "MockRenderer2", version: "0.0.2")
        let mockRenderer3 = MockPrebidMobilePluginRenderer(name: "MockRenderer3", version: "0.0.3")
        
        PrebidMobilePluginRegister.shared.registerPlugin(mockRenderer1)
        PrebidMobilePluginRegister.shared.registerPlugin(mockRenderer2)
        PrebidMobilePluginRegister.shared.registerPlugin(mockRenderer3)
        
        let adUnit = AdUnit(configId: "test", size: CGSize.zero, adFormats: [.banner])
        
        let bidRequest = buildBidRequest(with: adUnit.adUnitConfig)
        XCTAssertNil(bidRequest.extPrebid.sdkRenderers)
    }

    // MARK: - Helpers
    
    func buildBidRequest(with adUnitConfig: AdUnitConfig) -> PBMORTBBidRequest {
        let bidRequest = PBMORTBBidRequest()
        PBMBasicParameterBuilder(
            adConfiguration: adUnitConfig.adConfiguration,
            sdkConfiguration: sdkConfiguration,
            sdkVersion: "MOCK_SDK_VERSION",
            targeting: targeting
        )
        .build(bidRequest)
        
        DeviceInfoParameterBuilder(
            deviceAccessManager: MockDeviceAccessManager(rootViewController: nil)
        )
        .build(bidRequest)
        
        PBMPrebidParameterBuilder(
            adConfiguration: adUnitConfig,
            sdkConfiguration: sdkConfiguration,
            targeting: targeting,
            userAgentService: MockUserAgentService()
        )
        .build(bidRequest)
        
        return bidRequest
    }
}
