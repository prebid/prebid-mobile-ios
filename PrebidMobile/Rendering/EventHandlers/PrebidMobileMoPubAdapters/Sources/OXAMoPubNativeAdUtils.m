//
//  OXAMoPubNativeAdUtils.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//
#import <MoPub/MoPub.h>
#import <PrebidMobileRendering/OXAMoPubUtils.h>

#import "NSTimer+OXAScheduledTimerFactory.h"

#import "OXAMoPubConstants.h"
#import "OXAMoPubError.h"
#import "OXAMoPubNativeAdUtils.h"
#import "OXAMoPubNativeAdUtils+Internal.h"

static NSTimeInterval const MOPUB_LOCAL_CACHE_EXPIRATION_INTERVAL = 3600;

@interface OXAMoPubNativeAdUtils ()
@property (nonatomic, strong, nonnull, readonly) OXALocalResponseInfoCache *localCache;
@end

@implementation OXAMoPubNativeAdUtils

- (instancetype)initWithLocalCache:(OXALocalResponseInfoCache *)localCache {
    if (!(self = [super init])) {
        return nil;
    }
    _localCache = localCache;
    return self;
}

+ (instancetype)sharedUtils {
    static OXAMoPubNativeAdUtils *singleton = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OXAScheduledTimerFactory const timerFactory = [NSTimer oxaScheduledTimerFactory];
        OXALocalResponseInfoCache * const localCache = [[OXALocalResponseInfoCache alloc] initWithScheduledTimerFactory:timerFactory
                                                                                                     expirationInterval:MOPUB_LOCAL_CACHE_EXPIRATION_INTERVAL];
        singleton = [[OXAMoPubNativeAdUtils alloc] initWithLocalCache:localCache];
    });

    return singleton;
}

- (void)prepareAdObject:(id)adObject {
    if (![OXAMoPubUtils isCorrectAdObject:adObject]) {
        return;
    }

    id<OXAMoPubAdObjectProtocol> mopubAdObject = (id<OXAMoPubAdObjectProtocol>)adObject;
    
    OXADemandResponseInfo * const demandResponseInfo = mopubAdObject.localExtras[OXAMoPubAdNativeResponseKey];
    if (!demandResponseInfo) {
        return;
    }
    
    NSString * const localCacheID = [self.localCache storeResponseInfo:demandResponseInfo];
    NSString * const cacheKeyword = [NSString stringWithFormat:@"%@:%@", OXA_MOPUB_LOCAL_CACHE_ID_TARGETING_KEY, localCacheID];
    NSString * keywords = mopubAdObject.keywords;
    keywords = keywords.length > 0 ? [NSString stringWithFormat:@"%@,%@", keywords, cacheKeyword] : cacheKeyword;
    
    mopubAdObject.keywords = keywords;
}

- (void)findNativeAdIn:(MPNativeAd *)nativeAd nativeAdDetectionListener:(OXANativeAdDetectionListener *)nativeAdDetectionListener {
    
    if (![self isApolloAd:nativeAd]) {
        if (nativeAdDetectionListener.onPrimaryAdWin != nil) {
            nativeAdDetectionListener.onPrimaryAdWin();
        }
        return;
    }
    
    OXAInvalidNativeAdHandler const reportError = nativeAdDetectionListener.onNativeAdInvalid ?: ^(NSError *error) {};
    
    NSString * const localCacheID = nativeAd.properties[OXA_MOPUB_LOCAL_CACHE_ID_TARGETING_KEY];
    if (!localCacheID) {
        reportError([OXAMoPubError noLocalCacheID]);
        return;
    }

    OXADemandResponseInfo * const cachedResponse = [self.localCache getStoredResponseInfo:localCacheID];
    if (!cachedResponse) {
        reportError([OXAMoPubError invalidLocalCacheID]);
        return;
    }
    
    [cachedResponse getNativeAdWithCompletion:^(OXANativeAd * apolloNativeAd) {
        if (apolloNativeAd) {
            if (nativeAdDetectionListener.onNativeAdLoaded != nil) {
                nativeAdDetectionListener.onNativeAdLoaded(apolloNativeAd);
            }
        } else {
            reportError([OXAMoPubError invalidNativeAd]);
        }
    }];
}

- (BOOL)isApolloAd:(MPNativeAd *)nativeAd {
    if (![nativeAd respondsToSelector:@selector(properties)] || !(nativeAd.properties)) {
        return NO;
    }
    
    NSDictionary * const properties = nativeAd.properties;
    
    NSString * const isApolloCreativeFlag = properties[OXA_MOPUB_APOLLO_CREATIVE_FLAG_KEY];
    if ([isApolloCreativeFlag isEqualToString:OXA_MOPUB_APOLLO_CREATIVE_FLAG_VALUE]) {
        return YES;
    }
    NSString * const isPrebidCreativeFlag = properties[OXA_MOPUB_PREBID_CREATIVE_FLAG_KEY];
    if ([isPrebidCreativeFlag isEqualToString:OXA_MOPUB_PREBID_CREATIVE_FLAG_VALUE]) {
        return YES;
    }
    return NO;
}

@end
