//
//  PrebidNativeAdController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit

class PrebidNativeAdController: NSObject, AdaptedController, PrebidConfigurableNativeAdRenderingController {
    
    var prebidConfigId = ""
    var nativeAdConfig = PBMNativeAdConfiguration?.none
    
    var autoPlayOnVisible: Bool {
        get {
            nativeAdViewBox!.autoPlayOnVisible
        }
        set {
            nativeAdViewBox!.autoPlayOnVisible = newValue
        }
    }
    
    var showOnlyMediaView: Bool {
        get {
            nativeAdViewBox!.showOnlyMediaView
        }
        set {
            nativeAdViewBox!.showOnlyMediaView = newValue
        }
    }
    
    private weak var rootController: AdapterViewController?
    
    private var nativeAdViewBox: NativeAdViewBoxProtocol?
    
    private var adUnit: PBMNativeAdUnit?
    private var theNativeAd: PBMNativeAd?
    
    private let fetchDemandSuccessButton = EventReportContainer()
    private let fetchDemandFailedButton = EventReportContainer()
    private let getNativeAdSuccessButton = EventReportContainer()
    private let getNativeAdFailedButton = EventReportContainer()
    private let nativeAdDidClickButton = EventReportContainer()
    
    private let mediaPlaybackStartedButton = EventReportContainer()
    private let mediaPlaybackFinishedButton = EventReportContainer()
    private let mediaPlaybackPausedButton = EventReportContainer()
    private let mediaPlaybackResumedButton = EventReportContainer()
    private let mediaPlaybackMutedButton = EventReportContainer()
    private let mediaPlaybackUnmutedButton = EventReportContainer()
    private let mediaLoadingFinishedButton = EventReportContainer()
    
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
    }
    
    func setupNativeAdView(_ nativeAdViewBox: NativeAdViewBoxProtocol) {
        
        self.nativeAdViewBox = nativeAdViewBox
        
        fillBannerArea(rootController: self.rootController!)
        setupActions(rootController: self.rootController!)
        
        setupMediaPlaybackTrackers(isVisible: false)
        
        self.nativeAdViewBox?.setUpDummyValues()
    }
    
    private func fillBannerArea(rootController: AdapterViewController) {
        guard let bannerView = rootController.bannerView else {
            return
        }
        nativeAdViewBox?.embedIntoView(bannerView)
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
    }
    
    private func showDummyValues() {
        nativeAdViewBox?.setUpDummyValues()
    }
    
    private func setupActions(rootController: AdapterViewController) {
        rootController.setupAction(fetchDemandSuccessButton, "fetchDemand success")
        rootController.setupAction(fetchDemandFailedButton, "fetchDemand failed")
        rootController.setupAction(getNativeAdSuccessButton, "getNativeAd success")
        rootController.setupAction(getNativeAdFailedButton, "getNativeAd failed")
        rootController.setupAction(nativeAdDidClickButton, "nativeAdDidLogClick called")
        for nextEntry in nativeAdDidLogEventButtons {
            rootController.setupAction(nextEntry.button, "nativeAdDidLogEvent(\(nextEntry.name)) called")
        }
        rootController.setupAction(nativeAdWillLeaveAppButton, "nativeAdWillLeaveApplication called")
        rootController.setupAction(nativeAdWillPresentModalButton, "nativeAdWillPresentModal called")
        rootController.setupAction(nativeAdDidDismissModalButton, "nativeAdDidDismissModal called")
        
        rootController.setupAction(mediaLoadingFinishedButton, "onMediaLoadingFinishedButton called")
        rootController.setupAction(mediaPlaybackStartedButton, "onMediaPlaybackStartedButton called")
        rootController.setupAction(mediaPlaybackFinishedButton, "onMediaPlaybackFinishedButton called")
        rootController.setupAction(mediaPlaybackPausedButton, "onMediaPlaybackPausedButton called")
        rootController.setupAction(mediaPlaybackResumedButton, "onMediaPlaybackResumedButton called")
        rootController.setupAction(mediaPlaybackMutedButton, "onMediaPlaybackMutedButton called")
        rootController.setupAction(mediaPlaybackUnmutedButton, "onMediaPlaybackUnmutedButton called")
    }
    
    private func setupMediaPlaybackTrackers(isVisible: Bool) {
        [
            mediaLoadingFinishedButton,
            mediaPlaybackStartedButton,
            mediaPlaybackFinishedButton,
            mediaPlaybackPausedButton,
            mediaPlaybackResumedButton,
            mediaPlaybackMutedButton,
            mediaPlaybackUnmutedButton,
        ].forEach { $0.container.isHidden = !isVisible}
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
            guard demandResponseInfo.fetchDemandResult == .ok else {
                self.fetchDemandFailedButton.isEnabled = true
                return
            }
            self.fetchDemandSuccessButton.isEnabled = true
            demandResponseInfo.getNativeAd { [weak self] nativeAd in
                guard let self = self else {
                    return
                }
                guard let nativeAd = nativeAd else {
                    self.getNativeAdFailedButton.isEnabled = true
                    return
                }
                self.getNativeAdSuccessButton.isEnabled = true
                
                self.nativeAdViewBox?.renderNativeAd(nativeAd)
                self.nativeAdViewBox?.registerViews(nativeAd)
                self.theNativeAd = nativeAd // Note: RETAIN! or the tracking will not occur!
                nativeAd.trackingDelegate = self
                nativeAd.uiDelegate = self
                
                if let _ = nativeAd.videoAd?.mediaData {
                    self.nativeAdViewBox?.mediaViewDelegate = self
                    self.setupMediaPlaybackTrackers(isVisible: true)
                }
            }
        }
    }
}

extension PrebidNativeAdController: PBMNativeAdTrackingDelegate {
    func nativeAd(_ nativeAd: PBMNativeAd, didLogEvent nativeEvent: PBMNativeEventType) {
        nativeAdDidLogEventButtons.first{$0.event == nativeEvent}?.button.isEnabled = true
    }
    func nativeAdDidLogClick(_ nativeAd: PBMNativeAd) {
        nativeAdDidClickButton.isEnabled = true
    }
}

extension PrebidNativeAdController: PBMNativeAdUIDelegate {
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

extension PrebidNativeAdController: PBMMediaViewDelegate {
    func onMediaPlaybackStarted(_ mediaView: PBMMediaView) {
        mediaPlaybackStartedButton.isEnabled = true
    }
    func onMediaPlaybackFinished(_ mediaView: PBMMediaView) {
        mediaPlaybackFinishedButton.isEnabled = true
    }
    func onMediaPlaybackPaused(_ mediaView: PBMMediaView) {
        mediaPlaybackPausedButton.isEnabled = true
    }
    func onMediaPlaybackResumed(_ mediaView: PBMMediaView) {
        mediaPlaybackResumedButton.isEnabled = true
    }
    func onMediaPlaybackMuted(_ mediaView: PBMMediaView) {
        mediaPlaybackMutedButton.isEnabled = true
    }
    func onMediaPlaybackUnmuted(_ mediaView: PBMMediaView) {
        mediaPlaybackUnmutedButton.isEnabled = true
    }
    func onMediaLoadingFinished(_ mediaView: PBMMediaView) {
        mediaLoadingFinishedButton.isEnabled = true
    }
}
