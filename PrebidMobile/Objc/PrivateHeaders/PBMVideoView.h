/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PBMVideoViewDelegate.h"
#import "PBMVideoViewPlaybackState.h"
#import "PBMCircularProgressBarView.h"

@class PBMEventManager;
@class PBMVideoModel;
@class PBMCreativeModel;
@class PBMVideoCreative;
@class PBMOpenMeasurementSession;
@protocol PBMModalState;
typedef NS_ENUM(NSInteger, PBMTrackingEvent); // Forward declaration of Swift-defined enum

NS_ASSUME_NONNULL_BEGIN
@interface PBMVideoView : UIView <AVAssetResourceLoaderDelegate>

@property (nonatomic, weak, nullable) id<PBMVideoViewDelegate> videoViewDelegate;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong, nullable) PBMCircularProgressBarView *progressBar;

@property (nonatomic, assign, getter=isMuted) BOOL muted;
@property (nonatomic, assign) BOOL showLearnMore;

@property (nonatomic, assign, readonly) PBMVideoViewPlaybackState playbackState;

@property (nonatomic, assign) BOOL isSoundButtonVisible;

- (instancetype)initWithEventManager:(PBMEventManager *)eventManager;

- (instancetype)initWithCreative:(PBMVideoCreative *)creative;

- (void)updateLearnMoreButton;

- (void)showMediaFileURL:(NSURL *)mediaFileURL preloadedData:(NSData *)preloadedData;

- (void)startPlayback;
- (void)pause;
- (void)resume;

/// Pauses playback because the ad view left the viewport.
/// Does nothing unless the video is currently playing, so that a pause
/// made for another reason (clickthrough, background) is not overwritten.
- (void)pauseForVisibilityChange;

/// Resumes playback that was paused by `pauseForVisibilityChange`.
/// Does nothing if the video was paused for any other reason.
- (void)resumeAfterVisibilityChange;

- (void)stop;
- (void)stopWithTrackingEvent:(PBMTrackingEvent)trackingEvent;

- (void)mute;
- (void)unmute;

- (void)btnLearnMoreClick;
- (void)stopOnCloseButton:(PBMTrackingEvent)trackingEvent;

- (void)addFriendlyObstructionsToMeasurementSession:(PBMOpenMeasurementSession *)session;
- (void)updateControls;
- (void)initTimeObserver;
- (void)handleDidPlayToEndTime;
- (CGFloat)handlePeriodicTimeEvent;

- (void)modalManagerDidFinishPop:(id<PBMModalState>)state;
- (void)modalManagerDidLeaveApp:(id<PBMModalState>)state;

@end
NS_ASSUME_NONNULL_END
