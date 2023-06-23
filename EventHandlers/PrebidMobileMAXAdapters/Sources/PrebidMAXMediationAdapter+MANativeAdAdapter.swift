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
import PrebidMobile
import AppLovinSDK

extension PrebidMAXMediationAdapter: MANativeAdAdapter, NativeAdEventDelegate {
    
    public func loadNativeAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MANativeAdAdapterDelegate) {
        nativeDelegate = delegate
        
        guard let serverParameter = parameters.serverParameters[MAXCustomParametersKey] as? [String: String] else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noServerParameter)
            nativeDelegate?.didFailToLoadNativeAdWithError(error)
            return
        }
                
        guard let targetingInfo = parameters.localExtraParameters[PBMMediationTargetingInfoKey] as? [String: String] else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noTargetingInfoInBid)
            nativeDelegate?.didFailToLoadNativeAdWithError(error)
            return
        }
        
        guard MediationUtils.isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo) else {
            let error = MAAdapterError(nsError: MAXAdaptersError.wrongServerParameter)
            nativeDelegate?.didFailToLoadNativeAdWithError(error)
            return
        }
        
        // PrebidMAUnifiedNativeAd should be instantiated only in main thread
        DispatchQueue.main.async {
            switch MAXUtils.findNative(parameters.localExtraParameters) {

            case .success(let prebidNativeAd):
                prebidNativeAd.nativeAd.delegate = self
                self.nativeDelegate?.didLoadAd(for: prebidNativeAd, withExtraInfo: nil)
            case .failure(let error):
                self.nativeDelegate?.didFailToLoadNativeAdWithError(MAAdapterError(nsError: error))
            }
        }
    }
    
    public func adDidExpire(ad: NativeAd) {
        
    }
    
    public func adWasClicked(ad: NativeAd) {
        nativeDelegate?.didClickNativeAd()
    }
    
    public func adDidLogImpression(ad: NativeAd) {
        nativeDelegate?.didDisplayNativeAd(withExtraInfo: nil)
    }
}
