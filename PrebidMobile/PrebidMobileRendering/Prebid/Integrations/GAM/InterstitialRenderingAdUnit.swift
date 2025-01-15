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

/// Represents an interstitial ad unit. Built for rendering type of integration.
@objcMembers
public class InterstitialRenderingAdUnit: NSObject, BaseInterstitialAdUnitProtocol {
    
    /// A delegate for handling interactions with the ad unit.
    public weak var delegate: InterstitialAdUnitDelegate?
    
    /// A Boolean value indicating whether the ad unit is ready to be displayed.
    public var isReady: Bool {
        baseAdUnit.isReady
    }
    
    /// The set of ad formats supported by this ad unit.
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    /// The ORTB (OpenRTB) configuration string for the ad unit.
    @available(*, deprecated, message: "Deprecated. Use setImpORTBConfig(_:) and getImpORTBConfig() for impression-level ORTB configuration.")
    public var ortbConfig: String? {
        get { adUnitConfig.ortbConfig }
        set { adUnitConfig.ortbConfig = newValue }
    }
    
    /// The banner parameters used for configuring ad unit.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    /// The video parameters used for configuring ad unit.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    // MARK: - Video controls configuration
    
    /// The area of the close button in the video controls as a percentage.
    public var closeButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea = newValue }
    }
    
    /// The position of the close button in the video controls.
    public var closeButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition = newValue }
    }
    
    /// The area of the skip button in the video controls, specified as a percentage of the screen width.
    public var skipButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonArea = newValue }
    }
    
    /// The position of the skip button in the video controls.
    public var skipButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonPosition = newValue }
    }
    
    /// The delay before the skip button appears, in seconds.
    public var skipDelay: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipDelay }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipDelay = newValue }
    }
    
    /// A Boolean value indicating whether the video controls are muted.
    public var isMuted: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isMuted }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isMuted = newValue }
    }
    
    /// A Boolean value indicating whether the sound button is visible in the video controls.
    public var isSoundButtonVisible: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible = newValue }
    }
    
    // MARK: Private properties
    
    private let baseAdUnit: BaseInterstitialAdUnit
    
    // NOTE: exposed for tests
    var adUnitConfig: AdUnitConfig {
        baseAdUnit.adUnitConfig
    }
    
    private var eventHandler: PBMPrimaryAdRequesterProtocol {
        baseAdUnit.eventHandler
    }
    
    /// Initializes a new `BaseInterstitialAdUnit` with the specified configuration ID.
    /// - Parameter configID: The unique identifier for the ad unit configuration.
    public convenience init(configID: String) {
        self.init(
            configID: configID,
            minSizePerc: nil,
            primaryAdRequester: InterstitialEventHandlerStandalone()
        )
    }
    
    /// Initializes a new `InterstitialRenderingAdUnit` with the specified configuration ID and minimum size percentage.
    /// - Parameters:
    ///   - configID: The unique identifier for the ad unit configuration.
    ///   - minSizePercentage: The minimum size percentage for the ad unit.
    public convenience init(configID: String, minSizePercentage: CGSize) {
        self.init(
            configID: configID,
            minSizePerc: NSValue(cgSize: minSizePercentage),
            primaryAdRequester: InterstitialEventHandlerStandalone()
        )
    }
    
    /// Initializes a new `InterstitialRenderingAdUnit` with the specified configuration ID and event handler.
    /// - Parameters:
    ///   - configID: The unique identifier for the ad unit configuration.
    ///   - eventHandler: An object for handling ad events.
    public convenience init(configID: String, eventHandler: AnyObject?) {
        self.init(
            configID: configID,
            minSizePerc: nil,
            primaryAdRequester: (eventHandler as? PBMPrimaryAdRequesterProtocol) ?? InterstitialEventHandlerStandalone()
        )
    }
    
    /// Initializes a new `InterstitialRenderingAdUnit` with the specified configuration ID, minimum size percentage, and event handler.
    /// - Parameters:
    ///   - configID: The unique identifier for the ad unit configuration.
    ///   - minSizePercentage: The minimum size percentage for the ad unit.
    ///   - eventHandler: An object for handling ad events.
    public convenience init(
        configID: String,
        minSizePercentage: CGSize,
        eventHandler: AnyObject
    ) {
        self.init(
            configID: configID,
            minSizePerc: NSValue(cgSize: minSizePercentage),
            primaryAdRequester: (eventHandler as? PBMPrimaryAdRequesterProtocol) ?? InterstitialEventHandlerStandalone()
        )
    }
    
    required init(
        configID: String,
        minSizePerc: NSValue?,
        primaryAdRequester: PBMPrimaryAdRequesterProtocol
    ) {
        baseAdUnit = BaseInterstitialAdUnit(
            configID: configID,
            minSizePerc: minSizePerc,
            eventHandler: primaryAdRequester
        )
        
        super.init()
        
        baseAdUnit.delegate = self
    }
    
    // MARK: - Public methods
    
    /// Loads a new ad.
    public func loadAd() {
        baseAdUnit.loadAd()
    }
    
    /// Shows the ad from a specified view controller.
    /// - Parameter controller: The view controller from which the ad will be presented.
    /// - Note: This method must be called on the main thread.
    public func show(from controller: UIViewController) {
        baseAdUnit.show(from: controller)
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbObject: The impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        adUnitConfig.impORTBConfig
    }
    
    // MARK: - Ext Data (imp[].ext.data)
    
    /// Adds context data for a specified key.
    /// - Parameters:
    ///   - data: The data to add.
    ///   - key: The key associated with the data.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    public func addContextData(_ data: String, forKey key: String) {
        addExtData(key: key, value: data)
    }
    
    /// Updates context data for a specified key.
    /// - Parameters:
    ///   - data: A set of data to update.
    ///   - key: The key associated with the data.
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        updateExtData(key: key, value: data)
    }
    
    /// Removes context data for a specified key.
    /// - Parameter key: The key associated with the data to remove.
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    public func removeContextDate(forKey key: String) {
        removeExtData(forKey: key)
    }
    
    /// Clears all context data.
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    public func clearContextData() {
        clearExtData()
    }
    
    /// Adds ext data.
    /// - Parameters:
    ///   - key: The key for the data.
    ///   - value: The value for the data.
    public func addExtData(key: String, value: String) {
        adUnitConfig.addExtData(key: key, value: value)
    }
    
    /// Updates ext data.
    /// - Parameters:
    ///   - key: The key for the data.
    ///   - value: The value for the data.
    public func updateExtData(key: String, value: Set<String>) {
        adUnitConfig.updateExtData(key: key, value: value)
    }
    
    /// Removes ext data.
    /// - Parameters:
    ///   - key: The key for the data.
    public func removeExtData(forKey: String) {
        adUnitConfig.removeExtData(for: forKey)
    }
    
    /// Clears ext data.
    public func clearExtData() {
        adUnitConfig.clearExtData()
    }
    
    // MARK: - Ext keywords (imp[].ext.keywords)
    
    /// Adds a context keyword.
    /// - Parameter newElement: The keyword to add.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeyword method instead.")
    public func addContextKeyword(_ newElement: String) {
        addExtKeyword(newElement)
    }
    
    /// Adds a set of context keywords.
    /// - Parameter newElements: A set of keywords to add.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    public func addContextKeywords(_ newElements: Set<String>) {
        addExtKeywords(newElements)
    }
    
    /// Removes a context keyword.
    /// - Parameter element: The keyword to remove.
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    public func removeContextKeyword(_ element: String) {
        removeExtKeyword(element)
    }
    
    /// Clears all context keywords.
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    public func clearContextKeywords() {
        clearExtKeywords()
    }
    
    /// Adds an extended keyword.
    /// - Parameter newElement: The keyword to be added.
    public func addExtKeyword(_ newElement: String) {
        adUnitConfig.addExtKeyword(newElement)
    }
    
    /// Adds multiple extended keywords.
    /// - Parameter newElements: A set of keywords to be added.
    public func addExtKeywords(_ newElements: Set<String>) {
        adUnitConfig.addExtKeywords(newElements)
    }
    
    /// Removes an extended keyword.
    /// - Parameter element: The keyword to be removed.
    public func removeExtKeyword(_ element: String) {
        adUnitConfig.removeExtKeyword(element)
    }
    
    /// Clears all extended keywords.
    public func clearExtKeywords() {
        adUnitConfig.clearExtKeywords()
    }
    
    // MARK: - App Content (app.content.data)
    
    /// Sets the app content data.
    /// - Parameter appContent: The app content data.
    public func setAppContent(_ appContent: PBMORTBAppContent) {
        adUnitConfig.setAppContent(appContent)
    }
    
    /// Clears the app content data.
    public func clearAppContent() {
        adUnitConfig.clearAppContent()
    }
    
    /// Adds app content data objects.
    /// - Parameter dataObjects: The data objects to be added.
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        adUnitConfig.addAppContentData(dataObjects)
    }
    
    /// Removes an app content data object.
    /// - Parameter dataObject: The data object to be removed.
    public func removeAppContentDataObject(_ dataObject: PBMORTBContentData) {
        adUnitConfig.removeAppContentData(dataObject)
    }
    
    /// Clears all app content data objects.
    public func clearAppContentDataObjects() {
        adUnitConfig.clearAppContentData()
    }
    
    // MARK: - User Data (user.data)
    
    /// Adds user data objects.
    /// - Parameter userDataObjects: The user data objects to be added.
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        adUnitConfig.addUserData(userDataObjects)
    }
    
    /// Removes a user data object.
        /// - Parameter userDataObject: The user data object to be removed.
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        adUnitConfig.removeUserData(userDataObject)
    }
    
    /// Clears all user data objects.
    public func clearUserData() {
        adUnitConfig.clearUserData()
    }
    
    // MARK: - Internal methods
    
    func interstitialControllerDidCloseAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        baseAdUnit.interstitialControllerDidCloseAd(interstitialController)
    }
    
    func callDelegate_didReceiveAd() {
        delegate?.interstitialDidReceiveAd?(self)
    }
    
    func callDelegate_didFailToReceiveAd(with error: Error?) {
        delegate?.interstitial?(self, didFailToReceiveAdWithError: error)
    }
    
    func callDelegate_willPresentAd() {
        delegate?.interstitialWillPresentAd?(self)
    }
    
    func callDelegate_didDismissAd() {
        delegate?.interstitialDidDismissAd?(self)
    }
    
    func callDelegate_willLeaveApplication() {
        delegate?.interstitialWillLeaveApplication?(self)
    }
    
    func callDelegate_didClickAd() {
        delegate?.interstitialDidClickAd?(self)
    }
    
    func callEventHandler_isReady() -> Bool {
        (eventHandler as? InterstitialEventHandlerProtocol)?.isReady ?? false
    }
    
    func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?) {
        if let eventHandler = eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.loadingDelegate = loadingDelegate as? InterstitialEventLoadingDelegate
        }
    }
    
    func callEventHandler_setInteractionDelegate() {
        if let eventHandler = eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.interactionDelegate = baseAdUnit
        }
    }
    
    func callEventHandler_requestAd(with bidResponse: BidResponse?) {
        if let eventHandler = eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.requestAd(with: bidResponse)
        }
    }
    
    func callEventHandler_show(from controller: UIViewController?) {
        if let eventHandler = eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.show(from: controller)
        }
    }
    
    func callEventHandler_trackImpression() {
        if let eventHandler = eventHandler as? InterstitialEventHandlerProtocol {
            eventHandler.trackImpression?()
        }
    }
}
