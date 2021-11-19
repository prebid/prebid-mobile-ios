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
import MoPubSDK

import PrebidMobile
import PrebidMobileMoPubAdapters

class PrebidMoPubNativeAdFeedController: NSObject, PrebidConfigurableNativeAdCompatibleController {
    var prebidConfigId = ""
    var moPubAdUnitId = ""
    var nativeAdConfig = NativeAdConfiguration?.none
    var adRenderingViewClass: AnyClass?
    
    private var adUnit: MediationNativeAdUnit?
    private var theNativeAd: MPNativeAd?
    
    private var adLoadingAllowed = false
    private var onAdLoadingAllowed: (()->())?
    
    private weak var rootTableViewController: PrebidFeedTableViewController?
    
    private var adView = UIView()
    
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
                
                self.setUpBannerArea(bannerView: adViewCell.bannerView)
                
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
    
    private func setUpBannerArea(bannerView: UIView) {
        let bannerConstraints = bannerView.constraints
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
        if let bannerParent = bannerView.superview, bannerParent.constraints.count < 3 {
            
            let bannerHeightConstraint = bannerView.heightAnchor.constraint(equalToConstant: 160)
            bannerHeightConstraint.priority = .defaultLow
            let bannerWidthConstraint = NSLayoutConstraint(item: bannerView,
                                                       attribute: .width,
                                                       relatedBy: .lessThanOrEqual,
                                                       toItem: bannerParent,
                                                       attribute: .width,
                                                       multiplier: 1,
                                                       constant: -10)
            NSLayoutConstraint.activate([bannerWidthConstraint, bannerHeightConstraint])
        }
    }
    
    private func loadAd(for cell: FeedAdTableViewCell) {
        guard let nativeAdConfig = nativeAdConfig else {
            return
        }
        
        self.cleanUp(cell: cell)
        
        adUnit = MediationNativeAdUnit(configID: prebidConfigId, nativeAdConfiguration: nativeAdConfig)
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        let targeting = MPNativeAdRequestTargeting()
        
        adUnit?.fetchDemand(with: targeting!) { [weak self] result in
            guard let self = self else {
                return
            }
        
            let settings = MPStaticNativeAdRendererSettings();
            settings.renderingViewClass = self.adRenderingViewClass
            let prebidConfig = PrebidMoPubNativeAdRenderer.rendererConfiguration(with: settings);
            let mopubConfig = MPStaticNativeAdRenderer.rendererConfiguration(with: settings);
            
            let adRequest = MPNativeAdRequest.init(adUnitIdentifier: self.moPubAdUnitId,
                                                   rendererConfigurations: [prebidConfig, mopubConfig!])
            adRequest?.targeting = targeting
            
            adRequest?.start { [weak self, weak cell] _, response , error in
                guard let self = self else {
                    return
                }
                
                guard error == nil else {
                    return
                }
                
                guard let nativeAd = response else {
                    return
                }
                
                self.setupNativeAd(nativeAd, for: cell)
            }
        }
    }
    
    private func cleanUp(cell: FeedAdTableViewCell) {
        let contentView = cell.bannerView.subviews.first
        contentView?.removeFromSuperview()
    }
    
    private func setupNativeAd(_ nativeAd: MPNativeAd, for cell: FeedAdTableViewCell?) {
        self.theNativeAd = nativeAd
        self.theNativeAd?.delegate = self
        
        guard let bannerView = cell?.bannerView else {
            return
        }
        
        guard let adView = try? nativeAd.retrieveAdView(), let pbmAdView = adView.subviews.first else {
            return
        }
        
        cell?.adView = adView
        
        adView.addConstraints([
            adView.widthAnchor.constraint(equalTo: pbmAdView.widthAnchor),
            adView.heightAnchor.constraint(equalTo: pbmAdView.heightAnchor),
        ])
        adView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(adView)
        bannerView.addConstraints([
            bannerView.widthAnchor.constraint(equalTo: adView.widthAnchor),
            bannerView.heightAnchor.constraint(equalTo: adView.heightAnchor),
        ])
    }
}

extension PrebidMoPubNativeAdFeedController: NativeAdUIDelegate {
    func viewPresentationControllerForNativeAd(_ nativeAd: PBRNativeAd) -> UIViewController? {
        return rootTableViewController
    }
}

extension PrebidMoPubNativeAdFeedController: MPNativeAdDelegate {
    func viewControllerForPresentingModalView() -> UIViewController! {
        return rootTableViewController
    }
}
