//
//  GAMUtils.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileRendering

fileprivate let localCacheExpirationInterval: TimeInterval = 3600
fileprivate let prebidKeywordPrefix = "hb_"

public class GAMUtils {
    
    // MARK: - Private Properties
    
    private let localCache: PBMLocalResponseInfoCache
    
    private init() {
        localCache = PBMLocalResponseInfoCache(expirationInterval: localCacheExpirationInterval)
    }
    
    // MARK: - Public
    
    public static let shared = GAMUtils()
    
    public func prepareRequest(_ request: GAMRequest,
                               demandResponseInfo: PBMDemandResponseInfo)  {
        guard let boxedRequest = GAMRequestWrapper(request: request) else {
            return
        }
        
        var mergedTargeting = getPrebidTargeting(from: boxedRequest)
        
        if let bidTargeting = demandResponseInfo.bid?.targetingInfo {
            mergedTargeting.merge(bidTargeting) { $1 }
        }
        
        mergedTargeting[Constants.targetingKeyLocalCacheID] = localCache.store(demandResponseInfo)
        
        boxedRequest.customTargeting = mergedTargeting
    }
    
    public func findNativeAd(for nativeAd: GADNativeAd,
                             nativeAdDetectionListener: PBMNativeAdDetectionListener) {
        
        guard let wrappedAd = GADNativeAdWrapper(nativeAd: nativeAd) else {
            nativeAdDetectionListener.onNativeAdInvalid?(GAMEventHandlerError.gamClassesNotFound)
            return
        }
        
        findNativeAd(flagLookupClosure: {
            GAMUtils.findPrebidFlagInNativeAd(wrappedAd)
        }, localCacheIDExtractor: {
            GAMUtils.localCacheIDFromNativeAd(wrappedAd)
        }, nativeAdDetectionListener: nativeAdDetectionListener)
    }
    
    public func findCustomNativeAd(for customNativeAd: GADCustomNativeAd,
                            nativeAdDetectionListener: PBMNativeAdDetectionListener) {
        
        guard let wrappedAd = GADCustomNativeAdWrapper(customNativeAd: customNativeAd) else {
            nativeAdDetectionListener.onNativeAdInvalid?(GAMEventHandlerError.gamClassesNotFound)
            return
        }
        
        findNativeAd(flagLookupClosure: {
            GAMUtils.findCreativeFlagInCustomNativeAd(wrappedAd)
        }, localCacheIDExtractor: {
            GAMUtils.localCacheIDFromCustomNativeAd(wrappedAd)
        }, nativeAdDetectionListener: nativeAdDetectionListener)
    }
    
    class func log(error: GAMEventHandlerError) {
        // TODO: use unified Logging system from the Rendering or Prebid SDK
        NSLog(error.localizedDescription)
    }
    
    // MARK: Private Methods
    
    private func getPrebidTargeting(from request: GAMRequestWrapper) -> [String: String] {
        guard let requestTargeting = request.customTargeting else {
            return [:]
        }
        
        return requestTargeting.filter {
            $0.key.hasPrefix(prebidKeywordPrefix)
        }
    }
    
    private func findNativeAd(flagLookupClosure: () -> Bool,
                              localCacheIDExtractor: () -> String?,
                              nativeAdDetectionListener: PBMNativeAdDetectionListener) {
        
        if !flagLookupClosure() {
            nativeAdDetectionListener.onPrimaryAdWin?()
            return
        }
        
        guard let localCacheID = localCacheIDExtractor() else {
            nativeAdDetectionListener.onNativeAdInvalid?(GAMEventHandlerError.noLocalCacheID)
            return
        }
        
        guard let cacheResponse = localCache.getStoredResponseInfo(localCacheID) else {
            nativeAdDetectionListener.onNativeAdInvalid?(GAMEventHandlerError.invalidLocalCacheID)
            return
        }
        
        cacheResponse.getNativeAd {
            guard let nativeAd = $0 else {
                nativeAdDetectionListener.onNativeAdInvalid?(GAMEventHandlerError.invalidNativeAd)
                return
            }
            
            nativeAdDetectionListener.onNativeAdLoaded?(nativeAd)
        }
    }
    
    // MARK: UnifiedNativeAd decomposition

    private class func findPrebidFlagInNativeAd(_ nativeAd: GADNativeAdWrapper) -> Bool {
        nativeAd.body == Constants.creativeDataKeyIsPrebid
    }
    
    private class func localCacheIDFromNativeAd(_ nativeAd: GADNativeAdWrapper) -> String? {
        nativeAd.callToAction;
    }

    // MARK: NativeCustomTemplateAd decomposition

    private class func findCreativeFlagInCustomNativeAd(_ customNativeAd: GADCustomNativeAdWrapper) -> Bool {
        if let isPrebidCreativeVar = customNativeAd.string(forKey: Constants.creativeDataKeyIsPrebid),
           isPrebidCreativeVar == Constants.creativeDataValueIsPrebid {
            return true;
        }

        return false;
    }

    private class func localCacheIDFromCustomNativeAd(_ customNativeAd: GADCustomNativeAdWrapper) -> String? {
        customNativeAd.string(forKey: Constants.targetingKeyLocalCacheID)
    }
}
