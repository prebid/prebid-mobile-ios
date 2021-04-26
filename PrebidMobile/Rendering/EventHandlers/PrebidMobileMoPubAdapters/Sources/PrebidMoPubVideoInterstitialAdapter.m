//
//  PBMMoPubVideoInterstitialAdapter.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <MoPub/MoPub.h>

#import <PrebidMobileRendering/PBMInterstitialController.h>

#import "PrebidMoPubVideoInterstitialAdapter.h"

@interface PrebidMoPubVideoInterstitialAdapter () <PBMInterstitialControllerLoadingDelegate, PBMInterstitialControllerInteractionDelegate>

@property (nonatomic, strong) PBMInterstitialController* interstitialController;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, copy) NSString *configId;
@end

@implementation PrebidMoPubVideoInterstitialAdapter

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
    
    [self.interstitialController loadAd];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdUnitId]);
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    self.rootViewController = viewController;
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.interstitialController show];
}

- (NSString *) getAdUnitId {
    return self.configId ?: @"";
}

#pragma mark - PBMInterstitialControllerDelegate

- (void)interstitialController:(nonnull PBMInterstitialController *)interstitialController didFailWithError:(nonnull NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialControllerDidClickAd:(nonnull PBMInterstitialController *)interstitialController {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)interstitialControllerDidCloseAd:(nonnull PBMInterstitialController *)interstitialController {
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
