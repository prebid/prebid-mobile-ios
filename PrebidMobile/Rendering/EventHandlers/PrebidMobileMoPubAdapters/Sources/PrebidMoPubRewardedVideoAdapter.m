//
//  PBMMoPubRewardedVideoAdapter.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <MoPub/MoPub.h>

#import <PrebidMobileRendering/PBMInterstitialController.h>

#import "PrebidMoPubRewardedVideoAdapter.h"

@interface PrebidMoPubRewardedVideoAdapter () <PBMInterstitialControllerLoadingDelegate, PBMInterstitialControllerInteractionDelegate>

@property (nonatomic, strong) PBMInterstitialController* interstitialController;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, copy) NSString *configId;
@property (nonatomic, assign) BOOL adAvailable;
@end

@implementation PrebidMoPubRewardedVideoAdapter

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (self.localExtras.count == 0) {
        NSError *error = [NSError errorWithDomain:PBMErrorDomain
                                             code:PBMErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The local extras is empty", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], @"");
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    PBMBid *bid = self.localExtras[PBMMoPubAdUnitBidKey];
    if (!bid) {
        NSError *error = [NSError errorWithDomain:PBMErrorDomain
                                             code:PBMErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Bid object is absent in the extras", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.configId = self.localExtras[PBMMoPubConfigIdKey];
    if (!self.configId) {
        NSError *error = [NSError errorWithDomain:PBMErrorDomain
                                             code:PBMErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Config ID absent in the extras", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.interstitialController = [[PBMInterstitialController alloc] initWithBid:bid configId:self.configId];
    self.interstitialController.loadingDelegate = self;
    self.interstitialController.interactionDelegate = self;
    self.interstitialController.adFormat = PBMAdFormatVideo;
    self.interstitialController.isOptIn = YES;
    
    [self.interstitialController loadAd];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdUnitId]);
}

-(BOOL)isRewardExpected {
    return YES;
}

-(BOOL)hasAdAvailable {
    return self.adAvailable;
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    
    if ([self hasAdAvailable]) {
        self.rootViewController = viewController;
        [self.interstitialController show];
    } else {
        NSError *error = [NSError errorWithDomain:PBMErrorDomain
                                             code:PBMErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The ad hasn’t been loaded", nil)}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    }
}

- (NSString *) getAdUnitId {
    return self.configId ?: @"";
}

#pragma mark - PBMInterstitialControllerDelegate

- (void)interstitialController:(nonnull PBMInterstitialController *)interstitialController didFailWithError:(nonnull NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
    self.adAvailable = NO;
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialControllerDidDisplay:(PBMInterstitialController *)interstitialController {
    NSString *adUnitId = [self getAdUnitId];
    NSString *classString = NSStringFromClass(self.class);
    MPLogAdEvent(MPLogEvent.adShowSuccess, adUnitId);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:classString], adUnitId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:classString], adUnitId);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:classString], adUnitId);
    
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)interstitialControllerDidComplete:(PBMInterstitialController *)interstitialController {
    self.adAvailable = NO;
    
    // Get rid of the interstitial view controller when done with it so we don't hold on longer than needed
    self.interstitialController = nil;
    MPLogInfo(@"Interstitial did complete");
    MPReward *reward = [[MPReward alloc] initWithCurrencyAmount:@(1)];
    [self.delegate fullscreenAdAdapter:self willRewardUser:reward];
}

- (void)interstitialControllerDidClickAd:(nonnull PBMInterstitialController *)interstitialController {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)interstitialControllerDidCloseAd:(nonnull PBMInterstitialController *)interstitialController {
    self.adAvailable = NO;
    NSString *adUnitId = [self getAdUnitId];
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], adUnitId);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], adUnitId);

    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)interstitialControllerDidLeaveApp:(nonnull PBMInterstitialController *)interstitialController {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)interstitialControllerDidLoadAd:(nonnull PBMInterstitialController *)interstitialController {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    self.adAvailable = YES;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)trackImpressionForInterstitialController:(nonnull PBMInterstitialController *)interstitialController {
    //Impressions will be tracked automatically
    //unless enableAutomaticImpressionAndClickTracking = NO
    //In this case you have to override the didDisplayAd method
    //and manually call inlineAdAdapterDidTrackImpression
    //in this method to ensure correct metrics
}

- (nonnull UIViewController *)viewControllerForModalPresentationFrom:(nonnull PBMInterstitialController *)interstitialController {
    return self.rootViewController;
}


@end
