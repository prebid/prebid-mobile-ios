//
//  PBMNativeAdImage.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdImage.h"
#import "PBMNativeAdAsset+Protected.h"
#import "PBMNativeAdAssetBoxingError.h"

@implementation PBMNativeAdImage

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(PBMNativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!nativeAdMarkupAsset.img) {
        if (error) {
            *error = [PBMNativeAdAssetBoxingError noImageInsideNativeAdMarkupAsset];
        }
        return nil;
    }
    
    return (self = [super initWithNativeAdMarkupAsset:nativeAdMarkupAsset error:error]);
}

// MARK: - Public properties

- (NSNumber *)imageType {
    return self.nativeAdMarkupAsset.img.imageType;
}

- (NSNumber *)width {
    return self.nativeAdMarkupAsset.img.width;
}

- (NSNumber *)height {
    return self.nativeAdMarkupAsset.img.height;
}

- (NSString *)url {
    return self.nativeAdMarkupAsset.img.url ?: @"";
}

- (NSDictionary<NSString *,id> *)imageExt {
    return self.nativeAdMarkupAsset.img.ext;
}

@end
