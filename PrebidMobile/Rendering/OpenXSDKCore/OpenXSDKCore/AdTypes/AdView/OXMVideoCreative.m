//
//  OXMVideoCreative.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVideoCreative.h"
#import "OXMAbstractCreative+Protected.h"

#import "OXMFunctions+Private.h"
#import "UIView+OxmExtensions.h"

#import "OXMAdConfiguration.h"
#import "OXMClickthroughBrowserView.h"
#import "OXMConstants.h"
#import "OXMCreativeModel.h"
#import "OXMDownloadDataHelper.h"
#import "OXMError.h"
#import "OXMEventManager.h"
#import "OXMFunctions.h"
#import "OXMOpenMeasurementWrapper.h"
#import "OXMOpenMeasurementSession.h"
#import "OXMModalManager.h"
#import "OXMVideoView.h"
#import "OXMModalState.h"
#import "OXMMacros.h"
#import "OXMTransaction.h"
#import "OXMCreativeResolutionDelegate.h"
#import "OXMInterstitialDisplayProperties.h"
#import "OXMCreativeViewabilityTracker.h"


#pragma mark - Private Extension

@interface OXMVideoCreative ()

@property (nonatomic, strong) OXMVideoView *videoView;
@property (nonatomic, strong) NSData *data;

@end

#pragma mark - Implementation

@implementation OXMVideoCreative

#pragma mark - Properties

+ (NSInteger)maxSizeForPreRenderContent {
    // 25 MiB
    return 25 * 1024 * 1024;
}

#pragma mark - OXMAbstractCreative

- (instancetype)initWithCreativeModel:(OXMCreativeModel *)creativeModel
                          transaction:(OXMTransaction *)transaction
                            videoData:(NSData *)data {
    self = [super initWithCreativeModel:creativeModel transaction:transaction];
    if (self) {
        OXMAssert(data);

        self.data = data;
        
        self.videoView = [[OXMVideoView alloc] initWithCreative:self];
        self.videoView.videoViewDelegate = self;
        self.view = self.videoView;
    }
    
    return self;
}

- (void)setupView {
    [super setupView];
    [self showVideoViewWithPreloadedData:self.data];
}

- (void)displayWithRootViewController:(UIViewController *)viewController {
    [super displayWithRootViewController:viewController];
    [self.viewabilityTracker start];

    if (self.creativeModel.adConfiguration.isBuiltInVideo && !self.creativeModel.adConfiguration.presentAsInterstitial) {
        [self.videoView mute];
    }
    
    [self.videoView startPlayback];
    [self.videoView OXMAddFillSuperviewConstraints];
}

- (void)showAsInterstitialFromRootViewController:(UIViewController *)uiViewController displayProperties:(OXMInterstitialDisplayProperties *)displayProperties {
    NSNumber *videoDuration = self.creativeModel.displayDurationInSeconds;
    if (!videoDuration) {
        OXMLogWarn(@"Undefined video duration.");
        // TODO: Should we return or show with default duration?
        return;
    }
    
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.videoView unmute];
    });
    
    //Create a copy of the interstitialDisplayProperties and modify the closeDelay to take the video length into account.
    OXMInterstitialDisplayProperties* newDisplayProperties = [self createInterstitialPropertiesForCurrentVideoStateFor:displayProperties];
    [super showAsInterstitialFromRootViewController:uiViewController displayProperties:newDisplayProperties];
}

- (void)onAdDisplayed {
    [super onAdDisplayed];
    [self.viewabilityTracker stop];
    self.viewabilityTracker = NULL;
}

- (void)pause {
    [self.videoView pause];
}

- (void)resume {
    [self.videoView resume];
}

- (void)mute {
    [self.videoView mute];
}

- (void)unmute {
    [self.videoView unmute];
}

- (BOOL)isMuted {
    return self.videoView.isMuted;
}

// Should the concept of "close" or dismiss be moved to OXMAbstractCreative?
- (void)close {
    [self.videoView stopOnCloseButton:OXMTrackingEventCloseLinear];
}

- (BOOL)isPlaybackFinished {
    return self.videoView.vastDurationHasEnded;
}

- (void)createOpenMeasurementSession {
    
    if (self.transaction.adConfiguration.isNative) {
        return;
    }
    
    if (!NSThread.currentThread.isMainThread) {
        OXMLogError(@"Open Measurement session can only be created on the main thread");
        return;
    }
    
    self.transaction.measurementSession = [self.transaction.measurementWrapper
                                          initializeNativeVideoSession:self.videoView
                                                verificationParameters:self.creativeModel.verificationParameters];
    if (self.transaction.measurementSession) {
        [self.videoView addFriendlyObstructionsToMeasurementSession:self.transaction.measurementSession];
        [self.transaction.measurementSession start];
        [self.eventManager registerTracker:self.transaction.measurementSession.eventTracker];
        [self.eventManager trackVideoAdLoaded:[OXMVideoVerificationParameters new]];
    }
}

#pragma mark - OXMVideoViewDelegate

- (void)videoViewCompletedDisplay {
    if ([self.creativeViewDelegate respondsToSelector:@selector(videoCreativeDidComplete:)]) {
        [self.creativeViewDelegate videoCreativeDidComplete:self];
    }
    
    // Companion ad:
    // forward the event to the delegate so that it can display the next creative, if any.
    if (self.creativeModel.hasCompanionAd) {
        [self.creativeViewDelegate creativeDidComplete:self];
        return;
    }
    
    if (self.creativeModel.adConfiguration.presentAsInterstitial) {
        // no companion ads so pass this event to the OXMModalManager
        // and close video automatically
        [self.modalManager creativeDisplayCompleted:self];        
        if (self.dismissInterstitialModalState) {
            self.dismissInterstitialModalState();
        }
    } else {
        [self.creativeViewDelegate creativeDidComplete:self];
    }
}

- (void)videoViewFailedWithError:(NSError *)error {
    [self.creativeResolutionDelegate creativeFailed:error];
}

- (void)videoViewReadyToDisplay {
    [self.creativeResolutionDelegate creativeReady:self];
}

- (void)learnMoreWasClicked {
    [self.creativeViewDelegate creativeWasClicked:self];
    [self.eventManager trackEvent:OXMTrackingEventClick];
    
    NSURL* url = [NSURL URLWithString:self.creativeModel.clickThroughURL];
    
    [self pause];
    @weakify(self);
    [super handleClickthrough:url completionHandler:^(BOOL success) {
        // nop
    } onExit:^{
        @strongify(self);
        [self resume];
    }];
}

- (void)videoViewWasTapped {
    if (self.creativeModel.adConfiguration.clickHandlerOverride != nil) {
        [self.eventManager trackEvent:OXMTrackingEventClick];
        [self pause];
        self.creativeModel.adConfiguration.clickHandlerOverride(^{
            [self resume];
        });
        return;
    }
    
    // Do not process the click if video is finished
    if (self.isPlaybackFinished) {
        return;
    }
    
    [self.creativeViewDelegate creativeViewWasClicked:self];
}

#pragma mark - OXMModalManagerDelegate

- (void)modalManagerDidFinishPop:(OXMModalState*)state {
    
    //Clickthrough
    if ([state.view isKindOfClass:[OXMClickthroughBrowserView class]]) {
        [self.creativeViewDelegate creativeClickthroughDidClose:self];
        self.clickthroughVisible = NO;
        return;
    }
    
    if (self.creativeModel.adConfiguration.isBuiltInVideo) {
        [self.creativeViewDelegate creativeFullScreenDidFinish:self];
        return;
    }

    [self close];
    
    //Creative presented as Interstitial
    [self.creativeViewDelegate creativeInterstitialDidClose:self];
    [self.creativeViewDelegate creativeDidComplete:self];
}

- (void)modalManagerDidLeaveApp:(OXMModalState*)state {
    [self.creativeViewDelegate creativeInterstitialDidLeaveApp:self];
}

#pragma mark - Internal methods

- (void)showVideoViewWithPreloadedData:(NSData *)preloadedData {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self.videoView showMediaFileURL:[NSURL URLWithString:self.creativeModel.videoFileURL] preloadedData:preloadedData];
    });
}

#pragma mark - Utility

- (OXMInterstitialDisplayProperties *)createInterstitialPropertiesForCurrentVideoStateFor:(OXMInterstitialDisplayProperties *)initialProperties {
    OXMInterstitialDisplayProperties *newDisplayProperties = [initialProperties copy];
    newDisplayProperties.closeDelay = [self calculateCloseDelayForPubCloseDelay:newDisplayProperties.closeDelay];
    newDisplayProperties.closeDelayLeft = newDisplayProperties.closeDelay;
    return newDisplayProperties;
}

- (NSTimeInterval)calculateCloseDelayForPubCloseDelay:(NSTimeInterval)pubCloseDelay {
    if (self.creativeModel.skipOffset) {
        return [self.creativeModel.skipOffset doubleValue];
    }
    else if (self.creativeModel.adConfiguration.isOptIn) {
        return [self.creativeModel.displayDurationInSeconds doubleValue];
    } else {
        const double videoDuration = self.creativeModel.displayDurationInSeconds.doubleValue;
        if (videoDuration <= 0) {
            return OXMTimeInterval.CLOSE_DELAY_MIN;
        }
        
        NSTimeInterval lowerBound = OXMTimeInterval.CLOSE_DELAY_MIN;
        NSTimeInterval upperBound = MIN(videoDuration, OXMTimeInterval.CLOSE_DELAY_MAX);
        NSTimeInterval ret = [OXMFunctions clamp:pubCloseDelay lowerBound:lowerBound upperBound:upperBound];
        
        return ret;
    }
}

@end
