//
//  UIView+OXMViewExposure.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "UIView+OXMViewExposure.h"
#import "OXMViewExposureChecker.h"

@implementation UIView (OXMViewExposure)

- (OXMViewExposure *)viewExposure {
    return [OXMViewExposureChecker exposureOfView:self];
}

@end
