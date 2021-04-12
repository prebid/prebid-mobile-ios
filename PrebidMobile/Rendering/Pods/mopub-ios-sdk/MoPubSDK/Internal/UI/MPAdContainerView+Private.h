//
//  MPAdContainerView+Private.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdContainerView.h"
#import "MPAdViewOverlay.h"
#import "MPVASTCompanionAdView.h"
#import "MPVideoConfig.h"
#import "MPVideoPlayerView.h"
#import "MPViewableVisualEffectView.h"
#import "MPWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPAdContainerView ()
@property (nonatomic, assign) BOOL isVideoFinished; // default to NO

@property (nonatomic, strong) MPAdViewOverlay *overlay;
@property (nonatomic, strong) MPWebView *webContentView;

#pragma mark - Video
/**
 Video configuration containing the video asset to render and video player settings.
 */
@property (nonatomic, strong) MPVideoConfig *videoConfig;

/**
 View responsible for rendering the VAST video player. This is optional since the creative may not
 have a video to render.
 */
@property (nonatomic, strong, nullable) MPVideoPlayerView *videoPlayerView;

/**
 Optional comapnion ad to render.
 */
@property (nonatomic, strong, nullable) MPVASTCompanionAdView *companionAdView;

/**
 Autolayout constraints for the companion ad.
 @see @c updateConstraints
 */
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *companionAdViewEdgeConstraints;

/**
 Blur effect that is applied to the last frame of the video when there is no companion ad to show at the end
 of the video.
 @note: This is a friendly obstruction and conforms to @c MPViewabilityObstruction
 */
@property (nonatomic, strong) MPViewableVisualEffectView *blurEffectView;

@end

NS_ASSUME_NONNULL_END
