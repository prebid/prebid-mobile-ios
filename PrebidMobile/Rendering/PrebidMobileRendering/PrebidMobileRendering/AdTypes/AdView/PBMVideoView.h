//
//  PBMVideoView.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

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

// Indicates that video reached the VAST Duration
// We must use this flag instead of player’s state to prevent double-stopping of the video due to async work of observers.
@property (nonatomic, assign, readonly) BOOL vastDurationHasEnded;

- (instancetype)initWithEventManager:(PBMEventManager *)eventManager;

- (instancetype)initWithCreative:(PBMVideoCreative *)creative;

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
