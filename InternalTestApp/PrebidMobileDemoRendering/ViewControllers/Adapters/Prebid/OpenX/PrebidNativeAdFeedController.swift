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
import PrebidMobile

class PrebidNativeAdFeedController: NSObject, PrebidConfigurableNativeAdRenderingController {
    var prebidConfigId = ""
    var nativeAdConfig = NativeAdConfiguration?.none

    var autoPlayOnVisible = true
    var showOnlyMediaView = false
    
    private var adLoadingAllowed = false
    private var onAdLoadingAllowed: (()->())?
    
    private var adUnit: NativeAdUnit?
    
    private weak var rootTableViewController: PrebidFeedTableViewController?
    
    required init(rootTableViewController: PrebidFeedTableViewController) {
        self.rootTableViewController = rootTableViewController
    }
    
    func configurationController() -> BaseConfigurationController? {
        return PrebidNativeAdRenderingConfigurationController(controller: self)
    }
    
    func allowLoadingAd() {
        adLoadingAllowed = true
        if let onAdLoadingAllowed = onAdLoadingAllowed {
            self.onAdLoadingAllowed = nil
            onAdLoadingAllowed()
        }
    }
    
    func createCells() {
        guard let tableView = self.rootTableViewController?.tableView else {
            return
        }
        
        self.rootTableViewController?.testCases = [
            TestCaseManager.createDummyTableCell(for: tableView),
            TestCaseManager.createDummyTableCell(for: tableView),
            TestCaseManager.createDummyTableCell(for: tableView),
            TestCaseManager.createDummyTableCell(for: tableView),
            
            TestCaseForTableCell(configurationClosureForTableCell: { [weak self, weak tableView] cell in
                guard let self = self else {
                    return
                }
                
                guard let adViewCell = tableView?.dequeueReusableCell(withIdentifier: "FeedAdTableViewCell") as? FeedAdTableViewCell else {
                    return
                }
                
                cell = adViewCell
                
                let onAdLoadingAllowed = { [weak self, weak adViewCell] in
                    if let self = self, let adViewCell = adViewCell {
                        self.loadAd(for: adViewCell)
                    }
                }
                
                if self.adLoadingAllowed {
                    onAdLoadingAllowed()
                } else {
                    self.onAdLoadingAllowed = onAdLoadingAllowed
                }
            }),
        ]
    }
    
    private func loadAd(for cell: FeedAdTableViewCell) {
        
        guard let nativeAdConfig = nativeAdConfig else {
            return
        }
        
        self.cleanUp(cell: cell)
        
        let adUnit = NativeAdUnit(configID: prebidConfigId, nativeAdConfiguration: nativeAdConfig)
        self.adUnit = adUnit
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        adUnit.fetchDemand { [weak self, weak cell] demandResponseInfo in
            guard let self = self else {
                return
            }
            guard demandResponseInfo.fetchDemandResult == .ok else {
                return
            }
            demandResponseInfo.getNativeAd { [weak self, weak cell] nativeAd in
                guard let self = self else {
                    return
                }

                guard let nativeAd = nativeAd else {
                    return
                }
                
                guard let cell = cell else {
                    return
                }
                
                cell.nativeAd = nativeAd // Note: RETAIN! or the tracking will not occur!
                nativeAd.uiDelegate = self
                
                let nativeAdViewBox = NativeAdViewBox()
                nativeAdViewBox.showOnlyMediaView = self.showOnlyMediaView
                nativeAdViewBox.mediaView.autoPlayOnVisible = self.autoPlayOnVisible
                nativeAdViewBox.renderNativeAd(nativeAd)
                nativeAdViewBox.registerViews(nativeAd)
                
                self.fillBannerArea(bannerView: cell.bannerView, nativeAdViewBox: nativeAdViewBox)
            }
        }
    }
    
    private func fillBannerArea(bannerView: UIView, nativeAdViewBox: NativeAdViewBox) {
        nativeAdViewBox.embedIntoView(bannerView)
        if let bannerParent = bannerView.superview, bannerParent.constraints.count < 3 {
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
    
    private func cleanUp(cell: FeedAdTableViewCell) {
        if cell.nativeAd != nil, let bannerView = cell.bannerView {
            cell.nativeAd = nil
            let bannerConstraints = bannerView.constraints
            bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
            bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
            
            let contentView = cell.bannerView.subviews.first
            contentView?.removeFromSuperview()
        }
    }
}

extension PrebidNativeAdFeedController: NativeAdUIDelegate {
    func viewPresentationControllerForNativeAd(_ nativeAd: PBRNativeAd) -> UIViewController? {
        return rootTableViewController
    }
}
