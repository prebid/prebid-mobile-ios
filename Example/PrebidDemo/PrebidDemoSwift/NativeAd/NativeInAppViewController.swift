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

import UIKit
import GoogleMobileAds
import PrebidMobile

import PrebidMobileGAMEventHandlers
import PrebidMobileAdMobAdapters

fileprivate let nativeStoredImpression = "imp-prebid-banner-native-styles"
fileprivate let nativeStoredResponse = "response-prebid-banner-native-styles"

fileprivate let gamRenderingNativeAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
fileprivate let admobRenderingNativeAdUnitId = "ca-app-pub-5922967660082475/8634069303"

class NativeInAppViewController: UIViewController {

    @IBOutlet weak var adContainerView: UIView!
    
    var adLoader: GADAdLoader?
    var nativeAd: NativeAd?
    var nativeAdView: NativeAdView?
    var nativeUnit: NativeRequest!
    var eventTrackers: NativeEventTracker!
    var integrationKind: IntegrationKind = .undefined
    
    var gadRequest: GADRequest!
    var mediationDelegate: AdMobMediationNativeUtils!
    var admobMediationNativeAdUnit: MediationNativeAdUnit!
    
    var defaultNativeRequestAssets: [NativeAsset] {
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 50, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        let body = NativeAssetData(type: DataAsset.description, required: true)
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
        
        return [title,icon,image,sponsored,body,cta]
    }
    
    var defaultEventTrackers: [NativeEventTracker] {
       [NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])]
    }

    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch integrationKind {
        case .originalGAM:
            setupAndLoadNativeInAppForDFP()
        case .inApp:
            setupAndLoadNativeRenderingInApp()
        case .renderingGAM:
            setupAndLoadNativeRenderingGAM()
        case .renderingAdMob:
            setupAndLoadNativeRenderingAdMob()
        case .renderingMAX:
            print("TODO: Add Example")
        case .undefined:
            assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }
    }
    
    deinit {
        Prebid.shared.storedAuctionResponse = nil
    }
    
    func setupPrebidServer(storedResponse: String) {
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")

        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    func setupNativeAdUnit(_ configId: String) {
        nativeUnit = NativeRequest(configId: configId, assets: defaultNativeRequestAssets)
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
    
        nativeUnit.eventtrackers = defaultEventTrackers
    }
    
    func setupAdMobMediationNativeAdUnit(_ configId: String) {
        gadRequest = GADRequest()
        mediationDelegate = AdMobMediationNativeUtils(gadRequest: gadRequest)
        admobMediationNativeAdUnit = MediationNativeAdUnit(configId: nativeStoredImpression,
                                                      mediationDelegate: mediationDelegate)
        admobMediationNativeAdUnit.addNativeAssets(defaultNativeRequestAssets)
        admobMediationNativeAdUnit.setContextType(.Social)
        admobMediationNativeAdUnit.setPlacementType(.FeedContent)
        admobMediationNativeAdUnit.setContextSubType(.Social)
        
        admobMediationNativeAdUnit.addEventTracker(defaultEventTrackers)
    }
    
    // In-App
    func setupAndLoadNativeRenderingInApp() {
        setupPrebidServer(storedResponse: nativeStoredResponse)
        setupNativeAdUnit(nativeStoredImpression)
        loadNativeInAppAd()
    }
    
    func loadNativeInAppAd() {
        nativeUnit.fetchDemand { [weak self] result, kvResultDict in
            guard let self = self else {
                return
            }
            
            guard let kvResultDict = kvResultDict, let cacheId = kvResultDict[PrebidLocalCacheIdKey] else {
                return
            }
            
            guard let nativeAd = NativeAd.create(cacheId: cacheId) else {
                return
            }
            
            self.createNativeInAppView()
            self.nativeAd = nativeAd
            self.registerNativeInAppView()
            self.renderNativeInAppAd()
        }
    }
    
    // Rendering GAM
    func setupAndLoadNativeRenderingGAM() {
        setupPrebidServer(storedResponse: nativeStoredResponse)
        setupNativeAdUnit(nativeStoredImpression)
        loadNativeRenderingGAM()
    }
    
    func loadNativeRenderingGAM() {
        nativeUnit.fetchDemand { result, kvResultDict in
            let dfpRequest = GAMRequest()
            GAMUtils.shared.prepareRequest(dfpRequest, bidTargeting: kvResultDict ?? [:])
            
            self.adLoader = GADAdLoader(adUnitID: gamRenderingNativeAdUnitId,
                                        rootViewController: self,
                                        adTypes: [.customNative],
                                        options: [])
            self.adLoader?.delegate = self
            self.adLoader?.load(dfpRequest)
        }
    }
    
    // Rendering AdMob
    func setupAndLoadNativeRenderingAdMob() {
        setupPrebidServer(storedResponse: nativeStoredResponse)
        setupAdMobMediationNativeAdUnit(nativeStoredImpression)
        loadNativeRenderingAdMob()
    }
    
    func loadNativeRenderingAdMob() {
        admobMediationNativeAdUnit.fetchDemand { [weak self] result in
            guard let self = self else { return }
            
            let prebidExtras = self.mediationDelegate.getEventExtras()
            let extras = GADCustomEventExtras()
            extras.setExtras(prebidExtras, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
            self.gadRequest.register(extras)
            
            self.adLoader = GADAdLoader(adUnitID: admobRenderingNativeAdUnitId,
                                        rootViewController: self,
                                        adTypes: [ .native ],
                                        options: nil)
            self.adLoader?.delegate = self
            
            self.adLoader?.load(self.gadRequest)
        }
    }
    
    func setupPBNativeInApp(host: PrebidHost, accountId: String, configId: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        
        setupNativeAdUnit(configId)
    }
    
    func createNativeInAppView(){
        removePreviousAds()
        let adNib = UINib(nibName: "NativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let nativeAdView = array.first as? NativeAdView {
            self.nativeAdView = nativeAdView
            nativeAdView.frame = CGRect(x: 0, y: 0, width: self.adContainerView.frame.size.width, height: 150 + self.screenWidth * 400 / 600)
            self.adContainerView.addSubview(nativeAdView)
        }
    }
    
    func renderNativeInAppAd() {
        nativeAdView?.titleLabel.text = nativeAd?.title
        nativeAdView?.bodyLabel.text = nativeAd?.text
        
        if let iconString = nativeAd?.iconUrl {
            ImageHelper.downloadImageAsync(iconString) { result in
                if case let .success(icon) = result {
                    DispatchQueue.main.async {
                        self.nativeAdView?.iconImageView.image = icon
                    }
                }
            }
        }
        
        if let imageString = nativeAd?.imageUrl {
            ImageHelper.downloadImageAsync(imageString) { result in
                if case let .success(image) = result {
                    DispatchQueue.main.async {
                        self.nativeAdView?.mainImageView.image = image
                    }
                }
            }
        }
        
        nativeAdView?.callToActionButton.setTitle(nativeAd?.callToAction, for: .normal)
        nativeAdView?.sponsoredLabel.text = nativeAd?.sponsoredBy
    }
    
    func renderCustomTemplateAd(_ customTemplateAd: GADCustomNativeAd) {
        nativeAdView?.titleLabel.text = customTemplateAd.string(forKey: "title")
        nativeAdView?.bodyLabel.text = customTemplateAd.string(forKey: "text")
        
        nativeAdView?.callToActionButton.setTitle(customTemplateAd.string(forKey: "cta"), for: .normal)
        nativeAdView?.sponsoredLabel.text = customTemplateAd.string(forKey: "sponsoredBy")
        
        if let imageString = customTemplateAd.string(forKey: "imgUrl") {
            ImageHelper.downloadImageAsync(imageString) { result in
                if case let .success(image) = result {
                    DispatchQueue.main.async {
                        self.nativeAdView?.mainImageView.image = image
                    }
                }
            }
        }
        
        if let iconString = customTemplateAd.string(forKey: "iconUrl") {
            ImageHelper.downloadImageAsync(iconString) { result in
                if case let .success(icon) = result {
                    DispatchQueue.main.async {
                        self.nativeAdView?.iconImageView.image = icon
                    }
                }
            }
        }
        
        nativeAdView?.bodyLabel.numberOfLines = 0
     }
    
    func renderGADNativeAd(_ gadAd: GADNativeAd) {
        nativeAdView?.titleLabel.text = gadAd.headline
        nativeAdView?.bodyLabel.text = gadAd.body
        
        nativeAdView?.callToActionButton.setTitle(gadAd.callToAction ?? "", for: .normal)
        nativeAdView?.sponsoredLabel.text = gadAd.advertiser
        
        if let adIcon = gadAd.icon {
            self.nativeAdView?.iconImageView.image = adIcon.image
        }
        
        if let adImage = gadAd.images?.first {
            self.nativeAdView?.mainImageView.image = adImage.image
        }

        nativeAdView?.bodyLabel.numberOfLines = 0
    }
    
    func setupAndLoadNativeInAppForDFP() {
        setupPBNativeInApp(host: .Appnexus, accountId: "bfa84af2-bd16-4d35-96ad-31c6bb888df0", configId: "25e17008-5081-4676-94d5-923ced4359d3")
        loadNativeInAppForDFP()
    }
    
    func loadNativeInAppForDFP(){
        let dfpRequest = GAMRequest()
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            self?.callDFP(dfpRequest)
        }
    }
    
    func callDFP(_ dfpRequest: GAMRequest){
        adLoader = GADAdLoader(adUnitID: "/19968336/Abhas_test_native_native_adunit",
                               rootViewController: self,
                               adTypes: [ GADAdLoaderAdType.gamBanner, GADAdLoaderAdType.customNative],
                               options: [ ])
        adLoader?.delegate  = self
        adLoader?.load(dfpRequest)
    }
    
    //MARK: Helper functions
    
    func registerNativeInAppView() {
        nativeAd?.delegate = self
        if let nativeAdView = nativeAdView {
            nativeAd?.registerView(view: nativeAdView, clickableViews: [nativeAdView.callToActionButton])
        }
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
}

extension NativeInAppViewController: GAMBannerAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive bannerView: GAMBannerView) {
        nativeAdView?.addSubview(bannerView)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Prebid GADAdLoader failed \(error)")
    }
    
    func validBannerSizes(for adLoader: GADAdLoader) -> [NSValue] {
        return [NSValueFromGADAdSize(kGADAdSizeBanner)]
    }
}

extension NativeInAppViewController: GADCustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        if adLoader.adUnitID == gamRenderingNativeAdUnitId {
            return ["11934135"]
        }
        return ["11963183"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        if adLoader.adUnitID == gamRenderingNativeAdUnitId {
            let result = GAMUtils.shared.findCustomNativeAd(for: customNativeAd)
            
            switch result {
            case .success(let nativeAd):
                self.createNativeInAppView()
                self.nativeAd = nativeAd
                registerNativeInAppView()
                renderNativeInAppAd()
            case .failure(let error):
                if error == GAMEventHandlerError.nonPrebidAd {
                    self.createNativeInAppView()
                    self.renderCustomTemplateAd(customNativeAd)
                }
            }
        } else {
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: customNativeAd)
        }
    }
}

extension NativeInAppViewController: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        createNativeInAppView()
        nativeAdView?.nativeAd = nativeAd
        renderGADNativeAd(nativeAd)
    }
}

extension NativeInAppViewController: NativeAdDelegate {
    
    func nativeAdLoaded(ad: NativeAd) {
        print("nativeAdLoaded")
        nativeAd = ad
        registerNativeInAppView()
        renderNativeInAppAd()
    }
    
    func nativeAdNotFound() {
        print("nativeAdNotFound")
    }
    
    func nativeAdNotValid() {
        print("nativeAdNotValid")
    }
}

extension NativeInAppViewController: NativeAdEventDelegate {
    
    func adDidExpire(ad:NativeAd){
        print("adDidExpire")
    }
    
    func adWasClicked(ad:NativeAd){
        print("adWasClicked")
    }
    
    func adDidLogImpression(ad:NativeAd){
        print("adDidLogImpression")
    }
}
