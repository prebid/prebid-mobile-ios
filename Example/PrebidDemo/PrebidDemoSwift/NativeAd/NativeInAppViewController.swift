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
import AppLovinSDK

import PrebidMobile

import PrebidMobileGAMEventHandlers
import PrebidMobileAdMobAdapters
import PrebidMobileMAXAdapters

fileprivate let nativeStoredImpression = "imp-prebid-banner-native-styles"
fileprivate let nativeStoredResponse = "response-prebid-banner-native-styles"

fileprivate let gamRenderingNativeAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"
fileprivate let admobRenderingNativeAdUnitId = "ca-app-pub-5922967660082475/8634069303"
fileprivate let maxRenderingNativeAdUnitId = "52e66b26792f28ca"

class NativeInAppViewController: UIViewController {
    
    @IBOutlet weak var adContainerView: UIView!
    
    var adLoader: GADAdLoader?
    var nativeAd: NativeAd?
    
    lazy var defaultAdViewSize = CGSize(width: adContainerView.frame.size.width, height: 150 + screenWidth * 400 / 600)
    
    var nativeAdRenderer: NativeAdRenderer? {
        didSet {
            nativeAd = nil
            if let nativeAdRenderer = nativeAdRenderer {
                self.adContainerView.addSubview(nativeAdRenderer.nativeAdView)
            }
        }
    }
    
    var nativeUnit: NativeRequest!
    var eventTrackers: NativeEventTracker!
    var integrationKind: IntegrationKind = .undefined
    
    var gadRequest: GADRequest!
    var mediationDelegate: AdMobMediationNativeUtils!
    var admobMediationNativeAdUnit: MediationNativeAdUnit!
    
    private var maxMediationNativeAdUnit: MediationNativeAdUnit!
    private var maxMediationDelegate: MAXMediationNativeUtils!
    private var maxNativeAdLoader: MANativeAdLoader!
    private var maxLoadedNativeAd: MAAd!
    
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
        // To run this example you should create your own MAX ad unit.
        case .renderingMAX:
            setupAndLoadNativeRenderingMAX()
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
        nativeUnit = NativeRequest(configId: configId, assets: .defaultNativeRequestAssets)
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        
        nativeUnit.eventtrackers = .defaultEventTrackers
    }
    
    func setupAdMobMediationNativeAdUnit(_ configId: String) {
        gadRequest = GADRequest()
        mediationDelegate = AdMobMediationNativeUtils(gadRequest: gadRequest)
        admobMediationNativeAdUnit = MediationNativeAdUnit(configId: nativeStoredImpression,
                                                           mediationDelegate: mediationDelegate)
        admobMediationNativeAdUnit.addNativeAssets(.defaultNativeRequestAssets)
        admobMediationNativeAdUnit.setContextType(.Social)
        admobMediationNativeAdUnit.setPlacementType(.FeedContent)
        admobMediationNativeAdUnit.setContextSubType(.Social)
        
        admobMediationNativeAdUnit.addEventTracker(.defaultEventTrackers)
    }
    
    // Original GAM
    
    func setupAndLoadNativeInAppForDFP() {
        setupPrebidServer(storedResponse: nativeStoredResponse)
        setupNativeAdUnit(nativeStoredImpression)
        loadNativeInAppForDFP()
    }
    
    func loadNativeInAppForDFP(){
        let dfpRequest = GAMRequest()
        nativeUnit.fetchDemand(adObject: dfpRequest) { [weak self] (resultCode: ResultCode) in
            guard let self = self else { return }
            self.adLoader = GADAdLoader(adUnitID: gamRenderingNativeAdUnitId,
                                   rootViewController: self,
                                   adTypes: [GADAdLoaderAdType.customNative],
                                   options: [])
            self.adLoader?.delegate  = self
            self.adLoader?.load(dfpRequest)
        }
    }
    
    // In-App
    func setupAndLoadNativeRenderingInApp() {
        nativeAdRenderer = nil
        setupPrebidServer(storedResponse: nativeStoredResponse)
        setupNativeAdUnit(nativeStoredImpression)
        loadNativeRenderingInAppAd()
    }
    
    func loadNativeRenderingInAppAd() {
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
            
            self.nativeAdRenderer = NativeAdRenderer(size: self.defaultAdViewSize)
            self.nativeAd = nativeAd
            self.nativeAdRenderer?.renderNativeInAppAd(with: nativeAd)
        }
    }
    
    // Rendering GAM
    func setupAndLoadNativeRenderingGAM() {
        nativeAdRenderer = nil
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
        nativeAdRenderer = nil
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
    
    // Rendering MAX
    func setupAndLoadNativeRenderingMAX() {
        nativeAdRenderer = nil
        setupPrebidServer(storedResponse: nativeStoredResponse)
        setupMAXMediationNativeAdUnit(nativeStoredImpression)
        loadNativeRenderingMAX()
    }
    
    func setupMAXMediationNativeAdUnit(_ configId: String) {
        maxNativeAdLoader = MANativeAdLoader(adUnitIdentifier: maxRenderingNativeAdUnitId)
        maxNativeAdLoader.nativeAdDelegate = self
        maxMediationDelegate = MAXMediationNativeUtils(nativeAdLoader: maxNativeAdLoader)
        maxMediationNativeAdUnit = MediationNativeAdUnit(configId: configId, mediationDelegate: maxMediationDelegate)
        
        maxMediationNativeAdUnit.addNativeAssets(.defaultNativeRequestAssets)
        maxMediationNativeAdUnit.setContextType(.Social)
        maxMediationNativeAdUnit.setPlacementType(.FeedContent)
        maxMediationNativeAdUnit.setContextSubType(.Social)
        maxMediationNativeAdUnit.addEventTracker(.defaultEventTrackers)
    }
    
    func loadNativeRenderingMAX() {
        maxMediationNativeAdUnit.fetchDemand { [weak self] result in
            self?.maxNativeAdLoader.loadAd(into: self?.createMAXAndBindNativeAdView())
        }
    }
    
    private func createMAXAndBindNativeAdView() -> MANativeAdView {
        let nativeAdViewNib = UINib(nibName: "MAXNativeAdView", bundle: Bundle.main)
        let nativeAdView = nativeAdViewNib.instantiate(withOwner: nil, options: nil).first! as! MANativeAdView?
        
        let adViewBinder = MANativeAdViewBinder.init(builderBlock: { (builder) in
            builder.iconImageViewTag = 1
            builder.titleLabelTag = 2
            builder.bodyLabelTag = 3
            builder.advertiserLabelTag = 4
            builder.callToActionButtonTag = 5
            builder.mediaContentViewTag = 123
        })
        
        nativeAdView!.bindViews(with: adViewBinder)
        return nativeAdView!
    }
}

// MARK: - NativeAdDelegate

extension NativeInAppViewController: NativeAdDelegate {
    func nativeAdLoaded(ad: NativeAd) {
        print("nativeAdLoaded")
        nativeAd = ad
        nativeAdRenderer = NativeAdRenderer(size: defaultAdViewSize)
        nativeAdRenderer?.renderNativeInAppAd(with: ad)
    }
    
    func nativeAdNotFound() {
        print("nativeAdNotFound")
    }
    
    func nativeAdNotValid() {
        print("nativeAdNotValid")
    }
}

// MARK: - NativeAdEventDelegate

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

// MARK: - GADCustomNativeAdLoaderDelegate

extension NativeInAppViewController: GADCustomNativeAdLoaderDelegate {
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        if adLoader.adUnitID == gamRenderingNativeAdUnitId {
            return ["11934135"]
        }
        return []
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        if integrationKind == .renderingGAM {
            let result = GAMUtils.shared.findCustomNativeAd(for: customNativeAd)
            
            switch result {
            case .success(let nativeAd):
                self.nativeAd = nativeAd
                nativeAdRenderer = NativeAdRenderer(size: defaultAdViewSize)
                nativeAdRenderer?.renderNativeInAppAd(with: nativeAd)
            case .failure(let error):
                if error == GAMEventHandlerError.nonPrebidAd {
                    nativeAdRenderer = NativeAdRenderer(size: defaultAdViewSize)
                    nativeAdRenderer?.renderCustomTemplateAd(with: customNativeAd)
                }
            }
        } else {
            Utils.shared.delegate = self
            Utils.shared.findNative(adObject: customNativeAd)
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Prebid GADAdLoader failed \(error)")
    }
}

// MARK: - GADNativeAdLoaderDelegate

extension NativeInAppViewController: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAdRenderer = NativeAdRenderer(size: defaultAdViewSize)
        nativeAdRenderer?.nativeAdView.nativeAd = nativeAd
        nativeAdRenderer?.renderGADNativeAd(with: nativeAd)
    }
}

// MARK: - MANativeAdDelegate

extension NativeInAppViewController: MANativeAdDelegate {
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        if let nativeAd = maxLoadedNativeAd {
            maxNativeAdLoader?.destroy(nativeAd)
        }

        adContainerView.backgroundColor = .clear
        
        maxLoadedNativeAd = ad
        nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        adContainerView.addSubview(nativeAdView!)
        
        adContainerView.heightAnchor.constraint(equalTo: nativeAdView!.heightAnchor).isActive = true
        adContainerView.topAnchor.constraint(equalTo: nativeAdView!.topAnchor).isActive = true
        adContainerView.leftAnchor.constraint(equalTo: nativeAdView!.leftAnchor).isActive = true
        adContainerView.rightAnchor.constraint(equalTo: nativeAdView!.rightAnchor).isActive = true
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Log.error(error.message)
    }
    
    func didClickNativeAd(_ ad: MAAd) {
        print("didClickNativeAd(_ ad: MAAd)")
    }
}
