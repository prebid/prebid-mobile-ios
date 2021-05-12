//
//  MPAdAdapter.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdAdapterDelegate.h"
#import "MPAnalyticsTracker.h"
#import "MPAdConfiguration.h"
#import "MPAdTargeting.h"

@protocol MPAdAdapter <NSObject>

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, readonly) MPAdConfiguration *configuration;
@property (nonatomic, weak) id<MPAdAdapterBaseDelegate> adapterDelegate;
@property (nonatomic, strong) id<MPAnalyticsTracker> analyticsTracker;

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration targeting:(MPAdTargeting *)targeting;

@optional

#pragma mark - Inline only

@property (nonatomic, strong) UIView * adView;
- (void)didPresentInlineAd;
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

#pragma mark - Fullscreen only

/**
Optional custom data string to include in the server-to-server callback. If a server-to-server callback
is not used, or if the ad unit is configured for local rewarding, this value will not be persisted.
*/
@property (nonatomic, copy) NSString *customData;

- (void)showFullscreenAdFromViewController:(UIViewController *)viewController;

- (void)expireAdapter;

#pragma mark - Rewarded only

/**
 Tells the caller whether the underlying ad network currently has an ad available for presentation.
 */
@property (nonatomic, readonly) BOOL hasAdAvailable;

/**
 This method is called when another ad unit has played a rewarded ad from the same
 network this adapter represents.
 */
- (void)handleDidPlayAd;

@end
