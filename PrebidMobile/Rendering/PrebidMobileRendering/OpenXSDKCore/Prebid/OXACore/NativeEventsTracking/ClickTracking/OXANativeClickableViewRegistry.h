//
//  OXANativeClickableViewRegistry.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeAdMarkupLink.h"
#import "OXANativeClickTrackerBinderFactoryBlock.h"
#import "OXANativeViewClickHandlerBlock.h"

NS_ASSUME_NONNULL_BEGIN

@class UIView;


@interface OXANativeClickableViewRegistry : NSObject

- (instancetype)initWithBinderFactory:(OXANativeClickTrackerBinderFactoryBlock)binderFactory
                         clickHandler:(OXANativeViewClickHandlerBlock)clickHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)registerLink:(OXANativeAdMarkupLink *)link forView:(UIView *)view;

/// does NOT overwrite 'url'+'fallback' if 'url' is already present
- (void)registerParentLink:(OXANativeAdMarkupLink *)link forView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
