//
//  OXAMoPubVideoInterstitialAdapter.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <MoPub/MoPub.h>

#import <PrebidMobileRendering/OXAInterstitialController.h>

#import "OXAMoPubVideoInterstitialAdapter.h"

@interface OXAMoPubVideoInterstitialAdapter () <OXAInterstitialControllerLoadingDelegate, OXAInterstitialControllerInteractionDelegate>

@property (nonatomic, strong) OXAInterstitialController* interstitialController;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, copy) NSString *configId;
@end

@implementation OXAMoPubVideoInterstitialAdapter

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (self.localExtras.count == 0) {
        NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                             code:OXAErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The local extras is empty", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], @"");
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    OXABid *bid = self.localExtras[OXAMoPubAdUnitBidKey];
    if (!bid) {
        NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                             code:OXAErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Bid object is absent in the extras", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.configId = self.localExtras[OXAMoPubConfigIdKey];
    if (!self.configId) {
        NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                             code:OXAErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Config ID absent in the extras", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.interstitialController = [[OXAInterstitialController alloc] initWithBid:bid configId:self.configId];
    self.interstitialController.loadingDelegate = self;
    self.interstitialController.interactionDelegate = self;
    self.interstitialController.adFormat = OXAAdFormatVideo;
    
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

#pragma mark - OXAInterstitialControllerDelegate

- (void)interstitialController:(nonnull OXAInterstitialController *)interstitialController didFailWithError:(nonnull NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialControllerDidClickAd:(nonnull OXAInterstitialController *)interstitialController {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)interstitialControllerDidCloseAd:(nonnull OXAInterstitialController *)interstitialController {
    NSString *adUnitId = [self getAdUnitId];
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], adUnitId);
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], adUnitId);

    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)interstitialControllerDidLeaveApp:(nonnull OXAInterstitialController *)interstitialController {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)interstitialControllerDidLoadAd:(nonnull OXAInterstitialController *)interstitialController {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)trackImpressionForInterstitialController:(nonnull OXAInterstitialController *)interstitialController {
    //Impressions will be tracked automatically
    //unless enableAutomaticImpressionAndClickTracking = NO
    //In this case you have to override the didDisplayAd method
    //and manually call inlineAdAdapterDidTrackImpression
    //in this method to ensure correct metrics
}

- (nonnull UIViewController *)viewControllerForModalPresentationFrom:(nonnull OXAInterstitialController *)interstitialController {
    return self.rootViewController;
}

@end
