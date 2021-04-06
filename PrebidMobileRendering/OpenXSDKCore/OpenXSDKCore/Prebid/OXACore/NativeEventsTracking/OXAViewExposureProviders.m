//
//  OXAViewExposureProviders.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAViewExposureProviders.h"

#import "OXASDKConfiguration.h"
#import "OXASDKConfiguration+oxmTestExtension.h"
#import "OXMViewExposureChecker.h"
#import "UIView+OxmExtensions.h"

@implementation OXAViewExposureProviders

+ (OXAViewExposureProvider)viewExposureForView:(UIView *)view {
    OXMViewExposureChecker * const exposureChecker = [[OXMViewExposureChecker alloc] initWithView:view];
    return ^ OXMViewExposure * {
        return exposureChecker.exposure;
    };
}

+ (OXAViewExposureProvider)visibilityAsExposureForView:(UIView *)view {
    return ^ OXMViewExposure * {
        BOOL isViewVisible = (view && [view oxmIsVisibleInViewLegacy:view.superview] && (view.window != nil));
#       ifdef DEBUG
        if ([OXASDKConfiguration singleton].forcedIsViewable) {
            isViewVisible = YES;
        }
#       endif
        if (isViewVisible) {
            return [[OXMViewExposure alloc] initWithExposureFactor:1
                                                  visibleRectangle:view.bounds
                                               occlusionRectangles:nil];
        } else {
            return [[OXMViewExposure alloc] initWithExposureFactor:0
                                                  visibleRectangle:CGRectZero
                                               occlusionRectangles:nil];
        }
    };
}

@end
