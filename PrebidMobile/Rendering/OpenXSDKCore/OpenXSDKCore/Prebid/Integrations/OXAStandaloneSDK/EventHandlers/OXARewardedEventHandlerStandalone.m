//
//  OXARewardedEventHandlerStandalone.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXARewardedEventHandlerStandalone.h"

@implementation OXARewardedEventHandlerStandalone

@synthesize loadingDelegate = _loadingDelegate;
@synthesize interactionDelegate = _interactionDelegate;

- (BOOL)isReady {
    return NO;
}

- (void)requestAdWithBidResponse:(nullable OXABidResponse *)bidResponse {
    [self.loadingDelegate apolloDidWin];
}

- (void)showFromViewController:(UIViewController *)controller {
    // nop -- should never be called, as OXA SDK always wins
}

@end
