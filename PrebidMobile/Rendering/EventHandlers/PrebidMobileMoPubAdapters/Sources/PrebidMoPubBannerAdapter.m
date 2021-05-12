//
//  PBMMoPubBannerAdapter.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <MoPub.h>

#import <PrebidMobileRendering/PBMDisplayView.h>

#import "PrebidMoPubBannerAdapter.h"

/**
 PBM SDK passes to the localExtras two objects: PBMBid, configId
 */

@interface PrebidMoPubBannerAdapter () <PBMDisplayViewLoadingDelegate, PBMDisplayViewInteractionDelegate>

@property (nonatomic, copy) NSString *configId;
@property (strong, nonatomic) PBMDisplayView *displayView;

@end

@implementation PrebidMoPubBannerAdapter

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (self.localExtras.count == 0) {
        NSError *error = [NSError errorWithDomain:PBMErrorDomain
                                             code:PBMErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The local extras is empty", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], @"");
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    PBMBid *bid = self.localExtras[PBMMoPubAdUnitBidKey];
    if (!bid) {
        NSError *error = [NSError errorWithDomain:PBMErrorDomain
                                             code:PBMErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Bid object is absent in the extras", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.configId = self.localExtras[PBMMoPubConfigIdKey];
    if (!self.configId) {
        NSError *error = [NSError errorWithDomain:PBMErrorDomain
                                             code:PBMErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Config ID absent in the extras", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.displayView = [[PBMDisplayView alloc] initWithFrame:(CGRect){.origin = CGPointZero, .size = bid.size} bid:bid configId:self.configId];
    self.displayView.loadingDelegate = self;
    self.displayView.interactionDelegate = self;
    
    [self.displayView displayAd];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdUnitId]);
}

- (NSString *) getAdUnitId {
    return self.configId ?: @"";
}

#pragma mark - PBMDisplayViewDelegate handlers


- (void)didLeaveAppFromDisplayView:(nonnull PBMDisplayView *)displayView {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (void)displayView:(nonnull PBMDisplayView *)displayView didFailWithError:(nonnull NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)displayViewDidLoadAd:(nonnull PBMDisplayView *)displayView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:self.displayView];
}

- (void)trackImpressionForDisplayView:(nonnull PBMDisplayView *)displayView {
    //Impressions will be tracked automatically
    //unless enableAutomaticImpressionAndClickTracking = NO
    //In this case you have to override the didDisplayAd method
    //and manually call inlineAdAdapterDidTrackImpression
    //in this method to ensure correct metrics
}

- (nonnull UIViewController *)viewControllerForModalPresentationFrom:(nonnull PBMDisplayView *)displayView {
    return [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
}

- (void)displayViewWillPresentModal:(PBMDisplayView *)displayView {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)displayViewDidDismissModal:(PBMDisplayView *)displayView {
    MPLogInfo(@"Banner's clickthrough did close");
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

@end
