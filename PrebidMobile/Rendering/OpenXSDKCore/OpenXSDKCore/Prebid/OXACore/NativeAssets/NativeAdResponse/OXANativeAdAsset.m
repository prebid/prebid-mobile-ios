//
//  OXANativeAdAsset.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdAsset.h"
#import "OXANativeAdAsset+FromMarkup.h"
#import "OXANativeAdAsset+Protected.h"

@implementation OXANativeAdAsset

// MARK: - Lifecycle

- (nullable instancetype)initWithNativeAdMarkupAsset:(OXANativeAdMarkupAsset *)nativeAdMarkupAsset
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
    OXANativeAdAsset *other = object;
    return (self == other) || [self.nativeAdMarkupAsset isEqual:other.nativeAdMarkupAsset];
}

// MARK: - Public properties

- (NSNumber *)assetID {
    return self.nativeAdMarkupAsset.assetID;
}

- (NSNumber *)required {
    return self.nativeAdMarkupAsset.required;
}

- (OXANativeAdMarkupLink *)link {
    return self.nativeAdMarkupAsset.link;
}

- (NSDictionary<NSString *, id> *)assetExt {
    return self.nativeAdMarkupAsset.ext;
}

@end
