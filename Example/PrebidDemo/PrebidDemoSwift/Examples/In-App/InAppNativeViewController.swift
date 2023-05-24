/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

fileprivate let nativeStoredImpression = "prebid-demo-banner-native-styles"

class InAppNativeViewController: NativeBaseViewController {
    
    // Prebid
    private var nativeUnit: NativeRequest!
    private var nativeAd: NativeAd?
    
    private var nativeRequestAssets: [NativeAsset] {
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 50, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        let body = NativeAssetData(type: DataAsset.description, required: true)
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
        
        return [title, icon, image, sponsored, body, cta]
    }
    
    private var eventTrackers: [NativeEventTracker] {
        [NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])]
    }

    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a NativeRequest
        nativeUnit = NativeRequest(configId: nativeStoredImpression, assets: nativeRequestAssets)
        
        // 2. Configure the NativeRequest
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        nativeUnit.eventtrackers = eventTrackers
        
        // 3. Make a bid request to Prebid Server
        nativeUnit.fetchDemand { [weak self] result, kvResultDict in
            PrebidDemoLogger.shared.info("Prebid demand fetch result \(result.name())")
            
            guard let self = self else {
                return
            }
            
            // 4. Find cached native ad
            guard let kvResultDict = kvResultDict, let cacheId = kvResultDict[PrebidLocalCacheIdKey] else {
                return
            }
            
            // 5. Create a NativeAd
            guard let nativeAd = NativeAd.create(cacheId: cacheId) else {
                return
            }
            
            self.nativeAd = nativeAd
            
            // 6. Render the native ad
            self.titleLabel.text = nativeAd.title
            self.bodyLabel.text = nativeAd.text
            
            if let iconString = nativeAd.iconUrl {
                ImageHelper.downloadImageAsync(iconString) { result in
                    if case let .success(icon) = result {
                        DispatchQueue.main.async {
                            self.iconView.image = icon
                        }
                    }
                }
            }
            
            if let imageString = nativeAd.imageUrl {
                ImageHelper.downloadImageAsync(imageString) { result in
                    if case let .success(image) = result {
                        DispatchQueue.main.async {
                            self.mainImageView.image = image
                        }
                    }
                }
            }
            
            self.callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
            self.sponsoredLabel.text = nativeAd.sponsoredBy
            
            self.nativeAd?.registerView(view: self.view, clickableViews: [self.callToActionButton])
        }
    }
}
