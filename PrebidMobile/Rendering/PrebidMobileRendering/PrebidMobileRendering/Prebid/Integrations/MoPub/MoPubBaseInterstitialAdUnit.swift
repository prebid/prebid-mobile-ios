//
//  MoPubBaseInterstitialAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class MoPubBaseInterstitialAdUnit : NSObject {
    
    let adUnitConfig: AdUnitConfig
    
    public var configId: String {
        adUnitConfig.configID
    }
    
    var bidRequester: PBMBidRequester?
    
    var adObject: NSObject?
    var completion: ((FetchDemandResult) -> Void)?
    
    init(configId: String) {
        
        adUnitConfig = AdUnitConfig(configID: configId)
        adUnitConfig.isInterstitial = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.videoPlacementType = .sliderOrFloating
    }
    
    public func fetchDemand(with adObject: NSObject,
                            completion: ((FetchDemandResult)->Void)?) {
        
        fetchDemand(with: adObject,
                    connection: PBMServerConnection.singleton(),
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
    func fetchDemand(with adObject: NSObject,
                             connection: PBMServerConnectionProtocol,
                             sdkConfiguration: PrebidRenderingConfig,
                             targeting: PrebidRenderingTargeting,
                             completion: ((FetchDemandResult)->Void)?) {
        guard bidRequester == nil else {
            // Request in progress
            return
        }
        
        if !MoPubUtils.isCorrectAdObject(adObject) {
            completion?(.wrongArguments)
            return
        }
        
        self.adObject = adObject
        self.completion = completion
        
        MoPubUtils.cleanUpAdObject(adObject)
        
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
        var demandResult = FetchDemandResult.demandNoBids
        
        if let adObject = self.adObject,
           let winningBid = bidResponse.winningBid,
           let targetingInfo = winningBid.targetingInfo {
            
            if MoPubUtils.setUpAdObject(adObject,
                                        configID: configId,
                                        targetingInfo: targetingInfo,
                                        extraObject: winningBid,
                                        forKey: PBMMoPubAdUnitBidKey) {
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
        adObject = nil
        completion = nil
        bidRequester = nil
    }
}
