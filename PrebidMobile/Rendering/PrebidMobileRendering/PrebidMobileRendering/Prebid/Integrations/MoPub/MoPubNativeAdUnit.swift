//
//  MoPubNativeAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class MoPubNativeAdUnit : NSObject {
    
    weak var adObject: NSObject?
    var completion: ((PBMFetchDemandResult) -> Void)?
    var nativeAdUnit: NativeAdUnit
    
    // MARK: - Public Properties
    
    var configID: String {
        nativeAdUnit.configId
    }
    
    var nativeAdConfiguration: NativeAdConfiguration {
        nativeAdUnit.nativeAdConfig
    }
    
    // MARK: - Public Methods
    
    convenience public init(configID: String,
                nativeAdConfiguration: NativeAdConfiguration) {
        self.init(nativeAdUnit: NativeAdUnit(configID: configID,
                                       nativeAdConfiguration: nativeAdConfiguration))
    }
    
    public func fetchDemand(with adObject: NSObject,
                            completion: ((PBMFetchDemandResult)->Void)?) {
        
        if !MoPubUtils.isCorrectAdObject(adObject) {
            completion?(.wrongArguments)
            return
        }
        
        self.completion = completion
        self.adObject = adObject
        
        MoPubUtils.cleanUpAdObject(adObject)
        
        nativeAdUnit.fetchDemand { [weak self] fetchDemandInfo in
            guard let self = self else {
                return
            }
            
            if fetchDemandInfo.fetchDemandResult != .ok {
                self.completeWithResult(fetchDemandInfo.fetchDemandResult)
                return
            }
            
            var fetchDemandResult: PBMFetchDemandResult = .wrongArguments
            
            if MoPubUtils.setUpAdObject(adObject,
                                        configID: self.configID,
                                        targetingInfo: fetchDemandInfo.bid?.targetingInfo ?? [:],
                                        extraObject: fetchDemandInfo,
                                        forKey: PBMMoPubAdNativeResponseKey) {
                fetchDemandResult = .ok
            }
            
            self.completeWithResult(fetchDemandResult)
        }
    }
    
    // MARK: - Context Data

    public func addContextData(_ data: String, forKey key: String) {
        nativeAdUnit.addContextData(data, forKey: key)
    }
    
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        nativeAdUnit.updateContextData(data, forKey: key)
    }
    
    public func removeContextDate(forKey key: String) {
        nativeAdUnit.removeContextData(forKey: key)
    }
    
    public func clearContextData() {
        nativeAdUnit.clearContextData()
    }
    
    // MARK: - Private Methods
    
    // NOTE: do not use `private` to expose this method to unit tests
    init(nativeAdUnit: NativeAdUnit) {
        self.nativeAdUnit = nativeAdUnit
    }
    
    private func completeWithResult(_ fetchDemandResult: PBMFetchDemandResult) {
        guard let completion = self.completion else {
            return
        }
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
    
}
