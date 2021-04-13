//
//  OXANativeAdMarkupLink.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdMarkupLink.h"

#import "OXMConstants.h"
#import "OXMLog.h"

@implementation OXANativeAdMarkupLink

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
    _clicktrackers = [jsonDictionary[@"clicktrackers"] copy];
    _fallback = [jsonDictionary[@"fallback"] copy];
    _url = [jsonDictionary[@"url"] copy];
    _ext = jsonDictionary[@"ext"];
    
    if (!_url) {
        OXMLogWarn(@"Required property 'url' is absent in jsonDict for native ad link");
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
    OXANativeAdMarkupLink *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(OXANativeAdMarkupLink *src) { return src.url; })
                && objComparator(^(OXANativeAdMarkupLink *src) { return src.clicktrackers; })
                && objComparator(^(OXANativeAdMarkupLink *src) { return src.fallback; })
                && objComparator(^(OXANativeAdMarkupLink *src) { return src.ext; })
                )
            );
}

@end
