//
//  OXMVideoView.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "OXMVideoViewDelegate.h"
#import "OXMCircularProgressBarView.h"
#import "OXMTrackingEvent.h"

@class OXMEventManager;
@class OXMVideoModel;
@class OXMCreativeModel;
@class OXMVideoCreative;
@class OXMOpenMeasurementSession;

NS_ASSUME_NONNULL_BEGIN
@interface OXMVideoView : UIView <AVAssetResourceLoaderDelegate>

@property (nonatomic, weak, nullable) id<OXMVideoViewDelegate> videoViewDelegate;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong, nullable) OXMCircularProgressBarView *progressBar;

@property (nonatomic, assign, getter=isMuted) BOOL muted;

// Indicates that video reached the VAST Duration
// We must use this flag instead of player’s state to prevent double-stopping of the video due to async work of observers.
@property (nonatomic, assign, readonly) BOOL vastDurationHasEnded;

- (instancetype)initWithEventManager:(OXMEventManager *)eventManager;

- (instancetype)initWithCreative:(OXMVideoCreative *)creative;

- (void)showMediaFileURL:(NSURL *)mediaFileURL preloadedData:(NSData *)preloadedData;

- (void)startPlayback;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)stopWithTrackingEvent:(OXMTrackingEvent)trackingEvent;

- (void)mute;
- (void)unmute;

- (void)btnLearnMoreClick;
- (void)stopOnCloseButton:(OXMTrackingEvent)trackingEvent;

- (void)addFriendlyObstructionsToMeasurementSession:(OXMOpenMeasurementSession *)session;
- (void)updateControls;
- (void)initTimeObserver;
- (void)handleDidPlayToEndTime;
- (CGFloat)handlePeriodicTimeEvent;

- (void)modalManagerDidFinishPop:(OXMModalState*)state;
- (void)modalManagerDidLeaveApp:(OXMModalState*)state;

@end
NS_ASSUME_NONNULL_END
