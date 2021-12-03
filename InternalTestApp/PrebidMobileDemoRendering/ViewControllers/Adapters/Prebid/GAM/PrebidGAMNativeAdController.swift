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

class PrebidGAMNativeAdController: NSObject, AdaptedController, PrebidConfigurableNativeAdCompatibleController {
    var prebidConfigId = ""
    var gamAdUnitId = ""
    var gamCustomTemplateIDs: [String] = []
    var adTypes: [GADAdLoaderAdType] = []
    var nativeAdConfig = NativeAdConfiguration?.none
    
    
    private weak var rootController: AdapterViewController?
    
    private let nativeAdViewBox = NativeAdViewBox()
    
    /// The native ad view that is being presented.
    private var nativeAdView: GADNativeAdView?
    
    private var adUnit: NativeAdUnit?
    private var theNativeAd: PBRNativeAd?
    
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
    private let nativeAdDidClickButton = EventReportContainer()
    
    private let nativeAdDidLogEventButtons: [(event: NativeEventType, name: String, button: EventReportContainer)] = [
        (.impression, "impression", .init()),
        (.mrc50, "MRC50", .init()),
        (.mrc100, "MRC100", .init()),
        (.video50, "video50", .init()),
    ]
    private let nativeAdWillPresentModalButton = EventReportContainer()
    private let nativeAdDidDismissModalButton = EventReportContainer()
    private let nativeAdWillLeaveAppButton = EventReportContainer()
    
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
        rootController.setupAction(nativeAdDidClickButton, "nativeAdDidLogClick called")
        for nextEntry in nativeAdDidLogEventButtons {
            rootController.setupAction(nextEntry.button, "nativeAdDidLogEvent(\(nextEntry.name)) called")
        }
        rootController.setupAction(nativeAdWillLeaveAppButton, "nativeAdWillLeaveApplication called")
        rootController.setupAction(nativeAdWillPresentModalButton, "nativeAdWillPresentModal called")
        rootController.setupAction(nativeAdDidDismissModalButton, "nativeAdDidDismissModal called")
    }
    
    func configurationController() -> BaseConfigurationController? {
        return PrebidNativeAdRenderingConfigurationController(controller: self)
    }
    
    func loadAd() {
        guard let nativeAdConfig = nativeAdConfig else {
            return
        }
        adUnit = NativeAdUnit(configID: prebidConfigId, nativeAdConfiguration: nativeAdConfig)
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        adUnit?.fetchDemand { [weak self] demandResponseInfo in
            guard let self = self else {
                return
            }
            if demandResponseInfo.fetchDemandResult == .ok {
                self.fetchDemandSuccessButton.isEnabled = true
            } else {
                self.fetchDemandFailedButton.isEnabled = true
            }
            
            let dfpRequest = GAMRequest()
            GAMUtils.shared.prepareRequest(dfpRequest, demandResponseInfo: demandResponseInfo)
            
            print(">>> \(String(describing: dfpRequest.customTargeting))")
            
            self.adLoader = GADAdLoader(adUnitID: self.gamAdUnitId,
                                        rootViewController: self.rootController,
                                        adTypes: self.adTypes,
                                        options: [])
            self.adLoader?.delegate = self
            self.adLoader?.load(dfpRequest)
        }
    }
}

extension PrebidGAMNativeAdController: NativeAdTrackingDelegate {
    func nativeAd(_ nativeAd: PBRNativeAd, didLogEvent nativeEvent: NativeEventType) {
        nativeAdDidLogEventButtons.first{$0.event == nativeEvent}?.button.isEnabled = true
    }
    func nativeAdDidLogClick(_ nativeAd: PBRNativeAd) {
        nativeAdDidClickButton.isEnabled = true
    }
}

extension PrebidGAMNativeAdController: NativeAdUIDelegate {
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

extension PrebidGAMNativeAdController: GADCustomNativeAdLoaderDelegate {
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return gamCustomTemplateIDs

    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADCustomNativeAd) {
        customAdRequestSuccessful.isEnabled = true
        customTemplateAd = nil
        
        let nativeAdDetectionListener = NativeAdDetectionListener { [weak self] nativeAd in
            guard let self = self else {
                return
            }
            self.nativeAdLoadedButton.isEnabled = true
            self.nativeAdViewBox.renderNativeAd(nativeAd)
            self.nativeAdViewBox.registerViews(nativeAd)
            self.theNativeAd = nativeAd // Note: RETAIN! or the tracking will not occur!
            nativeAd.trackingDelegate = self
            nativeAd.uiDelegate = self
            self.customTemplateAd = nativeCustomTemplateAd
            nativeCustomTemplateAd.customClickHandler = { assetID in }
            nativeCustomTemplateAd.recordImpression()
        } onPrimaryAdWin: { [weak self] in
            guard let self = self else {
                return
            }
            self.customAdWinButton.isEnabled = true
            self.nativeAdViewBox.renderCustomTemplateAd(nativeCustomTemplateAd)
            self.customTemplateAd = nativeCustomTemplateAd
            nativeCustomTemplateAd.recordImpression()
        } onNativeAdInvalid: { [weak self] error in
            self?.nativeAdInvalidButton.isEnabled = true
        }
        
        GAMUtils.shared.findCustomNativeAd(for: nativeCustomTemplateAd,
                                           nativeAdDetectionListener: nativeAdDetectionListener)
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
        
        let nativeAdDetectionListener = NativeAdDetectionListener { [weak self] prebidNativeAd in
            guard let self = self else {
                return
            }
            self.nativeAdLoadedButton.isEnabled = true
            self.nativeAdViewBox.renderNativeAd(prebidNativeAd)
            self.nativeAdViewBox.registerViews(prebidNativeAd)
            self.theNativeAd = prebidNativeAd // Note: RETAIN! or the tracking will not occur!
            prebidNativeAd.trackingDelegate = self
            prebidNativeAd.uiDelegate = self
            
            // TODO: Implement(?)
            // self.customTemplateAd = nativeCustomTemplateAd
            // nativeCustomTemplateAd.customClickHandler = { assetID in }
            // nativeCustomTemplateAd.recordImpression()
        } onPrimaryAdWin: { [weak self] in
            guard let self = self else {
                return
            }
            self.unifiedAdWinButton.isEnabled = true
            
            self.nativeAdView?.removeFromSuperview()
            
            guard
                let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
                let adView = nibObjects.first as? UnifiedNativeAdView
            else {
                assert(false, "Could not load nib file for adView")
            }
            
            self.setAdView(adView)
            
            adView.renderUnifiedNativeAd(nativeAd)
        } onNativeAdInvalid: { [weak self] error in
            self?.nativeAdInvalidButton.isEnabled = true
        }

        GAMUtils.shared.findNativeAd(for: nativeAd,
                                     nativeAdDetectionListener: nativeAdDetectionListener)
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
