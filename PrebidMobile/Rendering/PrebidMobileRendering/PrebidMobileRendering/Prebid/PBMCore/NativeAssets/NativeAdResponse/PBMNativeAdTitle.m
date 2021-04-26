//
//  PBMNativeAdTitle.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdTitle.h"
#import "PBMNativeAdAsset+Protected.h"
#import "PBMNativeAdAssetBoxingError.h"

@implementation PBMNativeAdTitle

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(PBMNativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!nativeAdMarkupAsset.title) {
        if (error) {
            *error = [PBMNativeAdAssetBoxingError noTitleInsideNativeAdMarkupAsset];
        }
        return nil;
    }
    
    return (self = [super initWithNativeAdMarkupAsset:nativeAdMarkupAsset error:error]);
}

// MARK: - Public properties

- (NSString *)text {
    return self.nativeAdMarkupAsset.title.text ?: @"";
}

- (NSNumber *)length {
    return self.nativeAdMarkupAsset.title.length;
}

- (NSDictionary<NSString *,id> *)titleExt {
    return self.nativeAdMarkupAsset.title.ext;
}

@end
