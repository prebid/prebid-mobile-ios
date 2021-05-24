//
//  PrebidMoPubNativeCustomEvent.swift
//  PrebidMobileMoPubAdapters
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

import MoPubSDK

import PrebidMobileRendering

// @objc is required for instantiating in the MoPub SDK
@objc(PrebidMoPubNativeCustomEvent)
public class PrebidMoPubNativeCustomEvent : MPNativeCustomEvent {
    
    // MARK: MPNativeCustomEvent
    
    public override func requestAd(withCustomEventInfo info: [AnyHashable : Any]!, adMarkup: String!) {
        
        if localExtras.count == 0 {
            let error = MoPubAdaptersError.emptyLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: String(describing: PrebidMoPubNativeCustomEvent.self), error: error), source: nil, from: nil)
            delegate.nativeCustomEvent(self, didFailToLoadAdWithError: error)
            return
        }
        
        MoPubUtils.findNativeAd(localExtras) { [weak self] (ad, error) in
            if let nativeAd = ad {
                self?.nativeAdDidLoad(nativeAd)
            } else {
                let error = error ?? MoPubAdaptersError.unknown
                
                MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: String(describing: PrebidMoPubNativeCustomEvent.self), error: error), source: nil, from: nil)
                self?.delegate.nativeCustomEvent(self, didFailToLoadAdWithError: error)
            }
        }
    }
    
    // MARK: Private Methods
    
    func nativeAdDidLoad(_ nativeAd: NativeAd) {
        
        let adAdapter = PrebidMoPubNativeAdAdapter(nativeAd: nativeAd)
        let interfaceAd = MPNativeAd(adAdapter: adAdapter)
        
        MPLogging.logEvent(MPLogEvent.adLoadSuccess(forAdapter: String(describing: PrebidMoPubNativeCustomEvent.self)), source: nil, from: nil)
        
        delegate.nativeCustomEvent(self, didLoad: interfaceAd)
    }
}
