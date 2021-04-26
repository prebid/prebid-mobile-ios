//
//  UIView+PBMViewExposure.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "UIView+PBMViewExposure.h"
#import "PBMViewExposureChecker.h"

@implementation UIView (PBMViewExposure)

- (PBMViewExposure *)viewExposure {
    return [PBMViewExposureChecker exposureOfView:self];
}

@end
