//
//  PBMGAMInterstitialEventHandler.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMGAMInterstitialEventHandler.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#import <PrebidMobileRendering/PBMBid.h>
#import "PBMDFPInterstitial.h"
#import "PBMDFPRequest.h"
#import "PBMGAMError.h"


static NSString * const appEvent = @"PrebidAppEvent";
static float const appEventTimeout = 0.6f;


@interface PBMGAMInterstitialEventHandler () <GADInterstitialDelegate, GADAppEventDelegate>

@property (nonatomic, strong, nullable) PBMDFPInterstitial *requestInterstitial;
@property (nonatomic, strong, nullable) PBMDFPInterstitial *oxbProxyInterstitial;
@property (nonatomic, strong, nullable) PBMDFPInterstitial *embeddedInterstitial;
@property (nonatomic, strong, readonly, nonnull) NSArray<NSValue *> *adSizes;
@property (nonatomic, assign) BOOL isExpectingAppEvent;

// invalidate <- [self appEventDetected]
// on timeout -> [self appEventTimedOut]
@property (nonatomic, strong, nullable) NSTimer *appEventTimer;

@end



@implementation PBMGAMInterstitialEventHandler

@synthesize loadingDelegate = _loadingDelegate;
@synthesize interactionDelegate = _interactionDelegate;

// MARK: - Public API

- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
    if (!(self = [super init])) {
        return nil;
    }
    _adUnitID = [adUnitID copy];
    return self;
}

- (BOOL)isReady {
    if (self.requestInterstitial) {
        return NO;
    }
    PBMDFPInterstitial * const loadedInterstitial = self.embeddedInterstitial ?: self.oxbProxyInterstitial;
    return loadedInterstitial.isReady;
}

// MARK: - PBMInterstitialEventHandler protocol

- (void)requestAdWithBidResponse:(nullable PBMBidResponse *)bidResponse {
    if (!([PBMDFPInterstitial classesFound] && [PBMDFPRequest classesFound])) {
        NSError * const error = [PBMGAMError gamClassesNotFound];
        [PBMGAMError logError:error];
        [self.loadingDelegate failedWithError:error];
        return;
    }
    if (self.requestInterstitial) {
        // request to primaryAdServer in progress
        return;
    }
    if (self.oxbProxyInterstitial || self.embeddedInterstitial) {
        // interstitial already loaded
        return;
    }
    self.requestInterstitial = [[PBMDFPInterstitial alloc] initWithAdUnitID:self.adUnitID];
    PBMDFPRequest * const dfpRequest = [[PBMDFPRequest alloc] init];
    if (bidResponse) {
        self.isExpectingAppEvent = bidResponse.winningBid;
        NSMutableDictionary * const targeting = [[NSMutableDictionary alloc] init];
        if (dfpRequest.customTargeting) {
            [targeting addEntriesFromDictionary:dfpRequest.customTargeting];
        }
        if (bidResponse.targetingInfo) {
            [targeting addEntriesFromDictionary:bidResponse.targetingInfo];
        }
        if (targeting.count) {
            dfpRequest.customTargeting = targeting;
        }
    }
    self.requestInterstitial.delegate = self;
    self.requestInterstitial.appEventDelegate = self;
    // self.requestInterstitial.enableManualImpressions = YES; // FIXME: (PB-X) Implement impressions
    
    [self.requestInterstitial loadRequest:dfpRequest];
}

- (void)showFromViewController:(UIViewController *)controller {
    if (self.embeddedInterstitial.isReady) {
        [self.embeddedInterstitial presentFromRootViewController:controller];
    }
}

- (void)trackImpression {
    // FIXME: (PB-X) Implement impressions
}

// MARK: - GADInterstitialDelegate protocol

- (void)interstitialDidReceiveAd:(nonnull GADInterstitial *)ad {
    if (self.requestInterstitial.boxedInterstitial == ad) {
        [self primaryAdReceived];
    }
}

- (void)interstitial:(nonnull GADInterstitial *)ad
    didFailToReceiveAdWithError:(nonnull GADRequestError *)error
{
    if (self.requestInterstitial.boxedInterstitial == ad) {
        self.requestInterstitial = nil;
        [self forgetCurrentInterstitial];
        [self.loadingDelegate failedWithError:error];
    }
}

- (void)interstitialWillPresentScreen:(nonnull GADInterstitial *)ad {
    [self.interactionDelegate willPresentAd];
}

- (void)interstitialDidFailToPresentScreen:(nonnull GADInterstitial *)ad {
    // nop?
}

- (void)interstitialWillDismissScreen:(nonnull GADInterstitial *)ad {
    // nop?
}

- (void)interstitialDidDismissScreen:(nonnull GADInterstitial *)ad {
    [self.interactionDelegate didDismissAd];
}

- (void)interstitialWillLeaveApplication:(nonnull GADInterstitial *)ad {
    [self.interactionDelegate willLeaveApp];
}

// MARK: - GADAppEventDelegate protocol

- (void)adView:(nonnull GADBannerView *)banner
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info
{
    // nop
}

- (void)interstitial:(nonnull GADInterstitial *)interstitial
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info
{
    if (self.requestInterstitial.boxedInterstitial == interstitial && [name isEqualToString:appEvent]) {
        [self appEventDetected];
    }
}

// MARK: - Private Helpers

- (void)primaryAdReceived {
    if (self.isExpectingAppEvent) {
        if (self.appEventTimer) {
            return;
        }
        self.appEventTimer = [NSTimer scheduledTimerWithTimeInterval:appEventTimeout
                                                              target:self
                                                            selector:@selector(appEventTimedOut)
                                                            userInfo:nil
                                                             repeats:NO];
    } else {
        // no bids were present in prebid response -- no need to wait for app event
        PBMDFPInterstitial * const dfpInterstitial = self.requestInterstitial;
        self.requestInterstitial = nil;
        [self forgetCurrentInterstitial];
        self.embeddedInterstitial = dfpInterstitial;
        [self.loadingDelegate adServerDidWin];
    }
}

- (void)appEventDetected {
    PBMDFPInterstitial * const dfpInterstitial = self.requestInterstitial;
    self.requestInterstitial = nil;
    if (self.isExpectingAppEvent) {
        if (self.appEventTimer) {
            [self.appEventTimer invalidate];
            self.appEventTimer = nil;
        }
        self.isExpectingAppEvent = NO;
        [self forgetCurrentInterstitial];
        self.oxbProxyInterstitial = dfpInterstitial;
        [self.loadingDelegate prebidDidWin];
    }
}

- (void)appEventTimedOut {
    PBMDFPInterstitial * const dfpInterstitial = self.requestInterstitial;
    self.requestInterstitial = nil;
    [self forgetCurrentInterstitial];
    self.embeddedInterstitial = dfpInterstitial;
    self.isExpectingAppEvent = NO;
    self.appEventTimer = nil;
    [self.loadingDelegate adServerDidWin];
}

- (void)forgetCurrentInterstitial {
    if (self.embeddedInterstitial) {
        self.embeddedInterstitial = nil;
    } else if (self.oxbProxyInterstitial) {
        self.oxbProxyInterstitial = nil;
        // self.recycledInterstitial.enableManualImpressions = NO;  // FIXME: (PB-X) Implement impressions
    }
}

@end
