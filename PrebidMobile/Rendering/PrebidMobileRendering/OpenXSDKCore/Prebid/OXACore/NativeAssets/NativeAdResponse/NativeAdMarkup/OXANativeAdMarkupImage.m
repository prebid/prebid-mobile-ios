//
//  OXANativeAdMarkupImage.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdMarkupImage.h"

#import "OXMConstants.h"
#import "OXMLog.h"

@implementation OXANativeAdMarkupImage

- (instancetype)initWithUrl:(NSString *)url {
    if (!(self = [super init])) {
        return nil;
    }
    _url = [url copy];
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _imageType = jsonDictionary[@"type"];
    _width = jsonDictionary[@"w"];
    _height = jsonDictionary[@"h"];
    _url = [jsonDictionary[@"url"] copy];
    _ext = jsonDictionary[@"ext"];
    
    if (!_url) {
        OXMLogWarn(@"Required property 'url' is absent in jsonDict for nativeAsset.image");
    }
    if (error) {
        *error = nil;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    OXANativeAdMarkupImage *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (self.imageType == other.imageType
                && objComparator(^(OXANativeAdMarkupImage *src) { return src.width; })
                && objComparator(^(OXANativeAdMarkupImage *src) { return src.height; })
                && objComparator(^(OXANativeAdMarkupImage *src) { return src.url; })
                && objComparator(^(OXANativeAdMarkupImage *src) { return src.ext; })
                )
            );
}

@end
