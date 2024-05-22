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
import GoogleMobileAds
import PrebidMobile
import PrebidMobileGAMEventHandlers

class PrebidGAMNativeAdController: NSObject, AdaptedController {
    
    public var prebidConfigId = ""

    public var gamAdUnitId = ""
    public var gamCustomTemplateIDs: [String] = []
    public var adTypes: [GADAdLoaderAdType] = []
    
    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    private weak var rootController: AdapterViewController?
    
    private let nativeAdViewBox = NativeAdViewBox()
    
    /// The native ad view that is being presented.
    private var nativeAdView: GADNativeAdView?
    
    private var adUnit: NativeRequest?
    private var theNativeAd: NativeAd?
    
    private var adLoader: GADAdLoader?
    
    private var customTemplateAd: GADCustomNativeAd?
    
    private let fetchDemandSuccessButton = EventReportContainer()
    private let fetchDemandFailedButton = EventReportContainer()
    private let customAdRequestSuccessful = EventReportContainer()
    private let unifiedAdRequestSuccessful = EventReportContainer()
    private let primaryAdRequestFailed = EventReportContainer()
    private let nativeAdLoadedButton = EventReportContainer()
    private let customAdWinButton = EventReportContainer()
    private let unifiedAdWinButton = EventReportContainer()
    private let nativeAdInvalidButton = EventReportContainer()
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        
        rootController.showButton.isHidden = true
        
        fillBannerArea(rootController: rootController)
        setupActions(rootController: rootController)
        
        nativeAdViewBox.setUpDummyValues()
    }
    
    private func fillBannerArea(rootController: AdapterViewController) {
        guard let bannerView = rootController.bannerView else {
            return
        }
        nativeAdViewBox.embedIntoView(bannerView)
        let bannerConstraints = bannerView.constraints
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
        if let bannerParent = bannerView.superview {
            bannerParent.addConstraints([
                NSLayoutConstraint(item: bannerView,
                                   attribute: .width,
                                   relatedBy: .lessThanOrEqual,
                                   toItem: bannerParent,
                                   attribute: .width,
                                   multiplier: 1,
                                   constant: -10),
            ])
        }
        nativeAdViewBox.ctaButton.addTarget(self, action: #selector(ctaClicked(sender:)), for: .touchUpInside)
    }
    
    private func setupActions(rootController: AdapterViewController) {
        rootController.setupAction(fetchDemandSuccessButton, "fetchDemand success")
        rootController.setupAction(fetchDemandFailedButton, "fetchDemand failed")
        rootController.setupAction(customAdRequestSuccessful, "custom ad request successful")
        rootController.setupAction(unifiedAdRequestSuccessful, "unified ad request successful")
        rootController.setupAction(primaryAdRequestFailed, "primary ad request failed")
        rootController.setupAction(nativeAdLoadedButton, "onNativeAdLoaded called")
        rootController.setupAction(customAdWinButton, "onPrimaryAdWin called (custom)")
        rootController.setupAction(unifiedAdWinButton, "onPrimaryAdWin called (unified)")
        rootController.setupAction(nativeAdInvalidButton, "onNativeAdInvalid called")
    }
    
    func loadAd() {
        setupNativeAdUnit()
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(key: dataPair.value, value: dataPair.key)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                adUnit?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            adUnit?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            adUnit?.addAppContentData([ortbAppContentData])
        }
        
        adUnit?.fetchDemand(completion: { [weak self] result, kvResultDict in
            guard let self = self else {
                return
            }
            
            if result == .prebidDemandFetchSuccess {
                self.fetchDemandSuccessButton.isEnabled = true
            } else {
                self.fetchDemandFailedButton.isEnabled = true
            }
            
            let dfpRequest = GAMRequest()
            GAMUtils.shared.prepareRequest(dfpRequest, bidTargeting: kvResultDict ?? [:])
            
            print(">>> \(String(describing: dfpRequest.customTargeting))")
            
            self.adLoader = GADAdLoader(adUnitID: self.gamAdUnitId,
                                        rootViewController: self.rootController,
                                        adTypes: self.adTypes,
                                        options: [])
            self.adLoader?.delegate = self
            self.adLoader?.load(dfpRequest)
        })
    }
    
    // MARK: - Helpers
    
    private func setupNativeAdUnit() {
        adUnit = NativeRequest(configId: prebidConfigId, assets: nativeAssets ?? [], eventTrackers: eventTrackers ?? [])
        adUnit?.context = ContextType.Social
        adUnit?.placementType = PlacementType.FeedContent
        adUnit?.contextSubType = ContextSubType.Social
    }
}

extension PrebidGAMNativeAdController: GADCustomNativeAdLoaderDelegate {
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return gamCustomTemplateIDs
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADCustomNativeAd) {
        customAdRequestSuccessful.isEnabled = true
        customTemplateAd = nil
        
        let result = GAMUtils.shared.findCustomNativeAd(for: nativeCustomTemplateAd)
        
        switch result {
        case .success(let nativeAd):
            self.nativeAdLoadedButton.isEnabled = true
            self.nativeAdViewBox.renderNativeAd(nativeAd)
            self.nativeAdViewBox.registerViews(nativeAd)
            self.theNativeAd = nativeAd // Note: RETAIN! or the tracking will not occur!
 
            self.customTemplateAd = nativeCustomTemplateAd
            nativeCustomTemplateAd.customClickHandler = { assetID in }
            nativeCustomTemplateAd.recordImpression()
        case .failure(let error):
            if error == GAMEventHandlerError.nonPrebidAd {
                self.customAdWinButton.isEnabled = true
                self.nativeAdViewBox.renderCustomTemplateAd(nativeCustomTemplateAd)
                self.customTemplateAd = nativeCustomTemplateAd
                nativeCustomTemplateAd.recordImpression()
            } else {
                self.nativeAdInvalidButton.isEnabled = true
            }
        }
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // nop
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        primaryAdRequestFailed.isEnabled = true
    }
    
    @objc private func ctaClicked(sender: UIButton) {
        customTemplateAd?.performClickOnAsset(withKey: "cta")
    }
}

extension PrebidGAMNativeAdController: GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        unifiedAdRequestSuccessful.isEnabled = true
        customTemplateAd = nil
    
        let result = GAMUtils.shared.findNativeAd(for: nativeAd)
        
        switch result {
        case .success(let prebidNativeAd):
            self.nativeAdLoadedButton.isEnabled = true
            self.nativeAdViewBox.renderNativeAd(prebidNativeAd)
            self.nativeAdViewBox.registerViews(prebidNativeAd)
            self.theNativeAd = prebidNativeAd // Note: RETAIN! or the tracking will not occur!
            
        case .failure(let error):
            if error == GAMEventHandlerError.nonPrebidAd {
                self.unifiedAdWinButton.isEnabled = true
                
                self.nativeAdView?.removeFromSuperview()
                
                guard
                    let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
                    let adView = nibObjects.first as? UnifiedNativeAdView
                else {
                    assert(false, "Could not load nib file for adView")
                    return
                }
                
                self.setAdView(adView)
                
                adView.renderUnifiedNativeAd(nativeAd)
            } else {
                nativeAdInvalidButton.isEnabled = true
            }
        }
    }
    
    private func setAdView(_ view: GADNativeAdView) {
        // Remove the previous ad view.
        nativeAdView = view
        rootController?.bannerView.addSubview(view)
        nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view to stretch the entire width and height
        // of the nativeAdPlaceholder.
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        rootController?.bannerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        rootController?.bannerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
}
