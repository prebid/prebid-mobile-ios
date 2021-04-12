//
//  OXABannerAdLoader.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABannerAdLoader.h"

#import <UIKit/UIKit.h>

#import "OXAAdLoaderFlowDelegate.h"
#import "OXABannerEventHandler.h"
#import "OXABannerEventLoadingDelegate.h"
#import "OXABid.h"
#import "OXADisplayView.h"
#import "OXADisplayView+InternalState.h"
#import "OXADisplayViewLoadingDelegate.h"

#import "OXMMacros.h"


@interface OXABannerAdLoader () <OXADisplayViewLoadingDelegate, OXABannerEventLoadingDelegate>
@property (nonatomic, weak, nullable, readonly) id<OXABannerAdLoaderDelegate> delegate;
@end



@implementation OXABannerAdLoader

@synthesize flowDelegate = _flowDelegate;

// MARK: - Lifecycle

- (instancetype)initWithDelegate:(id<OXABannerAdLoaderDelegate>)delegate {
    if (!(self = [super init])) {
        return nil;
    }
    _delegate = delegate;
    return self;
}

// MARK: - OXAAdLoaderProtocol

- (id<OXAPrimaryAdRequesterProtocol>)primaryAdRequester {
    id<OXABannerEventHandler> const eventHandler = self.delegate.eventHandler;
    eventHandler.loadingDelegate = self;
    return eventHandler;
}

- (void)createApolloAdWithBid:(OXABid *)bid
                 adUnitConfig:(OXAAdUnitConfig *)adUnitConfig
                adObjectSaver:(void (^)(id))adObjectSaver
            loadMethodInvoker:(void (^)(dispatch_block_t))loadMethodInvoker
{
    CGRect const displayFrame = CGRectMake(0, 0, bid.size.width, bid.size.height);
    OXADisplayView * const newDisplayView = [[OXADisplayView alloc] initWithFrame:displayFrame
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

// MARK: - OXADisplayViewLoadingDelegate

- (void)displayViewDidLoadAd:(OXADisplayView *)displayView {
    [self.flowDelegate adLoaderLoadedApolloAd:self];
}

- (void)displayView:(OXADisplayView *)displayView didFailWithError:(NSError *)error {
    [self.flowDelegate adLoader:self failedWithApolloError:error];
}

// MARK: - OXABannerEventLoadingDelegate

- (void)apolloDidWin {
    [self.flowDelegate adLoaderDidWinApollo:self];
}

- (void)adServerDidWin:(UIView *)view adSize:(CGSize)adSize {
    [self.flowDelegate adLoader:self loadedPrimaryAd:view adSize:[NSValue valueWithCGSize:adSize]];
}

- (void)failedWithError:(nullable NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrimarySDKError:error];
}

@end
