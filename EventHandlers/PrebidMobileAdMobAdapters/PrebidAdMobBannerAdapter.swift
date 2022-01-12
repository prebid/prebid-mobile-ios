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
    NSObject,
    GADCustomEventBanner,
    DisplayViewLoadingDelegate,
    DisplayViewInteractionDelegate {
    
    public var delegate: GADCustomEventBannerDelegate?
    
    public var displayView: PBMDisplayView?
    
    required public override init() {
        super.init()
    }
    
    
    public func requestAd(_ adSize: GADAdSize, parameter serverParameter: String?, label serverLabel: String?, request: GADCustomEventRequest) {
        
        guard let serverParameter = serverParameter else {
            let error = AdMobAdaptersError.noServerParameter
            delegate?.customEventBanner(self, didFailAd: error)
            return
        }
        
        guard let keywords = request.userKeywords as? [String] else {
            let error = AdMobAdaptersError.emptyCustomEventExtras
            delegate?.customEventBanner(self, didFailAd: error)
            return
        }
        
        guard AdMobUtils.isServerParameterInKeywords(serverParameter, keywords) else {
            let error = AdMobAdaptersError.wrongServerParameter
            delegate?.customEventBanner(self, didFailAd: error)
            return
        }
        
        guard let eventExtras = request.additionalParameters, !eventExtras.isEmpty else {
            let error = AdMobAdaptersError.emptyCustomEventExtras
            delegate?.customEventBanner(self, didFailAd: error)
            return
        }
        
        guard let bid = eventExtras[PBMMediationAdUnitBidKey] as? Bid else {
            let error = AdMobAdaptersError.noBidInEventExtras
            delegate?.customEventBanner(self, didFailAd: error)
            return
        }
        
        guard let configId = eventExtras[PBMMediationConfigIdKey] as? String else {
            let error = AdMobAdaptersError.noConfigIDInEventExtras
            delegate?.customEventBanner(self, didFailAd: error)
            return
        }
    
        let frame = CGRect(origin: .zero, size: bid.size)
        
        displayView = PBMDisplayView(frame: frame, bid: bid, configId: configId)
        displayView?.interactionDelegate = self
        displayView?.loadingDelegate = self
        
        displayView?.displayAd()
    }
    
    // MARK: - DisplayViewLoadingDelegate
    
    public func displayViewDidLoadAd(_ displayView: PBMDisplayView) {
        delegate?.customEventBanner(self, didReceiveAd: displayView)
    }
    
    
    public func displayView(_ displayView: PBMDisplayView, didFailWithError error: Error) {
        delegate?.customEventBanner(self, didFailAd: error)
    }
    
    // MARK: - PBMDisplayViewInteractionDelegate
    
    public func trackImpression(for displayView: PBMDisplayView) {
        //Impressions will be tracked automatically
        //unless enableAutomaticImpressionAndClickTracking = NO
    }
    
    public func viewControllerForModalPresentation(from displayView: PBMDisplayView) -> UIViewController? {
        return delegate?.viewControllerForPresentingModalView
    }
    
    public func didLeaveApp(from displayView: PBMDisplayView) {
        delegate?.customEventBannerWillLeaveApplication(self)
    }
    
    public func willPresentModal(from displayView: PBMDisplayView) {
        delegate?.customEventBannerWillPresentModal(self)
    }
    
    public func didDismissModal(from displayView: PBMDisplayView) {
        delegate?.customEventBannerWillDismissModal(self)
        delegate?.customEventBannerDidDismissModal(self)
    }
}
