//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation
import UIKit

@objc(PBMAdViewManagerDelegate)
public
protocol AdViewManagerDelegate: NSObjectProtocol {
    func viewControllerForModalPresentation() -> UIViewController?
    
    func adLoaded(_ adDetails: AdDetails)
    func failedToLoad(_ error: Error)
    
    func adDidComplete()
    func adDidDisplay()
    
    func adWasClicked()
    func adViewWasClicked()
    
    func adDidExpand()
    func adDidCollapse()
    
    func adDidLeaveApp()
    
    func adClickthroughDidClose()
    
    func adDidClose()
    
    //Only used by BannerView & PBMVideoAdView
    // The actual top layer view that displays the ad
    @objc optional var displayView: UIView { get}
    
    //Only used by PBMVideoAdView, PBMDisplayView, PBMInterstitialController
    //Note: all of them seem to simply return a new object.
    //TODO: Verify whether the instantiation of an object should be inside the delegate.
    @objc optional var interstitialDisplayProperties: InterstitialDisplayProperties { get }
    
    @objc optional func videoAdDidFinish()
    @objc optional func videoAdWasMuted()
    @objc optional func videoAdWasUnmuted()
    
    // Used only for rewarded API
    @objc optional func adDidSendRewardedEvent()
    
}
