//
//  PBMViewExposureProviders.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMViewExposureProviders.h"

#import "PBMSDKConfiguration.h"
#import "PBMSDKConfiguration+pbmTestExtension.h"
#import "PBMViewExposureChecker.h"
#import "UIView+PBMExtensions.h"

@implementation PBMViewExposureProviders

+ (PBMViewExposureProvider)viewExposureForView:(UIView *)view {
    PBMViewExposureChecker * const exposureChecker = [[PBMViewExposureChecker alloc] initWithView:view];
    return ^ PBMViewExposure * {
        return exposureChecker.exposure;
    };
}

+ (PBMViewExposureProvider)visibilityAsExposureForView:(UIView *)view {
    return ^ PBMViewExposure * {
        BOOL isViewVisible = (view && [view pbmIsVisibleInViewLegacy:view.superview] && (view.window != nil));
#       ifdef DEBUG
        if ([PBMSDKConfiguration singleton].forcedIsViewable) {
            isViewVisible = YES;
        }
#       endif
        if (isViewVisible) {
            return [[PBMViewExposure alloc] initWithExposureFactor:1
                                                  visibleRectangle:view.bounds
                                               occlusionRectangles:nil];
        } else {
            return [[PBMViewExposure alloc] initWithExposureFactor:0
                                                  visibleRectangle:CGRectZero
                                               occlusionRectangles:nil];
        }
    };
}

@end
