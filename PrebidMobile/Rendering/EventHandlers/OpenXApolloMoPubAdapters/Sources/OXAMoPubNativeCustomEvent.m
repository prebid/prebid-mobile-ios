//
//  OXAMoPubNativeCustomEvent.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import OpenXApolloSDK;

#import "OXAMoPubNativeAdAdapter.h"
#import "OXAMoPubNativeCustomEvent.h"

@implementation OXAMoPubNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    [self requestAdWithCustomEventInfo:info adMarkup:nil];
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (self.localExtras.count == 0) {
        NSError *error = [NSError errorWithDomain:OXAErrorDomain
                                             code:OXAErrorCodeGeneral
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"The local extras is empty", nil)}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], @"");
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    [OXAMoPubUtils findNativeAd:self.localExtras callback:^(OXANativeAd *nativeAd, NSError *error){
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

- (void)nativeAdDidLoad:(OXANativeAd *)nativeAd{
    OXAMoPubNativeAdAdapter *adAdapter = [[OXAMoPubNativeAdAdapter alloc] initWithOXANativeAd:nativeAd];
    
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    MPLogEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
}

@end
