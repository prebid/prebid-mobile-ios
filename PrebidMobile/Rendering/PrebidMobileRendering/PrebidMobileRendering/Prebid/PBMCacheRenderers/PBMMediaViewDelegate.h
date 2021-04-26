//
//  PBMMediaViewDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class PBMMediaView;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMMediaViewDelegate <NSObject>

@required

- (void)onMediaPlaybackStarted:(PBMMediaView *)mediaView;
- (void)onMediaPlaybackFinished:(PBMMediaView *)mediaView;

- (void)onMediaPlaybackPaused:(PBMMediaView *)mediaView;
- (void)onMediaPlaybackResumed:(PBMMediaView *)mediaView;

- (void)onMediaPlaybackMuted:(PBMMediaView *)mediaView;
- (void)onMediaPlaybackUnmuted:(PBMMediaView *)mediaView;

- (void)onMediaLoadingFinished:(PBMMediaView *)mediaView;

@end

NS_ASSUME_NONNULL_END
