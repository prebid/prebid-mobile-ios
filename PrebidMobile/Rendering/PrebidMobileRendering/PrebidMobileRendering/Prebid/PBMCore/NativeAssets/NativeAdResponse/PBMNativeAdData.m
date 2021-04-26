//
//  PBMNativeAdData.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdData.h"
#import "PBMNativeAdAsset+Protected.h"
#import "PBMNativeAdAssetBoxingError.h"

@implementation PBMNativeAdData

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(PBMNativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!nativeAdMarkupAsset.data) {
        if (error) {
            *error = [PBMNativeAdAssetBoxingError noDataInsideNativeAdMarkupAsset];
        }
        return nil;
    }
    
    return (self = [super initWithNativeAdMarkupAsset:nativeAdMarkupAsset error:error]);
}

// MARK: - Public properties

- (NSNumber *)dataType {
    return self.nativeAdMarkupAsset.data.dataType;
}

- (NSString *)value {
    return self.nativeAdMarkupAsset.data.value ?: @"";
}

- (NSNumber *)length {
    return self.nativeAdMarkupAsset.data.length;
}

- (NSDictionary<NSString *,id> *)dataExt {
    return self.nativeAdMarkupAsset.data.ext;
}

@end
