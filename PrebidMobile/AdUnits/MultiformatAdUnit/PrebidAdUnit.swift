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

import Foundation

/// Multiformat ad unit. Built for original API.
@objcMembers
public class PrebidAdUnit: NSObject {
    
    /// The ad slot identifier for the Prebid ad unit.
    public var pbAdSlot: String? {
        get { adUnit.pbAdSlot }
        set { adUnit.pbAdSlot = newValue }
    }
    
    private let adUnit: AdUnit
    
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
    public func fetchDemand(adObject: AnyObject, request: PrebidRequest,
                            completion: @escaping (BidInfo) -> Void) {
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
    
    /// Makes bid request for the specified request config.
    /// - Parameters:
    ///   - request: The `PrebidRequest` containing the demand request parameters.
    ///   - completion: A closure to be called with the `BidInfo` result.
    public func fetchDemand(request: PrebidRequest, completion: @escaping (BidInfo) -> Void) {
        guard requestHasParameters(request) else {
            completion(BidInfo(resultCode: .prebidInvalidRequest))
            return
        }
        
        config(with: request)
        adUnit.baseFetchDemand { bidInfo in
            DispatchQueue.main.async {
                completion(bidInfo)
            }
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
        
        adUnit.adUnitConfig.gpid = request.gpid
        
        adUnit.adUnitConfig.setExtData(request.getExtData())
        adUnit.adUnitConfig.setExtKeywords(request.getExtKeywords())
        adUnit.adUnitConfig.setAppContent(request.getAppContent())
        adUnit.adUnitConfig.setUserData(request.getUserData())
    }
    
    // For tests, SDK internal
    func getConfiguration() -> AdUnitConfig {
        return adUnit.adUnitConfig
    }
}
