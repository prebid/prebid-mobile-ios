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

/// Represents an rewarded ad unit. Built for rendering type of integration.
@objc
public class RewardedAdUnit: NSObject, BaseInterstitialAdUnitProtocol {
    
    public weak var delegate: RewardedAdUnitDelegate?
    
    public var isReady: Bool {
        baseAdUnit.isReady
    }
    
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    public var ortbConfig: String? {
        get { adUnitConfig.ortbConfig }
        set { adUnitConfig.ortbConfig = newValue }
    }
    
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    // MARK: - Video controls configuration
    
    public var closeButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea = newValue }
    }
    
    public var closeButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition = newValue }
    }
    
    public var isMuted: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isMuted }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isMuted = newValue }
    }
    
    public var isSoundButtonVisible: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible = newValue }
    }
    
    // MARK: Private properties
    
    private let baseAdUnit: BaseRewardedAdUnit
    
    private var adUnitConfig: AdUnitConfig {
        baseAdUnit.adUnitConfig
    }
    
    private var eventHandler: PBMPrimaryAdRequesterProtocol {
        baseAdUnit.eventHandler
    }
    
    public convenience init(configID: String) {
        self.init(
            configID: configID,
            minSizePerc: nil,
            primaryAdRequester: RewardedEventHandlerStandalone()
        )
    }
    
    public convenience init(configID: String, minSizePercentage: CGSize) {
        self.init(
            configID: configID,
            minSizePerc: NSValue(cgSize: minSizePercentage),
            primaryAdRequester: RewardedEventHandlerStandalone()
        )
    }
    
    public convenience init(configID: String, eventHandler: AnyObject?) {
        self.init(
            configID: configID,
            minSizePerc: nil,
            primaryAdRequester: (eventHandler as? PBMPrimaryAdRequesterProtocol) ?? RewardedEventHandlerStandalone()
        )
    }
    
    public convenience init(
        configID: String,
        minSizePercentage: CGSize,
        eventHandler: AnyObject
    ) {
        self.init(
            configID: configID,
            minSizePerc: NSValue(cgSize: minSizePercentage),
            primaryAdRequester: (eventHandler as? PBMPrimaryAdRequesterProtocol) ?? RewardedEventHandlerStandalone()
        )
    }
    
    required init(
        configID: String,
        minSizePerc: NSValue?,
        primaryAdRequester: PBMPrimaryAdRequesterProtocol
    ) {
        baseAdUnit = BaseRewardedAdUnit(
            configID: configID,
            minSizePerc: minSizePerc,
            eventHandler: primaryAdRequester
        )
        
        super.init()
        
        baseAdUnit.delegate = self
    }
    
    // MARK: - Public methods
    
    public func loadAd() {
        baseAdUnit.loadAd()
    }
    
    public func show(from controller: UIViewController) {
        baseAdUnit.show(from: controller)
    }
    
    // MARK: - Ext Data (imp[].ext.data)
    
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    public func addContextData(_ data: String, forKey key: String) {
        addExtData(key: key, value: data)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        updateExtData(key: key, value: data)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    public func removeContextDate(forKey key: String) {
        removeExtData(forKey: key)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    public func clearContextData() {
        clearExtData()
    }
    
    public func addExtData(key: String, value: String) {
        adUnitConfig.addExtData(key: key, value: value)
    }
    
    public func updateExtData(key: String, value: Set<String>) {
        adUnitConfig.updateExtData(key: key, value: value)
    }
    
    public func removeExtData(forKey: String) {
        adUnitConfig.removeExtData(for: forKey)
    }
    
    public func clearExtData() {
        adUnitConfig.clearExtData()
    }
    
    // MARK: - Ext keywords (imp[].ext.keywords)
    
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeyword method instead.")
    public func addContextKeyword(_ newElement: String) {
        addExtKeyword(newElement)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    public func addContextKeywords(_ newElements: Set<String>) {
        addExtKeywords(newElements)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    public func removeContextKeyword(_ element: String) {
        removeExtKeyword(element)
    }

    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    public func clearContextKeywords() {
        clearExtKeywords()
    }
    
    public func addExtKeyword(_ newElement: String) {
        adUnitConfig.addExtKeyword(newElement)
    }
    
    public func addExtKeywords(_ newElements: Set<String>) {
        adUnitConfig.addExtKeywords(newElements)
    }
    
    public func removeExtKeyword(_ element: String) {
        adUnitConfig.removeExtKeyword(element)
    }
    
    public func clearExtKeywords() {
        adUnitConfig.clearExtKeywords()
    }
    
    // MARK: - App Content (app.content.data)
    
    public func setAppContent(_ appContent: PBMORTBAppContent) {
        adUnitConfig.setAppContent(appContent)
    }
    
    public func clearAppContent() {
        adUnitConfig.clearAppContent()
    }
    
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        adUnitConfig.addAppContentData(dataObjects)
    }

    public func removeAppContentDataObject(_ dataObject: PBMORTBContentData) {
        adUnitConfig.removeAppContentData(dataObject)
    }
    
    public func clearAppContentDataObjects() {
        adUnitConfig.clearAppContentData()
    }
    
    // MARK: - User Data (user.data)
    
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        adUnitConfig.addUserData(userDataObjects)
    }
    
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        adUnitConfig.removeUserData(userDataObject)
    }
    
    public func clearUserData() {
        adUnitConfig.clearUserData()
    }
    
    // MARK: - Internal methods
    
    func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController) {
        baseAdUnit.interstitialControllerDidCloseAd(interstitialController)
    }
    
    func callDelegate_didReceiveAd() {
        delegate?.rewardedAdDidReceiveAd?(self)
    }
    
    func callDelegate_didFailToReceiveAd(with error: Error?) {
        delegate?.rewardedAd?(self, didFailToReceiveAdWithError: error)
    }
    
    func callDelegate_willPresentAd() {
        delegate?.rewardedAdWillPresentAd?(self)
    }
    
    func callDelegate_didDismissAd() {
        delegate?.rewardedAdDidDismissAd?(self)
    }
    
    func callDelegate_willLeaveApplication() {
        delegate?.rewardedAdWillLeaveApplication?(self)
    }
    
    func callDelegate_didClickAd() {
        delegate?.rewardedAdDidClickAd?(self)
    }
    
    func callEventHandler_isReady() -> Bool {
        (eventHandler as? RewardedEventHandlerProtocol)?.isReady ?? false
    }
    
    func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?) {
        if let eventHandler = eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.loadingDelegate = loadingDelegate as? RewardedEventLoadingDelegate
        }
    }
    
    func callEventHandler_setInteractionDelegate() {
        if let eventHandler = eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.interactionDelegate = baseAdUnit
        }
    }
    
    func callEventHandler_requestAd(with bidResponse: BidResponse?) {
        if let eventHandler = eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.requestAd(with: bidResponse)
        }
    }
    
    func callEventHandler_show(from controller: UIViewController?) {
        if let eventHandler = eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.show(from: controller)
        }
    }
    
    func callEventHandler_trackImpression() {
        if let eventHandler = eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.trackImpression?()
        }
    }
    
    func callDelegate_rewardedAdUserDidEarnReward(reward: PrebidReward) {
        delegate?.rewardedAdUserDidEarnReward?(self, reward: reward)
    }
}
