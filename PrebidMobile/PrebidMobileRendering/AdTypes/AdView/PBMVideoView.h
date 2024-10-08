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
#import "PBMCircularProgressBarView.h"
#import "PBMTrackingEvent.h"

@class PBMEventManager;
@class PBMVideoModel;
@class PBMCreativeModel;
@class PBMVideoCreative;
@class PBMOpenMeasurementSession;

NS_ASSUME_NONNULL_BEGIN
@interface PBMVideoView : UIView <AVAssetResourceLoaderDelegate>

@property (nonatomic, weak, nullable) id<PBMVideoViewDelegate> videoViewDelegate;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong, nullable) PBMCircularProgressBarView *progressBar;

@property (nonatomic, assign, getter=isMuted) BOOL muted;
@property (nonatomic, assign) BOOL showLearnMore;

// Indicates that video reached the VAST Duration
// We must use this flag instead of player’s state to prevent double-stopping of the video due to async work of observers.
@property (nonatomic, assign, readonly) BOOL isPlaybackFinished;

@property (nonatomic, assign) BOOL isSoundButtonVisible;

- (instancetype)initWithEventManager:(PBMEventManager *)eventManager;

- (instancetype)initWithCreative:(PBMVideoCreative *)creative;

- (void)updateLearnMoreButton;

- (void)showMediaFileURL:(NSURL *)mediaFileURL preloadedData:(NSData *)preloadedData;

- (void)startPlayback;
- (void)pause;
- (void)resume;
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

- (void)modalManagerDidFinishPop:(PBMModalState*)state;
- (void)modalManagerDidLeaveApp:(PBMModalState*)state;

@end
NS_ASSUME_NONNULL_END
