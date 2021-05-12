//
//  MPRewardedAdManager.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdTargeting.h"
#import "MPImpressionData.h"

@class MPReward;
@protocol MPRewardedAdManagerDelegate;

/**
 `MPRewardedAdManager` represents a rewarded ad for a single ad unit ID. This is the object that
 `MPRewardedAds` uses to load and present the ad.
 */
@interface MPRewardedAdManager : NSObject

@property (nonatomic, weak) id<MPRewardedAdManagerDelegate> delegate;
@property (nonatomic, readonly) NSString *adUnitId;
@property (nonatomic, strong) NSArray *mediationSettings;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, strong) MPAdTargeting *targeting;

/**
 An array of @c MPReward that are available for the rewarded ad that can be selected when presenting the ad.
 */
@property (nonatomic, readonly) NSArray<MPReward *> *availableRewards;

/**
 The currently selected reward that will be awarded to the user upon completion of the ad. By default,
 this corresponds to the first reward in `availableRewards`.
 */
@property (nonatomic, readonly) MPReward *selectedReward;

- (instancetype)initWithAdUnitID:(NSString *)adUnitID delegate:(id<MPRewardedAdManagerDelegate>)delegate;

/**
 Returns the adapter class type.
 */
- (Class)adapterClass;

/**
 Loads a rewarded ad with the ad manager's ad unit ID.

 @param customerId The user's id within the app.
 @param targeting Optional ad targeting parameters.

 However, if an ad has been shown for the last time a load was issued and load is called again, the method will request a new ad.
 */
- (void)loadRewardedAdWithCustomerId:(NSString *)customerId targeting:(MPAdTargeting *)targeting;

/**
 Tells the caller whether the underlying ad network currently has an ad available for presentation.
 */
- (BOOL)hasAdAvailable;

/**
 Shows a rewarded ad.

 @param viewController Presents the rewarded ad from viewController.
 @param reward A reward chosen from `availableRewards` to award the user upon completion.
 This value should not be `nil`. If the reward that is passed in did not come from `availableRewards`,
 this method will not present the rewarded ad and invoke `rewardedAdDidFailToShowForAdManager:error:`.
 @param customData Optional custom data string to include in the server-to-server callback. If a server-to-server callback
 is not used, or if the ad unit is configured for local rewarding, this value will not be persisted.
 */
- (void)presentRewardedAdFromViewController:(UIViewController *)viewController withReward:(MPReward *)reward customData:(NSString *)customData;

/**
 This method is called when another ad unit has shown a rewarded ad from the same network this ad manager's adapter
 represents.
 */
- (void)handleAdPlayedForAdapterNetwork;

@end

@protocol MPRewardedAdManagerDelegate <NSObject>

- (void)rewardedAdDidLoadForAdManager:(MPRewardedAdManager *)manager;
- (void)rewardedAdDidFailToLoadForAdManager:(MPRewardedAdManager *)manager error:(NSError *)error;
- (void)rewardedAdDidExpireForAdManager:(MPRewardedAdManager *)manager;
- (void)rewardedAdDidFailToShowForAdManager:(MPRewardedAdManager *)manager error:(NSError *)error;
- (void)rewardedAdWillAppearForAdManager:(MPRewardedAdManager *)manager;
- (void)rewardedAdDidAppearForAdManager:(MPRewardedAdManager *)manager;
- (void)rewardedAdWillDismissForAdManager:(MPRewardedAdManager *)manager;
- (void)rewardedAdDidDismissForAdManager:(MPRewardedAdManager *)manager;
- (void)rewardedAdDidReceiveTapEventForAdManager:(MPRewardedAdManager *)manager;
- (void)rewardedAdManager:(MPRewardedAdManager *)manager didReceiveImpressionEventWithImpressionData:(MPImpressionData *)impressionData;
- (void)rewardedAdWillLeaveApplicationForAdManager:(MPRewardedAdManager *)manager;
- (void)rewardedAdShouldRewardUserForAdManager:(MPRewardedAdManager *)manager reward:(MPReward *)reward;

@end
