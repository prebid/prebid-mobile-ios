//
//  OXAMoPubUtils.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "OXAMoPubUtils.h"
#import "OXAMoPubUtils+Private.h"

#import "OXADemandResponseInfo.h"
#import "OXAErrorCode.h"
#import "OXAPublicConstants.h"

NSString * const OXAMoPubAdUnitBidKey        = @"OXA_BID";
NSString * const OXAMoPubConfigIdKey         = @"OXA_CONFIG_ID";
NSString * const OXAMoPubAdNativeResponseKey = @"OXA_NATIVE_RESPONSE";

static NSString * keywordsSeparator = @",";
static NSString * HBKeywordPrefix = @"hb_";

@implementation OXAMoPubUtils

+ (BOOL)isCorrectAdObject:(NSObject *)adObject {
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wundeclared-selector"
    return  [adObject respondsToSelector:@selector(setLocalExtras:)] &&
            [adObject respondsToSelector:@selector(localExtras)] &&
            [adObject respondsToSelector:@selector(setKeywords:)] &&
            [adObject respondsToSelector:@selector(keywords)];
    #pragma GCC diagnostic pop
}

/**
 targetingInfo =  {
     "hb_bidder" = openx;
     "hb_bidder_openx" = openx;
     "hb_cache_host" = "prebid.openx.net";
     "hb_cache_host_openx" = "prebid.openx.net";
     "hb_cache_id" = "e67ae55d-0f15-4676-91f4-237006ce4cc6";
     "hb_cache_id_openx" = "e67ae55d-0f15-4676-91f4-237006ce4cc6";
     "hb_cache_path" = "/cache";
     "hb_cache_path_openx" = "/cache";
     "hb_env" = "mobile-app";
     "hb_env_openx" = "mobile-app";
     "hb_pb" = "0.10";
     "hb_pb_openx" = "0.10";
     "hb_size" = 320x50;
     "hb_size_openx" = 320x50;
 }
 */

+ (BOOL)setUpAdObject:(id<OXAMoPubAdObjectProtocol>)adObject
         withConfigId:(NSString *)configId
        targetingInfo:(NSDictionary<NSString *,NSString *> *)targetingInfo
          extraObject:(id)anObject forKey:(NSString *)aKey {
    
    NSDictionary *extras = adObject.localExtras;
    if (extras && ![extras isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    NSString *adKeywords = adObject.keywords;
    if (adKeywords && ![adKeywords isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    //Pass our objects via the localExtra property
    NSMutableDictionary *mutableExtras = extras ? [extras mutableCopy] : [NSMutableDictionary new];
    mutableExtras[aKey] = anObject;
    mutableExtras[OXAMoPubConfigIdKey] = configId;
    adObject.localExtras = mutableExtras;
    
    //Setup bid targeting keyword
    if (targetingInfo.count > 0) {
        NSString *bidKeywords = [OXAMoPubUtils keywordsFrom:targetingInfo];
        adKeywords = adKeywords.length > 0 ? [NSString stringWithFormat:@"%@,%@", adKeywords, bidKeywords] : bidKeywords;
        adObject.keywords = adKeywords;
    }
    
    return YES;
}

+ (void)cleanUpAdObject:(id<OXAMoPubAdObjectProtocol>)adObject {
    NSString *keywords = adObject.keywords;
    if (keywords && [keywords isKindOfClass:[NSString class]]) {
        keywords = [OXAMoPubUtils removeHBKeywordsFrom:keywords];
        adObject.keywords = keywords;
    }
    
    NSDictionary *extras = adObject.localExtras;
    if (extras && [extras isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableExtras =  [extras mutableCopy];
        [mutableExtras removeObjectsForKeys:@[OXAMoPubAdUnitBidKey, OXAMoPubConfigIdKey, OXAMoPubAdNativeResponseKey]];
        adObject.localExtras = mutableExtras;
    }
}

+ (NSString *)keywordsFrom:(NSDictionary<NSString *,NSString *> *)targetingInfo {
    NSMutableArray *targetingParams = [NSMutableArray arrayWithCapacity:targetingInfo.count];
    [targetingInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [targetingParams addObject:[NSString stringWithFormat:@"%@:%@", key, obj]];
    }];
    return [targetingParams componentsJoinedByString:keywordsSeparator];
}

+ (NSString *)removeHBKeywordsFrom:(NSString *)keyWords {
    NSMutableArray *cleanKeywordsArray = [NSMutableArray new];
    NSArray *keywordsArray = [keyWords componentsSeparatedByString:keywordsSeparator];
    [keywordsArray enumerateObjectsUsingBlock:^(NSString *keyWord, NSUInteger idx, BOOL *stop){
        if (![keyWord hasPrefix:HBKeywordPrefix]) {
            [cleanKeywordsArray addObject:keyWord];
        }
    }];
    return [cleanKeywordsArray componentsJoinedByString:keywordsSeparator];
}

+ (void)findNativeAd:(NSDictionary *_Nullable)extras callback:(nonnull OXAFindNativeAdHandler)callback {
    OXADemandResponseInfo *response = extras[OXAMoPubAdNativeResponseKey];
    if (!response) {
        NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                             code:OXAErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Response object is absent in the extras", nil)}];
        callback(nil, error);
        return;
    }
    
    [response getNativeAdWithCompletion:^(OXANativeAd * nativeAd) {
        if (nativeAd) {
            callback(nativeAd, nil);
        } else {
            NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                                 code:OXAErrorCodeGeneral
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Native Ad object is absent in the extras", nil)}];
            callback(nil, error);
        }
    }];
}

@end
