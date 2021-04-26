//
//  PBMNativeAdAssetBoxingError.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdAssetBoxingError.h"
#import "PBMErrorFamily.h"

@implementation PBMNativeAdAssetBoxingError

+ (NSError *)noDataInsideNativeAdMarkupAsset {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:pbmErrorCode(kPBMErrorFamily_IncompatibleNativeAdMarkupAsset, 1)
                           userInfo:@{ NSLocalizedDescriptionKey: @"NativeAdMarkupAsset has no 'data'", }];
}

+ (NSError *)noImageInsideNativeAdMarkupAsset {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:pbmErrorCode(kPBMErrorFamily_IncompatibleNativeAdMarkupAsset, 2)
                           userInfo:@{ NSLocalizedDescriptionKey: @"NativeAdMarkupAsset has no 'img'", }];
}

+ (NSError *)noTitleInsideNativeAdMarkupAsset {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:pbmErrorCode(kPBMErrorFamily_IncompatibleNativeAdMarkupAsset, 3)
                           userInfo:@{ NSLocalizedDescriptionKey: @"NativeAdMarkupAsset has no 'title'", }];
}

+ (NSError *)noVideoInsideNativeAdMarkupAsset {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:pbmErrorCode(kPBMErrorFamily_IncompatibleNativeAdMarkupAsset, 4)
                           userInfo:@{ NSLocalizedDescriptionKey: @"NativeAdMarkupAsset has no 'video'", }];
}

@end
