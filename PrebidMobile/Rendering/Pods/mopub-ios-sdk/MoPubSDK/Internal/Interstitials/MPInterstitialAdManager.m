//
//  MPInterstitialAdManager.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <objc/runtime.h>

#import "MPInterstitialAdManager.h"

#import "MPAdServerURLBuilder.h"
#import "MPAdTargeting.h"
#import "MPFullscreenAdAdapter+MPAdAdapter.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPInterstitialAdController.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider.h"
#import "MPInterstitialAdManagerDelegate.h"
#import "MPLogging.h"
#import "MPError.h"
#import "MPStopwatch.h"
#import "MPViewabilityManager.h"
#import "NSMutableArray+MPAdditions.h"
#import "NSDate+MPAdditions.h"
#import "NSError+MPAdditions.h"

@interface MPInterstitialAdManager ()

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign, readwrite) BOOL ready;
@property (nonatomic, strong) MPFullscreenAdAdapter *adapter;
@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPAdConfiguration *requestingConfiguration;
@property (nonatomic, strong) NSMutableArray<MPAdConfiguration *> *remainingConfigurations;
@property (nonatomic, strong) MPStopwatch *loadStopwatch;
@property (nonatomic, strong) MPAdTargeting * targeting;
@property (nonatomic, strong) NSURL *mostRecentlyLoadedURL;  // ADF-4286: avoid infinite ad reloads

- (void)setUpAdapterWithConfiguration:(MPAdConfiguration *)configuration;

@end

#pragma mark -

@interface MPInterstitialAdManager (MPAdAdapterDelegate) <MPAdAdapterFullscreenEventDelegate, MPAdAdapterRewardEventDelegate>
@end

#pragma mark -

@implementation MPInterstitialAdManager

- (id)initWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.communicator = [[MPAdServerCommunicator alloc] initWithDelegate:self];
        self.delegate = delegate;

        _loadStopwatch = MPStopwatch.new;
    }
    return self;
}

- (void)dealloc
{
    [self.communicator cancel];
    [self.communicator setDelegate:nil];

    self.adapter = nil;
}

#pragma mark - Public

- (void)loadAdWithURL:(NSURL *)URL
{
    if (self.loading) {
        MPLogEvent([MPLogEvent error:NSError.adAlreadyLoading message:nil]);
        return;
    }

    self.loading = YES;
    self.mostRecentlyLoadedURL = URL;
    [self.communicator loadURL:URL];
}


- (void)loadInterstitialWithAdUnitID:(NSString *)ID targeting:(MPAdTargeting *)targeting
{
    MPLogAdEvent(MPLogEvent.adLoadAttempt, ID);

    if (self.ready) {
        [self.delegate managerDidLoadInterstitial:self];
    } else {
        self.targeting = targeting;
        [self loadAdWithURL:[MPAdServerURLBuilder URLWithAdUnitID:ID targeting:targeting]];
    }
}

- (void)presentInterstitialFromViewController:(UIViewController *)controller
{
    MPLogAdEvent(MPLogEvent.adShowAttempt, self.delegate.interstitialAdController.adUnitId);

    // Don't allow the ad to be shown if it isn't ready.
    if (!self.ready) {
        MPLogInfo(@"Interstitial ad view is not ready to be shown");
        return;
    }

    [self.adapter showFullscreenAdFromViewController:controller];
}

- (MPInterstitialAdController *)interstitialAdController
{
    return [self.delegate interstitialAdController];
}

- (id)interstitialDelegate
{
    return [self.delegate interstitialDelegate];
}

#pragma mark - MPAdServerCommunicatorDelegate

- (void)communicatorDidReceiveAdConfigurations:(NSArray<MPAdConfiguration *> *)configurations {
    self.remainingConfigurations = [NSMutableArray arrayWithArray:configurations];
    self.requestingConfiguration = [self.remainingConfigurations removeFirst];

    // There are no configurations to try. Consider this a clear response by the server.
    if (self.remainingConfigurations.count == 0 && self.requestingConfiguration == nil) {
        MPLogInfo(kMPClearErrorLogFormatWithAdUnitID, self.delegate.interstitialAdController.adUnitId);
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:[NSError errorWithCode:MOPUBErrorNoInventory]];
        return;
    }

    [self fetchAdWithConfiguration:self.requestingConfiguration];
}

- (void)fetchAdWithConfiguration:(MPAdConfiguration *)configuration
{
    MPLogInfo(@"Interstitial ad view is fetching ad type: %@", configuration.adType);

    if (configuration.adUnitWarmingUp) {
        MPLogInfo(kMPWarmingUpErrorLogFormatWithAdUnitID, self.delegate.interstitialAdController.adUnitId);
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:[NSError errorWithCode:MOPUBErrorAdUnitWarmingUp]];
        return;
    }

    if ([configuration.adType isEqualToString:kAdTypeClear]) {
        MPLogInfo(kMPClearErrorLogFormatWithAdUnitID, self.delegate.interstitialAdController.adUnitId);
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:[NSError errorWithCode:MOPUBErrorNoInventory]];
        return;
    }

    [self setUpAdapterWithConfiguration:configuration];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;

    [self.delegate manager:self didFailToLoadInterstitialWithError:error];
}

- (void)setUpAdapterWithConfiguration:(MPAdConfiguration *)configuration
{
    // Notify Ad Server of the adapter load. This is fire and forget.
    [self.communicator sendBeforeLoadUrlWithConfiguration:configuration];

    // Start the stopwatch for the adapter load.
    [self.loadStopwatch start];

    if (configuration.adapterClass == nil) {
        [self adapter:nil didFailToLoadAdWithError:nil];
        return;
    }

    NSObject *object = [configuration.adapterClass new];
    if ([object isKindOfClass:MPFullscreenAdAdapter.class]) {
        MPFullscreenAdAdapter *adapter = (MPFullscreenAdAdapter *)object;
        self.adapter = adapter;
        adapter.adapterDelegate = self;
        [adapter getAdWithConfiguration:configuration targeting:self.targeting];
    }
    else { // unrecognized ad adapter
        [self adapter:nil didFailToLoadAdWithError:nil];
    }
}

- (BOOL)isFullscreenAd {
    return YES;
}

- (NSString *)adUnitId {
    return [self.delegate adUnitId];
}

@end

#pragma mark -

@implementation MPInterstitialAdManager (MPAdAdapterDelegate)

- (void)adAdapter:(id<MPAdAdapter>)adapter handleFullscreenAdEvent:(MPFullscreenAdEvent)fullscreenAdEvent {
    switch (fullscreenAdEvent) {
        case MPFullscreenAdEventDidLoad:
            self.remainingConfigurations = nil;
            self.ready = YES;
            self.loading = NO;

            // Record the end of the adapter load and send off the fire and forget after-load-url tracker.
            NSTimeInterval duration = [self.loadStopwatch stop];
            [self.communicator sendAfterLoadUrlWithConfiguration:self.requestingConfiguration adapterLoadDuration:duration adapterLoadResult:MPAfterLoadResultAdLoaded];

            MPLogAdEvent(MPLogEvent.adDidLoad, self.delegate.interstitialAdController.adUnitId);
            [self.delegate managerDidLoadInterstitial:self];
            break;
        case MPFullscreenAdEventDidExpire:
            self.ready = NO;
            MPLogAdEvent([MPLogEvent adExpiredWithTimeInterval:MPConstants.adsExpirationInterval], self.delegate.interstitialAdController.adUnitId);
            [self.delegate managerDidExpireInterstitial:self];
            break;
        case MPFullscreenAdEventWillAppear:
            MPLogAdEvent(MPLogEvent.adWillAppear, self.delegate.interstitialAdController.adUnitId);
            [self.delegate managerWillPresentInterstitial:self];
            break;
        case MPFullscreenAdEventDidAppear:
            MPLogAdEvent(MPLogEvent.adDidAppear, self.delegate.interstitialAdController.adUnitId);
            [self.delegate managerDidPresentInterstitial:self];
            break;
        case MPFullscreenAdEventWillDisappear:
            break;
        case MPFullscreenAdEventDidDisappear:
            break;
        case MPFullscreenAdEventDidReceiveTap:
            MPLogAdEvent(MPLogEvent.adWillPresentModal, self.delegate.interstitialAdController.adUnitId);
            [self.delegate managerDidReceiveTapEventFromInterstitial:self];
            break;
        case MPFullscreenAdEventWillLeaveApplication: // no op
            MPLogAdEvent(MPLogEvent.adWillLeaveApplication, self.delegate.interstitialAdController.adUnitId);
            break;
        case MPFullscreenAdEventWillDismiss:
            MPLogAdEvent(MPLogEvent.adWillDismiss, self.delegate.interstitialAdController.adUnitId);
            [self.delegate managerWillDismissInterstitial:self];
            break;
        case MPFullscreenAdEventDidDismiss: {
            // End the Viewability session and schedule the previously onscreen adapter for
            // deallocation if it exists since it is going offscreen. This only applies to
            // webview-based content.
            BOOL isWebViewContent = (self.adapter.adContentType == MPAdContentTypeWebNoMRAID || self.adapter.adContentType == MPAdContentTypeWebWithMRAID);
            if (self.adapter != nil && isWebViewContent) {
                [MPViewabilityManager.sharedManager scheduleAdapterForDeallocation:self.adapter];
            }

            // Reset state
            self.adapter = nil;     // `nil` to trigger the scheduled deallocation since we are handing over ownership of the reference
            self.ready = NO;
            self.loading = NO;

            MPLogAdEvent(MPLogEvent.adDidDismiss, self.delegate.interstitialAdController.adUnitId);
            [self.delegate managerDidDismissInterstitial:self];
            break;
        }
    }
}

- (void)adapter:(id<MPAdAdapter> _Nullable)adapter didFailToLoadAdWithError:(NSError *)error {
    // Record the end of the adapter load and send off the fire and forget after-load-url tracker
    // with the appropriate error code result.
    NSTimeInterval duration = [self.loadStopwatch stop];
    MPAfterLoadResult result = (error.isAdRequestTimedOutError ? MPAfterLoadResultTimeout : (adapter == nil ? MPAfterLoadResultMissingAdapter : MPAfterLoadResultError));
    [self.communicator sendAfterLoadUrlWithConfiguration:self.requestingConfiguration adapterLoadDuration:duration adapterLoadResult:result];

    // There are more ad configurations to try.
    if (self.remainingConfigurations.count > 0) {
        self.requestingConfiguration = [self.remainingConfigurations removeFirst];
        [self fetchAdWithConfiguration:self.requestingConfiguration];
    }
    // No more configurations to try. Send new request to Ads server to get more Ads.
    else if (self.requestingConfiguration.nextURL != nil
             && [self.requestingConfiguration.nextURL isEqual:self.mostRecentlyLoadedURL] == false) {
        self.ready = NO;
        self.loading = NO;
        [self loadAdWithURL:self.requestingConfiguration.nextURL];
    }
    // No more configurations to try and no more pages to load.
    else {
        self.ready = NO;
        self.loading = NO;

        NSError * clearResponseError = [NSError errorWithCode:MOPUBErrorNoInventory localizedDescription:[NSString stringWithFormat:kMPClearErrorLogFormatWithAdUnitID, self.delegate.interstitialAdController.adUnitId]];
        MPLogAdEvent([MPLogEvent adFailedToLoadWithError:clearResponseError], self.delegate.interstitialAdController.adUnitId);
        [self.delegate manager:self didFailToLoadInterstitialWithError:clearResponseError];
    }
}

- (void)adapter:(id<MPAdAdapter>)adapter didFailToPlayAdWithError:(NSError *)error {
    // no op: `MPInterstitialAdManager` only cares about `FailToLoad`
}

- (void)adDidReceiveImpressionEventForAdapter:(id<MPAdAdapter>)adapter {
    [self.delegate interstitialAdManager:self didReceiveImpressionEventWithImpressionData:self.requestingConfiguration.impressionData];
}

#pragma mark - Transitional MPAdAdapterRewardEventDelegate Implementation


- (NSString * _Nullable)customerId {
    return nil;
}

- (id<MPMediationSettingsProtocol> _Nullable)instanceMediationSettingsForClass:(Class)aClass {
    return nil;
}

- (void)adShouldRewardUserForAdapter:(id<MPAdAdapter>)adapter reward:(MPReward *)reward {
    // no op
}

@end
