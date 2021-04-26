//
//  PBMNativeAdVideo.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdVideo.h"
#import "PBMNativeAdVideo+Internal.h"
#import "PBMNativeAdAsset+Protected.h"
#import "PBMNativeAdAssetBoxingError.h"

#import "PBMMediaData.h"
#import "PBMMediaData+Internal.h"

@implementation PBMNativeAdVideo

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(PBMNativeAdMarkupAsset *)nativeAdMarkupAsset
                                       nativeAdHooks:(PBMNativeAdMediaHooks *)nativeAdHooks
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!nativeAdMarkupAsset.video) {
        if (error) {
            *error = [PBMNativeAdAssetBoxingError noVideoInsideNativeAdMarkupAsset];
        }
        return nil;
    }
    if (!(self = [super initWithNativeAdMarkupAsset:nativeAdMarkupAsset error:error])) {
        return nil;
    }
    _mediaData = [[PBMMediaData alloc] initWithMediaAsset:nativeAdMarkupAsset nativeAdHooks:nativeAdHooks];
    return self;
}

@end
