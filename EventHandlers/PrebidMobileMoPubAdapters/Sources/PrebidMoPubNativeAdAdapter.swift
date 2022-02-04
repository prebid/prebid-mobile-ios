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

import PrebidMobile

@objc(PrebidMoPubNativeAdAdapter)
class PrebidMoPubNativeAdAdapter:
    NSObject,
    MPNativeAdAdapter,
    NativeAdEventDelegate {
    // MARK: - Public Properties
    
    weak var delegate: MPNativeAdAdapterDelegate?
    var nativeAd: NativeAd
    
    // MARK: - Public Methods
    
    init(nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        
        super.init()
        
        self.nativeAd.delegate = self
        
        properties[kAdTitleKey] = nativeAd.title
        properties[kAdTextKey] = nativeAd.desc
       
        let sponsored = nativeAd.sponsored
       
        properties[kAdSponsoredByCompanyKey] = sponsored
        properties[kAdCTATextKey] = nativeAd.ctaText
        
        if let iconUrl = nativeAd.iconUrl, !iconUrl.isEmpty {
            properties[kAdIconImageKey] = iconUrl
        }
        
        if let imageUrl = nativeAd.imageUrl, !imageUrl.isEmpty {
            properties[kAdMainImageKey] = imageUrl
        }

    }
    
    // MARK: - MPNativeAdAdapter
    
    var properties = [AnyHashable : Any]()
    
    var defaultActionURL: URL? {
        nil
    }
    
    func enableThirdPartyClickTracking() -> Bool {
        true
    }
    
    func mainMediaView() -> UIView? {
        nil
    }
    
    // MARK: - NativeAdEventDelegate
    
    func adDidExpire(ad: NativeAd) {
        
    }
    
    func adWasClicked(ad: NativeAd) {
        delegate?.nativeAdDidClick?(self)
    }
    
    func adDidLogImpression(ad: NativeAd) {
        delegate?.nativeAdWillLogImpression?(self)
    }
}
