//
//  PBMMoPubNativeAdRenderer.h
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <MoPubSDK/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@class MPNativeAdRendererConfiguration;
@class MPStaticNativeAdRendererSettings;

@interface PrebidMoPubNativeAdRenderer : NSObject <MPNativeAdRenderer>

@property (nonatomic, readonly) MPNativeViewSizeHandler viewSizeHandler;

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings;

@end

NS_ASSUME_NONNULL_END
