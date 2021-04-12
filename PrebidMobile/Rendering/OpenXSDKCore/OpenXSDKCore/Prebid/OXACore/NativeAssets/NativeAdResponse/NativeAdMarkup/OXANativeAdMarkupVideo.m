//
//  OXANativeAdMarkupVideo.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdMarkupVideo.h"

#import "OXMConstants.h"
#import "OXMLog.h"

@implementation OXANativeAdMarkupVideo

// MARK: - Lifecycle

- (instancetype)initWithVastTag:(NSString *)vasttag {
    if (!(self = [super init])) {
        return nil;
    }
    _vasttag = [vasttag copy];
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _vasttag = [jsonDictionary[@"vasttag"] copy];
    
    if (!_vasttag) {
        OXMLogWarn(@"Required property 'vasttag' is absent in jsonDict for nativeAsset.video");
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
    OXANativeAdMarkupVideo *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(OXANativeAdMarkupVideo *src) { return src.vasttag; })
                )
            );
}

@end
