//
//  OXAMediaView.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAMediaView.h"
#import "OXAMediaView+Internal.h"

#import "NSTimer+OXAScheduledTimerFactory.h"
#import "OXAAdUnitConfig.h"
#import "OXAAdUnitConfig+Internal.h"
#import "OXAError.h"
#import "OXAMediaData.h"
#import "OXAMediaData+Internal.h"
#import "OXAVastTransactionFactory.h"
#import "OXAViewabilityPlaybackBinder.h"
#import "OXAViewExposureProviders.h"
#import "OXMAdViewManager.h"
#import "OXMAdViewManagerDelegate.h"

#import "OXMModalManagerDelegate.h"
#import "OXMServerConnection.h"
#import "OXMServerConnectionProtocol.h"

#import "OXMMacros.h"


static NSTimeInterval const DEFAULT_VIEWABILITY_POLLING_INTERVAL = 0.2;
static BOOL const IGNORE_CLICKS_IF_UNREGISTERED = YES;



@interface OXAMediaView () <OXMAdViewManagerDelegate>

@property (nonatomic, strong, nullable) OXMAdConfiguration *adConfiguration; // created on media loading attempt

// TODO: Move to test header {
@property (nonatomic, strong, nullable) id<OXMServerConnectionProtocol> connection;
@property (nonatomic, strong, nullable) NSNumber *pollingInterval; // NSTimeInterval
@property (nonatomic, strong, nullable) OXAScheduledTimerFactory scheduledTimerFactory;
// }

// Ad loading and management {
@property (nonatomic, strong, nullable) OXAVastTransactionFactory *vastTransactionFactory;
@property (nonatomic, strong, nullable) OXMAdViewManager *adViewManager;
// }

// optional part of OXMAdViewManagerDelegate protocol {
@property (nonatomic, strong, readonly, nonnull) OXMInterstitialDisplayProperties *interstitialDisplayProperties;
// }

@property (atomic, nullable, readwrite) OXAMediaData *mediaData; // filled on successful load
@property (atomic, nullable) OXAMediaData *mediaDataToLoad; // present during the loading

// autoPlayOnVisible {
@property (atomic, assign) BOOL rawAutoPlayOnVisible; // backing storage for computed 'autoPlayOnVisible'
@property (atomic, strong, nullable) OXAViewabilityPlaybackBinder *viewabilityPlaybackBinder;
@property (atomic, assign) BOOL bindPlaybackToViewability; // computed; backed by 'viewabilityPlaybackBinder'
@property (atomic, readonly) BOOL shouldBindPlaybackToViewability; // computed; goal for 'bindPlaybackToViewability'
// }

@property (nonatomic,assign) OXAMediaViewState state;
@property (nonatomic, assign) BOOL isPaused;

@end


@implementation OXAMediaView

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    [OXAMediaView setDefaultPropertiesForMediaView:self];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (!(self = [super initWithCoder:coder])) {
        return nil;
    }
    [OXAMediaView setDefaultPropertiesForMediaView:self];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    [OXAMediaView setDefaultPropertiesForMediaView:self];
    return self;
}

+ (void)setDefaultPropertiesForMediaView:(OXAMediaView *)mediaView {
    mediaView.rawAutoPlayOnVisible = YES;
}

// MARK: - Public computed properties

- (BOOL)autoPlayOnVisible {
    return self.rawAutoPlayOnVisible;
}

- (void)setAutoPlayOnVisible:(BOOL)autoPlayOnVisible {
    self.rawAutoPlayOnVisible = autoPlayOnVisible;
    self.bindPlaybackToViewability = self.shouldBindPlaybackToViewability;
}

// MARK: - Public API

- (void)loadMedia:(OXAMediaData *)mediaData {
    if (self.mediaData != nil) {
        [self reportFailureWithError:[OXAError replacingMediaDataInMediaView] markLoadingStopped:NO];
        return;
    }
    if (self.vastTransactionFactory || self.mediaDataToLoad != nil) {
        // the Ad is being loaded
        return;
    }
    NSString * const vasttag = mediaData.mediaAsset.video.vasttag;
    if (vasttag == nil) {
        [self reportFailureWithError:[OXAError noVastTagInMediaData] markLoadingStopped:YES];
        return;
    }
    
    self.state = OXAMediaViewState_Undefined;
    self.mediaDataToLoad = mediaData;
    self.adConfiguration = [[OXMAdConfiguration alloc] init];
    self.adConfiguration.adFormat = OXMAdFormatVideo;
    self.adConfiguration.isNative = YES;
    self.adConfiguration.isInterstitialAd = NO;
    self.adConfiguration.isBuiltInVideo = YES;
    
    if (IGNORE_CLICKS_IF_UNREGISTERED) {
        self.adConfiguration.clickHandlerOverride = ^(OXMVoidBlock onClickthroughExitBlock) {
            // nop
            onClickthroughExitBlock();
        };
    } else {
        self.adConfiguration.clickHandlerOverride = mediaData.nativeAdHooks.clickHandlerOverride;
    }
    
    self.adViewManager.autoDisplayOnLoad = NO;
    
    @weakify(self);
    self.vastTransactionFactory = [[OXAVastTransactionFactory alloc] initWithConnection:self.connection ?: [OXMServerConnection singleton]
                                                                        adConfiguration:self.adConfiguration
                                                                               callback:^(OXMTransaction * _Nullable transaction,
                                                                                          NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            [self reportFailureWithError:error markLoadingStopped:YES];
        } else {
            [self displayTransaction:transaction];
        }
    }];
    [self.vastTransactionFactory loadWithAdMarkup:vasttag];
}

- (void)mute {
    if (!self.isActive || self.adViewManager.isMuted) {
        return;
    }
    [self.adViewManager mute];
    [self.delegate onMediaPlaybackMuted:self];
}

- (void)unmute {
    if (!self.isActive || !self.adViewManager.isMuted) {
        return;
    }
    [self.adViewManager unmute];
    [self.delegate onMediaPlaybackUnmuted:self];
}

// MARK: - OXAPlayable protocol

- (BOOL)canPlay {
    return self.state == OXAMediaViewState_PlaybackNotStarted;
}

- (void)play {
    if (![self canPlay]) {
        return;
    }
    
    self.state = OXAMediaViewState_Playing;
    [self.adViewManager show];
    [self.delegate onMediaPlaybackStarted:self];
}

- (void)pause {
    [self pauseWithState:OXAMediaViewState_PausedByUser];
}

- (void)autoPause {
    [self pauseWithState:OXAMediaViewState_PausedAuto];
}

- (void)pauseWithState:(OXAMediaViewState)state {
    if (self.state != OXAMediaViewState_Playing) {
        return;
    }
    self.state = state;
    [self.adViewManager pause];
    [self.delegate onMediaPlaybackPaused:self];
}

- (BOOL)canAutoResume {
    return self.state == OXAMediaViewState_PausedAuto;
}

- (void)resume {
    if (!self.isPaused) {
        return;
    }
    self.state = OXAMediaViewState_Playing;
    [self.adViewManager resume];
    [self.delegate onMediaPlaybackResumed:self];
}

- (BOOL)isPaused {
    return self.state == OXAMediaViewState_PausedAuto ||
           self.state == OXAMediaViewState_PausedByUser;
}

- (BOOL)isActive {
    return self.state == OXAMediaViewState_Playing || self.isPaused;
}

// MARK: - OXMAdViewManagerDelegate protocol

- (UIViewController *)viewControllerForModalPresentation {
    OXAMediaData * const mediaData = (self.mediaData ?: self.mediaDataToLoad);
    OXAViewControllerProvider const provider = mediaData.nativeAdHooks.viewControllerProvider;
    return (provider != nil) ? provider() : nil;
}

- (void)adLoaded:(OXMAdDetails *)oxmAdDetails {
    self.state = OXAMediaViewState_PlaybackNotStarted;
    [self reportSuccess];
}

- (void)failedToLoad:(NSError *)error {
    [self reportFailureWithError:error markLoadingStopped:YES];
}

- (void)adDidComplete {
    // FIXME: Implement
}

- (void)videoAdDidFinish {
    self.state = OXAMediaViewState_PlaybackFinished;
    [self.delegate onMediaPlaybackFinished:self];
}

- (void)videoAdWasMuted {
    [self.delegate onMediaPlaybackMuted:self];
}

- (void)videoAdWasUnmuted {
    [self.delegate onMediaPlaybackUnmuted:self];
}

- (void)adDidDisplay {
    // FIXME: Implement
}

- (void)adWasClicked {
    // FIXME: Implement
}

- (void)adViewWasClicked {
    // FIXME: Implement
}

- (void)adDidExpand {
    // FIXME: Implement
}

- (void)adDidCollapse {
    // FIXME: Implement
}

- (void)adDidLeaveApp {
    // FIXME: Implement
}

- (void)adClickthroughDidClose {
    // FIXME: Implement
}

- (void)adDidClose {
    // FIXME: Implement
}

- (UIView *)displayView {
    return self;
}

// MARK: - Private computed properties

- (BOOL)bindPlaybackToViewability {
    return (self.viewabilityPlaybackBinder != nil);
}

- (void)setBindPlaybackToViewability:(BOOL)bindPlaybackToViewability {
    if (!bindPlaybackToViewability) {
        // -> turn OFF
        self.viewabilityPlaybackBinder = nil;
        return;
    }
    if (self.viewabilityPlaybackBinder != nil) {
        // already ON
        return;
    }
    // -> turn ON
    OXAViewExposureProvider const exposureProvider = [OXAViewExposureProviders visibilityAsExposureForView:self];
    NSTimeInterval const pollingInterval = (self.pollingInterval
                                            ? self.pollingInterval.doubleValue
                                            : DEFAULT_VIEWABILITY_POLLING_INTERVAL);
    OXAScheduledTimerFactory const timerFactory = (self.scheduledTimerFactory ?: [NSTimer oxaScheduledTimerFactory]);
    self.viewabilityPlaybackBinder = [[OXAViewabilityPlaybackBinder alloc] initWithExposureProvider:exposureProvider
                                                                                    pollingInterval:pollingInterval
                                                                              scheduledTimerFactory:timerFactory
                                                                                           playable:self];
}

- (BOOL)shouldBindPlaybackToViewability {
    return (self.autoPlayOnVisible && (self.mediaData != nil));
}

// MARK: - Private Helpers

- (void)reportFailureWithError:(NSError *)error markLoadingStopped:(BOOL)markLoadingStopped {
    if (markLoadingStopped) {
        self.vastTransactionFactory = nil;
        self.mediaDataToLoad = nil;
    }
    // FIXME: Implement
}

- (void)reportSuccess {
    self.mediaData = self.mediaDataToLoad;
    self.vastTransactionFactory = nil;
    self.bindPlaybackToViewability = self.shouldBindPlaybackToViewability;
    [self.delegate onMediaLoadingFinished:self];
}

- (void)displayTransaction:(OXMTransaction *)transaction {
    id<OXMServerConnectionProtocol> const connection = self.connection ?: [OXMServerConnection singleton];
    self.adViewManager = [[OXMAdViewManager alloc] initWithConnection:connection modalManagerDelegate:nil];
    self.adViewManager.adViewManagerDelegate = self;
    self.adViewManager.adConfiguration = self.adConfiguration;
    self.adViewManager.autoDisplayOnLoad = NO;
    [self.adViewManager handleExternalTransaction:transaction];
}

@end
