//
//  PBMBannerAdLoader.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBannerAdLoader.h"

#import <UIKit/UIKit.h>

#import "PBMAdLoaderFlowDelegate.h"
#import "PBMBannerEventHandler.h"
#import "PBMBannerEventLoadingDelegate.h"
#import "PBMBid.h"
#import "PBMDisplayView.h"
#import "PBMDisplayView+InternalState.h"
#import "PBMDisplayViewLoadingDelegate.h"

#import "PBMMacros.h"


@interface PBMBannerAdLoader () <PBMDisplayViewLoadingDelegate, PBMBannerEventLoadingDelegate>
@property (nonatomic, weak, nullable, readonly) id<PBMBannerAdLoaderDelegate> delegate;
@end



@implementation PBMBannerAdLoader

@synthesize flowDelegate = _flowDelegate;

// MARK: - Lifecycle

- (instancetype)initWithDelegate:(id<PBMBannerAdLoaderDelegate>)delegate {
    if (!(self = [super init])) {
        return nil;
    }
    _delegate = delegate;
    return self;
}

// MARK: - PBMAdLoaderProtocol

- (id<PBMPrimaryAdRequesterProtocol>)primaryAdRequester {
    id<PBMBannerEventHandler> const eventHandler = self.delegate.eventHandler;
    eventHandler.loadingDelegate = self;
    return eventHandler;
}

- (void)createPrebidAdWithBid:(PBMBid *)bid
                 adUnitConfig:(AdUnitConfig *)adUnitConfig
                adObjectSaver:(void (^)(id))adObjectSaver
            loadMethodInvoker:(void (^)(dispatch_block_t))loadMethodInvoker
{
    CGRect const displayFrame = CGRectMake(0, 0, bid.size.width, bid.size.height);
    PBMDisplayView * const newDisplayView = [[PBMDisplayView alloc] initWithFrame:displayFrame
                                                                              bid:bid
                                                                  adConfiguration:adUnitConfig];
    adObjectSaver(newDisplayView);
    @weakify(self);
    loadMethodInvoker(^{
        @strongify(self);
        newDisplayView.loadingDelegate = self;
        [self.delegate bannerAdLoader:self createdDisplayView:newDisplayView];
        [newDisplayView displayAd];
    });
}

- (void)reportSuccessWithAdObject:(id)adObject adSize:(nullable NSValue *)adSize {
    [self.delegate bannerAdLoader:self loadedAdView:adObject adSize:adSize.CGSizeValue];
}

// MARK: - PBMDisplayViewLoadingDelegate

- (void)displayViewDidLoadAd:(PBMDisplayView *)displayView {
    [self.flowDelegate adLoaderLoadedPrebidAd:self];
}

- (void)displayView:(PBMDisplayView *)displayView didFailWithError:(NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrebidError:error];
}

// MARK: - PBMBannerEventLoadingDelegate

- (void)prebidDidWin {
    [self.flowDelegate adLoaderDidWinPrebid:self];
}

- (void)adServerDidWin:(UIView *)view adSize:(CGSize)adSize {
    [self.flowDelegate adLoader:self loadedPrimaryAd:view adSize:[NSValue valueWithCGSize:adSize]];
}

- (void)failedWithError:(nullable NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrimarySDKError:error];
}

@end
