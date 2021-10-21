//
//  MPRewardedVideo.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPImpressionData.h"

@class MPReward;
@class MPRewardedVideoReward;
@class CLLocation;
@protocol MPRewardedVideoDelegate;

/**
 Notice:
 @c MPRewardedVideo is deprecated and will be removed in a future version. Use
 @c MPRewardedAds instead.

 @c MPRewardedVideo allows you to load and play rewarded video ads. All ad events are
 reported, with an ad unit ID, to the delegate allowing the application to respond to the events
 for the corresponding ad.
 */
DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo is deprecated. Please use MPRewardedAds instead.")
@interface MPRewardedVideo : NSObject

/**
 Sets the delegate that will be the receiver of rewarded video events for the given
 ad unit ID.
 @remark A weak reference to the delegate will be held.
 @deprecated This API is deprecated and will be removed in a future version.
 @param delegate Delegate that will recieve rewarded video events for the ad unit ID.
 @param adUnitId Ad unit ID
 */
+ (void)setDelegate:(id<MPRewardedVideoDelegate>)delegate forAdUnitId:(NSString *)adUnitId DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.setDelegate:forAdUnitId: is deprecated and will be removed in a future version. Use MPRewardedAds.setDelegate:forAdUnitId: instead.");

/**
 Removes the delegate as a receiver of rewarded video events for all available ad unit IDs.
 @deprecated This API is deprecated and will be removed in a future version.
 @param delegate Reference to the delegate to remove as a listener.
 */
+ (void)removeDelegate:(id<MPRewardedVideoDelegate>)delegate DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.removeDelegate: is deprecated and will be removed in a future version. Use MPRewardedAds.removeDelegate: instead.");

/**
 Removes the rewarded video delegate that is associated with the ad unit ID.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitId Ad unit ID of the delegate to remove.
 */
+ (void)removeDelegateForAdUnitId:(NSString *)adUnitId DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.removeDelegateForAdUnitId: is deprecated and will be removed in a future version. Use MPRewardedAds.removeDelegateForAdUnitId: instead.");

/**
 Loads a rewarded video ad for the given ad unit ID.
 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID that ads should be loaded from.
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withMediationSettings:(NSArray *)mediationSettings DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.loadRewardedVideoAdWithAdUnitID:withMediationSettings: is deprecated and will be removed in a future version. Use MPRewardedAds.loadRewardedAdWithAdUnitID:withMediationSettings: instead.");

/**
 Loads a rewarded video ad for the given ad unit ID.
 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID that ads should be loaded from.
 @param keywords A string representing a set of non-personally identifiable keywords that should be passed to the MoPub ad server to receive more relevant advertising.
 @param userDataKeywords A string representing a set of personally identifiable keywords that should be passed to the MoPub ad server to receive
 more relevant advertising.
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.
 Note: If a user is in General Data Protection Regulation (GDPR) region and MoPub doesn't obtain consent from the user, "keywords" will be sent to the server but "userDataKeywords" will be excluded.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords mediationSettings:(NSArray *)mediationSettings DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.loadRewardedVideoAdWithAdUnitID:keywords:userDataKeywords:mediationSettings: is deprecated and will be removed in a future version. Use MPRewardedAds.loadRewardedAdWithAdUnitID:keywords:userDataKeywords:mediationSettings: instead.");

/**
 Loads a rewarded video ad for the given ad unit ID.
 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID that ads should be loaded from.
 @param keywords A string representing a set of non-personally identifiable keywords that should be passed to the MoPub ad server to receive more relevant advertising.
 @param userDataKeywords A string representing a set of personally identifiable keywords that should be passed to the MoPub ad server to receive
 more relevant advertising.
 @param location Latitude/Longitude that are passed to the MoPub ad server
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.
 Note: If a user is in General Data Protection Regulation (GDPR) region and MoPub doesn't obtain consent from the user, "keywords" will be sent to the server but "userDataKeywords" will be excluded.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords location:(CLLocation *)location mediationSettings:(NSArray *)mediationSettings DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.loadRewardedVideoAdWithAdUnitID:keywords:userDataKeywords:location:mediationSettings: is deprecated and will be removed in a future version. Use MPRewardedAds.loadRewardedAdWithAdUnitID:keywords:userDataKeywords:mediationSettings: instead.");

/**
 Loads a rewarded video ad for the given ad unit ID.
 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID that ads should be loaded from.
 @param keywords A string representing a set of non-personally identifiable keywords that should be passed to the MoPub ad server to receive more relevant advertising.
 @param userDataKeywords A string representing a set of personally identifiable keywords that should be passed to the MoPub ad server to receive
 more relevant advertising.
 @param customerId This is the ID given to the user by the publisher to identify them in their app
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.
 Note: If a user is in General Data Protection Regulation (GDPR) region and MoPub doesn't obtain consent from the user, "keywords" will be sent to the server but "userDataKeywords" will be excluded.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.loadRewardedVideoAdWithAdUnitID:keywords:userDataKeywords:customerId:mediationSettings: is deprecated and will be removed in a future version. Use MPRewardedAds.loadRewardedAdWithAdUnitID:keywords:userDataKeywords:customerId:mediationSettings: instead.");

/**
 Loads a rewarded video ad for the given ad unit ID.
 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID that ads should be loaded from.
 @param keywords A string representing a set of non-personally identifiable keywords that should be passed to the MoPub ad server to receive more relevant advertising.
 @param userDataKeywords A string representing a set of personally identifiable keywords that should be passed to the MoPub ad server to receive
 more relevant advertising.
 @param location Latitude/Longitude that are passed to the MoPub ad server
 @param customerId This is the ID given to the user by the publisher to identify them in their app
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.
 Note: If a user is in General Data Protection Regulation (GDPR) region and MoPub doesn't obtain consent from the user, "keywords" will be sent to the server but "userDataKeywords" will be excluded.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords location:(CLLocation *)location customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.loadRewardedVideoAdWithAdUnitID:keywords:userDataKeywords:location:customerId:mediationSettings: is deprecated and will be removed in a future version. Use MPRewardedAds.loadRewardedAdWithAdUnitID:keywords:userDataKeywords:customerId:mediationSettings: instead.");

/**
 Loads a rewarded video ad for the given ad unit ID.
 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.
 @deprecated This API is deprecated and will be removed in a future version.
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
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings localExtras:(NSDictionary *)localExtras DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.loadRewardedVideoAdWithAdUnitID:keywords:userDataKeywords:customerId:mediationSettings:localExtras: is deprecated and will be removed in a future version. Use MPRewardedAds.loadRewardedAdWithAdUnitID:keywords:userDataKeywords:customerId:mediationSettings:localExtras: instead.");

/**
 Loads a rewarded video ad for the given ad unit ID.
 The mediation settings array should contain ad network specific objects for networks that may be loaded for the given ad unit ID.
 You should set the properties on these objects to determine how the underlying ad network should behave. You only need to supply
 objects for the networks you wish to configure. If you do not want your network to behave differently from its default behavior, do
 not pass in an mediation settings object for that network.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID that ads should be loaded from.
 @param keywords A string representing a set of non-personally identifiable keywords that should be passed to the MoPub ad server to receive more relevant advertising.
 @param userDataKeywords A string representing a set of personally identifiable keywords that should be passed to the MoPub ad server to receive
 more relevant advertising.
 @param location Latitude/Longitude that are passed to the MoPub ad server
 @param customerId This is the ID given to the user by the publisher to identify them in their app
 @param mediationSettings An array of mediation settings objects that map to networks that may show ads for the ad unit ID. This array
 should only contain objects for networks you wish to configure. This can be nil.
 @param localExtras An optional dictionary containing extra local data.
 Note: If a user is in General Data Protection Regulation (GDPR) region and MoPub doesn't obtain consent from the user, "keywords" will be sent to the server but "userDataKeywords" will be excluded.
 */
+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID keywords:(NSString *)keywords userDataKeywords:(NSString *)userDataKeywords location:(CLLocation *)location customerId:(NSString *)customerId mediationSettings:(NSArray *)mediationSettings localExtras:(NSDictionary *)localExtras DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.loadRewardedVideoAdWithAdUnitID:keywords:userDataKeywords:location:customerId:mediationSettings:localExtras: is deprecated and will be removed in a future version. Use MPRewardedAds.loadRewardedAdWithAdUnitID:keywords:userDataKeywords:customerId:mediationSettings:localExtras: instead.");

/**
 Returns whether or not an ad is available for the given ad unit ID.
 @param adUnitID The ad unit ID associated with the ad you want to retrieve the availability for.
 @deprecated This API is deprecated and will be removed in a future version.
 */
+ (BOOL)hasAdAvailableForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.hasAdAvailableForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAds.hasAdAvailableForAdUnitID: instead.");

/**
 Returns an array of @c MPRewardedVideoReward that are available for the given ad unit ID.
 @deprecated This API is deprecated and will be removed in a future version.
 */
+ (NSArray *)availableRewardsForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.availableRewardsForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAds.availableRewardsForAdUnitID: instead.");

/**
 The currently selected reward that will be awarded to the user upon completion of the ad. By default,
 this corresponds to the first reward in `availableRewardsForAdUnitID:`.
 @deprecated This API is deprecated and will be removed in a future version.
 */
+ (MPRewardedVideoReward *)selectedRewardForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.selectedRewardForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAds.selectedRewardForAdUnitID: instead.");

/**
 Plays a rewarded video ad.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID associated with the video ad you wish to play.
 @param viewController The view controller that will present the rewarded video ad.
 @param reward A reward selected from `availableRewardsForAdUnitID:` to award the user upon successful completion of the ad.
 This value should not be `nil`.
 @warning **Important**: You should not attempt to play the rewarded video unless `+hasAdAvailableForAdUnitID:` indicates that an
 ad is available for playing or you have received the `[-rewardedVideoAdDidLoadForAdUnitID:]([MPRewardedVideoDelegate rewardedVideoAdDidLoadForAdUnitID:])`
 message.
 */
+ (void)presentRewardedVideoAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController withReward:(MPRewardedVideoReward *)reward DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.presentRewardedVideoAdForAdUnitID:fromViewController:withReward: is deprecated and will be removed in a future version. Use MPRewardedAds.presentRewardedAdForAdUnitID:fromViewController:withReward: instead.");

/**
 Plays a rewarded video ad.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID associated with the video ad you wish to play.
 @param viewController The view controller that will present the rewarded video ad.
 @param reward A reward selected from `availableRewardsForAdUnitID:` to award the user upon successful completion of the ad.
 This value should not be `nil`.
 @param customData Optional custom data string to include in the server-to-server callback. If a server-to-server callback
 is not used, or if the ad unit is configured for local rewarding, this value will not be persisted.
 @warning **Important**: You should not attempt to play the rewarded video unless `+hasAdAvailableForAdUnitID:` indicates that an
 ad is available for playing or you have received the `[-rewardedVideoAdDidLoadForAdUnitID:]([MPRewardedVideoDelegate rewardedVideoAdDidLoadForAdUnitID:])`
 message.
 */
+ (void)presentRewardedVideoAdForAdUnitID:(NSString *)adUnitID fromViewController:(UIViewController *)viewController withReward:(MPRewardedVideoReward *)reward customData:(NSString *)customData DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideo.presentRewardedVideoAdForAdUnitID:fromViewController:withReward:customData: is deprecated and will be removed in a future version. Use MPRewardedAds.presentRewardedAdForAdUnitID:fromViewController:withReward:customData: instead.");

@end

@protocol MPRewardedVideoDelegate <NSObject>

@optional

/**
 This method is called after an ad loads successfully.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdDidLoadForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdDidLoadForAdUnitID: instead.");

/**
 This method is called after an ad fails to load.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 @param error An error indicating why the ad failed to load.
 */
- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdDidFailToLoadForAdUnitID:error: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdDidFailToLoadForAdUnitID:error: instead.");

/**
 This method is called when a previously loaded rewarded video is no longer eligible for presentation.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdDidExpireForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdDidExpireForAdUnitID: instead.");

/**
 This method is called when an attempt to play a rewarded video fails.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 @param error An error describing why the video couldn't play.
 */
- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdDidFailToPlayForAdUnitID:error: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdDidFailToShowForAdUnitID:error: instead.");

/**
 This method is called when a rewarded video ad is about to appear.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdWillAppearForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdWillPresentForAdUnitID: instead.");

/**
 This method is called when a rewarded video ad has appeared.
 Your implementation of this method should pause any application activity that requires user
 interaction.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdDidAppearForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdDidPresentForAdUnitID: instead.");

/**
 This method is called when a rewarded video ad will be dismissed.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdWillDisappearForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdWillDismissForAdUnitID: instead.");

/**
 This method is called when a rewarded video ad has been dismissed.
 Your implementation of this method should resume any application activity that was paused
 prior to the interstitial being presented on-screen.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdDidDisappearForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdDidDismissForAdUnitID: instead.");

/**
 This method is called when the user taps on the ad.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdDidReceiveTapEventForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdDidReceiveTapEventForAdUnitID: instead.");

/**
 This method is called when a rewarded video ad will cause the user to leave the application.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 */
- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdWillLeaveApplicationForAdUnitID: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdWillLeaveApplicationForAdUnitID: instead.");

/**
 This method is called when the user should be rewarded for watching a rewarded video ad.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the ad associated with the event.
 @param reward The object that contains all the information regarding how much you should reward the user.
 */
- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.rewardedVideoAdShouldRewardForAdUnitID:reward: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.rewardedAdShouldRewardForAdUnitID:reward: instead.");

/**
 Called when an impression is fired on a Rewarded Video. Includes information about the impression if applicable.
 @deprecated This API is deprecated and will be removed in a future version.
 @param adUnitID The ad unit ID of the rewarded video that fired the impression.
 @param impressionData Information about the impression, or @c nil if the server didn't return any information.
 */
- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData DEPRECATED_MSG_ATTRIBUTE("MPRewardedVideoDelegate.didTrackImpressionWithAdUnitID:impressionData: is deprecated and will be removed in a future version. Use MPRewardedAdsDelegate.didTrackImpressionWithAdUnitID:impressionData: instead.");

@end
