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
    
import UIKit

@objc(PBMInterstitialAd)
public protocol InterstitialAd: PrimaryAdRequesterProtocol {
    /**
     @abstract Return whether an interstitial is ready for display
     */
    var isReady: Bool { get }
    
    /**
     @abstract PBM SDK calls this method to show the interstitial ad from the ad server SDK
     @param controller view controller to be used for presenting the interstitial ad
     */
    @objc(showFromViewController:)
    func show(from viewController: UIViewController?)
    
    /**
     @abstract Called by PBM SDK to notify primary ad server.
     */
    @objc optional func trackImpression()
}
