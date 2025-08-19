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

fileprivate let assertionMessageMainThread = "Expected to only be called on the main thread"

/// The view that will display the particular banner ad. Built for rendering type of integration.
@objcMembers
public class BannerView:
    UIView,
    BannerEventInteractionDelegate,
    DisplayViewInteractionDelegate {
    
    /// The ad unit configuration.
    public let adUnitConfig: AdUnitConfig
    
    /// The event handler for banner view events.
    public let eventHandler: BannerEventHandler?
    
    // MARK: - Public Properties
    
    /// Banner-specific parameters.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    /// Video-specific parameters.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    /// The last bid response received.
    public var lastBidResponse: BidResponse? {
        adLoadFlowController?.bidResponse
    }
    
    /// ID of Stored Impression on the Prebid server
    public var configID: String {
        adUnitConfig.configId
    }
    
    /// The interval for refreshing the ad.
    public var refreshInterval: TimeInterval {
        get { adUnitConfig.refreshInterval }
        set { adUnitConfig.refreshInterval = newValue }
    }
    
    /// Additional sizes for the ad.
    public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    /// The ad format (e.g., banner, video).
    public var adFormat: AdFormat {
        get { adUnitConfig.adFormats.first ?? .banner }
        set { adUnitConfig.adFormats = [newValue] }
    }
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }

    /// ORTB configuration string.
    public weak var delegate: BannerViewDelegate?
    
    // MARK: Readonly storage
    
    var autoRefreshManager: AutoRefreshManager?
    var adLoadFlowController: AdLoadFlowController?
    
    // MARK: Externally observable
    var deployedView: UIView?
    var isRefreshStopped = false
    var isAdOpened = false
    
    // MARK: Computed helpers
    
    /// whether auto-refresh is allowed to occur now
    var mayRefreshNow: Bool {
        guard let controller = adLoadFlowController else {
            return false
        }
        
        if controller.hasFailedLoading {
            return  true
        }
        
        if isAdOpened || !isVisible() || isCreativeOpened {
            return false
        }
        
        return  true
    }
    
    var isCreativeOpened : Bool {
        if let displayView = deployedView as? DisplayView {
            return displayView.isCreativeOpened
        }
        
        return false
    }
    
    // MARK: - Public Methods
    
    /// Initializes a new `BannerView`.
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - configID: The configuration ID for the ad unit.
    ///   - adSize: The size of the ad.
    ///   - eventHandler: The event handler for the banner view.
    public init(
        frame: CGRect,
        configID: String,
        adSize: CGSize,
        eventHandler: BannerEventHandler
    ) {
        adUnitConfig = AdUnitConfig(configId: configID, size: adSize)
        adUnitConfig.adConfiguration.bannerParameters.api = PrebidConstants.supportedRenderingBannerAPISignals

        self.eventHandler = eventHandler
        super.init(frame: frame)
        accessibilityLabel = PrebidConstants.ACCESSIBILITY_BANNER_VIEW
        
        let bannerAdLoader = BannerAdLoader(delegate: self)
        
        adLoadFlowController = AdLoadFlowController(
            bidRequesterFactory: { [adUnitConfig] config in
                Factory.createBidRequester(
                    connection: PrebidServerConnection.shared,
                    sdkConfiguration: Prebid.shared,
                    targeting: Targeting.shared,
                    adUnitConfiguration: adUnitConfig
                )
            },
            adLoader: bannerAdLoader,
            adUnitConfig: adUnitConfig,
            delegate: self,
            configValidationBlock: { adUnitConfig, renderWithPrebid in
                true
            })
        
        autoRefreshManager = AutoRefreshManager(
            prefetchTime: PrebidConstants.AD_PREFETCH_TIME,
            lockingQueue: adLoadFlowController?.dispatchQueue,
            lockProvider: { [weak self] in
                self?.adLoadFlowController?.mutationLock
            },
            refreshDelayBlock: { [weak self] in
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
    
    /// Convenience initializer for creating a `BannerView` with a configuration ID and event handler.
    /// - Parameters:
    ///   - configID: The configuration ID for the ad unit.
    ///   - eventHandler: The event handler for the banner view.
    public convenience init(
        configID: String,
        eventHandler: BannerEventHandler
    ) {
        let size = eventHandler.adSizes.first ?? CGSize()
        let frame = CGRect(origin: CGPoint.zero, size: size)
        
        self.init(
            frame: frame,
            configID: configID,
            adSize: size,
            eventHandler: eventHandler
        )
        
        if eventHandler.adSizes.count > 1 {
            self.additionalSizes = Array(eventHandler.adSizes.suffix(from: 1))
        }
    }
    
    /// Convenience initializer for creating a `BannerView` with a frame, configuration ID, and ad size.
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - configID: The configuration ID for the ad unit.
    ///   - adSize: The size of the ad.
    public convenience init(
        frame: CGRect,
        configID: String,
        adSize: CGSize
    ) {
        self.init(
            frame: frame,
            configID: configID,
            adSize: adSize,
            eventHandler: BannerEventHandlerStandalone()
        )
    }
    
    deinit {
        Prebid.shared.storedAuctionResponse = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Loads the ad for the banner view.
    public func loadAd() {
        adLoadFlowController?.refresh()
    }
    
    /// Sets the stored auction response.
    /// - Parameter storedAuction: The stored auction response string.
    public func setStoredAuctionResponse(storedAuction:String){
        Prebid.shared.storedAuctionResponse = storedAuction
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbConfig: The  impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    @objc public func setImpORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    @objc public func getImpORTBConfig() -> String? {
        adUnitConfig.impORTBConfig
    }
    
    /// Sets the content OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbConfig: The content OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setContentORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.contentORTBConfig = ortbConfig
    }
    
    /// Returns the content OpenRTB configuration string.
    public func getContentORTBConfig() -> String? {
        adUnitConfig.contentORTBConfig
    }
    
    /// Stops the auto-refresh of the ad.
    public func stopRefresh() {
        adLoadFlowController?.enqueueGatedBlock { [weak self] in
            self?.isRefreshStopped = true
        }
    }
    
    // MARK: Custom Renderer
    
    /// Subscribe to plugin renderer events
    public func setPluginEventDelegate(_ pluginEventDelegate: PluginEventDelegate) {
        PrebidMobilePluginRegister.shared.registerEventDelegate(
            pluginEventDelegate,
            adUnitConfigFingerprint: adUnitConfig.fingerprint
        )
    }
    
    // MARK: - DisplayViewInteractionDelegate
    
    public func trackImpression(forDisplayView: UIView) {
        guard let eventHandler = self.eventHandler,
              eventHandler.responds(to: #selector(BannerEventHandler.trackImpression)) else {
                  return
              }
        
        eventHandler.trackImpression()
    }
    
    public func viewControllerForModalPresentation(
        fromDisplayView: UIView
    ) -> UIViewController? {
        return viewControllerForPresentingModal
    }
    
    public func didLeaveApp(from displayView: UIView) {
        willLeaveApp()
    }
    
    public func willPresentModal(from displayView: UIView) {
        willPresentModal()
    }
    
    public func didDismissModal(from displayView: UIView) {
        didDismissModal()
    }
    
    // MARK: - BannerEventInteractionDelegate
    
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
}

@_spi(PBMInternal)
extension BannerView : AdLoadFlowControllerDelegate, BannerAdLoaderDelegate {
    // MARK: - AdLoadFlowControllerDelegate
    
    public func adLoadFlowController(
        _ adLoadFlowController: AdLoadFlowController,
        failedWithError error: Error?
    ) {
        reportLoadingFailed(with: error)
    }
    
    public func adLoadFlowControllerWillSendBidRequest(_ adLoadFlowController: AdLoadFlowController) {
        isRefreshStopped = false
        autoRefreshManager?.cancelRefreshTimer()
    }
    
    public func adLoadFlowControllerWillRequestPrimaryAd(_ adLoadFlowController: AdLoadFlowController) {
        autoRefreshManager?.setupRefreshTimer()
        eventHandler?.interactionDelegate = self
    }
    
    public func adLoadFlowControllerShouldContinue(_ adLoadFlowController: AdLoadFlowController) -> Bool {
        !isRefreshStopped
    }
    
    // MARK: - BannerAdLoaderDelegate
    
    @_spi(PBMInternal)
    public func bannerAdLoader(
        _ bannerAdLoader: BannerAdLoader,
        loadedAdView adView: UIView,
        adSize: CGSize
    ) {
        deployView(adView)
        reportLoadingSuccess(with: adSize)
    }
}
