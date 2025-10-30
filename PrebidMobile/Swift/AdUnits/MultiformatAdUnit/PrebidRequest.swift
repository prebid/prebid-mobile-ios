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

/// Class that contains properties and methods to configure Prebid request.
@objcMembers
public class PrebidRequest: NSObject {
    
    // MARK: - Public properties
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition = .undefined
    
    // MARK: - SKAdNetwork
    
    /// A flag that determines whether SKOverlay should be supported for interstitials
    public var supportSKOverlayForInterstitial: Bool = false
    
    // MARK: - Internal properties
    
    private(set) var bannerParameters: BannerParameters?
    private(set) var videoParameters: VideoParameters?
    private(set) var nativeParameters: NativeParameters?
    
    private(set) var isInterstitial = false
    private(set) var isRewarded = false
    
    private(set) var gpid: String?
    private var impORTBConfig: String?
    private var globalORTBConfig: String?
    
    /// Initializes a new `PrebidRequest` with the given parameters.
    /// - Parameters:
    ///   - bannerParameters: The banner parameters for the ad request.
    ///   - videoParameters: The video parameters for the ad request.
    ///   - nativeParameters: The native parameters for the ad request.
    ///   - isInterstitial: Indicates if the request is for an interstitial ad.
    ///   - isRewarded: Indicates if the request is for a rewarded ad.
    public init(
        bannerParameters: BannerParameters? = nil,
        videoParameters: VideoParameters? = nil,
        nativeParameters: NativeParameters? = nil,
        isInterstitial: Bool = false,
        isRewarded: Bool = false
    ) {
        self.bannerParameters = bannerParameters
        self.videoParameters = videoParameters
        self.nativeParameters = nativeParameters
        self.isInterstitial = isInterstitial
        self.isRewarded = isRewarded
        
        super.init()
    }
    
    // MARK: GPID
    
    /// Sets the GPID for the ad request.
    /// - Parameter gpid: The GPID to set.
    public func setGPID(_ gpid: String?) {
        self.gpid = gpid
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbConfig: The  impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        self.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        impORTBConfig
    }
    
    /// Sets the global OpenRTB configuration string for the ad unit. It takes precedence over `Targeting.setGlobalOrtbConfig`.
    ///
    /// - Parameter ortbConfig: The global OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setGlobalORTBConfig(_ ortbConfig: String?) {
        self.globalORTBConfig = ortbConfig
    }
    
    /// Returns the global OpenRTB configuration string.
    public func getGlobalORTBConfig() -> String? {
        globalORTBConfig
    }
}
