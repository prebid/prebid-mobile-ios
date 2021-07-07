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

import UIKit

import GoogleMobileAds
import PrebidMobileRendering
import PrebidMobileGAMEventHandlers

class FeedGAMAdTableViewCell: UITableViewCell {
    @IBOutlet weak var bannerView: UIView!
    
    var gamCustomTemplateIDs: [String] = []
    
    private var adUnit: NativeAdUnit?
    private var theNativeAd: NativeAd?
    
    private let nativeAdViewBox = NativeAdViewBox()
    
    private var adLoader: GADAdLoader?
    
    private var customTemplateAd: GADCustomNativeAd?
    
    private weak var rootController: UIViewController?
    
    func loadAd(configID: String,
                nativeAdConfig: NativeAdConfiguration,
                GAMAdUnitID: String,
                rootViewController: UIViewController,
                adTypes: [GADAdLoaderAdType]) {
        
        self.rootController = rootViewController
        self.adUnit = NativeAdUnit(configID: configID, nativeAdConfiguration: nativeAdConfig)
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        adUnit?.fetchDemand { [weak self] demandResponseInfo in
            guard let self = self else {
                return
            }
            
            guard demandResponseInfo.fetchDemandResult == .ok else {
                return
            }
            
            let dfpRequest = GAMRequest()
            GAMUtils.shared.prepareRequest(dfpRequest, demandResponseInfo: demandResponseInfo)
            self.adLoader = GADAdLoader(adUnitID: GAMAdUnitID,
                                        rootViewController: rootViewController,
                                        adTypes: adTypes,
                                        options: [])
            self.adLoader?.delegate = self
            self.adLoader?.load(dfpRequest)
        }
    }
}

extension FeedGAMAdTableViewCell: GADCustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return gamCustomTemplateIDs
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive
                    nativeCustomTemplateAd: GADCustomNativeAd) {
        customTemplateAd = nil
        
        let nativeAdDetectionListener = NativeAdDetectionListener { [weak self] nativeAd in
            guard let self = self else {
                return
            }
            self.setupBanner()
            
            self.nativeAdViewBox.renderNativeAd(nativeAd)
            self.nativeAdViewBox.registerViews(nativeAd)
            self.theNativeAd = nativeAd // Note: RETAIN! or the tracking will not occur!
            nativeAd.uiDelegate = self
            self.customTemplateAd = nativeCustomTemplateAd
            nativeCustomTemplateAd.customClickHandler = { assetID in }
            nativeCustomTemplateAd.recordImpression()
        } onPrimaryAdWin: { [weak self] in
            guard let self = self else {
                return
            }
            self.nativeAdViewBox.renderCustomTemplateAd(nativeCustomTemplateAd)
            self.customTemplateAd = nativeCustomTemplateAd
            nativeCustomTemplateAd.recordImpression()
        } onNativeAdInvalid: { _ in

        }

        GAMUtils.shared.findCustomNativeAd(for: nativeCustomTemplateAd,
                                           nativeAdDetectionListener: nativeAdDetectionListener)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
    }
    
    private func setupBanner() {
        guard let bannerView = self.bannerView else {
            return
        }
        
        self.nativeAdViewBox.embedIntoView(self.bannerView)
        let bannerConstraints = bannerView.constraints
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
        if let bannerParent = bannerView.superview {
            bannerParent.addConstraints([
                NSLayoutConstraint(item: bannerView,
                                   attribute: .width,
                                   relatedBy: .lessThanOrEqual,
                                   toItem: bannerParent,
                                   attribute: .width,
                                   multiplier: 1,
                                   constant: -10),
            ])
        }
    }
}

extension FeedGAMAdTableViewCell: NativeAdUIDelegate {
    func viewPresentationControllerForNativeAd(_ nativeAd: NativeAd) -> UIViewController? {
        return rootController
    }
}
