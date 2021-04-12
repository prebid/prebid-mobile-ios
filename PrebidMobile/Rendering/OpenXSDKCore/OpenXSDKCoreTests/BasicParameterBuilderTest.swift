
import UIKit
import XCTest
@testable import OpenXApolloSDK

class OXMBasicParameterBuilderTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    private var targeting: OXATargeting!
    
    override func setUp() {
        super.setUp()
        
        targeting = .withDisabledLock
        targeting.parameterDictionary["foo"] = "bar"
        targeting.userAge = 10
    }

    override func tearDown() {
        logToFile = nil
        
        super.tearDown()
    }

    func testParameterBuilderBannerAUID() {
        
        //Create Builder
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.isInterstitialAd = false
        
        let sdkConfiguration = OXASDKConfiguration()
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        
        //Run Builder
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check Impression
        OXMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No imp object")
            return
        }
        
        OXMAssertEq(imp.instl, 0)
        OXMAssertEq(imp.displaymanager, "openx")
        OXMAssertEq(imp.displaymanagerver, "MOCK_SDK_VERSION")
        OXMAssertEq(imp.secure, 1)
        OXMAssertEq(imp.clickbrowser, 0)
        
        //Check banner
        guard let banner = imp.banner else {
            XCTFail("No banner object!")
            return
        }
        
        OXMAssertEq(banner.api, [])
        
        //Check Regs
        XCTAssertNil(bidRequest.regs.coppa)
    }
    
    func testParameterBuilderExternalBrowser() {
        let adConfiguration = OXMAdConfiguration()
        
        let sdkConfiguration = OXASDKConfiguration()
        sdkConfiguration.useExternalClickthroughBrowser = true
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        guard let imp = bidRequest.imp.first else {
            XCTFail("No imp object")
            return
        }
        
        OXMAssertEq(imp.clickbrowser, 1)
    }
    
    func testParameterBuilderInterstitialVAST() {
        let adUnit = OXAInterstitialAdUnit.init(configId: "configId")
        adUnit.adFormat = .video
        let adConfiguration = adUnit.adUnitConfig.adConfiguration
        
        //Run the Builder
        let sdkConfiguration = OXASDKConfiguration()
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
      
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
              
        //Check that this is counted as an interstitial
        OXMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }
        
        OXMAssertEq(imp.instl, 1)
        
        guard let video = imp.video else {
            XCTFail("No video object!")
            return
        }
        
        OXMAssertEq(video.mimes, OXMConstants.supportedVideoMimeTypes)
        OXMAssertEq(video.protocols, [2,5])
        OXMAssertEq(video.placement, 5)
        OXMAssertEq(video.delivery!, [3])
        OXMAssertEq(video.pos, 7)
    }
    
    func testParameterBuilderOutstream() {
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .video
        adConfiguration.size = CGSize(width: 300, height: 250)
        
        //Run the Builder
        let sdkConfiguration = OXASDKConfiguration()
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        OXMAssertEq(bidRequest.imp.count, 1)
        guard let imp = bidRequest.imp.first else {
            XCTFail("No Imp object!")
            return
        }
        OXMAssertEq(imp.instl, 0)
        
        guard let video = imp.video else {
            XCTFail("No video object!")
            return
        }
        
        OXMAssertEq(video.mimes, OXMConstants.supportedVideoMimeTypes)
        OXMAssertEq(video.protocols, [2,5])
        XCTAssertNil(video.placement)
        
        OXMAssertEq(video.delivery!, [3])
        OXMAssertEq(video.pos, 7)
    }
    
    func testParameterBuilderCOPPANotSet() {
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.isInterstitialAd = false
        
        let sdkConfiguration = OXASDKConfiguration()
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        
        //Run Builder
        let bidRequest = OXMORTBBidRequest()
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
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.isInterstitialAd = false
        
        if let coppa = value {
            targeting.coppa = coppa
        }
        
        let sdkConfiguration = OXASDKConfiguration()
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        
        //Run Builder
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        OXMAssertEq(bidRequest.regs.coppa, expectedRegValue)
    }
    
    func testInvalidProperties() {
        let adConfiguration = OXMAdConfiguration()
        
        let sdkConfiguration = OXASDKConfiguration()
        let bidRequest = OXMORTBBidRequest()
        
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                                  sdkVersion:"MOCK_SDK_VERSION",
                                                  targeting: targeting)
        
        
        builder.build(bidRequest)
        
        logToFile = .init()
        
        builder.adConfiguration = nil
        builder.build(bidRequest)
        var log = OXMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains("Invalid properties"))
        
        logToFile = nil
        logToFile = .init()
        
        builder.adConfiguration = adConfiguration
        builder.sdkConfiguration = nil
        builder.build(bidRequest)
        log = OXMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains("Invalid properties"))
        
        logToFile = nil
        logToFile = .init()
        
        builder.sdkConfiguration = sdkConfiguration
        builder.sdkVersion = nil
        builder.build(bidRequest)
        log = OXMLog.singleton.getLogFileAsString()
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
    
    func testParameterBuilderVideo(placement: OXAVideoPlacementType,
                                   isInterstitial: Bool,
                                   expectedPlacement:Int) {
        
        var adConfiguration: OXMAdConfiguration
        if (isInterstitial) {
            let adUnit = OXAInterstitialAdUnit.init(configId: "configId")
            adUnit.adFormat = .video
            adConfiguration = adUnit.adUnitConfig.adConfiguration
        } else {
            let adUnit = OXABannerView.init(frame: CGRect.zero, configId: "configId", adSize: CGSize.zero)
            adUnit.adFormat = .video
            if (placement != .undefined) {
                adUnit.videoPlacementType = placement
            }
            adConfiguration = adUnit.adUnitConfig.adConfiguration
        }

        let sdkConfiguration = OXASDKConfiguration()
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        guard let video = bidRequest.imp.first?.video else {
            XCTFail("No video object!")
            return
        }
        
        if (expectedPlacement == 0) {
            XCTAssertNil(video.placement)
        } else {
            OXMAssertEq(video.placement?.intValue, expectedPlacement)
        }
        
    }
    
    func testParameterBuilderDeprecatedProperties() {
            
        //Create Builder
        let adConfiguration = OXMAdConfiguration()
    
        targeting.addParam("rab", withName: "foo")
        adConfiguration.isInterstitialAd = false
        
        let sdkConfiguration = OXASDKConfiguration()
        let builder = OXMBasicParameterBuilder(adConfiguration:adConfiguration,
                                                  sdkConfiguration:sdkConfiguration,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        //Run Builder
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check Regs
        XCTAssertNil(bidRequest.regs.coppa)
    }
}
