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

import Foundation
import UIKit

/// A base class for interstitial ad units.
public class BaseInterstitialAdUnit :
    NSObject,
    PBMInterstitialAdLoaderDelegate,
    AdLoadFlowControllerDelegate,
    InterstitialControllerInteractionDelegate,
    InterstitialEventInteractionDelegate,
    BaseInterstitialAdUnitProtocol {
    
    // MARK: - Public Properties
    
    /// The banner parameters used for configuring ad unit.
    @objc public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    /// The video parameters used for configuring ad unit.
    @objc public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    /// The last bid response received for the ad unit.
    @objc public var lastBidResponse: BidResponse? {
        return adLoadFlowController?.bidResponse
    }
    
    /// The configuration ID for the ad unit.
    @objc public var configID: String {
        adUnitConfig.configId
    }
    
    /// The set of ad formats supported by this ad unit.
    @objc public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    /// The ORTB (OpenRTB) configuration string for the ad unit.
    @objc public var ortbConfig: String? {
        get { adUnitConfig.ortbConfig }
        set { adUnitConfig.ortbConfig = newValue }
    }
     
    /// A Boolean value indicating whether the ad unit is ready to be displayed.
    @objc public var isReady: Bool {
        objc_sync_enter(blocksLockToken)
        if let block = isReadyBlock {
            let res = block()
            objc_sync_exit(blocksLockToken)
            return res
        }
        
        objc_sync_exit(blocksLockToken)
        return false
    }

    /// A Boolean value indicating whether the video controls are muted.
    @objc public var isMuted: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isMuted }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isMuted = newValue }
    }

    /// A Boolean value indicating whether the sound button is visible in the video controls.
    @objc public var isSoundButtonVisible: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible = newValue }
    }

    /// The area of the close button in the video controls as a percentage.
    @objc public var closeButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea = newValue }
    }

    /// The position of the close button in the video controls.
    @objc public var closeButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition = newValue }
    }

    /// A delegate for handling interactions with the ad unit.
    @objc public weak var delegate: AnyObject?
    
    /// The configuration object for the ad unit.
    public let adUnitConfig: AdUnitConfig
    
    // MARK: - Private Properties
    
    private var adLoadFlowController: PBMAdLoadFlowController!
    
    private let blocksLockToken: NSObject
        
    private var showBlock: ((UIViewController?) -> Void)?
    private var currentAdBlock: ((UIViewController?) -> Void)?
    private var isReadyBlock: (() -> Bool)?

    private weak var targetController: UIViewController?
    
    // MARK: - Public Methods
    
    /// Initializes a new `BaseInterstitialAdUnit` with the specified configuration ID, minimum size percentage, and event handler.
    /// - Parameters:
    ///   - configID: The unique identifier for the ad unit configuration.
    ///   - minSizePerc: The minimum size percentage for the ad unit.
    ///   - eventHandler: An optional event handler object for handling ad events.
    required public init(configID: String,
                         minSizePerc: NSValue?,
                         eventHandler: AnyObject?) {
        
        adUnitConfig = AdUnitConfig(configId: configID)
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.minSizePerc = minSizePerc
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adConfiguration.adFormats = [.banner, .video]
        adUnitConfig.adConfiguration.bannerParameters.api = PrebidConstants.supportedRenderingBannerAPISignals
        blocksLockToken = NSObject()

        self.eventHandler = eventHandler

        super.init()
        
        videoParameters.placement = .Interstitial
        
        let adLoader = PBMInterstitialAdLoader(delegate: self)
        callEventHandler_setLoadingDelegate(adLoader)
        
        adLoadFlowController =  PBMAdLoadFlowController(bidRequesterFactory: { adUnitConfig in
            return PBMBidRequester(connection: PrebidServerConnection.shared,
                                   sdkConfiguration: Prebid.shared,
                                   targeting: Targeting.shared,
                                   adUnitConfiguration: adUnitConfig)
        },
        adLoader: adLoader,
        delegate: self,
        configValidationBlock: { _,_ in true } )
    }
    
    /// Initializes a new `BaseInterstitialAdUnit` with the specified configuration ID, minimum size percentage, and event handler.
    /// - Parameters:
    ///   - configID: The unique identifier for the ad unit configuration.
    ///   - minSizePercentage: The minimum size percentage for the ad unit.
    ///   - eventHandler: An optional event handler object for handling ad events.
    public convenience init(configID: String,
                            minSizePercentage: CGSize,
                            eventHandler:AnyObject?)
    {
        self.init(configID: configID,
                  minSizePerc:NSValue(cgSize: minSizePercentage),
                  eventHandler: eventHandler)
    }

    /// Initializes a new `BaseInterstitialAdUnit` with the specified configuration ID and event handler.
    /// - Parameters:
    ///   - configID: The unique identifier for the ad unit configuration.
    ///   - eventHandler: An optional event handler object for handling ad events.
    public convenience init(configID: String,
                            eventHandler:AnyObject?) {
        self.init(configID: configID,
                  minSizePerc:nil,
                  eventHandler: eventHandler)
        
    }

    /// Initializes a new `BaseInterstitialAdUnit` with the specified configuration ID and minimum size percentage.
    /// - Parameters:
    ///   - configID: The unique identifier for the ad unit configuration.
    ///   - minSizePercentage: The minimum size percentage for the ad unit.
    public convenience init(configID: String,
                            minSizePercentage:CGSize) {
        
        self.init(configID: configID,
                  minSizePerc:NSValue(cgSize: minSizePercentage),
                  eventHandler: nil)
    }

    /// Initializes a new `BaseInterstitialAdUnit` with the specified configuration ID.
    /// - Parameter configID: The unique identifier for the ad unit configuration.
    public convenience init(configID: String)  {
        self.init(configID: configID,
                  minSizePerc:nil,
                  eventHandler: nil)    }
    
    // MARK: - Public Methods
    
    /// Loads a new ad.
    @objc public func loadAd() {
        adLoadFlowController.refresh()
    }
    
    /// Shows the ad from a specified view controller.
    /// - Parameter controller: The view controller from which the ad will be presented.
    /// - Note: This method must be called on the main thread.
    @objc public func show(from controller: UIViewController) {
        // It is expected from the user to call this method on main thread
        assert(Thread.isMainThread, "Expected to only be called on the main thread");
       
        objc_sync_enter(blocksLockToken)

            guard self.showBlock != nil,
                  self.currentAdBlock == nil else {
                objc_sync_exit(blocksLockToken)
                return;
            }
            isReadyBlock = nil;
            currentAdBlock = showBlock;
            showBlock = nil;
        
            callDelegate_willPresentAd()
            targetController = controller;
            currentAdBlock?(controller);
            objc_sync_exit(blocksLockToken)

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
    
    // MARK: - PBMInterstitialAdLoaderDelegate
    
    /// Internal delegate method.
    public func interstitialAdLoader(_ interstitialAdLoader: PBMInterstitialAdLoader,
                                     loadedAd showBlock: @escaping (UIViewController?) -> Void,
                                     isReadyBlock: @escaping () -> Bool) {
        objc_sync_enter(blocksLockToken)
        self.showBlock = showBlock
        self.isReadyBlock = isReadyBlock
        objc_sync_exit(blocksLockToken)
        
        reportLoadingSuccess()
    }
    
    /// Internal delegate method.
    public func interstitialAdLoader(_ interstitialAdLoader: PBMInterstitialAdLoader,
                                     createdInterstitialController interstitialController: InterstitialController) {
        interstitialController.interactionDelegate = self
    }
   
    /// The event handler for the interstitial events.
    public var eventHandler: Any?
    
    
    // MARK: - AdLoadFlowControllerDelegate
    
    /// Called when the ad load flow controller is about to send a bid request.
    public func adLoadFlowControllerWillSendBidRequest(_ adLoadFlowController: PBMAdLoadFlowController) {
        // nop
    }
    
    /// Called when the ad load flow controller is about to request the primary ad.
    public func adLoadFlowControllerWillRequestPrimaryAd(_ adLoadFlowController: PBMAdLoadFlowController) {
        callEventHandler_setInteractionDelegate()
    }
    
    /// Called to determine if the ad load flow controller should continue with the current flow.
    public func adLoadFlowControllerShouldContinue(_ adLoadFlowController: PBMAdLoadFlowController) -> Bool {
        true
    }
    
    /// Called when the ad load flow controller fails with an error.
    public func adLoadFlowController(_ adLoadFlowController: PBMAdLoadFlowController, failedWithError error: Error?) {
        reportLoadingFailed(with: error)
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    /// Tracks an impression for the given interstitial controller.
    public func trackImpression(forInterstitialController: InterstitialController) {
        DispatchQueue.main.async {
            self.callEventHandler_trackImpression()
        }
    }
    
    /// Called when the ad in the interstitial controller is clicked.
    public func interstitialControllerDidClickAd(_ interstitialController: InterstitialController) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        callDelegate_didClickAd()
    }
    
    /// Called when the ad in the interstitial controller is closed.
    public func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        callDelegate_didDismissAd()
    }
    
    /// Called when the ad in the interstitial controller causes the app to leave.
    public func interstitialControllerDidLeaveApp(_ interstitialController: InterstitialController) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        callDelegate_willLeaveApplication()
    }
    
    /// Called when the interstitial controller displays an ad.
    public func interstitialControllerDidDisplay(_ interstitialController: InterstitialController) {
        
    }
    
    /// Called when the interstitial controller completes the ad display.
    public func interstitialControllerDidComplete(_ interstitialController: InterstitialController) {
        
    }
    
    /// Provides the view controller to use for modal presentation.
    public func viewControllerForModalPresentation(fromInterstitialController: InterstitialController) -> UIViewController? {
        return targetController
    }
    
    // MARK: - Private methods

    private func reportLoadingSuccess() {
        DispatchQueue.main.async {
            self.callDelegate_didReceiveAd()
        }
    }

    private func reportLoadingFailed(with error: Error?) {
        DispatchQueue.main.async {
            self.callDelegate_didFailToReceiveAd(with: error)
        }
    }
    
    // MARK: - InterstitialEventInteractionDelegate
    
    /// Called when an ad is about to be presented.
    public func willPresentAd() {
        DispatchQueue.main.async {
            self.callDelegate_willPresentAd()
        }
    }
    
    /// Called when an ad has been dismissed.
    public func didDismissAd() {
        objc_sync_enter(blocksLockToken)
        currentAdBlock = nil
        objc_sync_exit(blocksLockToken)
        
        DispatchQueue.main.async {
            self.callDelegate_didDismissAd()
        }
    }
    
    /// Called when the ad causes the app to leave.
    public func willLeaveApp() {
        DispatchQueue.main.async {
            self.callDelegate_willLeaveApplication()
        }
    }
    
    /// Called when an ad is clicked.
    public func didClickAd() {
        DispatchQueue.main.async {
            self.callDelegate_didClickAd()
        }
    }

    // MARK: - BaseInterstitialAdUnitProtocol
    
    /// Requests an ad using the provided bid response.
    public func callEventHandler_requestAd(with bidResponse: BidResponse?) {
        
    }
    
    /// Displays the ad using the provided view controller.
    public func callEventHandler_show(from controller: UIViewController?) {
        
    }

    // MARK: - Abstract Methods
    
    /// Checks if the ad unit is ready to show an ad.
    public func callEventHandler_isReady() -> Bool {
        return false // to be overridden in subclass
    }

    /// Notifies the delegate that an ad has been successfully received.
    public func callDelegate_didReceiveAd() {
        // to be overridden in subclass
    }

    /// Notifies the delegate that the ad failed to load.
    public func callDelegate_didFailToReceiveAd(with: Error?) {
        // to be overridden in subclass
    }

    /// Notifies the delegate that an ad is about to be presented.
    public func callDelegate_willPresentAd() {
        // to be overridden in subclass
    }

    /// Notifies the delegate that an ad has been dismissed.
    public func callDelegate_didDismissAd() {
        // to be overridden in subclass
    }

    /// Notifies the delegate that the app is about to leave due to an ad.
    public func callDelegate_willLeaveApplication() {
        // to be overridden in subclass
    }

    /// Notifies the delegate that an ad has been clicked.
    public func callDelegate_didClickAd() {
        // to be overridden in subclass
    }

    /// Sets the loading delegate for the event handler.
    public func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?) {
        // to be overridden in subclass
    }

    /// Sets the interaction delegate for the event handler.
    public func callEventHandler_setInteractionDelegate() {
        // to be overridden in subclass
    }

    /// Shows the ad from the provided view controller.
    public func callEventHandler_showFromViewController(controller: UIViewController?) {
        // to be overridden in subclass
    }

    /// Tracks an impression for the ad.
    public func callEventHandler_trackImpression() {
        // to be overridden in subclass
    }
}
