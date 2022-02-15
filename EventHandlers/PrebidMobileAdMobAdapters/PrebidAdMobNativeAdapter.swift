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
import GoogleMobileAds
import PrebidMobile

@objc(PrebidAdMobNativeAdapter)
public class PrebidAdMobNativeAdapter:
    NSObject,
    GADCustomEventNativeAd {
    
    public weak var delegate: GADCustomEventNativeAdDelegate?
    
    required public override init() {
        super.init()
    }
    
    public func request(withParameter serverParameter: String, request: GADCustomEventRequest, adTypes: [Any], options: [Any], rootViewController: UIViewController) {
        guard !serverParameter.isEmpty else {
            let error = AdMobAdaptersError.noServerParameter
            delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            return
        }
        
        guard let keywords = request.userKeywords as? [String] else {
            let error = AdMobAdaptersError.emptyUserKeywords
            delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            return
        }
        
        guard AdMobUtils.isServerParameterInKeywords(serverParameter, keywords) else {
            let error = AdMobAdaptersError.wrongServerParameter
            delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            return
        }
        
        guard let eventExtras = request.additionalParameters, !eventExtras.isEmpty else {
            let error = AdMobAdaptersError.emptyCustomEventExtras
            delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            return
        }
        
        AdMobMediationNativeUtils.findNative(eventExtras) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let ad):
                self.delegate?.customEventNativeAd(self, didReceive: ad)
            case .failure(let error):
                self.delegate?.customEventNativeAd(self, didFailToLoadWithError: error)
            }
        }
    }
    
    public func handlesUserClicks() -> Bool {
        return false
    }
    
    public func handlesUserImpressions() -> Bool {
        return false
    }
}
