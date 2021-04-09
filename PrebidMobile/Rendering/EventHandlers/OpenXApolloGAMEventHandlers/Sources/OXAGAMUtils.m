//
//  OXAGAMUtils.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAGAMUtils.h"
#import "OXAGAMUtils+Internal.h"

#import "OXADFPRequest.h"
#import "OXAGADNativeCustomTemplateAd.h"
#import "OXAGADUnifiedNativeAd.h"
#import "OXAGAMConstants.h"
#import "OXAGAMError.h"
#import "NSTimer+OXAScheduledTimerFactory.h"


static NSTimeInterval const LOCAL_CACHE_EXPIRATION_INTERVAL = 3600;
static NSString * const PREBID_KEYWORD_PREFIX = @"hb_";


@interface OXAGAMUtils ()
@property (nonatomic, strong, nonnull, readonly) OXALocalResponseInfoCache *localCache;
@end



@implementation OXAGAMUtils

- (instancetype)initWithLocalCache:(OXALocalResponseInfoCache *)localCache {
    if (!(self = [super init])) {
        return nil;
    }
    _localCache = localCache;
    return self;
}

+ (instancetype)sharedUtils {
    static OXAGAMUtils *singleton = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OXAScheduledTimerFactory const timerFactory = [NSTimer oxaScheduledTimerFactory];
        OXALocalResponseInfoCache * const localCache = [[OXALocalResponseInfoCache alloc] initWithScheduledTimerFactory:timerFactory
                                                                                                     expirationInterval:LOCAL_CACHE_EXPIRATION_INTERVAL];
        singleton = [[OXAGAMUtils alloc] initWithLocalCache:localCache];
    });

    return singleton;
}
    
- (void)prepareRequest:(DFPRequest *)request demandResponseInfo:(OXADemandResponseInfo *)demandResponseInfo {
    if (![OXADFPRequest classesFound]) {
        return;
    }
    NSString * const localCacheID = [self.localCache storeResponseInfo:demandResponseInfo];
    OXADFPRequest * const boxedRequest = [[OXADFPRequest alloc] initWithDFPRequest:request];
    NSMutableDictionary<NSString *, NSString *> * const mergedTargeting = [self cleanTargetingFromRequest:boxedRequest];
    NSDictionary<NSString *, NSString *> * const bidTargeting = demandResponseInfo.bid.targetingInfo;
    if (bidTargeting != nil) {
        [mergedTargeting addEntriesFromDictionary:bidTargeting];
    }
    mergedTargeting[OXA_GAM_LOCAL_CACHE_ID_TARGETING_KEY] = localCacheID;
    boxedRequest.customTargeting = mergedTargeting;
}

- (NSMutableDictionary<NSString *, NSString *> *)cleanTargetingFromRequest:(OXADFPRequest *)request {
    NSMutableDictionary<NSString *, NSString *> * const result = [[NSMutableDictionary alloc] init];
    NSDictionary * const requestTargeting = request.customTargeting;
    if (requestTargeting != nil) {
        for (NSString *key in requestTargeting) {
            if (![key hasPrefix:PREBID_KEYWORD_PREFIX]) {
                result[key] = requestTargeting[key];
            }
        }
    }
    return result;
}

- (void)findNativeAdInCustomTemplateAd:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd
             nativeAdDetectionListener:(OXANativeAdDetectionListener *)nativeAdDetectionListener
{
    OXAInvalidNativeAdHandler const reportError = nativeAdDetectionListener.onNativeAdInvalid ?: ^(NSError *error) {};
    if (![OXAGADNativeCustomTemplateAd classesFound]) {
        reportError([OXAGAMError gamClassesNotFound]);
        return;
    }
    OXAGADNativeCustomTemplateAd * const wrappedAd = [[OXAGADNativeCustomTemplateAd alloc] initWithCustomTemplateAd:nativeCustomTemplateAd];
    [self findNativeAdWithFlagLookupBlock:^BOOL{
        return [self findApolloCreativeFlagInNativeCustomTemplateAd:wrappedAd];
    } localCacheIDExtractor:^NSString * _Nullable{
        return [self localCacheIDFromNativeCustomTemplateAd:wrappedAd];
    } nativeAdDetectionListener:nativeAdDetectionListener];
}

- (void)findNativeAdInUnifiedNativeAd:(GADUnifiedNativeAd *)unifiedNativeAd
            nativeAdDetectionListener:(OXANativeAdDetectionListener *)nativeAdDetectionListener
{
    OXAInvalidNativeAdHandler const reportError = nativeAdDetectionListener.onNativeAdInvalid ?: ^(NSError *error) {};
    if (![OXAGADUnifiedNativeAd classesFound]) {
        reportError([OXAGAMError gamClassesNotFound]);
        return;
    }
    OXAGADUnifiedNativeAd * const wrappedAd = [[OXAGADUnifiedNativeAd alloc] initWithUnifiedNativeAd:unifiedNativeAd];
    [self findNativeAdWithFlagLookupBlock:^BOOL{
        return [self findApolloCreativeFlagInUnifiedNativeAd:wrappedAd];
    } localCacheIDExtractor:^NSString * _Nullable{
        return [self localCacheIDFromUnifiedNativeAd:wrappedAd];
    } nativeAdDetectionListener:nativeAdDetectionListener];
}

// MARK: - Private Helpers

- (void)findNativeAdWithFlagLookupBlock:(BOOL (NS_NOESCAPE ^ _Nonnull)(void))flagLookupBlock
                  localCacheIDExtractor:(NSString * _Nullable (NS_NOESCAPE ^ _Nonnull)(void))localCacheIDExtractor
              nativeAdDetectionListener:(OXANativeAdDetectionListener *)nativeAdDetectionListener
{
    OXAInvalidNativeAdHandler const reportError = nativeAdDetectionListener.onNativeAdInvalid ?: ^(NSError *error) {};
    if (!flagLookupBlock()) {
        if (nativeAdDetectionListener.onPrimaryAdWin != nil) {
            nativeAdDetectionListener.onPrimaryAdWin();
        }
        return;
    }
    NSString * const localCacheID = localCacheIDExtractor();
    if (localCacheID == nil) {
        reportError([OXAGAMError noLocalCacheID]);
        return;
    }
    OXADemandResponseInfo * const cachedResponse = [self.localCache getStoredResponseInfo:localCacheID];
    if (cachedResponse == nil) {
        reportError([OXAGAMError invalidLocalCacheID]);
        return;
    }
    [cachedResponse getNativeAdWithCompletion:^(OXANativeAd * _Nullable nativeAd) {
        if (nativeAd != nil) {
            if (nativeAdDetectionListener.onNativeAdLoaded != nil) {
                nativeAdDetectionListener.onNativeAdLoaded(nativeAd);
            }
        } else {
            // TODO: Update 'completion' type to forward the underlying error(?)
            reportError([OXAGAMError invalidNativeAd]);
        }
    }];
}

// MARK: NativeCustomTemplateAd decomposition

- (BOOL)findApolloCreativeFlagInNativeCustomTemplateAd:(OXAGADNativeCustomTemplateAd *)nativeCustomTemplateAd {
    NSString * const isApolloCreativeVar = [nativeCustomTemplateAd stringForKey:OXA_GAM_APOLLO_CREATIVE_FLAG_KEY];
    if ([isApolloCreativeVar isEqualToString:OXA_GAM_APOLLO_CREATIVE_FLAG_VALUE]) {
        return YES;
    }
    NSString * const isPrebidCreativeVar = [nativeCustomTemplateAd stringForKey:OXA_GAM_PREBID_CREATIVE_FLAG_KEY];
    if ([isPrebidCreativeVar isEqualToString:OXA_GAM_PREBID_CREATIVE_FLAG_VALUE]) {
        return YES;
    }
    // fallback
    return NO;
}

- (NSString *)localCacheIDFromNativeCustomTemplateAd:(OXAGADNativeCustomTemplateAd *)nativeCustomTemplateAd {
    return [nativeCustomTemplateAd stringForKey:OXA_GAM_LOCAL_CACHE_ID_TARGETING_KEY];
}

// MARK: UnifiedNativeAd decomposition

- (BOOL)findApolloCreativeFlagInUnifiedNativeAd:(OXAGADUnifiedNativeAd *)unifiedNativeAd {
    return [unifiedNativeAd.body isEqualToString:OXA_GAM_APOLLO_CREATIVE_FLAG_KEY];
}

- (NSString *)localCacheIDFromUnifiedNativeAd:(OXAGADUnifiedNativeAd *)unifiedNativeAd {
    return unifiedNativeAd.callToAction;
}


@end
