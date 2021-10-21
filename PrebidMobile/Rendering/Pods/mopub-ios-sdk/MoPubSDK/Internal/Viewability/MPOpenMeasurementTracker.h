//
//  MPOpenMeasurementTracker.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdContainerView.h"
#import "MPVideoConfig.h"
#import "MPViewabilityContext.h"
#import "MPViewabilityObstruction.h"
#import "MPViewabilityTracker.h"
#import "MPWebView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Open Measurement Viewability tracker
 */
@interface MPOpenMeasurementTracker : NSObject<MPViewabilityTracker>

#pragma mark - Initialization

/**
 Initializes the tracker for WebView-based creatives.
 @param webview Web view instance to track.
 @param containerView The ad container view that includes @c webView as part of the view hierarchy.
 @param obstructions Optional set of view obstructions that should not be considered as part of the Viewability calculation.
 @returns An instance of the tracker or @c nil if Viewability is not initialized or is disabled.
 */
- (instancetype)initWithWebView:(MPWebView *)webview
                containedInView:(UIView *)containerView
           friendlyObstructions:(NSSet<UIView<MPViewabilityObstruction> *> * _Nullable)obstructions;

/**
 Initializes the tracker for VAST video creatives.
 @param videoPlayerContainerView The view that contains the VAST video player in the view hierarchy, in addition to
 all UI elements considered as friendly obstructions.
 @param videoConfig VAST video configuration that contains a Viewability context.
 @returns An instance of the tracker or @c nil if Viewability is not initialized or is disabled.
 */
- (instancetype)initWithVASTPlayerView:(MPAdContainerView *)videoPlayerContainerView
                           videoConfig:(MPVideoConfig *)videoConfig;

/**
 Initializes the tracker for natively rendered ads.
 @note Web view and VAST creatives should use their specific initializers.
 @param view Native view to track.
 @param context Tracking context for the ad.
 @param obstructions Optional set of view obstructions that should not be considered as part of the Viewability calculation.
 */
- (instancetype)initWithNativeView:(UIView *)view
                    trackerContext:(MPViewabilityContext *)context
              friendlyObstructions:(NSSet<UIView<MPViewabilityObstruction> *> * _Nullable)obstructions;

#pragma mark - Unavailable

/**
 These initializers are not available
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
