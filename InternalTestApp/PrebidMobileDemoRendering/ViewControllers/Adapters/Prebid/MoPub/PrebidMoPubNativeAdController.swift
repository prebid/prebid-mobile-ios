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

class PrebidMoPubNativeAdController: NSObject, AdaptedController, PrebidConfigurableNativeAdCompatibleController {
    
    var prebidConfigId = ""
    var moPubAdUnitId = ""
    var nativeAdConfig = NativeAdConfiguration?.none
    var adRenderingViewClass: AnyClass?
    
    private weak var rootController: AdapterViewController?
    
    private let nativeAdViewBox = NativeAdViewBox()
    
    private var adUnit: MoPubNativeAdUnit?
    private var theMoPubNativeAd: MPNativeAd?
    private var thePrebidNativeAd: PBRNativeAd?
    
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
    private let nativeAdDidLogEventButtons: [(event: NativeEventType, name: String, button: EventReportContainer)] = [
        (.impression, "impression", .init()),
        (.mrc50, "MRC50", .init()),
        (.mrc100, "MRC100", .init()),
        (.video50, "video50", .init()),
    ]
    
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
        for nextEntry in nativeAdDidLogEventButtons {
            rootController.setupAction(nextEntry.button, "nativeAdDidLogEvent(\(nextEntry.name)) called")
        }
        rootController.setupAction(nativeAdWillLeaveAppButton, "nativeAdWillLeaveApplication called")
        rootController.setupAction(nativeAdWillPresentModalButton, "nativeAdWillPresentModal failed")
        rootController.setupAction(nativeAdDidDismissModalButton, "nativeAdDidDismissModal called")
        rootController.setupAction(nativeAdDidTrackImpressionButton, "nativeAdDidTrackImpression called")
    }
    
    func configurationController() -> BaseConfigurationController? {
        return PrebidNativeAdCompatibleConfigurationController(controller: self)
    }
    
    func loadAd() {
        guard let nativeAdConfig = nativeAdConfig, let adRenderingViewClass = adRenderingViewClass else {
            return
        }
        
        adUnit = MoPubNativeAdUnit(configID: prebidConfigId, nativeAdConfiguration: nativeAdConfig)
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        let targeting = MPNativeAdRequestTargeting()
        
        adUnit?.fetchDemand(with: targeting!) { [weak self] result in
            guard let self = self else {
                return
            }
            
            if result != .ok {
                self.fetchDemandFailedButton.isEnabled = true
            } else {
                self.fetchDemandSuccessButton.isEnabled = true
            }
            
            let settings = MPStaticNativeAdRendererSettings();
            settings.renderingViewClass = adRenderingViewClass
            let prebidConfig = PrebidMoPubNativeAdRenderer.rendererConfiguration(with: settings);
            let mopubConfig = MPStaticNativeAdRenderer.rendererConfiguration(with: settings);
            
            
            PrebidMoPubAdaptersUtils.shared.prepareAdObject(targeting!)
            
            let adRequest = MPNativeAdRequest.init(adUnitIdentifier: self.moPubAdUnitId, rendererConfigurations: [prebidConfig, mopubConfig!])
            adRequest?.targeting = targeting
            
            adRequest?.start { [weak self] request, response , error in
                guard let self = self else {
                    return
                }
                
                guard error == nil else {
                    self.getNativeAdFailedButton.isEnabled = true
                    return
                }
                
                guard let moPubNativeAd = response else {
                    self.getNativeAdFailedButton.isEnabled = true
                    return
                }
                
                self.getNativeAdSuccessButton.isEnabled = true
                
                let nativeAdDetectionListener = NativeAdDetectionListener { [weak self] nativeAd in
                    guard let self = self else {
                        return
                    }
                    self.setupPrebidNativeAd(nativeAd)
                } onPrimaryAdWin: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.setupMoPubNativeAd(moPubNativeAd)
                } onNativeAdInvalid: { [weak self] error in
                    self?.nativeAdInvalidButton.isEnabled = true
                }
                
                PrebidMoPubAdaptersUtils.shared.find(nativeAd: moPubNativeAd,
                                       nativeAdDetectionListener: nativeAdDetectionListener)
            }
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
        
        if let videoAdView = pbmAdView as? MoPubNativeVideoAdView {
            videoAdView.setupMediaControls()
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
    
    private func setupPrebidNativeAd(_ nativeAd: PBRNativeAd) {
        self.nativeAdLoadedButton.isEnabled = true
        self.thePrebidNativeAd = nativeAd
        
        guard let bannerView = rootController?.bannerView else {
            return
        }
        nativeAdViewBox.embedIntoView(bannerView)
        
        self.nativeAdViewBox.renderNativeAd(nativeAd)
        self.nativeAdViewBox.registerViews(nativeAd)
        nativeAd.trackingDelegate = self
        nativeAd.uiDelegate = self
    }
}

extension PrebidMoPubNativeAdController: MPNativeAdDelegate {
    func viewControllerForPresentingModalView() -> UIViewController! {
        return rootController
    }
    
    func willPresentModal(for nativeAd: MPNativeAd!) {
        nativeAdWillPresentModalButton.isEnabled = true
    }
    
    func didDismissModal(for nativeAd: MPNativeAd!) {
        nativeAdDidDismissModalButton.isEnabled = true
    }
    
    func willLeaveApplication(from nativeAd: MPNativeAd!) {
        nativeAdWillLeaveAppButton.isEnabled = true
    }
    
    func mopubAd(_ ad: MPMoPubAd, didTrackImpressionWith impressionData: MPImpressionData?) {
        nativeAdDidTrackImpressionButton.isEnabled = true
    }
}

extension PrebidMoPubNativeAdController: NativeAdTrackingDelegate {
    func nativeAd(_ nativeAd: PBRNativeAd, didLogEvent nativeEvent: NativeEventType) {
        nativeAdDidLogEventButtons.first{$0.event == nativeEvent}?.button.isEnabled = true
    }
    func nativeAdDidLogClick(_ nativeAd: PBRNativeAd) {
        nativeAdDidClickButton.isEnabled = true
    }
    func nativeAdDidExpire(_ nativeAd: PBRNativeAd) {
        nativeAdDidExpireButton.isEnabled = true
    }
}

extension PrebidMoPubNativeAdController: NativeAdUIDelegate {
    func viewPresentationControllerForNativeAd(_ nativeAd: PBRNativeAd) -> UIViewController? {
        return rootController
    }
    func nativeAdWillLeaveApplication(_ nativeAd: PBRNativeAd) {
        nativeAdWillLeaveAppButton.isEnabled = true
    }
    func nativeAdWillPresentModal(_ nativeAd: PBRNativeAd) {
        nativeAdWillPresentModalButton.isEnabled = true
    }
    func nativeAdDidDismissModal(_ nativeAd: PBRNativeAd) {
        nativeAdDidDismissModalButton.isEnabled = true
    }
}

