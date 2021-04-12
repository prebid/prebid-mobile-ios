//
//  OXAMoPubNativeAdRenderer.h
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <MoPub/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@class MPNativeAdRendererConfiguration;
@class MPStaticNativeAdRendererSettings;

@interface OXAMoPubNativeAdRenderer : NSObject <MPNativeAdRenderer>

@property (nonatomic, readonly) MPNativeViewSizeHandler viewSizeHandler;

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings;

@end

NS_ASSUME_NONNULL_END
