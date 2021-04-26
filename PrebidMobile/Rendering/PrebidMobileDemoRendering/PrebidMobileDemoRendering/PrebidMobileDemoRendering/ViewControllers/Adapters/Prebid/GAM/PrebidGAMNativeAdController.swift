//
//  PrebidGAMNativeAdController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PrebidMobileGAMEventHandlers

class PrebidGAMNativeAdController: NSObject, AdaptedController, PrebidConfigurableNativeAdCompatibleController {
    var prebidConfigId = ""
    var gamAdUnitId = ""
    var gamCustomTemplateIDs: [String] = []
    var adTypes: [GADAdLoaderAdType] = []
    var nativeAdConfig = PBMNativeAdConfiguration?.none
    
    
    private weak var rootController: AdapterViewController?
    
    private let nativeAdViewBox = NativeAdViewBox()
    
    /// The native ad view that is being presented.
    private var nativeAdView: GADUnifiedNativeAdView?
    
    private var adUnit: PBMNativeAdUnit?
    private var theNativeAd: PBMNativeAd?
    
    private var adLoader: GADAdLoader?
    
    private var customTemplateAd: GADNativeCustomTemplateAd?
    
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
    
    private let nativeAdDidLogEventButtons: [(event: PBMNativeEventType, name: String, button: EventReportContainer)] = [
        (.impression, "impression", .init()),
        (.MRC50, "MRC50", .init()),
        (.MRC100, "MRC100", .init()),
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
        adUnit = PBMNativeAdUnit(configID: prebidConfigId, nativeAdConfiguration: nativeAdConfig)
        
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
            
            let dfpRequest = DFPRequest()
            PBMGAMUtils.shared().prepare(dfpRequest, demandResponseInfo: demandResponseInfo)
            self.adLoader = GADAdLoader(adUnitID: self.gamAdUnitId,
                                        rootViewController: self.rootController,
                                        adTypes: self.adTypes,
                                        options: [])
            self.adLoader?.delegate = self
            self.adLoader?.load(dfpRequest)
        }
    }
}

extension PrebidGAMNativeAdController: PBMNativeAdTrackingDelegate {
    func nativeAd(_ nativeAd: PBMNativeAd, didLogEvent nativeEvent: PBMNativeEventType) {
        nativeAdDidLogEventButtons.first{$0.event == nativeEvent}?.button.isEnabled = true
    }
    func nativeAdDidLogClick(_ nativeAd: PBMNativeAd) {
        nativeAdDidClickButton.isEnabled = true
    }
}

extension PrebidGAMNativeAdController: PBMNativeAdUIDelegate {
    func viewPresentationController(for nativeAd: PBMNativeAd) -> UIViewController? {
        return rootController
    }
    func nativeAdWillLeaveApplication(_ nativeAd: PBMNativeAd) {
        nativeAdWillLeaveAppButton.isEnabled = true
    }
    func nativeAdWillPresentModal(_ nativeAd: PBMNativeAd) {
        nativeAdWillPresentModalButton.isEnabled = true
    }
    func nativeAdDidDismissModal(_ nativeAd: PBMNativeAd) {
        nativeAdDidDismissModalButton.isEnabled = true
    }
}

extension PrebidGAMNativeAdController: GADNativeCustomTemplateAdLoaderDelegate {
    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return gamCustomTemplateIDs
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
        customAdRequestSuccessful.isEnabled = true
        customTemplateAd = nil
        
        let nativeAdDetectionListener = PBMNativeAdDetectionListener { [weak self] nativeAd in
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

        PBMGAMUtils.shared().findNativeAd(in: nativeCustomTemplateAd,
                                          nativeAdDetectionListener: nativeAdDetectionListener)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // nop
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        primaryAdRequestFailed.isEnabled = true
    }
    
    @objc private func ctaClicked(sender: UIButton) {
        customTemplateAd?.performClickOnAsset(withKey: "cta")
    }
}

extension PrebidGAMNativeAdController: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        unifiedAdRequestSuccessful.isEnabled = true
        customTemplateAd = nil
        
        let nativeAdDetectionListener = PBMNativeAdDetectionListener { [weak self] prebidNativeAd in
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

        PBMGAMUtils.shared().findNativeAd(in: nativeAd, nativeAdDetectionListener: nativeAdDetectionListener)
    }
    
    private func setAdView(_ view: GADUnifiedNativeAdView) {
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
