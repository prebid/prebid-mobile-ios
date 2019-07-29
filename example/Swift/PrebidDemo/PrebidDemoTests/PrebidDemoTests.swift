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
import MoPub
import GoogleMobileAds
import WebKit
@testable import PrebidMobile
@testable import PrebidDemo

class PrebidDemoTests: XCTestCase, GADBannerViewDelegate, GADInterstitialDelegate, MPAdViewDelegate, MPInterstitialAdControllerDelegate {

    var viewController: IndexController?
    var loadSuccesfulException: XCTestExpectation?
    var timeoutForRequest: TimeInterval = 0.0
    var mopubInterstitial: MPInterstitialAdController?
    var dfpInterstitial: DFPInterstitial?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        setUpAppNexus()
       // Prebid.shared.shareGeoLocation = true
        timeoutForRequest = 35.0

        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "index") as? IndexController
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window?.rootViewController = viewController
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        loadSuccesfulException = nil
        mopubInterstitial = nil
        dfpInterstitial = nil
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

    func testAppNexusDFPBannerSanityAppCheckTest() {
        
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.delegate = self
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandFetchSuccess {
                XCTAssertNotNil(request.customTargeting)
                XCTAssertNotNil(request.customTargeting!["hb_pb"])
                dfpBanner.load(request)
            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }
    
    func testRubiconDFPBannerSanityAppCheckTest() {
        setUpAppRubicon()
        
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_RUBICON, size: CGSize(width: 300, height: 250))
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_RUBICON
        dfpBanner.rootViewController = viewController
        dfpBanner.delegate = self
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandFetchSuccess {
                XCTAssertNotNil(request.customTargeting)
                XCTAssertNotNil(request.customTargeting!["hb_pb"])
                dfpBanner.load(request)
            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
        
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
            
            func adViewDidReceiveAd(_ bannerView: GADBannerView) {
                Log.debug("AdManager adViewDidReceiveAd")
                
                Utils.shared.findPrebidCreativeSize(bannerView) { (size) in
                    if let bannerView = bannerView as? DFPBannerView, let size = size {
                        bannerView.resize(GADAdSizeFromCGSize(size))
                        
                        let bannerViewFrame = bannerView.frame;
                        let bannerViewSize = CGSize(width: bannerViewFrame.width, height: bannerViewFrame.height)
                        
                        XCTAssertEqual(bannerViewSize, size)
                        
                        //Wait to make screenshot
                        XCTWaiter.wait(for: [XCTestExpectation(description: "wait")], timeout: self.outer.screenshotDelaySeconds)
                        
                        self.outer.makeScreenShot()
                    }

                    self.outer.onResult(isSuccess: true, prebidbBannerAdUnit: self.prebidbBannerAdUnit, loadSuccesfulExpectation: self.loadSuccesfulExpectation, first: &self.first, second: &self.second)
                }
                
            }
            
            func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
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
        timeoutForRequest = 30.0
        
        let prebidbBannerAdUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_RUBICON, size: CGSize(width: 300, height: 250))
        
        let delegare = BannerViewDelegate(outer:self, loadSuccesfulExpectation: loadSuccesfulExpectation, prebidbBannerAdUnit: prebidbBannerAdUnit, first: &firstTransactionCount, second: &secondTransactionCount)
        
        let gamBannerView = DFPBannerView()
        gamBannerView.validAdSizes = [
            NSValueFromGADAdSize(kGADAdSizeMediumRectangle),
            NSValueFromGADAdSize(GADAdSizeFromCGSize(CGSize(width: 728, height: 90))),
        ]
        
        gamBannerView.adUnitID = "/5300653/test_adunit_pavliuchyk_300x250_puc_ucTagData_prebid-server.rubiconproject.com"
        
        gamBannerView.rootViewController = viewController
        gamBannerView.delegate = delegare
        gamBannerView.backgroundColor = .red
        
        viewController?.view.addSubview(gamBannerView)
        
        
        let request: DFPRequest = DFPRequest()
        prebidbBannerAdUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandFetchSuccess {
                
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
            //time-out
            XCTWaiter.wait(for: [XCTestExpectation(description: "wait")], timeout: self.transactionFailDelaySeconds)
            
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
    
    func makeScreenShot() {
        // Taking screenshot after test
        let screenshot = XCUIScreen.main.screenshot()
        let fullScreenshotAttachment = XCTAttachment(screenshot: screenshot)
        fullScreenshotAttachment.lifetime = .keepAlways
        
        add(fullScreenshotAttachment)
    }

    func testDFPBannerWithoutAutoRefresh() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
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
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
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
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
        bannerUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(2, fetchDemandCount)
    }

    func testDFPInterstitialSanityAppCheckTest() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        dfpInterstitial = DFPInterstitial(adUnitID: Constants.DFP_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        let request: DFPRequest = DFPRequest()
        dfpInterstitial?.delegate = self
        request.testDevices = [ kGADSimulatorID]
        interstitialUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandFetchSuccess {
                XCTAssertNotNil(request.customTargeting)
                XCTAssertNotNil(request.customTargeting!["hb_pb"])
                self.dfpInterstitial?.load(request)

            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testDFPInterstitialWithoutAutoRefresh() {
        var fetchDemandCount = 0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        dfpInterstitial = DFPInterstitial(adUnitID: Constants.DFP_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
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
        dfpInterstitial = DFPInterstitial(adUnitID: Constants.DFP_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
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
        dfpInterstitial = DFPInterstitial(adUnitID: Constants.DFP_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
        interstitialUnit.fetchDemand(adObject: request) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(2, fetchDemandCount)
    }

    func testAppNexusMoPubBannerSanityAppCheckTest() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 20.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        mopubBanner?.delegate = self
        viewController?.view.addSubview(mopubBanner!)
        bannerUnit.fetchDemand(adObject: mopubBanner!) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandNoBids {
                self.mopubInterstitial?.loadAd()
            } else if resultCode == ResultCode.prebidDemandFetchSuccess {
                XCTAssertNotNil(mopubBanner!.keywords)
                XCTAssertNotNil(mopubBanner!.keywords.contains("hb_pb"))
                mopubBanner!.loadAd()
            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }
    
    func testRubiconMoPubBannerSanityAppCheckTest() {
        setUpAppRubicon()
        
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 20.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_RUBICON, size: CGSize(width: 300, height: 250))
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_RUBICON)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_RUBICON, size: CGSize(width: 300, height: 250))
        mopubBanner?.delegate = self
        viewController?.view.addSubview(mopubBanner!)
        bannerUnit.fetchDemand(adObject: mopubBanner!) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandNoBids {
                self.mopubInterstitial?.loadAd()
            } else if resultCode == ResultCode.prebidDemandFetchSuccess {
                XCTAssertNotNil(mopubBanner!.keywords)
                XCTAssertNotNil(mopubBanner!.keywords.contains("hb_pb"))
                mopubBanner!.loadAd()
            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testMopubBannerWithoutAutoRefresh() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.fetchDemand(adObject: mopubBanner!) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }

    func testMopubBannerWithInvalidAutoRefresh() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 20000)
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.fetchDemand(adObject: mopubBanner!) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }

    func testMopubBannerWithValidAutoRefresh() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 30000)
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.fetchDemand(adObject: mopubBanner!) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(2, fetchDemandCount)
    }

    func testMoPubInterstitialSanityAppCheckTest() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 20.0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        mopubInterstitial = MPInterstitialAdController(forAdUnitId: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        mopubInterstitial?.delegate = self
        interstitialUnit.fetchDemand(adObject: mopubInterstitial!) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandNoBids {
                self.mopubInterstitial?.loadAd()
            } else if resultCode == ResultCode.prebidDemandFetchSuccess {
                XCTAssertNotNil(self.mopubInterstitial!.keywords)
                XCTAssertNotNil(self.mopubInterstitial!.keywords.contains("hb_pb"))
                self.mopubInterstitial?.loadAd()
            } else {
                XCTFail("resultCode:\(resultCode.name())")
                self.loadSuccesfulException?.fulfill()
            }
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testMopubInterstitialWithoutAutoRefresh() {
        var fetchDemandCount = 0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        mopubInterstitial = MPInterstitialAdController(forAdUnitId: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        interstitialUnit.fetchDemand(adObject: mopubInterstitial!) { (_) in
             fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }

    func testMopubInterstitialWithInvalidAutoRefresh() {
        var fetchDemandCount = 0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        interstitialUnit.setAutoRefreshMillis(time: 20000)
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        mopubInterstitial = MPInterstitialAdController(forAdUnitId: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        interstitialUnit.fetchDemand(adObject: mopubInterstitial!) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(1, fetchDemandCount)
    }

    func testMopubInterstitialWithValidAutoRefresh() {
        var fetchDemandCount = 0
        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        interstitialUnit.setAutoRefreshMillis(time: 30000)
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        mopubInterstitial = MPInterstitialAdController(forAdUnitId: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        interstitialUnit.fetchDemand(adObject: mopubInterstitial!) { (_) in
            fetchDemandCount += 1
        }
        wait(31)
        XCTAssertEqual(2, fetchDemandCount)
    }

    func testAutoRefreshWith2MinThenDisable() {
        var fetchDemandCount = 0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 30000)
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
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
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
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
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidInvalidAccountId)
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
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_RUBICON
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidInvalidAccountId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
        
    }

    func testEmptyPrebidServerAccountId() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerAccountId = Constants.PBS_EMPTY_ACCOUNT_ID
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidInvalidAccountId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }

    func testAppNexusInvalidConfigId() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_INVALID_CONFIG_ID_APPNEXUS, size: CGSize(width: 300, height: 250))
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidInvalidConfigId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }
    
    func testRubiconInvalidConfigId() {
        
        setUpAppRubicon()
        
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_INVALID_CONFIG_ID_RUBICON, size: CGSize(width: 300, height: 250))
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_RUBICON
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidInvalidConfigId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
        
    }

    func testRubiconCOPPA() {
        
        var methodRequest: Method = class_getClassMethod(JSONSerialization.self, #selector(JSONSerialization.data(withJSONObject:options:)))!
        var swizzledMethodRequest: Method = class_getClassMethod(PrebidDemoTests.self, #selector(PrebidDemoTests.swizzledJSONSerializationData(withJSONObject:options:)))!
        method_exchangeImplementations(methodRequest, swizzledMethodRequest)
        
        var methodResponse: Method = class_getClassMethod(JSONSerialization.self, #selector(JSONSerialization.jsonObject as (Data, JSONSerialization.ReadingOptions) throws -> Any ))!
        var swizzledMethodResponse: Method = class_getClassMethod(PrebidDemoTests.self, #selector(PrebidDemoTests.swizzledJSONSerializationJsonObject(with:options:)))!
        method_exchangeImplementations(methodResponse, swizzledMethodResponse)
        
        loadSuccesfulException = expectation(description: "\(#function)")
        
        //Rubicon prod
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        
        //Rubicon qa
//        Prebid.shared.prebidServerHost = PrebidHost.Custom
//        do {
//            try Prebid.shared.setCustomPrebidServer(url: "https://prebid-server.qa.rubiconproject.com/openrtb2/auction")
//        } catch {
//            Log.error("testRubiconQaCOPPA")
//        }
        
        Prebid.shared.prebidServerAccountId = "1001"
        
        Targeting.shared.subjectToCOPPA = true
        defer {
            Targeting.shared.subjectToCOPPA = false
        }
        
        do {
            try Targeting.shared.setYearOfBirth(yob: 1990)
        } catch {
            Log.error("testRubiconQaCOPPA")
        }
        Targeting.shared.gender = .male
        
        let bannerUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let manager: BidManager = BidManager(adUnit: bannerUnit)
        manager.requestBidsForAdUnit { (bidResponse, _) in

            sleep(2)
            self.loadSuccesfulException?.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    dynamic class func swizzledJSONSerializationData(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions = []) throws -> Data {
        
        var requestBody: [String: Any] = obj as! [String : Any]
        requestBody.merge(dict: ["test" : 1])
        
        return try PrebidDemoTests.swizzledJSONSerializationData(withJSONObject: requestBody, options: opt)
    }
    
    dynamic class func swizzledJSONSerializationJsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
        let result = try PrebidDemoTests.swizzledJSONSerializationJsonObject(with: data, options: opt)
        
        let response = result as? [String: AnyObject]
        
        if let response = response,
            response.count > 0,
            let ext = response["ext"] as? [String: Any],
            let debug = ext["debug"] as? [String: Any],
            let httpcalls = debug["httpcalls"] as? [String: Any],
            let rubicon = httpcalls["rubicon"] as? [Any],
            let first = rubicon[0] as? [String: Any],
            let requestbody = first["requestbody"] as? String {
            
            Log.debug("requestbody to exchange \(requestbody)")
            XCTAssertFalse(requestbody.contains("\"yob\""))
            XCTAssertFalse(requestbody.contains("\"gender\""))
            XCTAssertFalse(requestbody.contains("\"lat\""))
            XCTAssertFalse(requestbody.contains("\"lon\""))
        }
        
        return result
    }

    func testEmptyConfigId() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 10.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_EMPTY_CONFIG_ID, size: CGSize(width: 300, height: 250))
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidInvalidConfigId)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }

    func testYOBWith2018() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        let targeting = Targeting.shared
        XCTAssertNoThrow(try targeting.setYearOfBirth(yob: 2018))
        let value = Targeting.shared.yearOfBirth
        XCTAssertTrue((value == 2018))

        let adUnit = BannerAdUnit(configId: "47706260-ee91-4cd7-b656-2185aca89f59", size: CGSize(width: 300, height: 250))

        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "a935eac11acd416f92640411234fbba6")
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: "a935eac11acd416f92640411234fbba6", size: CGSize(width: 300, height: 250))
        adUnit.fetchDemand(adObject: mopubBanner!) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidDemandNoBids)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testYOBWith1989() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        let targeting = Targeting.shared
        XCTAssertNoThrow(try targeting.setYearOfBirth(yob: 1989))
        let value = Targeting.shared.yearOfBirth
        XCTAssertTrue((value == 1989))

        let adUnit = BannerAdUnit(configId: "47706260-ee91-4cd7-b656-2185aca89f59", size: CGSize(width: 300, height: 250))

        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "a935eac11acd416f92640411234fbba6")
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: "a935eac11acd416f92640411234fbba6", size: CGSize(width: 300, height: 250))
        adUnit.fetchDemand(adObject: mopubBanner!) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidDemandFetchSuccess)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testAppNexusKeyValueTargeting() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"

        timeoutForRequest = 20.0
        let adUnit = BannerAdUnit(configId: "67bac530-9832-4f78-8c94-fbf88ac7bd14", size: CGSize(width: 300, height: 250))
        adUnit.removeUserKeyword(forKey: "pbm_key")
        adUnit.addUserKeyword(key: "pbm_key", value: "pbm_value1")

        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "a935eac11acd416f92640411234fbba6")
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: "a935eac11acd416f92640411234fbba6", size: CGSize(width: 300, height: 250))
        adUnit.fetchDemand(adObject: mopubBanner!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }

    func testAppNexusKeyValueTargeting2() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"

        timeoutForRequest = 20.0
        let adUnit = BannerAdUnit(configId: "67bac530-9832-4f78-8c94-fbf88ac7bd14", size: CGSize(width: 300, height: 250))
        adUnit.removeUserKeyword(forKey: "pbm_key")
        adUnit.addUserKeyword(key: "pbm_key", value: "pbm_value2")

        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "a935eac11acd416f92640411234fbba6")
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: "a935eac11acd416f92640411234fbba6", size: CGSize(width: 300, height: 250))
        adUnit.fetchDemand(adObject: mopubBanner!) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidDemandNoBids)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)

    }

    func testDFPCustomKeywords() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        var fetchCount = 0
        timeoutForRequest = 60.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 30000)
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.customTargeting = ["key1": "value1", "key2": "value2"] as [String: AnyObject]
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
        bannerUnit.fetchDemand(adObject: request) { (_) in
            fetchCount += 1
            XCTAssertNotNil(request.customTargeting)
            if fetchCount == 1 {
                XCTAssertEqual(request.customTargeting!["key1"] as! String, "value1")
                XCTAssertEqual(request.customTargeting!["key2"] as! String, "value2")
            } else {
                XCTAssertNotEqual(request.customTargeting!["key1"] as! String, "value1")
                XCTAssertNotEqual(request.customTargeting!["key2"] as! String, "value2")
                XCTAssertEqual(request.customTargeting!["key2"] as! String, "value1")
                XCTAssertEqual(request.customTargeting!["key3"] as! String, "value3")
                XCTAssertEqual(request.customTargeting!["key1"] as! String, "")
                self.loadSuccesfulException?.fulfill()
            }
            request.customTargeting = ["key1": "", "key2": "value1", "key3": "value3"] as [String: AnyObject]

        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testMoPubCustomKeywords() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        var fetchCount = 0
        timeoutForRequest = 60.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 30000)
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS)
        sdkConfig.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}
        let mopubBanner = MPAdView(adUnitId: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        mopubBanner?.keywords = "key1:value1,key2:value2"
        bannerUnit.fetchDemand(adObject: mopubBanner!) { (_) in
            fetchCount += 1
            XCTAssertNotNil(mopubBanner?.keywords)
            let keywords = mopubBanner?.keywords
            let keywordsArray = keywords!.components(separatedBy: ",")
            if fetchCount == 1 {
                XCTAssertTrue(keywordsArray.contains("key1:value1"))
                XCTAssertTrue(keywordsArray.contains("key2:value2"))
            } else {
                XCTAssertFalse(keywordsArray.contains("key1:value1"))
                XCTAssertFalse(keywordsArray.contains("key2:value2"))
                XCTAssertTrue(keywordsArray.contains("key1:value2"))
                XCTAssertTrue(keywordsArray.contains("key2:value1"))
                self.loadSuccesfulException?.fulfill()
            }
            mopubBanner?.keywords = "key1:value2,key2:value1"
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testBannerWith5ValidAnd1InvalidSizes() {
        loadSuccesfulException = expectation(description: "\(#function)")
        
        timeoutForRequest = 30.0
        let bannerUnit = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let arraySizes = [CGSize(width: 320, height: 50), CGSize(width: 300, height: 250), CGSize(width: 300, height: 600), CGSize(width: 320, height: 100), CGSize(width: 320, height: 480), CGSize(width: 0, height: 0)]
        bannerUnit.addAdditionalSize(sizes: arraySizes)
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidInvalidSize, resultCode.name())
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
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = Constants.DFP_BANNER_ADUNIT_ID_300x250_APPNEXUS
        dfpBanner.rootViewController = viewController
        dfpBanner.backgroundColor = .red
        viewController?.view.addSubview(dfpBanner)
        let request: DFPRequest = DFPRequest()
        request.testDevices = [ kGADSimulatorID, "cc7ca766f86b43ab6cdc92bed424069b"]
        bannerUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode, ResultCode.prebidInvalidSize)
            self.loadSuccesfulException?.fulfill()
        }
        
        waitForExpectations(timeout: timeoutForRequest, handler: nil)
    }

    func testMultipleAdUnitsAllDemandFetched() {
        var fetchDemandCount = 0
        let bannerUnit1 = BannerAdUnit(configId: "7cd2c7c8-cebe-4206-b5a4-97b9e840729e", size: CGSize(width: 320, height: 50))
        let sdkConfig1 = MPMoPubConfiguration(adUnitIdForAppInitialization: "9a8c2ccd3dae405bb925397d35eed8f9")
        sdkConfig1.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig1) {}
        let mopubBanner1 = MPAdView(adUnitId: "9a8c2ccd3dae405bb925397d35eed8f9", size: CGSize(width: 320, height: 50))
        mopubBanner1?.delegate = self
        viewController?.view.addSubview(mopubBanner1!)
        bannerUnit1.fetchDemand(adObject: mopubBanner1!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let bannerUnit2 = BannerAdUnit(configId: "525a5fee-ffbb-4f16-935d-3717c56e7aeb", size: CGSize(width: 320, height: 50))
        let sdkConfig2 = MPMoPubConfiguration(adUnitIdForAppInitialization: "50564379db734ebbb347849221a1081e")
        sdkConfig2.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig2) {}
        let mopubBanner2 = MPAdView(adUnitId: "50564379db734ebbb347849221a1081e", size: CGSize(width: 320, height: 50))
        mopubBanner2?.delegate = self
        viewController?.view.addSubview(mopubBanner2!)
        bannerUnit2.fetchDemand(adObject: mopubBanner2!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let bannerUnit3 = BannerAdUnit(configId: "511c39f2-b527-41af-811a-adac6911bdfc", size: CGSize(width: 300, height: 250))
        let sdkConfig3 = MPMoPubConfiguration(adUnitIdForAppInitialization: "5ff9556b05964e65b684ec54013df59d")
        sdkConfig3.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig3) {}
        let mopubBanner3 = MPAdView(adUnitId: "5ff9556b05964e65b684ec54013df59d", size: CGSize(width: 300, height: 250))
        mopubBanner3?.delegate = self
        viewController?.view.addSubview(mopubBanner3!)
        bannerUnit3.fetchDemand(adObject: mopubBanner3!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let bannerUnit4 = BannerAdUnit(configId: "42ad4418-9b36-4e39-ae54-2f7a13ad8616", size: CGSize(width: 300, height: 250))
        let sdkConfig4 = MPMoPubConfiguration(adUnitIdForAppInitialization: "c5c9267bcf6247cb91a116d1ef6c7487")
        sdkConfig4.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig4) {}
        let mopubBanner4 = MPAdView(adUnitId: "c5c9267bcf6247cb91a116d1ef6c7487", size: CGSize(width: 300, height: 250))
        mopubBanner4?.delegate = self
        viewController?.view.addSubview(mopubBanner4!)
        bannerUnit4.fetchDemand(adObject: mopubBanner4!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let bannerUnit5 = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        let sdkConfig5 = MPMoPubConfiguration(adUnitIdForAppInitialization: "a935eac11acd416f92640411234fbba6")
        sdkConfig5.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig5) {}
        let mopubBanner5 = MPAdView(adUnitId: "a935eac11acd416f92640411234fbba6", size: CGSize(width: 300, height: 250))
        mopubBanner5?.delegate = self
        viewController?.view.addSubview(mopubBanner5!)
        bannerUnit5.fetchDemand(adObject: mopubBanner5!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let interstitialUnit6 = InterstitialAdUnit(configId: "625c6125-f19e-4d5b-95c5-55501526b2a4")
        let sdkConfig6 = MPMoPubConfiguration(adUnitIdForAppInitialization: "2829868d308643edbec0795977f17437")
        sdkConfig6.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig6) {}
        let mopubInterstitial6 = MPInterstitialAdController(forAdUnitId: "2829868d308643edbec0795977f17437")
        
        interstitialUnit6.fetchDemand(adObject: mopubInterstitial6!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let interstitialUnit7 = InterstitialAdUnit(configId: "bde00f49-0a1b-483a-9716-e2dd427b794c")
        let sdkConfig7 = MPMoPubConfiguration(adUnitIdForAppInitialization: "c3fca03154a540bfa7f0971fb984e3e8")
        sdkConfig7.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig7) {}
        let mopubInterstitial7 = MPInterstitialAdController(forAdUnitId: "c3fca03154a540bfa7f0971fb984e3e8")
        interstitialUnit7.fetchDemand(adObject: mopubInterstitial7!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let interstitialUnit8 = InterstitialAdUnit(configId: "6ceca3d4-f5b8-4717-b4d9-178843f873f8")
        let sdkConfig8 = MPMoPubConfiguration(adUnitIdForAppInitialization: "12ecf78eb8314f8bb36192a6286adc56")
        sdkConfig8.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig8) {}
        let mopubInterstitial8 = MPInterstitialAdController(forAdUnitId: "12ecf78eb8314f8bb36192a6286adc56")
        interstitialUnit8.fetchDemand(adObject: mopubInterstitial8!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let interstitialUnit9 = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        let sdkConfig9 = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        sdkConfig9.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig9) {}
        let mopubInterstitial9 = MPInterstitialAdController(forAdUnitId: Constants.MOPUB_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        interstitialUnit9.fetchDemand(adObject: mopubInterstitial9!) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        let interstitialUnit = InterstitialAdUnit(configId: Constants.PBS_CONFIG_ID_INTERSTITIAL_APPNEXUS)
        let dfpInterstitial = DFPInterstitial(adUnitID: Constants.DFP_INTERSTITIAL_ADUNIT_ID_APPNEXUS)
        let request: DFPRequest = DFPRequest()
        dfpInterstitial.delegate = self
        request.testDevices = [ kGADSimulatorID]
        interstitialUnit.fetchDemand(adObject: request) { (resultCode: ResultCode) in
            XCTAssert(resultCode == ResultCode.prebidDemandFetchSuccess || resultCode == ResultCode.prebidDemandNoBids, resultCode.name())
            fetchDemandCount += 1
        }

        wait(10)
        XCTAssertEqual(10, fetchDemandCount)
    }

    func testSameConfigIdOnDifferentAdObjects() {
        var fetchDemandCount = 0
        let bannerUnit1 = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let sdkConfig1 = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS)
        sdkConfig1.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig1) {}
        let mopubBanner1 = MPAdView(adUnitId: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        mopubBanner1?.delegate = self
        viewController?.view.addSubview(mopubBanner1!)
        bannerUnit1.fetchDemand(adObject: mopubBanner1!) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandNoBids {
                fetchDemandCount += 1
            } else {
                XCTAssertEqual(resultCode, ResultCode.prebidDemandFetchSuccess)
                XCTAssertNotNil(mopubBanner1!.keywords)
                let keywords = mopubBanner1!.keywords
                if let keywordsArray = keywords?.components(separatedBy: ",") {
                    XCTAssertEqual(10, keywordsArray.count)
                    XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
                    XCTAssertTrue (keywords!.contains("hb_cache_id:"))
                    fetchDemandCount += 1
                }
            }
        }

        let bannerUnit2 = BannerAdUnit(configId: Constants.PBS_CONFIG_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        let sdkConfig2 = MPMoPubConfiguration(adUnitIdForAppInitialization: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS)
        sdkConfig2.globalMediationSettings = []
        MoPub.sharedInstance().initializeSdk(with: sdkConfig2) {}
        let mopubBanner2 = MPAdView(adUnitId: Constants.MOPUB_BANNER_ADUNIT_ID_300x250_APPNEXUS, size: CGSize(width: 300, height: 250))
        mopubBanner2?.delegate = self
        viewController?.view.addSubview(mopubBanner2!)
        bannerUnit2.fetchDemand(adObject: mopubBanner2!) { (resultCode: ResultCode) in
            if resultCode == ResultCode.prebidDemandNoBids {
                fetchDemandCount += 1
            } else {
                XCTAssertEqual(resultCode, ResultCode.prebidDemandFetchSuccess, resultCode.name())
                XCTAssertNotNil(mopubBanner2?.keywords)
                let keywords = mopubBanner2?.keywords
                if let keywordsArray = keywords?.components(separatedBy: ",") {
                    XCTAssertEqual(10, keywordsArray.count)
                    XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
                    XCTAssertTrue (keywords!.contains("hb_cache_id:"))
                    fetchDemandCount += 1
                }
            }
        }

        wait(5)
        XCTAssertEqual(2, fetchDemandCount)
    }

    // MARK: - DFP delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        Utils.shared.findPrebidCreativeSize(bannerView) { (size) in
            if let bannerView = bannerView as? DFPBannerView, let size = size {
                bannerView.resize(GADAdSizeFromCGSize(size))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
                    let result = PBViewTool.checkDFPAdViewContainsPBMAd(bannerView)
                    XCTAssertTrue(result)
                    self.loadSuccesfulException?.fulfill()
                })
            }
        }
        
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        loadSuccesfulException = nil
    }

    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("Ad presented")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        // Send another GADRequest here
        print("Ad dismissed")
    }

    func interstitialDidReceiveAd(_ ad: GADInterstitial) {

        if (self.dfpInterstitial?.isReady ?? true) {
            print("Ad ready")
            self.dfpInterstitial?.present(fromRootViewController: viewController!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                let result = PBViewTool.checkDFPInterstitialAdViewContainsPBMAd(self.viewController!.presentedViewController!)
                XCTAssertTrue(result)
                self.loadSuccesfulException?.fulfill()
            })
        } else {
            print("Ad not ready")
        }
    }

    // MARK: - Mopub delegate
    func viewControllerForPresentingModalView() -> UIViewController! {
        return viewController
    }

    func adViewDidLoadAd(_ view: MPAdView!) {
        print("adViewDidReceiveAd")
        PBViewTool.checkMPAdViewContainsPBMAd(view) { (result) in
            XCTAssertTrue(result)
            self.loadSuccesfulException?.fulfill()
        }
    }

    func adViewDidFail(toLoadAd view: MPAdView!) {
        print("adViewDidFail")
        loadSuccesfulException = nil
    }

    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        print("Ad ready")
        if (self.mopubInterstitial?.ready ?? true) {
            self.mopubInterstitial?.show(from: viewController)
        }
    }

    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!) {
        print("Ad not ready")
        loadSuccesfulException = nil
    }

    func interstitialDidAppear(_ interstitial: MPInterstitialAdController!) {
        print("ad appeared")
        PBViewTool.checkMPInterstitialContainsPBMAd(self.viewController!.presentedViewController!, withCompletionHandler: { (result) in
                XCTAssertTrue(result)
                self.loadSuccesfulException?.fulfill()
            })

    }

    func interstitialWillAppear(_ interstitial: MPInterstitialAdController!) {
        print("ad appeared")
    }

}

extension XCTestCase {
    func wait(for element: XCUIElement, timeout: TimeInterval) {
        let p = NSPredicate(format: "exists == true") // Checks for exists true
        let e = expectation(for: p, evaluatedWith: element, handler: nil)
        wait(for: [e], timeout: timeout)
    }
    func wait(_ interval: Int) {
        let expectation: XCTestExpectation = self.expectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(interval), execute: {
            expectation.fulfill()
        })
        waitForExpectations(timeout: TimeInterval(interval + 1), handler: nil)
    }
}
