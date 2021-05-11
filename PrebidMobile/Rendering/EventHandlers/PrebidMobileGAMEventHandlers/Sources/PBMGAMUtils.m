//
//  PBMGAMUtils.m
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMGAMUtils.h"
#import "PBMGAMUtils+Internal.h"

#import "PBMGAMRequest.h"
#import "PBMGADCustomNativeAd.h"
#import "PBMGADNativeAd.h"
#import "PBMGAMConstants.h"
#import "PBMGAMError.h"
//#import "NSTimer+PBMScheduledTimerFactory.h"


static NSTimeInterval const LOCAL_CACHE_EXPIRATION_INTERVAL = 3600;
static NSString * const PREBID_KEYWORD_PREFIX = @"hb_";


@interface PBMGAMUtils ()
@property (nonatomic, strong, nonnull, readonly) PBMLocalResponseInfoCache *localCache;
@end



@implementation PBMGAMUtils

- (instancetype)initWithLocalCache:(PBMLocalResponseInfoCache *)localCache {
    if (!(self = [super init])) {
        return nil;
    }
    _localCache = localCache;
    return self;
}

+ (instancetype)sharedUtils {
    static PBMGAMUtils *singleton = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PBMScheduledTimerFactory const timerFactory = [NSTimer pbmScheduledTimerFactory];
        PBMLocalResponseInfoCache * const localCache = [[PBMLocalResponseInfoCache alloc] initWithScheduledTimerFactory:timerFactory
                                                                                                     expirationInterval:LOCAL_CACHE_EXPIRATION_INTERVAL];
        singleton = [[PBMGAMUtils alloc] initWithLocalCache:localCache];
    });

    return singleton;
}
    
- (void)prepareRequest:(GAMRequest *)request
    demandResponseInfo:(PBMDemandResponseInfo *)demandResponseInfo {
    if (![PBMGAMRequest classesFound]) {
        return;
    }
    NSString * const localCacheID = [self.localCache storeResponseInfo:demandResponseInfo];
    PBMGAMRequest * const boxedRequest = [[PBMGAMRequest alloc] initWithDFPRequest:request];
    NSMutableDictionary<NSString *, NSString *> * const mergedTargeting = [self cleanTargetingFromRequest:boxedRequest];
    NSDictionary<NSString *, NSString *> * const bidTargeting = demandResponseInfo.bid.targetingInfo;
    if (bidTargeting != nil) {
        [mergedTargeting addEntriesFromDictionary:bidTargeting];
    }
    mergedTargeting[PREBID_GAM_LOCAL_CACHE_ID_TARGETING_KEY] = localCacheID;
    boxedRequest.customTargeting = mergedTargeting;
}

- (NSMutableDictionary<NSString *, NSString *> *)cleanTargetingFromRequest:(PBMGAMRequest *)request {
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

- (void)findNativeAdInCustomTemplateAd:(GADCustomNativeAd *)nativeCustomTemplateAd
             nativeAdDetectionListener:(PBMNativeAdDetectionListener *)nativeAdDetectionListener
{
    PBMInvalidNativeAdHandler const reportError = nativeAdDetectionListener.onNativeAdInvalid ?: ^(NSError *error) {};
    if (![PBMGADCustomNativeAd classesFound]) {
        reportError([PBMGAMError gamClassesNotFound]);
        return;
    }
    PBMGADCustomNativeAd * const wrappedAd = [[PBMGADCustomNativeAd alloc] initWithCustomNativeAd:nativeCustomTemplateAd];
    [self findNativeAdWithFlagLookupBlock:^BOOL{
        return [self findPrebidCreativeFlagInNativeCustomTemplateAd:wrappedAd];
    } localCacheIDExtractor:^NSString * _Nullable{
        return [self localCacheIDFromNativeCustomTemplateAd:wrappedAd];
    } nativeAdDetectionListener:nativeAdDetectionListener];
}

- (void)findNativeAdInUnifiedNativeAd:(GADNativeAd *)unifiedNativeAd
            nativeAdDetectionListener:(PBMNativeAdDetectionListener *)nativeAdDetectionListener
{
    PBMInvalidNativeAdHandler const reportError = nativeAdDetectionListener.onNativeAdInvalid ?: ^(NSError *error) {};
    if (![PBMGADNativeAd classesFound]) {
        reportError([PBMGAMError gamClassesNotFound]);
        return;
    }
    PBMGADNativeAd * const wrappedAd = [[PBMGADNativeAd alloc] initWithNativeAd:unifiedNativeAd];
    [self findNativeAdWithFlagLookupBlock:^BOOL{
        return [self findPrebidCreativeFlagInUnifiedNativeAd:wrappedAd];
    } localCacheIDExtractor:^NSString * _Nullable{
        return [self localCacheIDFromUnifiedNativeAd:wrappedAd];
    } nativeAdDetectionListener:nativeAdDetectionListener];
}

// MARK: - Private Helpers

- (void)findNativeAdWithFlagLookupBlock:(BOOL (NS_NOESCAPE ^ _Nonnull)(void))flagLookupBlock
                  localCacheIDExtractor:(NSString * _Nullable (NS_NOESCAPE ^ _Nonnull)(void))localCacheIDExtractor
              nativeAdDetectionListener:(PBMNativeAdDetectionListener *)nativeAdDetectionListener
{
    PBMInvalidNativeAdHandler const reportError = nativeAdDetectionListener.onNativeAdInvalid ?: ^(NSError *error) {};
    if (!flagLookupBlock()) {
        if (nativeAdDetectionListener.onPrimaryAdWin != nil) {
            nativeAdDetectionListener.onPrimaryAdWin();
        }
        return;
    }
    NSString * const localCacheID = localCacheIDExtractor();
    if (localCacheID == nil) {
        reportError([PBMGAMError noLocalCacheID]);
        return;
    }
    PBMDemandResponseInfo * const cachedResponse = [self.localCache getStoredResponseInfo:localCacheID];
    if (cachedResponse == nil) {
        reportError([PBMGAMError invalidLocalCacheID]);
        return;
    }
    [cachedResponse getNativeAdWithCompletion:^(PBMNativeAd * _Nullable nativeAd) {
        if (nativeAd != nil) {
            if (nativeAdDetectionListener.onNativeAdLoaded != nil) {
                nativeAdDetectionListener.onNativeAdLoaded(nativeAd);
            }
        } else {
            // TODO: Update 'completion' type to forward the underlying error(?)
            reportError([PBMGAMError invalidNativeAd]);
        }
    }];
}

// MARK: NativeCustomTemplateAd decomposition

- (BOOL)findPrebidCreativeFlagInNativeCustomTemplateAd:(PBMGADCustomNativeAd *)nativeCustomTemplateAd {
    NSString * const isPrebidCreativeVar = [nativeCustomTemplateAd stringForKey:PREBID_GAM_PREBID_CREATIVE_FLAG_KEY];
    if ([isPrebidCreativeVar isEqualToString:PREBID_GAM_PREBID_CREATIVE_FLAG_VALUE]) {
        return YES;
    }
    // fallback
    return NO;
}

- (NSString *)localCacheIDFromNativeCustomTemplateAd:(PBMGADCustomNativeAd *)nativeCustomTemplateAd {
    return [nativeCustomTemplateAd stringForKey:PREBID_GAM_LOCAL_CACHE_ID_TARGETING_KEY];
}

// MARK: UnifiedNativeAd decomposition

- (BOOL)findPrebidCreativeFlagInUnifiedNativeAd:(PBMGADNativeAd *)unifiedNativeAd {
    return [unifiedNativeAd.body isEqualToString:PREBID_GAM_PREBID_CREATIVE_FLAG_KEY];
}

- (NSString *)localCacheIDFromUnifiedNativeAd:(PBMGADNativeAd *)unifiedNativeAd {
    return unifiedNativeAd.callToAction;
}


@end
