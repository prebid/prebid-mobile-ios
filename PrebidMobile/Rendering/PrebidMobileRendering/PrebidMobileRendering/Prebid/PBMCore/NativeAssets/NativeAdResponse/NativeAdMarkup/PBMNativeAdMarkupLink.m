//
//  PBMNativeAdMarkupLink.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdMarkupLink.h"

#import "PBMConstants.h"
#import "PBMLog.h"

@implementation PBMNativeAdMarkupLink

- (instancetype)initWithUrl:(NSString *)url {
    if (!(self = [super init])) {
        return nil;
    }
    _url = [url copy];
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary
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
        PBMLogWarn(@"Required property 'url' is absent in jsonDict for native ad link");
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
    PBMNativeAdMarkupLink *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(PBMNativeAdMarkupLink *src) { return src.url; })
                && objComparator(^(PBMNativeAdMarkupLink *src) { return src.clicktrackers; })
                && objComparator(^(PBMNativeAdMarkupLink *src) { return src.fallback; })
                && objComparator(^(PBMNativeAdMarkupLink *src) { return src.ext; })
                )
            );
}

@end
