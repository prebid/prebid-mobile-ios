//
//  OXANativeAdImage.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdImage.h"
#import "OXANativeAdAsset+Protected.h"
#import "OXANativeAdAssetBoxingError.h"

@implementation OXANativeAdImage

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(OXANativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!nativeAdMarkupAsset.img) {
        if (error) {
            *error = [OXANativeAdAssetBoxingError noImageInsideNativeAdMarkupAsset];
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
