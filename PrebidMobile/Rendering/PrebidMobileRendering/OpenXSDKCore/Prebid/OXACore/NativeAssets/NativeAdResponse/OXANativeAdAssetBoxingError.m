//
//  OXANativeAdAssetBoxingError.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdAssetBoxingError.h"
#import "OXAErrorFamily.h"

@implementation OXANativeAdAssetBoxingError

+ (NSError *)noDataInsideNativeAdMarkupAsset {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:oxaErrorCode(kOXAErrorFamily_IncompatibleNativeAdMarkupAsset, 1)
                           userInfo:@{ NSLocalizedDescriptionKey: @"NativeAdMarkupAsset has no 'data'", }];
}

+ (NSError *)noImageInsideNativeAdMarkupAsset {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:oxaErrorCode(kOXAErrorFamily_IncompatibleNativeAdMarkupAsset, 2)
                           userInfo:@{ NSLocalizedDescriptionKey: @"NativeAdMarkupAsset has no 'img'", }];
}

+ (NSError *)noTitleInsideNativeAdMarkupAsset {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:oxaErrorCode(kOXAErrorFamily_IncompatibleNativeAdMarkupAsset, 3)
                           userInfo:@{ NSLocalizedDescriptionKey: @"NativeAdMarkupAsset has no 'title'", }];
}

+ (NSError *)noVideoInsideNativeAdMarkupAsset {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:oxaErrorCode(kOXAErrorFamily_IncompatibleNativeAdMarkupAsset, 4)
                           userInfo:@{ NSLocalizedDescriptionKey: @"NativeAdMarkupAsset has no 'video'", }];
}

@end
