//
//  OXANativeAdMarkupTitle.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdMarkupTitle.h"

#import "OXMConstants.h"
#import "OXMLog.h"

@implementation OXANativeAdMarkupTitle

- (instancetype)initWithText:(NSString *)text {
    if (!(self = [super init])) {
        return nil;
    }
    _text = [text copy];
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _length = jsonDictionary[@"len"];
    _text = [jsonDictionary[@"text"] copy];
    _ext = jsonDictionary[@"ext"];
    
    if (!_text) {
        OXMLogWarn(@"Required property 'text' is absent in jsonDict for nativeAsset.title");
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
    OXANativeAdMarkupTitle *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(OXANativeAdMarkupTitle *src) { return src.text; })
                && objComparator(^(OXANativeAdMarkupTitle *src) { return src.length; })
                && objComparator(^(OXANativeAdMarkupTitle *src) { return src.ext; })
                )
            );
}

@end
