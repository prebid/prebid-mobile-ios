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

import UIKit
import PrebidMobile
import PrebidMobileAdMobAdapters
import GoogleMobileAds

class PrebidAdMobNativeViewController: NSObject, AdaptedController, GADNativeAdLoaderDelegate {
    
    public let accountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
    public var prebidConfigId = "25e17008-5081-4676-94d5-923ced4359d3"

    public var adMobAdUnitId: String?
    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    private weak var rootController: AdapterViewController?
    
    private var admobNativeAdView: AdMobNativeAdView?
    private var thePrebidNativeAd: NativeAd?
    private var adLoader: GADAdLoader?
    private var gadRequest = GADRequest()

    private var nativeAdUnit: MediationNativeAdUnit!
    private var mediationDelegate: AdMobMediationNativeUtils?
    
    private let adLoaderDidReceiveAdButton = EventReportContainer()
    private let adLoaderDidFailToReceiveAdWithErrorButton = EventReportContainer()
    private let adLoaderDidFinishLoadingButton = EventReportContainer()
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        setupActions(rootController: rootController)
    }
    
    func loadAd() {
        setUpBannerArea(rootController: rootController!) 
        setupMediationNativeAdUnit()
   
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                nativeAdUnit?.addContextData(key: dataPair.value, value: dataPair.key)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                nativeAdUnit?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            nativeAdUnit?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            nativeAdUnit?.addAppContentData([ortbAppContentData])
        }
        
        nativeAdUnit.fetchDemand { [weak self] result in
            guard let self = self else { return }
            
            self.adLoader = GADAdLoader(adUnitID: self.adMobAdUnitId!,
                                        rootViewController: self.rootController,
                                        adTypes: [ .native ],
                                        options: nil)
            self.adLoader?.delegate = self
            
            self.adLoader?.load(self.gadRequest)
        }
    }
        
    private func setupMediationNativeAdUnit() {
        mediationDelegate = AdMobMediationNativeUtils(gadRequest: gadRequest)
        nativeAdUnit = MediationNativeAdUnit(configId: prebidConfigId, mediationDelegate: mediationDelegate!)
        nativeAdUnit.setContextType(ContextType.Social)
        nativeAdUnit.setPlacementType(PlacementType.FeedContent)
        nativeAdUnit.setContextSubType(ContextSubType.Social)
         
        if let nativeAssets = nativeAssets {
            nativeAdUnit.addNativeAssets(nativeAssets)
        }
        if let eventTrackers = eventTrackers {
            nativeAdUnit.addEventTracker(eventTrackers)
        }
    }
    
    private func setUpBannerArea(rootController: AdapterViewController) {
        guard let bannerView = rootController.bannerView else {
            return
        }
        
        let bannerConstraints = bannerView.constraints
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
        if let bannerParent = bannerView.superview {
            let bannerHeightConstraint = bannerView.heightAnchor.constraint(equalToConstant: 200)
            bannerHeightConstraint.priority = .defaultLow
            let bannerWidthConstraint = NSLayoutConstraint(item: bannerView,
                                                       attribute: .width,
                                                       relatedBy: .lessThanOrEqual,
                                                       toItem: bannerParent,
                                                       attribute: .width,
                                                       multiplier: 1,
                                                       constant: -10)
            NSLayoutConstraint.activate([bannerWidthConstraint, bannerHeightConstraint])
        }
    }
    
    private func createNativeAdMobView(nativeAd: GADNativeAd) {
        guard let bannerView = rootController?.bannerView else {
            return
        }
        
        rootController?.showButton.isHidden = true
        bannerView.backgroundColor = .clear
        admobNativeAdView = AdMobNativeAdView.instanceFromNib()
        admobNativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(admobNativeAdView!)
        bannerView.heightAnchor.constraint(equalTo: admobNativeAdView!.heightAnchor).isActive = true
        bannerView.topAnchor.constraint(equalTo: admobNativeAdView!.topAnchor).isActive = true
        bannerView.leftAnchor.constraint(equalTo: admobNativeAdView!.leftAnchor).isActive = true
        bannerView.rightAnchor.constraint(equalTo: admobNativeAdView!.rightAnchor).isActive = true
    }
    
    private func renderNativeAd(ad: GADNativeAd) {
        guard let admobNativeAdView = admobNativeAdView else { return }
        admobNativeAdView.admobNativeAd = ad
        admobNativeAdView.titleLabel.text = ad.headline
        admobNativeAdView.bodyLabel.text = ad.body
        admobNativeAdView.callToActionButton.setTitle(ad.callToAction, for: .normal)
        admobNativeAdView.sponsoredLabel.text = ad.advertiser
        
        if let adIcon = ad.icon {
            self.admobNativeAdView?.iconImageView.image = adIcon.image
        }

//        if let adImage = ad.images?.first {
//            self.admobNativeAdView?.mainImageView.image = adImage.image
//        }
    }
    
    private func setupActions(rootController: AdapterViewController) {
        rootController.setupAction(adLoaderDidReceiveAdButton, "adLoaderDidReceiveAdButton called")
        rootController.setupAction(adLoaderDidFailToReceiveAdWithErrorButton, "adLoaderDidFailToReceiveAdWithErrorButton called")
        rootController.setupAction(adLoaderDidFinishLoadingButton, "adLoaderDidFinishLoadingButton called")
    }
    
    // MARK: - GADNativeAdLoaderDelegate
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        createNativeAdMobView(nativeAd: nativeAd)
        renderNativeAd(ad: nativeAd)
        adLoaderDidReceiveAdButton.isEnabled = true
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        admobNativeAdView = nil
        Log.error(error.localizedDescription)
        adLoaderDidFailToReceiveAdWithErrorButton.isEnabled = true
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        Log.info("GAD ad loader did finished loading.")
        adLoaderDidFinishLoadingButton.isEnabled = true
    }
}
