//
//  PBMMoPubNativeAdUtils.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//
#import <MoPub/MoPub.h>
#import <PrebidMobileRendering/PBMMoPubUtils.h>

#import "NSTimer+PBMScheduledTimerFactory.h"

#import "PrebidMoPubConstants.h"
#import "PrebidMoPubError.h"
#import "PrebidMoPubNativeAdUtils.h"
#import "PrebidMoPubNativeAdUtils+Internal.h"

static NSTimeInterval const MOPUB_LOCAL_CACHE_EXPIRATION_INTERVAL = 3600;

@interface PrebidMoPubNativeAdUtils ()
@property (nonatomic, strong, nonnull, readonly) PBMLocalResponseInfoCache *localCache;
@end

@implementation PrebidMoPubNativeAdUtils

- (instancetype)initWithLocalCache:(PBMLocalResponseInfoCache *)localCache {
    if (!(self = [super init])) {
        return nil;
    }
    _localCache = localCache;
    return self;
}

+ (instancetype)sharedUtils {
    static PrebidMoPubNativeAdUtils *singleton = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PBMScheduledTimerFactory const timerFactory = [NSTimer pbmScheduledTimerFactory];
        PBMLocalResponseInfoCache * const localCache = [[PBMLocalResponseInfoCache alloc] initWithScheduledTimerFactory:timerFactory
                                                                                                     expirationInterval:MOPUB_LOCAL_CACHE_EXPIRATION_INTERVAL];
        singleton = [[PrebidMoPubNativeAdUtils alloc] initWithLocalCache:localCache];
    });

    return singleton;
}

- (void)prepareAdObject:(id)adObject {
    if (![PBMMoPubUtils isCorrectAdObject:adObject]) {
        return;
    }

    id<PBMMoPubAdObjectProtocol> mopubAdObject = (id<PBMMoPubAdObjectProtocol>)adObject;
    
    PBMDemandResponseInfo * const demandResponseInfo = mopubAdObject.localExtras[PBMMoPubAdNativeResponseKey];
    if (!demandResponseInfo) {
        return;
    }
    
    NSString * const localCacheID = [self.localCache storeResponseInfo:demandResponseInfo];
    NSString * const cacheKeyword = [NSString stringWithFormat:@"%@:%@", PREBID_MOPUB_LOCAL_CACHE_ID_TARGETING_KEY, localCacheID];
    NSString * keywords = mopubAdObject.keywords;
    keywords = keywords.length > 0 ? [NSString stringWithFormat:@"%@,%@", keywords, cacheKeyword] : cacheKeyword;
    
    mopubAdObject.keywords = keywords;
}

- (void)findNativeAdIn:(MPNativeAd *)nativeAd nativeAdDetectionListener:(PBMNativeAdDetectionListener *)nativeAdDetectionListener {
    
    if (![self isPrebidAd:nativeAd]) {
        if (nativeAdDetectionListener.onPrimaryAdWin != nil) {
            nativeAdDetectionListener.onPrimaryAdWin();
        }
        return;
    }
    
    PBMInvalidNativeAdHandler const reportError = nativeAdDetectionListener.onNativeAdInvalid ?: ^(NSError *error) {};
    
    NSString * const localCacheID = nativeAd.properties[PREBID_MOPUB_LOCAL_CACHE_ID_TARGETING_KEY];
    if (!localCacheID) {
        reportError([PrebidMoPubError noLocalCacheID]);
        return;
    }

    PBMDemandResponseInfo * const cachedResponse = [self.localCache getStoredResponseInfo:localCacheID];
    if (!cachedResponse) {
        reportError([PrebidMoPubError invalidLocalCacheID]);
        return;
    }
    
    [cachedResponse getNativeAdWithCompletion:^(PBMNativeAd * prebidNativeAd) {
        if (prebidNativeAd) {
            if (nativeAdDetectionListener.onNativeAdLoaded != nil) {
                nativeAdDetectionListener.onNativeAdLoaded(prebidNativeAd);
            }
        } else {
            reportError([PrebidMoPubError invalidNativeAd]);
        }
    }];
}

- (BOOL)isPrebidAd:(MPNativeAd *)nativeAd {
    if (![nativeAd respondsToSelector:@selector(properties)] || !(nativeAd.properties)) {
        return NO;
    }
    
    NSDictionary * const properties = nativeAd.properties;
    NSString * const isPrebidCreativeFlag = properties[PREBID_MOPUB_PREBID_CREATIVE_FLAG_KEY];
    if ([isPrebidCreativeFlag isEqualToString:PREBID_MOPUB_PREBID_CREATIVE_FLAG_VALUE]) {
        return YES;
    }
    return NO;
}

@end
