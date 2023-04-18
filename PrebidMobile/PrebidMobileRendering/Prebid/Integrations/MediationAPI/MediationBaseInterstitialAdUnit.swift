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

@objcMembers
public class MediationBaseInterstitialAdUnit : NSObject {
    
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    public var isMuted: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isMuted }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isMuted = newValue }
    }

    public var isSoundButtonVisible: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible = newValue }
    }

    public var closeButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonArea = newValue }
    }

    public var closeButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.closeButtonPosition = newValue }
    }
    
    let adUnitConfig: AdUnitConfig
    
    public var configId: String {
        adUnitConfig.configId
    }
    
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
    }
    
    public func fetchDemand(completion: ((ResultCode)->Void)?) {
        fetchDemand(connection: ServerConnection.shared,
                    sdkConfiguration: Prebid.shared,
                    targeting: Targeting.shared,
                    completion: completion)
    }
    
    // MARK: - Ext Data (imp[].ext.data)
    
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    public func addContextData(_ data: String, forKey key: String) {
        adUnitConfig.addExtData(key: key, value: data)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        adUnitConfig.updateExtData(key: key, value: data)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    public func removeContextDate(forKey key: String) {
        adUnitConfig.removeExtData(for: key)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    public func clearContextData() {
        adUnitConfig.clearExtData()
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
    @objc public func addContextKeyword(_ newElement: String) {
        adUnitConfig.addExtKeyword(newElement)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    @objc public func addContextKeywords(_ newElements: Set<String>) {
        adUnitConfig.addExtKeywords(newElements)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    @objc public func removeContextKeyword(_ element: String) {
        adUnitConfig.removeExtKeyword(element)
    }

    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    @objc public func clearContextKeywords() {
        adUnitConfig.clearExtKeywords()
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
    
    // MARK: - Internal Methods
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(connection: ServerConnectionProtocol,
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
