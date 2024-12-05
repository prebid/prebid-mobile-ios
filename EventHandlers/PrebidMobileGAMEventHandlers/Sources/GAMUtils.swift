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
import GoogleMobileAds
import PrebidMobile

fileprivate let prebidKeywordPrefix = "hb_"

@objcMembers
public class GAMUtils: NSObject {
    
    // MARK: - Private Properties
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public
    
    public static let shared = GAMUtils()
    
    @objc public static var errorDomain: String {
        "org.prebid.mobile.GAMEventHandlers"
    }
    
    public func initializeGAM() {
        GADMobileAds.sharedInstance().start()
    }
    
    public func prepareRequest(_ request: GAMRequest,
                               bidTargeting: [String: String])  {
        guard let boxedRequest = GAMRequestWrapper(request: request) else {
            return
        }
        
        var mergedTargeting = getPrebidTargeting(from: boxedRequest)
        
        mergedTargeting.merge(bidTargeting) { $1 }
        
        boxedRequest.customTargeting = mergedTargeting
    }
        
    class func log(error: GAMEventHandlerError) {
        Log.error(error.localizedDescription)
    }
    
    // Added for tests
    static func latestTestedGMAVersion() -> GADVersionNumber {
        return GADVersionNumber(majorVersion: 11, minorVersion: 13, patchVersion: 0)
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
        customNativeAd.string(forKey: PrebidLocalCacheIdKey)
    }
}

extension GAMUtils {
    
    public func findNativeAd(for nativeAd: GADNativeAd) -> Result<NativeAd, GAMEventHandlerError> {
        guard let wrappedAd = GADNativeAdWrapper(nativeAd: nativeAd) else {
            return .failure(GAMEventHandlerError.gamClassesNotFound)
        }
        
        if !GAMUtils.findPrebidFlagInNativeAd(wrappedAd) {
            return .failure(GAMEventHandlerError.nonPrebidAd)
        }
        
        guard let localCacheId = GAMUtils.localCacheIDFromNativeAd(wrappedAd) else {
            return .failure(GAMEventHandlerError.noLocalCacheID)
        }
        
        
        return createNativeAd(from: localCacheId)
    }
    
    public func findNativeAdObjc(for nativeAd: GADNativeAd,
                                 completion: @escaping (NativeAd?, NSError?) -> Void) {
        switch findNativeAd(for: nativeAd) {
        case .success(let nativeAd):
            completion(nativeAd, nil)
        case .failure(let error):
            let nsError = NSError(domain: GAMUtils.errorDomain, code: error.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString(error.localizedDescription, comment: "")])
            completion(nil, nsError)
        }
    }
    
    
    public func findCustomNativeAd(for nativeAd: GADCustomNativeAd) -> Result<NativeAd, GAMEventHandlerError> {
        guard let wrappedAd = GADCustomNativeAdWrapper(customNativeAd: nativeAd) else {
            return .failure(GAMEventHandlerError.gamClassesNotFound)
        }
        
        if !GAMUtils.findCreativeFlagInCustomNativeAd(wrappedAd) {
            return .failure(GAMEventHandlerError.nonPrebidAd)
        }
        
        guard let localCacheId = GAMUtils.localCacheIDFromCustomNativeAd(wrappedAd) else {
            return .failure(GAMEventHandlerError.noLocalCacheID)
        }
        
        return createNativeAd(from: localCacheId)
    }
    
    public func findCustomNativeAdObjc(for nativeAd: GADCustomNativeAd,
                                       completion: @escaping (NativeAd?, NSError?) -> Void) {
        switch findCustomNativeAd(for: nativeAd) {
        case .success(let nativeAd):
            completion(nativeAd, nil)
        case .failure(let error):
            let nsError = NSError(domain: GAMUtils.errorDomain, code: error.rawValue, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString(error.localizedDescription, comment: "")])
            completion(nil, nsError)
        }
    }
    
    private func createNativeAd(from cacheId: String) -> Result<NativeAd, GAMEventHandlerError> {
        guard CacheManager.shared.isValid(cacheId: cacheId) else {
            return .failure(GAMEventHandlerError.invalidLocalCacheID)
        }
        
        guard let nativeAd = NativeAd.create(cacheId: cacheId) else {
            return .failure(GAMEventHandlerError.noAd)
        }
        
        return .success(nativeAd)
    }
}
