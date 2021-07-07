//
//  MPRewardedAds.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPImpressionData.h"

@class MPReward;
@protocol MPRewardedAdsDelegate;

/**
 @c MPRewardedAds allows you to load and play rewarded ads. All ad events are reported,
 with an ad unit ID, to the delegate allowing the application to respond to the events
 for the corresponding ad.
 */
@interface MPRewardedAds : NSObject

/**
 Sets the delegate that will be the receiver of rewarded ads events for the given
 ad unit ID.
 @remark A weak reference to the delegate will be held.
 @param delegate Delegate that will receive rewarded ads events for the ad unit ID.
 @param adUnitId Ad unit ID
 */
+ (void)setDelegate:(id<MPRewardedAdsDelegate>)delegate forAdUnitId:(NSString *)adUnitId;

/**
 Removes the delegate as a receiver of rewarded ad events for all available ad unit IDs.
 @param delegate Reference to the delegate to remove as a listener.
 */
+ (void)removeDelegate:(id<MPRewardedAdsDelegate>)delegate;

/**
 Removes the rewarded ads delegate that is associated with the ad unit ID.
 @param adUnitId Ad unit ID of the delegate to remove.
 */
+ (void)removeDelegateForAdUnitId:(NSString *)adUnitId;

/**
 Loads a rewarded ad for the given ad unit ID.

 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.

 @param adUnitID The ad unit ID that ads should be loaded from.
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.
 */
+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID withMediationSettings:(NSArray *)mediationSettings;

/**
 Loads a rewarded ad for the given ad unit ID.

 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.

 @param adUnitID The ad unit ID that ads should be loaded from.
 @param keywords A string representing a set of non-personally identifiable keywords that should be passed to the MoPub ad server to receive more relevant advertising.
 @param userDataKeywords A string representing a set of personally identifiable keywords that should be passed to the MoPub ad server to receive
 more relevant advertising.
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.

 Note: If a user is in General Data Protection Regulation (GDPR) region and MoPub doesn't obtain consent from the user, "keywords" will be sent to the server but "userDataKeywords" will be excluded.
 */
+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords mediationSettings:(NSArray *)mediationSettings;

/**
 Loads a rewarded ad for the given ad unit ID.

 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.

 @param adUnitID The ad unit ID that ads should be loaded from.
 @param keywords A string representing a set of non-personally identifiable keywords that should be passed to the MoPub ad server to receive more relevant advertising.
 @param userDataKeywords A string representing a set of personally identifiable keywords that should be passed to the MoPub ad server to receive
 more relevant advertising.
 @param customerId This is the ID given to the user by the publisher to identify them in their app
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.

 Note: If a user is in General Data Protection Regulation (GDPR) region and MoPub doesn't obtain consent from the user, "keywords" will be sent to the server but "userDataKeywords" will be excluded.
 */
+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings;

/**
 Loads a rewarded ad for the given ad unit ID.

 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.

 @param adUnitID The ad unit ID that ads should be loaded from.
 @param keywords A string representing a set of non-personally identifiable keywords that should be passed to the MoPub ad server to receive more relevant advertising.
 @param userDataKeywords A string representing a set of personally identifiable keywords that should be passed to the MoPub ad server to receive
 more relevant advertising.
 @param customerId This is the ID given to the user by the publisher to identify them in their app
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.
 @param localExtras An optional dictionary containing extra local data.

 Note: If a user is in General Data Protection Regulation (GDPR) region and MoPub doesn't obtain consent from the user, "keywords" will be sent to the server but "userDataKeywords" will be excluded.
 */
+ (void)loadRewardedAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings localExtras:(NSDictionary *)localExtras;

/**
 Returns whether or not an ad is available for the given ad unit ID.

 @param adUnitID The ad unit ID associated with the ad you want to retrieve the availability for.
 */
+ (BOOL)hasAdAvailableForAdUnitID:(NSString *)adUnitID;

/**
 Returns an array of @c MPReward that are available for the given ad unit ID.
 */
+ (NSArray *)availableRewardsForAdUnitID:(NSString *)adUnitID;

/**
 The currently selected reward that will be awarded to the user upon completion of the ad. By default,
 this corresponds to the first reward in `availableRewardsForAdUnitID:`.
 */
+ (MPReward *)selectedRewardForAdUnitID:(NSString *)adUnitID;

/**
 Shows a rewarded ad.

 @param adUnitID The ad unit ID associated with the ad you wish to play.
 @param viewController The view controller that will present the rewarded ad.
 @param reward A reward selected from `availableRewardsForAdUnitID:` to award the user upon successful completion of the ad.
 This value should not be `nil`.

 @warning **Important**: You should not attempt to play the rewarded ad unless `+hasAdAvailableForAdUnitID:` indicates that an
 ad is available for playing or you have received the `[-rewardedAdDidLoadForAdUnitID:]([MPRewardedAdsDelegate rewardedAdDidLoadForAdUnitID:])`
 message.
 */
+ (void)presentRewardedAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController withReward:(MPReward *)reward;

/**
 Shows a rewarded ad.

 @param adUnitID The ad unit ID associated with the ad you wish to play.
 @param viewController The view controller that will present the rewarded ad.
 @param reward A reward selected from `availableRewardsForAdUnitID:` to award the user upon successful completion of the ad.
 This value should not be `nil`.
 @param customData Optional custom data string to include in the server-to-server callback. If a server-to-server callback
 is not used, or if the ad unit is configured for local rewarding, this value will not be persisted.

 @warning **Important**: You should not attempt to play the rewarded ad unless `+hasAdAvailableForAdUnitID:` indicates that an
 ad is available for playing or you have received the `[-rewardedAdDidLoadForAdUnitID:]([MPRewardedAdsDelegate rewardedAdDidLoadForAdUnitID:])`
 message.
 */
+ (void)presentRewardedAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController withReward:(MPReward *)reward customData:(NSString *)customData;

@end

@protocol MPRewardedAdsDelegate <NSObject>

@optional

/**
 This method is called after an ad loads successfully.

 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedAdDidLoadForAdUnitID:(NSString *)adUnitID;

/**
 This method is called after an ad fails to load.

 @param adUnitID The ad unit ID of the ad associated with the event.
 @param error An error indicating why the ad failed to load.
 */
- (void)rewardedAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error;

/**
 This method is called when a previously loaded rewarded ad is no longer eligible for presentation.

 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedAdDidExpireForAdUnitID:(NSString *)adUnitID;

/**
 This method is called when an attempt to show a rewarded ad fails.

 @param adUnitID The ad unit ID of the ad associated with the event.
 @param error An error describing why the ad wouldn't show.
 */
- (void)rewardedAdDidFailToShowForAdUnitID:(NSString *)adUnitID error:(NSError *)error;

/**
 This method is called when a rewarded ad is about to present.

 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedAdWillPresentForAdUnitID:(NSString *)adUnitID;

/**
 This method is called when a rewarded ad has presented.

 Your implementation of this method should pause any application activity that requires user
 interaction.

 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedAdDidPresentForAdUnitID:(NSString *)adUnitID;

/**
 This method is called when a rewarded ad will be dismissed.

 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedAdWillDismissForAdUnitID:(NSString *)adUnitID;

/**
 This method is called when a rewarded ad has been dismissed.

 Your implementation of this method should resume any application activity that was paused
 prior to the interstitial being presented on-screen.

 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedAdDidDismissForAdUnitID:(NSString *)adUnitID;

/**
 This method is called when the user taps on the ad.

 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID;

/**
 This method is called when a rewarded ad will cause the user to leave the application.

 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID;

/**
 This method is called when the user should be rewarded for watching a rewarded ad.

 @param adUnitID The ad unit ID of the ad associated with the event.
 @param reward The object that contains all the information regarding how much you should reward the user.
 */
- (void)rewardedAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPReward *)reward;

/**
 Called when an impression is fired on a rewarded ad. Includes information about the impression if applicable.
 
 @param adUnitID The ad unit ID of the rewarded ad that fired the impression.
 @param impressionData Information about the impression, or @c nil if the server didn't return any information.
 */
- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData;

@end
