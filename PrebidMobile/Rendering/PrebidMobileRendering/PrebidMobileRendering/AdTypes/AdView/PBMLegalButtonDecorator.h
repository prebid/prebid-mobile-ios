//
//  PBMLegalButtonDecorator.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMAdViewButtonDecorator.h"
#import "PBMClickthroughBrowserView.h"

FOUNDATION_EXPORT NSString * _Nonnull const PBMPrivacyPolicyUrlString;

NS_ASSUME_NONNULL_BEGIN
@interface PBMLegalButtonDecorator : PBMAdViewButtonDecorator

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPosition:(PBMPosition)position;

- (nullable PBMClickthroughBrowserView *)clickthroughBrowserView;

@end
NS_ASSUME_NONNULL_END
