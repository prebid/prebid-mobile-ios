//
//  MPAdContainerView.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdViewConstant.h"
#import "MPCountdownTimerDelegate.h"
#import "MPVideoPlayer.h"
#import "MPVideoPlayerDelegate.h"
#import "MPVideoPlayerView.h"
#import "MPViewableView.h"
#import "MPWebView.h"

NS_ASSUME_NONNULL_BEGIN

@class MPImageCreativeView;

@protocol MPAdContainerViewWebAdDelegate;

/**
 This is the unified ad container view for all inline and fullscreen ad formats. Ad content view is
 added as a subview. An overlay with all the accessory views (Close, Skip, Countdown timer, CTA)
 is always also added as a subview. This overlay is always on top of the content view, and is able to
 intercept all touch events before passing to the content view.
 */
@interface MPAdContainerView : MPViewableView

@property (nonatomic, assign) NSTimeInterval skipOffset;
@property (nonatomic, readonly) BOOL wasTapped;
@property (nonatomic, weak) id<MPAdContainerViewWebAdDelegate> webAdDelegate; // only for web ads
@property (nonatomic, weak) id<MPVideoPlayerDelegate> videoPlayerDelegate; // only for video ads
@property (nonatomic, weak) id<MPCountdownTimerDelegate> countdownTimerDelegate;

/**
 Initializes @c MPAdContainerView to a given frame with a given web content view.

 @param frame The frame of the view
 @param webContentView The web view that will contain the content of the ad
 */
- (instancetype)initWithFrame:(CGRect)frame webContentView:(MPWebView *)webContentView;

/**
 Initializes @c MPAdContainerView to a given frame with a given image content view.

 @param frame The frame of the view
 @param imageCreativeView The image view that will contain the content of the ad
 */
- (instancetype)initWithFrame:(CGRect)frame imageCreativeView:(MPImageCreativeView *)imageCreativeView;

/**
 Provided the ad size and Close button location, returns the frame of the Close button.
 Note: The provided ad size is assumed to be at least 50x50 (@c kMPAdViewCloseButtonSize), otherwise
 the return value is undefined.

 @param adSize The size of the ad.
 @param location The location of the close button.
 */
+ (CGRect)closeButtonFrameForAdSize:(CGSize)adSize atLocation:(MPAdViewCloseButtonLocation)location;

/**
 Set the Close button location with UI update.
 */
- (void)setCloseButtonLocation:(MPAdViewCloseButtonLocation)closeButtonLocation;

/**
 Set the Close button location with UI update.
 */
- (void)setCloseButtonType:(MPAdViewCloseButtonType)closeButtonType;

/**
 Show the countdown timer.
 */
- (void)showCountdownTimer:(NSTimeInterval)duration;

/**
 Pauses the countdown timer.
 */
- (void)pauseCountdownTimer;

/**
 Resumes a paused countdown timer.
 */
- (void)resumeCountdownTimer;

@end

#pragma mark -

@interface MPAdContainerView (MPVideoPlayer) <MPVideoPlayer>
@property (nonatomic, readonly) MPVideoPlayerView *videoPlayerView;
@end

#pragma mark -

@protocol MPAdContainerViewWebAdDelegate <NSObject>

/**
 For Close button action handling.
 Note: If  @c videoPlayerDelegate is assigned, and @c MPVideoPlayerEvent_Close happens,
 @c MPVideoPlayerDelegate.videoPlayer:didTriggerEvent:videoProgress: is called instead.
 */
- (void)adContainerViewDidHitCloseButton:(MPAdContainerView *)adContainerView;

@optional

/**
 Typically for MRAID two-part ad creative resizing.
 */
- (void)adContainerView:(MPAdContainerView *)adContainerView didMoveToWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
