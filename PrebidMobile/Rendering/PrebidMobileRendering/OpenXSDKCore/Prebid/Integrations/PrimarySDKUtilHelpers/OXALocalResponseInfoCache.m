//
//  OXALocalResponseInfoCache.m
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXALocalResponseInfoCache.h"
#import "OXALocalResponseInfoCache+Internal.h"

#import "OXACachedResponseInfo.h"
#import "OXAWeakTimerTargetBox.h"


@interface OXALocalResponseInfoCache ()
@property (nonatomic, strong, nonnull, readonly) NSMutableDictionary<NSString *, OXACachedResponseInfo *> *cachedResponses;
@property (nonatomic, strong, nonnull, readonly) OXAScheduledTimerFactory scheduledTimerFactory;
@property (nonatomic, assign, readonly) NSTimeInterval expirationInterval;
@property (nonatomic, strong, nonnull, readonly) NSObject *cacheLock;
@end


@implementation OXALocalResponseInfoCache

- (instancetype)initWithScheduledTimerFactory:(OXAScheduledTimerFactory)scheduledTimerFactory
                           expirationInterval:(NSTimeInterval)expirationInterval
{
    if (!(self = [super init])) {
        return nil;
    }
    _cachedResponses = [[NSMutableDictionary alloc] init];
    _scheduledTimerFactory = [OXAWeakTimerTargetBox
                              scheduledTimerFactoryWithWeakifiedTarget:[scheduledTimerFactory copy]];
    _expirationInterval = expirationInterval;
    _cacheLock = [[NSObject alloc] init];
    return self;
}

// MARK: - Internal API

- (NSString *)storeResponseInfo:(OXADemandResponseInfo *)responseInfo {
    NSUUID * const uuid = [NSUUID UUID];
    NSString * const localCacheID = [NSString stringWithFormat:@"Apollo_%@", uuid.UUIDString];
    @synchronized (self.cacheLock) {
        id<OXATimerInterface> const timer = [self scheduleExpirationTimerForID:localCacheID];
        OXACachedResponseInfo * const cachedResponse = [[OXACachedResponseInfo alloc] initWithResponseInfo:responseInfo
                                                                                           expirationTimer:timer];
        self.cachedResponses[localCacheID] = cachedResponse;
    }
    return localCacheID;
}

- (OXADemandResponseInfo *)getStoredResponseInfo:(NSString *)localCacheID {
    return [self getAndRemoveCachedResponseInfo:localCacheID];
}

// MARK: - Private API

- (id<OXATimerInterface>)scheduleExpirationTimerForID:(NSString *)localCacheID {
    return self.scheduledTimerFactory(self.expirationInterval,          // interval
                                      self,                             // target
                                      @selector(expireCachedResponse:), // selector
                                      localCacheID,                     // user info
                                      NO);                              // repeats
}

- (void)expireCachedResponse:(NSString *)localCacheID {
    OXADemandResponseInfo * const expiredResponse = [self getAndRemoveCachedResponseInfo:localCacheID];
    [self notifyResponseInfoExpired:expiredResponse];
}

- (OXADemandResponseInfo *)getAndRemoveCachedResponseInfo:(NSString *)localCacheID {
    OXACachedResponseInfo *cachedEntry = nil;
    @synchronized (self.cacheLock) {
        cachedEntry = self.cachedResponses[localCacheID];
        [cachedEntry.expirationTimer invalidate];
        [self.cachedResponses removeObjectForKey:localCacheID];
    }
    return cachedEntry.responseInfo;
}

- (void)notifyResponseInfoExpired:(OXADemandResponseInfo *)expiredResponseInfo {
    // TODO: Implement
}

@end
