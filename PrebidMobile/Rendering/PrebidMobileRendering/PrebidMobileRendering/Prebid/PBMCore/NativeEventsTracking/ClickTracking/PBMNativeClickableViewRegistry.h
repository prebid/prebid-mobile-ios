//
//  PBMNativeClickableViewRegistry.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeAdMarkupLink.h"
#import "PBMNativeClickTrackerBinderFactoryBlock.h"
#import "PBMNativeViewClickHandlerBlock.h"

NS_ASSUME_NONNULL_BEGIN

@class UIView;


@interface PBMNativeClickableViewRegistry : NSObject

- (instancetype)initWithBinderFactory:(PBMNativeClickTrackerBinderFactoryBlock)binderFactory
                         clickHandler:(PBMNativeViewClickHandlerBlock)clickHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)registerLink:(PBMNativeAdMarkupLink *)link forView:(UIView *)view;

/// does NOT overwrite 'url'+'fallback' if 'url' is already present
- (void)registerParentLink:(PBMNativeAdMarkupLink *)link forView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
