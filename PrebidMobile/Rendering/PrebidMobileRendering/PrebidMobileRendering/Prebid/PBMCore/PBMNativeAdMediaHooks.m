//
//  PBMNativeAdMediaHooks.m
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeAdMediaHooks.h"

@implementation PBMNativeAdMediaHooks

- (instancetype)initWithViewControllerProvider:(PBMViewControllerProvider)viewControllerProvider
                          clickHandlerOverride:(PBMCreativeClickHandlerBlock)clickHandlerOverride
{
    if (!(self = [super init])) {
        return nil;
    }
    _viewControllerProvider = [viewControllerProvider copy];
    _clickHandlerOverride = [clickHandlerOverride copy];
    return self;
}

@end
