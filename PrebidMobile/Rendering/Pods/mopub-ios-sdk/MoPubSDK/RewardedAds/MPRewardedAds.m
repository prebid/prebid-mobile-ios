//
//  MPRewardedAds.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedAds.h"
#import "MPAdTargeting.h"
#import "MPGlobal.h"
#import "MPImpressionTrackedNotification.h"
#import "MPLogging.h"
#import "MPRewardedAdManager.h"
#import "MPRewardedAdsError.h"
#import "MPRewardedAdConnection.h"
#import "MoPub+Utility.h"

static MPRewardedAds *gSharedInstance = nil;

@interface MPRewardedAds () <MPRewardedAdManagerDelegate, MPRewardedAdConnectionDelegate>

@property (nonatomic, strong) NSMutableDictionary *rewardedAdManagers;
@property (nonatomic) NSMutableArray *rewardedAdConnections;
@property (nonatomic, strong) NSMapTable<NSString *, id<MPRewardedAdsDelegate>> * delegateTable;

+ (MPRewardedAds *)sharedInstance;

@end

@implementation MPRewardedAds

- (instancetype)init
{
    if (self = [super init]) {
        _rewardedAdManagers = [[NSMutableDictionary alloc] init];
        _rewardedAdConnections = [NSMutableArray new];
        
        // Keys (ad unit ID) are strong, values (delegates) are weak.
        _delegateTable = [NSMapTable strongToWeakObjectsMapTable];
    }

    return self;
}

+ (void)setDelegate:(id<MPRewardedAdsDelegate>)delegate forAdUnitId:(NSString *)adUnitId
{
    if (adUnitId == nil) {
        return;
    }
    
    [[[self class] sharedInstance].delegateTable setObject:delegate forKey:adUnitId];
}

+ (void)removeDelegate:(id<MPRewardedAdsDelegate>)delegate
{
    if (delegate == nil) {
        return;
    }
    
    NSMapTable * mapTable = [[self class] sharedInstance].delegateTable;
    
    // Find all keys that contain the delegate
    NSMutableArray<NSString *> * keys = [NSMutableArray array];
    for (NSString * key in mapTable) {
        if ([mapTable objectForKey:key] == delegate) {
            [keys addObject:key];
        }
    }
    
    // Remove all of the found keys
    for (NSString * key in keys) {
        [mapTable removeObjectForKey:key];
    }
}

+ (void)removeDelegateForAdUnitId:(NSString *)adUnitId
{
    if (adUnitId == nil) {
        return;
    }
    
    [[[self class] sharedInstance].delegateTable removeObjectForKey:adUnitId];
}

+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID withMediationSettings:(NSArray *)mediationSettings
{
    [MPRewardedAds loadRewardedAdWithAdUnitID:adUnitID keywords:nil userDataKeywords:nil customerId:nil mediationSettings:mediationSettings localExtras:nil];
}

+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords mediationSettings:(NSArray *)mediationSettings
{
    [self loadRewardedAdWithAdUnitID:adUnitID keywords:keywords userDataKeywords:userDataKeywords customerId:nil mediationSettings:mediationSettings];
}

+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings
{
    [self loadRewardedAdWithAdUnitID:adUnitID keywords:keywords userDataKeywords:userDataKeywords customerId:customerId mediationSettings:mediationSettings localExtras:nil];
}

+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings localExtras:(NSDictionary *)localExtras
{
    MPRewardedAds *sharedInstance = [[self class] sharedInstance];

    if (![adUnitID length]) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorInvalidAdUnitID userInfo:nil];
        id<MPRewardedAdsDelegate> delegate = [sharedInstance.delegateTable objectForKey:adUnitID];
        [delegate rewardedAdDidFailToLoadForAdUnitID:adUnitID error:error];
        return;
    }

    MPRewardedAdManager *adManager = sharedInstance.rewardedAdManagers[adUnitID];

    if (!adManager) {
        adManager = [[MPRewardedAdManager alloc] initWithAdUnitID:adUnitID delegate:sharedInstance];
        sharedInstance.rewardedAdManagers[adUnitID] = adManager;
    }

    adManager.mediationSettings = mediationSettings;
    
    // Ad targeting options
    MPAdTargeting * targeting = [MPAdTargeting targetingWithCreativeSafeSize:MPApplicationFrame(YES).size];
    targeting.keywords = keywords;
    targeting.localExtras = localExtras;
    targeting.userDataKeywords = userDataKeywords;
    
    [adManager loadRewardedAdWithCustomerId:customerId targeting:targeting];
}

+ (BOOL)hasAdAvailableForAdUnitID:(NSString *)adUnitID
{
    MPRewardedAds *sharedInstance = [[self class] sharedInstance];
    MPRewardedAdManager *adManager = sharedInstance.rewardedAdManagers[adUnitID];

    return [adManager hasAdAvailable];
}

+ (NSArray<MPReward *> *)availableRewardsForAdUnitID:(NSString *)adUnitID
{
    MPRewardedAds *sharedInstance = [[self class] sharedInstance];
    MPRewardedAdManager *adManager = sharedInstance.rewardedAdManagers[adUnitID];
    
    if (adManager.availableRewards == nil) {
        return nil;
    }
    else {
        NSMutableArray<MPReward *> *rewards = [NSMutableArray new];
        for (MPReward *reward in adManager.availableRewards) {
            [rewards addObject:reward];
        }
        return rewards;
    }
}

+ (MPReward *)selectedRewardForAdUnitID:(NSString *)adUnitID
{
    MPRewardedAds *sharedInstance = [[self class] sharedInstance];
    MPRewardedAdManager *adManager = sharedInstance.rewardedAdManagers[adUnitID];
    
    return adManager.selectedReward;
}

+ (void)presentRewardedAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController withReward:(MPReward *)reward customData:(NSString *)customData
{
    MPRewardedAds *sharedInstance = [[self class] sharedInstance];
    MPRewardedAdManager *adManager = sharedInstance.rewardedAdManagers[adUnitID];

    if (!adManager) {
        MPLogInfo(@"The rewarded ad could not be shown: "
                  @"no ads have been loaded for adUnitID: %@", adUnitID);

        return;
    }

    if (!viewController) {
        MPLogInfo(@"The rewarded ad could not be shown: "
                  @"a nil view controller was passed to -presentRewardedAdForAdUnitID:fromViewController:.");

        return;
    }

    if (![viewController.view.window isKeyWindow]) {
        MPLogInfo(@"Attempting to present a rewarded ad in non-key window. The ad may not render properly.");
    }

    [adManager presentRewardedAdFromViewController:viewController withReward:reward customData:customData];
}

+ (void)presentRewardedAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController withReward:(MPReward *)reward
{
    [MPRewardedAds presentRewardedAdForAdUnitID:adUnitID fromViewController:viewController withReward:reward customData:nil];
}

#pragma mark - Private

+ (MPRewardedAds *)sharedInstance
{
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        gSharedInstance = [[self alloc] init];
    });

    return gSharedInstance;
}

#pragma mark - MPRewardedAdManagerDelegate

- (void)rewardedAdDidLoadForAdManager:(MPRewardedAdManager *)manager
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdDidLoadForAdUnitID:)]) {
        [delegate rewardedAdDidLoadForAdUnitID:manager.adUnitId];
    }
}

- (void)rewardedAdDidFailToLoadForAdManager:(MPRewardedAdManager *)manager error:(NSError *)error
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdDidFailToLoadForAdUnitID:error:)]) {
        [delegate rewardedAdDidFailToLoadForAdUnitID:manager.adUnitId error:error];
    }
}

- (void)rewardedAdDidExpireForAdManager:(MPRewardedAdManager *)manager
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdDidExpireForAdUnitID:)]) {
        [delegate rewardedAdDidExpireForAdUnitID:manager.adUnitId];
    }
}

- (void)rewardedAdDidFailToShowForAdManager:(MPRewardedAdManager *)manager error:(NSError *)error
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdDidFailToShowForAdUnitID:error:)]) {
        [delegate rewardedAdDidFailToShowForAdUnitID:manager.adUnitId error:error];
    }
}

- (void)rewardedAdWillAppearForAdManager:(MPRewardedAdManager *)manager
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdWillPresentForAdUnitID:)]) {
        [delegate rewardedAdWillPresentForAdUnitID:manager.adUnitId];
    }
}

- (void)rewardedAdDidAppearForAdManager:(MPRewardedAdManager *)manager
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdDidPresentForAdUnitID:)]) {
        [delegate rewardedAdDidPresentForAdUnitID:manager.adUnitId];
    }
}

- (void)rewardedAdWillDismissForAdManager:(MPRewardedAdManager *)manager
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdWillDismissForAdUnitID:)]) {
        [delegate rewardedAdWillDismissForAdUnitID:manager.adUnitId];
    }
}

- (void)rewardedAdDidDismissForAdManager:(MPRewardedAdManager *)manager
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdDidDismissForAdUnitID:)]) {
        [delegate rewardedAdDidDismissForAdUnitID:manager.adUnitId];
    }

    // Since multiple ad units may be attached to the same network, we should notify the adapters (which should then notify the application)
    // that their ads may not be available anymore since another ad unit might have "played" their ad. We go through and notify all ad managers
    // that are of the type of ad that is playing now.
    Class adapterClass = manager.adapterClass;
    
    for (id key in self.rewardedAdManagers) {
        MPRewardedAdManager *adManager = self.rewardedAdManagers[key];
        
        if (adManager != manager && adManager.adapterClass == adapterClass) {
            [adManager handleAdPlayedForAdapterNetwork];
        }
    }
}

- (void)rewardedAdDidReceiveTapEventForAdManager:(MPRewardedAdManager *)manager
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdDidReceiveTapEventForAdUnitID:)]) {
        [delegate rewardedAdDidReceiveTapEventForAdUnitID:manager.adUnitId];
    }
}

- (void)rewardedAdManager:(MPRewardedAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData
{
    [MoPub sendImpressionNotificationFromAd:nil
                                   adUnitID:manager.adUnitId
                             impressionData:impressionData];
    
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(didTrackImpressionWithAdUnitID:impressionData:)]) {
        [delegate didTrackImpressionWithAdUnitID:manager.adUnitId impressionData:impressionData];
    }
}

- (void)rewardedAdWillLeaveApplicationForAdManager:(MPRewardedAdManager *)manager
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdWillLeaveApplicationForAdUnitID:)]) {
        [delegate rewardedAdWillLeaveApplicationForAdUnitID:manager.adUnitId];
    }
}

- (void)rewardedAdShouldRewardUserForAdManager:(MPRewardedAdManager *)manager reward:(MPReward *)reward
{
    id<MPRewardedAdsDelegate> delegate = [self.delegateTable objectForKey:manager.adUnitId];
    if ([delegate respondsToSelector:@selector(rewardedAdShouldRewardForAdUnitID:reward:)]) {
        [delegate rewardedAdShouldRewardForAdUnitID:manager.adUnitId
                                             reward:reward];
    }
}

#pragma mark - rewarded server to server callback

- (void)startRewardedAdConnectionWithUrl:(NSURL *)url
{
    MPRewardedAdConnection *connection = [[MPRewardedAdConnection alloc] initWithUrl:url delegate:self];
    [self.rewardedAdConnections addObject:connection];
    [connection sendRewardedAdCompletionRequest];
}

#pragma mark - MPRewardedAdConnectionDelegate

- (void)rewardedAdConnectionCompleted:(MPRewardedAdConnection *)connection url:(NSURL *)url
{
    [self.rewardedAdConnections removeObject:connection];
}

@end
