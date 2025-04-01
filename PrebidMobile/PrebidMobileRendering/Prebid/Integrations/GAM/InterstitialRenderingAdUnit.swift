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
    
    /// The banner parameters used for configuring ad unit.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    /// The video parameters used for configuring ad unit.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    // MARK: - SKAdNetwork
    
    /// A flag that determines whether SKOverlay should be supported
    public var supportSKOverlay: Bool {
        get { adUnitConfig.adConfiguration.supportSKOverlay }
        set { adUnitConfig.adConfiguration.supportSKOverlay = newValue }
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
    
    // MARK: - Ext keywords (imp[].ext.keywords)
    
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
