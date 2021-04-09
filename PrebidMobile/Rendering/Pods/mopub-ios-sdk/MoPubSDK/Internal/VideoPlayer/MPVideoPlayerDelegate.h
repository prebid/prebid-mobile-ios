//
//  MPVideoPlayerDelegate.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPVASTCompanionAdView.h"
#import "MPVASTIndustryIconView.h"
#import "MPVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MPVideoPlayerDelegate <NSObject>

#pragma mark - Video Player View

- (UIViewController *)viewControllerForPresentingModalMRAIDExpandedView;

- (void)videoPlayerDidLoadVideo:(id<MPVideoPlayer>)videoPlayer;

- (void)videoPlayerDidFailToLoadVideo:(id<MPVideoPlayer>)videoPlayer error:(NSError *)error;

- (void)videoPlayerDidStartVideo:(id<MPVideoPlayer>)videoPlayer duration:(NSTimeInterval)duration;

- (void)videoPlayerDidCompleteVideo:(id<MPVideoPlayer>)videoPlayer duration:(NSTimeInterval)duration;

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
videoDidReachProgressTime:(NSTimeInterval)videoProgress
           duration:(NSTimeInterval)duration;

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
    didTriggerEvent:(MPVideoPlayerEvent)event
      videoProgress:(NSTimeInterval)videoProgress;

#pragma mark - Industry Icon View

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didShowIndustryIconView:(MPVASTIndustryIconView *)iconView;

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didClickIndustryIconView:(MPVASTIndustryIconView *)iconView
overridingClickThroughURL:(NSURL * _Nullable)url;

#pragma mark - Companion Ad View

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didShowCompanionAdView:(MPVASTCompanionAdView *)companionAdView;

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didClickCompanionAdView:(MPVASTCompanionAdView *)companionAdView
overridingClickThroughURL:(NSURL * _Nullable)url;

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didFailToLoadCompanionAdView:(MPVASTCompanionAdView *)companionAdView;

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
companionAdViewRequestDismiss:(MPVASTCompanionAdView *)companionAdView;

@end

NS_ASSUME_NONNULL_END
