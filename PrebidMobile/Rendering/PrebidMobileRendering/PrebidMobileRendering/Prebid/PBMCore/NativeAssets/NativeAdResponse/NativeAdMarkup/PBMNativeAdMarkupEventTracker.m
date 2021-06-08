//
//  PBMNativeAdMarkupEventTracker.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdMarkupEventTracker.h"

#import "PBMError.h"
#import "PBMConstants.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@implementation PBMNativeAdMarkupEventTracker

- (instancetype)initWithEvent:(NSInteger)event method:(NSInteger)method url:(NSString *)url
{
    if (!(self = [super init])) {
        return nil;
    }
    _event = event;
    _method = method;
    _url = [url copy];
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSNumber * const eventObj = jsonDictionary[@"event"];
    if (!eventObj) {
        if (error) {
            *error = [PBMError noEventForNativeAdMarkupEventTracker];
        }
        return nil;
    }
    NSNumber * const methodObj = jsonDictionary[@"method"];
    if (!methodObj) {
        if (error) {
            *error = [PBMError noMethodForNativeAdMarkupEventTracker];
        }
        return nil;
    }
    NSNumber * const url = jsonDictionary[@"url"];
    if (!url) {
        if (error) {
            *error = [PBMError noUrlForNativeAdMarkupEventTracker];
        }
        return nil;
    }
    if (error) {
        *error = nil;
    }
    if (!(self = [super init])) {
        return nil;
    }
    _event = eventObj.integerValue;
    _method = methodObj.integerValue;
    _url = [url copy];
    _customdata = jsonDictionary[@"customdata"];
    _ext = jsonDictionary[@"ext"];
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    PBMNativeAdMarkupEventTracker *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (self.event == other.event
                && self.method == other.method
                && objComparator(^(PBMNativeAdMarkupEventTracker *src) { return src.url; })
                && objComparator(^(PBMNativeAdMarkupEventTracker *src) { return src.customdata; })
                && objComparator(^(PBMNativeAdMarkupEventTracker *src) { return src.ext; })
                )
            );
}

@end
