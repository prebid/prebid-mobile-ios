//
//  MoPubUtils.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public let PBMMoPubAdUnitBidKey        = "PBM_BID"
public let PBMMoPubConfigIdKey         = "PBM_CONFIG_ID"
public let PBMMoPubAdNativeResponseKey = "PBM_NATIVE_RESPONSE"

fileprivate let keywordsSeparator = ","
fileprivate let HBKeywordPrefix = "hb_"

fileprivate let MoPubSelector_localExtras = "localExtras"
fileprivate let MoPubSelector_setLocalExtras = "setLocalExtras:"

fileprivate let MoPubSelector_keywords  = "keywords"
fileprivate let MoPubSelector_setKeywords  = "setKeywords:"


public class MoPubUtils {
    /**
     Checks that a passed object confirms to the PBMMoPubAdObjectProtocol
     @return YES if the passed object is correct, FALSE otherwise
     */
    public static func isCorrectAdObject(_ adObject: NSObject) -> Bool {
        return
            adObject.responds(to: Selector((MoPubSelector_localExtras)))        &&
            adObject.responds(to: Selector((MoPubSelector_setLocalExtras)))    &&
            adObject.responds(to: Selector((MoPubSelector_setKeywords)))       &&
            adObject.responds(to: Selector((MoPubSelector_keywords)))
    }

    /**
     Finds an native ad object in the given extra dictionary.
     Calls the provided callback with the finded native ad object or error
     */
    public static func findNativeAd(_ extras: [AnyHashable : Any],
                                    completion: @escaping (PBMNativeAd?, Error?) -> Void) {
    
        guard let response = extras[PBMMoPubAdNativeResponseKey] as? PBMDemandResponseInfo else {
            let error = PBMError.error(description: "The Response object is absent in the extras")
            completion(nil, error)
            return
        }
        
        response.getNativeAd { ad in
            guard let nativeAd = ad else {
                let error = PBMError.error(description: "The Native Ad object is absent in the extras")
                completion(nil, error)
                return
            }
            
            completion(nativeAd, nil)
        }
    }

    /**
     Removes an bid info from ad object's localExtra
     and prebid-specific keywords from ad object's keywords
     */
    public static func cleanUpAdObject(_ adObject: NSObject) {
        guard MoPubUtils.isCorrectAdObject(adObject),
              let adExtras = adObject.value(forKey: MoPubSelector_localExtras) as? [AnyHashable : Any],
              let adKeywords = adObject.value(forKey: MoPubSelector_keywords) as? String else {
            return
        }
        
        let keywords = MoPubUtils.removeHBKeywordsFrom(adKeywords)
        adObject.setValue(keywords, forKey: MoPubSelector_keywords)
        
        let HBKeys = [PBMMoPubAdUnitBidKey, PBMMoPubConfigIdKey, PBMMoPubAdNativeResponseKey]
        let extras = adExtras.filter {
            guard let key = $0.key as? String else { return true }
            return !HBKeys.contains(key)
        }
        
        adObject.setValue(extras, forKey: MoPubSelector_localExtras)
    }

    /**
     Puts to ad object's localExtra the ad object (winning bid or native ad) and configId
     and populates adObject's keywords by targeting info
     @return YES on success and NO otherwise (when the passed ad has wrong type)
     */
    public static func setUpAdObject(_ adObject: NSObject,
                                     configID:String,
                                     targetingInfo: [String : String],
                                     extraObject:Any?,
                                     forKey:String ) -> Bool {
        guard MoPubUtils.isCorrectAdObject(adObject) else {
            return false
        }
        
        let extras = adObject.value(forKey: MoPubSelector_localExtras) as? [AnyHashable : Any]
        let adKeywords = (adObject.value(forKey: MoPubSelector_keywords) as? String) ?? ""
        
        //Pass our objects via the localExtra property
        var mutableExtras = extras ?? [:]
        mutableExtras[forKey] = extraObject
        mutableExtras[PBMMoPubConfigIdKey] = configID
        
        adObject.setValue(mutableExtras, forKey: MoPubSelector_localExtras)
        
        //Setup bid targeting keyword
        if targetingInfo.count > 0 {
            let bidKeywords = MoPubUtils.keywordsFrom(targetingInfo)
            let keywords = adKeywords.isEmpty ?
                bidKeywords :
                adKeywords + "," + bidKeywords
            
            adObject.setValue(keywords, forKey: MoPubSelector_keywords)
        }

        return true
    }
    
    // MARK: - Private Methods
    
    private static func keywordsFrom(_ targetingInfo: [String : String]) -> String {
        return targetingInfo
            .map { $0 + ":" + $1 }
            .joined(separator: keywordsSeparator)
    }
    
    private static func removeHBKeywordsFrom(_ keywords: String) -> String  {
        return keywords
            .components(separatedBy: keywordsSeparator)
            .filter { !$0.hasPrefix(HBKeywordPrefix) }
            .joined(separator: keywordsSeparator)
    }


}
