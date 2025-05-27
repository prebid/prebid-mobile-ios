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

/// Represents an interstitial ad unit built for original type of integration.
public class InterstitialAdUnit: AdUnit, BannerBasedAdUnitProtocol, VideoBasedAdUnitProtocol {
    
    /// The banner parameters for this ad unit.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
        set { adUnitConfig.adConfiguration.bannerParameters = newValue }
    }
    
    /// The video parameters for this ad unit.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }
    
    /// The ad formats for the ad unit.
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    // MARK: - SKAdNetwork
    
    /// A flag that determines whether SKOverlay should be supported
    public var supportSKOverlay: Bool {
        get { adUnitConfig.adConfiguration.supportSKOverlay }
        set { adUnitConfig.adConfiguration.supportSKOverlay = newValue }
    }
    
    private var skOverlayManager: SKOverlayInterstitialManager?
    
    /// Initializes a new interstitial ad unit with a unique configuration identifier.
    /// - Parameter configId: The unique identifier for the ad unit configuration.
    public init(configId: String) {
        super.init(configId: configId, size: nil, adFormats: [.banner])
        
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adConfiguration.videoParameters.placement = .Interstitial
        adUnitConfig.adConfiguration.videoParameters.plcmnt = .Interstitial
    }
    
    deinit {
        dismissSKOverlayIfAvailable()
    }
    
    /// Initializes a new interstitial ad unit with a minimum width and height percentage.
    /// - Parameter configId: The unique identifier for the ad unit configuration.
    /// - Parameter minWidthPerc: The minimum width percentage of the ad.
    /// - Parameter minHeightPerc: The minimum height percentage of the ad.
    public convenience init(configId: String, minWidthPerc: Int, minHeightPerc: Int) {
        self.init(configId: configId)
        adUnitConfig.minSizePerc = NSValue(cgSize: CGSize(width: minWidthPerc, height: minHeightPerc))
    }
    
    // MARK: Prebid Impression Tracking
    
    /// Sets the view in which Prebid will start tracking an impression.
    public func activatePrebidImpressionTracker() {
        if let window = UIWindow.firstKeyWindow {
            impressionTracker.start(in: window)
        }
    }
    
    // MARK: SKAdNetwork
    
    /// Activates Prebid's SKAdNetwork StoreKit ads flow.
    ///
    /// Ensure this method is called before presenting interstitials.
    ///
    /// This feature is not available for video ads.
    public func activatePrebidSKAdNetworkStoreKitAdsFlow() {
        guard !adFormats.contains(.video) else {
            Log.warn("SKAdNetwork StoreKit ads flow is not supported for video ads.")
            return
        }
        
        if let window = UIWindow.firstKeyWindow {
            skadnStoreKitAdsHelper.start(in: window)
        }
    }
    
    // MARK: SKOverlay
    
    /// Attempts to display an `SKOverlay` if a valid configuration is available.
    public func activateSKOverlayIfAvailable() {
        skOverlayManager = SKOverlayInterstitialManager()
        skOverlayManager?.tryToShow()
    }
    
    /// Dismisses the SKOverlay if presented.
    public func dismissSKOverlayIfAvailable() {
        skOverlayManager?.dismiss()
        skOverlayManager = nil
    }
}
