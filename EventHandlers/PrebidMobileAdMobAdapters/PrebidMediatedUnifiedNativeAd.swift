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
import GoogleMobileAds

public class PrebidMediatedUnifiedNativeAd: NSObject {
    
    var nativeAd: NativeAd?
    var mappedImages = [GADNativeAdImage]()
    var mappedIcon: GADNativeAdImage?
    
    public init(nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        super.init()
        
        if let imageUrl = nativeAd.imageUrl {
            if case .success(let image) = ImageHelper.downloadImageSync(imageUrl) {
                mappedImages = [GADNativeAdImage(image: image)]
            }
        }
        
        if let iconUrl = nativeAd.iconUrl {
            if case .success(let icon) = ImageHelper.downloadImageSync(iconUrl) {
                mappedIcon = GADNativeAdImage(image: icon)
            }
        }
    }
}

extension PrebidMediatedUnifiedNativeAd: GADMediatedUnifiedNativeAd {
    public var headline: String? {
        nativeAd?.title
    }
    
    public var images: [GADNativeAdImage]? {
        mappedImages
    }
    
    public var body: String? {
        nativeAd?.desc
    }
    
    public var icon: GADNativeAdImage? {
        mappedIcon
    }
    
    public var callToAction: String? {
        nativeAd?.ctaText
    }
    
    public var starRating: NSDecimalNumber? {
        NSDecimalNumber(string: nativeAd?.dataObjects(of: .rating).first?.value)
    }
    
    public var store: String? {
        nil
    }
    
    public var price: String? {
        nativeAd?.dataObjects(of: .salePrice).first?.value
    }
    
    public var advertiser: String? {
        nativeAd?.sponsored
    }
    
    public var extraAssets: [String : Any]? {
        nil
    }
    
    public func didRender(in view: UIView, clickableAssetViews: [GADNativeAssetIdentifier : UIView], nonclickableAssetViews: [GADNativeAssetIdentifier : UIView], viewController: UIViewController) {
        nativeAd?.registerView(view: view, clickableViews: Array(clickableAssetViews.values))
    }
    
    public func didRecordClickOnAsset(withName assetName: GADNativeAssetIdentifier, view: UIView, viewController: UIViewController) {
        
    }
    
    public func didRecordImpression() {
        
    }
    
    public func didUntrackView(_ view: UIView?) {
    
    }
}
