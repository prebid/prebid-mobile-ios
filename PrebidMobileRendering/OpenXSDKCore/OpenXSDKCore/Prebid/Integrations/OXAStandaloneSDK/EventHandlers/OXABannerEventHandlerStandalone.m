//
//  OXABannerEventHandlerStandalone.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABannerEventHandlerStandalone.h"

@implementation OXABannerEventHandlerStandalone

@synthesize loadingDelegate = _loadingDelegate;
@synthesize interactionDelegate = _interactionDelegate;
@synthesize adSizes = _adSizes;

- (void)requestAdWithBidResponse:(nullable OXABidResponse *)bidResponse {
    [self.loadingDelegate apolloDidWin];
}

- (BOOL)isCreativeRequiredForNativeAds {
    return YES;
}

@end
