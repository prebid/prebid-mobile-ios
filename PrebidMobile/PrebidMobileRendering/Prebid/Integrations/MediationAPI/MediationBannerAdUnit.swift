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

/// This class is responsible for making bid request and providing the winning bid and targeting keywords to mediating SDKs.
/// This class is a part of Mediation API.
@objcMembers
public class MediationBannerAdUnit : NSObject {
    
    var bidRequester: PBMBidRequester?
    // The view in which ad is displayed
    weak var adView: UIView?
    var completion: ((ResultCode) -> Void)?
    
    weak var lastAdView: UIView?
    var lastCompletion: ((ResultCode) -> Void)?
    
    var isRefreshStopped = false
    var autoRefreshManager: PBMAutoRefreshManager?
    
    var adRequestError: Error?
    
    var adUnitConfig: AdUnitConfig
    
    /// Property that performs certain utilty work for the `MediationBannerAdUnit`
    public let mediationDelegate: PrebidMediationDelegate
    
    // MARK: - Computed properties
    
    /// The configuration ID for an ad unit
    public var configID: String {
        adUnitConfig.configId
    }
    
    /// The ad format for the ad unit.
    public var adFormat: AdFormat {
        get { adUnitConfig.adFormats.first ?? .banner }
        set { adUnitConfig.adFormats = [newValue] }
    }
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    /// Parameters for configuring banner ads.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    /// Parameters for configuring video ads.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    /// The refresh interval for the ad.
    public var refreshInterval: TimeInterval {
        get { adUnitConfig.refreshInterval }
        set { adUnitConfig.refreshInterval = newValue }
    }
    
    /// Additional sizes for the ad unit.
    public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    /// The ORTB (OpenRTB) configuration string for the ad unit.
    @available(*, deprecated, message: "Deprecated. Use setImpORTBConfig(_:) and getImpORTBConfig() for impression-level ORTB configuration.")
    public var ortbConfig: String? {
        get { adUnitConfig.ortbConfig }
        set { adUnitConfig.ortbConfig = newValue }
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbObject: The  impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        adUnitConfig.impORTBConfig
    }

    // MARK: - Ext Data (imp[].ext.data)
    
    /// This method obtains the context data keyword & value for adunit context targeting
    /// if the key already exists the value will be appended to the list. No duplicates will be added
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    public func addContextData(key: String, value: String) {
        addExtData(key: key, value: value)
    }

    /// This method obtains the context data keyword & values for adunit context targeting
    /// the values if the key already exist will be replaced with the new set of values
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    public func updateContextData(key: String, value: Set<String>) {
        updateExtData(key: key, value: value)
    }
    
    /// This method allows to remove specific context data keyword & values set from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    public func removeContextData(forKey: String) {
        removeExtData(forKey: forKey)
    }
    
    /// This method allows to remove all context data set from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    public func clearContextData() {
        clearExtData()
    }
    
    /// This method obtains the ext data keyword & value for adunit targeting.
    /// If the key already exists the value will be appended to the list. No duplicates will be added
    public func addExtData(key: String, value: String) {
        adUnitConfig.addExtData(key: key, value: value)
    }
    
    /// This method obtains the ext data keyword & values for adunit targeting.
    /// The values if the key already exist will be replaced with the new set of values
    public func updateExtData(key: String, value: Set<String>) {
        adUnitConfig.updateExtData(key: key, value: value)
    }
    
    /// This method allows to remove specific ext data keyword & values set from adunit targeting
    public func removeExtData(forKey: String) {
        adUnitConfig.removeExtData(for: forKey)
    }
    
    /// This method allows to remove all ext data set from adunit targeting
    public func clearExtData() {
        adUnitConfig.clearExtData()
    }
    
    // MARK: - Ext keywords (imp[].ext.keywords)
    
    /// This method obtains the context keyword for adunit context targeting
    /// Inserts the given element in the set if it is not already present.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeyword method instead.")
    public func addContextKeyword(_ newElement: String) {
        addExtKeyword(newElement)
    }
    
    /// This method obtains the context keyword set for adunit context targeting
    /// Adds the elements of the given set to the set.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    public func addContextKeywords(_ newElements: Set<String>) {
        addExtKeywords(newElements)
    }
    
    /// This method allows to remove specific context keyword from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    public func removeContextKeyword(_ element: String) {
        removeExtKeyword(element)
    }
    
    /// This method allows to remove all keywords from the set of adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    public func clearContextKeywords() {
        clearExtKeywords()
    }
    
    /// This method obtains the keyword for adunit targeting
    /// Inserts the given element in the set if it is not already present.
    public func addExtKeyword(_ newElement: String) {
        adUnitConfig.addExtKeyword(newElement)
    }
    
    /// This method obtains the keyword set for adunit targeting
    /// Adds the elements of the given set to the set.
    public func addExtKeywords(_ newElements: Set<String>) {
        adUnitConfig.addExtKeywords(newElements)
    }
    
    /// This method allows to remove specific keyword from adunit targeting
    public func removeExtKeyword(_ element: String) {
        adUnitConfig.removeExtKeyword(element)
    }
    
    /// This method allows to remove all keywords from the set of adunit targeting
    public func clearExtKeywords() {
        adUnitConfig.clearExtKeywords()
    }
    
    // MARK: - App Content (app.content.data)
    
    /// Sets the app content object, replacing any existing content.
    ///
    /// - Parameter appContentObject: The `PBMORTBAppContent` object representing the app's content.
    public func setAppContent(_ appContentObject: PBMORTBAppContent) {
        adUnitConfig.setAppContent(appContentObject)
    }
    
    /// Retrieves the current app content object.
    ///
    /// - Returns: The current `PBMORTBAppContent` object, or `nil` if no content is set.
    public func getAppContent() -> PBMORTBAppContent? {
        return adUnitConfig.getAppContent()
    }
    
    /// Clears the current app content object.
    public func clearAppContent() {
        adUnitConfig.clearAppContent()
    }
    
    /// Adds an array of content data objects to the app content.
    ///
    /// - Parameter dataObjects: An array of `PBMORTBContentData` objects to add.
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        adUnitConfig.addAppContentData(dataObjects)
    }
    
    /// Removes a specific content data object from the app content.
    ///
    /// - Parameter dataObject: The `PBMORTBContentData` object to remove.
    public func removeAppContentData(_ dataObject: PBMORTBContentData) {
        adUnitConfig.removeAppContentData(dataObject)
    }
    
    /// Clears all content data objects from the app content.
    public func clearAppContentData() {
        adUnitConfig.clearAppContentData()
    }
    
    // MARK: - User Data (user.data)
    
    /// Adds an array of user data objects.
    ///
    /// - Parameter userDataObjects: An array of `PBMORTBContentData` objects to add to the user data.
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        adUnitConfig.addUserData(userDataObjects)
    }
    
    /// Removes a specific user data object.
    ///
    /// - Parameter userDataObject: The `PBMORTBContentData` object to remove from the user data.
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        adUnitConfig.removeUserData(userDataObject)
    }
    
    /// Clears all user data.
    public func clearUserData() {
        adUnitConfig.clearUserData()
    }
    
    // MARK: - Public Methods
    
    /// Initializes a new mediation banner ad unit with the specified configuration ID, size, and mediation delegate.
    /// - Parameter configID: The unique identifier for the ad unit configuration.
    /// - Parameter size: The size of the ad.
    /// - Parameter mediationDelegate: The delegate for handling mediation.
    public init(configID: String, size: CGSize, mediationDelegate: PrebidMediationDelegate) {
        adUnitConfig = AdUnitConfig(configId: configID, size: size)
        adUnitConfig.adConfiguration.bannerParameters.api = PrebidConstants.supportedRenderingBannerAPISignals
        
        self.mediationDelegate = mediationDelegate
        super.init()
        
        autoRefreshManager = PBMAutoRefreshManager(prefetchTime: PBMAdPrefetchTime,
                                                   locking: nil,
                                                   lockProvider: nil,
                                                   refreshDelay: { [weak self] in
            (self?.adUnitConfig.refreshInterval ?? 0) as NSNumber
        },
                                                   mayRefreshNowBlock: { [weak self] in
            guard let self = self else { return false }
            return self.isAdObjectVisible() || self.adRequestError != nil
        }, refreshBlock: { [weak self] in
            guard let self = self,
                  self.lastAdView != nil,
                  let completion = self.lastCompletion else {
                return
            }
            
            self.fetchDemand(connection: PrebidServerConnection.shared,
                             sdkConfiguration: Prebid.shared,
                             targeting: Targeting.shared,
                             completion: completion)
        })
    }
    
    /// Makes bid request and setups mediation parameters.
    /// - Parameter completion: The completion handler to call when the demand fetch is complete.
    public func fetchDemand(completion: ((ResultCode)->Void)?) {
        
        fetchDemand(connection: PrebidServerConnection.shared,
                    sdkConfiguration: Prebid.shared,
                    targeting: Targeting.shared,
                    completion: completion)
    }
    
    /// Stops the auto-refresh for the ad unit.
    public func stopRefresh() {
        isRefreshStopped = true
    }
    
    /// Handles the event when the ad object fails to load an ad.
    /// - Parameter adObject: The ad object that failed to load the ad.
    /// - Parameter error: The error that occurred during the ad load.
    public func adObjectDidFailToLoadAd(adObject: UIView,
                                        with error: Error) {
        if adObject === self.adView || adObject === self.lastAdView {
            self.adRequestError = error
        }
    }
    
    // MARK: Private functions
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(connection: PrebidServerConnectionProtocol,
                     sdkConfiguration: Prebid,
                     targeting: Targeting,
                     completion: ((ResultCode)->Void)?) {
        guard bidRequester == nil else {
            // Request in progress
            return
        }
        
        autoRefreshManager?.cancelRefreshTimer()
        
        if isRefreshStopped {
            return
        }
        
        self.adView = mediationDelegate.getAdView()
        self.completion = completion
        
        lastAdView = nil
        lastCompletion = nil
        adRequestError = nil
        
        mediationDelegate.cleanUpAdObject()
        
        bidRequester = PBMBidRequester(connection: connection,
                                       sdkConfiguration: sdkConfiguration,
                                       targeting: targeting,
                                       adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids(completion: { bidResponse, error in
            // Note: we have to run the completion on the main thread since
            // the handlePrebidResponse changes the Primary SDK Object which is UIView
            // This point to switch the context to the main thread looks the most accurate.
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.isRefreshStopped {
                    self.markLoadingFinished()
                    return
                }
                
                if let response = bidResponse {
                    self.handlePrebidResponse(response: response)
                } else {
                    self.handlePrebidError(error: error)
                }
            }
        })
    }
    
    private func isAdObjectVisible() -> Bool {
        guard let adObject = lastAdView else {
            return false
        }
        
        return adObject.pbmIsVisible()
    }
    
    private func markLoadingFinished() {
        adView = nil
        completion = nil
        bidRequester = nil
    }
    
    private func handlePrebidResponse(response: BidResponse) {
        var demandResult = ResultCode.prebidDemandNoBids
        
        if self.adView != nil, let winningBid = response.winningBid, let targetingInfo = response.targetingInfo {
            
            let adObjectSetupDictionary: [String: Any] = [
                PBMMediationConfigIdKey: configID,
                PBMMediationTargetingInfoKey: targetingInfo,
                PBMMediationAdUnitBidKey: winningBid
            ]
            
            if mediationDelegate.setUpAdObject(with: adObjectSetupDictionary) {
                demandResult = .prebidDemandFetchSuccess
            } else {
                demandResult = .prebidWrongArguments
            }    
        } else {
            Log.error("The winning bid is absent in response!")
        }
        
        completeWithResult(demandResult)
    }
    
    private func handlePrebidError(error: Error?) {
        completeWithResult(PBMError.demandResult(from: error))
    }
    
    private func completeWithResult(_ fetchDemandResult: ResultCode) {
        defer {
            markLoadingFinished()
        }
        
        guard let adObject = self.adView,
              let completion = self.completion else {
            return
        }
        
        lastAdView = adObject
        lastCompletion = completion
        
        autoRefreshManager?.setupRefreshTimer()
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
}
