/*   Copyright 2018-2019 Prebid.org, Inc.

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

/// A class representing a banner ad unit for original type of integration.
public class BannerAdUnit: AdUnit, BannerBasedAdUnitProtocol, VideoBasedAdUnitProtocol {
    
    /// The banner ad parameters used to configure the ad unit.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
        set { adUnitConfig.adConfiguration.bannerParameters = newValue }
    }
    
    /// The video ad parameters used to configure the ad unit.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }
    
    /// The set of ad formats for the ad unit.
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    /// Initializes a new `BannerAdUnit` with the specified configuration ID and size.
    /// - Parameters:
    ///   - configId: The unique identifier for the ad unit configuration.
    ///   - size: The size of the banner ad unit.
    public init(configId: String, size: CGSize) {
        super.init(configId: configId, size: size, adFormats: [.banner])
    }

    /// Adds additional sizes to the banner ad unit's configuration.
    /// - Parameter sizes: An array of `CGSize` objects representing additional sizes.
    public func addAdditionalSize(sizes: [CGSize]) {
        if super.adUnitConfig.additionalSizes == nil {
            super.adUnitConfig.additionalSizes = [CGSize]()
        }
        
        super.adUnitConfig.additionalSizes?.append(contentsOf: sizes)
    }
    
    // MARK: Prebid Impression Tracking
    
    /// Sets the view in which Prebid will start tracking an impression.
    /// - Parameters:
    ///   - adView: The ad view that contains ad creative(f.e. GAMBannerView). This object will be used later for tracking `burl`.
    public func activatePrebidImpressionTracker(adView: UIView) {
        impressionTracker.start(in: adView)
    }
    
    // MARK: SKAdNetwork
    
    /// Activates Prebid's SKAdNetwork StoreKit ads flow for the provided ad view.
    ///
    /// Ensure this method is called within the Google Mobile Ads ad received method
    /// (e.g., in the GADBannerViewDelegate's `bannerViewDidReceiveAd` or similar callbacks).
    ///
    /// This feature is not available for video ads.
    ///
    /// - Parameters:
    ///   - adView: The ad view that contains ad creative(f.e. GAMBannerView).
    public func activatePrebidSKAdNetworkStoreKitAdsFlow(adView: UIView) {
        guard !adFormats.contains(.video) else {
            Log.warn("SKAdNetwork StoreKit ads flow is not supported for video ads.")
            return
        }
        
        skadnStoreKitAdsHelper.start(in: adView)
    }
}
