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

/// This class is responsible for making bid request and providing the winning bid and targeting keywords to mediating SDKs.
/// This class is a part of Mediation API.
@objcMembers
public class MediationNativeAdUnit : NSObject {
    
    let mediationDelegate: PrebidMediationDelegate
    
    /// The native request of the fetch that has not completed yet. Weak, so that a request released
    /// before it answers (after `nativeAdUnit` was replaced) does not block later fetches.
    private weak var requestInFlight: NativeRequest?
    
    // MARK: - Public Properties
    
    /// The native ad unit that makes native request.
    public var nativeAdUnit: NativeRequest
    
    var configID: String
    
    // MARK: - Public Methods
    
    /// Initializes a new instance of the `MediationNativeAdUnit` with the specified configuration ID and mediation delegate.
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - mediationDelegate: The delegate for mediation-related tasks.
    public init(configId: String, mediationDelegate: PrebidMediationDelegate) {
        self.configID = configId
        self.mediationDelegate = mediationDelegate
        self.nativeAdUnit = NativeRequest(configId: configId)
    }
    
    /// Adds event trackers to the native ad unit.
    /// - Parameter eventTrackers: An array of `NativeEventTracker` objects to add.
    public func addEventTracker(_ eventTrackers: [NativeEventTracker]) {
        nativeAdUnit.addNativeEventTracker(eventTrackers)
    }
    
    /// Adds native assets to the native ad unit.
    /// - Parameter assets: An array of `NativeAsset` objects to add.
    public func addNativeAssets(_ assets: [NativeAsset]) {
        nativeAdUnit.addNativeAssets(assets)
    }
    
    /// Sets the context type for the native ad unit.
    /// - Parameter contextType: The context type to set.
    public func setContextType(_ contextType: ContextType) {
        nativeAdUnit.context = contextType
    }
    
    /// Sets the placement type for the native ad unit.
    /// - Parameter placementType: The placement type to set.
    public func setPlacementType(_ placementType: PlacementType) {
        nativeAdUnit.placementType = placementType
    }
    
    /// Sets the placement count for the native ad unit.
    /// - Parameter placementCount: The placement count to set.
    public func setPlacementCount(_ placementCount: Int) {
        nativeAdUnit.placementCount = placementCount
    }
    
    /// Sets the context subtype for the native ad unit.
    /// - Parameter contextSubType: The context subtype to set.
    public func setContextSubType(_ contextSubType: ContextSubType) {
        nativeAdUnit.contextSubType = contextSubType
    }
    
    /// Sets the sequence for the native ad unit.
    /// - Parameter sequence: The sequence to set.
    public func setSequence(_ sequence: Int) {
        nativeAdUnit.sequence = sequence
    }
    
    /// Sets the asset URL support for the native ad unit.
    /// - Parameter assetURLSupport: The asset URL support value to set.
    public func setAssetURLSupport(_ assetURLSupport: Int) {
        nativeAdUnit.asseturlsupport = assetURLSupport
    }
    
    /// Sets the DURL support for the native ad unit.
    /// - Parameter dURLSupport: The DURL support value to set.
    public func setDURLSupport(_ dURLSupport: Int) {
        nativeAdUnit.durlsupport = dURLSupport
    }
    
    /// Sets the privacy value for the native ad unit.
    /// - Parameter privacy: The privacy value to set.
    public func setPrivacy(_ privacy: Int) {
        nativeAdUnit.privacy = privacy
    }
    
    /// Sets the extended data for the native ad unit.
    /// - Parameter ext: A dictionary containing the extended data to set.
    public func setExt(_ ext: [String: Any]) {
        nativeAdUnit.ext = ext
    }
    
    // MARK: Arbitrary ORTB Configuration
        
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbConfig: The  impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        nativeAdUnit.adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        nativeAdUnit.adUnitConfig.impORTBConfig
    }
    
    /// Sets the global OpenRTB configuration string for the ad unit. It takes precedence over `Targeting.setGlobalOrtbConfig`.
    ///
    /// - Parameter ortbConfig: The global OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setGlobalORTBConfig(_ ortbConfig: String?) {
        nativeAdUnit.adUnitConfig.globalORTBConfig = ortbConfig
    }
    
    /// Returns the global OpenRTB configuration string.
    public func getGlobalORTBConfig() -> String? {
        nativeAdUnit.adUnitConfig.globalORTBConfig
    }
    
    /// Makes bid request for the native ad unit and setups mediation parameters.
    ///
    /// If an earlier fetch has not completed yet, `completion` is called at once with
    /// `.prebidSDKMisusePreviousFetchNotCompletedYet` and the earlier fetch carries on.
    /// - Parameter completion: The completion handler to call with the result code.
    public func fetchDemand(completion: ((ResultCode) -> Void)?) {
        baseFetchDemand(completion: completion.map { completion in { completion($0.resultCode) } })
    }
    
    /// Makes bid request for the native ad unit and setups mediation parameters. Like `fetchDemand(completion:)`,
    /// but provides the full `BidInfo` (including the winning-bid economics) instead of only the result code.
    ///
    /// If an earlier fetch has not completed yet, `completion` is called at once with
    /// `.prebidSDKMisusePreviousFetchNotCompletedYet` and the earlier fetch carries on.
    /// - Parameter completion: A closure called with a `BidInfo` object representing the fetched demand.
    public func fetchDemandBidInfo(completion: @escaping (_ bidInfo: BidInfo) -> Void) {
        baseFetchDemand(completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func baseFetchDemand(completion: ((BidInfo) -> Void)?) {
        // The native request runs one bid request at a time. A second one would fail there,
        // and on its way it would reset the state the first one's timeout relies on.
        guard requestInFlight == nil else {
            Log.warn("\(String(describing: self)): the previous fetch has not completed yet.")
            completeWithResult(BidInfo(resultCode: .prebidSDKMisusePreviousFetchNotCompletedYet), completion: completion)
            return
        }
        
        mediationDelegate.cleanUpAdObject()
        
        requestInFlight = nativeAdUnit
        
        // Each fetch keeps its own completion here, so its result can't reach another fetch
        nativeAdUnit.fetchDemand { [weak self] bidInfo in
            guard let self = self else { return }
            
            self.requestInFlight = nil
            
            guard bidInfo.resultCode == .prebidDemandFetchSuccess else {
                self.completeWithResult(bidInfo, completion: completion)
                return
            }
            
            // When the bid can't be read back from the cache, nothing is attached to the ad object.
            // A response with bids but no designated winner gets here: it is reported as success,
            // but no bid was cached.
            let noBidInfo = BidInfo.create(resultCode: .prebidDemandNoBids, requestId: bidInfo.requestId)
            
            guard let kvResultDict = bidInfo.targetingKeywords,
                  let cacheId = kvResultDict[PrebidLocalCacheIdKey],
                  CacheManager.shared.isValid(cacheId: cacheId) else {
                      Log.error("\(String(describing: self)): no cache in kvResultDict.")
                      self.completeWithResult(noBidInfo, completion: completion)
                      return
                  }
            
            guard let bidString = CacheManager.shared.get(cacheId: cacheId) else {
                Log.error("\(String(describing: self)): no bid for given cache id.")
                self.completeWithResult(noBidInfo, completion: completion)
                return
            }
            
            guard var fetchDemandInfo = Utils.shared.getDictionaryFromString(bidString) else {
                Log.error("\(String(describing: self)): parsing bid string to bid dictionary failed.")
                self.completeWithResult(noBidInfo, completion: completion)
                return
            }
            
            fetchDemandInfo[PrebidLocalCacheIdKey] = cacheId as AnyObject
            
            let adObjectSetupDictionary: [String: Any] = [
                PBMMediationConfigIdKey: self.configID,
                PBMMediationTargetingInfoKey: kvResultDict,
                PBMMediationAdNativeResponseKey: fetchDemandInfo
            ]
        
            if self.mediationDelegate.setUpAdObject(with: adObjectSetupDictionary) {
                self.completeWithResult(bidInfo, completion: completion)
            } else {
                let newBidInfo = BidInfo.create(resultCode: .prebidWrongArguments, requestId: bidInfo.requestId)
                self.completeWithResult(newBidInfo, completion: completion)
            }
        }
    }
    
    private func completeWithResult(_ bidInfo: BidInfo, completion: ((BidInfo) -> Void)?) {
        guard let completion else {
            return
        }
        
        DispatchQueue.main.async {
            completion(bidInfo)
        }
    }
}
