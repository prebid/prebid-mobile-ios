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

public class NativeAdUnit: PBMBaseAdUnit {
    
    // MARK: - Required properties
    @objc public override var configId: String { super.configId }
    @objc public var nativeAdConfig: NativeAdConfiguration { adUnitConfig.nativeAdConfiguration! }
    
    var hasStartedFetching = false
    
    // MARK: - Lifecycle
    
    @objc public convenience init(configID: String, nativeAdConfiguration: NativeAdConfiguration) {
        self.init(configID: configID,
                  nativeAdConfiguration: nativeAdConfiguration,
                  serverConnection: PBMServerConnection.singleton(),
                  sdkConfiguration: PrebidRenderingConfig.shared,
                  targeting: PrebidRenderingTargeting.shared)
    }
    
    // MARK: - Get Native Ad
    @objc public override func fetchDemand(completion: @escaping PBMFetchDemandCompletionHandler) {
        //@synchronized (self.stateLockToken) {..}
        objc_sync_enter(self.stateLockToken)
        if hasStartedFetching {
            completion(DemandResponseInfo(fetchDemandResult: .sdkMisuseNativeAdUnitFetchedAgain,
                                             bid: nil,
                                             configId: nil,
                                             winNotifierBlock: winNotifierBlock))
            objc_sync_exit(self.stateLockToken)
            return
        }
        hasStartedFetching = true
        objc_sync_exit(self.stateLockToken)

        super.fetchDemand(completion: completion)
    }
    
    public convenience init(configID: String,
                     nativeAdConfiguration: NativeAdConfiguration,
                     serverConnection: PBMServerConnectionProtocol,
                     sdkConfiguration: PrebidRenderingConfig,
                     targeting: PrebidRenderingTargeting) {
        
        self.init(configID: configID,
                  nativeAdConfiguration: nativeAdConfiguration,
                  bidRequesterFactory: PBMBidRequesterFactory.requesterFactory(withConnection: serverConnection,
                                                                               sdkConfiguration: sdkConfiguration,
                                                                               targeting: targeting),
                  winNotifierBlock: PBMWinNotifier.winNotifierBlock(withConnection: serverConnection))
    }
    
    // MARK: - Private
    
    init(configID: String,
                 nativeAdConfiguration: NativeAdConfiguration,
                 bidRequesterFactory: @escaping PBMBidRequesterFactoryBlock,
                 winNotifierBlock: @escaping PBMWinNotifierBlock) {
        
        super.init(configID: configID,
                   bidRequesterFactory: bidRequesterFactory,
                   winNotifierBlock: winNotifierBlock)
        
        setupNativeAdConfiguration(nativeAdConfiguration)
    }
    
    private func setupNativeAdConfiguration(_ nativeAdConfiguration: NativeAdConfiguration) {
        guard let nativeAdConfig = nativeAdConfiguration.copy() as? NativeAdConfiguration else {
            return
        }

        var eventtrackers = nativeAdConfig.eventtrackers ?? []
        let omidEventTracker = NativeEventTracker(event: NativeEventType.omid.rawValue,
                                                  methods: [NativeEventTrackingMethod.js.rawValue])
        eventtrackers.append(omidEventTracker)
        nativeAdConfig.eventtrackers = eventtrackers

        adUnitConfig.nativeAdConfiguration = nativeAdConfig
    }
}
