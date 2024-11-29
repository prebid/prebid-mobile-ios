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

extension PrebidMAXMediationAdapter:
    MAAdViewAdapter,
    DisplayViewLoadingDelegate,
    DisplayViewInteractionDelegate {
    
    // MARK: - MAAdViewAdapter

    public func loadAdViewAd(for parameters: MAAdapterResponseParameters, adFormat: MAAdFormat, andNotify delegate: MAAdViewAdapterDelegate) {
        bannerDelegate = delegate
        
        guard let serverParameter = parameters.serverParameters[MAXCustomParametersKey] as? [String: String] else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noServerParameter)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
                
        guard let bid = parameters.localExtraParameters[PBMMediationAdUnitBidKey] as? Bid else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noBidInLocalExtraParameters)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        guard let targetingInfo = bid.targetingInfo else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noTargetingInfoInBid)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        guard MediationUtils.isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo) else {
            let error = MAAdapterError(nsError: MAXAdaptersError.wrongServerParameter)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        guard let configId = parameters.localExtraParameters[PBMMediationConfigIdKey] as? String else {
            let error = MAAdapterError(nsError: MAXAdaptersError.noConfigIdInLocalExtraParameters)
            bannerDelegate?.didFailToLoadAdViewAdWithError(error)
            return
        }
        
        let frame = CGRect(origin: .zero, size: bid.size)
        displayView = PBMDisplayView(frame: frame, bid: bid, configId: configId)
        displayView?.interactionDelegate = self
        displayView?.loadingDelegate = self
        
        displayView?.loadAd()
    }
    
    // MARK: - DisplayViewLoadingDelegate
    
    public func displayViewDidLoadAd(_ displayView: UIView) {
        bannerDelegate?.didLoadAd(forAdView: displayView)
    }
    
    public func displayView(_ displayView: UIView, didFailWithError error: Error) {
        let maError = MAAdapterError(nsError: error)
        bannerDelegate?.didFailToLoadAdViewAdWithError(maError)
    }
    
    // MARK: DisplayViewInteractionDelegate
    
    public func viewControllerForModalPresentation(fromDisplayView: UIView) -> UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
    
    public func willPresentModal(from displayView: UIView) {
        bannerDelegate?.didClickAdViewAd()
        bannerDelegate?.didExpandAdViewAd()
    }
    
    public func didDismissModal(from displayView: UIView) {
        bannerDelegate?.didHideAdViewAd()
        bannerDelegate?.didCollapseAdViewAd()
    }
    
    public func trackImpression(forDisplayView: UIView) {}
    public func didLeaveApp(from displayView: UIView) {}
}
