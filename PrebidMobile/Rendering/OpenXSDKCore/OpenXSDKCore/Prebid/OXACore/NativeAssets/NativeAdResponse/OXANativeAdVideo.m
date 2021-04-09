//
//  OXANativeAdVideo.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdVideo.h"
#import "OXANativeAdVideo+Internal.h"
#import "OXANativeAdAsset+Protected.h"
#import "OXANativeAdAssetBoxingError.h"

#import "OXAMediaData.h"
#import "OXAMediaData+Internal.h"

@implementation OXANativeAdVideo

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(OXANativeAdMarkupAsset *)nativeAdMarkupAsset
                                       nativeAdHooks:(OXANativeAdMediaHooks *)nativeAdHooks
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!nativeAdMarkupAsset.video) {
        if (error) {
            *error = [OXANativeAdAssetBoxingError noVideoInsideNativeAdMarkupAsset];
        }
        return nil;
    }
    if (!(self = [super initWithNativeAdMarkupAsset:nativeAdMarkupAsset error:error])) {
        return nil;
    }
    _mediaData = [[OXAMediaData alloc] initWithMediaAsset:nativeAdMarkupAsset nativeAdHooks:nativeAdHooks];
    return self;
}

@end
