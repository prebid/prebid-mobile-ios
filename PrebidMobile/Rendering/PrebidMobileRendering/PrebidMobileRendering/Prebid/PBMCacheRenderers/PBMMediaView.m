//
//  PBMMediaView.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMMediaView.h"
#import "PBMMediaView+Internal.h"

#import "NSTimer+PBMScheduledTimerFactory.h"
#import "PBMAdUnitConfig.h"
#import "PBMAdUnitConfig+Internal.h"
#import "PBMError.h"
#import "PBMMediaData.h"
#import "PBMMediaData+Internal.h"
#import "PBMVastTransactionFactory.h"
#import "PBMViewabilityPlaybackBinder.h"
#import "PBMViewExposureProviders.h"
#import "PBMAdViewManager.h"
#import "PBMAdViewManagerDelegate.h"

#import "PBMModalManagerDelegate.h"
#import "PBMServerConnection.h"
#import "PBMServerConnectionProtocol.h"

#import "PBMMacros.h"


static NSTimeInterval const DEFAULT_VIEWABILITY_POLLING_INTERVAL = 0.2;
static BOOL const IGNORE_CLICKS_IF_UNREGISTERED = YES;



@interface PBMMediaView () <PBMAdViewManagerDelegate>

@property (nonatomic, strong, nullable) PBMAdConfiguration *adConfiguration; // created on media loading attempt

// TODO: Move to test header {
@property (nonatomic, strong, nullable) id<PBMServerConnectionProtocol> connection;
@property (nonatomic, strong, nullable) NSNumber *pollingInterval; // NSTimeInterval
@property (nonatomic, strong, nullable) PBMScheduledTimerFactory scheduledTimerFactory;
// }

// Ad loading and management {
@property (nonatomic, strong, nullable) PBMVastTransactionFactory *vastTransactionFactory;
@property (nonatomic, strong, nullable) PBMAdViewManager *adViewManager;
// }

// optional part of PBMAdViewManagerDelegate protocol {
@property (nonatomic, strong, readonly, nonnull) PBMInterstitialDisplayProperties *interstitialDisplayProperties;
// }

@property (atomic, nullable, readwrite) PBMMediaData *mediaData; // filled on successful load
@property (atomic, nullable) PBMMediaData *mediaDataToLoad; // present during the loading

// autoPlayOnVisible {
@property (atomic, assign) BOOL rawAutoPlayOnVisible; // backing storage for computed 'autoPlayOnVisible'
@property (atomic, strong, nullable) PBMViewabilityPlaybackBinder *viewabilityPlaybackBinder;
@property (atomic, assign) BOOL bindPlaybackToViewability; // computed; backed by 'viewabilityPlaybackBinder'
@property (atomic, readonly) BOOL shouldBindPlaybackToViewability; // computed; goal for 'bindPlaybackToViewability'
// }

@property (nonatomic,assign) PBMMediaViewState state;
@property (nonatomic, assign) BOOL isPaused;

@end


@implementation PBMMediaView

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    [PBMMediaView setDefaultPropertiesForMediaView:self];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (!(self = [super initWithCoder:coder])) {
        return nil;
    }
    [PBMMediaView setDefaultPropertiesForMediaView:self];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    [PBMMediaView setDefaultPropertiesForMediaView:self];
    return self;
}

+ (void)setDefaultPropertiesForMediaView:(PBMMediaView *)mediaView {
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

- (void)loadMedia:(PBMMediaData *)mediaData {
    if (self.mediaData != nil) {
        [self reportFailureWithError:[PBMError replacingMediaDataInMediaView] markLoadingStopped:NO];
        return;
    }
    if (self.vastTransactionFactory || self.mediaDataToLoad != nil) {
        // the Ad is being loaded
        return;
    }
    NSString * const vasttag = mediaData.mediaAsset.video.vasttag;
    if (vasttag == nil) {
        [self reportFailureWithError:[PBMError noVastTagInMediaData] markLoadingStopped:YES];
        return;
    }
    
    self.state = PBMMediaViewState_Undefined;
    self.mediaDataToLoad = mediaData;
    self.adConfiguration = [[PBMAdConfiguration alloc] init];
    self.adConfiguration.adFormat = PBMAdFormatVideoInternal;
    self.adConfiguration.isNative = YES;
    self.adConfiguration.isInterstitialAd = NO;
    self.adConfiguration.isBuiltInVideo = YES;
    
    if (IGNORE_CLICKS_IF_UNREGISTERED) {
        self.adConfiguration.clickHandlerOverride = ^(PBMVoidBlock onClickthroughExitBlock) {
            // nop
            onClickthroughExitBlock();
        };
    } else {
        self.adConfiguration.clickHandlerOverride = mediaData.nativeAdHooks.clickHandlerOverride;
    }
    
    self.adViewManager.autoDisplayOnLoad = NO;
    
    @weakify(self);
    self.vastTransactionFactory = [[PBMVastTransactionFactory alloc] initWithConnection:self.connection ?: [PBMServerConnection singleton]
                                                                        adConfiguration:self.adConfiguration
                                                                               callback:^(PBMTransaction * _Nullable transaction,
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

// MARK: - PBMPlayable protocol

- (BOOL)canPlay {
    return self.state == PBMMediaViewState_PlaybackNotStarted;
}

- (void)play {
    if (![self canPlay]) {
        return;
    }
    
    self.state = PBMMediaViewState_Playing;
    [self.adViewManager show];
    [self.delegate onMediaPlaybackStarted:self];
}

- (void)pause {
    [self pauseWithState:PBMMediaViewState_PausedByUser];
}

- (void)autoPause {
    [self pauseWithState:PBMMediaViewState_PausedAuto];
}

- (void)pauseWithState:(PBMMediaViewState)state {
    if (self.state != PBMMediaViewState_Playing) {
        return;
    }
    self.state = state;
    [self.adViewManager pause];
    [self.delegate onMediaPlaybackPaused:self];
}

- (BOOL)canAutoResume {
    return self.state == PBMMediaViewState_PausedAuto;
}

- (void)resume {
    if (!self.isPaused) {
        return;
    }
    self.state = PBMMediaViewState_Playing;
    [self.adViewManager resume];
    [self.delegate onMediaPlaybackResumed:self];
}

- (BOOL)isPaused {
    return self.state == PBMMediaViewState_PausedAuto ||
           self.state == PBMMediaViewState_PausedByUser;
}

- (BOOL)isActive {
    return self.state == PBMMediaViewState_Playing || self.isPaused;
}

// MARK: - PBMAdViewManagerDelegate protocol

- (UIViewController *)viewControllerForModalPresentation {
    PBMMediaData * const mediaData = (self.mediaData ?: self.mediaDataToLoad);
    PBMViewControllerProvider const provider = mediaData.nativeAdHooks.viewControllerProvider;
    return (provider != nil) ? provider() : nil;
}

- (void)adLoaded:(PBMAdDetails *)pbmAdDetails {
    self.state = PBMMediaViewState_PlaybackNotStarted;
    [self reportSuccess];
}

- (void)failedToLoad:(NSError *)error {
    [self reportFailureWithError:error markLoadingStopped:YES];
}

- (void)adDidComplete {
    // FIXME: Implement
}

- (void)videoAdDidFinish {
    self.state = PBMMediaViewState_PlaybackFinished;
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
    PBMViewExposureProvider const exposureProvider = [PBMViewExposureProviders visibilityAsExposureForView:self];
    NSTimeInterval const pollingInterval = (self.pollingInterval
                                            ? self.pollingInterval.doubleValue
                                            : DEFAULT_VIEWABILITY_POLLING_INTERVAL);
    PBMScheduledTimerFactory const timerFactory = (self.scheduledTimerFactory ?: [NSTimer pbmScheduledTimerFactory]);
    self.viewabilityPlaybackBinder = [[PBMViewabilityPlaybackBinder alloc] initWithExposureProvider:exposureProvider
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

- (void)displayTransaction:(PBMTransaction *)transaction {
    id<PBMServerConnectionProtocol> const connection = self.connection ?: [PBMServerConnection singleton];
    self.adViewManager = [[PBMAdViewManager alloc] initWithConnection:connection modalManagerDelegate:nil];
    self.adViewManager.adViewManagerDelegate = self;
    self.adViewManager.adConfiguration = self.adConfiguration;
    self.adViewManager.autoDisplayOnLoad = NO;
    [self.adViewManager handleExternalTransaction:transaction];
}

@end
