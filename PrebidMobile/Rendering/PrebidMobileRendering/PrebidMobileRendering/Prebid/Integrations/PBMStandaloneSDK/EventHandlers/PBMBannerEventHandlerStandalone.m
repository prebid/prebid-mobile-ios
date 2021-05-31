//
//  PBMBannerEventHandlerStandalone.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBannerEventHandlerStandalone.h"

@implementation PBMBannerEventHandlerStandalone

@synthesize loadingDelegate = _loadingDelegate;
@synthesize interactionDelegate = _interactionDelegate;
@synthesize adSizes = _adSizes;

- (void)requestAdWithBidResponse:(nullable BidResponse *)bidResponse {
    [self.loadingDelegate prebidDidWin];
}

- (BOOL)isCreativeRequiredForNativeAds {
    return YES;
}

@end
