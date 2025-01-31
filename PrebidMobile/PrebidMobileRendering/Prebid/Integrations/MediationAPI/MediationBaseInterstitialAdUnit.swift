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

/// Base class for interstitial ads in Mediation API.
@objcMembers
public class MediationBaseInterstitialAdUnit : NSObject {
    
    /// Parameters for configuring banner ads.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    /// Parameters for configuring video ads.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    /// Indicates whether the video ad is muted.
    public var isMuted: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isMuted }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isMuted = newValue }
    }

    /// Indicates whether the sound button is visible in the video ad.
    public var isSoundButtonVisible: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible = newValue }
    }
    
    /// The area for the close button in the video ad.
    public var closeButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea = newValue }
    }
    
    /// The position of the close button in the video ad.
    public var closeButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition = newValue }
    }
    
    /// The ORTB (OpenRTB) configuration string for the ad unit.
    @available(*, deprecated, message: "Deprecated. Use setImpORTBConfig(_:) and getImpORTBConfig() for impression-level ORTB configuration.")
    public var ortbConfig: String? {
        get { adUnitConfig.ortbConfig }
        set { adUnitConfig.ortbConfig = newValue }
    }
    
    /// The configuration ID for the ad unit.
    public var configId: String {
        adUnitConfig.configId
    }
    
    let adUnitConfig: AdUnitConfig
    
    var bidRequester: PBMBidRequester?
    
    var completion: ((ResultCode) -> Void)?
    
    let mediationDelegate: PrebidMediationDelegate
    
    init(configId: String, mediationDelegate: PrebidMediationDelegate) {
        self.mediationDelegate = mediationDelegate
        adUnitConfig = AdUnitConfig(configId: configId)
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adConfiguration.adFormats = [.banner, .video]
        adUnitConfig.adConfiguration.bannerParameters.api = PrebidConstants.supportedRenderingBannerAPISignals
        
        super.init()
        videoParameters.placement = .Interstitial
        videoParameters.plcmnt = .Interstitial
    }
    
    /// Makes bid request and setups mediation parameters.
    /// - Parameters:
    ///   - completion: A closure called with the result code indicating the outcome of the demand fetch.
    public func fetchDemand(completion: ((ResultCode)->Void)?) {
        fetchDemand(connection: PrebidServerConnection.shared,
                    sdkConfiguration: Prebid.shared,
                    targeting: Targeting.shared,
                    completion: completion)
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
    
    // MARK: - Internal Methods
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(connection: PrebidServerConnectionProtocol,
                     sdkConfiguration: Prebid,
                     targeting: Targeting,
                     completion: ((ResultCode)->Void)?) {
        guard bidRequester == nil else {
            // Request in progress
            return
        }
        
        self.completion = completion
        
        mediationDelegate.cleanUpAdObject()
        
        bidRequester = PBMBidRequester(connection: connection,
                                       sdkConfiguration: sdkConfiguration,
                                       targeting: targeting,
                                       adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids(completion: { [weak self] (bidResponse, error) in
            if let response = bidResponse {
                self?.handleBidResponse(response)
            } else {
                self?.handleBidRequestError(error)
            }
        })
    }
    
    // MARK: - Private Methods
    
    private func handleBidResponse(_ bidResponse: BidResponse) {
        var demandResult = ResultCode.prebidDemandNoBids
        
        if let winningBid = bidResponse.winningBid, let targetingInfo = winningBid.targetingInfo {
            var adObjectSetupDictionary: [String: Any] = [
                PBMMediationConfigIdKey: configId,
                PBMMediationTargetingInfoKey: targetingInfo,
                PBMMediationAdUnitBidKey: winningBid
            ]
            
            if bidResponse.winningBid?.adFormat == .video {
                // Append video specific configurations
                let videoSetupDictionary: [String: Any] = [
                    PBMMediationVideoAdConfiguration: self.adUnitConfig.adConfiguration.videoControlsConfig,
                    PBMMediationVideoParameters: self.adUnitConfig.adConfiguration.videoParameters
                ]
                adObjectSetupDictionary.merge(videoSetupDictionary, uniquingKeysWith: { $1 })
            }
            
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
    
    private func handleBidRequestError(_ error: Error?) {
        completeWithResult(PBMError.demandResult(from: error))
    }
    
    private func completeWithResult(_ demandResult: ResultCode) {
        if let completion = self.completion {
            DispatchQueue.main.async {
                completion(demandResult)
            }
        }
        
        self.completion = nil
        
        markLoadingFinished()
    }
    
    private func markLoadingFinished() {
        completion = nil
        bidRequester = nil
    }
}
