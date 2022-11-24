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

@objcMembers
public class PrebidMAUnifiedNativeAd: MANativeAd {
    
    public var nativeAd: NativeAd
    
    public init(nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        
        super.init(format: .native) { builder in
            builder.title = nativeAd.title ?? ""
            builder.advertiser = nativeAd.sponsoredBy
            builder.body = nativeAd.text
            builder.callToAction = nativeAd.callToAction
            
            if let iconUrlString = nativeAd.iconUrl {
                if let iconURL = URL(string: iconUrlString) {
                    builder.icon = MANativeAdImage(url: iconURL)
                }
            }
            
            if let imageUrlString = nativeAd.imageUrl {
                if let imageUrl = URL(string: imageUrlString) {
                    builder.mainImage = MANativeAdImage(url: imageUrl)
                }
            }
        }
    }
    
    public override func prepare(forInteractionClickableViews clickableViews: [UIView], withContainer container: UIView) -> Bool {
        super.prepare(forInteractionClickableViews: clickableViews, withContainer: container)
        nativeAd.registerView(view: container, clickableViews: clickableViews)
        
        return true
    }
}
