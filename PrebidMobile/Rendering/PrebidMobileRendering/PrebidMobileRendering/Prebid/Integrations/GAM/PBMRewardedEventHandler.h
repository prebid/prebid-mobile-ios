//
//  PBMRewardedEventHandler.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMInterstitialEventHandler.h"

#import "PBMRewardedEventLoadingDelegate.h"
#import "PBMRewardedEventInteractionDelegate.h"

@class BidResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMRewardedEventHandler <PBMInterstitialAd>

@required

/// Delegate for custom event handler to inform the PBM SDK about the events related to the ad server communication.
@property (nonatomic, weak, nullable) id<PBMRewardedEventLoadingDelegate> loadingDelegate;

/// Delegate for custom event handler to inform the PBM SDK about the events related to the user's interaction with the ad.
@property (nonatomic, weak, nullable) id<PBMRewardedEventInteractionDelegate> interactionDelegate;

@end

NS_ASSUME_NONNULL_END
