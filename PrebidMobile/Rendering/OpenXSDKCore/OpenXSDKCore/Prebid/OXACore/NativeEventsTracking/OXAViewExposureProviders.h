//
//  OXAViewExposureProviders.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import UIKit;

#import "OXAViewExposureProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAViewExposureProviders : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (OXAViewExposureProvider)viewExposureForView:(UIView *)view;
+ (OXAViewExposureProvider)visibilityAsExposureForView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
