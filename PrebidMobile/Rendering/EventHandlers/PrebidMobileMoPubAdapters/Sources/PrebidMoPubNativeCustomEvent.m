//
//  PBMMoPubNativeCustomEvent.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//
#import <MoPub/MoPub.h>

#import <PrebidMobileRendering/PBMNativeAd.h>

#import "PrebidMoPubNativeAdAdapter.h"
#import "PrebidMoPubNativeCustomEvent.h"

@implementation PrebidMoPubNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    [self requestAdWithCustomEventInfo:info adMarkup:nil];
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (self.localExtras.count == 0) {
        NSError *error = [NSError errorWithDomain:PBMErrorDomain
                                             code:PBMErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The local extras is empty", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], @"");
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    [PBMMoPubUtils findNativeAd:self.localExtras callback:^(PBMNativeAd *nativeAd, NSError *error){
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        
        if (nativeAd) {
            [strongSelf nativeAdDidLoad:nativeAd];
        } else {
            MPLogEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(strongSelf.class) error:error]);
            [strongSelf.delegate nativeCustomEvent:strongSelf didFailToLoadAdWithError:error];
        }
    }];
}

#pragma mark - Private methods

- (void)nativeAdDidLoad:(PBMNativeAd *)nativeAd{
    PrebidMoPubNativeAdAdapter *adAdapter = [[PrebidMoPubNativeAdAdapter alloc] initWithPBMNativeAd:nativeAd];
    
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

@end
