//
//  OXANativeAdMediaHooks.m
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeAdMediaHooks.h"

@implementation OXANativeAdMediaHooks

- (instancetype)initWithViewControllerProvider:(OXAViewControllerProvider)viewControllerProvider
                          clickHandlerOverride:(OXACreativeClickHandlerBlock)clickHandlerOverride
{
    if (!(self = [super init])) {
        return nil;
    }
    _viewControllerProvider = [viewControllerProvider copy];
    _clickHandlerOverride = [clickHandlerOverride copy];
    return self;
}

@end
