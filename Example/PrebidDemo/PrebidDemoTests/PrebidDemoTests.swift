/*   Copyright 2018-2019 Prebid.org, Inc.

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
import WebKit
import TestUtils
@testable import PrebidMobile
@testable import PrebidDemoSwift

// Disabled
class PrebidDemoTests: XCTestCase {
    
    var viewController: IndexController?
    var loadSuccesfulException: XCTestExpectation?
    var timeoutForRequest: TimeInterval = 0.0
    var nativeUnit : NativeRequest!
    var dfpNativeAdUnit: GAMBannerView!
    
    override func setUp() {
        StubbingHandler.shared.turnOff()
        setUpAppNexus()
        timeoutForRequest = 35.0

        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "index") as? IndexController
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window?.rootViewController = viewController
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [GADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
    }

    override func tearDown() {
        loadSuccesfulException = nil
        nativeUnit = nil
        dfpNativeAdUnit = nil
    }
    
    func setUpAppNexus() {
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        Prebid.shared.prebidServerAccountId = Constants.PBS_ACCOUNT_ID_APPNEXUS
        Prebid.shared.timeoutMillis = 10_000;
    }
    
    func setUpAppRubicon() {
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        Prebid.shared.prebidServerAccountId = Constants.PBS_RUBICON_ACCOUNT_ID
        Prebid.shared.timeoutMillis = 10_000;
    }
    
    func loadNativeAssets(){
        let assetImage = NativeAssetImage(minimumWidth: 200, minimumHeight: 200,required:true)
        assetImage.type = ImageAsset.Main
        
        let assetTitle = NativeAssetTitle(length: 90, required:true)
        
        nativeUnit = NativeRequest(configId: Constants.PBS_CONFIG_ID_NATIVE_APPNEXUS, assets: [assetImage,assetTitle])
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        let eventTrackers = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])
        nativeUnit.eventtrackers = [eventTrackers]
    }
    
    func loadDFPNative(){
        dfpNativeAdUnit = GAMBannerView(adSize: GADAdSizeFluid)
        dfpNativeAdUnit.adUnitID = Constants.DFP_NATIVE_ADUNIT_ID_APPNEXUS
        dfpNativeAdUnit.rootViewController = viewController
        dfpNativeAdUnit.delegate = self
        dfpNativeAdUnit.backgroundColor = .green
        viewController?.view.addSubview(dfpNativeAdUnit)
    }
    
    // FIXME: Disabled because of the resultCode: Prebid Server did not return bids
    func testAppNexusDFPBannerSanityAppCheckTest() {
        
        //given
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.delegate = self
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        
        //when
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            if resultCode == .prebidDemandFetchSuccess {
                dfpBanner.load(request)
            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

        
        //then
        XCTAssertNotNil(request.customTargeting)
        if let customTargeting = request.customTargeting {
            XCTAssertNotNil(customTargeting["hb_pb"])
        }
        
        XCTAssertNil(prebidCreativeError)
        XCTAssertNotNil(prebidCreativeSize)
    }
    
    func testRubiconDFPBannerSanityAppCheckTest() {
        
        //given
        setUpAppRubicon()
        Prebid.shared.storedAuctionResponse = "1001-rubicon-300x250"
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_RUBICON, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_RUBICON
        dfpBanner.rootViewController = viewController
        dfpBanner.delegate = self
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        
        //when
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            if resultCode == .prebidDemandFetchSuccess {

                dfpBanner.load(request)
            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

        //then
        XCTAssertNotNil(request.customTargeting)
        if let customTargeting = request.customTargeting {
            XCTAssertNotNil(customTargeting["hb_pb"])
        }
        
        XCTAssertNil(prebidCreativeError)
        XCTAssertNotNil(prebidCreativeSize)
    }
    
    let transactionFailRepeatCount = 5
    let screenshotDelaySeconds = 3.0
    let transactionFailDelaySeconds = 3.0
    
    //30x250 -> 728x90
    func testRubiconDFPBannerResizeSanityAppCheckTest() {
        
        class BannerViewDelegate: NSObject, GADBannerViewDelegate {
            let outer: PrebidDemoTests
            var loadSuccesfulExpectation: XCTestExpectation
            var prebidbBannerAdUnit: BannerAdUnit
            var first: Int
            var second: Int
            
            init(outer: PrebidDemoTests, loadSuccesfulExpectation: XCTestExpectation, prebidbBannerAdUnit: BannerAdUnit, first: inout Int, second: inout Int) {
                
                self.outer = outer
                self.loadSuccesfulExpectation =  loadSuccesfulExpectation
                self.prebidbBannerAdUnit = prebidbBannerAdUnit
                self.first = first
                self.second = second
            }
            
            func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
                Log.debug("AdManager adViewDidReceiveAd")
                AdViewUtils.findPrebidCreativeSize(bannerView, success: { (size) in
                    if let bannerView = bannerView as? GAMBannerView {
                        bannerView.resize(GADAdSizeFromCGSize(size))
                        
                        let bannerViewFrame = bannerView.frame;
                        let bannerViewSize = CGSize(width: bannerViewFrame.width, height: bannerViewFrame.height)
                        
                        XCTAssertEqual(bannerViewSize, size)
                    }
                    
                    self.outer.onResult(isSuccess: true, prebidbBannerAdUnit: self.prebidbBannerAdUnit, loadSuccesfulExpectation: self.loadSuccesfulExpectation, first: &self.first, second: &self.second)
                }) { (error) in
                    Log.warn("ERROR AdViewUtils findPrebidCreativeSize: \(error)")
                }
            }

            func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
                Log.warn("AdManager adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
                
                self.outer.onResult(isSuccess: false, prebidbBannerAdUnit: self.prebidbBannerAdUnit, loadSuccesfulExpectation: loadSuccesfulExpectation, first: &self.first, second: &self.second)
            }
        }

        var firstTransactionCount = 0
        var secondTransactionCount = 0
        
        let loadSuccesfulExpectation: XCTestExpectation = expectation(description: "load succesful")
        loadSuccesfulExpectation.expectedFulfillmentCount = 2
        loadSuccesfulExpectation.assertForOverFulfill = false
        
        //Logic
        setUpAppRubicon()
        Prebid.shared.storedAuctionResponse = "1001-rubicon-300x250"
        timeoutForRequest = 30.0
        
        let prebidbBannerAdUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_RUBICON, size: CGSize(width: 300, height: 250))
        
        let delegare = BannerViewDelegate(outer:self, loadSuccesfulExpectation: loadSuccesfulExpectation, prebidbBannerAdUnit: prebidbBannerAdUnit, first: &firstTransactionCount, second: &secondTransactionCount)
        
        let gamBannerView = GAMBannerView()
        gamBannerView.validAdSizes = [
            NSValueFromGADAdSize(GADAdSizeMediumRectangle),
            NSValueFromGADAdSize(GADAdSizeFromCGSize(CGSize(width: 728, height: 90))),
        ]
        
        gamBannerView.adUnitID = "/5300653/test_adunit_pavliuchyk_300x250_puc_ucTagData_prebid-server.rubiconproject.com"
        
        gamBannerView.rootViewController = viewController
        gamBannerView.delegate = delegare
        gamBannerView.backgroundColor = .red
        
        viewController?.view.addSubview(gamBannerView)
        
        
        let request = GAMRequest()
        prebidbBannerAdUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            if resultCode == .prebidDemandFetchSuccess {
                
                gamBannerView.load(request)
            } else {
                Log.warn("ERROR bannerUnit.fetchDemand resultCode: \(resultCode.name())")
                self.onResult(isSuccess: false, prebidbBannerAdUnit: prebidbBannerAdUnit, loadSuccesfulExpectation: loadSuccesfulExpectation, first: &firstTransactionCount, second: &secondTransactionCount)
            }
        }

        wait(for: [loadSuccesfulExpectation], timeout: 100)
    }
    
    func onResult(isSuccess: Bool, prebidbBannerAdUnit: BannerAdUnit, loadSuccesfulExpectation: XCTestExpectation, first: inout Int, second: inout Int) {
        if isSuccess {
            
            if first != -1 {
                first = -1

                prebidbBannerAdUnit.adSizes = [CGSize(width: 728, height: 90)]
                prebidbBannerAdUnit.refreshDemand()
                
            } else if second != -1 {
                second = -1
            }
            
            loadSuccesfulExpectation.fulfill()
            
        } else {
            if first != -1 {
                if first > self.transactionFailRepeatCount - 2 {
                    XCTFail("first Transaction Count == 5")
                    loadSuccesfulExpectation.fulfill()
                    loadSuccesfulExpectation.fulfill()
                    
                } else {
                    Log.warn("first transaction repear#\(first)")
                    first += 1
                    prebidbBannerAdUnit.refreshDemand()
                }
            } else if second != -1 {
                if second > self.transactionFailRepeatCount - 2 {
                    XCTFail("second Transaction Count == 5")
                    loadSuccesfulExpectation.fulfill()
                    loadSuccesfulExpectation.fulfill()
                } else {
                    Log.warn("second transaction repear#\(second)")
                    second += 1
                    prebidbBannerAdUnit.refreshDemand()
                }
            } else {
                XCTFail("Unexpected")
            }
            
        }
    }

    func testDFPBannerWithoutAutoRefresh() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }

    func testDFPBannerWithInvalidAutoRefresh() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 20000)
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }

    func testDFPBannerWithValidAutoRefresh() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 30000)
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(2, fetchDemandCount)
    }

    func testAMInterstitialSanity() {
        
        setUpAppRubicon()
        Prebid.shared.storedAuctionResponse = "1001-rubicon-300x250"
        loadSuccesfulException = expectation(description: "\(#function)")
        
        //given
        timeoutForRequest = 30.0
        let interstitialUnit = InterstitialAdUnit(configId: "1001-1")
        let request = GAMRequest()

        //when
        interstitialUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            if resultCode == .prebidDemandFetchSuccess {

            GAMInterstitialAd.load(withAdManagerAdUnitID: "/5300653/test_adunit_interstitial_pavliuchyk_prebid-server.qa.rubiconproject.com", request: request, completionHandler: self.interstitialCallback)

            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
        
        //then
        XCTAssertNotNil(request.customTargeting)
        if let customTargeting = request.customTargeting {
            XCTAssertNotNil(customTargeting["hb_pb"])
        }
        
        XCTAssertNil(prebidCreativeError)
        XCTAssertNotNil(prebidCreativeSize)
    }

    func testDFPInterstitialWithoutAutoRefresh() {
        var fetchDemandCount = 0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)

        let request = GAMRequest()
        interstitialUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }

    func testDFPInterstitialWithInvalidAutoRefresh() {
        var fetchDemandCount = 0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        interstitialUnit.setAutoRefreshMillis(time: 20000)
        let request = GAMRequest()
        interstitialUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }

    func testDFPInterstitialWithValidAutoRefresh() {
        var fetchDemandCount = 0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        interstitialUnit.setAutoRefreshMillis(time: 30000)
        let request = GAMRequest()
        interstitialUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(2, fetchDemandCount)
    }
    
    // FIXME: Disabled because of the resultCode: Prebid Server did not return bids
    func testDFPNativeSanityAppCheckTest() {
        //given
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        loadNativeAssets()
        loadDFPNative()
        
        let request = GAMRequest()
        nativeUnit.fetchDemand(adObject: request) {[weak self] (resultCode:ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            if resultCode == .prebidDemandFetchSuccess{
                self?.dfpNativeAdUnit.load(request)
            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self?.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

        
        //then
        XCTAssertNotNil(request.customTargeting)
        if let customTargeting = request.customTargeting {
            XCTAssertNotNil(customTargeting["hb_pb"])
        }
    }
    
    func testDFPNativeWithoutAutoRefresh() {
        var fetchDemandCount = 0
        loadNativeAssets()
        loadDFPNative()
        let request = GAMRequest()
        nativeUnit.fetchDemand(adObject: request) {(resultCode:ResultCode) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }
    
    func testDFPNativeWithInvalidAutoRefresh() {
        var fetchDemandCount = 0
        loadNativeAssets()
        nativeUnit.setAutoRefreshMillis(time: 20000)
        loadDFPNative()
        let request = GAMRequest()
        nativeUnit.fetchDemand(adObject: request) {(resultCode:ResultCode) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }
    
    func testDFPNativeWithValidAutoRefresh() {
        var fetchDemandCount = 0
        loadNativeAssets()
        nativeUnit.setAutoRefreshMillis(time: 30000)
        loadDFPNative()
        let request = GAMRequest()
        nativeUnit.fetchDemand(adObject: request) {(resultCode:ResultCode) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(2, fetchDemandCount)
    }

    func testAutoRefreshWith2MinThenDisable() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 30000)
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(124)
        XCTAssertEqual(5, fetchDemandCount)
        fetchDemandCount = 0
        bannerUnit.stopAutoRefresh()
        wait(35)
        XCTAssertEqual(0, fetchDemandCount)
    }
    
    func testAutoRefreshWith5MinThenDisable() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 120000)
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(300)
        XCTAssertEqual(3, fetchDemandCount)
        fetchDemandCount = 0
        bannerUnit.stopAutoRefresh()
        wait(35)
        XCTAssertEqual(0, fetchDemandCount)
    }

    func testAppNexusInvalidPrebidServerAccountId() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerAccountId = Constants.PBS_INVALID_ACCOUNT_ID_APPNEXUS
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, .prebidInvalidAccountId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }
    
    func testRubiconInvalidPrebidServerAccountId() {
        
        setUpAppRubicon()
        
        loadSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerAccountId = Constants.PBS_INVALID_ACCOUNT_ID_RUBICON
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_RUBICON, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_RUBICON
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, .prebidInvalidAccountId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
        
    }

    func testEmptyPrebidServerAccountId() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerAccountId = Constants.PBS_EMPTY_ACCOUNT_ID
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, .prebidInvalidAccountId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }

    func testAppNexusInvalidConfigId() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_INVALID_CONFIG_ID_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, .prebidInvalidConfigId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }
    
    func testRubiconInvalidConfigId() {
        
        setUpAppRubicon()
        
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_INVALID_CONFIG_ID_RUBICON, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_RUBICON
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, .prebidInvalidConfigId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
        
    }

    func testRubiconCOPPA() throws {
        
        swizzleJsonSerializationData()
        swizzleJsonSerializationJsonObject()
        
        defer {
            swizzleJsonSerializationData()
            swizzleJsonSerializationJsonObject()
        }
        
        loadSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        
        Prebid.shared.prebidServerAccountId = "1001"
        
        Targeting.shared.subjectToCOPPA = true
        defer {
            Targeting.shared.subjectToCOPPA = false
        }
        
        Targeting.shared.setYearOfBirth(yob: 1990)
        Targeting.shared.userGender = .male
        
        let bannerUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        bannerUnit.fetchDemand { result, kvResultDict in
            sleep(2)
            self.loadSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        guard let response = PrebidDemoTests.pbServerResponse,
            response.count > 0,
            let ext = response["ext"] as? [String: Any],
            let debug = ext["debug"] as? [String: Any],
            let httpcalls = debug["httpcalls"] as? [String: Any],
            let rubicon = httpcalls["rubicon"] as? [Any],
            let first = rubicon[0] as? [String: Any],
            let requestbody = first["requestbody"] as? String else {

                XCTFail("parsing error")
                return
        }
        
        //then
        XCTAssertFalse(requestbody.contains("\"yob\""))
        XCTAssertFalse(requestbody.contains("\"gender\""))
        XCTAssertFalse(requestbody.contains("\"lat\""))
        XCTAssertFalse(requestbody.contains("\"lon\""))
    }

    func testEmptyConfigId() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_EMPTY_CONFIG_ID, size: CGSize(width: 300, height: 250))
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, .prebidInvalidConfigId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }

    func testYOBWith2018() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        setUpAppRubicon()
        Prebid.shared.storedAuctionResponse = "1001-rubicon-300x250"
        
        let targeting = Targeting.shared
        targeting.setYearOfBirth(yob: 2018)
        let value = Targeting.shared.yearOfBirth
        XCTAssertTrue((value == 2018))
    }

    func testYOBWith1989() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        setUpAppRubicon()
        Prebid.shared.storedAuctionResponse = "1001-rubicon-300x250"
        
        let targeting = Targeting.shared
        targeting.setYearOfBirth(yob: 1989)
        let value = Targeting.shared.yearOfBirth
        XCTAssertTrue((value == 1989))
    }

    func testAppNexusKeyValueTargeting() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"

        timeoutForRequest = 20.0
        _ = BannerAdUnit(configId: "67bac530-9832-4f78-8c94-fbf88ac7bd14", size: CGSize(width: 300, height: 250))
    }

    func testDFPCustomKeywords() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        var fetchCount = 0
        timeoutForRequest = 60.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 30000)
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        request.customTargeting = ["key1": "value1", "key2": "value2"]
        bannerUnit.fetchDemand(adObject: request) { (_) in
            fetchCount += 1
            XCTAssertNotNil(request.customTargeting)
            if fetchCount == 1 {
                XCTAssertEqual(request.customTargeting!["key1"]!, "value1")
                XCTAssertEqual(request.customTargeting!["key2"]!, "value2")
            } else {
                XCTAssertNotEqual(request.customTargeting!["key1"]!, "value1")
                XCTAssertNotEqual(request.customTargeting!["key2"]!, "value2")
                XCTAssertEqual(request.customTargeting!["key2"]!, "value1")
                XCTAssertEqual(request.customTargeting!["key3"]!, "value3")
                XCTAssertEqual(request.customTargeting!["key1"]!, "")
                self.loadSuccesfulException?.fulfill()
            }
            request.customTargeting = ["key1": "", "key2": "value1", "key3": "value3"]

        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testBannerWith5ValidAnd1InvalidSizes() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let arraySizes = [CGSize(width: 320, height: 50), CGSize(width: 300, height: 250), CGSize(width: 300, height: 600), CGSize(width: 320, height: 100), CGSize(width: 320, height: 480), CGSize(width: 0, height: 0)]
        bannerUnit.addAdditionalSize(sizes: arraySizes)
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, .prebidInvalidSize, resultCode.name())
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testBannerWithInvalidSize() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 320, height: 50))
        let arraySizes = [CGSize(width: 0, height: 0)]
        bannerUnit.addAdditionalSize(sizes: arraySizes)
        let dfpBanner = GAMBannerView(adSize: GADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request = GAMRequest()
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, .prebidInvalidSize)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    
    //MARK: - AM Interstitial
    func interstitialCallback(_ ad: GAMInterstitialAd?, _ error: Error?) {
        if let error = error {
            print("AM Interstitial didFailToReceiveAdWithError:\(error.localizedDescription)")
            
            self.prebidCreativeError = error
            self.loadSuccesfulException?.fulfill()
            return
        }
        print("interstitialDidReceiveAd")

        ad?.present(fromRootViewController: viewController!)

        let _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Hello World!")], timeout: 2.0)
        didLoadAdByAdServerHelper(view: self.viewController!.presentedViewController!.view)
    }
    
    //MARK: - private zone
    
    private var prebidCreativeSize: CGSize? = nil
    private var prebidCreativeError: Error? = nil
    
    private func didLoadAdByAdServerHelper(view: UIView) {
        let success: (CGSize) -> Void = { s in
            self.prebidCreativeSize = s
            self.loadSuccesfulException?.fulfill()
        }
        
        let failure: (Error) -> Void = { err in
            self.prebidCreativeError = err
            self.loadSuccesfulException?.fulfill()
        }
        
        AdViewUtils.findPrebidCreativeSize(view, success: success, failure: failure)
    }
    
    private func swizzleJsonSerializationData() {
        
        let methodRequest: Method = class_getClassMethod(JSONSerialization.self, #selector(JSONSerialization.data(withJSONObject:options:)))!
        let swizzledMethodRequest: Method = class_getClassMethod(PrebidDemoTests.self, #selector(PrebidDemoTests.swizzledJSONSerializationData(withJSONObject:options:)))!
        method_exchangeImplementations(methodRequest, swizzledMethodRequest)
    }
    
    private func swizzleJsonSerializationJsonObject() {
        
        let methodResponse: Method = class_getClassMethod(JSONSerialization.self, #selector(JSONSerialization.jsonObject as (Data, JSONSerialization.ReadingOptions) throws -> Any ))!
        let swizzledMethodResponse: Method = class_getClassMethod(PrebidDemoTests.self, #selector(PrebidDemoTests.swizzledJSONSerializationJsonObject(with:options:)))!
        method_exchangeImplementations(methodResponse, swizzledMethodResponse)
    }
    
    dynamic
    class func swizzledJSONSerializationData(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions = []) throws -> Data {
        
        var requestBody: [String: Any] = obj as! [String : Any]
        requestBody.merge(dict: ["test" : 1])
        
        return try PrebidDemoTests.swizzledJSONSerializationData(withJSONObject: requestBody, options: opt)
    }
    
    private static var pbServerResponse: [String: AnyObject]? = nil
    
    dynamic
    class func swizzledJSONSerializationJsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
        let result = try PrebidDemoTests.swizzledJSONSerializationJsonObject(with: data, options: opt)
        
        pbServerResponse = result as? [String: AnyObject]
        
        return result
    }

}

// MARK: - GADBannerViewDelegate

extension PrebidDemoTests: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        didLoadAdByAdServerHelper(view: bannerView)
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        loadSuccesfulException = nil
    }
}
