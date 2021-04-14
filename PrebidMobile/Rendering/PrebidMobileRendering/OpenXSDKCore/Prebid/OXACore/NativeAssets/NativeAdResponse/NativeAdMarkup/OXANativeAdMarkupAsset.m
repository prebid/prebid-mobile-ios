//
//  OXANativeAdMarkupAsset.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdMarkupAsset.h"

#import "OXMLog.h"
#import "OXMConstants.h"

@implementation OXANativeAdMarkupAsset

- (instancetype)initWithData:(OXANativeAdMarkupData *)data {
    if (!(self = [super init])) {
        return nil;
    }
    _data = data;
    return self;
}

- (instancetype)initWithImage:(OXANativeAdMarkupImage *)image {
    if (!(self = [super init])) {
        return nil;
    }
    _img = image;
    return self;
}

- (instancetype)initWithTitle:(OXANativeAdMarkupTitle *)title {
    if (!(self = [super init])) {
        return nil;
    }
    _title = title;
    return self;
}

- (instancetype)initWithVideo:(OXANativeAdMarkupVideo *)video {
    if (!(self = [super init])) {
        return nil;
    }
    _video = video;
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _assetID = jsonDictionary[@"id"];
    _required = jsonDictionary[@"required"];
    _ext = jsonDictionary[@"ext"];
    
    OXMJsonDictionary * const dataJson = jsonDictionary[@"data"];
    if (dataJson) {
        // TODO: Handle (optional) data parsing error?
        _data = [[OXANativeAdMarkupData alloc] initWithJsonDictionary:dataJson error:nil];
    }
    
    OXMJsonDictionary * const imageJson = jsonDictionary[@"img"];
    if (imageJson) {
        // TODO: Handle (optional) image parsing error?
        _img = [[OXANativeAdMarkupImage alloc] initWithJsonDictionary:imageJson error:nil];
    }
    
    OXMJsonDictionary * const titleJson = jsonDictionary[@"title"];
    if (titleJson) {
        // TODO: Handle (optional) title parsing error?
        _title = [[OXANativeAdMarkupTitle alloc] initWithJsonDictionary:titleJson error:nil];
    }
    
    OXMJsonDictionary * const videoJson = jsonDictionary[@"video"];
    if (videoJson) {
        // TODO: Handle (optional) video parsing error?
        _video = [[OXANativeAdMarkupVideo alloc] initWithJsonDictionary:videoJson error:nil];
    }
    
    if (!(_data || _img || _title || _video)) {
        OXMLogWarn(@"'data', 'img', 'title' or 'video' must be present in JSON for nativeAsset, but all 4 are absent");
    }
    
    OXMJsonDictionary * const linkJson = jsonDictionary[@"link"];
    if (linkJson) {
        // TODO: Handle (optional) link parsing error?
        _link = [[OXANativeAdMarkupLink alloc] initWithJsonDictionary:linkJson error:nil];
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
    OXANativeAdMarkupAsset *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(OXANativeAdMarkupAsset *src) { return src.assetID; })
                && objComparator(^(OXANativeAdMarkupAsset *src) { return src.required; })
                && objComparator(^(OXANativeAdMarkupAsset *src) { return src.title; })
                && objComparator(^(OXANativeAdMarkupAsset *src) { return src.img; })
                && objComparator(^(OXANativeAdMarkupAsset *src) { return src.video; })
                && objComparator(^(OXANativeAdMarkupAsset *src) { return src.data; })
                && objComparator(^(OXANativeAdMarkupAsset *src) { return src.link; })
                && objComparator(^(OXANativeAdMarkupAsset *src) { return src.ext; })
                )
            );
}

@end
