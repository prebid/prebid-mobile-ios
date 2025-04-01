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
    
    // MARK: - Ext keywords (imp[].ext.keywords)
        
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
