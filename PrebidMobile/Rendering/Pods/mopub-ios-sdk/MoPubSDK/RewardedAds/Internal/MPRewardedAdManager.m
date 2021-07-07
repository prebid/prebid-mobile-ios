//
//  MPRewardedAdManager.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPRewardedAdManager.h"

#import "MPAdServerCommunicator.h"
#import "MPAdServerURLBuilder.h"
#import "MPFullscreenAdAdapter+MPAdAdapter.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPCoreInstanceProvider.h"
#import "MPRewardedAdsError.h"
#import "MPLogging.h"
#import "MPStopwatch.h"
#import "MPViewabilityManager.h"
#import "MoPub.h"
#import "NSMutableArray+MPAdditions.h"
#import "NSDate+MPAdditions.h"
#import "NSError+MPAdditions.h"

@interface MPRewardedAdManager () <MPAdServerCommunicatorDelegate>

@property (nonatomic, strong) MPFullscreenAdAdapter *adapter;
@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, strong) NSMutableArray<MPAdConfiguration *> *remainingConfigurations;
@property (nonatomic, strong) NSURL *mostRecentlyLoadedURL;  // ADF-4286: avoid infinite ad reloads
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL playedAd;
@property (nonatomic, assign) BOOL ready;
@property (nonatomic, strong) MPStopwatch *loadStopwatch;

@end

#pragma mark -

@interface MPRewardedAdManager (MPAdAdapterDelegate) <
    MPAdAdapterFullscreenEventDelegate,
    MPAdAdapterRewardEventDelegate
>
@end

#pragma mark -

@implementation MPRewardedAdManager

- (instancetype)initWithAdUnitID:(NSString *)adUnitID delegate:(id<MPRewardedAdManagerDelegate>)delegate
{
    if (self = [super init]) {
        _adUnitId = [adUnitID copy];
        _communicator = [[MPAdServerCommunicator alloc] initWithDelegate:self];
        _delegate = delegate;
        _loadStopwatch = MPStopwatch.new;
    }

    return self;
}

- (void)dealloc
{
    [_communicator cancel];
}

- (NSArray<MPReward *> *)availableRewards
{
    return self.configuration.availableRewards;
}

- (MPReward *)selectedReward
{
    return self.configuration.selectedReward;
}

- (Class)adapterClass
{
    return self.configuration.adapterClass;
}

- (BOOL)hasAdAvailable
{
    //An Ad is not ready or has expired.
    if (!self.ready) {
        return NO;
    }

    // If we've already played an ad, return NO since we allow one play per load.
    if (self.playedAd) {
        return NO;
    }
    return [self.adapter hasAdAvailable];
}

- (void)loadRewardedAdWithCustomerId:(NSString *)customerId targeting:(MPAdTargeting *)targeting
{
    MPLogAdEvent(MPLogEvent.adLoadAttempt, self.adUnitId);
    
    // We will just tell the delegate that we have loaded an ad if we already have one ready. However, if we have already
    // played a video for this ad manager, we will go ahead and request another ad from the server so we aren't potentially
    // stuck playing ads from the same network for a prolonged period of time which could be unoptimal with respect to the waterfall.
    if (self.ready && !self.playedAd) {
        // If we already have an ad, do not set the customerId. We'll leave the customerId as the old one since the ad we currently have
        // may be tied to an older customerId.
        [self.delegate rewardedAdDidLoadForAdManager:self];
    } else {
        // This has multiple behaviors. For ads that require us to set the customID: (outside of load), this will overwrite the ad's previously
        // set customerId. Other ads require customerId on presentation in which we will use this new id coming in when presenting the ad.
        self.customerId = customerId;
        self.targeting = targeting;
        [self loadAdWithURL:[MPAdServerURLBuilder URLWithAdUnitID:self.adUnitId targeting:targeting]];
    }
}

- (void)presentRewardedAdFromViewController:(UIViewController *)viewController withReward:(MPReward *)reward customData:(NSString *)customData
{
    MPLogAdEvent(MPLogEvent.adShowAttempt, self.adUnitId);
    
    // Don't allow the ad to be shown if it isn't ready.
    if (!self.ready) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorNoAdReady userInfo:@{ NSLocalizedDescriptionKey: @"Rewarded video ad view is not ready to be shown"}];
        MPLogInfo(@"%@ error: %@", NSStringFromSelector(_cmd), error.localizedDescription);
        [self.delegate rewardedAdDidFailToShowForAdManager:self error:error];
        return;
    }
    
    // If we've already played an ad, don't allow playing of another since we allow one play per load.
    if (self.playedAd) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorAdAlreadyPlayed userInfo:nil];
        [self.delegate rewardedAdDidFailToShowForAdManager:self error:error];
        return;
    }
    
    // No reward is specified
    if (reward == nil) {
        // Only a single currency; It should automatically select the only currency available.
        if (self.availableRewards.count == 1) {
            MPReward *defaultReward = self.availableRewards[0];
            self.configuration.selectedReward = defaultReward;
        }
        // Unspecified rewards in a multicurrency situation are not allowed.
        else {
            NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorNoRewardSelected userInfo:nil];
            [self.delegate rewardedAdDidFailToShowForAdManager:self error:error];
            return;
        }
    }
    // Reward is specified
    else {
        // Verify that the reward exists in the list of available rewards. If it doesn't, fail to play the ad.
        if (![self.availableRewards containsObject:reward]) {
            NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorInvalidReward userInfo:nil];
            [self.delegate rewardedAdDidFailToShowForAdManager:self error:error];
            return;
        }
        // Reward passes validation, set it as selected.
        else {
            self.configuration.selectedReward = reward;
        }
    }
    
    self.adapter.customData = customData;
    [self.adapter presentAdFromViewController:viewController];
}

- (void)handleAdPlayedForAdapterNetwork
{
    // We only need to notify the backing ad network if the ad is marked ready for display.
    if (self.ready) {
        [self.adapter handleDidPlayAd];
    }
}

#pragma mark - Private

- (void)loadAdWithURL:(NSURL *)URL
{
    self.playedAd = NO;
    
    if (self.loading) {
        MPLogEvent([MPLogEvent error:NSError.adAlreadyLoading message:nil]);
        return;
    }

    self.loading = YES;
    self.mostRecentlyLoadedURL = URL;
    [self.communicator loadURL:URL];
}

- (void)fetchAdWithConfiguration:(MPAdConfiguration *)configuration {
    MPLogInfo(@"Rewarded video ad is fetching ad type: %@", configuration.adType);
    
    if (configuration.adUnitWarmingUp) {
        MPLogInfo(kMPWarmingUpErrorLogFormatWithAdUnitID, self.adUnitId);
        self.loading = NO;
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorAdUnitWarmingUp userInfo:nil];
        [self.delegate rewardedAdDidFailToLoadForAdManager:self error:error];
        return;
    }
    
    if ([configuration.adType isEqualToString:kAdTypeClear]) {
        MPLogInfo(kMPClearErrorLogFormatWithAdUnitID, self.adUnitId);
        self.loading = NO;
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedAdDidFailToLoadForAdManager:self error:error];
        return;
    }
    
    // Notify Ad Server of the adapter load. This is fire and forget.
    [self.communicator sendBeforeLoadUrlWithConfiguration:configuration];
    
    // Start the stopwatch for the adapter load.
    [self.loadStopwatch start];
    
    NSObject *object = [configuration.adapterClass new];
    if ([object isKindOfClass:MPFullscreenAdAdapter.class]) {
        MPFullscreenAdAdapter *adapter = (MPFullscreenAdAdapter *)object;
        self.adapter = adapter;
        adapter.adapterDelegate = self;
        [adapter getAdWithConfiguration:configuration targeting:self.targeting];
    }
    else { // unrecognized ad adapter
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorUnknown userInfo:nil];
        [self adapter:nil didFailToLoadAdWithError:error];
    }
}

#pragma mark - MPAdServerCommunicatorDelegate

- (void)communicatorDidReceiveAdConfigurations:(NSArray<MPAdConfiguration *> *)configurations
{
    self.remainingConfigurations = [configurations mutableCopy];
    self.configuration = [self.remainingConfigurations removeFirst];
    
    // There are no configurations to try. Consider this a clear response by the server.
    if (self.remainingConfigurations.count == 0 && self.configuration == nil) {
        MPLogInfo(kMPClearErrorLogFormatWithAdUnitID, self.adUnitId);
        self.loading = NO;
        NSError *error = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain code:MPRewardedAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedAdDidFailToLoadForAdManager:self error:error];
        return;
    }
    
    [self fetchAdWithConfiguration:self.configuration];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;

    [self.delegate rewardedAdDidFailToLoadForAdManager:self error:error];
}

- (BOOL)isFullscreenAd {
    return YES;
}

@end

#pragma mark -

@implementation MPRewardedAdManager (MPAdAdapterDelegate)

- (id<MPMediationSettingsProtocol> _Nullable)instanceMediationSettingsForClass:(Class)aClass
{
    for (id<MPMediationSettingsProtocol> settings in self.mediationSettings) {
        if ([settings isKindOfClass:aClass]) {
            return settings;
        }
    }

    return nil;
}

- (void)adapter:(id<MPAdAdapter> _Nullable)adapter didFailToLoadAdWithError:(NSError * _Nullable)error {
    // Record the end of the adapter load and send off the fire and forget after-load-url tracker
    // with the appropriate error code result.
    NSTimeInterval duration = [self.loadStopwatch stop];
    MPAfterLoadResult result = (error.isAdRequestTimedOutError ? MPAfterLoadResultTimeout : (adapter == nil ? MPAfterLoadResultMissingAdapter : MPAfterLoadResultError));
    [self.communicator sendAfterLoadUrlWithConfiguration:self.configuration adapterLoadDuration:duration adapterLoadResult:result];
    
    // There are more ad configurations to try.
    if (self.remainingConfigurations.count > 0) {
        self.configuration = [self.remainingConfigurations removeFirst];
        [self fetchAdWithConfiguration:self.configuration];
    }
    // No more configurations to try. Send new request to Ads server to get more Ads.
    else if (self.configuration.nextURL != nil
             && [self.configuration.nextURL isEqual:self.mostRecentlyLoadedURL] == false) {
        self.ready = NO;
        self.loading = NO;
        [self loadAdWithURL:self.configuration.nextURL];
    }
    // No more configurations to try and no more pages to load.
    else {
        self.ready = NO;
        self.loading = NO;
        
        NSString *errorDescription = [NSString stringWithFormat:kMPClearErrorLogFormatWithAdUnitID, self.adUnitId];
        NSError * clearResponseError = [NSError errorWithDomain:MoPubRewardedAdsSDKDomain
                                                           code:MPRewardedAdErrorNoAdsAvailable
                                                       userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        MPLogAdEvent([MPLogEvent adFailedToLoadWithError:clearResponseError], self.adUnitId);
        [self.delegate rewardedAdDidFailToLoadForAdManager:self error:clearResponseError];
    }
}

- (void)adapter:(id<MPAdAdapter> _Nullable)adapter didFailToPlayAdWithError:(NSError *)error {
    // Playback of the rewarded video failed; reset the internal played state
    // so that a new rewarded video ad can be loaded.
    self.ready = NO;
    self.playedAd = NO;
    
    MPLogAdEvent([MPLogEvent adShowFailedWithError:error], self.adUnitId);
    [self.delegate rewardedAdDidFailToShowForAdManager:self error:error];
}

- (void)adAdapter:(id<MPAdAdapter>)adapter handleFullscreenAdEvent:(MPFullscreenAdEvent)fullscreenAdEvent {
    switch (fullscreenAdEvent) {
        case MPFullscreenAdEventDidLoad:
            self.remainingConfigurations = nil;
            self.ready = YES;
            self.loading = NO;
            
            // Record the end of the adapter load and send off the fire and forget after-load-url tracker.
            // Start the stopwatch for the adapter load.
            NSTimeInterval duration = [self.loadStopwatch stop];
            [self.communicator sendAfterLoadUrlWithConfiguration:self.configuration
                                             adapterLoadDuration:duration
                                               adapterLoadResult:MPAfterLoadResultAdLoaded];
            
            MPLogAdEvent(MPLogEvent.adDidLoad, self.adUnitId);
            [self.delegate rewardedAdDidLoadForAdManager:self];
            break;
        case MPFullscreenAdEventDidExpire:
            self.ready = NO;
            MPLogAdEvent([MPLogEvent adExpiredWithTimeInterval:MPConstants.adsExpirationInterval], self.adUnitId);
            [self.delegate rewardedAdDidExpireForAdManager:self];
            break;
        case MPFullscreenAdEventWillAppear:
            MPLogAdEvent(MPLogEvent.adWillAppear, self.adUnitId);
            [self.delegate rewardedAdWillAppearForAdManager:self];
            break;
        case MPFullscreenAdEventDidAppear:
            MPLogAdEvent(MPLogEvent.adDidAppear, self.adUnitId);
            [self.delegate rewardedAdDidAppearForAdManager:self];
            break;
        case MPFullscreenAdEventWillDisappear:
            break;
        case MPFullscreenAdEventDidDisappear:
            break;
        case MPFullscreenAdEventDidReceiveTap:
            MPLogAdEvent(MPLogEvent.adWillPresentModal, self.adUnitId);
            [self.delegate rewardedAdDidReceiveTapEventForAdManager:self];
            break;
        case MPFullscreenAdEventWillLeaveApplication:
            MPLogAdEvent(MPLogEvent.adWillLeaveApplication, self.adUnitId);
            [self.delegate rewardedAdWillLeaveApplicationForAdManager:self];
            break;
        case MPFullscreenAdEventWillDismiss:
            MPLogAdEvent(MPLogEvent.adWillDismiss, self.adUnitId);
            [self.delegate rewardedAdWillDismissForAdManager:self];
            break;
        case MPFullscreenAdEventDidDismiss: {
            // End the Viewability session and schedule the previously onscreen adapter for
            // deallocation if it exists since it is going offscreen. This only applies to
            // webview-based content.
            BOOL isWebViewContent = (self.adapter.adContentType == MPAdContentTypeWebNoMRAID || self.adapter.adContentType == MPAdContentTypeWebWithMRAID);
            if (self.adapter != nil && isWebViewContent) {
                [MPViewabilityManager.sharedManager scheduleAdapterForDeallocation:self.adapter];
            }
                    
            // Successful playback of the rewarded video; reset the internal played state.
            self.adapter = nil;     // `nil` to trigger the scheduled deallocation since we are handing over ownership of the reference
            self.ready = NO;
            self.playedAd = YES;
            self.loading = NO;
            
            MPLogAdEvent(MPLogEvent.adDidDismiss, self.adUnitId);
            [self.delegate rewardedAdDidDismissForAdManager:self];
            break;
        }
    }
}

- (void)adDidReceiveImpressionEventForAdapter:(id<MPAdAdapter>)adapter {
    [self.delegate rewardedAdManager:self didReceiveImpressionEventWithImpressionData:self.configuration.impressionData];
}

- (void)adShouldRewardUserForAdapter:(id<MPAdAdapter>)adapter reward:(MPReward *)reward {
    MPLogAdEvent([MPLogEvent adShouldRewardUserWithReward:reward], self.adUnitId);
    [self.delegate rewardedAdShouldRewardUserForAdManager:self reward:reward];
}

@end
