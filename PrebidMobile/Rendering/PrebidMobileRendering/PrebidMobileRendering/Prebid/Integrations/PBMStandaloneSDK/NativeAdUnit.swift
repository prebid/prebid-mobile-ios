//
//  NativeAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

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
                  sdkConfiguration: PBMSDKConfiguration.singleton,
                  targeting: PBMTargeting.shared())
    }
    
    // MARK: - Get Native Ad
    @objc public override func fetchDemand(completion: @escaping PBMFetchDemandCompletionHandler) {
        //@synchronized (self.stateLockToken) {..}
        objc_sync_enter(self.stateLockToken)
        if hasStartedFetching {
            completion(PBMDemandResponseInfo(fetchDemandResult: .sdkMisuse_NativeAdUnitFetchedAgain,
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
                     sdkConfiguration: PBMSDKConfiguration,
                     targeting: PBMTargeting) {
        
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
        
        //NOTE: At the moment (10 March 2021) PBS doesn't support OM event trackers:
        //https://github.com/prebid/prebid-server/issues/1732
        //Remove the next line
        adUnitConfig.nativeAdConfiguration = nativeAdConfiguration
        //and uncomment the next one when PBS be ready
        //setupNativeAdConfiguration(nativeAdConfiguration)
    }
    
    private func setupNativeAdConfiguration(_ nativeAdConfiguration: NativeAdConfiguration) {
        guard let nativeAdConfig = nativeAdConfiguration.copy() as? NativeAdConfiguration else {
            return
        }

        var eventtrackers = nativeAdConfig.eventtrackers ?? []
        let omidEventTracker = PBMNativeEventTracker(event: .OMID,
                                                     methods: [NSNumber(value: PBMNativeEventTrackingMethod.JS.rawValue)])
        eventtrackers.append(omidEventTracker)
        nativeAdConfig.eventtrackers = eventtrackers

        adUnitConfig.nativeAdConfiguration = nativeAdConfig
    }
}
