//
//  MPRewardedVideo.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedVideo.h"
#import "MPRewardedAds.h"
#import "MPRewardedVideoReward.h"

/**
 This class wraps @c MPRewardedAds to maintain backwards compatibility with deprecated @c MPRewardedVideo APIs.

 Since @c MPRewardedAds is a singleton which does not expose a shared instance, this generally wraps at the class
 level. However, the delegate pattern is expected to be instance-to-instance, so some special handling had to be
 set up to handle forwarding @c MPRewardedAdsDelegate events to @c MPRewardedVideoDelegate objects.

 To handle this, the @c MPRewardedVideo wrapper holds:
 - a shared instance of @c MPRewardedVideo which conforms to @c MPRewardedAdsDelegate. This object is used as the
   receiver of callbacks to be forwarded from @c MPRewardedAds in all cases.
 - a table of publisher objects which conform to @c MPRewardedVideoDelegate, keyed off of Ad Unit ID.

 When the @c MPRewardedVideo shared instance receives an event from @c MPRewardedAds, the ad unit ID is used to
 look up the pub's @c MPRewardedVideoDelegate object in our delegate table and send the equivalent callback to that
 object. During this lookup process, if the pub's delegate has gone nil (we hold our reference weakly), then we drop
 our delegate from the @c MPRewardedAds singleton to stop receiving callbacks ourselves.

 Besides that bit of complexity, the wrapping otherwise happens as you'd expect. Our methods call equivalent
 @c MPRewardedAds methods.
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
@interface MPRewardedVideo () <MPRewardedAdsDelegate>

// Used to hold the publisher's delegate object. Weak references needed since they're delegate objects.
// Key: Ad Unit ID, Value: pub objects conforming to @c MPRewardedVideoDelegate
@property (nonatomic, strong, class) NSMapTable <NSString *, id<MPRewardedVideoDelegate>> *rewardedVideoDelegateTable;

@property (nonatomic, strong, readonly, class) MPRewardedVideo *sharedRewardedAdsDelegate;

@end

@implementation MPRewardedVideo

#pragma mark Class-level Delegate Table

static NSMapTable <NSString *, id<MPRewardedVideoDelegate>> *sRewardedVideoDelegateTable = nil;

+ (void)initialize {
    self.rewardedVideoDelegateTable = [NSMapTable strongToWeakObjectsMapTable];
}

+ (void)setRewardedVideoDelegateTable:(NSMapTable<NSString *,id<MPRewardedVideoDelegate>> *)rewardedVideoDelegateTable {
    sRewardedVideoDelegateTable = rewardedVideoDelegateTable;
}

+ (NSMapTable <NSString *, id<MPRewardedVideoDelegate>> *)rewardedVideoDelegateTable {
    return sRewardedVideoDelegateTable;
}

#pragma mark Shared Delegate Object

+ (instancetype)sharedRewardedAdsDelegate {
    static dispatch_once_t onceToken;
    static MPRewardedVideo *sharedDelegate;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[self alloc] init];
    });

    return sharedDelegate;
}

#pragma mark MPRewardedVideo singleton re-implementation

+ (void)setDelegate:(id<MPRewardedVideoDelegate>)delegate forAdUnitId:(NSString *)adUnitId {
    // Add RV delegate object to our table
    [self.rewardedVideoDelegateTable setObject:delegate forKey:adUnitId];

    // Register shared RA delegate object to MPRewardedAds singleton
    [MPRewardedAds setDelegate:self.sharedRewardedAdsDelegate forAdUnitId:adUnitId];
}

+ (void)removeDelegate:(id<MPRewardedVideoDelegate>)delegate {
    if (delegate == nil) {
        return;
    }

    NSMapTable *delegateTable = self.rewardedVideoDelegateTable;

    // Gather the ad unit IDs that should have their delegates removed
    NSMutableArray<NSString *> *adUnitIdsToRemove = [NSMutableArray arrayWithCapacity:delegateTable.count];
    for (NSString *adUnitId in delegateTable) {
        if ([delegateTable objectForKey:adUnitId] == delegate) {
            [adUnitIdsToRemove addObject:adUnitId];
        }
    }

    // Remove them
    for (NSString *adUnitId in adUnitIdsToRemove) {
        [self removeDelegateForAdUnitId:adUnitId];
    }
}

+ (void)removeDelegateForAdUnitId:(NSString *)adUnitId {
    // Remove delegate object from our table
    [self.rewardedVideoDelegateTable removeObjectForKey:adUnitId];

    // Remove our delegate from the RewardedAds singleton
    [MPRewardedAds removeDelegateForAdUnitId:adUnitId];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withMediationSettings:(NSArray *)mediationSettings {
    [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitID withMediationSettings:mediationSettings];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID
                               keywords:(NSString *)keywords
                       userDataKeywords:(NSString *)userDataKeywords
                      mediationSettings:(NSArray *)mediationSettings {
    [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitID
                                     keywords:keywords
                             userDataKeywords:userDataKeywords
                            mediationSettings:mediationSettings];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID
                               keywords:(NSString *)keywords
                       userDataKeywords:(NSString *)userDataKeywords
                               location:(CLLocation *)location
                      mediationSettings:(NSArray *)mediationSettings {
    // Pub-gathered location is deprecated, so don't use that method on @c MPRewardedAds
    [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitID
                                     keywords:keywords
                             userDataKeywords:userDataKeywords
                            mediationSettings:mediationSettings];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID
                               keywords:(NSString *)keywords
                       userDataKeywords:(NSString *)userDataKeywords
                             customerId:(NSString *)customerId
                      mediationSettings:(NSArray *)mediationSettings {
    [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitID
                                     keywords:keywords
                             userDataKeywords:userDataKeywords
                                   customerId:customerId
                            mediationSettings:mediationSettings];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID
                               keywords:(NSString *)keywords
                       userDataKeywords:(NSString *)userDataKeywords
                               location:(CLLocation *)location
                             customerId:(NSString *)customerId
                      mediationSettings:(NSArray *)mediationSettings {
    // Pub-gathered location is deprecated, so don't use that method on @c MPRewardedAds
    [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitID
                                     keywords:keywords
                             userDataKeywords:userDataKeywords
                                   customerId:customerId
                            mediationSettings:mediationSettings];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID
                               keywords:(NSString *)keywords
                       userDataKeywords:(NSString *)userDataKeywords
                             customerId:(NSString *)customerId
                      mediationSettings:(NSArray *)mediationSettings
                            localExtras:(NSDictionary *)localExtras {
    [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitID
                                     keywords:keywords
                             userDataKeywords:userDataKeywords
                                   customerId:customerId
                            mediationSettings:mediationSettings
                                  localExtras:localExtras];
}

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID
                               keywords:(NSString *)keywords
                       userDataKeywords:(NSString *)userDataKeywords
                               location:(CLLocation *)location
                             customerId:(NSString *)customerId
                      mediationSettings:(NSArray *)mediationSettings
                            localExtras:(NSDictionary *)localExtras {
    // Pub-gathered location is deprecated, so don't use that method on @c MPRewardedAds
    [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitID
                                     keywords:keywords
                             userDataKeywords:userDataKeywords
                                   customerId:customerId
                            mediationSettings:mediationSettings
                                  localExtras:localExtras];

}

+ (BOOL)hasAdAvailableForAdUnitID:(NSString *)adUnitID {
    return [MPRewardedAds hasAdAvailableForAdUnitID:adUnitID];
}

+ (NSArray *)availableRewardsForAdUnitID:(NSString *)adUnitID {
    NSArray *rewards = [MPRewardedAds availableRewardsForAdUnitID:adUnitID];
    NSMutableArray *convertedRewards = [NSMutableArray arrayWithCapacity:rewards.count];
    for (MPReward *reward in rewards) {
        [convertedRewards addObject:[MPRewardedVideoReward rewardWithReward:reward]];
    }

    return convertedRewards;
}

+ (MPRewardedVideoReward *)selectedRewardForAdUnitID:(NSString *)adUnitID {
    return [MPRewardedVideoReward rewardWithReward:[MPRewardedAds selectedRewardForAdUnitID:adUnitID]];
}

+ (void)presentRewardedVideoAdForAdUnitID:(NSString *)adUnitID
                       fromViewController:(UIViewController *)viewController
                               withReward:(MPRewardedVideoReward *)reward {
    [MPRewardedAds presentRewardedAdForAdUnitID:adUnitID
                             fromViewController:viewController
                                     withReward:reward];
}

+ (void)presentRewardedVideoAdForAdUnitID:(NSString *)adUnitID
                       fromViewController:(UIViewController *)viewController
                               withReward:(MPRewardedVideoReward *)reward
                               customData:(NSString *)customData {
    [MPRewardedAds presentRewardedAdForAdUnitID:adUnitID
                             fromViewController:viewController
                                     withReward:reward
                                     customData:customData];
}

#pragma mark MPRewardedAdDelegate

// Helper to grab the delegate object needed to send the notification
- (id<MPRewardedVideoDelegate>)delegateForAdUnitId:(NSString *)adUnitId {
    id<MPRewardedVideoDelegate> delegate = [MPRewardedVideo.rewardedVideoDelegateTable objectForKey:adUnitId];

    // if @c delegate is @c nil, remove our delegate from @c MPRewardedAds singleton
    // to stop receiving updates for this ad unit ID.
    if (delegate == nil) {
        [MPRewardedAds removeDelegateForAdUnitId:adUnitId];
    }

    return delegate;
}

- (void)rewardedAdDidLoadForAdUnitID:(NSString *)adUnitID {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdDidLoadForAdUnitID:)]) {
        [delegate rewardedVideoAdDidLoadForAdUnitID:adUnitID];
    }
}

- (void)rewardedAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdDidFailToLoadForAdUnitID:error:)]) {
        [delegate rewardedVideoAdDidFailToLoadForAdUnitID:adUnitID error:error];
    }
}

- (void)rewardedAdDidExpireForAdUnitID:(NSString *)adUnitID {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdDidExpireForAdUnitID:)]) {
        [delegate rewardedVideoAdDidExpireForAdUnitID:adUnitID];
    }
}

- (void)rewardedAdDidFailToShowForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdDidFailToPlayForAdUnitID:error:)]) {
        [delegate rewardedVideoAdDidFailToPlayForAdUnitID:adUnitID error:error];
    }
}

- (void)rewardedAdWillPresentForAdUnitID:(NSString *)adUnitID {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdWillAppearForAdUnitID:)]) {
        [delegate rewardedVideoAdWillAppearForAdUnitID:adUnitID];
    }
}

- (void)rewardedAdDidPresentForAdUnitID:(NSString *)adUnitID {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdDidAppearForAdUnitID:)]) {
        [delegate rewardedVideoAdDidAppearForAdUnitID:adUnitID];
    }
}

- (void)rewardedAdWillDismissForAdUnitID:(NSString *)adUnitID {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdWillDisappearForAdUnitID:)]) {
        [delegate rewardedVideoAdWillDisappearForAdUnitID:adUnitID];
    }
}

- (void)rewardedAdDidDismissForAdUnitID:(NSString *)adUnitID {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdDidDisappearForAdUnitID:)]) {
        [delegate rewardedVideoAdDidDisappearForAdUnitID:adUnitID];
    }
}

- (void)rewardedAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdDidReceiveTapEventForAdUnitID:)]) {
        [delegate rewardedVideoAdDidReceiveTapEventForAdUnitID:adUnitID];
    }
}

- (void)rewardedAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdWillLeaveApplicationForAdUnitID:)]) {
        [delegate rewardedVideoAdWillLeaveApplicationForAdUnitID:adUnitID];
    }
}

- (void)rewardedAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPReward *)reward {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(rewardedVideoAdShouldRewardForAdUnitID:reward:)]) {
        [delegate rewardedVideoAdShouldRewardForAdUnitID:adUnitID reward:[MPRewardedVideoReward rewardWithReward:reward]];
    }
}

- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData {
    id<MPRewardedVideoDelegate> delegate = [self delegateForAdUnitId:adUnitID];

    if ([delegate respondsToSelector:@selector(didTrackImpressionWithAdUnitID:impressionData:)]) {
        [delegate didTrackImpressionWithAdUnitID:adUnitID impressionData:impressionData];
    }
}

@end
#pragma clang diagnostic pop
