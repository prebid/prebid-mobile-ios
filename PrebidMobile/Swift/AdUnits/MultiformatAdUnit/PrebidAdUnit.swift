/*   Copyright 2019-2023 Prebid.org, Inc.
 
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

/// Multiformat ad unit. Built for original API.
@objcMembers
public class PrebidAdUnit: NSObject {
    
    /// The ad slot identifier for the Prebid ad unit.
    public var pbAdSlot: String? {
        get { adUnit.pbAdSlot }
        set { adUnit.pbAdSlot = newValue }
    }
    
    private let adUnit: AdUnit
    
    private var skOverlayManager: SKOverlayInterstitialManager?
    
    /// Initializes a new `PrebidAdUnit` with the given configuration ID.
    /// - Parameter configId: The configuration ID for the ad unit.
    public init(configId: String) {
        adUnit = AdUnit(configId: configId, size: CGSize.zero, adFormats: [])
        super.init()
    }
    
    /// Makes bid request for the specified ad object and request config. Setups targeting keywords into the adObject.
    /// - Parameters:
    ///   - adObject: The ad object to fetch demand for.
    ///   - request: The `PrebidRequest` containing the demand request parameters.
    ///   - completion: A closure to be called with the `BidInfo` result.
    public func fetchDemand(
        adObject: AnyObject,
        request: PrebidRequest,
        completion: @escaping (BidInfo) -> Void
    ) {
        baseFetchDemand(
            adObject: adObject,
            request: request,
            completion: completion
        )
    }
    
    /// Makes bid request for the specified request config.
    /// - Parameters:
    ///   - request: The `PrebidRequest` containing the demand request parameters.
    ///   - completion: A closure to be called with the `BidInfo` result.
    public func fetchDemand(request: PrebidRequest, completion: @escaping (BidInfo) -> Void) {
        baseFetchDemand(
            adObject: nil,
            request: request,
            completion: completion
        )
    }
    
    private func baseFetchDemand(
        adObject: AnyObject?,
        request: PrebidRequest,
        completion: @escaping (BidInfo) -> Void
    ) {
        guard requestHasParameters(request) else {
            completion(BidInfo(resultCode: .prebidInvalidRequest))
            return
        }
        
        config(with: request)
        
        adUnit.baseFetchDemand(adObject: adObject) { bidInfo in
            DispatchQueue.main.async {
                completion(bidInfo)
            }
        }
    }
    
    // MARK: Prebid Impression Tracking
    
    /// Sets the view in which Prebid will start tracking an impression and activates the impression tracker.
    /// - Parameters:
    ///   - adView: The ad view that contains ad creative(f.e. GAMBannerView). This object will be used later for tracking `burl`.
    public func activatePrebidAdViewImpressionTracker(adView: UIView) {
        adUnit.impressionTracker.start(in: adView)
    }
    
    /// Activates interstitial impression tracker.
    public func activatePrebidInterstitialImpressionTracker() {
        if let window = UIWindow.firstKeyWindow {
            adUnit.impressionTracker.start(in: window)
        }
    }
    
    // MARK: SKAdNetwork
    
    /// Activates Prebid's SKAdNetwork StoreKit ads flow for the provided ad view.
    /// Note: Ensure this method is called within the Google Mobile Ads ad received method
    /// (e.g., in the GADBannerViewDelegate's bannerViewDidReceiveAd or similar callbacks).
    ///
    /// - Parameters:
    ///   - adView: The ad view that contains ad creative(f.e. GAMBannerView).
    public func activatePrebidBannerSKAdNetworkStoreKitAdsFlow(adView: UIView) {
        adUnit.skadnStoreKitAdsHelper.start(in: adView)
    }
    
    /// Activates Prebid's SKAdNetwork StoreKit ads flow.
    /// Note: Ensure this method is called before presenting interstitials.
    public func activatePrebidInterstitialSKAdNetworkStoreKitAdsFlow() {
        if let window = UIWindow.firstKeyWindow {
            adUnit.skadnStoreKitAdsHelper.start(in: window)
        }
    }
    
    // MARK: - Auto refresh API
    
    /// This method allows to set the auto refresh period for the demand
    ///
    /// - Parameter time: refresh time interval
    public func setAutoRefreshMillis(time: Double) {
        adUnit.setAutoRefreshMillis(time: time)
    }
    
    /// This method stops the auto refresh of demand
    public func stopAutoRefresh() {
        adUnit.stopAutoRefresh()
    }
    
    /// This method resumes the auto refresh of demand
    public func resumeAutoRefresh() {
        adUnit.resumeAutoRefresh()
    }
    
    // MARK: SKOverlay
    
    /// Attempts to display an `SKOverlay` over interstitial if a valid configuration is available.
    public func activateSKOverlayIfAvailable() {
        skOverlayManager = SKOverlayInterstitialManager()
        skOverlayManager?.tryToShow()
    }
    
    /// Dismisses the SKOverlay if presented
    public func dismissSKOverlayIfAvailable() {
        skOverlayManager?.dismiss()
        skOverlayManager = nil
    }
    
    // MARK: - Private zone
    
    private func requestHasParameters(_ request: PrebidRequest) -> Bool {
        return request.bannerParameters != nil || request.videoParameters != nil || request.nativeParameters != nil
    }
    
    private func config(with request: PrebidRequest) {
        if let bannerParameters = request.bannerParameters {
            adUnit.adUnitConfig.adConfiguration.bannerParameters = bannerParameters
            adUnit.adUnitConfig.adFormats.insert(.banner)
            
            if let adSizes = bannerParameters.adSizes, let primaryAdSize = adSizes.first {
                adUnit.adUnitConfig.adSize = primaryAdSize
                adUnit.adUnitConfig.additionalSizes = Array(adSizes.dropFirst())
            }
        }
        
        if let videoParameters = request.videoParameters {
            adUnit.adUnitConfig.adConfiguration.videoParameters = videoParameters
            adUnit.adUnitConfig.adFormats.insert(.video)
            
            if let adSize = videoParameters.adSize {
                adUnit.adUnitConfig.adSize = adSize
            }
        }
        
        if let nativeParameters = request.nativeParameters {
            adUnit.adUnitConfig.nativeAdConfiguration = NativeAdConfiguration(nativeParameters: nativeParameters)
            adUnit.adUnitConfig.adFormats.insert(.native)
        }
        
        adUnit.adUnitConfig.adConfiguration.isInterstitialAd = request.isInterstitial
        adUnit.adUnitConfig.adConfiguration.isRewarded = request.isRewarded
        adUnit.adUnitConfig.adPosition = request.adPosition
        adUnit.adUnitConfig.impORTBConfig = request.getImpORTBConfig()
        adUnit.adUnitConfig.contentORTBConfig = request.getContentORTBConfig()

        if request.isInterstitial || request.isRewarded {
            adUnit.adUnitConfig.adPosition = .fullScreen
            adUnit.adUnitConfig.adConfiguration.videoParameters.placement = .Interstitial
            adUnit.adUnitConfig.adConfiguration.videoParameters.plcmnt = .Interstitial
        }
        
        if let minWidthPerc = request.bannerParameters?.interstitialMinWidthPerc,
           let minHeightPerc = request.bannerParameters?.interstitialMinHeightPerc {
            let minSizePercCG = CGSize(width: minWidthPerc, height: minHeightPerc)
            adUnit.adUnitConfig.minSizePerc = NSValue(cgSize: minSizePercCG)
        }
        
        adUnit.adUnitConfig.adConfiguration.supportSKOverlay = request.supportSKOverlayForInterstitial
        adUnit.adUnitConfig.gpid = request.gpid
    }
    
    // For tests, SDK internal
    func getConfiguration() -> AdUnitConfig {
        return adUnit.adUnitConfig
    }
}
