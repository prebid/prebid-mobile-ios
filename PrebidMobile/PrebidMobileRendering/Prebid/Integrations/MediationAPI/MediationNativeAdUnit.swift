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

class MediationNativeAdUnit : NSObject {
    
    weak var adObject: NSObject?
    var completion: ((FetchDemandResult) -> Void)?
    var nativeAdUnit: NativeAdUnit
    
    let mediationDelegate: PrebidMediationDelegate
    
    // MARK: - Public Properties
    
    var configID: String {
        nativeAdUnit.configId
    }
    
    var nativeAdConfiguration: NativeAdConfiguration {
        nativeAdUnit.nativeAdConfig
    }
    
    // MARK: - Public Methods
    
    convenience public init(configID: String,
                            nativeAdConfiguration: NativeAdConfiguration, mediationDelegate: PrebidMediationDelegate) {
        self.init(nativeAdUnit: NativeAdUnit(configID: configID,
                                             nativeAdConfiguration: nativeAdConfiguration), mediationDelegate: mediationDelegate)
    }
    
    public func fetchDemand(with adObject: NSObject,
                            completion: ((FetchDemandResult)->Void)?) {
        
        if !mediationDelegate.isCorrectAdObject(adObject) {
            completion?(.wrongArguments)
            return
        }
        
        self.completion = completion
        self.adObject = adObject
        
        mediationDelegate.cleanUpAdObject(adObject)
        
        nativeAdUnit.fetchDemand { [weak self] fetchDemandInfo in
            guard let self = self else {
                return
            }
            
            if fetchDemandInfo.fetchDemandResult != .ok {
                self.completeWithResult(fetchDemandInfo.fetchDemandResult)
                return
            }
            
            var fetchDemandResult: FetchDemandResult = .wrongArguments
            
            if self.mediationDelegate.setUpAdObject(adObject,
                                                    configID: self.configID,
                                                    targetingInfo: fetchDemandInfo.bid?.targetingInfo ?? [:],
                                                    extraObject: fetchDemandInfo,
                                                    forKey: PBMMediationAdUnitBidKey) {
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
    init(nativeAdUnit: NativeAdUnit, mediationDelegate: PrebidMediationDelegate) {
        self.nativeAdUnit = nativeAdUnit
        self.mediationDelegate = mediationDelegate
    }
    
    private func completeWithResult(_ fetchDemandResult: FetchDemandResult) {
        guard let completion = self.completion else {
            return
        }
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
    
}
