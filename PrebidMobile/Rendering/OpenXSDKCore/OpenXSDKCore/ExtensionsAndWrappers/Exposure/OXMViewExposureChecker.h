//
//  OXMViewExposureChecker.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OXMViewExposure.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXMViewExposureChecker : NSObject

+ (OXMViewExposure *)exposureOfView:(UIView *)view;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nonnull, readonly) OXMViewExposure *exposure; // calculated

@end

NS_ASSUME_NONNULL_END
