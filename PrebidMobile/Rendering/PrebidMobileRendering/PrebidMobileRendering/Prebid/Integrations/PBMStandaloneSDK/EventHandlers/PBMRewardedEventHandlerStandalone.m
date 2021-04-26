//
//  PBMRewardedEventHandlerStandalone.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMRewardedEventHandlerStandalone.h"

@implementation PBMRewardedEventHandlerStandalone

@synthesize loadingDelegate = _loadingDelegate;
@synthesize interactionDelegate = _interactionDelegate;

- (BOOL)isReady {
    return NO;
}

- (void)requestAdWithBidResponse:(nullable PBMBidResponse *)bidResponse {
    [self.loadingDelegate prebidDidWin];
}

- (void)showFromViewController:(UIViewController *)controller {
    // nop -- should never be called, as PBM SDK always wins
}

@end
