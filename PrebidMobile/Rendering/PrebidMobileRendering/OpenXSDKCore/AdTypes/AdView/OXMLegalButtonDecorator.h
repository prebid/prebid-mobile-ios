//
//  OXMLegalButtonDecorator.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdViewButtonDecorator.h"
#import "OXMClickthroughBrowserView.h"

FOUNDATION_EXPORT NSString * _Nonnull const OXMPrivacyPolicyUrlString;

NS_ASSUME_NONNULL_BEGIN
@interface OXMLegalButtonDecorator : OXMAdViewButtonDecorator

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPosition:(OXMPosition)position;

- (nullable OXMClickthroughBrowserView *)clickthroughBrowserView;

@end
NS_ASSUME_NONNULL_END
