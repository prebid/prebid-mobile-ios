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

extension PrebidMAXMediationAdapter: MAAdViewAdapter, DisplayViewLoadingDelegate, DisplayViewInteractionDelegate {

    public func loadAdViewAd(for parameters: MAAdapterResponseParameters, adFormat: MAAdFormat, andNotify delegate: MAAdViewAdapterDelegate) {
        bannerDelegate = delegate
        
        guard let keywords = parameters.localExtraParameters[PBMMediationTargetingInfoKey] as? [String: String] else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noKeywordsInLocalExtraParameters)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        guard let serverParameter = parameters.serverParameters[MAXCustomParametersKey] as? [String: String] else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noServerParameter)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        guard MAXUtils.isServerParameterInKeywordsDictionary(serverParameter, keywords) else {
            let error = MAAdapterError(nsError: MAXAdaptersError.wrongServerParameter)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        guard let bid = parameters.localExtraParameters[PBMMediationAdUnitBidKey] as? Bid else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noBidInLocalExtraParameters)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        guard let configId = parameters.localExtraParameters[PBMMediationConfigIdKey] as? String else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noConfigIdInLocalExtraParameters)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        viewControllerForModalPresentation = parameters.localExtraParameters[PBMVCForModalPresentationKey] as? UIViewController
        
        let frame = CGRect(origin: .zero, size: bid.size)
        
        displayView = PBMDisplayView(frame: frame, bid: bid, configId: configId)
        displayView?.interactionDelegate = self
        displayView?.loadingDelegate = self
        
        displayView?.displayAd()
    }
    
    public func displayViewDidLoadAd(_ displayView: PBMDisplayView) {
        bannerDelegate?.didLoadAd(forAdView: displayView)
    }
    
    public func displayView(_ displayView: PBMDisplayView, didFailWithError error: Error) {
        let maError = MAAdapterError(nsError: error)
        bannerDelegate?.didFailToLoadAdViewAdWithError(maError)
    }
    
    public func trackImpression(for displayView: PBMDisplayView) {
        
    }
    
    public func viewControllerForModalPresentation(from displayView: PBMDisplayView) -> UIViewController? {
        return viewControllerForModalPresentation
    }
    
    public func didLeaveApp(from displayView: PBMDisplayView) {
        
    }
    
    public func willPresentModal(from displayView: PBMDisplayView) {
        
    }
    
    public func didDismissModal(from displayView: PBMDisplayView) {
        bannerDelegate?.didHideAdViewAd()
    }
}