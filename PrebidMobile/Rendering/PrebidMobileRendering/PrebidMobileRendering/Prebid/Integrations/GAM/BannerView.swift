//
//  BannerView.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import UIKit

fileprivate let assertionMessageMainThread = "Expected to only be called on the main thread"

public class BannerView: UIView,
                  PBMBannerAdLoaderDelegate,
                  PBMAdLoadFlowControllerDelegate,
                  PBMBannerEventInteractionDelegate,
                  PBMDisplayViewInteractionDelegate {

    public let adUnitConfig: AdUnitConfig
    public let eventHandler: PBMBannerEventHandler?
    
    // MARK: - Public Properties
    
    @objc public var configID: String {
        adUnitConfig.configID
    }

    @objc public var refreshInterval: TimeInterval {
        get { adUnitConfig.refreshInterval }
        set { adUnitConfig.refreshInterval = newValue }
    }
    
    @objc public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    @objc public var adFormat: PBMAdFormat {
        get { adUnitConfig.adFormat }
        set { adUnitConfig.adFormat = newValue }
    }
    
    @objc public var adPosition: PBMAdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    @objc public var videoPlacementType: PBMVideoPlacementType {
        get { adUnitConfig.videoPlacementType }
        set { adUnitConfig.videoPlacementType = newValue }
    }
    
    @objc public var nativeAdConfig: NativeAdConfiguration? {
        get { adUnitConfig.nativeAdConfiguration }
        set { adUnitConfig.nativeAdConfiguration = newValue }
    }

    @objc public weak var delegate: BannerViewDelegate?
    
    // MARK: Readonly storage
    
    var autoRefreshManager: PBMAutoRefreshManager?
    var adLoadFlowController: PBMAdLoadFlowController?

    // MARK: Externally observable
    var deployedView: UIView?
    var isRefreshStopped = false
    var isAdOpened = false

    // MARK: Computed helpers
    
    var mayRefreshNow: Bool {
        if let _ = adLoadFlowController?.hasFailedLoading {
            return  true
        }
        
        if isAdOpened || pbmIsVisible() || isCreativeOpened {
            return false
        }
        
        return  true
    } /// whether auto-refresh is allowed to occur now
   
    var isCreativeOpened : Bool {
        if let displayView = deployedView as? PBMDisplayView {
            return displayView.isCreativeOpened
        }
        
        return false
    }
    
    // MARK: - Public Methods
    
    @objc public init(frame: CGRect,
                configID: String,
                adSize: CGSize,
                eventHandler: PBMBannerEventHandler) {
        
        
        adUnitConfig = AdUnitConfig(configID: configID, size: adSize)
        self.eventHandler = eventHandler
        
        super.init(frame: frame)
        accessibilityLabel = PBMAccesibility.bannerView

        let bannerAdLoader = PBMBannerAdLoader(delegate: self)
        
        adLoadFlowController = PBMAdLoadFlowController(
            bidRequesterFactory: { [adUnitConfig] config in
                PBMBidRequester(connection: PBMServerConnection.singleton(),
                                sdkConfiguration: PrebidRenderingConfig.shared,
                                targeting: PrebidRenderingTargeting.shared,
                                adUnitConfiguration: adUnitConfig)
            },
            adLoader: bannerAdLoader,
            delegate: self,
            configValidationBlock: { adUnitConfig, renderWithPrebid in
                renderWithPrebid ?
                    BannerView.canPrebidDisplayAd(withConfiguration: adUnitConfig) :
                    BannerView.canEventHandler(eventHandler: eventHandler, displayAdWithConfiguration: adUnitConfig)
            })
        
        autoRefreshManager = PBMAutoRefreshManager(
            prefetchTime: PBMAdPrefetchTime,
            locking: adLoadFlowController?.dispatchQueue,
            lockProvider: { [weak self] in
                self?.adLoadFlowController?.mutationLock
            },
            refreshDelay: { [weak self] in
                if let interval = self?.adUnitConfig.refreshInterval {
                    return NSNumber(value: interval)
                }
                return NSNumber(value: 60)
            },
            mayRefreshNowBlock: { [weak self] in
                self?.mayRefreshNow ?? false
            },
            refreshBlock: { [weak self] in
                self?.adLoadFlowController?.refresh()
            })
    }
    
    @objc public convenience init(configID: String,
                            eventHandler: PBMBannerEventHandler) {
        let size = eventHandler.adSizes.first?.cgSizeValue ?? CGSize()
        let frame = CGRect(origin: CGPoint.zero, size: size)
        
        self.init(frame: frame,
                  configID: configID,
                  adSize: size,
                  eventHandler: eventHandler)
        
        if eventHandler.adSizes.count > 1 {
            self.additionalSizes = Array(eventHandler.adSizes.suffix(from: 1)
                                            .compactMap { $0.cgSizeValue })
        }
    }
    
    @objc public convenience init(frame: CGRect,
                            configID: String,
                            adSize: CGSize) {
        self.init(frame: frame,
                  configID: configID,
                  adSize: adSize,
                  eventHandler: PBMBannerEventHandlerStandalone())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func loadAd() {
        adLoadFlowController?.refresh()
    }
    
    @objc public func stopRefresh() {
        adLoadFlowController?.enqueueGatedBlock { [weak self] in
            self?.isRefreshStopped = true
        }
    }
    
    // MARK: - Context Data

    @objc public func addContextData(_ data: String, forKey key: String) {
        adUnitConfig.addContextData(data, forKey: key)
    }
    
    @objc public func updateContextData(_ data: Set<String>, forKey key: String) {
        adUnitConfig.updateContextData(data, forKey: key)
    }
    
    @objc public func removeContextDate(forKey key: String) {
        adUnitConfig.removeContextData(forKey: key)
    }
    
    @objc public func clearContextData() {
        adUnitConfig.clearContextData()
    }
    
    // MARK: - PBMDisplayViewInteractionDelegate
    
    public func trackImpression(for displayView: PBMDisplayView) {
        guard let eventHandler = self.eventHandler,
              eventHandler.responds(to: #selector(PBMBannerEventHandler.trackImpression)) else {
            return
        }
        
        eventHandler.trackImpression?()
    }
    
    public func viewControllerForModalPresentation(from displayView: PBMDisplayView) -> UIViewController? {
        return viewControllerForPresentingModal
    }
    
    public func didLeaveApp(from displayView: PBMDisplayView) {
        willLeaveApp()
    }
    
    public func displayViewWillPresentModal(_ displayView: PBMDisplayView) {
        willPresentModal()
    }
    
    public func displayViewDidDismissModal(_ displayView: PBMDisplayView) {
        didDismissModal()
    }
    
    // MARK: - PBMBannerAdLoaderDelegate
    
    public func bannerAdLoader(_ bannerAdLoader: PBMBannerAdLoader, loadedAdView adView: UIView, adSize: CGSize) {
        deployView(adView)
        reportLoadingSuccess(with: adSize)
    }
    
    public func bannerAdLoader(_ bannerAdLoader: PBMBannerAdLoader, createdDisplayView displayView: PBMDisplayView) {
        displayView.interactionDelegate = self
    }
    
    // MARK: - PBMAdLoadFlowControllerDelegate
    
    public func adLoadFlowController(_ adLoadFlowController: PBMAdLoadFlowController, failedWithError error: Error?) {
        reportLoadingFailed(with: error)
    }
    
    public func adLoadFlowControllerWillSendBidRequest(_ adLoadFlowController: PBMAdLoadFlowController) {
        isRefreshStopped = false
        autoRefreshManager?.cancelRefreshTimer()
    }
    
    public func adLoadFlowControllerWillRequestPrimaryAd(_ adLoadFlowController: PBMAdLoadFlowController) {
        autoRefreshManager?.setupRefreshTimer()
        eventHandler?.interactionDelegate = self
    }
    
    public func adLoadFlowControllerShouldContinue(_ adLoadFlowController: PBMAdLoadFlowController) -> Bool {
        !isRefreshStopped
    }
    
    // MARK: - PBMBannerEventInteractionDelegate
    
    public func willPresentModal() {
        assert(Thread.isMainThread, assertionMessageMainThread)
        isAdOpened = true
        
        invokeDelegateSelector(#selector(BannerViewDelegate.bannerViewWillPresentModal))
    }
    
    public func didDismissModal() {
        assert(Thread.isMainThread, assertionMessageMainThread)
        isAdOpened = false
        
        invokeDelegateSelector(#selector(BannerViewDelegate.bannerViewDidDismissModal))
    }
    
    public func willLeaveApp() {
        assert(Thread.isMainThread, assertionMessageMainThread)

        invokeDelegateSelector(#selector(BannerViewDelegate.bannerViewWillLeaveApplication))
    }
    
    public var viewControllerForPresentingModal: UIViewController? {
        guard let delegate = self.delegate,
              delegate.responds(to: #selector(BannerViewDelegate.bannerViewPresentationController)) else {
            return nil
        }
        
        return delegate.bannerViewPresentationController()
    }
    
    // MARK: - Private Methods
    
    private func invokeDelegateSelector(_ selector: Selector) {
        guard let delegate = self.delegate,
              delegate.responds(to: selector) else {
            return
        }
        
        delegate.perform(selector, with: self)
    }

    private func deployView(_ view: UIView) {
        guard deployedView !== view else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let oldDeployedView = self.deployedView {
                self.insertSubview(view, aboveSubview: oldDeployedView)
                oldDeployedView.removeFromSuperview()
            } else {
                self.addSubview(view)
            }
            
            self.installDeployedViewConstraints(view: view)
            self.deployedView = view
        }
    }
    
    private func reportLoadingSuccess(with size: CGSize) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let delegate = self.delegate,
                  delegate.responds(to: #selector(BannerViewDelegate.bannerView(_:didReceiveAdWithAdSize:))) else {
                return
            }
            
            delegate.bannerView?(self, didReceiveAdWithAdSize: size)
        }
    }
    
    private func reportLoadingFailed(with error: Error?) {
        DispatchQueue.main.async { [weak  self] in
            guard let self = self else { return }
            
            self.deployedView?.removeFromSuperview()
            self.deployedView = nil
            
            if let delegate = self.delegate,
               delegate.responds(to: #selector(BannerViewDelegate.bannerView(_:didFailToReceiveAdWith:))) {
                delegate.bannerView?(self, didFailToReceiveAdWith: error ?? PBMError.error(description: "Unknown Error"))
            }
        }
    }
    
    private func installDeployedViewConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
                        NSLayoutConstraint(item: self,
                                           attribute: .width,
                                           relatedBy: .equal,
                                           toItem: view,
                                           attribute: .width,
                                           multiplier: 1,
                                           constant: 0),
                        
                        NSLayoutConstraint(item: self,
                                           attribute: .height,
                                           relatedBy: .equal,
                                           toItem: view,
                                           attribute: .height,
                                           multiplier: 1, constant: 0)
        ])
    }


    // MARK: - Static Helpers

    private static func canEventHandler(eventHandler:PBMBannerEventHandler,
                                        displayAdWithConfiguration adUnitConfig: AdUnitConfig ) -> Bool {
        if adUnitConfig.adConfiguration.adFormat != .nativeInternal {
            return true;
        }
        
        if eventHandler.isCreativeRequiredForNativeAds {
            if let nativeStyleCreative = adUnitConfig.nativeAdConfiguration?.nativeStylesCreative {
                return !nativeStyleCreative.isEmpty
            } else {
                return false
            }
        }
        
        return true;
    }

    private static func canPrebidDisplayAd(withConfiguration adUnitConfig:AdUnitConfig) -> Bool {
        if adUnitConfig.adConfiguration.adFormat != .nativeInternal {
            return true;
        }
        
        if let nativeStyleCreative = adUnitConfig.nativeAdConfiguration?.nativeStylesCreative {
            return !nativeStyleCreative.isEmpty
        }
        
        return false
    }
}
