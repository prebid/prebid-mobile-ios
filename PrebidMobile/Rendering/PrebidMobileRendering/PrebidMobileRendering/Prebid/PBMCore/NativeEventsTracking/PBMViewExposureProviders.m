/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMViewExposureProviders.h"

#import "PBMViewExposureChecker.h"
#import "UIView+PBMExtensions.h"

#ifdef DEBUG
    #import "PrebidRenderingConfig+TestExtension.h"
#endif

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

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
        if (PrebidRenderingConfig.shared.forcedIsViewable) {
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
