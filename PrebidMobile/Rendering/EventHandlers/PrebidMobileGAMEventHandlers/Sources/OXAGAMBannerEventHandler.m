//
//  OXAGAMBannerEventHandler.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAGAMBannerEventHandler.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <PrebidMobileRendering/OXABid.h>
#import "OXADFPBanner.h"
#import "OXADFPRequest.h"
#import "OXAGAMError.h"



static NSString * const appEvent = @"OpenXApolloAppEvent";
static float const appEventTimeout = 0.6f;


@interface OXAGAMBannerEventHandler () <GADBannerViewDelegate, GADAppEventDelegate, GADAdSizeDelegate>

@property (nonatomic, strong, nullable) OXADFPBanner *requestBanner;
@property (nonatomic, strong, nullable) OXADFPBanner *oxbProxyBanner;
@property (nonatomic, strong, nullable) OXADFPBanner *embeddedBanner;
@property (nonatomic, assign) BOOL isExpectingAppEvent;

@property (nonatomic, strong, readonly, nonnull) NSArray<NSValue *> *validGADSizes;

// invalidate <- [self appEventDetected]
// on timeout -> [self appEventTimedOut]
@property (nonatomic, strong, nullable) NSTimer *appEventTimer;

@property (nonatomic, strong, nullable) NSValue *lastGADSize; // CGSize?
@property (nonatomic, readonly) CGSize dfpAdSize; // => lastGADSize ?: dfpBanner.size

@end



@implementation OXAGAMBannerEventHandler

@synthesize loadingDelegate = _loadingDelegate;
@synthesize interactionDelegate = _interactionDelegate;
@synthesize adSizes = _adSizes;

// MARK: - Public API

- (instancetype)initWithAdUnitID:(NSString *)adUnitID validGADAdSizes:(NSArray<NSValue *> *)adSizes {
    if (!(self = [super init])) {
        return nil;
    }
    _adUnitID = [adUnitID copy];
    _validGADSizes = [NSArray arrayWithArray:adSizes];
    _adSizes = [OXAGAMBannerEventHandler convertGADSizes:adSizes];
        
    return self;
}

// MARK: - OXABannerEventHandler protocol

- (void)requestAdWithBidResponse:(nullable OXABidResponse *)bidResponse {
    if (!([OXADFPBanner classesFound] && [OXADFPRequest classesFound])) {
        NSError * const error = [OXAGAMError gamClassesNotFound];
        [OXAGAMError logError:error];
        [self.loadingDelegate failedWithError:error];
        return;
    }
    if (self.requestBanner) {
        // request to primaryAdServer in progress
        return;
    }
    self.requestBanner = [[OXADFPBanner alloc] init];
    self.requestBanner.adUnitID = self.adUnitID;
    self.requestBanner.validAdSizes = self.validGADSizes;
    self.requestBanner.rootViewController = self.interactionDelegate.viewControllerForPresentingModal;
    OXADFPRequest * const dfpRequest = [[OXADFPRequest alloc] init];
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
    self.requestBanner.delegate = self;
    self.requestBanner.appEventDelegate = self;
    self.requestBanner.adSizeDelegate = self;
    self.requestBanner.enableManualImpressions = YES;
    
    self.lastGADSize = nil;
    
    [self.requestBanner loadRequest:dfpRequest];
}

- (void)trackImpression {
    [self.oxbProxyBanner recordImpression];
}

- (BOOL)isCreativeRequiredForNativeAds {
    return NO;
}

// MARK: - GADBannerViewDelegate protocol

- (void)adViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    if (self.requestBanner.view == bannerView) {
        [self primaryAdReceived];
    }
}

- (void)adView:(nonnull GADBannerView *)bannerView didFailToReceiveAdWithError:(nonnull GADRequestError *)error {
    if (self.requestBanner.view == bannerView) {
        self.requestBanner = nil;
        [self recycleCurrentBanner];
        [self.loadingDelegate failedWithError:error];
    }
}

- (void)adViewWillPresentScreen:(nonnull GADBannerView *)bannerView {
    [self.interactionDelegate willPresentModal];
}

- (void)adViewWillDismissScreen:(nonnull GADBannerView *)bannerView {
    // nop
}

- (void)adViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    [self.interactionDelegate didDismissModal];
}

- (void)adViewWillLeaveApplication:(nonnull GADBannerView *)bannerView {
    [self.interactionDelegate willLeaveApp];
}

// MARK: - GADAppEventDelegate protocol

- (void)adView:(nonnull GADBannerView *)banner
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info
{
    if (self.requestBanner.view == banner && [name isEqualToString:appEvent]) {
        [self appEventDetected];
    }
}

- (void)interstitial:(nonnull GADInterstitial *)interstitial
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info
{
    // nop
}

// MARK: - GADAdSizeDelegate protocol

- (void)adView:(nonnull GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size {
    self.lastGADSize = [NSValue valueWithCGSize:size.size];
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
        OXADFPBanner * const dfpBanner = self.requestBanner;
        self.requestBanner = nil;
        [self recycleCurrentBanner];
        self.embeddedBanner = dfpBanner;
        [self.loadingDelegate adServerDidWin:dfpBanner.view adSize:self.dfpAdSize];
    }
}

- (void)appEventDetected {
    OXADFPBanner * const dfpBanner = self.requestBanner;
    self.requestBanner = nil;
    if (self.isExpectingAppEvent) {
        if (self.appEventTimer) {
            [self.appEventTimer invalidate];
            self.appEventTimer = nil;
        }
        self.isExpectingAppEvent = NO;
        [self recycleCurrentBanner];
        self.oxbProxyBanner = dfpBanner;
        [self.loadingDelegate apolloDidWin];
    }
}

- (void)appEventTimedOut {
    OXADFPBanner * const dfpBanner = self.requestBanner;
    self.requestBanner = nil;
    [self recycleCurrentBanner];
    self.embeddedBanner = dfpBanner;
    self.isExpectingAppEvent = NO;
    self.appEventTimer = nil;
    [self.loadingDelegate adServerDidWin:dfpBanner.view adSize:self.dfpAdSize];
}

- (void)recycleCurrentBanner {
    self.embeddedBanner = nil;
    self.oxbProxyBanner = nil;
}

- (CGSize)dfpAdSize {
    return (self.lastGADSize ? self.lastGADSize.CGSizeValue : self.requestBanner.adSize.size);
}

+ (NSArray<NSValue *> *)convertGADSizes:(NSArray<NSValue *> *)GADSizes {
    NSMutableArray<NSValue *> *res = [NSMutableArray<NSValue *> new];
    
    for (NSValue *item in GADSizes) {
        GADAdSize size = GADAdSizeFromNSValue(item);
        [res addObject:[NSValue valueWithCGSize:CGSizeFromGADAdSize(size)]];
    }
    
    return res;
}

@end
