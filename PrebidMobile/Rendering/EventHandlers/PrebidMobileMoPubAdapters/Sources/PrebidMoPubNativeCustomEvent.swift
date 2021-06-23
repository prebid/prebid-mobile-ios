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

import MoPubSDK

//import PrebidMobile
import PrebidMobile

// @objc is required for instantiating in the MoPub SDK
@objc(PrebidMoPubNativeCustomEvent)
public class PrebidMoPubNativeCustomEvent : MPNativeCustomEvent {
    
    // MARK: MPNativeCustomEvent
    
    public override func requestAd(withCustomEventInfo info: [AnyHashable : Any]!, adMarkup: String!) {
        
        if localExtras.count == 0 {
            let error = MoPubAdaptersError.emptyLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: String(describing: PrebidMoPubNativeCustomEvent.self), error: error), source: nil, from: nil)
            delegate.nativeCustomEvent(self, didFailToLoadAdWithError: error)
            return
        }
        
        MoPubUtils.findNativeAd(localExtras) { [weak self] (ad, error) in
            if let nativeAd = ad {
                self?.nativeAdDidLoad(nativeAd)
            } else {
                let error = error ?? MoPubAdaptersError.unknown
                
                MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: String(describing: PrebidMoPubNativeCustomEvent.self), error: error), source: nil, from: nil)
                self?.delegate.nativeCustomEvent(self, didFailToLoadAdWithError: error)
            }
        }
    }
    
    // MARK: Private Methods
    
    func nativeAdDidLoad(_ nativeAd: NativeAd) {
        
        let adAdapter = PrebidMoPubNativeAdAdapter(nativeAd: nativeAd)
        let interfaceAd = MPNativeAd(adAdapter: adAdapter)
        
        MPLogging.logEvent(MPLogEvent.adLoadSuccess(forAdapter: String(describing: PrebidMoPubNativeCustomEvent.self)), source: nil, from: nil)
        
        delegate.nativeCustomEvent(self, didLoad: interfaceAd)
    }
}
