/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMBannerAdLoader.h"

#import <UIKit/UIKit.h>

#import "PBMAdLoaderFlowDelegate.h"
#import "PBMDisplayView.h"
#import "PBMDisplayView+InternalState.h"

#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif


@interface PBMBannerAdLoader () <DisplayViewLoadingDelegate, BannerEventLoadingDelegate>
@property (nonatomic, weak, nullable, readonly) id<BannerAdLoaderDelegate> delegate;
@end



@implementation PBMBannerAdLoader

@synthesize flowDelegate = _flowDelegate;

// MARK: - Lifecycle

- (instancetype)initWithDelegate:(id<BannerAdLoaderDelegate>)delegate {
    if (!(self = [super init])) {
        return nil;
    }
    _delegate = delegate;
    return self;
}

// MARK: - PBMAdLoaderProtocol

- (id<PBMPrimaryAdRequesterProtocol>)primaryAdRequester {
    id<BannerEventHandler> const eventHandler = self.delegate.eventHandler;
    eventHandler.loadingDelegate = self;
    return eventHandler;
}

- (void)createPrebidAdWithBid:(Bid *)bid
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
        if (!self) { return; }
        
        newDisplayView.loadingDelegate = self;
        [self.delegate bannerAdLoader:self createdDisplayView:newDisplayView];
        [newDisplayView displayAd];
    });
}

- (void)reportSuccessWithAdObject:(id)adObject adSize:(nullable NSValue *)adSize {
    [self.delegate bannerAdLoader:self loadedAdView:adObject adSize:adSize.CGSizeValue];
}

// MARK: - DisplayViewLoadingDelegate

- (void)displayViewDidLoadAd:(PBMDisplayView *)displayView {
    [self.flowDelegate adLoaderLoadedPrebidAd:self];
}

- (void)displayView:(PBMDisplayView *)displayView didFailWithError:(NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrebidError:error];
}

// MARK: - BannerEventLoadingDelegate

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
