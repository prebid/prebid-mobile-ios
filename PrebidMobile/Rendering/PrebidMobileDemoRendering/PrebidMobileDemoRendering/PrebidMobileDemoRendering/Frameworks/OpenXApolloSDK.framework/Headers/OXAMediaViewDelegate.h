//
//  OXAMediaViewDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class OXAMediaView;

NS_ASSUME_NONNULL_BEGIN

@protocol OXAMediaViewDelegate <NSObject>

@required

- (void)onMediaPlaybackStarted:(OXAMediaView *)mediaView;
- (void)onMediaPlaybackFinished:(OXAMediaView *)mediaView;

- (void)onMediaPlaybackPaused:(OXAMediaView *)mediaView;
- (void)onMediaPlaybackResumed:(OXAMediaView *)mediaView;

- (void)onMediaPlaybackMuted:(OXAMediaView *)mediaView;
- (void)onMediaPlaybackUnmuted:(OXAMediaView *)mediaView;

- (void)onMediaLoadingFinished:(OXAMediaView *)mediaView;

@end

NS_ASSUME_NONNULL_END
