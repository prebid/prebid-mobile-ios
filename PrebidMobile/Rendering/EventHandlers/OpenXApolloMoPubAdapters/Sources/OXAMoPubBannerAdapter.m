//
//  OXAMoPubBannerAdapter.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import OpenXApolloSDK;

#import "OXAMoPubBannerAdapter.h"

/**
 OXA SDK passes to the localExtras two objects: OXABid, configId
 */

@interface OXAMoPubBannerAdapter () <OXADisplayViewLoadingDelegate, OXADisplayViewInteractionDelegate>

@property (nonatomic, copy) NSString *configId;
@property (strong, nonatomic) OXADisplayView *displayView;

@end

@implementation OXAMoPubBannerAdapter

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (self.localExtras.count == 0) {
        NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                             code:OXAErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The local extras is empty", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], @"");
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    OXABid *bid = self.localExtras[OXAMoPubAdUnitBidKey];
    if (!bid) {
        NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                             code:OXAErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Bid object is absent in the extras", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.configId = self.localExtras[OXAMoPubConfigIdKey];
    if (!self.configId) {
        NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                             code:OXAErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The Config ID absent in the extras", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.displayView = [[OXADisplayView alloc] initWithFrame:(CGRect){.origin = CGPointZero, .size = bid.size} bid:bid configId:self.configId];
    self.displayView.loadingDelegate = self;
    self.displayView.interactionDelegate = self;
    
    [self.displayView displayAd];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdUnitId]);
}

- (NSString *) getAdUnitId {
    return self.configId ?: @"";
}

#pragma mark - OXADisplayViewDelegate handlers


- (void)didLeaveAppFromDisplayView:(nonnull OXADisplayView *)displayView {
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate inlineAdAdapterWillLeaveApplication:self];
}

- (void)displayView:(nonnull OXADisplayView *)displayView didFailWithError:(nonnull NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdUnitId]);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)displayViewDidLoadAd:(nonnull OXADisplayView *)displayView {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:self.displayView];
}

- (void)trackImpressionForDisplayView:(nonnull OXADisplayView *)displayView {
    //Impressions will be tracked automatically
    //unless enableAutomaticImpressionAndClickTracking = NO
    //In this case you have to override the didDisplayAd method
    //and manually call inlineAdAdapterDidTrackImpression
    //in this method to ensure correct metrics
}

- (nonnull UIViewController *)viewControllerForModalPresentationFrom:(nonnull OXADisplayView *)displayView {
    return [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
}

- (void)displayViewWillPresentModal:(OXADisplayView *)displayView {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdUnitId]);
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)displayViewDidDismissModal:(OXADisplayView *)displayView {
    MPLogInfo(@"Banner's clickthrough did close");
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

@end
