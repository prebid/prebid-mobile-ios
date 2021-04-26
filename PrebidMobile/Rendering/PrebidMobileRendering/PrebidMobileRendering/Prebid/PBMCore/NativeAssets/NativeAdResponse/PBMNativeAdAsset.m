//
//  PBMNativeAdAsset.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdAsset.h"
#import "PBMNativeAdAsset+FromMarkup.h"
#import "PBMNativeAdAsset+Protected.h"

@implementation PBMNativeAdAsset

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(PBMNativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _nativeAdMarkupAsset = nativeAdMarkupAsset;
    if (error) {
        *error = nil;
    }
    return self;
}

// MARK: - NSObject

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    PBMNativeAdAsset *other = object;
    return (self == other) || [self.nativeAdMarkupAsset isEqual:other.nativeAdMarkupAsset];
}

// MARK: - Public properties

- (NSNumber *)assetID {
    return self.nativeAdMarkupAsset.assetID;
}

- (NSNumber *)required {
    return self.nativeAdMarkupAsset.required;
}

- (PBMNativeAdMarkupLink *)link {
    return self.nativeAdMarkupAsset.link;
}

- (NSDictionary<NSString *, id> *)assetExt {
    return self.nativeAdMarkupAsset.ext;
}

@end
