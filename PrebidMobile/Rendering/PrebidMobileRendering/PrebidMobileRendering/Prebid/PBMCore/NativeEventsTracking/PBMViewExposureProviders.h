//
//  PBMViewExposureProviders.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMViewExposureProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMViewExposureProviders : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (PBMViewExposureProvider)viewExposureForView:(UIView *)view;
+ (PBMViewExposureProvider)visibilityAsExposureForView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
