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

@objc(PrebidAdMobBannerAdapter)
public class PrebidAdMobBannerAdapter:
    PrebidAdMobMediationBaseAdapter,
    GADMediationBannerAd,
    DisplayViewLoadingDelegate,
    DisplayViewInteractionDelegate {
    
    public var view: UIView {
        return displayView ?? UIView()
    }
    
    var displayView: PBMDisplayView?
    
    weak var delegate: GADMediationBannerAdEventDelegate?
    var adConfiguration: GADMediationBannerAdConfiguration?
    var completionHandler: GADMediationBannerLoadCompletionHandler?
    
    public func loadBanner(for adConfiguration: GADMediationBannerAdConfiguration,
                           completionHandler: @escaping GADMediationBannerLoadCompletionHandler) {
        self.adConfiguration = adConfiguration
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
        
        guard let bid = eventExtrasDictionary[PBMMediationAdUnitBidKey] as? Bid else {
            let error = AdMobAdaptersError.noBidInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let configId = eventExtrasDictionary[PBMMediationConfigIdKey] as? String else {
            let error = AdMobAdaptersError.noConfigIDInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        let frame = CGRect(origin: .zero, size: bid.size)
        
        displayView = PBMDisplayView(frame: frame, bid: bid, configId: configId)
        displayView?.interactionDelegate = self
        displayView?.loadingDelegate = self
        
        displayView?.loadAd()
    }
    
    // MARK: - DisplayViewLoadingDelegate
    
    public func displayViewDidLoadAd(_ displayViewManager: UIView) {
        if let handler = completionHandler {
            delegate = handler(self, nil)
        }
    }
    
    public func displayView(_ displayViewManager: UIView, didFailWithError error: Error) {
        if let handler = completionHandler {
            delegate = handler(nil, error)
        }
    }
    
    // MARK: - PBMDisplayViewInteractionDelegate
    
    public func trackImpression(forDisplayView: UIView) {
        delegate?.reportImpression()
    }
    
    public func viewControllerForModalPresentation(fromDisplayView: UIView) -> UIViewController? {
        return adConfiguration?.topViewController ?? UIApplication.shared.windows.first?.rootViewController
    }
    
    public func didLeaveApp(from displayView: UIView) {
        delegate?.reportClick()
    }
    
    public func willPresentModal(from displayView: UIView) {
        delegate?.willPresentFullScreenView()
    }
    
    public func didDismissModal(from displayView: UIView) {
        delegate?.willDismissFullScreenView()
        delegate?.didDismissFullScreenView()
    }
}
