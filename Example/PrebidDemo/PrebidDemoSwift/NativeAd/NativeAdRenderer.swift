/*   Copyright 2018-2021 Prebid.org, Inc.
 
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

import UIKit
import PrebidMobile
import GoogleMobileAds

public class NativeAdRenderer: NSObject {
    
    public var nativeAdView: NativeAdView!
    
    public init(size: CGSize) {
        super.init()
        let adNib = UINib(nibName: "NativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let nativeAdView = array.first as? NativeAdView {
            self.nativeAdView = nativeAdView
            nativeAdView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
    }
    
    public func renderNativeInAppAd(with nativeAd: NativeAd) {
        nativeAdView.titleLabel.text = nativeAd.title
        nativeAdView.bodyLabel.text = nativeAd.text
        
        if let iconString = nativeAd.iconUrl {
            ImageHelper.downloadImageAsync(iconString) { result in
                if case let .success(icon) = result {
                    DispatchQueue.main.async {
                        self.nativeAdView.iconImageView.image = icon
                    }
                }
            }
        }
        
        if let imageString = nativeAd.imageUrl {
            ImageHelper.downloadImageAsync(imageString) { result in
                if case let .success(image) = result {
                    DispatchQueue.main.async {
                        self.nativeAdView.mainImageView.image = image
                    }
                }
            }
        }
        
        nativeAdView.callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.sponsoredLabel.text = nativeAd.sponsoredBy
        
        nativeAd.registerView(view: nativeAdView, clickableViews: [nativeAdView.callToActionButton])
    }
    
    public func renderCustomTemplateAd(with customTemplateAd: GADCustomNativeAd) {
        nativeAdView.titleLabel.text = customTemplateAd.string(forKey: "title")
        nativeAdView.bodyLabel.text = customTemplateAd.string(forKey: "text")
        
        nativeAdView.callToActionButton.setTitle(customTemplateAd.string(forKey: "cta"), for: .normal)
        nativeAdView.sponsoredLabel.text = customTemplateAd.string(forKey: "sponsoredBy")
        
        if let imageString = customTemplateAd.string(forKey: "imgUrl") {
            ImageHelper.downloadImageAsync(imageString) { result in
                if case let .success(image) = result {
                    DispatchQueue.main.async {
                        self.nativeAdView.mainImageView.image = image
                    }
                }
            }
        }
        
        if let iconString = customTemplateAd.string(forKey: "iconUrl") {
            ImageHelper.downloadImageAsync(iconString) { result in
                if case let .success(icon) = result {
                    DispatchQueue.main.async {
                        self.nativeAdView.iconImageView.image = icon
                    }
                }
            }
        }
     }
    
    public func renderGADNativeAd(with gadAd: GADNativeAd) {
        nativeAdView.titleLabel.text = gadAd.headline
        nativeAdView.bodyLabel.text = gadAd.body
        
        nativeAdView.callToActionButton.setTitle(gadAd.callToAction ?? "", for: .normal)
        nativeAdView.sponsoredLabel.text = gadAd.advertiser
        
        if let adIcon = gadAd.icon {
            self.nativeAdView.iconImageView.image = adIcon.image
        }
        
        if let adImage = gadAd.images?.first {
            self.nativeAdView.mainImageView.image = adImage.image
        }

        nativeAdView.bodyLabel.numberOfLines = 0
    }
}
