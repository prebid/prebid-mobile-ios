//
//  MPVideoPlayerView.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPVideoPlayer.h"
#import "MPViewableView.h"

NS_ASSUME_NONNULL_BEGIN

// Forward declaration
@protocol MPVideoPlayerViewDelegate;

/**
 @c MPVideoPlayerView only allows start playing without pause, reset, nor fast forwarding. Video is
 only paused automatically due to app life cycle events or user interactions such as click-throughs.

 Note: The actually video duration is honored as the source of truth, while the video duration
 provided by the @c MPVideoConfig is ignored.
 */
@interface MPVideoPlayerView : MPViewableView <MPVideoPlayer>

/**
 Callback delegate.
 */
@property (nonatomic, weak) id<MPVideoPlayerViewDelegate> delegate;

/**
 Indicates whether a video is currently loaded in the player.
 @note Once set to @c YES, this value will never set back to @c NO.
 */
@property (nonatomic, readonly) BOOL isVideoLoaded;

/**
 Indicates that a video is currently playing.
 @note Once set to @c YES, this value will never set back to @c NO.
 */
@property (nonatomic, readonly) BOOL isVideoPlaying;

/**
 Video duration in seconds.
 */
@property (nonatomic, readonly) NSTimeInterval videoDuration;

/**
 Video progress in seconds.
 */
@property (nonatomic, readonly) NSTimeInterval videoProgress;

/**
 The audio playback volume for the player.
 A value of 0.0 indicates silence; a value of 1.0 (the default) indicates full audio volume for the player instance.
 */
@property (nonatomic, readonly) float videoVolume;

@end

#pragma mark - MPVideoPlayerViewDelegate

@protocol MPVideoPlayerViewDelegate <NSObject>

/**
 Video successfully loaded by @c videoPlayerView.
 @param videoPlayerView Video player view.
 */
- (void)videoPlayerViewDidLoadVideo:(MPVideoPlayerView *)videoPlayerView;

/**
 Video failed to load in @c videoPlayerView.
 @param videoPlayerView Video player view.
 @param error Error that occurred.
 */
- (void)videoPlayerViewDidFailToLoadVideo:(MPVideoPlayerView *)videoPlayerView error:(NSError *)error;

/**
 Video playback started in @c videoPlayerView.
 @param videoPlayerView Video player view.
 @param duration Duration of the video in seconds.
 */
- (void)videoPlayerViewDidStartVideo:(MPVideoPlayerView *)videoPlayerView duration:(NSTimeInterval)duration;

/**
 Video playback completed in @c videoPlayerView.
 @param videoPlayerView Video player view.
 @param duration Duration of the video in seconds.
 */
- (void)videoPlayerViewDidCompleteVideo:(MPVideoPlayerView *)videoPlayerView duration:(NSTimeInterval)duration;

/**
 Video playback reached @c videoProgress seconds into the @c duration video played  in @c videoPlayerView.
 @param videoPlayerView Video player view.
 @param videoProgress Video progress in seconds.
 @param duration Duration of the video in seconds.
 */
- (void)videoPlayerView:(MPVideoPlayerView *)videoPlayerView
videoDidReachProgressTime:(NSTimeInterval)videoProgress
               duration:(NSTimeInterval)duration;

/**
 Video player @c videoPlayerView triggered a @c event at @c videoProgress seconds.
 @param videoPlayerView Video player view.
 @param event Video event that triggered.
 @param videoProgress Video progress in seconds.
 */
- (void)videoPlayerView:(MPVideoPlayerView *)videoPlayerView
        didTriggerEvent:(MPVideoEvent)event
          videoProgress:(NSTimeInterval)videoProgress;

/**
 Video player @c videoPlayerView showed the industry icon associated with the video.
 @param videoPlayerView Video player view.
 @param icon Industry icon.
 */
- (void)videoPlayerView:(MPVideoPlayerView *)videoPlayerView
       showIndustryIcon:(MPVASTIndustryIcon *)icon;

/**
 Video player @c videoPlayerView hid the industry icon associated with the video.
 @param videoPlayerView Video player view.
 */
- (void)videoPlayerViewHideIndustryIcon:(MPVideoPlayerView *)videoPlayerView;

@end

NS_ASSUME_NONNULL_END
