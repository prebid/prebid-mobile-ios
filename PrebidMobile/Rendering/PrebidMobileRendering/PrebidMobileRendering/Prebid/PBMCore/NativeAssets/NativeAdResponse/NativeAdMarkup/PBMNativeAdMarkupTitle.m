//
//  PBMNativeAdMarkupTitle.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdMarkupTitle.h"

#import "PBMConstants.h"
#import "PBMLog.h"

@implementation PBMNativeAdMarkupTitle

- (instancetype)initWithText:(NSString *)text {
    if (!(self = [super init])) {
        return nil;
    }
    _text = [text copy];
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _length = jsonDictionary[@"len"];
    _text = [jsonDictionary[@"text"] copy];
    _ext = jsonDictionary[@"ext"];
    
    if (!_text) {
        PBMLogWarn(@"Required property 'text' is absent in jsonDict for nativeAsset.title");
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
    PBMNativeAdMarkupTitle *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(PBMNativeAdMarkupTitle *src) { return src.text; })
                && objComparator(^(PBMNativeAdMarkupTitle *src) { return src.length; })
                && objComparator(^(PBMNativeAdMarkupTitle *src) { return src.ext; })
                )
            );
}

@end
