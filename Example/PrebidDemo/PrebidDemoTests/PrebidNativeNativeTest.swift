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
@testable import PrebidMobile
@testable import PrebidDemoSwift

class PrebidNativeNativeTest: XCTestCase, PrebidNativeAdDelegate, PrebidNativeAdEventDelegate {
    
    var request: URLRequest!
    var jsonRequestBody = [String: Any]()
    
    var adExpiredAPIForNativeAd: XCTestExpectation?
    var adDidClickAPIForNativeAd: XCTestExpectation?
    var adDidLogImpressionAPIForNativeAd: XCTestExpectation?
    var prebidNativeAdLoadedExpectation: XCTestExpectation?
    var prebidNativeAdNotFoundExpectation: XCTestExpectation?
    var prebidNativeAdNotValidExpectation: XCTestExpectation?
    
    var timeoutForImpbusRequest: TimeInterval = 0.0
    
    var prebidNativeAd: PrebidNativeAd?
    var prebidNativeAdView: PrebidNativeAdView!
    var nativeUnit: NativeRequest!
    var eventTrackers: NativeEventTracker!
    var viewController: PrebidNativeViewController?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Prebid.shared.prebidServerHost = .Appnexus
        Prebid.shared.prebidServerAccountId = Constants.PBS_ACCOUNT_ID_APPNEXUS
        timeoutForImpbusRequest = 10.0
        PBHTTPStubbingManager.shared().enable()
        PBHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
        PBHTTPStubbingManager.shared().broadcastRequests = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestCompleted(_:)), name: NSNotification.Name.pbhttpStubURLProtocolRequestDidLoad, object: nil)
        
        let storyboard = UIStoryboard(name: "Main",bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "prebidNative") as? PrebidNativeViewController
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window?.rootViewController = viewController
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        PBHTTPStubbingManager.shared().disable()
        PBHTTPStubbingManager.shared().removeAllStubs()
        PBHTTPStubbingManager.shared().broadcastRequests = false
        adExpiredAPIForNativeAd = nil
        adDidClickAPIForNativeAd = nil
        adDidLogImpressionAPIForNativeAd = nil
        prebidNativeAdLoadedExpectation = nil
        prebidNativeAdNotFoundExpectation = nil
        prebidNativeAdNotValidExpectation = nil
        request = nil
        removePreviousAds()
    }

    // MARK: - Test methods.
    func testSuccessfulPrebidNativeResponseForMoPub() {
        prebidNativeAdLoadedExpectation = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("PrebidNativeAdResponse")
        createPrebidNativeView()
        loadNativeAssets()
        let mpNativeAd = MPNativeAd()
        let mopubNativeObject = MPNativeAdRequest()
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeObject.targeting = mopubNativeAdRequestTargeting
        
        nativeUnit.fetchDemand(adObject: mopubNativeObject) { [weak self] (resultCode: ResultCode) in
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
    
    func testPrebidNativeResponseNotFoundForMoPub() {
        prebidNativeAdNotFoundExpectation = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("PrebidNativeAdResponse")
        createPrebidNativeView()
        loadNativeAssets()
        let mpNativeAd = MPNativeAd()
        let mopubNativeObject = MPNativeAdRequest()
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeObject.targeting = mopubNativeAdRequestTargeting
        
        nativeUnit.fetchDemand(adObject: mopubNativeObject) { [weak self] (resultCode: ResultCode) in
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
    
    func testPrebidNativeResponseNotValidForMoPub() {
        prebidNativeAdNotValidExpectation = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("PrebidNativeAdInvalidResponse")
        createPrebidNativeView()
        loadNativeAssets()
        let mpNativeAd = MPNativeAd()
        let mopubNativeObject = MPNativeAdRequest()
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeObject.targeting = mopubNativeAdRequestTargeting
        
        nativeUnit.fetchDemand(adObject: mopubNativeObject) { [weak self] (resultCode: ResultCode) in
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
    
    func testSuccessfulPrebidNativeResponseForDFP() {
        prebidNativeAdLoadedExpectation = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("PrebidNativeAdResponse")
        createPrebidNativeView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testPrebidNativeResponseNotFoundForDFP() {
        prebidNativeAdNotFoundExpectation = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("PrebidNativeAdResponse")
        createPrebidNativeView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            gadNativeCustomTemplateAd.setValue("0", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testPrebidNativeResponseNotValidForDFP() {
        prebidNativeAdNotValidExpectation = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("PrebidNativeAdInvalidResponse")
        createPrebidNativeView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testPrebidNativeAdWithAdDidLogImpression() {
        adDidLogImpressionAPIForNativeAd = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("PrebidNativeAdResponse")
        createPrebidNativeView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testPrebidNativeAdWithAdWasClicked() {
        adDidClickAPIForNativeAd = expectation(description: "\(#function)")
        stubAppNexusRequestWithResponse("PrebidNativeAdResponse")
        createPrebidNativeView()
        loadNativeAssets()
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let dfpRequest = DFPNRequest()
        
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(dfpRequest.p_customKeywords["hb_cache_id_local"], forKey: "hb_cache_id_local")
            
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        }
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testPrebidNativeAdWithAdDidExpired() {
        adExpiredAPIForNativeAd = expectation(description: "\(#function)")
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let currentBundle = Bundle(for: type(of: self))
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: "PrebidNativeAd", ofType: "json") ?? "", encoding: .utf8)
        if let cacheId = CacheManager.shared.testSave(content: baseResponse!), !cacheId.isEmpty{
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(cacheId, forKey: "hb_cache_id_local")
        }

        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    //MARK: : Native functions
    func createPrebidNativeView(){
        let adNib = UINib(nibName: "PrebidNativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let prebidNativeAdView = array.first as? PrebidNativeAdView{
            self.prebidNativeAdView = prebidNativeAdView
            prebidNativeAdView.frame = CGRect(x: 0, y: 100, width: 300, height: 250)
            viewController?.view.addSubview(prebidNativeAdView)
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
        
        nativeUnit = NativeRequest(configId: "25e17008-5081-4676-94d5-923ced4359d3", assets: [icon,title,image,body,cta,sponsored])
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        
        let event1 = EventType.Impression
        eventTrackers = NativeEventTracker(event: event1, methods: [EventTracking.Image,EventTracking.js])
        nativeUnit.eventtrackers = [eventTrackers]
    }
    
    func removePreviousAds() {
        if prebidNativeAdView != nil {
            prebidNativeAdView?.iconImageView = nil
            prebidNativeAdView?.mainImageView = nil
            prebidNativeAdView!.removeFromSuperview()
            prebidNativeAdView = nil
        }
        if prebidNativeAd != nil {
            prebidNativeAd = nil
        }
    }
    
    func registerPrebidNativeView(){
        prebidNativeAd?.delegate = self
        if  let prebidNativeAdView = prebidNativeAdView {
            prebidNativeAd?.registerView(view: prebidNativeAdView, clickableViews: [prebidNativeAdView.callToActionButton])
        }
    }
    
    //MARK: Rendering Prebid Native
    func renderPrebidNativeAd() {
        prebidNativeAdView?.titleLabel.text = prebidNativeAd?.title
        prebidNativeAdView?.bodyLabel.text = prebidNativeAd?.text
        if let iconString = prebidNativeAd?.iconUrl, let iconUrl = URL(string: iconString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: iconUrl)
                DispatchQueue.main.async {
                    if data != nil {
                        self.prebidNativeAdView?.iconImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        if let imageString = prebidNativeAd?.imageUrl,let imageUrl = URL(string: imageString) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    if data != nil {
                     self.prebidNativeAdView?.mainImageView.image = UIImage(data:data!)
                    }
                }
            }
        }
        prebidNativeAdView?.callToActionButton.setTitle(prebidNativeAd?.callToAction, for: .normal)
        prebidNativeAdView?.sponsoredLabel.text = prebidNativeAd?.sponsoredBy
    }
    
    //MARK: PrebidNativeAdDelegate
    func prebidNativeAdLoaded(ad: PrebidNativeAd) {
        CacheManager.shared.delegate = ad
        prebidNativeAd = ad
        registerPrebidNativeView()
        renderPrebidNativeAd()
        self.prebidNativeAdLoadedExpectation?.fulfill()
        if self.adDidClickAPIForNativeAd != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.prebidNativeAdView?.callToActionButton.sendActions(for: .touchUpInside)
            })
        }
    }
    
    func prebidNativeAdNotFound() {
        self.prebidNativeAdNotFoundExpectation?.fulfill()
    }
    
    func prebidNativeAdNotValid() {
        self.prebidNativeAdNotValidExpectation?.fulfill()
    }
    
    //MARK: PrebidNativeAdEventDelegate
    func adDidExpire(ad:PrebidNativeAd){
        self.adExpiredAPIForNativeAd?.fulfill()
    }
    func adWasClicked(ad:PrebidNativeAd){
        self.adDidClickAPIForNativeAd?.fulfill()
    }
    func adDidLogImpression(ad:PrebidNativeAd){
        self.adDidLogImpressionAPIForNativeAd?.fulfill()
    }

    
    // MARK: - Stubbing
    func stubAppNexusRequestWithResponse(_ responseName: String?) {
        let currentBundle = Bundle(for: type(of: self))
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: responseName, ofType: "json") ?? "", encoding: .utf8)
        let requestStub = PBURLConnectionStub()
        requestStub.requestURL = "https://prebid.adnxs.com/pbs/v1/openrtb2/auction"
        requestStub.responseCode = 200
        requestStub.responseBody = baseResponse
        PBHTTPStubbingManager.shared().add(requestStub)
    }
    
    func requestCompleted(_ notification: Notification?) {
        let incomingRequest = notification?.userInfo![kPBHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = "https://prebid.adnxs.com/pbs/v1/openrtb2/auction"
        if request == nil && requestString?.range(of: searchString) != nil {
            request = notification!.userInfo![kPBHTTPStubURLProtocolRequest] as? URLRequest
            jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String: Any]
        }
    }
    
}


extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}
extension String {
    var unescaped: String {
        let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\", "\\\'", "\\\""]
        var current = self
        for entity in entities {
            let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
            let description = String(descriptionCharacters)
            current = current.replacingOccurrences(of: description, with: entity)
        }
        return current
    }
}

extension CacheManager {
    func testSave(content: String) -> String?{
        if content.isEmpty {
            return nil
        }else{
            let cacheId = "Prebid_" + UUID().uuidString
            self.savedValuesDict[cacheId] = content
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.savedValuesDict.removeValue(forKey: cacheId)
                self.delegate?.cacheExpired()
            })
            return cacheId
        }
    }
}

@objcMembers class MPNativeAdRequest: NSObject {
    
    var name: String!
    private(set) var p_customTargeting: MPNativeAdRequestTargeting

    var targeting: MPNativeAdRequestTargeting {

        get {
            return p_customTargeting
        }

        set {
            self.p_customTargeting = newValue
        }

    }

    override init() {
        self.p_customTargeting = MPNativeAdRequestTargeting()
    }
}

@objcMembers class MPNativeAdRequestTargeting: NSObject {
    var name: String!
    private(set) var p_customKeywords: String = ""

    var keywords: String {

        get {
            return p_customKeywords
        }

        set {
            self.p_customKeywords = newValue
        }

    }
}

@objcMembers class DFPNRequest: NSObject {
    var name: String!
    private(set) var p_customKeywords: [String: AnyObject]

    var customTargeting: [String: AnyObject] {

        get {
            return p_customKeywords
        }

        set {
            self.p_customKeywords = newValue
        }

    }

    override init() {
        self.p_customKeywords = [String: AnyObject]()
    }
}

@objcMembers class MPNativeAd: NSObject {
    
    var name: String!
    var p_customProperties: [String:AnyObject]

    var properties:  [String:AnyObject] {

        get {
            return p_customProperties
        }

        set {
            self.p_customProperties = newValue
        }

    }

    override init() {
        self.p_customProperties = [String:AnyObject]()
        self.p_customProperties["isPrebid"] = 1 as AnyObject
    }
}

class GADNativeCustomTemplateAd: UserDefaults {}

