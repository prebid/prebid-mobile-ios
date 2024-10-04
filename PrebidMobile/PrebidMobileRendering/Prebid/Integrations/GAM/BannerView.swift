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
public class BannerView: UIView,
                         BannerAdLoaderDelegate,
                         AdLoadFlowControllerDelegate,
                         BannerEventInteractionDelegate,
                         DisplayViewInteractionDelegate {
    
    /// The ad unit configuration.
    public let adUnitConfig: AdUnitConfig
    
    /// The event handler for banner view events.
    public let eventHandler: BannerEventHandler?
    
    // MARK: - Public Properties
    
    /// Banner-specific parameters.
    @objc public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    /// Video-specific parameters.
    @objc public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    /// The last bid response received.
    @objc public var lastBidResponse: BidResponse? {
        adLoadFlowController?.bidResponse
    }
    
    /// ID of Stored Impression on the Prebid server
    @objc public var configID: String {
        adUnitConfig.configId
    }
    
    /// The interval for refreshing the ad.
    @objc public var refreshInterval: TimeInterval {
        get { adUnitConfig.refreshInterval }
        set { adUnitConfig.refreshInterval = newValue }
    }
    
    /// Additional sizes for the ad.
    @objc public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    /// The ad format (e.g., banner, video).
    @objc public var adFormat: AdFormat {
        get { adUnitConfig.adFormats.first ?? .banner }
        set { adUnitConfig.adFormats = [newValue] }
    }
    
    /// The position of the ad on the screen.
    @objc public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    @objc public var ortbConfig: String? {
        get { adUnitConfig.ortbConfig }
        set { adUnitConfig.ortbConfig = newValue }
    }

    /// ORTB configuration string.
    @objc public weak var delegate: BannerViewDelegate?
    
    /// Subscribe to plugin renderer events
    @objc public func setPluginEventDelegate(_ pluginEventDelegate: PluginEventDelegate) {
        PrebidMobilePluginRegister.shared.registerEventDelegate(pluginEventDelegate, adUnitConfigFingerprint: adUnitConfig.fingerprint)
    }
    
    // MARK: Readonly storage
    
    var autoRefreshManager: PBMAutoRefreshManager?
    var adLoadFlowController: PBMAdLoadFlowController?
    
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
        
        if isAdOpened || !pbmIsVisible() || isCreativeOpened {
            return false
        }
        
        return  true
    }
    
    var isCreativeOpened : Bool {
        if let displayView = deployedView as? PBMDisplayView {
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
    @objc public init(frame: CGRect,
                      configID: String,
                      adSize: CGSize,
                      eventHandler: BannerEventHandler) {
        
        adUnitConfig = AdUnitConfig(configId: configID, size: adSize)
        adUnitConfig.adConfiguration.bannerParameters.api = PrebidConstants.supportedRenderingBannerAPISignals

        self.eventHandler = eventHandler
        super.init(frame: frame)
        accessibilityLabel = PBMAccesibility.bannerView
        
        let bannerAdLoader = PBMBannerAdLoader(delegate: self)
        
        adLoadFlowController = PBMAdLoadFlowController(
            bidRequesterFactory: { [adUnitConfig] config in
                PBMBidRequester(connection: PrebidServerConnection.shared,
                                sdkConfiguration: Prebid.shared,
                                targeting: Targeting.shared,
                                adUnitConfiguration: adUnitConfig)
            },
            adLoader: bannerAdLoader,
            adUnitConfig: adUnitConfig,
            delegate: self,
            configValidationBlock: { adUnitConfig, renderWithPrebid in
                true
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
    
    /// Convenience initializer for creating a `BannerView` with a configuration ID and event handler.
    /// - Parameters:
    ///   - configID: The configuration ID for the ad unit.
    ///   - eventHandler: The event handler for the banner view.
    @objc public convenience init(configID: String,
                                  eventHandler: BannerEventHandler) {
        
        let size = eventHandler.adSizes.first ?? CGSize()
        let frame = CGRect(origin: CGPoint.zero, size: size)
        
        self.init(frame: frame,
                  configID: configID,
                  adSize: size,
                  eventHandler: eventHandler)
        
        if eventHandler.adSizes.count > 1 {
            self.additionalSizes = Array(eventHandler.adSizes.suffix(from: 1))
        }
    }
    
    /// Convenience initializer for creating a `BannerView` with a frame, configuration ID, and ad size.
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - configID: The configuration ID for the ad unit.
    ///   - adSize: The size of the ad.
    @objc public convenience init(frame: CGRect,
                                  configID: String,
                                  adSize: CGSize) {
        self.init(frame: frame,
                  configID: configID,
                  adSize: adSize,
                  eventHandler: BannerEventHandlerStandalone())
    }
    
    deinit {
        Prebid.shared.storedAuctionResponse = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Loads the ad for the banner view.
    @objc public func loadAd() {
        adLoadFlowController?.refresh()
    }
    
    /// Sets the stored auction response.
    /// - Parameter storedAuction: The stored auction response string.
    @objc public func setStoredAuctionResponse(storedAuction:String){
        Prebid.shared.storedAuctionResponse = storedAuction
    }
    
    /// Stops the auto-refresh of the ad.
    @objc public func stopRefresh() {
        adLoadFlowController?.enqueueGatedBlock { [weak self] in
            self?.isRefreshStopped = true
        }
    }
    
    // MARK: - Ext Data (imp[].ext.data)
    
    /// Adds context data for a specified key.
    /// - Parameters:
    ///   - data: The data to add.
    ///   - key: The key associated with the data.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    @objc public func addContextData(_ data: String, forKey key: String) {
        addExtData(key: key, value: data)
    }
    
    /// Updates context data for a specified key.
    /// - Parameters:
    ///   - data: A set of data to update.
    ///   - key: The key associated with the data.
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    @objc public func updateContextData(_ data: Set<String>, forKey key: String) {
        updateExtData(key: key, value: data)
    }
    
    /// Removes context data for a specified key.
    /// - Parameter key: The key associated with the data to remove.
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    @objc public func removeContextDate(forKey key: String) {
        removeExtData(forKey: key)
    }
    
    /// Clears all context data.
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    @objc public func clearContextData() {
        clearExtData()
    }
    
    /// Adds ext data.
    /// - Parameters:
    ///   - key: The key for the data.
    ///   - value: The value for the data.
    @objc public func addExtData(key: String, value: String) {
        adUnitConfig.addExtData(key: key, value: value)
    }
    
    /// Updates ext data.
    /// - Parameters:
    ///   - key: The key for the data.
    ///   - value: The value for the data.
    @objc public func updateExtData(key: String, value: Set<String>) {
        adUnitConfig.updateExtData(key: key, value: value)
    }
    
    /// Removes ext data.
    /// - Parameters:
    ///   - key: The key for the data.
    @objc public func removeExtData(forKey: String) {
        adUnitConfig.removeExtData(for: forKey)
    }
    
    /// Clears ext data.
    @objc public func clearExtData() {
        adUnitConfig.clearExtData()
    }
    
    // MARK: - Ext keywords (imp[].ext.keywords)
    
    /// Adds a context keyword.
    /// - Parameter newElement: The keyword to add.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeyword method instead.")
    @objc public func addContextKeyword(_ newElement: String) {
        addExtKeyword(newElement)
    }
    
    /// Adds a set of context keywords.
    /// - Parameter newElements: A set of keywords to add.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    @objc public func addContextKeywords(_ newElements: Set<String>) {
        addExtKeywords(newElements)
    }
    
    /// Removes a context keyword.
    /// - Parameter element: The keyword to remove.
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    @objc public func removeContextKeyword(_ element: String) {
        removeExtKeyword(element)
    }

    /// Clears all context keywords.
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    @objc public func clearContextKeywords() {
        clearExtKeywords()
    }
    
    /// Adds an extended keyword.
    /// - Parameter newElement: The keyword to be added.
    @objc public func addExtKeyword(_ newElement: String) {
        adUnitConfig.addExtKeyword(newElement)
    }
    
    /// Adds multiple extended keywords.
    /// - Parameter newElements: A set of keywords to be added.
    @objc public func addExtKeywords(_ newElements: Set<String>) {
        adUnitConfig.addExtKeywords(newElements)
    }
    
    /// Removes an extended keyword.
    /// - Parameter element: The keyword to be removed.
    @objc public func removeExtKeyword(_ element: String) {
        adUnitConfig.removeExtKeyword(element)
    }
    
    /// Clears all extended keywords.
    @objc public func clearExtKeywords() {
        adUnitConfig.clearExtKeywords()
    }
    
    // MARK: - App Content (app.content.data)
    
    /// Sets the app content data.
    /// - Parameter appContent: The app content data.
    @objc public func setAppContent(_ appContent: PBMORTBAppContent) {
        adUnitConfig.setAppContent(appContent)
    }
    
    /// Clears the app content data.
    @objc public func clearAppContent() {
        adUnitConfig.clearAppContent()
    }
    
    /// Adds app content data objects.
    /// - Parameter dataObjects: The data objects to be added.
    @objc public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        adUnitConfig.addAppContentData(dataObjects)
    }
    
    /// Removes an app content data object.
    /// - Parameter dataObject: The data object to be removed.
    @objc public func removeAppContentDataObject(_ dataObject: PBMORTBContentData) {
        adUnitConfig.removeAppContentData(dataObject)
    }
    
    /// Clears all app content data objects.
    @objc public func clearAppContentDataObjects() {
        adUnitConfig.clearAppContentData()
    }
    
    // MARK: - User Data (user.data)
        
    /// Adds user data objects.
    /// - Parameter userDataObjects: The user data objects to be added.
    @objc public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        adUnitConfig.addUserData(userDataObjects)
    }
    
    /// Removes a user data object.
    /// - Parameter userDataObject: The user data object to be removed.
    @objc public func removeUserData(_ userDataObject: PBMORTBContentData) {
        adUnitConfig.removeUserData(userDataObject)
    }
    
    /// Clears all user data objects.
    @objc public func clearUserData() {
        adUnitConfig.clearUserData()
    }
    
    
    // MARK: - DisplayViewInteractionDelegate
    
    public func trackImpression(forDisplayView: PBMDisplayView) {
        guard let eventHandler = self.eventHandler,
              eventHandler.responds(to: #selector(BannerEventHandler.trackImpression)) else {
                  return
              }
        
        eventHandler.trackImpression()
    }
    
    public func viewControllerForModalPresentation(fromDisplayView: PBMDisplayView) -> UIViewController? {
        return viewControllerForPresentingModal
    }
    
    public func didLeaveApp(from displayView: PBMDisplayView) {
        willLeaveApp()
    }
    
    public func willPresentModal(from displayView: PBMDisplayView) {
        willPresentModal()
    }
    
    public func didDismissModal(from displayView: PBMDisplayView) {
        didDismissModal()
    }
    
    // MARK: - BannerAdLoaderDelegate
    
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
