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
    PrebidAdMobMediationBaseAdapter,
    GADMediationNativeAd,
    NativeAdEventDelegate {
    
    public var headline: String? {
        prebidNativeAd?.title
    }
    
    public var images: [GADNativeAdImage]?
    
    public var body: String? {
        prebidNativeAd?.text
    }
    
    public var icon: GADNativeAdImage?
    
    public var callToAction: String? {
        prebidNativeAd?.callToAction
    }
    
    public var starRating: NSDecimalNumber? {
        NSDecimalNumber(string: prebidNativeAd?.dataObjects(of: .rating).first?.value)
    }
    
    public var store: String?
    
    public var price: String? {
        prebidNativeAd?.dataObjects(of: .salePrice).first?.value
    }
    
    public var advertiser: String? {
        prebidNativeAd?.sponsoredBy
    }
    
    public var extraAssets: [String: Any]?
    
    var prebidNativeAd: NativeAd?
    
    public weak var delegate: GADMediationNativeAdEventDelegate?
    var completionHandler: GADMediationNativeLoadCompletionHandler?
    
    public func loadNativeAd(for adConfiguration: GADMediationNativeAdConfiguration, completionHandler: @escaping GADMediationNativeLoadCompletionHandler) {
        self.completionHandler = completionHandler
        
        guard let serverParameter = adConfiguration.credentials.settings["parameter"] as? String else {
            let error = AdMobAdaptersError.noServerParameter
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let eventExtras = adConfiguration.extras as? GADCustomEventExtras,
              let eventExtrasDictionary = eventExtras.extras(forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel),
              !eventExtrasDictionary.isEmpty else {
            let error = AdMobAdaptersError.emptyCustomEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let targetingInfo = eventExtrasDictionary[PBMMediationTargetingInfoKey] as? [String: String] else {
            let error = AdMobAdaptersError.noTargetingInfoInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        guard MediationUtils.isServerParameterInTargetingInfoDict(serverParameter, targetingInfo) else {
            let error = AdMobAdaptersError.wrongServerParameter
            delegate = completionHandler(nil, error)
            return
        }
        
        switch MediationNativeUtils.findNative(in: eventExtrasDictionary) {
        case .success(let nativeAd):
            prebidNativeAd = nativeAd
            prebidNativeAd?.delegate = self
            downloadImages { [weak self] in
                // Images are downloaded; native ad is ready to be displayed
                guard let self = self else { return }
                self.delegate = completionHandler(self, nil)
            }
        
        case .failure(let error):
            delegate?.didFailToPresentWithError(error)
        }
    }
    
    public func didRender(in view: UIView, clickableAssetViews: [GADNativeAssetIdentifier : UIView], nonclickableAssetViews: [GADNativeAssetIdentifier : UIView], viewController: UIViewController) {
        prebidNativeAd?.registerView(view: view, clickableViews: Array(clickableAssetViews.values))
    }
    
    public func handlesUserClicks() -> Bool {
        return false
    }
    
    public func handlesUserImpressions() -> Bool {
        return false
    }
    
    // MARK: - NativeAdEventDelegate
    
    public func adDidExpire(ad: NativeAd) {
        let error = AdMobAdaptersError.adExpired
        if let handler = completionHandler {
           delegate = handler(nil, error)
        }
    }
    
    public func adWasClicked(ad: NativeAd) {
        delegate?.reportClick()
    }
    
    public func adDidLogImpression(ad: NativeAd) {
        delegate?.reportImpression()
    }
    
    func downloadImages(completion: @escaping () -> Void) {
        guard let imageUrl = prebidNativeAd?.imageUrl, let iconUrl = prebidNativeAd?.iconUrl else { return }
        
        ImageHelper.downloadImageAsync(imageUrl) { [weak self] result in
            if case .success(let image) = result {
                self?.images = [GADNativeAdImage(image: image)]
            }
            
            ImageHelper.downloadImageAsync(iconUrl) { [weak self] result in
                if case .success(let image) = result {
                    self?.icon = GADNativeAdImage(image: image)
                    completion()
                }
            }
        }
    }
}
