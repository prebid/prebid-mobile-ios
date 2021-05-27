//
//  PrebidMoPubNativeAdUtils.swift
//  PrebidMobileMoPubAdapters
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

import MoPubSDK

import PrebidMobileRendering

fileprivate let localCacheExpirationInterval: TimeInterval = 3600

public class PrebidMoPubAdaptersUtils : NSObject {
    
    // MARK: - Public Properties
    
    public static let shared = PrebidMoPubAdaptersUtils()
    
    // MARK: - Internal Properties
    
    let localCache: LocalResponseInfoCache
    
    // MARK: - Public Methods
    
    public func prepareAdObject(_ adObject: NSObject) {
        guard MoPubUtils.isCorrectAdObject(adObject),
              let localExtras = adObject.value(forKey: "localExtras") as? [AnyHashable : Any],
              let demandResponseInfo = localExtras[PBMMoPubAdNativeResponseKey] as? PBMDemandResponseInfo else {
            return
        }
        
        let localCacheID = localCache.store(demandResponseInfo)
        let cacheKeyword = "\(Constants.targetingKeyLocalCacheID):\(localCacheID)"
        
        if let keywords = adObject.value(forKey: "keywords") as? String,
           !cacheKeyword.isEmpty {
            let newKeywords =  keywords + "," + cacheKeyword
            adObject.setValue(newKeywords, forKey: "keywords")
        } else {
            adObject.setValue(cacheKeyword, forKey: "keywords")
        }
    }
    
    public func find(nativeAd: MPNativeAd,
                     nativeAdDetectionListener: NativeAdDetectionListener) {
        guard isPrebidAd(nativeAd: nativeAd) == true else {
            nativeAdDetectionListener.onPrimaryAdWin?()
            return
        }
        
        guard let localCacheID = nativeAd.properties[Constants.targetingKeyLocalCacheID] as? String else {
            nativeAdDetectionListener.onNativeAdInvalid?(MoPubAdaptersError.noLocalCacheID)
            return
        }
        
        guard let cachedResponse = localCache.getStoredResponseInfo(localCacheID) else {
            nativeAdDetectionListener.onNativeAdInvalid?(MoPubAdaptersError.invalidLocalCacheID)
            return
        }
        
        cachedResponse.getNativeAd { ad in
            guard let nativeAd = ad else {
                nativeAdDetectionListener.onNativeAdInvalid?(MoPubAdaptersError.invalidNativeAd)
                return
            }
            
            nativeAdDetectionListener.onNativeAdLoaded?(nativeAd)
        }
    }
    
    // MARK: - Private Methods
    
    private override init () {
        localCache = LocalResponseInfoCache(expirationInterval: localCacheExpirationInterval)
    }
    
    private func isPrebidAd(nativeAd: MPNativeAd) -> Bool {
        guard nativeAd.responds(to: #selector(getter: MPNativeAd.properties)) else {
            return false
        }
        
        if let isPrebidCreativeFlag = nativeAd.properties?[Constants.creativeDataKeyIsPrebid] as? String,
           isPrebidCreativeFlag == Constants.creativeDataValueIsPrebid {
            
            return true
        }
        
        return false
    }
}
