//
//  OXARewardedEventHandler.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAInterstitialEventHandler.h"

#import "OXARewardedEventLoadingDelegate.h"
#import "OXARewardedEventInteractionDelegate.h"

@class OXABidResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol OXARewardedEventHandler <OXAInterstitialEventHandler>

@required

/// Delegate for custom event handler to inform the OXA SDK about the events related to the ad server communication.
@property (nonatomic, weak, nullable) id<OXARewardedEventLoadingDelegate> loadingDelegate;

/// Delegate for custom event handler to inform the OXA SDK about the events related to the user's interaction with the ad.
@property (nonatomic, weak, nullable) id<OXARewardedEventInteractionDelegate> interactionDelegate;

@end

NS_ASSUME_NONNULL_END
