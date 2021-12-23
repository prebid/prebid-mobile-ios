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
    
    let adUnitConfig: AdUnitConfig
    
    public var configId: String {
        adUnitConfig.configID
    }
    
    var bidRequester: PBMBidRequester?
    
    var completion: ((FetchDemandResult) -> Void)?
    
    let mediationDelegate: PrebidMediationDelegate
    
    init(configId: String, mediationDelegate: PrebidMediationDelegate) {
        self.mediationDelegate = mediationDelegate
        adUnitConfig = AdUnitConfig(configID: configId)
        adUnitConfig.isInterstitial = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.videoPlacementType = .sliderOrFloating
    }
    
    public func fetchDemand(completion: ((FetchDemandResult)->Void)?) {
        fetchDemand(connection: PBMServerConnection.shared,
                    sdkConfiguration: PrebidRenderingConfig.shared,
                    targeting: PrebidRenderingTargeting.shared,
                    completion: completion)
    }
    
    // MARK: - Context Data
    
    public func addContextData(_ data: String, forKey key: String) {
        adUnitConfig.addContextData(data, forKey: key)
    }
    
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        adUnitConfig.updateContextData(data, forKey: key)
    }
    
    public func removeContextDate(forKey key: String) {
        adUnitConfig.removeContextData(forKey: key)
    }
    
    public func clearContextData() {
        adUnitConfig.clearContextData()
    }
    
    // MARK: - Internal Methods
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(connection: PBMServerConnectionProtocol,
                     sdkConfiguration: PrebidRenderingConfig,
                     targeting: PrebidRenderingTargeting,
                     completion: ((FetchDemandResult)->Void)?) {
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
    
    private func handleBidResponse(_ bidResponse: BidResponseForRendering) {
        var demandResult = FetchDemandResult.demandNoBids
        
        if let winningBid = bidResponse.winningBid,
           let targetingInfo = winningBid.targetingInfo {
            
            if mediationDelegate.setUpAdObject(configId: configId,
                                               configIdKey: PBMMediationConfigIdKey,
                                               targetingInfo: targetingInfo,
                                               extrasObject: winningBid,
                                               extrasObjectKey: PBMMediationAdUnitBidKey) {
                demandResult = .ok
            } else {
                demandResult = .wrongArguments
            }
            
        } else {
            PBMLog.error("The winning bid is absent in response!")
        }
        
        completeWithResult(demandResult)
    }
    
    private func handleBidRequestError(_ error: Error?) {
        completeWithResult(PBMError.demandResult(from: error))
    }
    
    private func completeWithResult(_ demandResult: FetchDemandResult) {
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
