/*   Copyright 2019-2020 Prebid.org, Inc.

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
@testable import PrebidDemoSwift

class NativeInAppNativeTest: XCTestCase {
    
    var request: URLRequest!
    var jsonRequestBody = [String: Any]()
    
    var adExpiredAPIForNativeAd: XCTestExpectation?
    var adDidClickAPIForNativeAd: XCTestExpectation?
    var adDidLogImpressionAPIForNativeAd: XCTestExpectation?
    var nativeInAppAdLoadedExpectation: XCTestExpectation?
    var nativeInAppAdNotFoundExpectation: XCTestExpectation?
    var nativeInAppAdNotValidExpectation: XCTestExpectation?
    
    var timeoutForImpbusRequest: TimeInterval = 0.0
    
    var nativeAd: NativeAd?
    var nativeAdView: NativeAdView!
    var nativeUnit: NativeRequest!
    var eventTrackers: NativeEventTracker!
    var viewController: NativeInAppViewController?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setUp() {
        Prebid.shared.prebidServerHost = .Appnexus
        Prebid.shared.prebidServerAccountId = Constants.PBS_ACCOUNT_ID_APPNEXUS
        timeoutForImpbusRequest = 20.0
        StubbingHandler.shared.turnOn()
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestCompleted(_:)), name: NSNotification.Name.pbhttpStubURLProtocolRequestDidLoad, object: nil)
    }
    
    override func tearDown() {
        StubbingHandler.shared.turnOff()
        adExpiredAPIForNativeAd = nil
        adDidClickAPIForNativeAd = nil
        adDidLogImpressionAPIForNativeAd = nil
        nativeInAppAdLoadedExpectation = nil
        nativeInAppAdNotFoundExpectation = nil
        nativeInAppAdNotValidExpectation = nil
        request = nil
        removePreviousAds()
    }

    // MARK: - Test methods.
    func testSuccessfulNativeInAppResponseForMoPub() {
        setupViewController(for: .originalMoPub)
        nativeInAppAdLoadedExpectation = expectation(description: "\(#function)")
        StubbingHandler.shared.stubRequest(with: "NativeAdResponse", requestURL: Constants.PBS_APPNEXUS_HOST_URL)
        createNativeInAppView()
        loadNativeAssets()
        let mpNativeAd = MPNativeAd()
        let mopubNativeObject = MPNativeAdRequest()
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeObject.targeting = mopubNativeAdRequestTargeting
        
        nativeUnit.fetchDemand(adObject: mopubNativeObject) { [weak self] (resultCode: FetchDemandResult) in
            let array = mopubNativeObject.targeting.keywords.components(separatedBy: ",")
            for keyword in array{
                let keywordArr = keyword.components(separatedBy: ":")
                mpNativeAd.p_customProperties[keywordArr[0]] = keywordArr[1] as AnyObject
            }
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: mpNativeAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testNativeInAppResponseNotFoundForMoPub() {
        setupViewController(for: .originalMoPub)
        nativeInAppAdNotFoundExpectation = expectation(description: "\(#function)")
        StubbingHandler.shared.stubRequest(with: "NativeAdResponse", requestURL: Constants.PBS_APPNEXUS_HOST_URL)
        createNativeInAppView()
        loadNativeAssets()
        let mpNativeAd = MPNativeAd()
        let mopubNativeObject = MPNativeAdRequest()
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeObject.targeting = mopubNativeAdRequestTargeting
        
        nativeUnit.fetchDemand(adObject: mopubNativeObject) { [weak self] (resultCode: FetchDemandResult) in
            let array = mopubNativeObject.targeting.keywords.components(separatedBy: ",")
            for keyword in array{
                let keywordArr = keyword.components(separatedBy: ":")
                mpNativeAd.p_customProperties[keywordArr[0]] = keywordArr[1] as AnyObject
            }
            mpNativeAd.p_customProperties["isPrebid"] = 0 as AnyObject
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: mpNativeAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testNativeInAppResponseNotValidForMoPub() {
        setupViewController(for: .originalMoPub)
        nativeInAppAdNotValidExpectation = expectation(description: "\(#function)")
        StubbingHandler.shared.stubRequest(with: "NativeAdInvalidResponse", requestURL: Constants.PBS_APPNEXUS_HOST_URL)
        createNativeInAppView()
        loadNativeAssets()
        let mpNativeAd = MPNativeAd()
        let mopubNativeObject = MPNativeAdRequest()
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeObject.targeting = mopubNativeAdRequestTargeting
        
        nativeUnit.fetchDemand(adObject: mopubNativeObject) { [weak self] (resultCode: FetchDemandResult) in
            let array = mopubNativeObject.targeting.keywords.components(separatedBy: ",")
            for keyword in array{
                let keywordArr = keyword.components(separatedBy: ":")
                mpNativeAd.p_customProperties[keywordArr[0]] = keywordArr[1] as AnyObject
            }
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: mpNativeAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testSuccessfulNativeInAppResponseForDFP() {
        setupViewController(for: .originalGAM)
        nativeInAppAdLoadedExpectation = expectation(description: "\(#function)")
        StubbingHandler.shared.stubRequest(with: "NativeAdResponse", requestURL: Constants.PBS_APPNEXUS_HOST_URL)
        createNativeInAppView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: FetchDemandResult) in
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testNativeInAppResponseNotFoundForDFP() {
        setupViewController(for: .originalGAM)
        nativeInAppAdNotFoundExpectation = expectation(description: "\(#function)")
        StubbingHandler.shared.stubRequest(with: "NativeAdResponse", requestURL: Constants.PBS_APPNEXUS_HOST_URL)
        createNativeInAppView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: FetchDemandResult) in
            gadNativeCustomTemplateAd.setValue("0", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testNativeInAppResponseNotValidForDFP() {
        setupViewController(for: .originalGAM)
        nativeInAppAdNotValidExpectation = expectation(description: "\(#function)")
        StubbingHandler.shared.stubRequest(with: "NativeAdInvalidResponse", requestURL: Constants.PBS_APPNEXUS_HOST_URL)
        createNativeInAppView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: FetchDemandResult) in
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testNativeInAppAdWithAdDidLogImpression() {
        setupViewController(for: .originalGAM)
        adDidLogImpressionAPIForNativeAd = expectation(description: "\(#function)")
        StubbingHandler.shared.stubRequest(with: "NativeAdResponse", requestURL: Constants.PBS_APPNEXUS_HOST_URL)
        createNativeInAppView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: FetchDemandResult) in
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testNativeInAppAdWithAdWasClicked() {
        setupViewController(for: .originalGAM)
        adDidClickAPIForNativeAd = expectation(description: "\(#function)")
        StubbingHandler.shared.stubRequest(with: "NativeAdResponse", requestURL: Constants.PBS_APPNEXUS_HOST_URL)
        createNativeInAppView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: FetchDemandResult) in
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testNativeInAppAdWithAdDidExpired() {
        setupViewController(for: .originalGAM)
        adExpiredAPIForNativeAd = expectation(description: "\(#function)")
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let currentBundle = Bundle(for: TestUtils.PBHTTPStubbingManager.self)
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: "NativeAd", ofType: "json") ?? "", encoding: .utf8)
        if let cacheId = CacheManager.shared.testSave(content: baseResponse!), !cacheId.isEmpty{
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(cacheId, forKey: "hb_cache_id_local")
        }

        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func requestCompleted(_ notification: Notification?) {
        let incomingRequest = notification?.userInfo![kPBHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = Constants.PBS_APPNEXUS_HOST_URL
        if request == nil && requestString?.range(of: searchString) != nil {
            request = notification!.userInfo![kPBHTTPStubURLProtocolRequest] as? URLRequest
            jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String: Any]
        }
    }
    
    private func setupViewController(for integrationKind: IntegrationKind) {
        let storyboard = UIStoryboard(name: "Main",bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "NativeInAppViewController") as? NativeInAppViewController
        viewController?.integrationKind = integrationKind
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window?.rootViewController = viewController
    }
}

// MARK: - NativeAdDelegate

extension NativeInAppNativeTest: NativeAdDelegate {
    func nativeAdLoaded(ad: NativeAd) {
        nativeAd = ad
        CacheManager.shared.delegate = ad
        nativeAd?.delegate = self
        if let nativeAdView = nativeAdView {
            nativeAd?.registerView(view: nativeAdView, clickableViews: [nativeAdView.callToActionButton])
        }
        renderNativeInAppAd()
        self.nativeInAppAdLoadedExpectation?.fulfill()
        if self.adDidClickAPIForNativeAd != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.nativeAdView?.callToActionButton.sendActions(for: .touchUpInside)
            })
        }
    }
    
    func nativeAdNotFound() {
        self.nativeInAppAdNotFoundExpectation?.fulfill()
    }
    
    func nativeAdNotValid() {
        self.nativeInAppAdNotValidExpectation?.fulfill()
    }
}

// MARK: - NativeAdEventDelegate

extension NativeInAppNativeTest: NativeAdEventDelegate {
    func adDidExpire(ad: NativeAd) {
        self.adExpiredAPIForNativeAd?.fulfill()
    }
    
    func adWasClicked(ad: NativeAd) {
        self.adDidClickAPIForNativeAd?.fulfill()
    }
    
    func adDidLogImpression(ad: NativeAd) {
        self.adDidLogImpressionAPIForNativeAd?.fulfill()
    }
}

// MARK: - Native Helpers

extension NativeInAppNativeTest {
    func createNativeInAppView(){
        let adNib = UINib(nibName: "NativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let nativeAdView = array.first as? NativeAdView{
            self.nativeAdView = nativeAdView
            nativeAdView.frame = CGRect(x: 0, y: 100, width: 300, height: 250)
            viewController?.view.addSubview(nativeAdView)
        }
    }
    
    func loadNativeAssets(){
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 200, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        
        let body = NativeAssetData(type: DataAsset.description, required: true)
        
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
    
        let event1 = EventType.Impression
        eventTrackers = NativeEventTracker(event: event1, methods: [EventTracking.Image,EventTracking.js])
        
        nativeUnit = NativeRequest(configId: "25e17008-5081-4676-94d5-923ced4359d3",
                                   assets: [icon,title,image,body,cta,sponsored],
                                   eventTrackers: [eventTrackers])
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
    }
    
    func removePreviousAds() {
        if nativeAdView != nil {
            nativeAdView?.iconImageView = nil
            nativeAdView?.mainImageView = nil
            nativeAdView!.removeFromSuperview()
            nativeAdView = nil
        }
        
        if nativeAd != nil {
            nativeAd = nil
        }
    }
    
    // MARK: Rendering Prebid Native
    func renderNativeInAppAd() {
        nativeAdView?.titleLabel.text = nativeAd?.title
        nativeAdView?.bodyLabel.text = nativeAd?.text
        if let iconString = nativeAd?.iconUrl, let iconUrl = URL(string: iconString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: iconUrl)
                DispatchQueue.main.async {
                    if data != nil {
                        self.nativeAdView?.iconImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        if let imageString = nativeAd?.imageUrl,let imageUrl = URL(string: imageString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    if data != nil {
                     self.nativeAdView?.mainImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        nativeAdView?.callToActionButton.setTitle(nativeAd?.callToAction, for: .normal)
        nativeAdView?.sponsoredLabel.text = nativeAd?.sponsoredBy
    }
}
