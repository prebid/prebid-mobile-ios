//
//  OXANativeAdData.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdData.h"
#import "OXANativeAdAsset+Protected.h"
#import "OXANativeAdAssetBoxingError.h"

@implementation OXANativeAdData

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(OXANativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!nativeAdMarkupAsset.data) {
        if (error) {
            *error = [OXANativeAdAssetBoxingError noDataInsideNativeAdMarkupAsset];
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
