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
import MoPubSDK

import PrebidMobile
import PrebidMobileMoPubAdapters

class PrebidMoPubNativeAdController: NSObject, AdaptedController {
    
    var prebidConfigId = ""
    var moPubAdUnitId = ""
    var adRenderingViewClass: AnyClass?
    
    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    private weak var rootController: AdapterViewController?
    
    private let nativeAdViewBox = NativeAdViewBox()
    
    private var adUnit: MediationNativeAdUnit?
    private var theMoPubNativeAd: MPNativeAd?
    private var thePrebidNativeAd: NativeAd?
    
    private var mediationDelegate: MoPubMediationNativeUtils?    
    
    private let fetchDemandSuccessButton = EventReportContainer()
    private let fetchDemandFailedButton = EventReportContainer()
    private let getNativeAdSuccessButton = EventReportContainer()
    private let getNativeAdFailedButton = EventReportContainer()
    private let nativeAdLoadedButton = EventReportContainer()
    private let primaryAdWinButton = EventReportContainer()
    private let nativeAdInvalidButton = EventReportContainer()
    private let nativeAdWillPresentModalButton = EventReportContainer()
    private let nativeAdDidDismissModalButton = EventReportContainer()
    private let nativeAdWillLeaveAppButton = EventReportContainer()
    private let nativeAdDidTrackImpressionButton = EventReportContainer()
    private let nativeAdDidExpireButton = EventReportContainer()
    private let nativeAdDidClickButton = EventReportContainer()
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        
        rootController.showButton.isHidden = true
        
        setUpBannerArea(rootController: rootController)
        setupActions(rootController: rootController)
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

    private func setupActions(rootController: AdapterViewController) {
        rootController.setupAction(fetchDemandSuccessButton, "fetchDemand success")
        rootController.setupAction(fetchDemandFailedButton, "fetchDemand failed")
        rootController.setupAction(getNativeAdSuccessButton, "getNativeAd success")
        rootController.setupAction(getNativeAdFailedButton, "getNativeAd failed")
        rootController.setupAction(nativeAdLoadedButton, "onNativeAdLoaded called")
        rootController.setupAction(primaryAdWinButton, "onPrimaryAdWin called")
        rootController.setupAction(nativeAdInvalidButton, "onNativeAdInvalid called")
        
        rootController.setupAction(nativeAdDidExpireButton, "nativeAdDidExpire called")
        rootController.setupAction(nativeAdDidClickButton, "nativeAdDidLogClick called")
        rootController.setupAction(nativeAdWillLeaveAppButton, "nativeAdWillLeaveApplication called")
        rootController.setupAction(nativeAdWillPresentModalButton, "nativeAdWillPresentModal failed")
        rootController.setupAction(nativeAdDidDismissModalButton, "nativeAdDidDismissModal called")
        rootController.setupAction(nativeAdDidTrackImpressionButton, "nativeAdDidTrackImpression called")
    }
        
    func loadAd() {
        let targeting = MPNativeAdRequestTargeting()
        mediationDelegate = MoPubMediationNativeUtils(targeting: targeting!)
        setupMediationNativeAdUnit(targeting: targeting!)
        adUnit?.fetchDemand(completion: { [weak self] result in
            guard let self = self else {
                return
            }
            
            if result != .prebidDemandFetchSuccess {
                self.fetchDemandFailedButton.isEnabled = true
            } else {
                self.fetchDemandSuccessButton.isEnabled = true
            }
            
            let settings = MPStaticNativeAdRendererSettings()
            settings.renderingViewClass = self.adRenderingViewClass
            let prebidConfig = PrebidMoPubNativeAdRenderer.rendererConfiguration(with: settings)
            let mopubConfig = MPStaticNativeAdRenderer.rendererConfiguration(with: settings)
            
            let adRequest = MPNativeAdRequest.init(adUnitIdentifier: self.moPubAdUnitId, rendererConfigurations: [prebidConfig!, mopubConfig!])
            adRequest?.targeting = targeting
            
            adRequest?.start(completionHandler: { [weak self] request, nativeAd, error in
                guard let self = self else {
                    return
                }
                
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.getNativeAdFailedButton.isEnabled = true
                    }
                    return
                }
                
                guard let moPubNativeAd = nativeAd else {
                    DispatchQueue.main.async {
                        self.getNativeAdFailedButton.isEnabled = true
                    }
                    return
                }
                
                switch MoPubMediationNativeUtils.getPrebidNative(from: moPubNativeAd) {
                case .success(let ad):
                    DispatchQueue.main.async {
                        self.setupPrebidNativeAd(ad)
                    }
                case .failure(let error):
                    PBMLog.error(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.setupMoPubNativeAd(moPubNativeAd)
                    }
                }
            })
        })
    }
    
    // MARK: - Helpers
    
    private func setupMediationNativeAdUnit(targeting: MPNativeAdRequestTargeting) {
        mediationDelegate = MoPubMediationNativeUtils(targeting: targeting)
        adUnit = MediationNativeAdUnit(configId: prebidConfigId, mediationDelegate: mediationDelegate!)
        adUnit!.setContextType(ContextType.Social)
        adUnit!.setPlacementType(PlacementType.FeedContent)
        adUnit!.setContextSubType(ContextSubType.Social)
         
        if let nativeAssets = nativeAssets {
            adUnit!.addNativeAssets(nativeAssets)
        }
        if let eventTrackers = eventTrackers {
            adUnit!.addEventTracker(eventTrackers)
        }
    }
    
    private func setupMoPubNativeAd(_ nativeAd: MPNativeAd) {
        self.primaryAdWinButton.isEnabled = true
        
        self.theMoPubNativeAd = nativeAd
        self.theMoPubNativeAd?.delegate = self
        
        guard let bannerView = rootController?.bannerView else {
            return
        }
        
        guard let adView = try? nativeAd.retrieveAdView(), let pbmAdView = adView.subviews.first else {
            return
        }
        
        adView.addConstraints([
            adView.widthAnchor.constraint(equalTo: pbmAdView.widthAnchor),
            adView.heightAnchor.constraint(equalTo: pbmAdView.heightAnchor),
        ])
        adView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(adView)
        bannerView.addConstraints([
            bannerView.widthAnchor.constraint(equalTo: adView.widthAnchor),
            bannerView.heightAnchor.constraint(equalTo: adView.heightAnchor),
        ])
    }
    
    private func setupPrebidNativeAd(_ nativeAd: NativeAd) {
        self.nativeAdLoadedButton.isEnabled = true
        self.thePrebidNativeAd = nativeAd
        
        guard let bannerView = rootController?.bannerView else {
            return
        }
        nativeAdViewBox.embedIntoView(bannerView)
        
        self.nativeAdViewBox.renderNativeAd(nativeAd)
        self.nativeAdViewBox.registerViews(nativeAd)
    }
}

extension PrebidMoPubNativeAdController: MPNativeAdDelegate {
    func viewControllerForPresentingModalView() -> UIViewController! {
        return rootController
    }
    
    func willPresentModal(for nativeAd: MPNativeAd!) {
        DispatchQueue.main.async {
            self.nativeAdWillPresentModalButton.isEnabled = true
        }
    }
    
    func didDismissModal(for nativeAd: MPNativeAd!) {
        DispatchQueue.main.async {
            self.nativeAdDidDismissModalButton.isEnabled = true
        }
    }
    
    func willLeaveApplication(from nativeAd: MPNativeAd!) {
        DispatchQueue.main.async {
            self.nativeAdWillLeaveAppButton.isEnabled = true
        }
    }
    
    func mopubAd(_ ad: MPMoPubAd, didTrackImpressionWith impressionData: MPImpressionData?) {
        DispatchQueue.main.async {
            self.nativeAdDidTrackImpressionButton.isEnabled = true
        }
    }
}
